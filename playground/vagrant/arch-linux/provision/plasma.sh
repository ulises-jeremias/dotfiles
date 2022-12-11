#!/usr/bin/env bash

set -e

pacman -Syu --noconfirm --needed --noprogressbar \
  plasma-desktop \
  kwallet-pam \
  ark \
  dolphin \
  kate \
  konsole \
  kwalletmanager \
  okular \
  gwenview \
  spectacle
