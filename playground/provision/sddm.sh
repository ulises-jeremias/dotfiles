#!/usr/bin/env bash

set -e

cp /vagrant/config/sddm.conf /etc/sddm.conf
pacman -Syu --noconfirm --needed --noprogressbar \
  xorg-server \
  sddm

systemctl enable sddm
