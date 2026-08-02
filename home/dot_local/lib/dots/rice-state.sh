# shellcheck shell=bash
# Canonical rice-id state helpers.
#
# Canonical file (QS + CLI):
#   $DOTS_STATE_DIR/rice/current   (default: ~/.local/state/dots/rice/current)
#
# Legacy mirror (lockscreen / snappy / yazi / older scripts):
#   $DOTS_RICES_DIR/.current_rice  (default: ~/.local/share/dots/rices/.current_rice)
#
# Writers always update BOTH. Readers prefer canonical, then legacy.

DOTS_STATE_DIR="${DOTS_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/dots}"
DOTS_DATA_DIR="${DOTS_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/dots}"
DOTS_RICES_DIR="${DOTS_RICES_DIR:-$DOTS_DATA_DIR/rices}"
DOTS_RICE_CANONICAL_FILE="${DOTS_RICE_CANONICAL_FILE:-$DOTS_STATE_DIR/rice/current}"
DOTS_RICE_LEGACY_FILE="${DOTS_RICE_LEGACY_FILE:-$DOTS_RICES_DIR/.current_rice}"
DOTS_RICE_CACHE_FILE="${DOTS_RICE_CACHE_FILE:-${XDG_CACHE_HOME:-$HOME/.cache}/dots/current_rice}"

dots_rice_canonical_file() {
  printf '%s\n' "$DOTS_RICE_CANONICAL_FILE"
}

dots_rice_legacy_file() {
  printf '%s\n' "$DOTS_RICE_LEGACY_FILE"
}

dots_read_current_rice() {
  local id=""
  if [[ -f $DOTS_RICE_CANONICAL_FILE ]]; then
    id="$(head -n 1 "$DOTS_RICE_CANONICAL_FILE" 2>/dev/null || true)"
    id="${id//$'\r'/}"
    id="${id//$'\n'/}"
  fi
  if [[ -z $id && -f $DOTS_RICE_LEGACY_FILE ]]; then
    id="$(head -n 1 "$DOTS_RICE_LEGACY_FILE" 2>/dev/null || true)"
    id="${id//$'\r'/}"
    id="${id//$'\n'/}"
  fi
  printf '%s\n' "$id"
}

# Persist rice id to canonical + legacy mirror (+ optional cache export for old GTK path).
dots_write_current_rice() {
  local id="${1:-}"
  [[ -n $id ]] || return 1

  mkdir -p "$(dirname "$DOTS_RICE_CANONICAL_FILE")" "$(dirname "$DOTS_RICE_LEGACY_FILE")" \
    "$(dirname "$DOTS_RICE_CACHE_FILE")" 2>/dev/null || true

  printf '%s\n' "$id" >"$DOTS_RICE_CANONICAL_FILE"
  printf '%s\n' "$id" >"$DOTS_RICE_LEGACY_FILE"
  # Legacy GTK manager sourced this as bash; keep a harmless assignment form.
  printf 'CURRENT_RICE=%q\n' "$id" >"$DOTS_RICE_CACHE_FILE" 2>/dev/null || true
}

dots_rice_exists() {
  local id="${1:-}"
  [[ -n $id && -d "$DOTS_RICES_DIR/$id" ]]
}
