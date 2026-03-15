#!/usr/bin/env bash

set -euo pipefail

RICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKGROUND_DIR="$RICE_DIR/backgrounds"

notify-send "HorneroConfig" "Applying Nord Dreams rice... ❄️"

if ! command -v wpg &>/dev/null; then
  echo "wpg not found. Please install wpg."
  notify-send "HorneroConfig" "wpg not found. Please install wpg."
  exit 1
fi

# Gather wallpapers (skip hidden files like .keep)
shopt -s nullglob
image_files=("$BACKGROUND_DIR"/*.{png,jpg,jpeg,webp})
shopt -u nullglob

if [[ ${#image_files[@]} -eq 0 ]]; then
  notify-send "HorneroConfig" "Nord Dreams: no wallpapers found in backgrounds/. Add .png/.jpg files to get started."
  exit 0
fi

wpg -a "${image_files[@]}"

wallpaper="${BACKGROUND_IMAGE:-}"
if [[ -z $wallpaper ]]; then
  wallpaper="${image_files[0]}"
fi
wpg -s "$wallpaper"

# Apply minimal animations
ANIMATIONS_FILE="$HOME/.config/hypr/hyprland.conf.d/animations-minimal.conf"
if [[ -f $ANIMATIONS_FILE ]]; then
  ln -sf "$ANIMATIONS_FILE" "$HOME/.config/hypr/hyprland.conf.d/animations-current.conf"
fi

notify-send "HorneroConfig" "Nord Dreams rice applied! ❄️ Clean and crisp."
