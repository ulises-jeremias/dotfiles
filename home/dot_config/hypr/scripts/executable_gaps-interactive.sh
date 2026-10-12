#!/usr/bin/env bash

## Copyright (C) 2019-2025 Ulises Jeremias Cornejo Fandos
## Licensed under MIT.
##
## Interactive gaps management for Hyprland
## Equivalent to i3-gaps interactive gap mode

set -euo pipefail

hyprctl_helper="$HOME/.local/bin/hyprland-runtime"

# Get current gaps
get_inner_gaps() {
  "$hyprctl_helper" get-gap inner | jq -r '.custom' | awk '{print $1}'
}

get_outer_gaps() {
  "$hyprctl_helper" get-gap outer | jq -r '.custom' | awk '{print $1}'
}

# Show menu for gap selection
show_menu() {
  local title="$1"
  echo "$title"
  echo "1) Increase (+5)"
  echo "2) Decrease (-5)"
  echo "3) Increase All (Shift +5)"
  echo "4) Decrease All (Shift -5)"
  echo "5) Set to zero"
  echo "6) Restore defaults"
  printf "Choice [1-6]: "
  local n
  read -r n || return 1
  case "$n" in
    1) echo "Increase (+5)" ;;
    2) echo "Decrease (-5)" ;;
    3) echo "Increase All (Shift +5)" ;;
    4) echo "Decrease All (Shift -5)" ;;
    5) echo "Set to zero" ;;
    6) echo "Restore defaults" ;;
    *) return 1 ;;
  esac
}

# Main menu
echo "Gaps Mode"
echo "1) Inner Gaps"
echo "2) Outer Gaps"
printf "Choice [1-2]: "
read -r main_n || exit 1
case "$main_n" in
  1) main_choice="Inner Gaps" ;;
  2) main_choice="Outer Gaps" ;;
  *) exit 1 ;;
esac

case "$main_choice" in
  "Inner Gaps")
    current=$(get_inner_gaps)
    choice=$(show_menu "Inner Gaps (current: $current)")

    case "$choice" in
      "Increase (+5)")
        "$hyprctl_helper" adjust-gap inner 5
        ;;
      "Decrease (-5)")
        "$hyprctl_helper" adjust-gap inner -5
        ;;
      "Increase All (Shift +5)")
        "$hyprctl_helper" adjust-gap inner 5
        ;;
      "Decrease All (Shift -5)")
        "$hyprctl_helper" adjust-gap inner -5
        ;;
      "Set to zero")
        "$hyprctl_helper" set-gap inner 0
        ;;
      "Restore defaults")
        "$hyprctl_helper" set-gap inner 6
        ;;
    esac
    ;;

  "Outer Gaps")
    current=$(get_outer_gaps)
    choice=$(show_menu "Outer Gaps (current: $current)")

    case "$choice" in
      "Increase (+5)")
        "$hyprctl_helper" adjust-gap outer 5
        ;;
      "Decrease (-5)")
        "$hyprctl_helper" adjust-gap outer -5
        ;;
      "Increase All (Shift +5)")
        "$hyprctl_helper" adjust-gap outer 5
        ;;
      "Decrease All (Shift -5)")
        "$hyprctl_helper" adjust-gap outer -5
        ;;
      "Set to zero")
        "$hyprctl_helper" set-gap outer 0
        ;;
      "Restore defaults")
        "$hyprctl_helper" set-gap outer 18
        ;;
    esac
    ;;
esac

# Show notification
if command -v notify-send >/dev/null 2>&1; then
  notify-send "Gaps Updated" "Inner: $(get_inner_gaps) | Outer: $(get_outer_gaps)" -t 2000
fi
