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
- Rescue path: minimal prompt

```bash
dots launcher
dots launcher --backend=quickshell
```

### clipboard

- Primary: `dots-quickshell ipc utilities toggle`
- Secondary (Wayland): `cliphist` terminal picker
- X11 fallback: `copyq`
- Rescue path: minimal output

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
- Viewer backend: terminal (`less`)

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

### wallpaper-set

- Unified wallpaper entrypoint used by Quickshell and scripts
- Delegates to `wpg -s` when available
- Fallback path writes wallpaper state files and triggers smart-colors + Quickshell palette reload

```bash
dots wallpaper-set /path/to/wallpaper.jpg
```

## Notes

- Legacy Waybar/EWW/Rofi/JGMenu integration was intentionally removed.
- `dots rice` remains available as legacy-compatible naming; `dots appearance` is the canonical contract.
- `dots-*` scripts remain modular and can be called directly.
