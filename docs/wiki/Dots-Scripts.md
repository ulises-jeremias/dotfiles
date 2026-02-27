# Dots Scripts Utility Guide

`dots` is the unified entrypoint for Hornero scripts.

## Usage

```sh
dots --help
dots --list
dots <script> [options]
```

## Quickshell-first workflows

### launcher

- Primary: `dots-quickshell ipc launcher toggle`
- Fallbacks: `fuzzel`, `wofi`, minimal prompt

```bash
dots launcher
dots launcher --backend=quickshell
dots launcher --backend=fuzzel
```

### clipboard

- Primary: `dots-quickshell ipc utilities toggle`
- Fallbacks: `copyq`, `cliphist` (+ fuzzel/wofi), minimal

```bash
dots clipboard
dots clipboard --backend=copyq
dots clipboard --backend=cliphist
```

### power-menu

- Primary: `dots-quickshell ipc session toggle`
- Fallback: minimal TUI selector

```bash
dots power-menu
dots power-menu --mode=quickshell
dots power-menu --mode=minimal
```

### settings-gui

- Quickshell control-center entrypoint
- Starts Quickshell when needed, then toggles `utilities`

```bash
dots settings-gui
```

### keyboard-help

- Parses Hyprland keybindings dynamically
- Picker backend: `fuzzel` or `wofi`

```bash
dots keyboard-help
dots keyboard-help --search=workspace
```

## Theme and color workflows

### appearance

- Unified appearance API for Quickshell UI and scripts
- Manages full themes/rices plus variant/mode/wallpaper syncing

```bash
dots appearance list
dots appearance current
dots appearance apply neon-city
dots appearance set-variant vibrant
dots appearance set-mode dark
```

### smart-colors

- Generates semantic colors and M3 `scheme.json`
- Cache path: `~/.cache/dots/smart-colors/`

```bash
dots smart-colors --generate --m3
dots smart-colors --concept=error
```

### wal-reload

- Rebuilds palette from wallpaper
- Regenerates smart colors
- Reloads Quickshell palette through IPC

```bash
dots wal-reload
```

### hyprpaper-set

- Sets wallpaper through Hyprpaper IPC
- Persists wallpaper state
- Triggers smart-colors regeneration and Quickshell palette reload (unless invoked from an outer theme pipeline)

```bash
dots hyprpaper-set /path/to/wallpaper.jpg
```

## Notes

- Legacy Waybar/EWW/Rofi integration was intentionally removed.
- `dots rice` remains available as legacy-compatible naming; `dots appearance` is the canonical contract.
- `dots-*` scripts remain modular and can be called directly.
