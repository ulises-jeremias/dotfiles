#!/usr/bin/env bash

DOTS_CACHE_DIR="$HOME/.cache/dots"
[[ ! -d "$DOTS_CACHE_DIR" ]] && mkdir -p "$DOTS_CACHE_DIR"

RICES_DIR="$HOME/.local/share/dots/rices"

CURRENT_RICE_FILE="$RICES_DIR/.current_rice"
[[ ! -f "$CURRENT_RICE_FILE" ]] && echo "hornero" >"$CURRENT_RICE_FILE"

RICE_CONFIG_FILE="$RICES_DIR/$(<"$CURRENT_RICE_FILE")/config.sh"
if [[ ! -f "$RICE_CONFIG_FILE" ]]; then
	echo "The current rice configuration file does not exist"
	notify-send "Error" "The current rice configuration file does not exist" -u critical
	exit 1
fi

source "${RICE_CONFIG_FILE}"
