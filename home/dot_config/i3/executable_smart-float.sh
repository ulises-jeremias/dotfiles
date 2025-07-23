#!/usr/bin/env bash
#
# Smart Floating Window Script for i3
# Toggles floating mode and automatically centers + resizes to comfortable size
#

# Get the current window state
window_state=$(i3-msg -t get_tree | jq '.. | select(.focused? == true) | .floating')

if [[ "$window_state" == "\"user_on\"" || "$window_state" == "\"auto_on\"" ]]; then
    # Window is already floating, make it tiled
    i3-msg "floating toggle"
else
    # Window is tiled, make it floating and optimize size/position
    i3-msg "floating toggle"
    sleep 0.1  # Small delay to ensure floating mode is applied

    # Get screen dimensions
    eval $(xdotool getdisplaygeometry --shell)

    # Calculate comfortable size (70% of screen width, 65% of screen height)
    width=$((WIDTH * 70 / 100))
    height=$((HEIGHT * 65 / 100))

    # Ensure minimum and maximum sizes
    [[ $width -lt 600 ]] && width=600
    [[ $width -gt 1400 ]] && width=1400
    [[ $height -lt 400 ]] && height=400
    [[ $height -gt 900 ]] && height=900

    # Resize and center the window
    i3-msg "resize set ${width} ${height}"
    i3-msg "move position center"
fi
