#!/usr/bin/env bash

## Copyright (C) 2019-2025 Ulises Jeremias Cornejo Fandos
## Licensed under MIT.
##
## Smart floating mode for Hyprland
## Toggles floating, centers window, and sets a nice maximum size

set -euo pipefail

# Configuration
MAX_WIDTH=1400 # Maximum window width (pixels)
MAX_HEIGHT=900 # Maximum window height (pixels)

# Get active window info
window_info=$(hyprctl activewindow -j)
is_floating=$(echo "$window_info" | jq -r '.floating')
window_address=$(echo "$window_info" | jq -r '.address')

# Get monitor resolution
monitor_info=$(hyprctl monitors -j | jq -r '.[0]')
monitor_width=$(echo "$monitor_info" | jq -r '.width')
monitor_height=$(echo "$monitor_info" | jq -r '.height')

# Calculate optimal size (80% of monitor or MAX size, whichever is smaller)
optimal_width=$((monitor_width * 80 / 100))
optimal_height=$((monitor_height * 80 / 100))

# Use smaller of optimal or max size
final_width=$((optimal_width < MAX_WIDTH ? optimal_width : MAX_WIDTH))
final_height=$((optimal_height < MAX_HEIGHT ? optimal_height : MAX_HEIGHT))

if [ "$is_floating" = "false" ]; then
  # Make floating, center, and resize
  hyprctl dispatch togglefloating
  hyprctl dispatch resizeactive exact ${final_width} ${final_height}
  hyprctl dispatch centerwindow

  # Show notification
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Smart Float" "Window: ${final_width}x${final_height}" -t 1500 -u low
  fi
else
  # Already floating, just tile it
  hyprctl dispatch togglefloating

  # Show notification
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Smart Float" "Window tiled" -t 1500 -u low
  fi
fi
