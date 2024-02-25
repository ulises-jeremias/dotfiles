#!/usr/bin/env bash

## Files and cmd
CFG="$HOME/.config/eww/powermenu"

## Run eww daemon if not running already
if [[ "$(eww ping)" != "pong" ]]; then
	eww daemon
	if [[ "$(eww ping)" != "pong" ]]; then
		notify-send "Eww" "Failed to start eww daemon" -u critical
		exit 1
	fi
fi

## Open widgets
run_eww() {
	eww --config "$CFG" open-many --toggle \
		powermenu-background \
		powermenu-close \
		powermenu-clock \
		powermenu-uptime \
		powermenu-logout \
		powermenu-sleep \
		powermenu-reboot \
		powermenu-poweroff
}

## Launch or close widgets accordingly
run_eww
