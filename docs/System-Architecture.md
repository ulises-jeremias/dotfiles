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

- Polybar (profile selection via `POLYBAR_PROFILE`)
- EWW widgets (config paths)
- Window managers (i3, Openbox, XFCE4)
- Wallpaper system (wpg/pywal)
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
- Export formats: Hyprland, EWW (SCSS), Waybar (CSS), shell, environment variables
- Integration: Automatic reload on wallpaper change

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

## 3. Waybar Integration

**Purpose**: Modular status bar system with profile-based configuration.

**Architecture:**

- Profile system: Different bar layouts for different rices
- Module system: 20+ independent, reusable components
- Launch script: Window manager aware, multi-monitor capable
- Configuration hierarchy: Profiles → Bars → Modules → Colors

**Available Profiles:**

- `default`: Standard dual-bar layout (top + bottom)
- `vertical-left`: Vertical bar on left side
- `floating-neon`: Floating centered bar with neon glow effects (cyberpunk)
- `cozy-minimal`: Minimal floating bar with rounded corners (cozy)
- `dock-bottom`: macOS-style dock at bottom (clean)
- `retro-wave`: Synthwave-inspired with gradient effects (vaporwave)

**Module Categories:**

- System monitoring (CPU, memory, temperature, battery)
- User interaction (volume, brightness, microphone)
- Information display (date, weather, music player)
- Navigation (workspaces, windows, jgmenu)
- Communication (network, Bluetooth, GitHub notifications)

**Design Constraints:**

- Modules must be independently toggleable
- Scripts must handle missing dependencies
- Update intervals must be configurable
- Colors must use smart colors or xrdb references

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

## 4. EWW Widget System

**Purpose**: Modern, declarative system widgets with custom styling.

**Architecture:**

- Widget types: Dashboard, powermenu, sidebar, music player
- Launch scripts: Daemon management, state tracking, lock files
- Styling: SCSS with smart colors integration
- State management: Environment variables, scripts, IPC

**Component Structure:**

```
~/.config/eww/<widget-name>/
├── eww.yuck           # Widget definitions
├── eww.scss           # Styles with smart colors
├── launch.sh          # Enhanced launcher
└── scripts/           # Helper scripts
```

**Design Principles:**

- Single daemon for all widgets
- Atomic widget opening/closing
- Lock files prevent conflicts
- Automatic cleanup on exit

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
- User interaction (Rofi menus, notifications)
- Development (testing, validation, debugging)

**Mandatory Standards:**

- EasyOptions for all CLI parsing
- Strict mode: `set -euo pipefail`
- Error handling with exit codes
- Logging to `~/.cache/dots/`
- Help text in script header
