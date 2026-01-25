#!/usr/bin/env bash
#
# Dock Bottom Waybar Profile Configuration
# macOS-style dock at bottom with icons only
#

# Profile metadata
WAYBAR_PROFILE_NAME="dock-bottom"
WAYBAR_PROFILE_DESCRIPTION="macOS-style floating dock with icons only"

# Profile-specific configuration files
WAYBAR_PROFILE_CONFIG_FILE="$HOME/.config/waybar/configs/dock-bottom/config.json"
WAYBAR_PROFILE_STYLE_FILE="$HOME/.config/waybar/configs/dock-bottom/style.css"
WAYBAR_PROFILE_DUAL_BAR=false

# Profile-specific environment variables
export WAYBAR_PROFILE_THEME="dock-bottom"

# Profile initialization function
waybar_profile_init() {
  return 0
}

# Profile cleanup function
waybar_profile_cleanup() {
  return 0
}
