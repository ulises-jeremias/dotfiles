#!/usr/bin/env bash
#
# Default Polybar Profile Configuration
# This is the fallback configuration used when no specific profile is defined for a rice
#

# Profile metadata
POLYBAR_PROFILE_NAME="default"
POLYBAR_PROFILE_DESCRIPTION="Default polybar configuration"

# Bars to launch for this profile (window manager aware)
POLYBAR_PROFILE_BARS=("polybar-top" "polybar-bottom")

WM=$(wmctrl -m | grep -oE 'Name: .*' | cut -d' ' -f2 | tr '[:upper:]' '[:lower:]' 2>/dev/null || echo "unknown")
if [ "${WM}" = "i3" ]; then
  POLYBAR_PROFILE_BARS=("i3-polybar-top" "i3-polybar-bottom")
fi

# Profile-specific configuration (optional)
# You can override any polybar settings here
POLYBAR_PROFILE_CONFIG_FILE="$HOME/.config/polybar/configs/default/config.ini"

# Profile-specific environment variables (optional)
export POLYBAR_PROFILE_THEME="default"

# Profile initialization function (optional)
polybar_profile_init() {
  log_quiet "INFO" "Initializing default polybar profile"

  # Add any profile-specific initialization here
  # For example: setting environment variables, copying configs, etc.
  # Note: Smart colors are handled automatically by the centralized system

  return 0
}

# Profile cleanup function (optional)
polybar_profile_cleanup() {
  log_quiet "INFO" "Cleaning up default polybar profile"

  # Add any profile-specific cleanup here
  # Note: Smart colors cleanup is handled automatically by the centralized system

  return 0
}
