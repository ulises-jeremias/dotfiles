# Appearance and Theme Packs

HorneroConfig appearance is **live-state first**. Theme packs are optional
one-shot recipes — they never own a sticky “current theme”.

## Live sources of truth

| Concern        | Path / tool                                              |
|----------------|----------------------------------------------------------|
| Wallpaper      | `~/.local/state/dots/wallpaper/path`                     |
| Palette        | `~/.cache/dots/smart-colors/scheme.json`                 |
| Mode / flavour | `~/.local/state/dots/scheme/state.json`                  |
| GTK / icons    | via `dots-gtk-theme` → `settings.ini` + gsettings        |
| Wal pointer    | `~/.cache/wal/wal` (**text path file**, never a symlink) |

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
dots appearance set-gtk Orchis-Light-Compact
dots appearance set-icons Numix-Circle
dots appearance status
dots appearance doctor
```

GTK entrypoint (canonical for scripts and Quickshell):

```bash
dots-gtk-theme -q -p list
dots-gtk-theme -q -p current
dots-gtk-theme -q -p current-icon
dots-gtk-theme -q apply Orchis-Light-Compact Numix-Circle true
dots-gtk-theme -q color-scheme dark
dots-gtk-theme -q theme vapor-dreams
```

## Quickshell

- Orchestrator: `ThemePipeline` singleton (IPC target `appearance`)
- Control Center pane configures themes, wallpaper, mode, variant, scheme, GTK, icons
- GTK/icon apply always goes through `dots-gtk-theme` (never inline `gtk-theme-manager.sh` or raw `gsettings` from QML)
- Launcher actions: `theme` / `appearance`

## Consistency checks

```bash
./scripts/test-appearance-consistency.sh --source   # CI / repo
./scripts/test-appearance-consistency.sh             # live doctor + GTK
dots appearance doctor
```

## Historical note

Older docs referred to sticky “rices” (`rices/<id>/`, IPC `rice`, `dots-rice`).
That model was removed; this page is the current contract. The wiki filename
`Rice-System-Theme-Management` is kept only for stable links.
