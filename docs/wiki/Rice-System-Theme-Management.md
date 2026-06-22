# Rice System: Theme Management

The rice system is now managed through the Quickshell-first appearance workflow.

## Canonical Commands

```bash
dots appearance list
dots appearance current
dots appearance apply neon-city
dots appearance set-variant vibrant
dots appearance set-mode dark
dots appearance set-wallpaper /path/to/wallpaper.jpg
```

`dots rice ...` is retained as compatibility naming, but `dots appearance ...` is the canonical interface.

## What a Rice Controls

- wallpaper selection
- smart-colors / M3 palette generation
- light/dark mode and M3 variant
- GTK theme metadata and optional extras
- Quickshell-facing appearance state

## Quickshell Integration

Appearance changes done from the control center can be previewed first, then committed with Apply/Save.

```mermaid
flowchart LR
  user[UserSelectsAppearance] --> preview[QuickshellPreview]
  preview --> apply[ApplyOrSave]
  apply --> cli[dots-appearanceApply]
  cli --> palette[dots-smart-colorsAndScheme]
  palette --> shell[QuickshellReload]
```

## Structure

Rices live under:

`~/.local/share/dots/rices/<rice-name>/`

Typical files:

- `config.json` — canonical config consumed by Quickshell's `list-rices.py` and `Rice.qml`
- `config.sh` — shell-sourceable mirror of the same metadata (used by legacy/`dots-gtk-theme`)
- `backgrounds/` — wallpaper images (PNG/JPG/WEBP); the first sorted file becomes the default wallpaper
- `preview.png` — small thumbnail shown in the rice selector carousel

## Catppuccin Variants

All four official Catppuccin flavours are available as rices, grouped under the `catppuccin` tag in the launcher:

| Rice                   | Mode  | Base      | Accent (Mauve) | Best for                            |
|------------------------|-------|-----------|----------------|-------------------------------------|
| `catppuccin-latte`     | light | `#eff1f5` | `#8839ef`      | Daytime coding, bright environments |
| `catppuccin-frappe`    | dark  | `#303446` | `#ca9ee6`      | Balanced dark, everyday desktop     |
| `catppuccin-macchiato` | dark  | `#24273a` | `#c6a0f6`      | Deep dark, evening sessions         |
| `catppuccin-mocha`     | dark  | `#1e1e2e` | `#cba6f7`      | Cozy dark, creative work            |

Each rice ships with wallpapers generated from the official Catppuccin palette so that the M3 color extraction stays faithful to each variant. GTK themes fall back to `Orchis-Dark` (dark) or `catppuccin-latte-mauve-compact` (light) until a dedicated Catppuccin GTK package is installed.

```bash
dots appearance apply catppuccin-frappe
dots appearance apply catppuccin-macchiato
```

## Notes

- Legacy Rofi/JGMenu theme selectors were removed from the maintained path.
- The maintained desktop path is Hyprland + Quickshell.
