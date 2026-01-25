#!/usr/bin/env bash

RICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKGROUND_DIR="$RICE_DIR/backgrounds"

notify-send "HorneroConfig" "Applying Cozy Corner rice... 🧸"

if ! command -v wpg &>/dev/null; then
  echo "wpg not found. Please install wpg."
  notify-send "HorneroConfig" "wpg not found. Please install wpg."
  exit 1
fi

# Add all backgrounds from this rice to wpg
wpg -a "$BACKGROUND_DIR"/*

# Use the value of BACKGROUND_IMAGE if set, otherwise use the first image in the directory
wallpaper="${BACKGROUND_IMAGE}"
if [ -z "${wallpaper}" ]; then
  wallpaper=$(find "$BACKGROUND_DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | head -n 1)
fi
wpg -s "$wallpaper"

# Apply rice-specific Kitty settings if Kitty is running
if pgrep -x "kitty" > /dev/null; then
  source "$RICE_DIR/config.sh"
  if [[ -n "$KITTY_OPACITY" ]]; then
    kitty @ set-colors --all background_opacity="$KITTY_OPACITY" 2>/dev/null || true
  fi
  if [[ -n "$KITTY_FONT_SIZE" ]]; then
    kitty @ set-font-size "$KITTY_FONT_SIZE" 2>/dev/null || true
  fi
fi

# Apply cozy animations if the profile exists
ANIMATIONS_FILE="$HOME/.config/hypr/hyprland.conf.d/animations-cozy.conf"
if [[ -f "$ANIMATIONS_FILE" ]]; then
  ln -sf "$ANIMATIONS_FILE" "$HOME/.config/hypr/hyprland.conf.d/animations-current.conf"
fi

notify-send "HorneroConfig" "Cozy Corner rice applied successfully! 🌸"


