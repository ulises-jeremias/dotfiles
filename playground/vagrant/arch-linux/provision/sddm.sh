#!/usr/bin/env bash

set -e

mv /tmp/sddm.conf /etc/sddm.conf
pacman -Syu --noconfirm --needed --noprogressbar \
  xorg-server \
  plasma-desktop \
  sddm \
  kwallet-pam \
  ark \
  dolphin \
  kate \
  konsole \
  kwalletmanager \
  okular \
  gwenview \
  spectacle

systemctl enable sddm
localectl --no-convert set-x11-keymap us
