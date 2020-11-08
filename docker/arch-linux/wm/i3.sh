#!/usr/bin/env bash

# i3status is needed for first run
pacman -S i3-gaps i3status
echo "exec i3" >> ~/.xinitrc
