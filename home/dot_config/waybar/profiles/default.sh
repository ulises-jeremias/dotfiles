#!/usr/bin/env bash
#
# Default Waybar Profile Configuration
# default dual-bar configuration for Hyprland
#

# Profile metadata
WAYBAR_PROFILE_NAME="default"
WAYBAR_PROFILE_DESCRIPTION="default dual-bar configuration for Hyprland"

# Profile-specific configuration files
WAYBAR_PROFILE_CONFIG_TOP="$HOME/.config/waybar/configs/default/config-top.json"
WAYBAR_PROFILE_CONFIG_BOTTOM="$HOME/.config/waybar/configs/default/config-bottom.json"
WAYBAR_PROFILE_STYLE_FILE="$HOME/.config/waybar/configs/default/style.css"
WAYBAR_PROFILE_DUAL_BAR=true

# Profile-specific environment variables
export WAYBAR_PROFILE_THEME="default"

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
