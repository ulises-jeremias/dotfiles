# 💥 Dots Scripts Utility Guide

As part of this dotfiles installation, we provide a curated collection of utility scripts that help automate and enhance your desktop experience. These scripts handle everything from brightness control to network checks, and they’re neatly organized under a single command: `dots`.

> [!TIP]
> All scripts are fully customizable. You can modify them, add your own, or extend existing ones — and manage them with `chezmoi` just like any other part of your dotfiles.

---

## 🚀 What is `dots`?

`dots` is a wrapper utility that exposes various helpful scripts for configuring modules and interacting with your system.

You can use it directly from the terminal to:

- Run scripts individually
- Discover available helpers
- Simplify your workflow

---

## 📦 Usage

```sh
dots --help     # Show help menu
dots --list     # List all available scripts
dots <script>   # Run a specific script (with optional flags)
```

> 🔍 Pro Tip: You can use `chezmoi edit ~/.local/bin/dots` to customize the wrapper script if needed.

---

## 📜 Available Scripts

> 📝 This list may evolve. To check the current list on your system, run: `dots --list`

### 🎯 Core User Interface Tools

#### `launcher` – Application Launcher

**Purpose**: Unified application launcher with intelligent fallback chain  
**Primary Tool**: fuzzel (fast, minimal Wayland launcher)  
**Fallback Chain**: `fuzzel` → `wofi` → `rofi` → `minimal prompt`  
**Usage Examples**:

```bash
dots launcher                    # Auto-detect best launcher
dots launcher --backend=fuzzel   # Force fuzzel
dots launcher --backend=rofi     # Force rofi
dots launcher --list             # Show available launchers
```

#### `clipboard` – Clipboard Manager

**Purpose**: Clipboard history and management  
**Primary Tool**: copyq (feature-rich GUI clipboard manager)  
**Fallback Chain (Wayland)**: `copyq` → `cliphist`+(fuzzel/wofi/rofi) → `rofi greenclip` → `minimal`  
**Fallback Chain (X11)**: `copyq` → `rofi greenclip` → `minimal`  
**Usage Examples**:

```bash
dots clipboard                   # Auto-detect best manager
dots clipboard --backend=copyq   # Force copyq GUI
dots clipboard --backend=cliphist # Force cliphist (Wayland only)
```

#### `power-menu` – Power Management Menu

**Purpose**: System power options (lock, sleep, logout, reboot, shutdown)  
**Primary Tool**: nwg-bar (modern Wayland power menu)  
**Fallback Chain**: `nwg-bar` → `eww` → `rofi`  
**Usage Examples**:

```bash
dots power-menu                  # Auto-detect best menu
dots power-menu --mode=nwg-bar   # Force nwg-bar
dots power-menu --mode=rofi      # Force rofi menu
```

**Note**: wlogout is installed but disabled (styling issues)

#### `settings-gui` – Settings Hub

**Purpose**: Central GUI for system settings  
**Categories**:

- **GTK Themes**: `nwg-look` → `lxappearance` → rofi menu
- **Display**: `nwg-displays` (Wayland) / `arandr` (X11) → manual config
- **Network**: `nm-connection-editor` → `nmtui`
- **Audio**: `pavucontrol` → `alsamixer`
- **Keyboard**: LXQt keyboard configuration GUI
- **Default Applications**: Configure default apps via `handlr`
- **Power**: `hypridle` config editor
- **System Info**: `fastfetch` → `neofetch`

**Usage Examples**:

```bash
dots settings-gui                # Show all options
# Opens rofi menu to select: Themes, Display, Network, Audio, etc.
```

#### `default-apps` – Default Applications Manager

**Purpose**: Configure XDG default applications  
**Primary Tool**: handlr (modern XDG MIME handler)  
**System Integration**: Works with `exo-open`, `handlr`, and `xdg-open`  
**Categories**: file-manager, terminal, web-browser, text-editor, image-viewer, video-player, audio-player, pdf-viewer

**Usage Examples**:

```bash
dots default-apps --gui                    # Show GUI selector
dots default-apps --list                   # List current defaults
dots default-apps --type=file-manager      # Configure file manager
dots default-apps --set x-scheme-handler/http firefox.desktop  # Set browser
dots default-apps --info                   # Show configuration info
```

**How it works**:

- Uses `handlr` to manage XDG MIME associations
- `exo-open` respects these settings (e.g., `exo-open --launch FileManager`)
- GUI provides category-based selection (no need to know MIME types)
- Configuration stored in `~/.config/handlr/handlr.toml`

**Alternative tools**:

- Command-line: `handlr set <MIME_TYPE> <APP.desktop>`
- exo-open: For terminal emulator configuration

#### `performance-mode` – CPU Performance Profiles

**Purpose**: Switch between performance/balanced/power-saver modes  
**Primary Tool**: powerprofilesctl (systemd power profiles)  
**GUI Option**: auto-cpufreq-gtk (optional graphical monitor)  
**Fallback Chain**: `auto-cpufreq-gtk` (with --gui) → `powerprofilesctl` menu (fuzzel/wofi/rofi)  
**Usage Examples**:

```bash
dots performance-mode            # Show profile menu
dots performance-mode --gui      # Open auto-cpufreq GUI
dots performance-mode --backend=rofi  # Force rofi menu
```

#### `screenshooter` – Screenshot Tool

**Purpose**: Capture screenshots (fullscreen or region)  
**Primary Tool**: flameshot (cross-platform with editor)  
**Fallback Chain**: `grimblast` (Hyprland) → `grim`+`slurp` (Wayland) → `flameshot` (fallback)  
**Usage Examples**:

```bash
dots screenshooter --fullscreen  # Capture entire screen
dots screenshooter --region      # Select region to capture
```

#### `lockscreen` – Screen Lock

**Purpose**: Lock screen with blur/dim effects  
**Primary Tool**: hyprlock (Wayland)  
**Primary**: hyprlock (Wayland/Hyprland)  
**Effects**: dim, blur, dimblur, pixel  
**Usage Examples**:

```bash
dots lockscreen --lock           # Lock with default effect
dots lockscreen --lock-effect=blur  # Lock with blur
dots lockscreen --update=/path/to/wallpaper  # Update lockscreen image
dots lockscreen --wall           # Set wallpaper (uses hyprpaper)
```

#### `theme-selector` – GTK Theme Selector

**Purpose**: Choose GTK themes visually  
**Primary Tool**: nwg-look (modern GTK theme switcher)  
**Fallback**: rofi menu with installed themes  
**Usage Examples**:

```bash
dots theme-selector              # Open theme GUI or menu
```

### 🎨 Theming & Customization

#### `smart-colors` – Intelligent Color Analysis

**Purpose**: Theme-adaptive color palette analysis and semantic color generation  
**Features**:

- Automatic light/dark theme detection
- Smart foreground optimization for readability
- Semantic color mapping (error, success, warning, info, accent)
- Multi-format export (shell, EWW, mako, waybar, hyprland)
**Usage Examples**:

```bash
dots smart-colors                # Analyze current palette
dots smart-colors --analyze      # Detailed analysis
dots smart-colors --concept=error  # Get error color
dots smart-colors --export --format=eww  # Export EWW SCSS
```

#### `gtk-theme` – GTK Theme Manager

**Purpose**: Intelligent GTK theme management integrated with rice system  
**Features**:

- Rice-aware theme application
- Auto-detect light/dark themes from wallpaper
- List and apply themes interactively
**Usage Examples**:

```bash
dots gtk-theme list              # Show installed themes
dots gtk-theme current           # Show active theme
dots gtk-theme apply Orchis-Dark # Apply specific theme
dots gtk-theme auto              # Auto-detect optimal theme
dots gtk-theme rice space        # Apply rice-specific theme
```

#### `rice` – Rice Theme Manager

**Purpose**: Switch between complete desktop themes (wallpaper, colors, configs)  
**Features**:

- Modular rice system in `~/.local/share/dots/rices/`
- Each rice includes: wallpaper, color palette, module configs
- Integrated with smart-colors for automatic color generation
**Usage Examples**:

```bash
dots rice list                   # Show all available rices
dots rice set gruvbox-dark       # Apply gruvbox-dark rice
dots rice info space             # Show rice details
```

#### `wal-reload` – Theme Refresh

**Purpose**: Complete theme refresh after wallpaper changes  
**Automatic Process**:

1. Generate pywal colors from wallpaper
2. Analyze palette with smart-colors algorithm
3. Apply optimized colors to all applications:
   - EWW: Enhanced `colors.scss` with semantic variables
   - Waybar: Smart CSS variables + auto-restart
   - Hyprland: Generated color configuration
   - Waybar: `colors-waybar.css`
   - Mako: `colors-mako.conf`
   - Hyprland: `colors-hyprland.conf`
   - Scripts: Weather, player, jgmenu

**Usage**: Usually called automatically by wpg/wallpaper changes

```bash
dots wal-reload                  # Manual theme refresh
```

### 🖥️ System Utilities

#### `brightness` – Screen Brightness Control

**Purpose**: Adjust display brightness  
**Fallback Chain**: `brightnessctl` → `blight` → `xbacklight` → `xrandr`  
**Usage Examples**:

```bash
dots brightness                  # Show current brightness
dots brightness --list           # List displays
dots brightness --temp           # Show color temperature
dots brightness eDP-1 + 10       # Increase by 10%
dots brightness HDMI-1 set 50    # Set to 50%
```

#### `keyboard-layout` – Keyboard Layout Switcher

**Purpose**: Switch keyboard layouts with visual menu  
**Supported Layouts**: 13 layouts (us, es, fr, de, ru, ar, etc.)  
**Session Aware**: Hyprland (hyprctl) / X11 (setxkbmap)  
**Usage Examples**:

```bash
dots keyboard-layout --menu      # Show layout menu
dots keyboard-layout --current   # Show current layout
dots keyboard-layout --apply=es  # Switch to Spanish
dots keyboard-layout --list      # List all layouts
```

#### `battery-monitor` – Battery Alert Daemon

**Purpose**: Monitor battery and send low/critical alerts  
**Primary Tool**: poweralertd (if available)  
**Fallback**: Built-in acpi/upower monitoring  
**Usage Examples**:

```bash
dots battery-monitor --daemon    # Run as background daemon
dots battery-monitor --low=20 --crit=10  # Custom thresholds
dots battery-monitor --interval=60  # Check every 60s
```

#### `file-manager` – File Manager Launcher

**Purpose**: Wrapper for XDG default file manager  
**Primary Tool**: exo-open (respects XDG MIME associations)  
**Fallback Chain**: `exo-open` → `handlr` → `xdg-open`  
**Usage Examples**:

```bash
dots file-manager                # Open default file manager
dots file-manager --info         # Show current default
dots file-manager --select       # Configure default apps
dots file-manager --path=/home   # Open specific path
```

**Note**: Configure the actual file manager with `dots default-apps --type=file-manager`

#### `night-mode` – Blue Light Filter

**Purpose**: Reduce blue light for night viewing  
**Fallback Chain**: `redshift` → `gammastep` (Wayland) → `wlsunset` (Wayland) → `xrandr` (X11)  
**Usage Examples**:

```bash
dots night-mode toggle           # Toggle night mode on/off
dots night-mode status           # Check current status
```

### 🔧 System Management

- `check-network` – Verify internet connectivity
- `checkupdates` – Query available package updates  
- `config-manager` – Manage configuration snapshots and backups
- `dependencies` – Check and install required system dependencies
- `security-audit` – Comprehensive security audits with auto-fixes
- `sysupdate` – Perform full system updates (pacman/yay/flatpak)
- `toggle` – Toggle applications (waybar, notifications, widgets)
- `updates` – Check updates with notifications

### 🎵 Media & Extras

- `microphone` – Monitor and toggle mic mute with visual indicators
- `popup-calendar` – Display calendar in popup window
- `weather-info` – Current weather and forecasts
- `git-notify` – Notifications on git commits

### 🔗 Convenience Wrappers

- `rofi-run` – Convenience wrapper (delegates to `dots-launcher`)
- `rofi-bluetooth` – Bluetooth management via Rofi (use `dots settings-gui` for GUI)
- `rofi-randr` – Display config via Rofi (use `dots settings-gui` for GUI)
- `rofi-rice-selector` – Rice selector (use `dots rice` for full features)
- `rofi-xrandr` – Advanced display config (use `nwg-displays` or `arandr`)

---

## 🎨 Smart Colors System

### `dots-smart-colors`

**Purpose**: Intelligent color palette analysis and theme-adaptive color selection.

**Usage Examples:**

```bash
# Quick palette analysis
dots-smart-colors

# Detailed analysis with recommendations
dots-smart-colors --analyze

# Get specific semantic color
dots-smart-colors --concept=error
dots-smart-colors --concept=success --format=waybar

# Export for different applications
dots-smart-colors --export                    # Shell variables
dots-smart-colors --export --format=eww       # EWW SCSS
```

#### Export Colors for WM Integration

```bash
dots-smart-colors --export --format=hyprland  # Hyprland configuration
```

**Key Features:**

- **🆕 Light/Dark Theme Detection**: Automatically detects theme brightness and optimizes colors accordingly
- **🆕 Smart Foreground Optimization**: Light themes get softer foreground colors for better readability
- **Theme-adaptive**: Colors automatically adjust to any palette
- **Semantic mapping**: Intelligent error/success/warning color selection
- **Multiple formats**: Shell, Waybar, EWW, Hyprland export support
- **Fallback system**: Always provides valid colors
- **Simple variables**: Clean COLOR*ERROR, COLOR_SUCCESS format (no SMART* prefix)

### Enhanced `dots-wal-reload`

**Purpose**: Complete theme refresh with smart color integration.

**Automatic Integration:**
When you change wallpapers via `wpg`, the system now:

1. **Generates pywal colors** from wallpaper
2. **Analyzes palette** with smart colors algorithm
3. **Applies optimized colors** to all applications:
   - **EWW**: Enhanced `colors.scss` with semantic variables
   - **Waybar**: Smart CSS variables + auto-restart
   - **Hyprland**: Generated color configuration file
   - **Scripts**: Weather, player, jgmenu with smart colors

**No manual configuration needed** - everything happens automatically!

### Enhanced `dots-gtk-theme`

**Purpose**: Intelligent GTK theme management integrated with the rice system.

**Core Features:**

- **🎨 Rice Integration**: Automatically applies GTK themes based on rice configuration
- **🤖 Smart Detection**: Analyzes wallpaper brightness to suggest optimal themes
- **🔄 Auto-Application**: Integrated with `dots-wal-reload` for seamless theme switching
- **📋 Theme Management**: List, apply, and analyze installed GTK themes

**Usage Examples:**

```bash
# List all installed GTK themes
dots gtk-theme list

# Show current theme
dots gtk-theme current

# Apply specific theme
dots gtk-theme apply Orchis-Dark-Compact

# Auto-detect optimal theme for current wallpaper
dots gtk-theme auto

# Apply GTK theme for specific rice
dots gtk-theme rice space

# Analyze wallpaper and suggest theme
dots gtk-theme detect ~/Pictures/wallpaper.jpg
```

**Automatic Integration:**
When you switch rice themes or change wallpapers:

1. **Rice Configuration**: Each rice can specify preferred GTK theme
2. **Smart Analysis**: System analyzes wallpaper brightness and colors
3. **Theme Selection**: Automatically chooses light/dark theme variants
4. **Live Application**: GTK theme updates immediately for all applications

**Rice Configuration Support:**

```bash
# In rice config.sh files:
GTK_THEME="Orchis-Dark-Compact"    # Specific theme
ICON_THEME="Numix-Circle"          # Icon theme
PREFER_DARK_THEME="true"           # Dark preference

# Or use auto-detection:
GTK_THEME="auto"                   # Auto-detect based on wallpaper
PREFER_DARK_THEME="auto"           # Auto-detect light/dark preference
```

---

## 🧠 Customizing Scripts

All scripts can be found in your dotfiles repo (usually under `~/.local/bin/`). To customize:

```sh
chezmoi edit ~/.local/bin/<script-name>
chezmoi apply
```

You can also add your own scripts and link them via the `dots` interface for quick access.

---

## 🆘 Need Help?

- Explore the script source code: `chezmoi edit ~/.local/bin/dots`
- Join the [Dotfiles Discussions](https://github.com/ulises-jeremias/dotfiles/discussions)

Use the `dots` utility to take your workflow to the next level. Automate, simplify, and enjoy the full power of your environment! ⚡
