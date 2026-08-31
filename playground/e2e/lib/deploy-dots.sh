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

# Deploy a handful of wallpapers so the session does not start empty.
echo "==> deploying sample wallpapers"
find -L "${HOME}/Pictures/Wallpapers" -type f \( \
	-name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) \
	-size -5M 2> /dev/null | head -n 5 | tar cf - -T - 2> /dev/null \
	| e2e_ssh 'mkdir -p ~/Pictures/Wallpapers && tar xf - -C ~/Pictures/Wallpapers' \
	|| echo "warning: no wallpapers found on host, skipping"

# Disable idle locking: a headless VM idles out immediately and dots-lockscreen
# is not deployed, so hyprlock would crash into Hyprland's "Ooopsie daisy" screen.
echo "==> disabling idle lock (deterministic E2E)"
e2e_ssh ': > ~/.config/hypr/hypridle.conf'

echo "==> deployed"
