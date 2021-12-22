#!/usr/bin/env bash

sudo pacman -S openbox
mkdir -p "${XDG_CONFIG_HOME:-"${HOME}"/.config}"/openbox
