#!/usr/bin/env bash

sudo pacman -Syy --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay || exit 1
makepkg -si
