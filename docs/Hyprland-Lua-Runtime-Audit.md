# Runtime Hyprland Integrations — Lua Migration Audit

> Part of `ulises-jeremias/dotfiles#179` — closes `ulises-jeremias/dotfiles#186`

## Summary

Verifies that all runtime consumers of Hyprland configuration and IPC remain
compatible after the config-load-time migration from hyprlang to Lua.

## Runtime consumers audited

### Quickshell GameMode (`home/dot_config/quickshell/services/GameMode.qml`)

Uses `Hypr.extras.applyOptions()` which sends `hyprctl keyword` commands via the
Hornero C++ plugin's socket connection. Operates on the **live session** state,
not the config file. Compatible with Lua config. **No changes needed.**

### Quickshell Rice.qml — animation switching

Animation profile switching was updated in `#184` to:

- Write a Lua `require()` wrapper to `hyprland.lua.d/animations-current.lua`
- Use `hyprctl reload` to apply changes

`hyprctl reload` re-evaluates the entire config in a fresh Lua state, loading
the new animation profile. **Already updated in #184.**

### Quickshell Rice.qml — `hyprctl reload`

The `hyprReloadProc` Process sends `["hyprctl", "reload"]`, which re-evaluates
the config in a fresh Lua state regardless of config format. **No changes needed.**

### Quickshell HyprExtras plugin (`home/dot_config/quickshell/plugin/src/Hornero/Internal/`)

Communicates via Hyprland's UNIX socket (`.socket.sock`, `.socket2.sock`) for
request/response and events. Sends `keyword` and `dispatch` messages that
operate on the live session runtime state. **No changes needed.**

### `dots-hypr-layout` (`home/dot_local/bin/executable_dots-hypr-layout`)

Uses `hyprctl keyword general:layout ...` and `hyprctl getoption general:layout ...`
to read/write the active layout at runtime. These APIs use the live session
state. **No changes needed.**

### `dots-hypr-monitors` (`home/dot_local/bin/executable_dots-hypr-monitors`)

Uses `hyprctl keyword monitor ...` to enable/disable and reposition monitors at
runtime. Runtime session API. **No changes needed.**

### `gaps-interactive.sh` (`home/dot_config/hypr/scripts/executable_gaps-interactive.sh`)

Uses `hyprctl keyword general:gaps_in` and `general:gaps_out` to adjust gaps at
runtime. **No changes needed.**

### `smart-float.sh` (`home/dot_config/hypr/scripts/executable_smart-float.sh`)

Uses `hyprctl dispatch togglefloating`, `resizeactive`, and `centerwindow` at
runtime. **No changes needed.**

### `dots-keyboard-help` (`home/dot_local/bin/executable_dots-keyboard-help`)

Was updated in `#182` to use `hyprctl binds -j` instead of reading the old
`keybindings.conf` file. **Already updated in #182.**

### `dots-wal-reload` / `dots-color-scheme`

These scripts delegate to Quickshell IPC or run standalone fallbacks. They
do not reference any Hyprland config paths directly. **No changes needed.**

### `dots-hyprlock-theme` (`home/dot_local/bin/executable_dots-hyprlock-theme`)

Generates color overrides for **hyprlock**, which remains in hyprlang format.
Its output path is `~/.cache/dots/smart-colors/colors-hyprlock.conf`.
**No changes needed.**

## Conclusion

All runtime consumers use `hyprctl keyword`/`dispatch` or communicate via
Hyprland's IPC socket, which operate on the live session state independent of
the config file format. No additional code changes are required beyond the
animation path update already completed in `#184`.
