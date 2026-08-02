#!/usr/bin/env bash
# Resolve the current rice id and rices directory (config.json era).
# Does not source per-rice shell configs — use dots_rice_json_get / config.json.

# shellcheck source=/dev/null
source "${HOME}/.local/lib/dots/rice-state.sh" 2> /dev/null || true

DOTS_CACHE_DIR="${DOTS_CACHE_DIR:-$HOME/.cache/dots}"
[[ ! -d $DOTS_CACHE_DIR ]] && mkdir -p "$DOTS_CACHE_DIR"

RICES_DIR="${DOTS_RICES_DIR:-$HOME/.local/share/dots/rices}"
CURRENT_RICE_FILE="$(dots_rice_canonical_file 2> /dev/null || echo "$HOME/.local/state/dots/rice/current")"

current_rice=""
if declare -f dots_read_current_rice > /dev/null 2>&1; then
	current_rice="$(dots_read_current_rice)"
fi

if [[ -z $current_rice ]]; then
	current_rice="machines"
	if declare -f dots_write_current_rice > /dev/null 2>&1; then
		dots_write_current_rice "$current_rice" || true
	else
		mkdir -p "$(dirname "$CURRENT_RICE_FILE")"
		printf '%s\n' "$current_rice" > "$CURRENT_RICE_FILE"
	fi
fi

# Purge any leftover legacy pointers on load.
if declare -f dots_purge_legacy_rice_pointers > /dev/null 2>&1; then
	dots_purge_legacy_rice_pointers
fi

RICE_CONFIG_JSON="$RICES_DIR/${current_rice}/config.json"
if [[ ! -f $RICE_CONFIG_JSON ]]; then
	echo "The current rice configuration file does not exist: $RICE_CONFIG_JSON"
	notify-send "Error" "The current rice configuration file does not exist" -u critical
	exit 1
fi

# Convenience exports for callers that previously relied on sourced shell vars.
RICE_NAME="$(dots_rice_json_get "$current_rice" name "$current_rice" 2> /dev/null || echo "$current_rice")"
RICE_DESCRIPTION="$(dots_rice_json_get "$current_rice" description "" 2> /dev/null || true)"
RICE_STYLE="$(dots_rice_json_get "$current_rice" style "Unknown" 2> /dev/null || echo "Unknown")"
GTK_THEME="$(dots_rice_json_get "$current_rice" gtkTheme auto 2> /dev/null || echo auto)"
ICON_THEME="$(dots_rice_json_get "$current_rice" iconTheme Numix-Circle 2> /dev/null || echo Numix-Circle)"
CURSOR_THEME="$(dots_rice_json_get "$current_rice" cursorTheme "" 2> /dev/null || true)"
SCHEME_TYPE="$(dots_rice_json_get "$current_rice" schemeType tonal-spot 2> /dev/null || echo tonal-spot)"
DARK_MODE="$(dots_rice_json_get "$current_rice" darkMode true 2> /dev/null || echo true)"
BAR_POSITION="$(dots_rice_json_get "$current_rice" barPosition left 2> /dev/null || echo left)"
ACCENT_COLOR="$(dots_rice_json_get "$current_rice" accentColor "" 2> /dev/null || true)"
RICE_PRIMARY_COLOR="$(dots_rice_json_get "$current_rice" primaryColor "" 2> /dev/null || true)"
RICE_SECONDARY_COLOR="$(dots_rice_json_get "$current_rice" secondaryColor "" 2> /dev/null || true)"
HYPRLAND_ANIMATIONS="$(dots_rice_json_get "$current_rice" hyprlandAnimations "" 2> /dev/null || true)"
KITTY_OPACITY="$(dots_rice_json_get "$current_rice" kittyOpacity "" 2> /dev/null || true)"
SNAPPY_SWITCHER_THEME="$(dots_rice_json_get "$current_rice" snappyTheme "" 2> /dev/null || true)"
PREFER_DARK_THEME="$([[ $DARK_MODE == "true" ]] && echo true || echo false)"
