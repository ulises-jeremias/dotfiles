#!/usr/bin/env bash

POLYBARS=("polybar-top" "polybar-bottom")

WM=$(wmctrl -m | grep -oE 'Name: .*' | cut -d' ' -f2 | tr '[:upper:]' '[:lower:]')
if [ "${WM}" = "i3" ]; then
  POLYBARS=("i3-polybar-top" "i3-polybar-bottom")
fi
