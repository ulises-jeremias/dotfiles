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

        log_quiet "INFO" "Smart colors configured for minimal profile"
        return 0
    else
        log_quiet "WARN" "dots-smart-colors not found, skipping smart color setup"
        return 1
    fi
}

# Profile initialization function
polybar_profile_init() {
    log_quiet "INFO" "Initializing minimal polybar profile"

    # Setup smart theme-adaptive colors
    setup_smart_colors

    return 0
}

# Profile cleanup function
polybar_profile_cleanup() {
    log_quiet "INFO" "Cleaning up minimal polybar profile"

    # Clean up smart color variables (semantic + basic)
    unset SMART_COLOR_ERROR SMART_COLOR_WARNING SMART_COLOR_SUCCESS SMART_COLOR_INFO SMART_COLOR_ACCENT \
          SMART_COLOR_RED SMART_COLOR_GREEN SMART_COLOR_BLUE SMART_COLOR_YELLOW SMART_COLOR_CYAN \
          SMART_COLOR_MAGENTA SMART_COLOR_ORANGE SMART_COLOR_PINK SMART_COLOR_BROWN \
          SMART_COLOR_WHITE SMART_COLOR_BLACK SMART_COLOR_GRAY 2>/dev/null || true

    return 0
}
