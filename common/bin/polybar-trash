#!/usr/bin/env bash

TRASH_DIRECTORY="$BLOCK_INSTANCE"

if [[ $TRASH_DIRECTORY = "" ]]; then
    TRASH_DIRECTORY="${XDG_DATA_HOME:-$HOME/.local/share}/Trash"
fi

if [[ $BLOCK_BUTTON -eq 1 ]]; then
    xdg-open "$TRASH_DIRECTORY/files"
elif [[ $BLOCK_BUTTON -eq 3 ]]; then
    rm -r "$TRASH_DIRECTORY/files"
    rm -r "$TRASH_DIRECTORY/info"
    mkdir "$TRASH_DIRECTORY/files"
    mkdir "$TRASH_DIRECTORY/info"
fi

TRASH_COUNT=$(ls -U -1 "$TRASH_DIRECTORY/files" | wc -l)
URGENT_VALUE=30
echo "$TRASH_COUNT"
echo "$TRASH_COUNT"
echo ""

if [[ $TRASH_COUNT -ge $URGENT_VALUE ]]; then
    exit 31
fi
