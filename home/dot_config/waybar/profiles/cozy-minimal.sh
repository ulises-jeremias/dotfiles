#!/usr/bin/env bash
#
# Cozy Minimal Waybar Profile Configuration
# Soft, comfortable bar with rounded corners and gentle colors
#

# Profile metadata
WAYBAR_PROFILE_NAME="cozy-minimal"
WAYBAR_PROFILE_DESCRIPTION="Soft and comfortable minimal bar with rounded corners"

# Profile-specific configuration files
WAYBAR_PROFILE_CONFIG_FILE="$HOME/.config/waybar/configs/cozy-minimal/config.json"
WAYBAR_PROFILE_STYLE_FILE="$HOME/.config/waybar/configs/cozy-minimal/style.css"
WAYBAR_PROFILE_DUAL_BAR=false

# Profile-specific environment variables
export WAYBAR_PROFILE_THEME="cozy-minimal"

# Profile initialization function
waybar_profile_init() {
  # Smart colors are handled by the centralized system
  return 0
}

# Profile cleanup function
waybar_profile_cleanup() {
  return 0
}
