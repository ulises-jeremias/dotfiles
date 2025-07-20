# 📊 Polybar: Bar Configurations

Polybar configurations provide different layout options for various window managers and use cases, from minimalist single bars to complex multi-part layouts.

> [!TIP]
> Each bar configuration is designed to work seamlessly with different window managers while maintaining visual consistency and functionality across all environments.

---

## 📋 Available Bar Configurations

### Common Bars (Universal)

- **common-top.conf**: Universal top bar for all window managers
- **common-bottom.conf**: Universal bottom bar layout

### i3 Window Manager Bars

- **i3-top.conf**: i3-specific top bar with workspace integration
- **i3-bottom.conf**: i3-specific bottom bar with enhanced controls
- **i3-top-multipart.conf**: Multi-section top bar for i3 environments

---

## 🎯 Common Top Bar (`common-top.conf`)

### Layout Configuration

```ini
[bar/polybar-top]
width = 100%
height = 25
radius = 0

modules-left = jgmenu dots apps sep window_switch sep rices dots pipewire-microphone sep pipewire-bar sep backlight-acpi-bar
modules-center = date-popup weather
modules-right = night-mode sep feh-blur-toggle sep github dots tray
```

### Visual Design

- **Full width**: Spans entire monitor width
- **Minimal height**: 25px for clean appearance
- **No radius**: Sharp edges for modern look
- **Override-redirect**: False for proper window manager integration

### Module Distribution

**Left Section**:
- Application launcher (jgmenu)
- Window switcher
- Rice theme selector
- Audio controls (microphone, volume)
- Brightness controls

**Center Section**:
- Date and time with popup calendar
- Weather information

**Right Section**:
- Night mode toggle
- Background blur toggle
- GitHub notifications
- System tray

---

## 🎯 Common Bottom Bar (`common-bottom.conf`)

### Layout Configuration

```ini
[bar/polybar-bottom]
width = 100%
height = 30
bottom = true
radius = 0

modules-left = workspaces-with-icons
modules-center = player sep playing
modules-right = keyboard dots filesystem sep memory sep cpu sep temperature
```

### Visual Design

- **Bottom placement**: Positioned at bottom of screen
- **Slightly taller**: 30px for better content visibility
- **System monitoring focus**: Resource information and controls

### Module Distribution

**Left Section**:
- Workspace indicators with icons

**Center Section**:
- Media player controls
- Current playing song information

**Right Section**:
- Keyboard layout indicator
- Filesystem usage
- System resources (memory, CPU, temperature)

---

## 🎯 i3 Top Bar (`i3-top.conf`)

### Enhanced i3 Integration

```ini
[bar/i3-polybar-top]
width = 99.15%
height = 27
offset-x = 0.5%
offset-y = 0.7%
radius = 4

modules-left = jgmenu dots apps sep window_switch sep rices dots pipewire-microphone sep pipewire-bar sep backlight-acpi-bar
modules-center = date-popup weather
modules-right = night-mode sep feh-blur-toggle sep github dots tray

wm-restack = i3
override-redirect = true
```

### i3-Specific Features

- **Rounded corners**: 4px radius for modern aesthetics
- **Floating appearance**: Offset positioning with margins
- **i3 window stacking**: Proper integration with i3 window management
- **Override-redirect**: True for floating bar behavior

### Positioning

- **Width**: 99.15% with 0.5% horizontal offset
- **Vertical offset**: 0.7% from top edge
- **Floating style**: Creates space around the bar

---

## 🎯 i3 Bottom Bar (`i3-bottom.conf`)

### System Information Focus

```ini
[bar/i3-polybar-bottom]
width = 100%
height = 30
bottom = true
radius = 0

modules-left = i3-with-icons
modules-center = player sep playing
modules-right = xkeyboard dots filesystem sep memory sep cpu sep temperature

wm-restack = i3
```

### i3 Workspace Integration

**Left Section**:
- **i3-with-icons**: Enhanced workspace display
- Shows current workspace and available workspaces
- Icon-based workspace indicators
- Click to switch workspaces

**Center & Right**: Similar to common bottom bar but optimized for i3

---

## 🎯 i3 Multipart Top Bar (`i3-top-multipart.conf`)

### Advanced Multi-Section Layout

The multipart configuration creates **4 separate bar sections** for maximum flexibility:

#### Section 1: Application Controls
```ini
[bar/i3-polybar-top-1]
width = 24.75%
offset-x = 1%
modules-center = jgmenu dots apps sep window_switch sep rices dots pipewire-microphone sep pipewire-bar sep backlight-acpi-bar
```

#### Section 2: Date and Weather
```ini
[bar/i3-polybar-top-2]
width = 12%
offset-x = 44%
modules-center = date-popup weather
```

#### Section 3: System Status
```ini
[bar/i3-polybar-top-3]
width = 16.75%
offset-x = 82.25%
modules-center = night-mode sep feh-blur-toggle sep github dots tray
```

### Multipart Benefits

- **Modular design**: Each section can be independently positioned
- **Flexible spacing**: Gaps between sections for visual separation
- **Responsive layout**: Sections adapt to content length
- **Enhanced aesthetics**: More sophisticated visual arrangement

### Visual Effect

```text
[Apps | Controls] ··· [Date | Weather] ··· [System | Tray]
```

---

## 🎨 Visual Styling

### Font Configuration

All bars use consistent font stack:

```ini
font-0 = "Hack Nerd Font Mono:style=Regular:size=10;2"
font-1 = "Hack Nerd Font Mono:style=Solid:pixelsize=15;3"
font-2 = "Hack Nerd Font Mono:style=Regular:pixelsize=12;2"
font-3 = "Hack Nerd Font Mono:style=Solid:pixelsize=20;4"
font-4 = "Hack Nerd Font Mono:style=Solid:pixelsize=25;5"
font-5 = "Hack Nerd Font Mono:style=Solid:pixelsize=30;6"

; Emoji support (added for all configurations)
font-6 = "Noto Color Emoji:style=Regular:pixelsize=12;3"
font-7 = "Noto Color Emoji:style=Regular:pixelsize=15;3"
font-8 = "Noto Color Emoji:style=Regular:pixelsize=20;4"
font-9 = "Noto Color Emoji:style=Regular:pixelsize=25;5"
```

### Color Integration

All bars inherit colors from the main theme:

```ini
background = ${colors.background}
background-alt = ${colors.background-alt}
foreground = ${colors.foreground}
foreground-alt = ${colors.foreground-alt}
```

### Cursor Behavior

```ini
cursor-click = pointer
cursor-scroll = ns-resize
```

---

## 🔧 Configuration Selection

### Automatic Window Manager Detection

The `launch.sh` script automatically selects appropriate bars:

```bash
# Detect window manager
WM=$(wmctrl -m | grep -oE 'Name: .*' | cut -d' ' -f2 | tr '[:upper:]' '[:lower:]')

if [ "${WM}" = "i3" ]; then
  # Launch i3-specific bars
  polybar i3-polybar-top &
  polybar i3-polybar-bottom &
elif [ "${WM}" = "openbox" ]; then
  # Launch universal bars
  polybar polybar-top &
  polybar polybar-bottom &
fi
```

### Manual Bar Selection

```bash
# Launch specific bar configuration
polybar polybar-top &              # Universal top bar
polybar i3-polybar-top &           # i3 top bar
polybar i3-polybar-top-multipart & # i3 multipart (launches all sections)
```

### Monitor-Specific Configuration

```bash
# Set monitor for bar positioning
export MONITOR="HDMI-1"
polybar i3-polybar-top &

# Multi-monitor setup
for m in $(polybar --list-monitors | cut -d":" -f1); do
    MONITOR=$m polybar polybar-top &
done
```

---

## 🎯 Customization Patterns

### Creating Custom Bar Layouts

1. **Copy existing configuration**:
   ```bash
   cp ~/.config/polybar/bars/common-top.conf ~/.config/polybar/bars/my-custom-bar.conf
   ```

2. **Modify module placement**:
   ```ini
   [bar/my-custom-bar]
   modules-left = custom-module1
   modules-center = custom-module2
   modules-right = custom-module3
   ```

3. **Register in modules.conf**:
   ```ini
   include-file = ~/.config/polybar/bars/my-custom-bar.conf
   ```

### Module Arrangement Patterns

**Minimalist Layout**:
```ini
modules-left = jgmenu
modules-center = date
modules-right = tray
```

**Developer-Focused**:
```ini
modules-left = workspaces github
modules-center = playing
modules-right = cpu memory filesystem date
```

**Media-Centric**:
```ini
modules-left = apps
modules-center = player playing volume
modules-right = network date
```

### Responsive Design

```ini
# Adapt based on screen size
[bar/adaptive]
width = ${env:POLYBAR_WIDTH:100%}
height = ${env:POLYBAR_HEIGHT:25}
offset-x = ${env:POLYBAR_OFFSET_X:0}
```

---

## 🎚️ Advanced Features

### Inter-Process Communication (IPC)

All bars support IPC for dynamic control:

```ini
enable-ipc = true
```

Commands:
```bash
# Send action to bar
polybar-msg action "#github.hook.0"

# Update module
polybar-msg cmd restart
```

### Click Actions

Bars support various click interactions:

```ini
; Left click actions
click-left = command

; Right click actions  
click-right = rofi -show drun

; Scroll actions
scroll-up = increase-volume
scroll-down = decrease-volume
```

### Window Manager Integration

**i3 Configuration**:
```ini
wm-restack = i3
override-redirect = true
```

**Openbox Configuration**:
```ini
wm-restack = generic
override-redirect = false
```

---

## 🛠️ Troubleshooting

### Common Issues

**Bar not appearing**:
```bash
# Check if polybar is running
pgrep -f polybar

# Test configuration
polybar --config=~/.config/polybar/config.ini polybar-top

# Check for configuration errors
polybar --log=info polybar-top
```

**Wrong bar for window manager**:
```bash
# Check window manager detection
wmctrl -m

# Force specific window manager
export POLYBAR_WM="i3"
~/.config/polybar/launch.sh
```

**Modules not loading**:
```bash
# Verify module configuration
polybar --list-modules

# Check module-specific errors
polybar --log=debug polybar-top 2>&1 | grep ERROR
```

### Performance Optimization

**Reduce resource usage**:
- Increase module update intervals
- Use fewer modules
- Disable unnecessary animations

**Improve responsiveness**:
- Use appropriate module intervals
- Enable IPC for dynamic updates
- Optimize custom script execution

---

## ✅ Integration

### Works With

- ✅ **All supported window managers** (i3, Openbox, XFCE4)
- ✅ **Multi-monitor setups** with per-monitor configuration
- ✅ **Rice system** for automatic theme coordination
- ✅ **All polybar modules** from the dotfiles collection

### Pairs Well With

- **Rice switching** for coordinated theming
- **EWW widgets** for additional dashboard functionality
- **Window manager configurations** for complete desktop integration
- **Compositor settings** for visual effects

---

Choose the perfect bar layout for your workflow and window manager! 📊

> [!TIP]
> Start with the common bars for simplicity, then explore i3-specific features if using i3. The multipart layout offers the most flexibility for complex workflows but requires more configuration.
