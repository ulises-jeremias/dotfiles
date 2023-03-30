export POLYBAR_BARS="polybar-top,polybar-bottom"

# Battery ~> Use $ ls -1 /sys/class/power_supply/
export POLYBAR_MODULES_LAPTOP_BATTERY=BAT0
export POLYBAR_MODULES_LAPTOP_ADAPTER=AC

# Networking
export POLYBAR_MODULES_WIFI_IFACE=
export POLYBAR_MODULES_ETH_IFACE=

# Backlight
# Use the following command to list available cards
# ls -1 /sys/class/backlight/
export POLYBAR_MODULES_BACKLIGHT_CARD=intel_backlight

#=================================
# Polybar Top Bar attributes
#=================================

export POLYBAR_TOP_RADIUS=12.0

export POLYBAR_TOP_BACKGROUND=#B01C2023
export POLYBAR_TOP_BACKGROUND=#282c34
export POLYBAR_TOP_BACKGROUND=#00000000
export POLYBAR_TOP_BACKGROUND_ALT=
export POLYBAR_TOP_FOREGROUND=
export POLYBAR_TOP_FOREGROUND_ALT=

# Modules
export POLYBAR_TOP_LEFT="jgmenu menu window_switch pulseaudio-microphone pulseaudio-bar backlight-acpi-bar"
export POLYBAR_TOP_CENTER=
export POLYBAR_TOP_RIGHT="pkg night-mode filesystem memory cpu temperature networkmanager-dmenu battery"

# Dimesions
export POLYBAR_TOP_WIDTH=100%
export POLYBAR_TOP_HEIGHT=40
export POLYBAR_TOP_OFFSET_Y=
export POLYBAR_TOP_OFFSET_X=

export POLYBAR_TOP_BORDER_TOP_SIZE=
export POLYBAR_TOP_BORDER_BOTTOM_SIZE=
export POLYBAR_TOP_BORDER_RIGHT_SIZE=
export POLYBAR_TOP_BORDER_LEFT_SIZE=

#=================================
# Polybar Bottom Bar attributes
#=================================

export POLYBAR_BOTTOM_RADIUS=12.0

export POLYBAR_BOTTOM_BACKGROUND=#00000000
export POLYBAR_BOTTOM_BACKGROUND_ALT=
export POLYBAR_BOTTOM_FOREGROUND=
export POLYBAR_BOTTOM_FOREGROUND_ALT=

# Modules
export POLYBAR_BOTTOM_LEFT="i3-with-icons"
export POLYBAR_BOTTOM_CENTER=
export POLYBAR_BOTTOM_RIGHT=

# Dimensions
export POLYBAR_BOTTOM_WIDTH=
export POLYBAR_BOTTOM_HEIGHT=
export POLYBAR_BOTTOM_OFFSET_Y=
export POLYBAR_BOTTOM_OFFSET_X=

export POLYBAR_BOTTOM_BORDER_TOP_SIZE=
export POLYBAR_BOTTOM_BORDER_BOTTOM_SIZE=
export POLYBAR_BOTTOM_BORDER_RIGHT_SIZE=
export POLYBAR_BOTTOM_BORDER_LEFT_SIZE=
