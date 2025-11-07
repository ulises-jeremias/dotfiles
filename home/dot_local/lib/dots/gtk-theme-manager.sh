#!/usr/bin/env bash

## Copyright (C) 2019-2025 Ulises Jeremias Cornejo Fandos
## Licensed under MIT.
##
## GTK Theme Manager for Rice System Integration
##
## This library provides functions to manage GTK themes as part of the rice system,
## allowing for automatic theme switching based on rice preferences and color schemes.
##
## Usage:
##     source ~/.local/lib/dots/gtk-theme-manager.sh
##     apply_gtk_theme "theme-name" "icon-theme-name" [prefer-dark]
##     detect_optimal_gtk_theme
##     apply_rice_gtk_theme
##

set -euo pipefail

# Source smart colors for theme detection
if [[ -f "$HOME/.local/lib/dots/smart-colors.sh" ]]; then
  source "$HOME/.local/lib/dots/smart-colors.sh"
fi

# GTK configuration paths
readonly GTK2_CONFIG="$HOME/.gtkrc-2.0"
readonly GTK3_CONFIG="$HOME/.config/gtk-3.0/settings.ini"

# Function to log messages
log() {
  local level="$1"
  shift
  local message="$*"
  local timestamp
  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

  echo "[$timestamp] [GTK-THEME] [$level] $message" >&2
}

# Function to check if a GTK theme is installed
is_gtk_theme_installed() {
  local theme_name="$1"

  # Check in common theme directories
  local theme_dirs=(
    "/usr/share/themes"
    "/usr/local/share/themes"
    "$HOME/.themes"
    "$HOME/.local/share/themes"
  )

  for theme_dir in "${theme_dirs[@]}"; do
    if [[ -d "$theme_dir/$theme_name" ]]; then
      return 0
    fi
  done

  return 1
}

# Function to check if an icon theme is installed
is_icon_theme_installed() {
  local icon_theme="$1"

  # Check in common icon directories
  local icon_dirs=(
    "/usr/share/icons"
    "/usr/local/share/icons"
    "$HOME/.icons"
    "$HOME/.local/share/icons"
  )

  for icon_dir in "${icon_dirs[@]}"; do
    if [[ -d "$icon_dir/$icon_theme" ]]; then
      return 0
    fi
  done

  return 1
}

# Function to apply GTK theme with fallbacks
apply_gtk_theme() {
  local gtk_theme="$1"
  local icon_theme="${2:-elementary}"
  local prefer_dark="${3:-false}"

  log "INFO" "Applying GTK theme: $gtk_theme, icons: $icon_theme"

  # Validate theme availability with fallbacks
  if ! is_gtk_theme_installed "$gtk_theme"; then
    log "WARN" "GTK theme '$gtk_theme' not found, trying fallbacks..."

    # Common fallback themes in order of preference
    local fallback_themes=(
      "Orchis-Light"
      "elementary"
      "Arc-Dark"
      "Arc"
      "Breeze"
      "oxygen-gtk"
    )

    for fallback in "${fallback_themes[@]}"; do
      if is_gtk_theme_installed "$fallback"; then
        gtk_theme="$fallback"
        log "INFO" "Using fallback theme: $gtk_theme"
        break
      fi
    done

    if ! is_gtk_theme_installed "$gtk_theme"; then
      log "ERROR" "No suitable GTK theme found, keeping current theme"
      return 1
    fi
  fi

  # Validate icon theme with fallbacks
  if ! is_icon_theme_installed "$icon_theme"; then
    log "WARN" "Icon theme '$icon_theme' not found, trying fallbacks..."

    local fallback_icons=(
      "Numix-Circle"
      "elementary"
      "hicolor"
    )

    for fallback in "${fallback_icons[@]}"; do
      if is_icon_theme_installed "$fallback"; then
        icon_theme="$fallback"
        log "INFO" "Using fallback icon theme: $icon_theme"
        break
      fi
    done
  fi

  # Update GTK2 configuration
  if [[ -f $GTK2_CONFIG ]]; then
    sed -i "s/^gtk-theme-name=.*/gtk-theme-name=\"$gtk_theme\"/" "$GTK2_CONFIG"
    sed -i "s/^gtk-icon-theme-name=.*/gtk-icon-theme-name=\"$icon_theme\"/" "$GTK2_CONFIG"
    log "INFO" "Updated GTK2 configuration"
  else
    log "WARN" "GTK2 config not found, creating basic configuration"
    cat >"$GTK2_CONFIG" <<EOF
# DO NOT EDIT! This file will be overwritten by LXAppearance.
# Any customization should be done in ~/.gtkrc-2.0.mine instead.

include "/home/\$USER/.gtkrc-2.0.mine"
gtk-theme-name="$gtk_theme"
gtk-icon-theme-name="$icon_theme"
gtk-font-name="sans 11"
gtk-cursor-theme-name="elementary"
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-toolbar-icon-size=GTK_ICON_SIZE_SMALL_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintslight"
gtk-xft-rgba="rgb"
EOF
  fi

  # Update GTK3 configuration
  if [[ -f $GTK3_CONFIG ]]; then
    sed -i "s/^gtk-theme-name=.*/gtk-theme-name=$gtk_theme/" "$GTK3_CONFIG"
    sed -i "s/^gtk-icon-theme-name=.*/gtk-icon-theme-name=$icon_theme/" "$GTK3_CONFIG"
    sed -i "s/^gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=$prefer_dark/" "$GTK3_CONFIG"
    log "INFO" "Updated GTK3 configuration"
  else
    log "WARN" "GTK3 config not found, creating configuration"
    mkdir -p "$(dirname "$GTK3_CONFIG")"
    cat >"$GTK3_CONFIG" <<EOF
[Settings]
gtk-application-prefer-dark-theme=$prefer_dark
gtk-theme-name=$gtk_theme
gtk-icon-theme-name=$icon_theme
gtk-font-name=sans 11
gtk-cursor-theme-name=elementary
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-toolbar-icon-size=GTK_ICON_SIZE_SMALL_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
gtk-modules=colorreload-gtk-module
EOF
  fi

  # Notify running GTK applications to reload themes
  if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme "$icon_theme" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface gtk-application-prefer-dark-theme "$prefer_dark" 2>/dev/null || true
    log "INFO" "Updated gsettings"
  fi

  # XFCE4 settings support removed - using gsettings only
  # If running XFCE4 session, gsettings should be sufficient
  # Legacy xfconf-query support can be re-enabled if needed

  log "INFO" "GTK theme applied successfully: $gtk_theme"
  return 0
}

# Function to detect optimal GTK theme based on wallpaper colors
detect_optimal_gtk_theme() {
  local wallpaper_path="$1"
  local detected_theme="Orchis-Light" # Default
  local prefer_dark="false"

  # First, try to use pywal's background color to determine if theme should be dark or light
  if [[ -f "$HOME/.cache/wal/colors" ]]; then
    log "INFO" "Analyzing pywal colors for optimal theme selection"

    # Read background color from pywal
    local bg_color
    bg_color=$(head -n 1 "$HOME/.cache/wal/colors" | tr -d '#')

    if [[ -n $bg_color ]]; then
      # Convert hex to RGB and calculate brightness
      local r=$((16#${bg_color:0:2}))
      local g=$((16#${bg_color:2:2}))
      local b=$((16#${bg_color:4:2}))
      local brightness=$((r + g + b))

      # If background is dark (low brightness), suggest dark theme
      if [[ $brightness -lt 384 ]]; then # 384 = 128 * 3 (threshold for dark)
        log "INFO" "Dark background detected (brightness: $brightness), suggesting dark theme"
        local dark_themes=(
          "Orchis-Dark-Compact"
          "Arc-Dark"
          "elementary-dark"
          "Breeze-Dark"
        )

        for theme in "${dark_themes[@]}"; do
          if is_gtk_theme_installed "$theme"; then
            detected_theme="$theme"
            prefer_dark="true"
            break
          fi
        done
      else
        log "INFO" "Light background detected (brightness: $brightness), suggesting light theme"
        local light_themes=(
          "Orchis-Light"
          "Arc"
          "elementary"
          "Breeze"
        )

        for theme in "${light_themes[@]}"; do
          if is_gtk_theme_installed "$theme"; then
            detected_theme="$theme"
            prefer_dark="false"
            break
          fi
        done
      fi
    fi
  elif command -v dots-smart-colors >/dev/null 2>&1; then
    # Fallback: use smart-colors to analyze current theme
    log "INFO" "Using smart-colors to analyze current theme"

    # Check if current theme is light or dark using smart-colors logic
    if dots-smart-colors --analyze 2>/dev/null | grep -q "light theme\|bright"; then
      log "INFO" "Light theme detected, suggesting light GTK theme"
      local light_themes=(
        "Orchis-Light"
        "Arc"
        "elementary"
        "Breeze"
      )

      for theme in "${light_themes[@]}"; do
        if is_gtk_theme_installed "$theme"; then
          detected_theme="$theme"
          prefer_dark="false"
          break
        fi
      done
    else
      log "INFO" "Dark theme detected, suggesting dark GTK theme"
      local dark_themes=(
        "Orchis-Dark-Compact"
        "Arc-Dark"
        "elementary-dark"
        "Breeze-Dark"
      )

      for theme in "${dark_themes[@]}"; do
        if is_gtk_theme_installed "$theme"; then
          detected_theme="$theme"
          prefer_dark="true"
          break
        fi
      done
    fi
  else
    log "WARN" "No color analysis available, using default light theme"
  fi

  log "INFO" "Detected optimal theme: $detected_theme (dark: $prefer_dark)"
  echo "$detected_theme:$prefer_dark"
}

# Function to apply GTK theme based on current rice configuration
apply_rice_gtk_theme() {
  local rice_name="${1:-}"

  # If no rice specified, try to detect current rice
  if [[ -z $rice_name ]] && [[ -f "$HOME/.cache/dots/current_rice" ]]; then
    source "$HOME/.cache/dots/current_rice"
    rice_name="$CURRENT_RICE"
  fi

  if [[ -z $rice_name ]]; then
    log "WARN" "No rice specified, using default theme detection"
    local wallpaper
    wallpaper=$(cat "$HOME/.cache/wal/wal" 2>/dev/null || echo "")
    if [[ -n $wallpaper && -f $wallpaper ]]; then
      local theme_info
      theme_info=$(detect_optimal_gtk_theme "$wallpaper")
      local gtk_theme="${theme_info%:*}"
      local prefer_dark="${theme_info#*:}"
      apply_gtk_theme "$gtk_theme" "Numix-Circle" "$prefer_dark"
    else
      apply_gtk_theme "Orchis-Light" "Numix-Circle" "false"
    fi
    return
  fi

  log "INFO" "Applying GTK theme for rice: $rice_name"

  # Load rice configuration
  local rice_config="$HOME/.local/share/dots/rices/$rice_name/config.sh"
  if [[ ! -f $rice_config ]]; then
    log "ERROR" "Rice config not found: $rice_config"
    return 1
  fi

  # Source rice configuration
  source "$rice_config"

  # Get GTK theme from rice config or detect automatically
  local gtk_theme="${GTK_THEME:-}"
  local icon_theme="${ICON_THEME:-Numix-Circle}"
  local prefer_dark="${PREFER_DARK_THEME:-auto}"

  # If no explicit theme set in rice, detect based on wallpaper
  if [[ -z $gtk_theme ]] || [[ $gtk_theme == "auto" ]]; then
    local current_wallpaper
    current_wallpaper=$(cat "$HOME/.cache/wal/wal" 2>/dev/null || echo "")

    if [[ -n $current_wallpaper && -f $current_wallpaper ]]; then
      local theme_info
      theme_info=$(detect_optimal_gtk_theme "$current_wallpaper")
      gtk_theme="${theme_info%:*}"
      if [[ $prefer_dark == "auto" ]]; then
        prefer_dark="${theme_info#*:}"
      fi
    else
      gtk_theme="Orchis-Light"
      if [[ $prefer_dark == "auto" ]]; then
        prefer_dark="false"
      fi
    fi
  fi

  # Apply the theme
  apply_gtk_theme "$gtk_theme" "$icon_theme" "$prefer_dark"
}

# Function to get current GTK theme
get_current_gtk_theme() {
  if [[ -f $GTK3_CONFIG ]]; then
    grep "^gtk-theme-name=" "$GTK3_CONFIG" | cut -d'=' -f2
  elif [[ -f $GTK2_CONFIG ]]; then
    grep "^gtk-theme-name=" "$GTK2_CONFIG" | cut -d'"' -f2
  else
    echo "Unknown"
  fi
}

# Function to list installed GTK themes
list_installed_gtk_themes() {
  local themes=()

  local theme_dirs=(
    "/usr/share/themes"
    "/usr/local/share/themes"
    "$HOME/.themes"
    "$HOME/.local/share/themes"
  )

  for theme_dir in "${theme_dirs[@]}"; do
    if [[ -d $theme_dir ]]; then
      while IFS= read -r -d '' theme_path; do
        local theme_name
        theme_name=$(basename "$theme_path")
        if [[ -d "$theme_path/gtk-2.0" ]] || [[ -d "$theme_path/gtk-3.0" ]]; then
          themes+=("$theme_name")
        fi
      done < <(find "$theme_dir" -maxdepth 1 -type d -print0)
    fi
  done

  # Remove duplicates and sort
  printf '%s\n' "${themes[@]}" | sort -u
}
