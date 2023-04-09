#!/usr/bin/env bash

XDG_CONFIG_HOME="${HOME}"/.config
export XDG_CONFIG_HOME

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
[[ -z "$(pgrep picom)" ]] && picom --config "${XDG_CONFIG_HOME}"/picom.conf &

# i3 autotiling
[[ -z "$(pgrep autotiling)" ]] && "${XDG_CONFIG_HOME}"/i3/autotiling &

# restore last configured wallpaper and colors
dots-scripts wall-d -f -r &
wal -R -q
dots-scripts feh-blur --blur 10 -d &

# open polybar
"${XDG_CONFIG_HOME}"/polybar/launch &

# Start greenclip daemon
[[ -z "$(pgrep greenclip)" ]] && greenclip daemon &

# Start nm-applet
[[ -z "$(pgrep nm-applet)" ]] && nm-applet &
