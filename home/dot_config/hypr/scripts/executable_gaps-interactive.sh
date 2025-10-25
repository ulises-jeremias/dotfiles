#!/usr/bin/env bash

## Copyright (C) 2019-2025 Ulises Jeremias Cornejo Fandos
## Licensed under MIT.
##
## Interactive gaps management for Hyprland
## Equivalent to i3-gaps interactive gap mode

set -euo pipefail

# Get current gaps
get_inner_gaps() {
  hyprctl getoption general:gaps_in -j | jq -r '.int'
}

get_outer_gaps() {
  hyprctl getoption general:gaps_out -j | jq -r '.int'
}

# Show rofi menu for gap selection
show_menu() {
  local title="$1"
  echo -e "Increase (+5)\nDecrease (-5)\nIncrease All (Shift +5)\nDecrease All (Shift -5)\nReset (0)" |
    rofi -dmenu -p "$title" -theme-str 'window {width: 300px;}' -theme-str 'listview {lines: 5;}'
}

# Main menu
main_choice=$(echo -e "Inner Gaps\nOuter Gaps" | rofi -dmenu -p "Gaps Mode" -theme-str 'window {width: 200px;}' -theme-str 'listview {lines: 2;}')

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
