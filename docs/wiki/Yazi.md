# Yazi File Manager

Yazi is a blazing-fast terminal file manager written in Rust, with async I/O and native Kitty image previews. It replaces ranger in HorneroConfig with better performance, simpler theming, and built-in archive/media support.

---

## Quick Start

```bash
# Open yazi in current directory
dots yazi

# Open yazi and cd to last directory on exit
dots yazi --last-dir

# Or use the shell alias
ycd

# Show keybinding cheatsheet
dots yazi --cheatsheet

# Check preview dependencies
dots yazi --fix-previews
```

---

## Configuration

All config lives in `~/.config/yazi/`:

| File | Purpose |
| --- | --- |
| `yazi.toml` | General settings, openers, preview config |
| `keymap.toml` | Custom keybindings (layered on defaults) |
| `theme.toml` | Color scheme / flavor selection |
| `init.lua` | Lua plugin hooks |

### Key Settings (yazi.toml)

- **Miller columns**: `ratio = [2, 4, 4]` (parent, current, preview)
- **Hidden files**: `show_hidden = true`
- **Sort**: `sort_by = "natural"`, directories first
- **Previews**: Kitty protocol auto-detected, quality 75

### Openers

Files open with `xdg-open` by default. Directories can also open in Thunar. Text files open in `$EDITOR`.

---

## Keybindings

### Navigation

| Key | Action |
| --- | --- |
| `h` / `l` | Parent / Enter directory |
| `j` / `k` | Move down / up |
| `~` | Go home |
| `.` | Toggle hidden files |

### Quick Directories (g + key)

| Key | Directory |
| --- | --- |
| `gh` | Home |
| `gp` | ~/Projects |
| `gd` | ~/Downloads |
| `gD` | ~/Documents |
| `gP` | ~/Pictures |
| `gm` | ~/Music |
| `gv` | ~/Videos |
| `gc` | ~/.config |
| `gl` | ~/.local |
| `gr` | Rices directory |
| `gw` | Current rice wallpapers |
| `gb` | ~/.local/bin (scripts) |
| `gt` | /tmp |

### File Operations

| Key | Action |
| --- | --- |
| `Space` | Toggle select |
| `y` | Copy (yank) |
| `x` | Cut |
| `p` | Paste |
| `a` | Create file/dir |
| `r` | Rename |
| `d` | Trash |
| `DD` | Safe trash (confirm) |
| `yp` | Yank path to clipboard |
| `yd` | Yank directory to clipboard |
| `yn` | Yank filename to clipboard |

### Power Features

| Key | Action |
| --- | --- |
| `f` | Filter files |
| `/` | Search |
| `z` | Jump with zoxide |
| `Z` | Jump with fzf |
| `C` | Compress selection |
| `X` | Extract archive |
| `Alt-t` | Open in Thunar |
| `s` | Shell command |

### Sorting (o + key)

| Key | Sort by |
| --- | --- |
| `on` | Name |
| `os` | Size |
| `om` | Modified |
| `ot` | Type |
| `oe` | Extension |
| `or` | Reverse |

---

## Smart Colors Integration

Yazi inherits terminal colors via escape sequences. When you switch rice themes:

1. `dots-wal-reload` regenerates pywal colors
2. Terminal (Kitty) receives new color palette
3. Yazi automatically picks up the new colors

No custom colorscheme file is needed (unlike ranger). The `theme.toml` uses Catppuccin flavors as a base, with terminal colors taking priority.

---

## Image Previews

Yazi uses native Kitty image protocol for previews. Requirements:

- **Kitty terminal** (v0.28.0+) -- automatic, no configuration needed
- **ffmpegthumbnailer** -- video thumbnails
- **poppler** (pdftoppm) -- PDF previews
- **imagemagick** -- image conversion

Run `dots yazi --fix-previews` to check all dependencies.

---

## Shell Integration

The `ycd` alias (defined in `.zsh_aliases`) launches yazi and changes your shell directory to wherever you navigated when you quit:

```bash
ycd              # launch yazi, cd on exit
ycd ~/Projects   # start in specific directory
```

The `Super+E` keybinding in Hyprland opens yazi in a floating popup window.

---

## Dots Integration

- **Wrapper script**: `dots-yazi` (or `dots yazi`)
- **Hyprland keybinding**: `Super+E` opens yazi popup
- **Thunar context menu**: "Open in Yazi" right-click option
- **Waybar**: yazi popup windows get file manager icon
- **Smart colors**: automatic terminal color inheritance

---

## Troubleshooting

### Images not previewing

```bash
dots yazi --fix-previews
```

Check that you are running inside Kitty terminal. Other terminals may need ueberzugpp.

### Colors look wrong

Ensure pywal/smart-colors are generating terminal colors:

```bash
dots-wal-reload
```

### Plugins not loading

```bash
ya pkg install    # Install all locked plugins
ya pkg upgrade    # Upgrade plugins
```
