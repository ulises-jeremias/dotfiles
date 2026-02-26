#!/usr/bin/env bash

## Copyright (C) 2019-2026 Ulises Jeremias Cornejo Fandos
## Licensed under MIT.
##
## Snappy Switcher Theme Manager
##
## Usage:
##   source ~/.local/lib/dots/snappy-switcher-manager.sh
##   apply_rice_snappy_switcher_theme [rice_name]
##   apply_snappy_switcher_theme <theme_file.ini>
##

set -euo pipefail

readonly SNAPPY_CONFIG_DIR="$HOME/.config/snappy-switcher"
readonly SNAPPY_CONFIG_FILE="${SNAPPY_CONFIG_DIR}/config.ini"

snappy_log() {
  local level="$1"
  shift
  printf '[SNAPPY][%s] %s\n' "$level" "$*" >&2
}

is_snappy_switcher_available() {
  command -v snappy-switcher >/dev/null 2>&1
}

ensure_snappy_config() {
  if [[ -f $SNAPPY_CONFIG_FILE ]]; then
    return 0
  fi

  mkdir -p "$SNAPPY_CONFIG_DIR"

  if command -v snappy-install-config >/dev/null 2>&1; then
    if snappy-install-config >/dev/null 2>&1; then
      snappy_log "INFO" "Initialized snappy-switcher config with snappy-install-config"
    fi
  fi

  # Final fallback when installer is unavailable or fails.
  if [[ ! -f $SNAPPY_CONFIG_FILE ]]; then
    cat >"$SNAPPY_CONFIG_FILE" <<'EOF'
[general]
mode = context

[theme]
name = snappy-slate.ini

[icons]
theme = Tela-dracula
fallback = hicolor
show_letter_fallback = true
EOF
    snappy_log "WARN" "Created minimal snappy-switcher config fallback"
  fi
}

update_snappy_theme_name() {
  local theme_name="$1"
  local temp_file

  temp_file="$(mktemp)"

  awk -v theme_name="$theme_name" '
    BEGIN {
      in_theme = 0
      name_written = 0
      theme_section_seen = 0
    }
    /^\[theme\][[:space:]]*$/ {
      if (in_theme && !name_written) {
        print "name = " theme_name
        name_written = 1
      }
      in_theme = 1
      theme_section_seen = 1
      print
      next
    }
    /^\[[^]]+\][[:space:]]*$/ {
      if (in_theme && !name_written) {
        print "name = " theme_name
        name_written = 1
      }
      in_theme = 0
      print
      next
    }
    {
      if (in_theme && $0 ~ /^[[:space:]]*name[[:space:]]*=/) {
        if (!name_written) {
          print "name = " theme_name
          name_written = 1
        }
        next
      }
      print
    }
    END {
      if (!theme_section_seen) {
        print ""
        print "[theme]"
        print "name = " theme_name
      } else if (in_theme && !name_written) {
        print "name = " theme_name
      }
    }
  ' "$SNAPPY_CONFIG_FILE" >"$temp_file"

  mv "$temp_file" "$SNAPPY_CONFIG_FILE"
}

apply_snappy_switcher_theme() {
  local theme_name="${1:-}"
  if [[ -z $theme_name ]]; then
    snappy_log "ERROR" "Theme name is required"
    return 1
  fi

  if [[ $theme_name != *.ini ]]; then
    theme_name="${theme_name}.ini"
  fi

  if ! is_snappy_switcher_available; then
    snappy_log "WARN" "snappy-switcher not installed, skipping theme apply"
    return 0
  fi

  ensure_snappy_config
  update_snappy_theme_name "$theme_name"
  snappy_log "INFO" "Applied snappy-switcher theme: $theme_name"
}

get_rice_snappy_theme() {
  local rice_name="$1"
  local rice_config="$HOME/.local/share/dots/rices/${rice_name}/config.sh"

  if [[ ! -f $rice_config ]]; then
    snappy_log "ERROR" "Rice config not found: $rice_config"
    return 1
  fi

  # shellcheck disable=SC1090
  source "$rice_config"

  # Preferred key: SNAPPY_SWITCHER_THEME
  # Compatibility key: THEME
  if [[ -n ${SNAPPY_SWITCHER_THEME:-} ]]; then
    echo "$SNAPPY_SWITCHER_THEME"
    return 0
  fi

  if [[ -n ${THEME:-} ]]; then
    echo "$THEME"
    return 0
  fi

  # Intelligent fallback by brightness preference when not explicitly set.
  case "${PREFER_DARK_THEME:-auto}" in
    light)
      echo "catppuccin-latte.ini"
      ;;
    *)
      echo "snappy-slate.ini"
      ;;
  esac
}

apply_rice_snappy_switcher_theme() {
  local rice_name="${1:-}"

  if [[ -z $rice_name ]]; then
    local current_rice_file="$HOME/.local/share/dots/rices/.current_rice"
    if [[ -f $current_rice_file ]]; then
      rice_name=$(<"$current_rice_file")
    fi
  fi

  if [[ -z $rice_name ]]; then
    snappy_log "WARN" "No rice selected; skipping snappy-switcher theme sync"
    return 0
  fi

  local theme_name
  theme_name="$(get_rice_snappy_theme "$rice_name")" || return 1
  apply_snappy_switcher_theme "$theme_name"
}
