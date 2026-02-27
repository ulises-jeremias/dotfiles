# 🐚 Quickshell: Desktop Shell

Quickshell is the unified desktop shell for HorneroConfig, built with QML/QtQuick. It provides a cohesive, themeable, and extensible desktop experience.

> [!TIP]
> Quickshell integrates with Material Design 3 theming, automatically adapting all UI elements to your wallpaper's color palette.

---

## 📋 Overview

Quickshell provides all desktop shell functionality through modular QML components:

| Module | Description |
| ------ | ----------- |
| **Left Rail Bar** | Vertical/horizontal rail with workspaces, clock, status icons, power |
| **Launcher** | App search, calculator, wallpaper browser, appearance selector |
| **Dashboard** | Tabbed system overview, media, performance, weather |
| **Notifications** | Popup notifications and notification center sidebar |
| **Session Rail** | Right-edge quick actions menu (logout, power, session controls) |
| **Lock** | PAM-authenticated lock screen |
| **OSD Notch** | Right-edge sliders for volume/brightness feedback |
| **AI Chat** | Multi-provider AI assistant sidebar |
| **Background** | Desktop wallpaper with optional audio visualizer |
| **AreaPicker** | Screenshot region selector |
| **Utilities** | Quick toggles panel (WiFi, Bluetooth, DND, etc.) |

---

## 🚀 Management

Use the `dots-quickshell` script to manage the shell:

```bash
dots quickshell start               # Start Quickshell
dots quickshell stop                # Stop Quickshell
dots quickshell restart             # Restart Quickshell
dots quickshell status              # Check if running
dots quickshell preset list         # List shell presets
dots quickshell preset apply <name> # Apply shell preset
dots quickshell config get bar.position
```

### IPC Commands

```bash
dots-quickshell ipc colours reload    # Reload color scheme
dots-quickshell ipc bar toggle        # Toggle bar visibility
dots-quickshell ipc dashboard toggle  # Toggle dashboard
dots-quickshell ipc launcher toggle   # Toggle launcher
dots-quickshell ipc session toggle    # Toggle session/power menu
dots-quickshell ipc sidebar toggle    # Toggle notification sidebar
```

Note: drawer toggles are routed through Quickshell's `drawers` IPC target internally by `dots-quickshell`, so the commands above are the stable public interface you should keep using.

---

## 🎨 Theming

Quickshell uses **Material Design 3** (M3) color palettes generated from your wallpaper:

### Color Pipeline

1. Wallpaper change triggers `dots-smart-colors --m3`
2. `generate-m3-colors.py` extracts M3 palette using `python-materialyoucolor`
3. Palette saved to `~/.cache/dots/smart-colors/scheme.json`
4. Quickshell's `Colours` service watches the file and reloads automatically

### Scheme Configuration

Each appearance (rice) can configure its M3 scheme via `config.sh`:

```bash
SCHEME_TYPE="vibrant"     # tonalSpot, vibrant, expressive, neutral, monochrome, fidelity
DARK_MODE="true"          # true/false
ACCENT_COLOR=""           # Optional hex color override
BAR_POSITION="top"        # top/bottom
```

### Appearance Commands

```bash
dots appearance list
dots appearance current
dots appearance apply machines
dots appearance set-variant tonalspot
dots appearance set-mode light
```

---

## 🏗️ Architecture

### Unified Drawers Model

The active shell now follows a unified drawers architecture inspired by `reference/shell`:

- A dedicated drawers layer (`modules/drawers/Drawers.qml`) owns interaction orchestration.
- Edge exclusion windows (`modules/drawers/Exclusions.qml`) reserve space in Hyprland.
- A global rounded desktop frame (`modules/drawers/BorderFrame.qml`) provides shell chrome.
- Bar behavior is split into content and wrapper:
  - `modules/bar/BarContent.qml`
  - `modules/bar/BarWrapper.qml`
- Drawers interaction surface (`modules/drawers/Interactions.qml`) handles hover/wheel behavior.

### Services Layer

QML singletons providing system integration:

| Service | Purpose |
| ------- | ------- |
| `Colours` | M3 theming, transparency, wallpaper luminance |
| `Hypr` | Hyprland IPC (workspaces, monitors, keyboard) |
| `Audio` | PipeWire audio, Cava visualization, beat detection |
| `Players` | MPRIS media player control |
| `Brightness` | Screen brightness (brightnessctl, ddcutil) |
| `Network` | WiFi/Ethernet management (nmcli) |
| `SystemUsage` | CPU, GPU, memory, disk monitoring |
| `Weather` | Open-Meteo weather data |
| `Wallpapers` | Wallpaper browsing and selection |
| `Notifs` | Notification server (replaces Mako) |
| `Time` | System clock and date |
| `Visibilities` | Panel visibility state management |
| `Ai` | Multi-provider AI with function calling |

### C++ Plugin (Hornero)

Performance-critical components built with CMake:

- **ImageAnalyser** — Wallpaper luminance for dynamic transparency
- **Qalculator** — Mathematical expression evaluation (libqalculate)
- **AppDb** — Application frequency tracking (SQLite)
- **Toaster** — Toast notification management
- **Requests** — HTTP client for QML
- **AudioCollector** — PipeWire audio capture
- **BeatTracker** — Beat detection (aubio)
- **CavaProvider** — Audio visualization (cava)
- **FileSystemModel** — Filesystem browsing for QML
- **CachingImageManager** — Image caching from QML items

### Configuration

Shell behavior is configured via `~/.config/hornero/shell.json`:

```json
{
  "border": { "thickness": 2, "rounding": 24 },
  "bar": {
    "position": "left",
    "showOnHover": false,
    "sizes": { "innerWidth": 48 }
  },
  "appearance": {
    "animations": {
      "duration": 200,
      "durations": { "small": 160, "normal": 220, "large": 320 }
    }
  }
}
```

### Reference Parity Status

- **Matched**: wallpaper-driven M3 theming pipeline, left-rail shell feel, top control center, launcher command modes, right-edge OSD/session controls, rounded frame and edge exclusions.
- **Intentional deviations**: Hornero-specific `dots-*` integrations, rice selector mode in launcher, AI chat module.
- **In progress hardening**: deeper panel unification and additional popout parity refinements.

---

## ⌨️ Keybindings

| Keybinding | Action |
| ---------- | ------ |
| `Super+D` | Toggle launcher |
| `Super+X` | Toggle session/power menu |
| `Super+Ctrl+B` | Toggle bar |
| `Super+?` or `Super+/` | Keyboard shortcuts help |

---

## 📂 File Structure

```txt
~/.config/quickshell/
├── shell.qml              # Main entry point
├── config/
│   └── Config.qml         # Configuration singleton
├── services/              # System integration singletons
│   ├── Colours.qml        # M3 theming
│   ├── Hypr.qml           # Hyprland IPC
│   ├── Audio.qml          # Audio management
│   └── ...
├── modules/               # UI components
│   ├── bar/               # Status bar
│   ├── launcher/          # App launcher
│   ├── dashboard/         # System dashboard
│   ├── notifications/     # Notification system
│   ├── session/           # Power menu
│   ├── lock/              # Lock screen
│   ├── osd/               # On-screen display
│   ├── aichat/            # AI assistant
│   ├── sidebar/           # Notification sidebar
│   ├── background/        # Desktop background
│   ├── areapicker/        # Screenshot selector
│   └── utilities/         # Quick toggles
├── utils/                 # Shared utilities
│   ├── Paths.qml
│   ├── Icons.qml
│   ├── SysInfo.qml
│   └── Strings.qml
└── plugin/                # C++ plugin (built by Chezmoi)
    ├── CMakeLists.txt
    └── src/Hornero/
```

---

## 🔧 Troubleshooting

### Quickshell not starting

```bash
# Check if already running
dots-quickshell status

# Check for errors
quickshell 2>&1 | head -50

# Ensure plugin is built
ls ~/.local/lib/quickshell/qml/Hornero/
```

### Colors not updating

```bash
# Regenerate M3 palette
dots-smart-colors --m3

# Check scheme.json exists
cat ~/.cache/dots/smart-colors/scheme.json | head

# Force reload
dots-quickshell ipc colours reload
```

### Plugin build fails

```bash
# Ensure build deps are installed
yay -S --needed cmake ninja qt6-base qt6-declarative aubio cava pipewire

# Rebuild manually
cd ~/.config/quickshell/plugin
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
cmake --install build --prefix ~/.local/lib/quickshell
```

---

## 📚 Related Documentation

- [Rice System](Rice-System-Theme-Management.md) — Theme switching (legacy naming, now exposed as "Appearances")
- [Smart Colors System](Smart-Colors-System.md) — Color generation pipeline
- [Dots Scripts](Dots-Scripts.md) — CLI tools and management scripts
- [Hyprland Keybindings](Hyprland-Keybindings.md) — Keyboard shortcuts
- [Quickshell Parity Checklist](Quickshell-Parity-Checklist.md) — End-to-end validation steps
