#!/usr/bin/env bash
# Copy the working-tree dotfiles into the VM via a tar-over-ssh pipe.

set -euo pipefail

E2E_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/env.sh
source "${E2E_LIB_DIR}/env.sh"

e2e_ssh_ready || {
	echo "error: VM SSH is not up. Run lib/run.sh + lib/wait-ssh.sh first." >&2
	exit 1
}

echo "==> deploying Hyprland + Quickshell configs"
cd "${DOTFILES_ROOT}"
tar cf - \
	--exclude='*.log' \
	home/dot_config/hypr \
	home/dot_config/quickshell \
	| e2e_ssh 'tar xf - -C /home/hornero/ --strip-components=2 \
		--transform "s|^dot_config|\.config|"'

# Deploy a single deterministic wallpaper and point the shell's Rice
# service at it (it reads ~/.local/state/dots/wallpaper/path) so the
# background does not show the "Set it now" prompt.
echo "==> deploying wallpaper + Rice pointer"
WALL_SRC="$(find -L "${HOME}/Pictures/Wallpapers" -type f \( \
	-name '*.jpg' -o -name '*.png' \) -size -5M 2> /dev/null | head -n 1)"
if [[ -n ${WALL_SRC} ]]; then
	WALL_NAME="e2e-wallpaper.${WALL_SRC##*.}"
	e2e_scp "${WALL_SRC}" "${E2E_SSH_USER}@127.0.0.1:/tmp/${WALL_NAME}"
	e2e_ssh "mkdir -p ~/Pictures/Wallpapers/e2e && \
		mv /tmp/${WALL_NAME} ~/Pictures/Wallpapers/e2e/ && \
		mkdir -p ~/.local/state/dots/wallpaper && \
		printf '%s' \"\$HOME/Pictures/Wallpapers/e2e/${WALL_NAME}\" \
		> ~/.local/state/dots/wallpaper/path"
else
	echo "warning: no wallpapers found on host, background will stay empty"
fi

# The ScrollOverview HyprPM plugin is not built inside the VM, so its
# keybindings and plugin block would paint a permanent config-error
# overlay. Comment them out (E2E-only, the working tree is untouched).
echo "==> disabling scrolloverview keybindings + plugin block (plugin not in VM)"
e2e_ssh "sed -i 's/^\\(.*scrolloverview.*\\)\$/\\# e2e-disabled: \\1/' \
	~/.config/hypr/hyprland.conf.d/keybindings.conf
sed -i 's|^source = .*plugins\\.conf\$|# e2e-disabled: &|' \
	~/.config/hypr/hyprland.conf"

# Disable idle locking: a headless VM idles out immediately and dots-lockscreen
# is not deployed, so hyprlock would crash into Hyprland's "Ooopsie daisy" screen.
echo "==> disabling idle lock (deterministic E2E)"
e2e_ssh ': > ~/.config/hypr/hypridle.conf'

echo "==> deployed"
