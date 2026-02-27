#!/usr/bin/env sh

cat ~/.local/state/dots/sequences.txt 2>/dev/null

exec "$@"
