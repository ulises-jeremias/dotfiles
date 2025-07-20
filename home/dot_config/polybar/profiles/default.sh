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

# Setup smart colors function
setup_smart_colors() {
    # Check if dots-smart-colors is available
    if command -v dots-smart-colors >/dev/null 2>&1; then
        log_quiet "INFO" "Configuring smart theme-adaptive colors..."

        # Export smart color variables using dots-smart-colors
        eval "$(dots-smart-colors --export 2>/dev/null)" || {
            log_quiet "WARN" "Failed to generate smart colors, using fallbacks"
            return 1
        }

        log_quiet "INFO" "Smart colors configured: error=${SMART_COLOR_ERROR:-fallback}, success=${SMART_COLOR_SUCCESS:-fallback}, warning=${SMART_COLOR_WARNING:-fallback}"
        return 0
    else
        log_quiet "WARN" "dots-smart-colors not found, skipping smart color setup"
        return 1
    fi
}

# Profile initialization function (optional)
polybar_profile_init() {
    log_quiet "INFO" "Initializing default polybar profile"

    # Setup smart theme-adaptive colors
    setup_smart_colors

    # Add any profile-specific initialization here
    # For example: setting environment variables, copying configs, etc.

    return 0
}

# Profile cleanup function (optional)
polybar_profile_cleanup() {
    log_quiet "INFO" "Cleaning up default polybar profile"

    # Clean up smart color variables (semantic + basic)
    unset SMART_COLOR_ERROR SMART_COLOR_WARNING SMART_COLOR_SUCCESS SMART_COLOR_INFO SMART_COLOR_ACCENT \
          SMART_COLOR_RED SMART_COLOR_GREEN SMART_COLOR_BLUE SMART_COLOR_YELLOW SMART_COLOR_CYAN \
          SMART_COLOR_MAGENTA SMART_COLOR_ORANGE SMART_COLOR_PINK SMART_COLOR_BROWN \
          SMART_COLOR_WHITE SMART_COLOR_BLACK SMART_COLOR_GRAY 2>/dev/null || true

    # Add any profile-specific cleanup here

    return 0
}
