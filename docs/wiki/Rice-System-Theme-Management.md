# Appearance and Theme Packs

HorneroConfig appearance is **live-state first**. Theme packs are optional
one-shot recipes — they never own a sticky “current theme”.

## Live sources of truth

| Concern        | Path                                              |
|----------------|---------------------------------------------------|
| Wallpaper      | `~/.local/state/dots/wallpaper/path`              |
| Palette        | `~/.cache/dots/smart-colors/scheme.json`          |
| Mode / flavour | `~/.local/state/dots/scheme/state.json`           |
| GTK / icons    | via `dots-gtk-theme` → `settings.ini` + gsettings |

## Theme packs

Recipes live in `~/.local/share/dots/themes/<id>/theme.json`.
Wallpapers live in `~/.local/share/dots/wallpapers/<id>/` and are linked into
`~/Pictures/Wallpapers/<id>/` by chezmoi.

Apply from Control Center → Appearance → Themes (stage, optionally pick a
wallpaper, then Apply), or:

```bash
dots appearance theme list
dots appearance theme apply vapor-dreams
dots appearance theme apply neon-city --wallpaper ~/Pictures/Wallpapers/neon-city/neon-city-01.jpg
```

## Everyday controls

```bash
dots appearance set-wallpaper <path>
dots appearance set-mode dark|light
dots appearance set-variant expressive
dots appearance set-gtk Orchis-Dark
dots appearance set-icons Numix-Circle
dots appearance status
dots appearance doctor
```

## Quickshell

- Orchestrator: `ThemePipeline` singleton (IPC target `appearance`)
- Control Center pane configures themes, wallpaper, mode, variant, scheme, GTK, icons
- GTK/icon apply always goes through `dots-gtk-theme` (never inline `gtk-theme-manager.sh` or raw `gsettings` from QML)
