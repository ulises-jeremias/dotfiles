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

# restore colorscheme
[[ -z "$(pgrep wal)" ]] && wal -R -q

# run feh-blur in the background
dots-scripts feh-blur --blur 10 -d &

# open polybar
"${XDG_CONFIG_HOME}"/polybar/launch &

# i3 layouts
[[ -z "$(pgrep i3-layouts)" ]] && whereis i3-layouts && i3-layouts &

# Start nm-applet
[[ -z "$(pgrep nm-applet)" ]] && nm-applet &

# Start greenclip daemon
[[ -z "$(pgrep greenclip)" ]] && greenclip daemon &
