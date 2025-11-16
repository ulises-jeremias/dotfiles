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
readonly WINDOW_NAME="powermenu"

# Ensure daemon is running
if ! eww ping >/dev/null 2>&1; then
  eww --config "$EWW_CONFIG_DIR" daemon &
  sleep 1
fi

# Default action is toggle
action="${1:-toggle}"

case "$action" in
  open)
    eww --config "$EWW_CONFIG_DIR" open "$WINDOW_NAME" 2>/dev/null || true
    ;;
  close)
    eww --config "$EWW_CONFIG_DIR" close "$WINDOW_NAME" 2>/dev/null || true
    ;;
  toggle)
    if eww --config "$EWW_CONFIG_DIR" windows | grep -q "^\*$WINDOW_NAME$"; then
      eww --config "$EWW_CONFIG_DIR" close "$WINDOW_NAME" 2>/dev/null || true
    else
      eww --config "$EWW_CONFIG_DIR" open "$WINDOW_NAME" 2>/dev/null || true
    fi
    ;;
  *)
    echo "Usage: $0 [open|close|toggle]"
    exit 1
    ;;
esac
