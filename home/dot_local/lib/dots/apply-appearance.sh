# shellcheck shell=bash
# Shared appearance apply pipeline (QS-down / CLI fallback).
# Used by dots-appearance / dots-rice when Quickshell is not running,
# and optionally by other scripts that need a full apply without IPC.
#
# Expects wallpaper-resolver.sh and rice-state.sh to be sourceable.

DOTS_RICES_DIR="${DOTS_RICES_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/dots/rices}"
DOTS_STATE_DIR="${DOTS_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/dots}"
DOTS_CACHE_DIR="${DOTS_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/dots}"
DOTS_WALLPAPER_POINTER_FILE="${DOTS_WALLPAPER_POINTER_FILE:-$DOTS_STATE_DIR/wallpaper/path}"
DOTS_SCHEME_FILE="${DOTS_SCHEME_FILE:-$DOTS_CACHE_DIR/smart-colors/scheme.json}"
DOTS_M3_SCRIPT="${DOTS_M3_SCRIPT:-$HOME/.local/lib/dots/generate-m3-colors.py}"
DOTS_HYPR_ANIM_DIR="${DOTS_HYPR_ANIM_DIR:-$HOME/.config/hypr/hyprland.conf.d}"

_dots_aa_json_get() {
  local file="$1" key="$2" default="${3:-}"
  python3 - "$file" "$key" "$default" <<'PY'
import json, sys
path, key, default = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
except Exception:
    print(default)
    raise SystemExit(0)
val = data.get(key, default)
if isinstance(val, bool):
    print("true" if val else "false")
elif val is None:
    print(default)
else:
    print(val)
PY
}

_dots_aa_first_wallpaper() {
  local bg_dir="$1"
  [[ -d $bg_dir ]] || return 1
  # Follow symlinks; match list-rices.py extensions.
  find -L "$bg_dir" -maxdepth 1 \( -type f -o -type l \) \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \
    -o -iname "*.gif" -o -iname "*.bmp" \) 2>/dev/null | sort | head -n 1
}

_dots_aa_write_pointer() {
  local path="$1"
  mkdir -p "$(dirname "$DOTS_WALLPAPER_POINTER_FILE")"
  printf '%s\n' "$path" >"$DOTS_WALLPAPER_POINTER_FILE"
}

_dots_aa_normalize_scheme_type() {
  local raw="${1:-tonal-spot}"
  raw=$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]' | tr '_' '-' | tr -d ' ')
  case "$raw" in
    vibrant | expressive | fidelity | content | neutral | monochrome) printf '%s\n' "$raw" ;;
    tonalspot | tonal-spot) printf 'tonal-spot\n' ;;
    *) printf 'tonal-spot\n' ;;
  esac
}

_dots_aa_scheme_type_to_variant() {
  case "${1:-tonal-spot}" in
    tonal-spot) printf 'tonalspot\n' ;;
    *) printf '%s\n' "$1" ;;
  esac
}

# Apply rice by id. Optional second arg = wallpaper override.
# Returns 0 on success, non-zero on hard failure.
dots_apply_appearance() {
  local rice_id="${1:-}"
  local wallpaper_override="${2:-}"

  [[ -n $rice_id ]] || {
    echo "dots_apply_appearance: rice id required" >&2
    return 1
  }
  [[ -d "$DOTS_RICES_DIR/$rice_id" ]] || {
    echo "dots_apply_appearance: rice not found: $rice_id" >&2
    return 1
  }

  local config_json="$DOTS_RICES_DIR/$rice_id/config.json"
  [[ -f $config_json ]] || {
    echo "dots_apply_appearance: missing config.json for $rice_id" >&2
    return 1
  }

  local scheme_type dark_mode_raw dark_mode gtk_theme kitty_opacity hypr_anim rice_name
  scheme_type="$(_dots_aa_normalize_scheme_type "$(_dots_aa_json_get "$config_json" schemeType tonal-spot)")"
  dark_mode_raw="$(_dots_aa_json_get "$config_json" darkMode true)"
  if [[ $dark_mode_raw == "false" ]]; then
    dark_mode="light"
  else
    dark_mode="dark"
  fi
  gtk_theme="$(_dots_aa_json_get "$config_json" gtkTheme auto)"
  kitty_opacity="$(_dots_aa_json_get "$config_json" kittyOpacity "")"
  hypr_anim="$(_dots_aa_json_get "$config_json" hyprlandAnimations "")"
  rice_name="$(_dots_aa_json_get "$config_json" name "$rice_id")"

  local wallpaper=""
  if [[ -n $wallpaper_override ]]; then
    wallpaper="$(readlink -f "$wallpaper_override" 2>/dev/null || true)"
  fi
  if [[ -z ${wallpaper:-} || ! -f $wallpaper ]]; then
    wallpaper="$(_dots_aa_first_wallpaper "$DOTS_RICES_DIR/$rice_id/backgrounds" || true)"
  fi
  if [[ -z ${wallpaper:-} || ! -f $wallpaper ]]; then
    echo "dots_apply_appearance: no wallpaper for rice $rice_id" >&2
    return 1
  fi

  # Persist rice id only after we know apply can proceed with a wallpaper.
  if declare -f dots_write_current_rice >/dev/null 2>&1; then
    dots_write_current_rice "$rice_id"
  else
    mkdir -p "$DOTS_STATE_DIR/rice"
    printf '%s\n' "$rice_id" >"$DOTS_STATE_DIR/rice/current"
    rm -f "$DOTS_RICES_DIR/.current_rice" "${XDG_CACHE_HOME:-$HOME/.cache}/dots/current_rice" 2>/dev/null || true
  fi

  if ! command -v wal >/dev/null 2>&1; then
    echo "dots_apply_appearance: wal not found" >&2
    return 1
  fi

  if [[ $dark_mode == "light" ]]; then
    wal -i "$wallpaper" -q -l || {
      echo "dots_apply_appearance: wal failed" >&2
      return 1
    }
  else
    wal -i "$wallpaper" -q || {
      echo "dots_apply_appearance: wal failed" >&2
      return 1
    }
  fi

  _dots_aa_write_pointer "$wallpaper"
  # Keep pywal's wal symlink aligned even if a previous run pointed at a bad file.
  mkdir -p "$HOME/.cache/wal"
  ln -sfn "$wallpaper" "$HOME/.cache/wal/wal" 2>/dev/null || true

  if [[ ! -f $DOTS_M3_SCRIPT ]]; then
    echo "dots_apply_appearance: missing generate-m3-colors.py" >&2
    return 1
  fi

  mkdir -p "$(dirname "$DOTS_SCHEME_FILE")"
  if ! python3 "$DOTS_M3_SCRIPT" \
    --image "$wallpaper" \
    --scheme-type "$scheme_type" \
    --mode "$dark_mode" \
    --output "$DOTS_SCHEME_FILE"; then
    echo "dots_apply_appearance: M3 generation failed" >&2
    return 1
  fi

  # Keep scheme/state.json in sync with scheme.json meta.
  if command -v dots-color-scheme >/dev/null 2>&1; then
    dots-color-scheme sync-state >/dev/null 2>&1 || true
  fi

  # Side effects (best-effort)
  if [[ -n $hypr_anim && -f "$DOTS_HYPR_ANIM_DIR/animations-${hypr_anim}.conf" ]]; then
    ln -sf "$DOTS_HYPR_ANIM_DIR/animations-${hypr_anim}.conf" \
      "$DOTS_HYPR_ANIM_DIR/animations-current.conf" 2>/dev/null || true
  fi
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
  fi
  if [[ -n $kitty_opacity && $kitty_opacity != "null" ]] && command -v kitty >/dev/null 2>&1; then
    kitty @ set-colors --all "background_opacity=${kitty_opacity}" >/dev/null 2>&1 || true
  fi
  if command -v dots-gtk-theme >/dev/null 2>&1; then
    if [[ -n $gtk_theme && $gtk_theme != "auto" ]]; then
      dots-gtk-theme apply "$gtk_theme" >/dev/null 2>&1 || true
    else
      dots-gtk-theme rice "$rice_id" >/dev/null 2>&1 || true
    fi
  fi
  if [[ -f $HOME/.local/lib/dots/snappy-switcher-manager.sh ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.local/lib/dots/snappy-switcher-manager.sh" 2>/dev/null || true
    if declare -f apply_rice_snappy_switcher_theme >/dev/null 2>&1; then
      apply_rice_snappy_switcher_theme "$rice_id" >/dev/null 2>&1 || true
    fi
  fi
  if command -v dots-hyprlock-theme >/dev/null 2>&1; then
    dots-hyprlock-theme >/dev/null 2>&1 || true
  fi
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "HorneroConfig" "${rice_name} rice applied" >/dev/null 2>&1 || true
  fi

  return 0
}

# Wallpaper-only change using current rice scheme prefs (or defaults).
dots_apply_wallpaper_only() {
  local wallpaper="${1:-}"
  wallpaper="$(readlink -f "$wallpaper" 2>/dev/null || true)"
  [[ -n ${wallpaper:-} && -f $wallpaper ]] || {
    echo "dots_apply_wallpaper_only: wallpaper not found" >&2
    return 1
  }

  local rice_id="" scheme_type="tonal-spot" dark_mode="dark"
  if declare -f dots_read_current_rice >/dev/null 2>&1; then
    rice_id="$(dots_read_current_rice)"
  fi
  if [[ -n $rice_id && -f "$DOTS_RICES_DIR/$rice_id/config.json" ]]; then
    scheme_type="$(_dots_aa_normalize_scheme_type "$(_dots_aa_json_get "$DOTS_RICES_DIR/$rice_id/config.json" schemeType tonal-spot)")"
    if [[ "$(_dots_aa_json_get "$DOTS_RICES_DIR/$rice_id/config.json" darkMode true)" == "false" ]]; then
      dark_mode="light"
    fi
  elif command -v dots-color-scheme >/dev/null 2>&1; then
    # Prefer last scheme state when rice config unavailable.
    local state_file="$DOTS_STATE_DIR/scheme/state.json"
    if [[ -f $state_file ]]; then
      scheme_type="$(_dots_aa_normalize_scheme_type "$(_dots_aa_json_get "$state_file" flavour tonal-spot)")"
      dark_mode="$(_dots_aa_json_get "$state_file" mode dark)"
      [[ $dark_mode == "light" || $dark_mode == "dark" ]] || dark_mode="dark"
    fi
  fi

  if ! command -v wal >/dev/null 2>&1; then
    echo "dots_apply_wallpaper_only: wal not found" >&2
    return 1
  fi
  if [[ $dark_mode == "light" ]]; then
    wal -i "$wallpaper" -q -l || return 1
  else
    wal -i "$wallpaper" -q || return 1
  fi

  _dots_aa_write_pointer "$wallpaper"
  mkdir -p "$HOME/.cache/wal"
  ln -sfn "$wallpaper" "$HOME/.cache/wal/wal" 2>/dev/null || true
  mkdir -p "$(dirname "$DOTS_SCHEME_FILE")"
  python3 "$DOTS_M3_SCRIPT" \
    --image "$wallpaper" \
    --scheme-type "$scheme_type" \
    --mode "$dark_mode" \
    --output "$DOTS_SCHEME_FILE" || return 1

  if command -v dots-color-scheme >/dev/null 2>&1; then
    dots-color-scheme sync-state >/dev/null 2>&1 || true
  fi
  if command -v dots-hyprlock-theme >/dev/null 2>&1; then
    dots-hyprlock-theme >/dev/null 2>&1 || true
  fi
  return 0
}
