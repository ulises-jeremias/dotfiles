#!/usr/bin/env bash

RICE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKGROUND_DIR="$RICE_DIR/backgrounds"

notify-send "MachinesConfig" "Applying Machines rice..."

if ! command -v wpg &> /dev/null; then
	echo "wpg not found. Please install wpg."
	notify-send "MachinesConfig" "wpg not found. Please install wpg."
	exit 1
fi

wpg -a "$BACKGROUND_DIR"/*

# Set the first wallpaper as the primary wallpaper
first_wallpaper=$(find "$BACKGROUND_DIR" -type f | head -n 1)
wpg -s "$first_wallpaper"

~/.config/polybar/launch.sh &

notify-send "MachinesConfig" "Machines rice applied successfully."