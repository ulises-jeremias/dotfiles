#!/usr/bin/env bash

## Files and cmd
CFG="$HOME/.config/eww/dashboard"

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
	dashboard-background \
	dashboard-profile \
	dashboard-system \
	dashboard-clock \
	dashboard-uptime \
	dashboard-music \
	dashboard-github \
	dashboard-youtube \
	dashboard-weather \
	dashboard-mail \
	dashboard-lock \
	dashboard-logout \
	dashboard-sleep \
	dashboard-reboot \
	dashboard-poweroff \
	dashboard-folders \
	dashboard-placeholder
