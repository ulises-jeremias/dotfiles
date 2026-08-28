#!/usr/bin/env bash
# Provision Hyprland + the HorneroConfig wayland stack inside the VM.
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

echo "[hyprland] installing quickshell (AUR)"
sudo -u vagrant yay -S --noconfirm --needed quickshell-git || {
  echo "[hyprland] quickshell-git failed, trying quickshell"
  sudo -u vagrant yay -S --noconfirm --needed quickshell
}

echo "[hyprland] done"
