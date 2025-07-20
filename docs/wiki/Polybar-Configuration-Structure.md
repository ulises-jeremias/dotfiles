# ⚙️ Polybar: Configuration Structure

This page explains how the polybar configuration is organized in this dotfiles setup, making it easy to understand, customize, and extend.

> [!TIP]
> The modular configuration structure allows you to easily enable/disable modules and create custom bar layouts without affecting other components.

---

## 📁 Configuration Architecture

The polybar configuration uses a **modular architecture** split across multiple files:

```text
~/.config/polybar/
├── config.ini              # Main entry point (symlinks to master.conf)
├── master.conf              # Core configuration and color scheme
├── modules.conf             # Module includes registry
├── launch.sh                # Polybar startup script
├── bars/                    # Bar layout configurations
│   ├── common-top.conf      # Universal top bar layout
│   ├── common-bottom.conf   # Universal bottom bar layout
│   ├── i3-top.conf          # i3-specific top bar
│   ├── i3-bottom.conf       # i3-specific bottom bar
│   └── i3-top-multipart.conf # i3 multipart bar layout
├── modules/                 # Individual module configurations
│   ├── audio.conf           # Audio/sound modules
│   ├── bluetooth.conf       # Bluetooth connectivity
│   ├── datetime.conf        # Date and time display
│   ├── resources.conf       # CPU, memory, battery
│   ├── net.conf            # Network modules
│   ├── weather.conf        # Weather information
│   └── ...                 # Additional modules
└── scripts/                # Custom executable scripts
    ├── weather-info         # Weather data fetching
    ├── player              # Media player control
    └── spotify             # Spotify integration
```

---

## 🎨 Color System

### Base16 Color Scheme

Colors are sourced from Xresources using the **base16 color scheme**:

| Color | Purpose |
|-------|---------|
| `color0` | Default Background |
| `color1` | Lighter Background (status bars) |
| `color2` | Selection Background |
| `color3` | Comments, Line Highlighting |
| `color4` | Dark Foreground |
| `color5` | Default Foreground, Operators |
| `color8` | Variables, XML Tags |
| `color9` | Integers, Constants |
| `color10` | Classes, Search Background |
| `color11` | Strings, Code |
| `color12` | Regular Expressions |
| `color13` | Functions, Methods |
| `color14` | Keywords, Storage |
| `color15` | Deprecated elements |

### Available Color Variables

```ini
[colors]
background = ${xrdb:background}
foreground = ${xrdb:foreground}
primary = ${xrdb:color1}
secondary = ${xrdb:color2}
alert = ${xrdb:color3}
moderate = ${xrdb:color11}
urgent = ${xrdb:color9}
blue = #8fa1b3
```

---

## 🏗️ Configuration Hierarchy

### 1. Master Configuration (`master.conf`)

Contains:

- Global color definitions
- Font configurations
- Common settings shared across all bars

### 2. Module Registry (`modules.conf`)

Includes all available module files:

```ini
include-file = ~/.config/polybar/modules/audio.conf
include-file = ~/.config/polybar/modules/bluetooth.conf
include-file = ~/.config/polybar/modules/datetime.conf
# ... additional modules
```

### 3. Bar Configurations (`bars/`)

Define specific bar layouts and module arrangements:

- **common-top.conf**: Universal top bar for any window manager
- **common-bottom.conf**: Universal bottom bar companion
- **i3-*.conf**: i3 window manager specific configurations

### 4. Module Definitions (`modules/`)

Individual module configurations grouped by functionality:

- **resources.conf**: CPU, memory, battery, filesystem
- **audio.conf**: PipeWire, microphone, volume controls
- **net.conf**: Network connectivity and status
- **datetime.conf**: Date, time, calendar modules

---

## 🔧 Adding New Modules

### Step 1: Create Module Configuration

Create a new file in `~/.config/polybar/modules/`:

```ini
# ~/.config/polybar/modules/my-module.conf
[module/my-custom-module]
type = custom/script
exec = echo "Hello World"
interval = 30
```

### Step 2: Register Module

Add to `modules.conf`:

```ini
include-file = ~/.config/polybar/modules/my-module.conf
```

### Step 3: Add to Bar

Include in desired bar configuration:

```ini
# In bar configuration file
modules-right = existing-modules my-custom-module
```

---

## 🎯 Environment Variables

### Window Manager Detection

The configuration automatically adapts based on environment:

```bash
# Set in window manager startup
export POLYBAR_WM="i3"          # or "openbox"
export MONITOR="HDMI-1"         # Primary monitor
```

### Module-Specific Variables

```bash
# Battery configuration
export POLYBAR_MODULES_LAPTOP_BATTERY="BAT0"
export POLYBAR_MODULES_LAPTOP_ADAPTER="ADP1"

# Network interface
export POLYBAR_MODULES_ETH_INTERFACE="enp0s25"
export POLYBAR_MODULES_WLAN_INTERFACE="wlp3s0"
```

---

## 🚀 Bar Layouts

### Common Layouts

**Top Bar (common-top.conf)**:

```text
[menu] [workspaces] ··· [title] ··· [system] [network] [audio] [date]
```

**Bottom Bar (common-bottom.conf)**:

```text
[cpu] [memory] [filesystem] ··· [weather] ··· [battery] [tray]
```

### i3-Specific Layouts

**i3 Top Bar**:

```text
[i3] [mode] ··· [title] ··· [github] [spotify] [system] [date]
```

**i3 Multipart Bar**:

- Three separate bars with different module groups
- Left: Workspaces and system info
- Center: Window title and media
- Right: Status and controls

---

## 📱 Responsive Design

### Monitor Adaptation

Bars automatically adapt to:

- **Primary monitor** detection via `$MONITOR`
- **Multi-monitor** setups with per-monitor bars
- **Resolution changes** with percentage-based sizing

### Window Manager Integration

- **i3**: Workspace integration, mode display
- **Openbox**: Menu integration, window management
- **Universal**: Works with any EWMH-compliant WM

---

## 🛠️ Customization Patterns

### Module Inheritance

```ini
[module/cpu-basic]
type = internal/cpu
interval = 2

[module/cpu-detailed]
inherit = module/cpu-basic
format = %{T4}💻%{T-} <label> <bar-load>
```

### Conditional Loading

```ini
[module/battery]
; Only load on laptops
type = internal/battery
battery = ${env:POLYBAR_MODULES_LAPTOP_BATTERY:}
```

### Theme Integration

```ini
[module/themed-module]
background = ${colors.background}
foreground = ${colors.foreground}
underline = ${colors.primary}
```

---

## ✅ Best Practices

### Organization

- **Group related modules** in the same configuration file
- **Use descriptive names** for custom modules
- **Comment module purposes** and dependencies

### Performance

- **Set appropriate intervals** for script-based modules
- **Cache expensive operations** in custom scripts
- **Use conditional execution** for resource-intensive modules

### Maintenance

- **Test changes** with single bar restart: `polybar polybar-top`
- **Validate syntax** before full deployment
- **Keep backup** of working configurations

---

Ready to customize your polybar setup! The modular structure makes it easy to add, remove, or modify any component. 🎨

> [!TIP]
> Start by modifying existing module files, then create your own modules once you're comfortable with the structure.
