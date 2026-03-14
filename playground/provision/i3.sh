#!/usr/bin/env bash

set -e

pacman -Syu --noconfirm --needed --noprogressbar \
  i3-wm \
  i3status
