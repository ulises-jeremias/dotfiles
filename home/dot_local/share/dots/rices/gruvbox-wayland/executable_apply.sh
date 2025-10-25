#!/usr/bin/env bash

RICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKGROUND_DIR="$RICE_DIR/backgrounds"

# Detect session type
SESSION_TYPE="${XDG_SESSION_TYPE:-x11}"

notify-send "🎨 Gruvbox Wayland" "Applying rice theme..."

# Check for wpg
if ! command -v wpg &>/dev/null; then
  echo "wpg not found. Please install wpg."
  notify-send "❌ Error" "wpg not found. Please install wpg."
  exit 1
fi

# Add backgrounds to wpg
wpg -a "$BACKGROUND_DIR"/*

# Select wallpaper
wallpaper="${BACKGROUND_IMAGE}"
if [ -z "${wallpaper}" ]; then
  wallpaper=$(find "$BACKGROUND_DIR" -type f | head -n 1)
fi

# Apply wallpaper
wpg -s "$wallpaper"

# Apply theme based on session type
if [[ $SESSION_TYPE == "wayland" ]] && pgrep -x Hyprland >/dev/null; then
  echo "Applying Wayland/Hyprland configuration..."

  # Reload Hyprland colors
  if [[ -x "$HOME/.local/bin/dots-wal-reload" ]]; then
    dots-wal-reload
  fi

  # Restart Waybar
  if [[ -x "$HOME/.config/waybar/launch.sh" ]]; then
    "$HOME/.config/waybar/launch.sh" restart &
  fi

  # Set wallpaper for Wayland
  if command -v dots-hyprlock &>/dev/null; then
    dots-hyprlock set "$wallpaper"
  fi

  notify-send "✅ Gruvbox Wayland" "Wayland theme applied successfully."
else
  echo "Applying X11 configuration..."

  # Restart Polybar
  if [[ -x "$HOME/.config/polybar/launch.sh" ]]; then
    "$HOME/.config/polybar/launch.sh" restart &
  fi

  # Reload i3 if running
  if pgrep -x i3 >/dev/null; then
    i3-msg reload
  fi

  notify-send "✅ Gruvbox Wayland" "X11 theme applied successfully."
fi
