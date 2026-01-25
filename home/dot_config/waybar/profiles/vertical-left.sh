#!/usr/bin/env bash
#
# Vertical Left Sidebar Waybar Profile
# Single vertical bar on the left side for minimalist workflows
#

# Profile metadata
WAYBAR_PROFILE_NAME="vertical-left"
WAYBAR_PROFILE_DESCRIPTION="Single vertical sidebar on the left with essential modules"

# Profile-specific configuration files
WAYBAR_PROFILE_CONFIG_FILE="$HOME/.config/waybar/configs/vertical-left/config.json"
WAYBAR_PROFILE_STYLE_FILE="$HOME/.config/waybar/configs/vertical-left/style.css"
WAYBAR_PROFILE_DUAL_BAR=false

# Profile-specific environment variables
export WAYBAR_PROFILE_THEME="vertical-left"

# Profile initialization function
waybar_profile_init() {
  # Smart colors are handled by the centralized system
  # Add any profile-specific initialization here
  return 0
}

# Profile cleanup function
waybar_profile_cleanup() {
  # Cleanup handled by centralized system
  return 0
}
