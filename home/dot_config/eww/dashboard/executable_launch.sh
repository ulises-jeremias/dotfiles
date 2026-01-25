#!/usr/bin/env bash

## Copyright (C) 2019-2025 Ulises Jeremias Cornejo Fandos
## Licensed under MIT.
##
## Simple EWW Dashboard Launcher
##
## Usage:
##     launch.sh [open|close|toggle]

set -euo pipefail

# Configuration
readonly EWW_CONFIG_DIR="$HOME/.config/eww/dashboard"
readonly WIDGETS=(
  "dashboard-background"
  "dashboard-profile"
  "dashboard-system"
  "dashboard-clock"
  "dashboard-uptime"
  "dashboard-music"
  "dashboard-github"
  "dashboard-youtube"
  "dashboard-weather"
  "dashboard-mail"
  "dashboard-folders"
  "dashboard-lock"
  "dashboard-logout"
  "dashboard-sleep"
  "dashboard-reboot"
  "dashboard-poweroff"
  "dashboard-placeholder"
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
