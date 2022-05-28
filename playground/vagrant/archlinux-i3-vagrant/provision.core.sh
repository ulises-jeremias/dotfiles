#!/bin/sh

# this script must be executed as root user
username=$SUDO_USER
userhome=$(getent passwd $SUDO_USER | cut -d: -f6)
pacman --noconfirm -Syu
# remove guest utils provided by the box (they do not work in the GUI environment)
pacman --noconfirm -R virtualbox-guest-utils-nox
# feel free to add/remove packages as you need
pacman --noconfirm -S \
    base-devel net-tools vim wget git unzip openssh bash-completion \
    dialog alsa-utils pulseaudio \
    xorg-server xorg-xfontsel xorg-xrdb xorg-setxkbmap xorg-xinit xf86-video-intel xf86-input-synaptics xf86-input-libinput \
    i3 slim dmenu \
    ttf-inconsolata terminus-font \
    xclip feh rxvt-unicode chromium \
    jdk9-openjdk \
    php php-mcrypt php-xsl xdebug php-intl php-gd composer \
    mariadb mariadb-clients libmariadbclient \
    apache php-apache \
    virtualbox-guest-utils

# add user to the audio group
usermod -a -G audio "${username}"

# create folder for application instances
mkdir /srv/http/instances
chown "${username}:${username}" /srv/http/instances

# make sure that symlinks to home folder will work
chmod +x "${userhome}"

# enable display manager
systemctl enable slim.service
systemctl start slim.service
