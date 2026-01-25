#!/usr/bin/env bash
#
# Floating Neon Waybar Profile Configuration
# Cyberpunk-style floating island bar with neon glow effects
#

# Profile metadata
WAYBAR_PROFILE_NAME="floating-neon"
WAYBAR_PROFILE_DESCRIPTION="Cyberpunk floating island bar with neon glow effects"

# Profile-specific configuration files
WAYBAR_PROFILE_CONFIG_FILE="$HOME/.config/waybar/configs/floating-neon/config.json"
WAYBAR_PROFILE_STYLE_FILE="$HOME/.config/waybar/configs/floating-neon/style.css"
WAYBAR_PROFILE_DUAL_BAR=false

# Profile-specific environment variables
export WAYBAR_PROFILE_THEME="floating-neon"

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
