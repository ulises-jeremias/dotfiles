# Quickshell Hard-Cut Matrix

This document is the operational source of truth for the Quickshell-first simplification.
It defines what stays, what is removed, and why.

## Keep (Core Contract)

- `home/dot_local/bin/executable_dots-quickshell`
- `home/dot_local/bin/executable_dots-appearance`
- `home/dot_local/bin/executable_dots-color-scheme`
- `home/dot_local/bin/executable_dots-smart-colors`
- `home/dot_local/bin/executable_dots-hyprpaper-set`
- `home/dot_local/bin/executable_dots-wal-reload`
- `home/dot_local/bin/executable_dots-settings-gui`
- `home/dot_local/bin/executable_dots-launcher` (Quickshell-first, minimal rescue)
- `home/dot_local/bin/executable_dots-power-menu` (Quickshell-first, minimal rescue)
- `home/dot_local/bin/executable_dots-clipboard` (Wayland-first clipboard flow without legacy UI chain)

## Keep (Unique Capability, Not Replaced by Quickshell)

- `home/dot_local/bin/executable_dots-recorder`
- `home/dot_local/bin/executable_dots-screenshooter`
- `home/dot_local/bin/executable_dots-lockscreen`
- `home/dot_local/bin/executable_dots-backup`
- `home/dot_local/bin/executable_dots-security-audit`
- `home/dot_local/bin/executable_dots-keyboard-help`

## Remove (Hard Cut)

- `home/dot_local/bin/executable_dots-jgmenu`
- `home/dot_local/bin/executable_dots-scripts`
- `home/dot_config/jgmenu/append.csv`
- `home/dot_config/jgmenu/prepend.csv`
- `home/dot_config/jgmenu/jgmenurc-config`
- `home/.chezmoiscripts/linux/run_onchange_before_install-jgmenu.sh.tmpl`
- `home/.chezmoiscripts/linux/run_onchange_before_install-compositor.sh.tmpl` (picom legacy)
- `home/.chezmoiscripts/linux/run_onchange_before_install-x.sh.tmpl` (X11 helper legacy default)
- `home/.chezmoiscripts/linux/run_onchange_before_install-xfce4.sh.tmpl` (legacy desktop stack default)
- `home/.chezmoiscripts/linux/run_onchange_before_install-networkmanager-dmenu.sh.tmpl`
- `home/dot_config/autostart/eww-daemon.desktop`

## Install Surface (Core vs Optional)

Core install should represent Quickshell + Hyprland only:

- Keep: `hyprland`, `quickshell`, `hyprpaper`, `hyprlock`, `hypridle`, `cliphist`, `wl-clipboard`, `copyq`, core media/network/system packages.
- Remove from core defaults: `mako`, `wofi`, `nwg-bar`, `nwg-drawer`, `wlogout`, and other legacy menu/widget stack assumptions.

## Call-Site Cleanup Requirement

After removals, no remaining references should exist in:

- keybind docs and wiki pages
- install scripts
- validation scripts
- helper registries (`dots-scripts.sh`)
- startup/init scripts

## Validation Checklist

- `dots launcher` toggles Quickshell launcher.
- `dots power-menu` toggles Quickshell session drawer.
- `dots clipboard` works on Wayland without legacy menu chain.
- `dots quickshell ipc ...` targets still work (`launcher`, `session`, `utilities`, `dashboard`, `sidebar`, `bar`, `colours`).
- documentation commands match real binaries in `~/.local/bin`.
