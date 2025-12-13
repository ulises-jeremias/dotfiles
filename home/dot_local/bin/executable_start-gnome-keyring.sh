#!/usr/bin/env bash

# Start gnome-keyring-daemon and export environment variables
# This wrapper ensures proper initialization for Hyprland

if command -v gnome-keyring-daemon >/dev/null 2>&1; then
  # Start daemon and capture environment variable exports
  # The --start flag daemonizes the process and outputs env vars to set
  eval "$(gnome-keyring-daemon --start --components=secrets,pkcs11,ssh)"

  # Export variables for child processes
  export GNOME_KEYRING_CONTROL
  export SSH_AUTH_SOCK

  # The daemon is now running in the background, script can exit
else
  echo "gnome-keyring-daemon not found" >&2
  exit 1
fi
