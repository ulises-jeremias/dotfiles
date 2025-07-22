#!/usr/bin/env bash
#
# Minimal Polybar Profile Configuration
# A simple profile with just the top bar
#

# Profile metadata
POLYBAR_PROFILE_NAME="minimal"
POLYBAR_PROFILE_DESCRIPTION="Minimal polybar configuration with only top bar"

# Bars to launch for this profile (window manager aware)
POLYBAR_PROFILE_BARS=("polybar-top")

WM=$(wmctrl -m | grep -oE 'Name: .*' | cut -d' ' -f2 | tr '[:upper:]' '[:lower:]' 2>/dev/null || echo "unknown")
if [ "${WM}" = "i3" ]; then
    POLYBAR_PROFILE_BARS=("i3-polybar-top")
fi

# Profile-specific configuration
POLYBAR_PROFILE_CONFIG_FILE="$HOME/.config/polybar/configs/default/config.ini"

# Profile-specific environment variables
export POLYBAR_PROFILE_THEME="minimal"

# Profile initialization function
polybar_profile_init() {
    log_quiet "INFO" "Initializing minimal polybar profile"

    # Add any profile-specific initialization here
    # Note: Smart colors are handled automatically by the centralized system

    return 0
}

# Profile cleanup function
polybar_profile_cleanup() {
    log_quiet "INFO" "Cleaning up minimal polybar profile"

    # Add any profile-specific cleanup here
    # Note: Smart colors cleanup is handled automatically by the centralized system

    return 0
}
