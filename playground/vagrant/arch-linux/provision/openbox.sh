#!/usr/bin/env bash

set -e

pacman -Syu --noconfirm --needed --noprogressbar \
  openbox \
  obconf
