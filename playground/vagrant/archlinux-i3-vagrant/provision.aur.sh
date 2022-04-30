#!/bin/sh
# this script must not be executed as root user
username=$USER
userhome=$(getent passwd $USER | cut -d: -f6)

cd "${userhome}"

# copy configuration files
rm -rf .bashrc .vimrc .xinitrc .Xresources .i3status.conf .i3
cp /vagrant/.bashrc .
cp /vagrant/.vimrc .
cp /vagrant/.xinitrc .
cp /vagrant/.Xresources .
cp /vagrant/.i3status.conf .
mkdir .i3
cp /vagrant/.i3/config .i3/
# copy wallpaper
mkdir wallpapers
cp /vagrant/wallpaper.jpg wallpapers/
# create work folders
mkdir -p repositories/work

# set some basic git config settings
git config --global core.editor vim
git config --global core.eol lf
#git config --global user.name <your name>
#git config --global user.email <your email>

# install fonts
git clone https://aur.archlinux.org/consolas-font.git
cd consolas-font/
makepkg --noconfirm -si
sudo pacman --noconfirm -U consolas-font-*
cd ../
rm -rf consolas-font/

# install visual studio code
git clone https://aur.archlinux.org/visual-studio-code.git
cd visual-studio-code/
makepkg --noconfirm -si
sudo pacman --noconfirm -U visual-studio-code-*
cd ../
rm -rf visual-studio-code/
