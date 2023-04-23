#!/usr/bin/env bash

XDG_CONFIG_HOME="${HOME}"/.config
export XDG_CONFIG_HOME

[[ "${PATH}" == *"${HOME}/.local/bin"* ]] || export PATH="${HOME}/.local/bin:${PATH}"

run() {
  if ! pgrep "$1"; then
    "$@"&
  fi
}

run /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
run gnome-keyring-daemon --start --components=pkcs11
run xset dpms 600 900 1200
run xset r rate 350 60

# required for xfce settings to work
# run xfsettingsd in the background if it's not already running
run xfsettingsd

# run xfce4-power-manager in the background if it's not already running
run xfce4-power-manager --daemon

# load X params required for dotfiles to work
run xrdb -I"${HOME}" -load ~/.Xresources

# load picom
run picom --config "${XDG_CONFIG_HOME}"/picom.conf

# restore colorscheme
run wal -R -q

# run feh-blur in the background
run dots-scripts feh-blur --blur 10 -d

# open polybar
run "${XDG_CONFIG_HOME}"/polybar/launch

# i3 autotiling
# run ${XDG_CONFIG_HOME}/i3/autotiling

# Start nm-applet
run nm-applet

# Start greenclip daemon
run greenclip daemon
