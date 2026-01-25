#!/usr/bin/env bash
#
# Retro Wave Waybar Profile Configuration
# Vaporwave/80s-inspired bar with gradient backgrounds
#

# Profile metadata
WAYBAR_PROFILE_NAME="retro-wave"
WAYBAR_PROFILE_DESCRIPTION="Vaporwave-inspired bar with retro 80s gradients"

# Profile-specific configuration files
WAYBAR_PROFILE_CONFIG_FILE="$HOME/.config/waybar/configs/retro-wave/config.json"
WAYBAR_PROFILE_STYLE_FILE="$HOME/.config/waybar/configs/retro-wave/style.css"
WAYBAR_PROFILE_DUAL_BAR=false

# Profile-specific environment variables
export WAYBAR_PROFILE_THEME="retro-wave"

# Profile initialization function
waybar_profile_init() {
  return 0
}

# Profile cleanup function
waybar_profile_cleanup() {
  return 0
}

