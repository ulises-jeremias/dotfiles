#!/usr/bin/env bash

# Terminate already running bar instances
pkill -9 polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

if [ -z "${TERM}" ]; then
  TERM=xterm-256color
fi

export TERM

WM=$(wmctrl -m | grep -oE 'Name: .*' | cut -d' ' -f2 | tr '[:upper:]' '[:lower:]')

if [ "${WM}" = "i3" ]; then
  polybars=("i3-polybar-top" "i3-polybar-bottom")
else
  polybars=("polybar-top" "polybar-bottom")
fi

for bar in "${polybars[@]}"; do
  polybar -r "${bar}" 2>&1 | tee -a /tmp/polybar-"${bar}".log &
  disown
done
