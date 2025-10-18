#!/usr/bin/env bash

RICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKGROUND_DIR="$RICE_DIR/backgrounds"

notify-send "SpaceConfig" "Applying Space rice..."

if ! command -v wpg &>/dev/null; then
  echo "wpg not found. Please install wpg."
  notify-send "SpaceConfig" "wpg not found. Please install wpg."
  exit 1
fi

wpg -a "$BACKGROUND_DIR"/*

# Use the value of BACKGROUND_IMAGE if set, otherwise use the first image in the directory
wallpaper="${BACKGROUND_IMAGE}"
if [ -z "${wallpaper}" ]; then
  wallpaper=$(find "$BACKGROUND_DIR" -type f | head -n 1)
fi
wpg -s "$wallpaper"

# Apply GTK theme for this rice
if [[ -f "$HOME/.local/lib/dots/gtk-theme-manager.sh" ]]; then
  source "$HOME/.local/lib/dots/gtk-theme-manager.sh"
  apply_rice_gtk_theme "space"
fi

~/.config/polybar/launch.sh &

notify-send "SpaceConfig" "Space rice applied successfully."
