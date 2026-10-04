#!/usr/bin/env bash
# Provision Hyprland + the Hornero workstation stack inside the VM.
set -euo pipefail

echo "[hyprland] installing compositor and wayland stack"
pacman -Syu --noconfirm --needed --noprogressbar \
	hyprland \
	xdg-desktop-portal-hyprland \
	qt6-wayland \
	wayland-protocols \
	polkit-gnome \
	grim \
	slurp \
	wl-clipboard \
	foot

echo "[hyprland] installing the packaged Hornero runtime (AUR)"
sudo -u vagrant yay -S --noconfirm --needed quickshell hornero-shell hornero-config horneroctl-bin

echo "[hyprland] done"
