# Shared wallpaper resolution helpers for dots scripts.
# Priority: explicit path > wpgtk (.current) > dots state > wal cache.

dots_resolve_path_candidate() {
  local candidate="${1:-}"
  [[ -n $candidate ]] || return 1

  # Resolve symlink-style candidates first to normalize paths.
  local resolved=""
  resolved="$(readlink -f "$candidate" 2>/dev/null || true)"
  if [[ -n $resolved && -f $resolved ]]; then
    printf '%s\n' "$resolved"
    return 0
  fi

  # If candidate points directly to a file, use it.
  if [[ -f $candidate ]]; then
    printf '%s\n' "$candidate"
    return 0
  fi

  return 1
}

dots_resolve_from_pointer_file() {
  local pointer_file="${1:-}"
  [[ -n $pointer_file && -e $pointer_file ]] || return 1

  # Some files are symlinks to images, others contain a path string.
  local direct=""
  if direct="$(dots_resolve_path_candidate "$pointer_file" 2>/dev/null)"; then
    printf '%s\n' "$direct"
    return 0
  fi

  if [[ -f $pointer_file ]]; then
    local line=""
    line="$(head -n 1 "$pointer_file" 2>/dev/null || true)"
    line="${line%$'\r'}"
    if [[ -n $line ]]; then
      local from_line=""
      from_line="$(readlink -f "$line" 2>/dev/null || true)"
      if [[ -n $from_line && -f $from_line ]]; then
        printf '%s\n' "$from_line"
        return 0
      fi
      if [[ -f $line ]]; then
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
    "$HOME/.config/wpg/.current"
    "$HOME/.local/state/dots/wallpaper/path.txt"
    "$HOME/.cache/current_wallpaper"
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

  # Last compatibility fallback for older wpgtk state.
  if [[ -f "$HOME/.config/wpg/wp_init.py" ]] && command -v python3 >/dev/null 2>&1; then
    local py_wallpaper=""
    py_wallpaper="$(python3 -c "import os; exec(open(os.path.expanduser('~/.config/wpg/wp_init.py')).read()); print(wallpaper)" 2>/dev/null || true)"
    resolved="$(dots_resolve_path_candidate "$py_wallpaper" 2>/dev/null || true)"
    if [[ -n $resolved ]]; then
      printf '%s\n' "$resolved"
      return 0
    fi
  fi

  return 1
}
