#!/usr/bin/env bash

# shellcheck source=/dev/null
source "${HOME}/.local/lib/dots/rice-state.sh" 2>/dev/null || true

DOTS_CACHE_DIR="${DOTS_CACHE_DIR:-$HOME/.cache/dots}"
[[ ! -d $DOTS_CACHE_DIR ]] && mkdir -p "$DOTS_CACHE_DIR"

RICES_DIR="${DOTS_RICES_DIR:-$HOME/.local/share/dots/rices}"

# Prefer canonical rice pointer; fall back to legacy; default to machines.
CURRENT_RICE_FILE="$(dots_rice_canonical_file 2>/dev/null || echo "$HOME/.local/state/dots/rice/current")"
LEGACY_RICE_FILE="$(dots_rice_legacy_file 2>/dev/null || echo "$RICES_DIR/.current_rice")"

current_rice=""
if declare -f dots_read_current_rice >/dev/null 2>&1; then
  current_rice="$(dots_read_current_rice)"
fi
if [[ -z $current_rice && -f $LEGACY_RICE_FILE ]]; then
  current_rice="$(head -n 1 "$LEGACY_RICE_FILE" | tr -d '\r')"
fi
if [[ -z $current_rice ]]; then
  current_rice="machines"
  if declare -f dots_write_current_rice >/dev/null 2>&1; then
    dots_write_current_rice "$current_rice" || true
  else
    mkdir -p "$(dirname "$CURRENT_RICE_FILE")"
    printf '%s\n' "$current_rice" >"$CURRENT_RICE_FILE"
    printf '%s\n' "$current_rice" >"$LEGACY_RICE_FILE"
  fi
fi

# Keep CURRENT_RICE_FILE pointing at canonical for any callers that read the var.
CURRENT_RICE_FILE="$HOME/.local/state/dots/rice/current"

RICE_CONFIG_FILE="$RICES_DIR/${current_rice}/config.sh"
if [[ ! -f $RICE_CONFIG_FILE ]]; then
  echo "The current rice configuration file does not exist: $RICE_CONFIG_FILE"
  notify-send "Error" "The current rice configuration file does not exist" -u critical
  exit 1
fi

# shellcheck source=/dev/null
source "${RICE_CONFIG_FILE}"
