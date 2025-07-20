# 🎨 EWW: Elkowars Wacky Widgets

EWW (Elkowars Wacky Widgets) provides beautiful, customizable desktop widgets including a comprehensive dashboard and power menu for your dotfiles setup.

> [!TIP]
> EWW widgets integrate seamlessly with your rice themes and automatically adapt their colors using pywal/wpg color schemes.

---

## 📋 Overview

Your EWW setup includes two main widget collections:

- **Dashboard**: Complete desktop overview with system info, music controls, and quick actions
- **Powermenu**: Elegant system power controls (lock, logout, sleep, reboot, shutdown)

Both widgets feature:

- **Automatic color theming** via pywal integration
- **Responsive layouts** that adapt to different screen sizes
- **Click actions** for launching applications and system controls
- **Real-time system information** display

---

## 🎛️ Dashboard Widget

### Features

**System Monitoring**:

- CPU, memory, brightness, and battery usage with progress bars
- Real-time system resource visualization
- Color-coded status indicators

**Time & Weather**:

- Large, prominent clock display with AM/PM
- Current day and date information
- Weather integration with current conditions

**Music Control**:

- Album artwork display
- Current song and artist information
- Play/pause/next/previous controls
- Progress bar for track position

**Quick Links**:

- GitHub, YouTube, and email shortcuts
- Customizable application launchers
- File manager quick access folders

**Power Controls**:

- Lock, logout, sleep, reboot, and poweroff buttons
- Visual confirmation with themed icons
- Integration with system power management

### Launch Dashboard

```bash
# Launch dashboard
~/.config/eww/dashboard/launch.sh

# Or using the dots utility
dots eww-dashboard
```

### Dashboard Layout

```text
┌─────────────────────────────────────────────────────────┐
│ [Profile]    [System Stats]    [Clock]                 │
│              [CPU/Memory]      [Date]                  │
│              [Brightness]      [AM/PM]                 │
│              [Battery]                                 │
├─────────────────────────────────────────────────────────┤
│ [Music Player with Album Art]   [Weather Info]         │
│ [Song Title]                    [Temperature]          │
│ [Artist]                        [Conditions]           │
│ [Controls: ⏮️ ⏯️ ⏭️]             [Quote/Status]          │
├─────────────────────────────────────────────────────────┤
│ [GitHub] [YouTube] [Mail]      [Folders]               │
│                                [Documents] [Downloads]   │
│                                [Pictures] [Videos]      │
├─────────────────────────────────────────────────────────┤
│ [Power Controls: 🔒 🚪 😴 🔄 ⚡]                         │
└─────────────────────────────────────────────────────────┘
```

---

## ⚡ Powermenu Widget

### Power Options

**Power Options**:

- **Lock**: Secure your session with betterlockscreen
- **Logout**: Exit current user session
- **Sleep**: Suspend system to RAM
- **Reboot**: Restart the system
- **Poweroff**: Complete system shutdown

**Visual Design**:

- Elegant overlay with background blur
- Large, colorful icons for each power option
- Clock display for context
- System uptime information

### Launch Powermenu

```bash
# Launch powermenu
~/.config/eww/powermenu/launch.sh

# Or using keyboard shortcut (typically configured in WM)
# Default: Super + X
```

### Powermenu Layout

```text
┌─────────────────────────────────────────┐
│              [Clock Display]            │
│              [Current Time]             │
│              [Day & Date]               │
├─────────────────────────────────────────┤
│              [Uptime Info]              │
│          [Hours] : [Minutes]            │
├─────────────────────────────────────────┤
│  🔒    🚪    😴    🔄    ⚡            │
│ Lock  Logout Sleep Reboot Power         │
└─────────────────────────────────────────┘
```

---

## 🎨 Theming & Colors

### Automatic Color Integration

EWW widgets automatically inherit colors from your current rice theme:

```scss
// Dashboard colors (auto-generated)
@import "colors.scss";

.btn_lock {
  color: $color10;
}
.btn_logout {
  color: $color9;
}
.btn_sleep {
  color: $color11;
}
.btn_reboot {
  color: $color12;
}
.btn_poweroff {
  color: $color13;
}
```

### Color Sources

Colors are sourced from:

- **Primary**: `~/.cache/wal/colors.scss` (pywal generated)
- **Fallback**: Theme-specific color definitions
- **Update**: Automatic via `dots-wal-reload` script

### Theme Adaptation

When you switch rice themes:

1. **Colors update automatically** via symlinked color files
2. **Widgets reload** to apply new color scheme
3. **Background images** sync with current wallpaper
4. **Transparency effects** adapt to theme aesthetics

---

## 🔧 Configuration

### Dashboard Configuration

**Main Config**: `~/.config/eww/dashboard/eww.yuck`

Key configurable elements:

```yuck
; Profile section
(defwidget profile []
  (box :class "genwin" :orientation "v" :spacing 20 :halign "center" :valign "center" :space-evenly "false"
    (image :class "face" :path "/path/to/profile-image.png" :image-width 200 :image-height 200)
    (label :class "fullname" :halign "center" :text "Your Name")
    (label :class "username" :halign "center" :text "@username")))

; System monitoring
(defwidget system []
  (box :class "genwin" :orientation "v" :spacing 20 :halign "center" :valign "center" :space-evenly "false"
    (systemprogress :data 'CPU' :icon "" :onchange "")
    (systemprogress :data 'MEM' :icon "" :onchange "")
    (systemprogress :data 'BRIGHT' :icon "" :onchange "")
    (systemprogress :data 'BAT' :icon "" :onchange "")))
```

### Powermenu Configuration

**Main Config**: `~/.config/eww/powermenu/eww.yuck`

Power button actions:

```yuck
(defwidget logout []
  (box :class "genwin" :orientation "v" :spacing 20 :halign "center" :valign "center" :space-evenly "false"
    (button :class "btn_logout" :onclick "i3-msg exit" "")))

(defwidget lock []
  (box :class "genwin" :orientation "v" :spacing 20 :halign "center" :valign "center" :space-evenly "false"
    (button :class "btn_lock" :onclick "betterlockscreen -l" "")))
```

---

## 📱 Widget Management

### Starting EWW Daemon

```bash
# Check if EWW daemon is running
eww ping

# Start daemon if not running
eww daemon

# Kill all EWW windows
eww kill
```

### Managing Individual Widgets

```bash
# Dashboard controls
eww --config ~/.config/eww/dashboard open dashboard-background
eww --config ~/.config/eww/dashboard close dashboard-background

# Powermenu controls
eww --config ~/.config/eww/powermenu open powermenu-background
eww --config ~/.config/eww/powermenu close powermenu-background

# List active windows
eww active-windows
```

### Integration with Window Managers

**i3 Integration**:

```bash
# Add to i3 config
bindsym $mod+d exec ~/.config/eww/dashboard/launch.sh
bindsym $mod+x exec ~/.config/eww/powermenu/launch.sh
```

**Openbox Integration**:

```xml
<!-- Add to rc.xml -->
<keybind key="W-d">
  <action name="Execute">
    <command>~/.config/eww/dashboard/launch.sh</command>
  </action>
</keybind>
```

---

## 🎯 Customization

### Adding Custom Widgets

1. **Create widget definition** in `eww.yuck`
2. **Add styling** in `eww.scss`
3. **Update launch script** to include new widget
4. **Test and reload**

### Custom System Information

```yuck
; Example: Custom disk usage widget
(defwidget disk_usage []
  (box :class "genwin" :orientation "v"
    (label :class "disk_label" :text "Storage")
    (scale :class "disk_bar"
           :value {EWW_DISK["/"].used_perc}
           :orientation "h"
           :max 100
           :min 0)))
```

### Weather Integration

Update weather information:

```yuck
(defwidget weather []
  (box :class "genwin" :orientation "v"
    (label :class "iconweather" :text "")
    (label :class "label_temp" :text "${weather_temp}")
    (label :class "label_stat" :text "${weather_condition}")))
```

---

## 🚨 Troubleshooting

### Common Issues

**EWW daemon not starting**:

```bash
# Check for conflicts
pkill eww
eww daemon

# Check logs
eww logs
```

**Widgets not displaying**:

```bash
# Verify configuration syntax
eww --config ~/.config/eww/dashboard ping

# Reload widgets
eww --config ~/.config/eww/dashboard reload
```

**Color theming not working**:

```bash
# Check color file exists
ls -la ~/.config/eww/dashboard/colors.scss

# Regenerate colors
dots-wal-reload

# Force reload
eww --config ~/.config/eww/dashboard kill
~/.config/eww/dashboard/launch.sh
```

### Performance Optimization

**Reduce update frequency**:

```yuck
; Adjust polling intervals
(defpoll cpu_usage :interval "2s" `top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}'`)
```

**Optimize resource usage**:

```bash
# Monitor EWW resource usage
ps aux | grep eww
```

---

## ✅ Integration

### Works With

- ✅ **All rice themes** (automatic color adaptation)
- ✅ **Multiple window managers** (i3, Openbox, etc.)
- ✅ **System power management** (systemd, betterlockscreen)
- ✅ **Media players** (MPRIS-compatible applications)

### Pairs Well With

- **Polybar modules** for complementary system information
- **Rofi launchers** for application management
- **Rice switching system** for theme coordination

---

Transform your desktop with beautiful, functional widgets! ✨

> [!TIP]
> Use the dashboard as your desktop hub for quick system overview and the powermenu for elegant session management. Both widgets automatically adapt to your current rice theme for consistent visual experience.
