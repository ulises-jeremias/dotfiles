#!/usr/bin/env bash
# Start the Hyprland plus shell session inside the VM and verify both ends
# are alive. Restarts from a clean slate so repeat runs are deterministic.
# Usage: start-session.sh [--dry-run]

set -euo pipefail

VM_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/vm/lib/env.sh
# shellcheck disable=SC1091 # path resolves at runtime; use shellcheck -x to follow it
source "${VM_LIB_DIR}/env.sh"

if [[ "${1:-}" == "--help" ]]; then
    echo "usage: start-session.sh [--dry-run]"
    exit 0
fi
if [[ "${1:-}" == "--dry-run" ]]; then
    export VM_DRY_RUN=1
fi

if vm_is_dry_run; then
    echo "dry-run: would restart Hyprland (DRM backend) in the guest"
    echo "dry-run: would start the deployed shell with qs (fallback: quickshell)"
    echo "dry-run: would expose the native plugin via QML2_IMPORT_PATH=${VM_GUEST_PREFIX}/lib/qt6/qml"
    echo "dry-run: would verify Hyprland plus shell processes are alive"
    exit 0
fi

vm_ssh_ready || {
    echo "error: VM SSH is not up. Run lib/boot.sh + lib/wait-ssh.sh first." >&2
    exit 1
}

echo "==> restarting session cleanly (deterministic state)"
# shellcheck disable=SC2016
vm_ssh 'pkill -x qs 2> /dev/null; pkill -x quickshell 2> /dev/null; \
    pkill -x wf-recorder 2> /dev/null; pkill -x Hyprland 2> /dev/null; sleep 3' > /dev/null || true

echo "==> starting Hyprland (DRM backend)"
# shellcheck disable=SC2016
vm_ssh_bg 'export WLR_BACKENDS=drm && export WLR_RENDERER=gles2 && \
    export XDG_CONFIG_HOME=$HOME/.config && \
    nohup Hyprland > /tmp/hypr.log 2>&1 < /dev/null & disown'

if ! vm_session_ready; then
    echo "error: Hyprland did not start. Check /tmp/hypr.log inside the VM." >&2
    vm_ssh 'tail -n 20 /tmp/hypr.log' >&2 || true
    exit 1
fi

if vm_shell_ready; then
    echo "==> shell already running"
else
    echo "==> waiting for the Wayland socket (Hyprland creates it after pgrep shows up)"
    for _ in $(seq 1 30); do
        # shellcheck disable=SC2016
        vm_ssh 'test -S "$XDG_RUNTIME_DIR/wayland-1"' > /dev/null 2>&1 && break
        sleep 1
    done
    # shellcheck disable=SC2016
    vm_ssh 'test -S "$XDG_RUNTIME_DIR/wayland-1"' || {
        echo "error: Wayland socket never appeared" >&2
        exit 1
    }

    echo "==> starting the shell from the deployed checkout"
    # The checkout root is the Quickshell config dir. Guest-side variables
    # stay escaped so they expand inside the VM, not on the host.
    # The native plugin (built by deploy-shell.sh into the guest prefix) is
    # exposed through QML2_IMPORT_PATH; an absent dir is harmless.
    # shellcheck disable=SC2016 # remote $HOME must expand inside the guest
    guest_home="$(vm_ssh 'printf %s "$HOME"')"
    guest_qml_path="${VM_GUEST_PREFIX//\$HOME/${guest_home}}/lib/qt6/qml"
    vm_ssh_bg "$(vm_hypr_env)
export QML2_IMPORT_PATH=${guest_qml_path}:\$QML2_IMPORT_PATH
if command -v qs > /dev/null; then QS_BIN=qs; else QS_BIN=quickshell; fi
cd \$HOME/.config/quickshell && nohup \$QS_BIN > /tmp/qs.log 2>&1 < /dev/null & disown"
    sleep 10
fi

if vm_shell_ready; then
    echo "==> session is up (Hyprland plus shell)"
else
    echo "error: shell did not start. Check /tmp/qs.log inside the VM." >&2
    vm_ssh 'tail -n 20 /tmp/qs.log' >&2 || true
    exit 1
fi
