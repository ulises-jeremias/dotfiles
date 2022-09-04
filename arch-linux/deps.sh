#!/usr/bin/env bash

# Needed fonts
fonts=(
    nerd-fonts-hack
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra
)

# Needed apps, themes and icons
needed_pkgs=(
    alacritty
    arc-gtk-theme
    arandr
    dbus-python
    feh
    flameshot
    graphicsmagick
    i3lock-fancy
    jgmenu
    jq
    networkmanager-dmenu
    network-manager-applet
    numix-icon-theme
    pacman-contrib
    pamixer
    pavucontrol
    playerctl
    polybar
    pulseaudio
    python-pywal
    rofi
    scrot
    skippy-xd
    sxiv
    wmctrl
    xdotool
    xgetres
    yad
    zsh
    zsh-syntax-highlighting-git
)

# xfce4 utils
xfce4_pkgs=(
    exo
    libxfce4ui
    libxfce4util
    xfce4-settings
    xfce4-xkb-plugin
    xfconf
    xfce4-notifyd
)

util_pkgs=(
    "greenclip: Simple clipboard manager. Will be used in rofi"
    "dunst: Customizable and lightweight notification-daemon. Will be used by default for notifications if installed"
    "termite: Simple terminal emulator"
    "thunar: Modern file manager for Xfce"
    "thunar-archive-plugin: Create and extract archives in Thunar"
    "thunar-media-tags-plugin: Adds special features for media files to the Thunar File Manager"
    "thunar-volman: Automatic management of removeable devices in Thunar"
    "xfce4-power-manager: Power manager for the Xfce4 desktop"
    "xfce4-screenshooter: An application to take screenshots"
)

if [ -n "${nodunst}" ]; then
    xfce4_pkgs+=(xfce4-notifyd)
else
    needed_pkgs+=(dunst)
fi

if [ -n "${bluetooth}" ]; then
    needed_pkgs+=(bluez)
    util_pkgs+=(blueman)
fi

if [ -n "${utils}" ]; then
    for util in "${util_pkgs[@]}"; do
        util_pkg="${util%%:*}"
        echo "${util}"
        printf "Add %s to the installation list? [y/N]: " "${util_pkg}"

        read -r input

        case "${input}" in
        y | Y | yes | YES | Yes)
            xfce4_pkgs+=("${util_pkg}")
            ;;
        esac
    done
fi

pkgs=("${needed_pkgs[@]}" "${xfce4_pkgs[@]}")
pkgs=("${fonts[@]}" "${pkgs[@]}")
pkgs=$(printf ",%s" "${pkgs[@]}")
pkgs=${pkgs:1}
