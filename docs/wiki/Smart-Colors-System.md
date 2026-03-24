# Smart Colors System

Smart Colors generates semantic colors and Material Design 3 palettes from the current wallpaper, then keeps Quickshell synchronized.

## Primary Contract

- Quickshell is the main consumer through `~/.cache/dots/smart-colors/scheme.json`.
- `dots-wal-reload` and `dots-wallpaper-set` trigger palette refresh and Quickshell IPC reload.
- Script consumers can source shell/env exports from the same cache directory.

## Wallpaper Pipeline Contract

### Historical pipelines

- **wpgtk pipeline**: `wpg -s <image>` -> `wpg.conf` runs `dots-wal-reload` and refreshes shell colors.
- **Legacy Quickshell direct pipeline**: UI actions used to call compositor-specific wallpaper setters directly, bypassing `wpg` and global reload orchestration.

The direct pipeline could desynchronize `~/.config/wpg/.current` from shell/runtime state and miss some app reloads that are centralized in `dots-wal-reload`.

### Unified contract

- Use `dots-wallpaper-set` as the single entrypoint for wallpaper changes from shell UI/actions.
- When `wpg` is available, `dots-wallpaper-set` delegates to `wpg -s` so wpgtk remains source-compatible.
- Wallpaper resolution priority is unified across scripts:
  1. Explicit argument
  2. `~/.local/state/dots/wallpaper/path` (canonical persistent pointer; respects `DOTS_STATE_DIR` / `XDG_STATE_HOME`)
  3. `~/.cache/wal/wal` (pywal)
  4. `~/.config/wpg/.current` (optional, when using wpgtk)

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
  set --> wal[dots-wal-reload]
  wal --> smart[dots-smart-colorsGenerate]
  smart --> scheme[schemeJson]
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
