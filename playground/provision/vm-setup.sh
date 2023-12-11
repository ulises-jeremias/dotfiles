#!/usr/bin/env bash

set -e

pacman -Rs --noconfirm virtualbox-guest-utils-nox
pacman -Syu --noconfirm --needed --noprogressbar virtualbox-guest-utils

localectl --no-convert set-x11-keymap us
