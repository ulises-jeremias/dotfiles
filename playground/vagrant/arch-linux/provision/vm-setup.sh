#!/usr/bin/env bash

set -e

pacman -Rs --noconfirm virtualbox-guest-utils-nox
pacman -Syu --noconfirm --needed --noprogressbar virtualbox-guest-utils
