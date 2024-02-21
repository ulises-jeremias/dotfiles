#!/usr/bin/env bash

# Load the Xresources file if it exists
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# Launch polybar
~/.config/polybar/launch.sh &

# You can add new exec commands here or just create new .desktop files in the
# ~/.config/autostart directory.
