#!/usr/bin/env bash

## Copyright (C) 2019-2025 Ulises Jeremias Cornejo Fandos
## Licensed under MIT.
##
## Interactive gaps management for Hyprland
## Equivalent to i3-gaps interactive gap mode

set -euo pipefail

# Get current gaps
get_inner_gaps() {
  hyprctl getoption general:gaps_in -j | jq -r '.custom' | awk '{print $1}'
}

get_outer_gaps() {
  hyprctl getoption general:gaps_out -j | jq -r '.custom' | awk '{print $1}'
}

# Show menu for gap selection
show_menu() {
  local title="$1"
  local options="Increase (+5)\nDecrease (-5)\nIncrease All (Shift +5)\nDecrease All (Shift -5)\nReset (0)"
  if command -v fuzzel >/dev/null 2>&1; then
    echo -e "$options" | fuzzel --dmenu --prompt "$title> "
  elif command -v wofi >/dev/null 2>&1; then
    echo -e "$options" | wofi --dmenu --prompt "$title" --insensitive
  else
    return 1
  fi
}

# Main menu
if command -v fuzzel >/dev/null 2>&1; then
  main_choice=$(echo -e "Inner Gaps\nOuter Gaps" | fuzzel --dmenu --prompt "Gaps Mode> ")
elif command -v wofi >/dev/null 2>&1; then
  main_choice=$(echo -e "Inner Gaps\nOuter Gaps" | wofi --dmenu --prompt "Gaps Mode" --insensitive)
else
  echo "No menu backend available (requires fuzzel or wofi)." >&2
  exit 1
fi

case "$main_choice" in
  "Inner Gaps")
    current=$(get_inner_gaps)
    choice=$(show_menu "Inner Gaps (current: $current)")

    case "$choice" in
      "Increase (+5)")
        hyprctl keyword general:gaps_in $((current + 5))
        ;;
      "Decrease (-5)")
        hyprctl keyword general:gaps_in $((current - 5))
        ;;
      "Increase All (Shift +5)")
        hyprctl keyword general:gaps_in $((current + 5))
        ;;
      "Decrease All (Shift -5)")
        hyprctl keyword general:gaps_in $((current - 5))
        ;;
      "Reset (0)")
        hyprctl keyword general:gaps_in 12
        ;;
    esac
    ;;

  "Outer Gaps")
    current=$(get_outer_gaps)
    choice=$(show_menu "Outer Gaps (current: $current)")

    case "$choice" in
      "Increase (+5)")
        hyprctl keyword general:gaps_out $((current + 5))
        ;;
      "Decrease (-5)")
        hyprctl keyword general:gaps_out $((current - 5))
        ;;
      "Increase All (Shift +5)")
        hyprctl keyword general:gaps_out $((current + 5))
        ;;
      "Decrease All (Shift -5)")
        hyprctl keyword general:gaps_out $((current - 5))
        ;;
      "Reset (0)")
        hyprctl keyword general:gaps_out 18
        ;;
    esac
    ;;
esac

# Show notification
if command -v notify-send >/dev/null 2>&1; then
  notify-send "Gaps Updated" "Inner: $(get_inner_gaps) | Outer: $(get_outer_gaps)" -t 2000
fi
