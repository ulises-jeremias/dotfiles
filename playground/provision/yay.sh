#!/usr/bin/env bash

set -e

pacman -Syu --noconfirm --needed --noprogressbar base-devel git

cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf /tmp/yay
