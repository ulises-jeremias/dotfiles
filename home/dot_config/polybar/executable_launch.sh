#!/usr/bin/env bash

# Terminate already running bar instances
pkill -9 polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Set TERM variable to xterm-256color if it's not set
if [ -z "${TERM}" ]; then
  TERM=xterm-256color
fi
export TERM

source ~/.local/lib/dots/dots-rice-config.sh

for bar in "${POLYBARS[@]}"; do
  polybar -r "${bar}" 2>&1 | tee -a /tmp/polybar-"${bar}".log &
  disown
done
