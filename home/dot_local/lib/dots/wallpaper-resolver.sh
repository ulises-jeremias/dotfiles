# shellcheck shell=bash
# Shared wallpaper resolution helpers for dots scripts.
#
# Canonical pointer (one line, absolute path), PERSISTENT across reboots:
#   $DOTS_WALLPAPER_POINTER_FILE  (default: ~/.local/state/dots/wallpaper/path)
# Must match Quickshell Paths.state + "/wallpaper/path".
#
# Optional legacy (older installs): ~/.cache/dots/wallpaper/path — read-only fallback.
# Priority: explicit path > canonical state pointer > legacy cache pointer > wal link.
DOTS_STATE_DIR="${DOTS_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/dots}"
DOTS_WALLPAPER_POINTER_FILE="${DOTS_WALLPAPER_POINTER_FILE:-$DOTS_STATE_DIR/wallpaper/path}"
DOTS_CACHE_DIR="${DOTS_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/dots}"
DOTS_LEGACY_WALLPAPER_POINTER="${DOTS_LEGACY_WALLPAPER_POINTER:-$DOTS_CACHE_DIR/wallpaper/path}"

dots_strip_file_uri() {
  local s="${1:-}"
  s="${s#file://}"
  printf '%s\n' "$s"
}

dots_resolve_path_candidate() {
  local candidate=""
  candidate="$(dots_strip_file_uri "${1:-}")"
  [[ -n $candidate ]] || return 1

  local resolved=""
  resolved="$(readlink -f "$candidate" 2>/dev/null || true)"
  if [[ -n $resolved && -f $resolved ]]; then
    printf '%s\n' "$resolved"
    return 0
  fi

  if [[ -f $candidate ]]; then
    printf '%s\n' "$candidate"
    return 0
  fi

  return 1
}

dots_resolve_from_pointer_file() {
  local pointer_file="${1:-}"
  [[ -n $pointer_file && -e $pointer_file ]] || return 1

  local norm_ptr=""
  norm_ptr="$(readlink -f "$pointer_file" 2>/dev/null || true)"

  # Symlink to image: resolve directly.
  local direct=""
  if [[ -L $pointer_file ]]; then
    if direct="$(dots_resolve_path_candidate "$pointer_file" 2>/dev/null)"; then
      printf '%s\n' "$direct"
      return 0
    fi
  fi

  if [[ -f $pointer_file ]]; then
    local line=""
    line="$(head -n 1 "$pointer_file" 2>/dev/null || true)"
    line="${line%$'\r'}"
    line="$(dots_strip_file_uri "$line")"
    if [[ -n $line ]]; then
      # Corrupt pointer: file contains its own path (self-referential).
      local norm_line=""
      norm_line="$(readlink -f "$line" 2>/dev/null || true)"
      if [[ -n $norm_ptr && -n $norm_line && $norm_line == "$norm_ptr" ]]; then
        return 1
      fi
      if [[ $line == "$pointer_file" ]]; then
        return 1
      fi

      local from_line=""
      from_line="$(readlink -f "$line" 2>/dev/null || true)"
      if [[ -n $from_line && -f $from_line && $from_line != "$norm_ptr" ]]; then
        printf '%s\n' "$from_line"
        return 0
      fi
      if [[ -f $line && $line != "$pointer_file" ]]; then
        printf '%s\n' "$line"
        return 0
      fi
    fi
  fi

  return 1
}

dots_current_wallpaper() {
  local explicit="${1:-}"
  local resolved=""

  if [[ -n $explicit ]]; then
    resolved="$(dots_resolve_path_candidate "$explicit" 2>/dev/null || true)"
    if [[ -n $resolved ]]; then
      printf '%s\n' "$resolved"
      return 0
    fi
  fi

  local candidates=(
    "$DOTS_WALLPAPER_POINTER_FILE"
    "$DOTS_LEGACY_WALLPAPER_POINTER"
    "$HOME/.cache/wal/wal"
  )

  local candidate=""
  for candidate in "${candidates[@]}"; do
    resolved="$(dots_resolve_from_pointer_file "$candidate" 2>/dev/null || true)"
    if [[ -n $resolved ]]; then
      printf '%s\n' "$resolved"
      return 0
    fi
  done

  return 1
}
