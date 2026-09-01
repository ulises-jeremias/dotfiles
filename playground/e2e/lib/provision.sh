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

if e2e_ssh 'test -f ~/.cache/e2e-provisioned' > /dev/null 2>&1; then
	echo "==> VM already provisioned"
	exit 0
fi

echo "==> setting up Chaotic-AUR (for lib-cava)"
# shellcheck disable=SC2016  # remote script, no local expansion wanted
e2e_ssh 'if ! test -f /etc/pacman.d/chaotic-mirrorlist; then
	sudo pacman-key --recv-keys 3056513887B78AEB --keyserver keyserver.ubuntu.com
	sudo pacman-key --lsign-key 3056513887B78AEB
	for i in 1 2 3; do
		sudo pacman -U --noconfirm \
			https://cdn.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst \
			https://cdn.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst && break
		echo "retry $i/3"
		sleep 5
	done
fi
if test -f /etc/pacman.d/chaotic-mirrorlist && ! grep -q "^\[chaotic-aur\]" /etc/pacman.conf; then
	printf "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n" | sudo tee -a /etc/pacman.conf
fi' > /dev/null

echo "==> installing desktop stack (this takes a while on first boot)"
PACMAN_PKGS='hyprland xdg-desktop-portal-hyprland \
	pipewire wireplumber pipewire-pulse \
	seatd polkit-gnome \
	grim slurp wf-recorder \
	kitty qt6-svg qt6-multimedia qt6-declarative \
	cmake ninja git \
	networkmanager adwaita-icon-theme \
	noto-fonts noto-fonts-emoji ttf-jetbrains-mono-nerd \
	libqalculate aubio cava libcava'
e2e_ssh "sudo pacman -Sy --noconfirm --needed --overwrite '/usr/lib/*' ${PACMAN_PKGS}"

echo "==> granting DRM/seat access"
e2e_ssh 'sudo systemctl enable --now seatd && \
	sudo gpasswd -a hornero seat > /dev/null && \
	sudo gpasswd -a hornero video > /dev/null && \
	sudo gpasswd -a hornero render > /dev/null'

e2e_ssh 'mkdir -p ~/.cache && touch ~/.cache/e2e-provisioned'
echo "==> provisioned"
