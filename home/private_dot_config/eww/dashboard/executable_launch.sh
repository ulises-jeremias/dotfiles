#!/usr/bin/env bash

## Files and cmd
FILE="$HOME/.cache/eww_launch.dashboard"
CFG="$HOME/.config/eww/dashboard"
EWW="$(which eww)"

## Run eww daemon if not running already
if [[ ! $(pidof eww) ]]; then
	${EWW} daemon
	# wait for eww daemon to start
	max=10
	for _ in $(seq 1 $max); do
		if [[ $(pidof eww) ]]; then
			break
		elif [[ $_ -eq $max ]]; then
			notify-send "Eww daemon failed to start" -u critical
			exit 1
		fi
		sleep 0.1
	done
fi

## Open widgets
run_eww() {
	${EWW} --config "$CFG" open-many \
		background \
		profile \
		system \
		clock \
		uptime \
		music \
		github \
		reddit \
		twitter \
		youtube \
		weather \
		apps \
		mail \
		logout \
		sleep \
		reboot \
		poweroff \
		folders
}

## Launch or close widgets accordingly
if [[ ! -f "$FILE" ]]; then
	touch "$FILE"
	run_eww
else
	${EWW} --config "$CFG" close \
		background profile system clock uptime music github \
		reddit twitter youtube weather apps mail logout sleep reboot poweroff folders
	rm "$FILE"
fi
