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
    arc-gtk-theme
    arandr
    dbus-python
    drun
    feh
    graphicsmagick
    i3lock-fancy
    jgmenu
    jq
    networkmanager-dmenu
    network-manager-applet
    numix-icon-theme
    pamixer
    pavucontrol
    playerctl
    polybar
    pulseaudio
    rofi
    scrot
    skippy-xd
    termite
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
    thunar
    thunar-archive-plugin
    thunar-media-tags-plugin
    thunar-volman
    tumbler
    xfce4-battery-plugin
    xfce4-datetime-plugin
    xfce4-power-manager
    xfce4-pulseaudio-plugin
    xfce4-settings
    xfce4-xkb-plugin
    xfconf
)

util_pkgs=(
    mousepad
    parole
    ristretto
    xfce4-appfinder
    xfce4-clipman-plugin
    xfce4-cpufreq-plugin
    xfce4-cpugraph-plugin
    xfce4-diskperf-plugin
    xfce4-fsguard-plugin
    xfce4-genmon-plugin
    xfce4-mailwatch-plugin
    xfce4-mount-plugin
    xfce4-mpc-plugin
    xfce4-netload-plugin
    xfce4-notes-plugin
    xfce4-screensaver
    xfce4-screenshooter
    xfce4-sensors-plugin
    xfce4-smartbookmark-plugin
    xfce4-systemload-plugin
    xfce4-taskmanager
    xfce4-time-out-plugin
    xfce4-timer-plugin
    xfce4-verve-plugin
    xfce4-wavelan-plugin
    xfce4-weather-plugin
)

if [ -n "${nodunst}" ]; then
    xfce4_pkgs+=( xfce4-notifyd )
else
    needed_pkgs+=( dunst )
fi

if [ -n "${utils}" ]; then
    for util in "${util_pkgs[@]}"; do
        printf "Add ${util} to the installation list? [y/N]: "
        
        read -r input

        case "${input}" in
            y|Y|yes|YES|Yes)
                xfce4_pkgs+=( "${util}" )
            ;;
        esac
    done
fi

pkgs=( "${needed_pkgs[@]}" "${xfce4_pkgs[@]}" )
pkgs=( "${fonts[@]}" "${pkgs[@]}" )
pkgs=$(printf ",%s" "${pkgs[@]}")
pkgs=${pkgs:1}
