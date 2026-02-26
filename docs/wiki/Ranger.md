# 📁 Ranger Terminal File Manager

[Ranger](https://ranger.github.io/) is a terminal-based file manager with VI-style keybindings, file previews, and a column-based interface. In HorneroConfig it is fully integrated with the **Smart Colors System**, **Hyprland**, and the **dots ecosystem**.

> [!TIP]
> Ranger works alongside Thunar — use `Super+F` for the GUI file manager and `Super+Shift+F` for the terminal-based ranger. Both share the same bookmarks and integrate with the same color system.

---

## 🚀 Why Ranger?

- ⌨️ VI-style navigation — blazing fast without a mouse
- 🖼️ Rich file previews — images, PDFs, videos, code with syntax highlighting
- 🎨 Smart Colors — automatically adapts to your current rice/wallpaper
- 🔍 Fuzzy search — fzf + ripgrep integration for powerful file finding
- 📦 Archive handling — compress and extract with a single keystroke
- 🔗 Drag & drop — bridge terminal and GUI with `dragon-drop`
- 🗂️ Git-aware — VCS status shown in the file listing

---

## ⚙️ Configuration

All ranger config lives in `~/.config/ranger/` and is managed by chezmoi:

```
~/.config/ranger/
├── rc.conf          # Main settings and keybindings
├── rifle.conf       # File opener rules
├── scope.sh         # Preview generator script
├── commands.py      # Custom Python commands
└── colorschemes/
    └── smart.py     # Adaptive colorscheme
```

To edit with chezmoi:

```sh
chezmoi edit ~/.config/ranger/rc.conf
chezmoi apply
```

> [!NOTE]
> The config uses `RANGER_LOAD_DEFAULT_RC=FALSE` to load **only** our curated configuration, ignoring ranger's massive default rc.conf.

---

## 🖼️ Image Previews (Wayland)

HorneroConfig uses the **kitty image protocol** for inline image previews — the most reliable method on Wayland compositors like Hyprland.

### How it works

- `preview_images_method kitty` is set in `rc.conf`
- `python-pillow` provides the PIL library needed by the kitty protocol
- `scope.sh` generates thumbnails for PDFs, videos, SVGs, and more

### Supported preview types

| File type | Tool | Preview |
|-----------|------|---------|
| Images | kitty protocol | Inline image |
| Code | `bat` | Syntax-highlighted text |
| Markdown | `glow` | Rendered markdown |
| JSON | `jq` | Pretty-printed + colored |
| PDF | `pdftoppm` | First page as image |
| Video | `ffmpegthumbnailer` | Thumbnail frame |
| SVG | `rsvg-convert` | Rendered image |
| Archives | `atool` | File listing |
| Directories | `exa` / `lsd` / `tree` | Colorized file tree |
| Fonts | `fontimage` | Sample rendering |
| Torrents | `transmission-show` | Torrent info |
| EXIF | `exiftool` | Metadata |

### Troubleshooting previews

```sh
dots-ranger --fix-previews
```

This runs a diagnostic check on all preview dependencies and tells you what's missing.

---

## ⌨️ Key Bindings

### Navigation

| Key | Action |
|-----|--------|
| `h/j/k/l` | Left/Down/Up/Right (vim-style) |
| `gg` / `G` | Go to top / bottom |
| `H` / `L` | History back / forward |
| `[` / `]` | Parent directory up / down |
| `~` | Go to home directory |

### Quick Bookmarks

| Key | Directory |
|-----|-----------|
| `gh` | `~` (Home) |
| `gp` | `~/Projects` |
| `gd` | `~/Downloads` |
| `gD` | `~/Documents` |
| `gP` | `~/Pictures` |
| `gm` | `~/Music` |
| `gv` | `~/Videos` |
| `gc` | `~/.config` |
| `gl` | `~/.local/share` |
| `gb` | `~/.local/bin` |
| `gr` | `~/.local/share/dots/rices` |
| `gw` | Wallpapers directory |

### File Operations

| Key | Action |
|-----|--------|
| `Space` | Toggle selection |
| `v` / `uv` | Select all / Unselect all |
| `yy` | Yank (copy) |
| `dd` | Cut |
| `pp` | Paste |
| `po` | Paste overwriting |
| `cw` | Rename |
| `A` | Rename (append to name) |
| `I` | Rename (insert at beginning) |
| `a` | Rename (append before extension) |
| `DD` | Trash (move to trash) |
| `dD` | Delete permanently |
| `mkd` | Create directory |

### Power Commands

| Key | Action |
|-----|--------|
| `Ctrl+f` | **fzf file search** — fuzzy find with live preview |
| `Ctrl+g` | **fzf content search** — ripgrep inside files |
| `C` | **Compress** — create archive (auto-detects format) |
| `X` | **Extract** — smart extraction |
| `:dragon` | **Drag & drop** — send files to GUI apps |
| `:flat N` | Flatten directory N levels deep |
| `:disk_usage` | Calculate directory sizes |
| `:git_status` | Show git changes |
| `:cheatsheet` | Show all custom commands |

### Yank (Clipboard)

| Key | Action |
|-----|--------|
| `yn` | Yank filename |
| `y.` | Yank filename without extension |
| `yp` | Yank full path |
| `yd` | Yank directory path |

> [!NOTE]
> All yank commands use `wl-copy` (Wayland clipboard) for seamless integration with GUI apps.

### Tabs

| Key | Action |
|-----|--------|
| `Ctrl+n` | New tab |
| `Ctrl+w` | Close tab |
| `Tab` / `Shift+Tab` | Next / Previous tab |
| `Alt+N` | Go to tab N |

### Display

| Key | Action |
|-----|--------|
| `zh` / `Ctrl+h` | Toggle hidden files |
| `zp` | Toggle preview |
| `zf` | Filter files |
| `or` | Sort by reverse |
| `os` | Sort by size |
| `ot` | Sort by time |
| `on` | Sort by name |

---

## 🎨 Smart Colors Integration

Ranger's colorscheme automatically adapts to your current wallpaper/rice through the **Smart Colors System**.

### How it works

1. When you change wallpaper, `dots-wal-reload` triggers
2. `dots-smart-colors` generates `~/.cache/dots/smart-colors/colors-ranger.py`
3. The `smart` colorscheme in ranger reads these colors
4. Ranger receives `SIGUSR1` to live-reload without restarting

### Color mapping

| UI Element | Color Source |
|------------|-------------|
| Background | `background` from palette |
| Foreground | `foreground` from palette |
| Selected items | `accent` color |
| Directory names | `color4` (blue) |
| Executables | `color2` (green) |
| Links | `color6` (cyan) |
| Images | `color5` (magenta) |
| Archives | `color1` (red) |
| Status bar | `accent` on `background` |
| Error messages | `color1` (red) |
| Title bar | `accent` color, bold |

### Manual refresh

```sh
dots-wal-reload
# or just send the signal:
pkill -USR1 ranger
```

---

## 🛠️ Dots Integration

### dots-ranger

The `dots-ranger` wrapper script provides enhanced features:

```sh
# Normal launch
dots-ranger

# Navigate and cd to directory on exit
dots-ranger --last-dir

# Show command cheatsheet
dots-ranger --cheatsheet

# Diagnose preview issues
dots-ranger --fix-previews
```

### Shell aliases

Available in your shell after installation:

```sh
ra         # Launch ranger (quick alias)
rcd        # Launch ranger, cd to last directory on exit
```

The `rcd` function is especially powerful — navigate to any directory in ranger, press `q` to quit, and your shell is now in that directory.

### Hyprland keybindings

| Key | Action |
|-----|--------|
| `Super+F` | Open GUI file manager (Thunar) |
| `Super+Shift+F` | Open ranger in floating kitty window |

The floating ranger window uses the `ranger-popup` window class with a 75×80% size, centered on screen.

### Thunar integration

Right-click any directory in Thunar → **Open in Ranger** to launch ranger in a kitty terminal at that location.

---

## 📦 Dependencies

All dependencies are automatically installed via chezmoi. The install script handles:

**Core:**
- `ranger` — the file manager
- `python-pillow` — kitty image protocol support

**Preview tools:**
- `bat` — syntax-highlighted code previews
- `poppler` — PDF page rendering
- `ffmpegthumbnailer` — video thumbnails
- `mediainfo` — media file metadata
- `imagemagick` — image manipulation
- `perl-image-exiftool` — EXIF data
- `glow` — markdown rendering
- `odt2txt` — LibreOffice document text
- `w3m` — HTML rendering

**Power tools:**
- `fzf` — fuzzy file finder
- `ripgrep` — content search inside files
- `fd` — fast file finder
- `atool` — archive handling
- `trash-cli` — safe file deletion
- `dragon-drop-git` — terminal-to-GUI drag & drop

---

## 🆘 Common Issues

### Images not showing in preview pane

Run `dots-ranger --fix-previews` to diagnose. Most common causes:

1. **Missing python-pillow**: `yay -S python-pillow`
2. **Wrong terminal**: kitty image protocol requires the kitty terminal
3. **TERM variable**: Ensure `$TERM` contains `kitty` or `xterm-kitty`

### Colors not updating with wallpaper

1. Check that `~/.cache/dots/smart-colors/colors-ranger.py` exists
2. Run `dots-smart-colors` manually to regenerate
3. Verify the colorscheme is set: `set colorscheme smart` in `rc.conf`

### Preview pane shows raw text instead of images

Ensure `set preview_images true` and `set preview_images_method kitty` are in `rc.conf`.

---

## 🔗 Related

- [💻 Kitty Terminal](Kitty) — the terminal hosting ranger
- [📁 Thunar File Manager](Thunar-Side-Panel) — GUI file manager companion
- [🧠 Smart Colors System](Smart-Colors-System) — adaptive color theming
- [📜 Dots Scripts](Dots-Scripts) — all dots utilities
- [⌨️ Hyprland Keybindings](Hyprland-Keybindings) — keyboard shortcuts

---

Ranger gives you the speed of a terminal with the power of a visual file manager. Combined with smart colors and the dots ecosystem, it becomes a truly adaptive tool that feels native to your desktop. 📁⌨️
