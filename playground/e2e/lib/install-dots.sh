#!/usr/bin/env bash
# Install the dotfiles inside the VM the same way an end user would:
# copy the working tree over, then run ./install.sh (chezmoi init --apply).
#
# DOTS_E2E=1 selects the E2E install profile: full desktop (plugin builds,
# wallpapers link, hyprland stack installs) but non-interactive and with
# zero personal secrets (LastPass credentials and SSH keys stay out).

set -euo pipefail

E2E_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/env.sh
source "${E2E_LIB_DIR}/env.sh"

INSTALL_TIMEOUT="${E2E_INSTALL_TIMEOUT:-3600}"

e2e_ssh_ready || {
	echo "error: VM SSH is not up. Run lib/run.sh + lib/wait-ssh.sh first." >&2
	exit 1
}

echo "==> copying working tree into the VM (~/.dotfiles)"
cd "${DOTFILES_ROOT}"
# Tracked + untracked-not-ignored files: exactly the working tree under test.
git ls-files -co --exclude-standard | tar cf - -T - 2> /dev/null \
	| e2e_ssh 'rm -rf ~/.dotfiles && mkdir -p ~/.dotfiles && tar xf - -C ~/.dotfiles'

echo "==> launching end-user install (./install.sh with DOTS_E2E=1)"
# First-boot semantics: no prior chezmoi config/state, like a brand new user.
# Otherwise chezmoi prompts about files changed since the last apply and
# fails without a TTY.
# shellcheck disable=SC2016  # remote script, no local expansion wanted
e2e_ssh 'rm -rf ~/.config/chezmoi && cat > /tmp/run-e2e-install.sh << "EOF"
#!/usr/bin/env bash
cd "$HOME/.dotfiles"
DOTS_E2E=1 ./install.sh > /tmp/install.log 2>&1
echo $? > /tmp/install.exit
EOF
chmod +x /tmp/run-e2e-install.sh && rm -f /tmp/install.exit' > /dev/null
e2e_ssh_bg '/tmp/run-e2e-install.sh'

echo "==> waiting up to ${INSTALL_TIMEOUT}s for the install to finish"
DEADLINE=$((SECONDS + INSTALL_TIMEOUT))
while ((SECONDS < DEADLINE)); do
	if e2e_ssh 'test -f /tmp/install.exit' > /dev/null 2>&1; then
		break
	fi
	sleep 10
done

STATUS="$(e2e_ssh 'cat /tmp/install.exit 2>/dev/null || echo timeout')"
if [[ ${STATUS} != 0 ]]; then
	echo "error: install.sh failed (exit ${STATUS}). Last log lines:" >&2
	e2e_ssh 'tail -n 30 /tmp/install.log' >&2 || true
	exit 1
fi

echo "==> applying the E2E shell preset (hornero-left) like a real user"
# shellcheck disable=SC2016  # remote script, no local expansion wanted
e2e_ssh '$HOME/.local/bin/dots-quickshell preset apply hornero-left' > /dev/null \
	|| echo "warning: preset apply failed (shell will use its default)"

echo "==> bootstrapping the ScrollOverview plugin (hyprpm add/enable)"
# Without a session the reload step warns and is skipped; Hyprland loads
# the enabled plugin from the hyprpm cache at startup.
# shellcheck disable=SC2016  # remote script, no local expansion wanted
e2e_ssh '$HOME/.local/bin/dots-hyprland-plugins --no-update' > /dev/null 2>&1 \
	|| echo "warning: plugin bootstrap failed (config-error overlay may appear)"

echo "==> verifying the install"
for target in \
	.config/quickshell/shell.qml \
	.config/hypr/hyprland.conf \
	.local/lib/quickshell/qml/Hornero/qmldir \
	.local/bin/dots-quickshell; do
	e2e_ssh "test -e ~/.dotfiles/${target} || test -e ~/${target}" \
		|| {
			echo "error: missing after install: ~/${target}" >&2
			exit 1
		}
done
echo "==> install complete"
