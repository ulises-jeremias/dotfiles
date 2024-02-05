#!/usr/bin/env bash

[[ "${PATH}" == *"${HOME}/.local/bin"* ]] || export PATH="${HOME}/.local/bin:${PATH}"

/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
gnome-keyring-daemon --start --components=pkcs11 &
xset dpms 600 900 1200
xset r rate 350 60

# required for xfce settings to work
# run xfsettingsd in the background if it's not already running
[[ -z "$(pgrep xfsettingsd)" ]] && xfsettingsd &

# run xfce4-power-manager in the background if it's not already running
[[ -z "$(pgrep xfce4-power-manager)" ]] && xfce4-power-manager --daemon &

# load X params required for dotfiles to work
xrdb -I"${HOME}" -load ~/.Xresources &

# load picom
[[ -z "$(pgrep picom)" ]] && picom --config ~/picom/picom.conf --daemon &

# restore colorscheme
[[ -z "$(pgrep wal)" ]] && wal -R -q

# run feh-blur in the background
# dots feh-blur --blur 32 --darken 12 -c --no-animate -d

# open polybar
~/.config/polybar/launch.sh &

# Start nm-applet
[[ -z "$(pgrep nm-applet)" ]] && nm-applet &

# Start greenclip daemon
[[ -z "$(pgrep greenclip)" ]] && greenclip daemon &
