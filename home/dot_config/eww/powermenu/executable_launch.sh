#!/usr/bin/env bash

## Copyright (C) 2019-2025 Ulises Jeremias Cornejo Fandos
## Licensed under MIT.
##
## Simple EWW Powermenu Launcher
##
## Usage:
##     launch.sh [open|close|toggle]

set -euo pipefail

# Configuration
readonly EWW_CONFIG_DIR="$HOME/.config/eww/powermenu"
readonly WIDGETS=(
  "powermenu-bg"
  "powermenu-close"
  "powermenu-clock"
  "powermenu-uptime"
  "powermenu-lock"
  "powermenu-logout"
  "powermenu-sleep"
  "powermenu-reboot"
  "powermenu-poweroff"
  "powermenu-placeholder"
)

# Ensure daemon is running
if ! eww ping >/dev/null 2>&1; then
  eww --config "$EWW_CONFIG_DIR" daemon &
  sleep 1
fi

# Default action is toggle
action="${1:-toggle}"

case "$action" in
  open)
    eww --config "$EWW_CONFIG_DIR" open-many "${WIDGETS[@]}" 2>/dev/null || true
    ;;
  close)
    for widget in "${WIDGETS[@]}"; do
      eww --config "$EWW_CONFIG_DIR" close "$widget" 2>/dev/null || true
    done
    ;;
  toggle)
    eww --config "$EWW_CONFIG_DIR" open-many --toggle "${WIDGETS[@]}" 2>/dev/null || true
    ;;
  *)
    echo "Usage: $0 [open|close|toggle]"
    exit 1
    ;;
esac
