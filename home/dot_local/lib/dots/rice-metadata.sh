#!/usr/bin/env bash

## Copyright (C) 2019-2025 Ulises Jeremias Cornejo Fandos
## Licensed under MIT.
##
## Rice Metadata Management Library — reads config.json only.

set -euo pipefail

# shellcheck source=/dev/null
source "$HOME/.local/lib/dots/rice-state.sh" 2> /dev/null || true

RICES_DIR="${DOTS_RICES_DIR:-$HOME/.local/share/dots/rices}"

get_rice_metadata() {
	local rice_name="$1"
	local rice_json="$RICES_DIR/$rice_name/config.json"

	local RICE_NAME="$rice_name"
	local RICE_DESCRIPTION="No description available"
	local RICE_STYLE="Unknown"
	local GTK_THEME="auto"
	local ICON_THEME="Numix-Circle"
	local CURSOR_THEME=""
	local WALLPAPER_COUNT="0"
	local SMART_COLORS="true"
	local RICE_ACCENT_COLOR=""
	local RICE_PRIMARY_COLOR=""
	local RICE_SECONDARY_COLOR=""
	local RICE_TAGS=""
	local SCHEME_TYPE="tonal-spot"
	local DARK_MODE="true"
	local BAR_POSITION="left"

	if [[ -f $rice_json ]]; then
		eval "$(
			python3 - "$rice_json" << 'PY'
import json, shlex, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
tags = data.get("tags") or []
if isinstance(tags, list):
    tags_s = ",".join(str(t) for t in tags)
else:
    tags_s = str(tags)
mapping = {
    "RICE_NAME": data.get("name") or "",
    "RICE_DESCRIPTION": data.get("description") or "",
    "RICE_STYLE": data.get("style") or "Unknown",
    "GTK_THEME": data.get("gtkTheme") or "auto",
    "ICON_THEME": data.get("iconTheme") or "Numix-Circle",
    "CURSOR_THEME": data.get("cursorTheme") or "",
    "RICE_ACCENT_COLOR": data.get("accentColor") or "",
    "RICE_PRIMARY_COLOR": data.get("primaryColor") or "",
    "RICE_SECONDARY_COLOR": data.get("secondaryColor") or "",
    "RICE_TAGS": tags_s,
    "SCHEME_TYPE": data.get("schemeType") or "tonal-spot",
    "DARK_MODE": "true" if data.get("darkMode", True) else "false",
    "BAR_POSITION": data.get("barPosition") or "left",
}
for k, v in mapping.items():
    print(f"{k}={shlex.quote(str(v))}")
PY
		)"
	fi

	local backgrounds_dir="$RICES_DIR/$rice_name/backgrounds"
	if [[ -d $backgrounds_dir ]]; then
		WALLPAPER_COUNT=$(find -L "$backgrounds_dir" -maxdepth 1 \( -type f -o -type l \) \( \
			-iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \
			-o -iname "*.gif" -o -iname "*.bmp" \) | wc -l)
	fi

	echo "name:${RICE_NAME}"
	echo "description:${RICE_DESCRIPTION}"
	echo "style:${RICE_STYLE}"
	echo "gtk_theme:${GTK_THEME}"
	echo "icon_theme:${ICON_THEME}"
	echo "cursor_theme:${CURSOR_THEME}"
	echo "wallpaper_count:${WALLPAPER_COUNT}"
	echo "smart_colors:${SMART_COLORS}"
	echo "accent_color:${RICE_ACCENT_COLOR}"
	echo "primary_color:${RICE_PRIMARY_COLOR}"
	echo "secondary_color:${RICE_SECONDARY_COLOR}"
	echo "tags:${RICE_TAGS}"
	echo "scheme_type:${SCHEME_TYPE}"
	echo "dark_mode:${DARK_MODE}"
	echo "bar_position:${BAR_POSITION}"
}

format_rice_metadata() {
	local rice_name="$1"
	local format="${2:-simple}"

	local metadata
	metadata=$(get_rice_metadata "$rice_name")

	declare -A meta
	while IFS=':' read -r key value; do
		meta["$key"]="$value"
	done <<< "$metadata"

	case "$format" in
		simple)
			echo "${meta[style]} • GTK: ${meta[gtk_theme]} • Icons: ${meta[icon_theme]}"
			;;
		detailed)
			cat << EOF
Theme: ${meta[name]}
Style: ${meta[style]}
Wallpapers: ${meta[wallpaper_count]}
GTK: ${meta[gtk_theme]} | Icons: ${meta[icon_theme]}
Scheme: ${meta[scheme_type]} | Dark: ${meta[dark_mode]}
EOF
			;;
		compact)
			echo "${meta[name]} | ${meta[style]} | GTK: ${meta[gtk_theme]} | ${meta[wallpaper_count]} wallpapers"
			;;
		json)
			python3 - "$RICES_DIR/$rice_name/config.json" << 'PY'
import json, sys, pathlib
path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text(encoding="utf-8")) if path.exists() else {}
print(json.dumps(data, indent=2))
PY
			;;
		*)
			echo "Error: Unknown format '$format'"
			return 1
			;;
	esac
}

validate_rice_metadata() {
	local rice_name="$1"
	local rice_json="$RICES_DIR/$rice_name/config.json"

	if [[ ! -f $rice_json ]]; then
		echo "Rice config.json not found: $rice_json"
		return 1
	fi

	echo "Rice metadata validation for: $rice_name"
	get_rice_metadata "$rice_name" | while IFS=':' read -r key value; do
		if [[ -n $value && $value != "Unknown" && $value != "No description available" ]]; then
			echo "  ok $key: $value"
		else
			echo "  warn $key: $value"
		fi
	done
}

list_rices_with_metadata() {
	local format="${1:-simple}"

	if [[ ! -d $RICES_DIR ]]; then
		echo "Rices directory not found: $RICES_DIR"
		return 1
	fi

	for rice_dir in "$RICES_DIR"/*/; do
		if [[ -d $rice_dir && -f "${rice_dir}config.json" ]]; then
			local rice_name
			rice_name=$(basename "$rice_dir")
			echo "$rice_name"
			format_rice_metadata "$rice_name" "$format" | sed 's/^/   /'
			echo
		fi
	done
}

generate_rice_entry() {
	local rice_name="$1"
	local show_metadata="${2:-true}"

	local preview_image="$RICES_DIR/$rice_name/preview.png"

	if [[ $show_metadata == "true" ]]; then
		local info
		info=$(format_rice_metadata "$rice_name" "simple")
		echo -en "$rice_name\x00icon\x1f$preview_image\x00info\x1f$info\n"
	else
		echo -en "$rice_name\x00icon\x1f$preview_image\n"
	fi
}
