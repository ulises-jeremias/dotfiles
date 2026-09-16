#!/usr/bin/env bash
# Deploy the repo checkout under test into the VM as the live Quickshell
# config, plus the minimal harness Hyprland config for the test session.
# Usage: deploy-shell.sh [--dry-run]
#
# Only tracked plus untracked-not-ignored files travel (exactly the working
# tree under test); build output, the harness cache, and guest state stay out.

set -euo pipefail

VM_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/vm/lib/env.sh
# shellcheck disable=SC1091 # path resolves at runtime; use shellcheck -x to follow it
source "${VM_LIB_DIR}/env.sh"

if [[ "${1:-}" == "--help" ]]; then
    echo "usage: deploy-shell.sh [--dry-run]"
    exit 0
fi
if [[ "${1:-}" == "--dry-run" ]]; then
    export VM_DRY_RUN=1
fi

if vm_is_dry_run; then
    echo "dry-run: would copy ${SHELL_ROOT} working tree to guest ~/.config/quickshell"
    echo "dry-run: would install tests/vm/guest/hyprland.conf to guest ~/.config/hypr/hyprland.conf"
    echo "dry-run: would build the native QML plugin in the guest (prefix ${VM_GUEST_PREFIX}, skipped when unchanged)"
    if [[ -n "${HX_CONFIG_PIN}" || -n "${HX_MATERIALIZE_BIN}" ]]; then
        echo "dry-run: would materialize the config pin (${HX_CONFIG_PIN:-override}) in the guest"
        echo "dry-run: would validate the guest root with horneroctl (${HX_HOREROCTL_BIN:-absent: script-only})"
        echo "dry-run: would refuse a guest ulises-jeremias/dotfiles clone"
        echo "dry-run: would install factory defaults into the guest session (fresh-boot simulation)"
        echo "dry-run: would render factory wallpapers on the host and set the dark pointer"
        echo "dry-run: would re-install the harness Hyprland config over factory defaults"
    fi
    exit 0
fi

vm_ssh_ready || {
    echo "error: VM SSH is not up. Run lib/boot.sh + lib/wait-ssh.sh first." >&2
    exit 1
}

echo "==> copying shell working tree into the VM (~/.config/quickshell)"
cd "${SHELL_ROOT}"
git ls-files -co --exclude-standard | tar cf - -T - 2> /dev/null \
    | vm_ssh 'rm -rf ~/.config/quickshell && mkdir -p ~/.config/quickshell && tar xf - -C ~/.config/quickshell'

echo "==> installing harness Hyprland config (test session only)"
# Fresh cloud images have no ~/.config/hypr yet and scp cannot create it.
vm_ssh 'mkdir -p ~/.config/hypr'
vm_scp "${VM_DIR}/guest/hyprland.conf" "${VM_SSH_USER}@127.0.0.1:~/.config/hypr/hyprland.conf"

echo "==> verifying the deployed shell"
# shellcheck disable=SC2016
vm_ssh 'test -f ~/.config/quickshell/shell.qml && test -f ~/.config/hypr/hyprland.conf' || {
    echo "error: deployed tree is missing shell.qml or hyprland.conf" >&2
    exit 1
}

# --- native QML plugin (built from the deployed checkout, user prefix) ------
# Rebuilt only when the working tree changed (marker in the guest cache).
# shellcheck disable=SC2016 # remote $HOME must expand inside the guest
guest_home="$(vm_ssh 'printf %s "$HOME"')"
guest_prefix="${VM_GUEST_PREFIX//\$HOME/${guest_home}}"
tree_id="$(git -C "${SHELL_ROOT}" rev-parse HEAD):$(git -C "${SHELL_ROOT}" status --porcelain | sha256sum | awk '{ print $1 }')"
# shellcheck disable=SC2016
if vm_ssh "test -f ~/.cache/vm-harness-plugin-id && [ \"\$(cat ~/.cache/vm-harness-plugin-id)\" = '${tree_id}' ]" > /dev/null 2>&1; then
    echo "==> native plugin up to date, skipping rebuild"
else
    echo "==> building the native QML plugin in the guest (prefix ${guest_prefix})"
    # shellcheck disable=SC2016
    vm_ssh 'command -v cmake > /dev/null' || {
        echo "error: cmake missing in guest (provision.sh installs it)" >&2
        exit 1
    }
    # libcava is AUR-only: install it when the AUR knows it, else let the
    # build tell us whether it was actually required.
    # shellcheck disable=SC2016
    vm_ssh 'yay -Si libcava > /dev/null 2>&1 && yay -S --noconfirm --needed libcava || true'
    # Guest-side variables stay escaped so they expand inside the VM.
    if vm_ssh "set -e
cd ~/.config/quickshell
cmake -S . -B ~/.cache/hornero-shell-build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX='${guest_prefix}' -DINSTALL_QMLDIR='${guest_prefix}/lib/qt6/qml' -DINSTALL_LIBDIR='${guest_prefix}/lib/hornero' -DINSTALL_QSCONFDIR='${guest_prefix}/etc/xdg/quickshell/hornero'
cmake --build ~/.cache/hornero-shell-build -j\$(nproc)
cmake --install ~/.cache/hornero-shell-build"; then
        vm_ssh "printf %s '${tree_id}' > ~/.cache/vm-harness-plugin-id"
        echo "==> native plugin installed"
    else
        echo "warning: native plugin build failed; the shell starts without Hornero.* QML modules" >&2
    fi
fi

# --- pinned composition (opt-in via HX_CONFIG_PIN / HX_MATERIALIZE_BIN) -----
# Materializes the HorneroOS/config pin inside the guest and validates it
# with horneroctl. The guest never clones the personal dotfiles repository:
# the pin travels as a file copy and the guard below fails the deploy when
# any guest checkout carries that origin.
if [[ -n "${HX_CONFIG_PIN}" || -n "${HX_MATERIALIZE_BIN}" ]]; then
    echo "==> resolving the config pin for the guest composition"
    if [[ -n "${HX_MATERIALIZE_BIN}" ]]; then
        [[ -x "${HX_MATERIALIZE_BIN}" ]] || {
            echo "error: HX_MATERIALIZE_BIN is not executable: ${HX_MATERIALIZE_BIN}" >&2
            exit 1
        }
        HX_CONFIG_SRC="$(cd "$(dirname "${HX_MATERIALIZE_BIN}")/.." && pwd)"
        [[ -x "${HX_CONFIG_SRC}/scripts/materialize.sh" ]] || {
            echo "error: HX_MATERIALIZE_BIN must live in <config-checkout>/scripts/: ${HX_MATERIALIZE_BIN}" >&2
            exit 1
        }
        echo "==> using config checkout at ${HX_CONFIG_SRC}"
    else
        read -r HX_PIN_REPO HX_PIN_SHA <<< "${HX_CONFIG_PIN}"
        [[ "${HX_PIN_SHA:-}" =~ ^[0-9a-f]{40}$ ]] || {
            echo "error: HX_CONFIG_PIN must be '<repo-url> <40-hex-sha>', got: '${HX_CONFIG_PIN}'" >&2
            exit 1
        }
        HX_CONFIG_SRC="${VM_CACHE_DIR}/hx-config-pin"
        if [[ -d "${HX_CONFIG_SRC}/.git" && "$(git -C "${HX_CONFIG_SRC}" rev-parse HEAD 2> /dev/null)" == "${HX_PIN_SHA}" ]]; then
            echo "==> config pin already at ${HX_PIN_SHA:0:8}"
        else
            echo "==> fetching config pin ${HX_PIN_SHA:0:8}"
            rm -rf "${HX_CONFIG_SRC}"
            git init -q "${HX_CONFIG_SRC}"
            git -C "${HX_CONFIG_SRC}" remote add origin "${HX_PIN_REPO}"
            git -C "${HX_CONFIG_SRC}" fetch -q --depth 1 origin "${HX_PIN_SHA}"
            git -C "${HX_CONFIG_SRC}" checkout -q "${HX_PIN_SHA}"
            [[ "$(git -C "${HX_CONFIG_SRC}" rev-parse HEAD)" == "${HX_PIN_SHA}" ]] || {
                echo "error: config pin checkout mismatch" >&2
                exit 1
            }
        fi
    fi

    echo "==> copying the config pin into the guest (~/hx-config)"
    tar cf - --exclude=.git -C "${HX_CONFIG_SRC}" . \
        | vm_ssh 'rm -rf ~/hx-config ~/hx-root && mkdir -p ~/hx-config && tar xf - -C ~/hx-config'
    # shellcheck disable=SC2016
    vm_ssh 'test -x ~/hx-config/scripts/materialize.sh' || {
        echo "error: config pin is missing scripts/materialize.sh" >&2
        exit 1
    }

    if [[ -n "${HX_HOREROCTL_BIN}" ]]; then
        [[ -x "${HX_HOREROCTL_BIN}" ]] || {
            echo "error: HX_HOREROCTL_BIN is not executable: ${HX_HOREROCTL_BIN}" >&2
            exit 1
        }
        echo "==> copying horneroctl into the guest"
        vm_scp "${HX_HOREROCTL_BIN}" "${VM_SSH_USER}@127.0.0.1:~/horneroctl"
        # shellcheck disable=SC2016
        vm_ssh 'test -x ~/horneroctl' || {
            echo "error: horneroctl did not land executable in the guest" >&2
            exit 1
        }
        echo "==> materializing the composition in the guest"
        # shellcheck disable=SC2016
        vm_ssh 'HORNERO_MATERIALIZE_BIN=$HOME/hx-config/scripts/materialize.sh $HOME/horneroctl config materialize --dest $HOME/hx-root --yes' || {
            echo "error: guest composition materialize failed" >&2
            exit 1
        }
        echo "==> validating the materialized root in the guest"
        # shellcheck disable=SC2016
        vm_ssh 'CTL=$HOME/horneroctl
export HOME=$HOME/hx-root
unset XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME
"$CTL" config paths > /dev/null && "$CTL" config validate' || {
            echo "error: guest composition validation failed" >&2
            exit 1
        }
        # shell.json is user-created; seed an empty object so `config show`
        # exercises the parse path without faking user content.
        # shellcheck disable=SC2016
        vm_ssh 'CTL=$HOME/horneroctl
export HOME=$HOME/hx-root
unset XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME
mkdir -p $HOME/.config/hornero
printf "{}\n" > $HOME/.config/hornero/shell.json
"$CTL" config show > /dev/null' || {
            echo "error: guest composition show failed" >&2
            exit 1
        }
        echo "==> guest composition materialized and validated"
    else
        echo "warning: HX_HOREROCTL_BIN is unset; materializing via the script without horneroctl validation" >&2
        # shellcheck disable=SC2016
        vm_ssh 'bash ~/hx-config/scripts/materialize.sh --dest ~/hx-root' || {
            echo "error: guest composition materialize failed" >&2
            exit 1
        }
    fi

    echo "==> verifying the guest never cloned the personal dotfiles"
    vm_ssh 'test ! -e ~/dotfiles' || {
        echo "error: ~/dotfiles exists in the guest: refusing" >&2
        exit 1
    }
    # Only clone origins count: config files may mention the migration
    # source in comments, so content greps would false-positive.
    # shellcheck disable=SC2016
    if vm_ssh 'test -n "$(find ~ -maxdepth 5 -path "*/.git/config" -exec grep -l "ulises-jeremias/dotfiles" {} + 2> /dev/null)"'; then
        echo "error: the guest holds a ulises-jeremias/dotfiles clone:" >&2
        # shellcheck disable=SC2016
        vm_ssh 'find ~ -maxdepth 5 -path "*/.git/config" -exec grep -l "ulises-jeremias/dotfiles" {} + 2> /dev/null' >&2 || true
        exit 1
    fi
    echo "==> guest composition is dotfiles-clone free"
    echo "==> installing factory defaults into the guest session"
    # Fresh-boot simulation: the product installer would materialize factory
    # defaults; the harness reproduces that state (GTK dark, kitty dark,
    # recolor, factory record) so the session shows the intentional desktop.
    # shellcheck disable=SC2016
    vm_ssh 'bash ~/hx-config/scripts/materialize.sh' || {
        echo "error: guest factory install failed" >&2
        exit 1
    }
    echo "==> rendering factory wallpapers and setting the dark pointer"
    if command -v rsvg-convert > /dev/null 2>&1 && [[ -x "${HX_CONFIG_SRC}/scripts/render-brand-assets.sh" ]]; then
        WALLS_DIR="$(mktemp -d)"
        "${HX_CONFIG_SRC}/scripts/render-brand-assets.sh" --wallpapers "$WALLS_DIR" > /dev/null || {
            echo "error: host wallpaper render failed" >&2
            exit 1
        }
        tar cf - -C "$WALLS_DIR" . \
            | vm_ssh 'mkdir -p ~/.local/share/hornero/wallpapers ~/.local/state/hornero/wallpaper && tar xf - -C ~/.local/share/hornero/wallpapers'
        rm -rf "$WALLS_DIR"
        # shellcheck disable=SC2016
        vm_ssh 'printf "%s\n" "$HOME/.local/share/hornero/wallpapers/hornero-dark/hornero-dark-01.png" > ~/.local/state/hornero/wallpaper/path' || {
            echo "error: guest wallpaper pointer failed" >&2
            exit 1
        }
    else
        echo "warning: rsvg-convert or render-brand-assets.sh absent; guest keeps the missing-wallpaper empty state" >&2
    fi
    echo "==> re-installing the harness Hyprland config over factory defaults"
    vm_scp "${VM_DIR}/guest/hyprland.conf" "${VM_SSH_USER}@127.0.0.1:~/.config/hypr/hyprland.conf"
fi
echo "==> shell deployed"
