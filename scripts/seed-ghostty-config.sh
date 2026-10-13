#!/usr/bin/env bash
set -euo pipefail

source_config="${HORNEROS_GHOSTTY_DEFAULT_CONFIG:-/etc/skel/.config/ghostty/config.ghostty}"
config_home="${XDG_CONFIG_HOME:-${HOME:?HOME is required}/.config}"
destination="$config_home/ghostty/config.ghostty"

[[ -r $source_config ]] || exit 0

if [[ -e $destination || -L $destination ]]; then
  [[ -f $destination && ! -L $destination && ! -s $destination ]] || exit 0
fi

install -D -m 0644 -- "$source_config" "$destination"
