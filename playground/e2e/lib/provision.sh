#!/usr/bin/env bash
# Install the desktop stack inside the E2E VM (idempotent, cached by marker).

set -euo pipefail

E2E_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/env.sh
source "${E2E_LIB_DIR}/env.sh"

e2e_ssh_ready || {
	echo "error: VM SSH is not up. Run lib/run.sh + lib/wait-ssh.sh first." >&2
	exit 1
}

if e2e_ssh 'test -f ~/.cache/e2e-provisioned' >/dev/null 2>&1; then
	echo "==> VM already provisioned"
	exit 0
fi

echo "==> installing desktop stack (this takes a while on first boot)"
# Replace the retired third-party Cava library before installing the Arch
# package set. Remove its consumer too so pacman can install the replacement
# provider and Cava in one normal dependency transaction.
# shellcheck disable=SC2016  # remote script, no local expansion wanted
e2e_ssh 'if pacman -Qq lib-cava >/dev/null 2>&1; then
	packages="lib-cava"
	pacman -Qq cava >/dev/null 2>&1 && packages="cava ${packages}"
	sudo pacman -R --noconfirm ${packages}
fi' >/dev/null

PACMAN_PKGS='hyprland xdg-desktop-portal-hyprland \
	pipewire wireplumber pipewire-pulse \
	seatd polkit-gnome \
	grim slurp wf-recorder \
	kitty qt6-svg qt6-multimedia qt6-declarative \
	cmake ninja git \
	networkmanager adwaita-icon-theme \
	noto-fonts noto-fonts-emoji ttf-jetbrains-mono-nerd \
	libqalculate aubio cava'
e2e_ssh "sudo pacman -Syu --noconfirm --needed ${PACMAN_PKGS}"

echo "==> granting DRM/seat access"
e2e_ssh 'sudo systemctl enable --now seatd && \
	sudo gpasswd -a hornero seat > /dev/null && \
	sudo gpasswd -a hornero video > /dev/null && \
	sudo gpasswd -a hornero render > /dev/null'

e2e_ssh 'mkdir -p ~/.cache && touch ~/.cache/e2e-provisioned'
echo "==> provisioned"
