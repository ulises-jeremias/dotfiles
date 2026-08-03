# shellcheck shell=bash
# Shared appearance apply pipeline (QS-down / CLI fallback).
# Theme packs are apply-once recipes — this never writes a "current theme" id.

DOTS_THEMES_DIR="${DOTS_THEMES_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/dots/themes}"
DOTS_WALLPAPERS_DIR="${DOTS_WALLPAPERS_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/dots/wallpapers}"
DOTS_STATE_DIR="${DOTS_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/dots}"
DOTS_CACHE_DIR="${DOTS_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/dots}"
DOTS_WALLPAPER_POINTER_FILE="${DOTS_WALLPAPER_POINTER_FILE:-$DOTS_STATE_DIR/wallpaper/path}"
DOTS_SCHEME_FILE="${DOTS_SCHEME_FILE:-$DOTS_CACHE_DIR/smart-colors/scheme.json}"
DOTS_M3_SCRIPT="${DOTS_M3_SCRIPT:-$HOME/.local/lib/dots/generate-m3-colors.py}"
DOTS_PICTURES_WALLPAPERS="${DOTS_PICTURES_WALLPAPERS:-$HOME/Pictures/Wallpapers}"

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

# Resolve gtk-application-prefer-dark independently of shell darkMode when possible.
# Priority: theme.json gtkPreferDark → Light/Dark in gtk theme name → shell mode.
_dots_aa_resolve_gtk_prefer() {
  local config_json="${1:-}"
  local dark_mode="${2:-dark}"
  local gtk_theme="${3:-}"
  local explicit=""

  if [[ -n $config_json && -f $config_json ]]; then
    explicit="$(_dots_aa_json_get "$config_json" gtkPreferDark "")"
  fi
  case "$explicit" in
    true | false)
      printf '%s\n' "$explicit"
      return 0
      ;;
  esac

  local gtk_lc
  gtk_lc=$(printf '%s' "$gtk_theme" | tr '[:upper:]' '[:lower:]')
  case "$gtk_lc" in
    *light*)
      printf 'false\n'
      ;;
    *dark*)
      printf 'true\n'
      ;;
    *)
      if [[ $dark_mode == "light" ]]; then
        printf 'false\n'
      else
        printf 'true\n'
      fi
      ;;
  esac
}

_dots_aa_resolve_theme_wallpaper() {
  local theme_id="$1"
  local wallpaper_dir="$2"
  local default_name="$3"
  local override="${4:-}"
  local candidate=""

  if [[ -n $override ]]; then
    candidate="$(readlink -f "$override" 2>/dev/null || true)"
    [[ -n ${candidate:-} && -f $candidate ]] && {
      printf '%s\n' "$candidate"
      return 0
    }
  fi

  for base in "$DOTS_PICTURES_WALLPAPERS/$wallpaper_dir" "$DOTS_WALLPAPERS_DIR/$wallpaper_dir"; do
    if [[ -n $default_name && -f $base/$default_name ]]; then
      readlink -f "$base/$default_name"
      return 0
    fi
  done

  for base in "$DOTS_PICTURES_WALLPAPERS/$wallpaper_dir" "$DOTS_WALLPAPERS_DIR/$wallpaper_dir"; do
    [[ -d $base ]] || continue
    candidate="$(
      find -L "$base" -maxdepth 1 \( -type f -o -type l \) \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \
        -o -iname "*.gif" -o -iname "*.bmp" \) 2>/dev/null | sort | head -n 1 || true
    )"
    [[ -n ${candidate:-} && -f $candidate ]] && {
      printf '%s\n' "$candidate"
      return 0
    }
  done
  return 1
}

_dots_aa_sync_gtk_color_scheme() {
  local mode="${1:-dark}"
  if command -v dots-gtk-theme >/dev/null 2>&1; then
    dots-gtk-theme -q color-scheme "$mode" >/dev/null 2>&1 || true
  elif [[ -f $HOME/.local/lib/dots/gtk-theme-manager.sh ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.local/lib/dots/gtk-theme-manager.sh" 2>/dev/null || true
    if declare -f apply_gtk_color_scheme >/dev/null 2>&1; then
      apply_gtk_color_scheme "$mode" >/dev/null 2>&1 || true
    fi
  fi
}

_dots_aa_run_palette() {
  local wallpaper="$1"
  local scheme_type="$2"
  local dark_mode="$3"

  if ! command -v wal >/dev/null 2>&1; then
    echo "apply-appearance: wal not found" >&2
    return 1
  fi
  # Drop any prior wal→image symlink before wal runs; echoing a path through
  # that symlink would truncate the wallpaper file itself.
  mkdir -p "$HOME/.cache/wal"
  rm -f "$HOME/.cache/wal/wal"
  if [[ $dark_mode == "light" ]]; then
    wal -i "$wallpaper" -q -l || return 1
  else
    wal -i "$wallpaper" -q || return 1
  fi

  _dots_aa_write_pointer "$wallpaper"
  rm -f "$HOME/.cache/wal/wal"
  printf '%s\n' "$wallpaper" >"$HOME/.cache/wal/wal"

  [[ -f $DOTS_M3_SCRIPT ]] || {
    echo "apply-appearance: missing generate-m3-colors.py" >&2
    return 1
  }
  mkdir -p "$(dirname "$DOTS_SCHEME_FILE")"
  python3 "$DOTS_M3_SCRIPT" \
    --image "$wallpaper" \
    --scheme-type "$scheme_type" \
    --mode "$dark_mode" \
    --output "$DOTS_SCHEME_FILE" || return 1

  if command -v dots-color-scheme >/dev/null 2>&1; then
    dots-color-scheme sync-state >/dev/null 2>&1 || return 1
  fi
  _dots_aa_sync_gtk_color_scheme "$dark_mode"
  if command -v dots-hyprlock-theme >/dev/null 2>&1; then
    dots-hyprlock-theme >/dev/null 2>&1 || true
  fi
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
  fi
  return 0
}

# Apply a theme pack once (no persistent current-theme state).
dots_apply_theme() {
  local theme_id="${1:-}"
  local wallpaper_override="${2:-}"

  [[ -n $theme_id ]] || {
    echo "dots_apply_theme: theme id required" >&2
    return 1
  }
  local config_json="$DOTS_THEMES_DIR/$theme_id/theme.json"
  [[ -f $config_json ]] || {
    echo "dots_apply_theme: theme not found: $theme_id" >&2
    return 1
  }

  local scheme_type dark_mode_raw dark_mode gtk_theme icon_theme theme_name wallpaper_dir default_wp wallpaper
  scheme_type="$(_dots_aa_normalize_scheme_type "$(_dots_aa_json_get "$config_json" schemeType tonal-spot)")"
  dark_mode_raw="$(_dots_aa_json_get "$config_json" darkMode true)"
  if [[ $dark_mode_raw == "false" ]]; then
    dark_mode="light"
  else
    dark_mode="dark"
  fi
  gtk_theme="$(_dots_aa_json_get "$config_json" gtkTheme Orchis-Light-Compact)"
  icon_theme="$(_dots_aa_json_get "$config_json" iconTheme Numix-Circle)"
  theme_name="$(_dots_aa_json_get "$config_json" name "$theme_id")"
  wallpaper_dir="$(_dots_aa_json_get "$config_json" wallpaperDir "$theme_id")"
  default_wp="$(_dots_aa_json_get "$config_json" defaultWallpaper "")"

  wallpaper="$(_dots_aa_resolve_theme_wallpaper "$theme_id" "$wallpaper_dir" "$default_wp" "$wallpaper_override" || true)"
  [[ -n ${wallpaper:-} && -f $wallpaper ]] || {
    echo "dots_apply_theme: no wallpaper for theme $theme_id" >&2
    return 1
  }

  _dots_aa_run_palette "$wallpaper" "$scheme_type" "$dark_mode" || return 1

  if command -v dots-gtk-theme >/dev/null 2>&1; then
    if [[ -n $gtk_theme && $gtk_theme != "auto" ]]; then
      local prefer
      prefer="$(_dots_aa_resolve_gtk_prefer "$config_json" "$dark_mode" "$gtk_theme")"
      dots-gtk-theme -q apply "$gtk_theme" "${icon_theme:-Numix-Circle}" "$prefer" >/dev/null 2>&1 || true
    elif [[ $gtk_theme == "auto" ]]; then
      dots-gtk-theme -q theme "$theme_id" >/dev/null 2>&1 || true
      local prefer_auto
      prefer_auto="$(_dots_aa_resolve_gtk_prefer "$config_json" "$dark_mode" "")"
      if [[ $prefer_auto == "false" ]]; then
        dots-gtk-theme -q color-scheme light >/dev/null 2>&1 || true
      else
        dots-gtk-theme -q color-scheme dark >/dev/null 2>&1 || true
      fi
    elif [[ -n $icon_theme ]]; then
      dots-gtk-theme -q set-icons "$icon_theme" >/dev/null 2>&1 || true
      dots-gtk-theme -q color-scheme "$dark_mode" >/dev/null 2>&1 || true
    else
      dots-gtk-theme -q color-scheme "$dark_mode" >/dev/null 2>&1 || true
    fi
  elif [[ -n $icon_theme ]] && command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface icon-theme "$icon_theme" >/dev/null 2>&1 || true
    _dots_aa_sync_gtk_color_scheme "$dark_mode"
  else
    _dots_aa_sync_gtk_color_scheme "$dark_mode"
  fi

  if [[ -f $HOME/.local/lib/dots/snappy-switcher-manager.sh ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.local/lib/dots/snappy-switcher-manager.sh" 2>/dev/null || true
    if declare -f apply_theme_snappy_switcher_theme >/dev/null 2>&1; then
      apply_theme_snappy_switcher_theme "$theme_id" >/dev/null 2>&1 || true
    fi
  fi

  if command -v notify-send >/dev/null 2>&1; then
    notify-send "HorneroConfig" "${theme_name} theme applied" >/dev/null 2>&1 || true
  fi
  return 0
}

# Back-compat name used by older callers during transition.
dots_apply_appearance() {
  dots_apply_theme "$@"
}

# Wallpaper-only: live mode/flavour from scheme state.
dots_apply_wallpaper_only() {
  local wallpaper="${1:-}"
  wallpaper="$(readlink -f "$wallpaper" 2>/dev/null || true)"
  [[ -n ${wallpaper:-} && -f $wallpaper ]] || {
    echo "dots_apply_wallpaper_only: wallpaper not found" >&2
    return 1
  }

  local scheme_type="tonal-spot" dark_mode="dark"
  local state_file="$DOTS_STATE_DIR/scheme/state.json"
  if [[ -f $state_file ]]; then
    scheme_type="$(_dots_aa_normalize_scheme_type "$(_dots_aa_json_get "$state_file" flavour tonal-spot)")"
    dark_mode="$(_dots_aa_json_get "$state_file" mode dark)"
    [[ $dark_mode == "light" || $dark_mode == "dark" ]] || dark_mode="dark"
  fi

  _dots_aa_run_palette "$wallpaper" "$scheme_type" "$dark_mode"
}
