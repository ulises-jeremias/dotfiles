# shellcheck shell=bash
# Canonical rice-id state helpers.
#
# Sole source of truth:
#   $DOTS_STATE_DIR/rice/current   (default: ~/.local/state/dots/rice/current)
#
# Legacy paths (.current_rice, ~/.cache/dots/current_rice) are removed on write.

DOTS_STATE_DIR="${DOTS_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/dots}"
DOTS_DATA_DIR="${DOTS_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/dots}"
DOTS_RICES_DIR="${DOTS_RICES_DIR:-$DOTS_DATA_DIR/rices}"
DOTS_RICE_CANONICAL_FILE="${DOTS_RICE_CANONICAL_FILE:-$DOTS_STATE_DIR/rice/current}"

dots_rice_canonical_file() {
	printf '%s\n' "$DOTS_RICE_CANONICAL_FILE"
}

dots_purge_legacy_rice_pointers() {
	rm -f \
		"$DOTS_RICES_DIR/.current_rice" \
		"${XDG_CACHE_HOME:-$HOME/.cache}/dots/current_rice" \
		2> /dev/null || true
}

dots_read_current_rice() {
	local id=""
	if [[ -f $DOTS_RICE_CANONICAL_FILE ]]; then
		id="$(head -n 1 "$DOTS_RICE_CANONICAL_FILE" 2> /dev/null || true)"
		id="${id//$'\r'/}"
		id="${id//$'\n'/}"
	fi
	printf '%s\n' "$id"
}

dots_write_current_rice() {
	local id="${1:-}"
	[[ -n $id ]] || return 1

	mkdir -p "$(dirname "$DOTS_RICE_CANONICAL_FILE")" 2> /dev/null || true
	printf '%s\n' "$id" > "$DOTS_RICE_CANONICAL_FILE"
	dots_purge_legacy_rice_pointers
}

dots_rice_exists() {
	local id="${1:-}"
	[[ -n $id && -d "$DOTS_RICES_DIR/$id" && -f "$DOTS_RICES_DIR/$id/config.json" ]]
}

# Read a scalar field from a rice config.json (bool → true/false).
dots_rice_json_get() {
	local rice_id="${1:-}" key="${2:-}" default="${3:-}"
	local path="$DOTS_RICES_DIR/$rice_id/config.json"
	[[ -f $path ]] || {
		printf '%s\n' "$default"
		return 1
	}
	python3 - "$path" "$key" "$default" << 'PY'
import json, sys
path, key, default = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    data = json.load(open(path, encoding="utf-8"))
except Exception:
    print(default)
    raise SystemExit(0)
val = data.get(key, default)
if isinstance(val, bool):
    print("true" if val else "false")
elif val is None:
    print(default)
elif isinstance(val, (list, dict)):
    print(default if default else "")
else:
    print(val)
PY
}
