#!/usr/bin/env bash

## Copyright (C) 2019-2025 Ulises Jeremias Cornejo Fandos
## Licensed under MIT.
##
## Rice Metadata Management Library
##
## This library provides functions to extract and manage rice theme metadata
## for enhanced rice selection and information display.
##
## Check full documentation at: https://github.com/ulises-jeremias/dotfiles/wiki

set -euo pipefail

# Source rice configuration
source "$HOME/.local/lib/dots/dots-rice-config.sh"

# Function to get rice metadata
get_rice_metadata() {
  local rice_name="$1"
  local rice_config="$RICES_DIR/$rice_name/config.sh"

  # Default values
  local RICE_NAME="$rice_name"
  local RICE_DESCRIPTION="No description available"
  local RICE_STYLE="Unknown"
  local RICE_PALETTE="Standard"
  local GTK_THEME="Auto"
  local ICON_THEME="Numix-Circle"
  local CURSOR_THEME="elementary"
  local WALLPAPER_COUNT="Unknown"
  local SMART_COLORS="true"
  local RICE_ACCENT_COLOR="#bb77ff"
  local RICE_PRIMARY_COLOR="#458588"
  local RICE_SECONDARY_COLOR="#d79921"
  local RICE_TAGS=""
  local RICE_BEST_FOR=""
  local SCHEME_TYPE="auto"
  local DARK_MODE=true
  local ACCENT_COLOR=""
  local BAR_POSITION="left"

  # Load rice configuration if available
  if [[ -f $rice_config ]]; then
    # shellcheck disable=SC1090
    source "$rice_config"
  fi

  # Count wallpapers if backgrounds directory exists
  local backgrounds_dir="$RICES_DIR/$rice_name/backgrounds"
  if [[ -d $backgrounds_dir ]]; then
    local count=0
    count=$(find "$backgrounds_dir" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | wc -l)
    WALLPAPER_COUNT="$count"
  fi

  # Output metadata in key:value format
  echo "name:${RICE_NAME}"
  echo "description:${RICE_DESCRIPTION}"
  echo "style:${RICE_STYLE}"
  echo "palette:${RICE_PALETTE}"
  echo "gtk_theme:${GTK_THEME}"
  echo "icon_theme:${ICON_THEME}"
  echo "cursor_theme:${CURSOR_THEME}"
  echo "wallpaper_count:${WALLPAPER_COUNT}"
  echo "smart_colors:${SMART_COLORS}"
  echo "accent_color:${RICE_ACCENT_COLOR}"
  echo "primary_color:${RICE_PRIMARY_COLOR}"
  echo "secondary_color:${RICE_SECONDARY_COLOR}"
  echo "tags:${RICE_TAGS}"
  echo "best_for:${RICE_BEST_FOR}"
  echo "scheme_type:${SCHEME_TYPE}"
  echo "dark_mode:${DARK_MODE}"
  echo "accent_color_override:${ACCENT_COLOR}"
  echo "bar_position:${BAR_POSITION}"
}

# Function to format rice metadata for display
format_rice_metadata() {
  local rice_name="$1"
  local format="${2:-simple}"

  local metadata
  metadata=$(get_rice_metadata "$rice_name")

  # Parse metadata into associative array
  declare -A meta
  while IFS=':' read -r key value; do
    meta["$key"]="$value"
  done <<<"$metadata"

  case "$format" in
    "simple")
      # Single line selector format
      echo "${meta[style]} • ${meta[palette]} • GTK: ${meta[gtk_theme]} • Icons: ${meta[icon_theme]}"
      ;;
    "detailed")
      # Multi-line detailed format
      cat <<EOF
📱 Theme Details: ${meta[name]}

🎨 Visual Style
   • Style: ${meta[style]}
   • Palette: ${meta[palette]}
   • Wallpapers: ${meta[wallpaper_count]} available

🖼️ Theme Components
   • GTK Theme: ${meta[gtk_theme]}
   • Icon Theme: ${meta[icon_theme]}
   • Cursor Theme: ${meta[cursor_theme]}

🧠 Smart Features
   • Smart Colors: $([ "${meta[smart_colors]}" = "true" ] && echo "✅ Enabled" || echo "❌ Disabled")
   • Theme Adaptation: ✅ Auto-detect
   • Color Optimization: ✅ Optimized

$([ -n "${meta[best_for]}" ] && echo "🎯 Best For: ${meta[best_for]}")
EOF
      ;;
    "compact")
      # Compact selector message format
      echo "🎨 ${meta[name]} | ${meta[style]} | GTK: ${meta[gtk_theme]} | ${meta[wallpaper_count]} wallpapers"
      ;;
    "json")
      # JSON format for programmatic use
      cat <<EOF
{
  "name": "${meta[name]}",
  "description": "${meta[description]}",
  "style": "${meta[style]}",
  "palette": "${meta[palette]}",
  "gtk_theme": "${meta[gtk_theme]}",
  "icon_theme": "${meta[icon_theme]}",
  "cursor_theme": "${meta[cursor_theme]}",
  "wallpaper_count": "${meta[wallpaper_count]}",
  "smart_colors": ${meta[smart_colors]},
  "accent_color": "${meta[accent_color]}",
  "primary_color": "${meta[primary_color]}",
  "secondary_color": "${meta[secondary_color]}",
  "tags": "${meta[tags]}",
  "best_for": "${meta[best_for]}",
  "scheme_type": "${meta[scheme_type]}",
  "dark_mode": ${meta[dark_mode]},
  "accent_color_override": "${meta[accent_color_override]}",
  "bar_position": "${meta[bar_position]}"
}
EOF
      ;;
    *)
      echo "Error: Unknown format '$format'"
      return 1
      ;;
  esac
}

# Function to validate rice metadata
validate_rice_metadata() {
  local rice_name="$1"
  local rice_config="$RICES_DIR/$rice_name/config.sh"

  if [[ ! -f $rice_config ]]; then
    echo "❌ Rice config not found: $rice_config"
    return 1
  fi

  local metadata
  metadata=$(get_rice_metadata "$rice_name")

  echo "✅ Rice metadata validation for: $rice_name"
  echo "$metadata" | while IFS=':' read -r key value; do
    if [[ -n $value && $value != "Unknown" && $value != "No description available" ]]; then
      echo "  ✅ $key: $value"
    else
      echo "  ⚠️  $key: $value (consider adding metadata)"
    fi
  done
}

# Function to list all rices with metadata
list_rices_with_metadata() {
  local format="${1:-simple}"

  if [[ ! -d $RICES_DIR ]]; then
    echo "❌ Rices directory not found: $RICES_DIR"
    return 1
  fi

  for rice_dir in "$RICES_DIR"/*/; do
    if [[ -d $rice_dir ]]; then
      local rice_name
      rice_name=$(basename "$rice_dir")
      echo "🍚 $rice_name"
      format_rice_metadata "$rice_name" "$format" | sed 's/^/   /'
      echo
    fi
  done
}

# Function to generate rice selector entry with metadata
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
