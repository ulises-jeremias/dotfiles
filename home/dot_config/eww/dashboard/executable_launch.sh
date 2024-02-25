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
run_eww() {
	eww --config "$CFG" open-many --toggle \
		dashboard-background \
		dashboard-profile \
		dashboard-system \
		dashboard-clock \
		dashboard-uptime \
		dashboard-music \
		dashboard-github \
		dashboard-reddit \
		dashboard-twitter \
		dashboard-youtube \
		dashboard-weather \
		dashboard-apps \
		dashboard-mail \
		dashboard-logout \
		dashboard-sleep \
		dashboard-reboot \
		dashboard-poweroff \
		dashboard-folders
}

## Launch or close widgets accordingly
run_eww
