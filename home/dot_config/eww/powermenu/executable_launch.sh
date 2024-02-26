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
eww --config "$CFG" open-many --toggle \
	powermenu-background \
	powermenu-clock \
	powermenu-uptime \
	powermenu-lock \
	powermenu-logout \
	powermenu-sleep \
	powermenu-reboot \
	powermenu-poweroff \
	powermenu-placeholder
	# powermenu-close \
