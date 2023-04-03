#!/usr/bin/env bash

XDG_CONFIG_HOME="${HOME}"/.config
export XDG_CONFIG_HOME

[[ "${PATH}" == *"${HOME}/.local/bin"* ]] || export PATH="${HOME}/.local/bin:${PATH}"

dots-scripts autostart &
