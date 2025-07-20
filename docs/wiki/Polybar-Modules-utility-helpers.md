# 🛠️ Polybar Modules: Utility & Helper Modules

Essential utility modules that provide structure, visual separation, and system integration for your polybar configuration.

> [!TIP]
> These modules handle the foundational elements that make polybar functional and visually organized - from spacing and separators to system integration and keyboard layouts.

---

## 🎯 System Tray Module (`tray`)

### Overview

The system tray module provides a native system tray for application icons and notifications.

### Configuration

```ini
[module/tray]
type = internal/tray

tray-size = 15
tray-spacing = 18px
```

### Features

- **Application icons**: Shows running applications in the system tray
- **Notification area**: Displays system notifications and indicators
- **Configurable size**: Adjustable icon size and spacing
- **Native integration**: Works with all tray-compatible applications

### Visual Display

```text
🔊 📶 🔋 📧 ⚡
```

### Applications That Use Tray

- **Audio**: PulseAudio, PipeWire volume controls
- **Network**: NetworkManager, VPN clients
- **Communication**: Discord, Slack, email clients
- **System**: Battery indicators, Bluetooth managers
- **Custom apps**: Any application with tray support

---

## 📐 Visual Separator Modules

### Spacer Module (`sep`)

Provides visual spacing between modules for better organization.

```ini
[module/sep]
type = custom/text
label = "   "
label-foreground = ${colors.background}
```

**Usage**:
```text
[cpu] SEP [memory] SEP [date]
```

### Decorative Dots Module (`dots`)

Adds decorative elements for visual enhancement.

```ini
[module/dots]
type = custom/text
label = "  󰇙  "
label-foreground = ${colors.foreground-alt}
label-font = 6
```

**Usage**:
```text
[apps] DOTS [system] DOTS [tray]
```

### Visual Brackets

**Left Bracket (`lb`)**:
```ini
[module/lb]
type = custom/text
label = 󱎕
label-foreground = ${colors.foreground}
label-background = ${colors.background}
label-font = 5
```

**Right Bracket (`rb`)**:
```ini
[module/rb]
type = custom/text
label = 
label-foreground = ${colors.foreground}
label-background = ${colors.background}
label-font = 5
```

**Combined Usage**:
```text
󱎕 [content]  for grouped modules
```

---

## ⌨️ Keyboard Layout Module (`keyboard` / `xkeyboard`)

### Standard Keyboard Module

```ini
[module/keyboard]
type = internal/xkeyboard
blacklist-0 = num lock
blacklist-1 = scroll lock

format = <label-layout> <label-indicator>
format-prefix = "%{T5}󰌌%{T-} "
format-prefix-foreground = ${xrdb:color7}

label-layout = %{A3:xfce4-keyboard-settings & disown:} %name%%{A}
label-indicator-on = %name%
```

### Enhanced Keyboard Module (`xkeyboard`)

Simplified version with essential keyboard layout information:

```ini
[module/xkeyboard]
type = internal/xkeyboard
```

### Features

- **Layout display**: Shows current keyboard layout (US, ES, FR, etc.)
- **Indicator status**: Shows caps lock, num lock status
- **Click actions**: Right-click opens keyboard settings
- **Multi-layout support**: Easy switching between layouts
- **Visual indicators**: Icons and status indicators

### Visual Display

```text
󰌌 US    # US layout active
󰌌 ES    # Spanish layout active
󰌌 FR 🅰  # French layout with caps lock
```

### Click Actions

- **Right-click**: Opens keyboard settings (`xfce4-keyboard-settings`)
- **Scroll**: Switch between keyboard layouts (if configured)

---

## 🏠 Workspace Management Modules

### Standard Workspaces (`workspaces`)

```ini
[module/workspaces]
type = internal/workspaces
enable-click = true
enable-scroll = true

format = <label-state>
label-active = %name%
label-urgent = %name%
label-occupied = %name%
label-empty = %name%
```

### Enhanced Workspaces with Icons (`workspaces-with-icons`)

```ini
[module/workspaces-with-icons]
type = internal/workspaces
enable-click = true
enable-scroll = true

format = <label-state>
label-active = %{T4}%icon%%{T-} %name%
label-urgent = %{T4}%icon%%{T-} %name%
label-occupied = %{T4}%icon%%{T-} %name%
label-empty = %{T4}%icon%%{T-} %name%

icon-0 = 1;
icon-1 = 2;
icon-2 = 3;
icon-3 = 4;
icon-4 = 5;
```

### Features

- **Click navigation**: Click to switch workspaces
- **Scroll support**: Scroll to navigate between workspaces
- **Visual indicators**: Different styles for active/occupied/empty
- **Icon support**: Custom icons for each workspace
- **Universal compatibility**: Works with any EWMH window manager

### Visual Display

```text
 Terminal  Browser  Code  Chat
```

---

## 🪟 Window Management Module (`window_switch`)

### Overview

Provides window switching and management capabilities.

```ini
[module/window_switch]
type = custom/script
exec = ~/.config/polybar/configs/default/scripts/window-switcher
click-left = rofi -show window
interval = once
```

### Features

- **Window list**: Shows available windows
- **Quick switching**: Click to open window switcher
- **Rofi integration**: Uses rofi for window selection
- **Real-time updates**: Updates when windows change

### Window Title Module (`xwindow`)

Shows the title of the currently focused window:

```ini
[module/xwindow]
type = internal/xwindow
label = %title:0:50:...%
```

**Features**:
- **Current window title**: Shows active window name
- **Text truncation**: Limits title length with ellipsis
- **Dynamic updates**: Updates when focus changes

---

## 🎨 Usage Patterns

### Visual Organization

**Sectioned Layout**:
```ini
modules-left = jgmenu dots apps
modules-center = sep workspaces sep date sep
modules-right = system dots tray
```

**Grouped Elements**:
```ini
modules-left = lb cpu memory rb sep lb network battery rb
modules-right = lb keyboard date rb
```

**Clean Separation**:
```ini
modules-left = workspaces
modules-center = sep player sep playing sep
modules-right = system sep date
```

### Window Manager Integration

**i3 Setup**:
```ini
modules-left = i3-with-icons
modules-center = xwindow
modules-right = xkeyboard dots tray
```

**Universal Setup**:
```ini
modules-left = workspaces-with-icons
modules-center = window_switch
modules-right = keyboard dots tray
```

**XFCE4 Integration**:
```ini
modules-left = workspaces
modules-center = xwindow
modules-right = xkeyboard dots tray
```

---

## 🔧 Configuration Tips

### Tray Configuration

**Adjust tray size**:
```ini
tray-size = 20          # Larger icons
tray-spacing = 10px     # Tighter spacing
```

**Tray positioning**:
```ini
tray-position = right   # Place tray on right side
tray-detached = false   # Attach to bar
```

### Separator Customization

**Custom separators**:
```ini
[module/my-sep]
type = custom/text
label = " | "           # Pipe separator
label-foreground = ${colors.primary}
```

**Gradient separators**:
```ini
[module/gradient-sep]
type = custom/text
label = " ▌ "
label-foreground = ${colors.gradient-1}
```

### Keyboard Layout Tips

**Multiple layouts**:
```bash
# Set keyboard layouts
setxkbmap -layout "us,es,fr" -option "grp:alt_shift_toggle"
```

**Custom layout names**:
```ini
label-layout = %{A3:xfce4-keyboard-settings:}%layout%%{A}
```

---

## 🛠️ Troubleshooting

### System Tray Issues

**Tray not showing**:
```bash
# Check if tray is enabled
xprop -root | grep _NET_SYSTEM_TRAY

# Kill existing tray
pkill -f polybar && polybar yourbar &
```

**Applications not appearing**:
- Restart the application
- Check application tray settings
- Verify polybar tray configuration

### Keyboard Layout Problems

**Layout not updating**:
```bash
# Test layout switching
setxkbmap us
setxkbmap es

# Check current layout
setxkbmap -query
```

**Indicator not working**:
```bash
# Check keyboard mapping
xkb-switch -l
xkb-switch -s us
```

### Workspace Issues

**Workspaces not showing**:
- Verify window manager EWMH support
- Check workspace definitions
- Test with: `wmctrl -d`

---

## ✅ Integration

### Works With

- ✅ **All window managers** (i3, Openbox, XFCE4, etc.)
- ✅ **System tray applications** of all types
- ✅ **Multiple keyboard layouts** and input methods
- ✅ **All bar configurations** in the dotfiles

### Pairs Well With

- **All polybar modules** for complete functionality
- **Window manager configurations** for workspace integration
- **Rofi/dmenu** for enhanced window switching
- **System applications** requiring tray access

---

Keep your desktop organized and functional with these essential utility modules! 🛠️

> [!TIP]
> Use separators and spacing modules to create visual hierarchy in your bar. The system tray is essential for accessing system controls, and keyboard layout display helps with multilingual workflows.
