# Smart Colors System

Smart Colors generates semantic colors and Material Design 3 palettes from the current wallpaper, then keeps Quickshell synchronized.

## Primary Contract

- Quickshell is the main consumer through `~/.cache/dots/smart-colors/scheme.json`.
- `dots-wal-reload` and `dots-wallpaper-set` trigger palette refresh and Quickshell IPC reload.
- Script consumers can source shell/env exports from the same cache directory.

## Wallpaper Pipeline Contract

### Maintained path (Hyprland + Quickshell)

1. `dots-wallpaper-set <image>` (or Control Center Apply / `Rice.setWallpaper`)
2. When Quickshell is running → IPC `rice setWallpaper`
3. Otherwise → `apply-appearance.sh` wallpaper-only path:
   - `wal -i` (honors light/dark from current rice / scheme state)
   - write `~/.local/state/dots/wallpaper/path`
   - `generate-m3-colors.py` → `scheme.json`
   - `dots-color-scheme sync-state` → `scheme/state.json`
4. `Colours.qml` reloads via file watch or `dots-quickshell ipc colours reload` (real IPC + touch fallback)

### Wallpaper resolution priority

1. Explicit argument
2. `~/.local/state/dots/wallpaper/path` (canonical persistent pointer)
3. `~/.cache/wal/wal` (pywal symlink; last resort)

## Main Commands

```bash
dots-smart-colors --generate --m3
dots-smart-colors --analyze
dots-smart-colors --concept=error
dots-wal-reload
```

## Generated Cache

All generated files are written to `~/.cache/dots/smart-colors/`.

Core files:

- `scheme.json` (Quickshell M3 palette)
- `colors.sh` (shell variables for scripts)
- `colors.env` (export-friendly environment file)
- `colors-hyprlock.env` (lockscreen integration)
- `colors-kitty.conf` (terminal integration)
- `colors.css` (generic CSS variables)

Compatibility files may exist for external tooling, but they are not part of the primary UX contract.

## Data Flow

```mermaid
flowchart LR
  wallpaper[WallpaperChange] --> set[dots-wallpaper-set]
  set --> rice[RiceIpcOrShellFallback]
  rice --> wal[pywal]
  rice --> m3[generate-m3-colors]
  m3 --> scheme[schemeJson]
  m3 --> state[schemeStateJson]
  scheme --> colours[QuickshellColoursService]
  colours --> ui[QuickshellUIUpdated]
```

## Troubleshooting

```bash
# Rebuild smart-colors cache
dots-smart-colors --generate --m3

# Confirm cache files exist
ls -la ~/.cache/dots/smart-colors/

# Force shell-side reload path
dots-quickshell ipc colours reload
```

## Notes

- Legacy Waybar/EWW/Rofi integrations are no longer part of the maintained path.
- The supported default stack is Hyprland + Quickshell.
