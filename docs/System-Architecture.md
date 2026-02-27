# System Architecture

## 1. Theme System (Rice)

**Purpose**: Provide complete desktop theme management with one-command switching.

**Architecture:**

- Each rice is self-contained directory: `~/.local/share/dots/rices/<rice-name>/`
- Configuration: `config.sh` (shell variables, no execution)
- Application: `apply.sh` (executable script)
- Assets: `backgrounds/`, `preview.png`
- State tracking: `~/.config/.current_rice`

**Integration Points:**

- Quickshell (M3 color scheme via scheme.json)
- Hyprland (compositor animations and settings)
- Wallpaper system (hyprpaper)
- GTK themes (automatic light/dark selection)

**Design Constraints:**

- Rice configs must be sourceable (no side effects)
- Apply scripts must be idempotent
- Assets must be relative to rice directory
- No cross-rice dependencies allowed

## 2. Smart Colors System

**Purpose**: Intelligent color adaptation ensuring optimal readability across all themes.

**Architecture:**

- Analysis engine: Color science algorithms for semantic mapping
- Cache system: Pre-generated format-specific files in `~/.cache/dots/smart-colors/`
- Export formats: Material Design 3 scheme.json (Quickshell), Hyprland, shell, environment variables
- Integration: Automatic M3 palette regeneration on wallpaper change, watched by Quickshell Colours service

**Key Algorithms:**

1. **Theme Detection**: Luminance-based light/dark identification
2. **Semantic Mapping**: Hue-based concept assignment (red→error, green→success)
3. **Contrast Optimization**: WCAG-aware foreground/background selection
4. **Fallback Selection**: Distance-based color approximation

**Design Principles:**

- Colors generated once, cached for performance
- Multiple export formats from single analysis
- Automatic invalidation on palette change
- No hardcoded color values anywhere

## 3. Quickshell Desktop Shell

**Purpose**: Unified desktop shell for bar, launcher, dashboard, notifications, and controls.

**Architecture:**

- QML/QtQuick-based shell using Quickshell framework
- Unified drawers composition (`Drawers`, `Exclusions`, `BorderFrame`, `Interactions`, `Panels`)
- C++ plugin (Hornero) for performance-critical features: image analysis, audio visualization, calculator
- Services layer (QML singletons) for system integration
- Modules for UI components: left rail bar, launcher, dashboard, notifications, right-notch controls

**Key Modules:**

- **Left Rail Bar**: Status rail with workspaces, clock, status icons and power controls
- **Launcher**: App search, calculator, wallpaper browser, rice selector
- **Dashboard**: Tabbed system overview (media, performance, weather)
- **Notifications**: Popup and sidebar notification center
- **Session Rail**: Right-edge quick actions menu
- **Lock**: PAM-authenticated lock screen
- **OSD Notch**: Right-edge volume/brightness controls
- **AI Chat**: Multi-provider AI assistant
- **Background**: Wallpaper with optional visualizer
- **AreaPicker**: Screenshot region selector
- **Utilities**: Quick toggles panel

**Services:**

- Time, Hypr (Hyprland IPC), Audio (PipeWire), Players (MPRIS)
- Brightness, Network (nmcli), SystemUsage, Weather (Open-Meteo)
- Wallpapers, Notifs (NotificationServer), Colours (M3 theming)
- Visibilities (panel state management), Ai (multi-provider)

**Design Constraints:**

- All services are QML singletons with `pragma Singleton`
- UI delegates to dots-* scripts via Process components
- Theming uses Material Design 3 via wallpaper-driven `scheme.json`
- Edge exclusions must reserve shell space in Hyprland
- C++ plugin built with CMake, installed by Chezmoi script

## 3.1 Hyprland Animations

**Purpose**: Rice-specific animation profiles for window transitions.

**Available Profiles:**

- `animations-default.conf`: Standard smooth animations
- `animations-cyberpunk.conf`: Glitchy, tech-inspired effects
- `animations-cozy.conf`: Soft, gentle transitions
- `animations-vaporwave.conf`: Retro-style with bounce effects
- `animations-minimal.conf`: Quick, subtle animations

**Integration:**

Rices specify their animation profile via `HYPRLAND_ANIMATIONS` in `config.sh`:

```bash
HYPRLAND_ANIMATIONS="cyberpunk"  # Uses animations-cyberpunk.conf
```

## 4. Legacy Removal Note

Waybar, EWW, and Rofi integration was intentionally removed from runtime and install flows. Quickshell is the only desktop-shell UI stack.

## 5. Script Management (dots)

**Purpose**: Unified interface for 100+ utility scripts.

**Architecture:**

- Command wrapper: `dots` dispatcher script
- EasyOptions integration: Standardized argument parsing
- Registry system: Script discovery and documentation
- Namespace: `dots-*` prefix for all user-facing scripts

**Script Categories:**

- System management (updates, backups, monitoring)
- Theme control (rice application, color management)
- Security (auditing, hardening, secret scanning)
- User interaction (Quickshell IPC, notifications, launcher)
- Development (testing, validation, debugging)

**Mandatory Standards:**

- EasyOptions for all CLI parsing
- Strict mode: `set -euo pipefail`
- Error handling with exit codes
- Logging to `~/.cache/dots/`
- Help text in script header
