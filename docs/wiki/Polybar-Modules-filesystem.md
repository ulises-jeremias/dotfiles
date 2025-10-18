# 💾 Polybar Module: Filesystem

Monitor disk usage and storage capacity across your mounted filesystems directly in polybar.

> [!TIP]
> The filesystem module provides real-time disk usage information with customizable mount points and visual indicators for storage health.

---

## 📋 Module Overview

The filesystem module displays:

- **Disk usage percentage** for mounted filesystems
- **Available space** and total capacity
- **Mount point information** for multiple drives
- **Visual indicators** with color-coded warnings

---

## ⚙️ Configuration

### Basic Setup

```ini
[module/filesystem]
type = internal/fs
interval = 25

mount-0 = /

label-mounted = %{T5}%{T-} %mountpoint% %percentage_used%% of %total%
label-mounted-foreground = ${xrdb:color7}
label-unmounted = %mountpoint% not mounted
label-unmounted-foreground = ${colors.foreground}
```

### Configuration Options

| Property | Value | Description |
|----------|-------|-------------|
| `type` | `internal/fs` | Built-in filesystem monitoring |
| `interval` | `25` | Update interval in seconds |
| `mount-0` | `/` | Primary mount point to monitor |
| `mount-1` | `/home` | Additional mount point (optional) |
| `fixed-values` | `true` | Use fixed-width values |

---

## 🎨 Visual Appearance

### Default Display

```text
💾 / 45% of 500GB
```

### Multiple Mount Points

```text
💾 / 45% 💾 /home 78%
```

### Custom Format Options

```ini
# Minimal format
label-mounted = %{T5}💾%{T-} %percentage_used%%

# Detailed format with colors
label-mounted = %{F#4fc3f7}%{T5}💾%{T-}%{F-} %mountpoint% %percentage_used%% (%available%)

# Progress bar format
label-mounted = %{T5}💾%{T-} %mountpoint% <bar-used> %percentage_used%%
```

---

## 📊 Mount Point Configuration

### Single Root Filesystem

```ini
[module/filesystem-root]
type = internal/fs
interval = 25
mount-0 = /
```

### Multiple Filesystems

```ini
[module/filesystem-multi]
type = internal/fs
interval = 25

; Monitor root, home, and external drives
mount-0 = /
mount-1 = /home
mount-2 = /media/external

; Show only mounted filesystems
display-mounted = true
```

### Network Mounts

```ini
[module/filesystem-network]
type = internal/fs
interval = 60

; Monitor network shares (longer interval)
mount-0 = /mnt/nas
mount-1 = /mnt/backup
```

---

## 🎯 Format Tokens

### Available Tokens

| Token | Description | Example |
|-------|-------------|---------|
| `%mountpoint%` | Mount point path | `/`, `/home` |
| `%percentage_used%` | Used space percentage | `45` |
| `%percentage_free%` | Free space percentage | `55` |
| `%total%` | Total filesystem size | `500GB` |
| `%used%` | Used space amount | `225GB` |
| `%free%` | Available space amount | `275GB` |
| `%percentage_shared%` | Shared space percentage | `2` |

### Progress Bars

```ini
[module/filesystem-bar]
type = internal/fs
interval = 25
mount-0 = /

; Enable progress bar
format-mounted = <label-mounted> <bar-used>
label-mounted = %{T5}💾%{T-} %mountpoint%

; Bar configuration
bar-used-width = 10
bar-used-indicator =
bar-used-fill = ─
bar-used-empty = ─
bar-used-foreground-0 = #55aa55
bar-used-foreground-1 = #557755
bar-used-foreground-2 = #f5a70a
bar-used-foreground-3 = #ff5555
```

---

## 🚨 Warning Thresholds

### Color-Coded Warnings

```ini
[module/filesystem-warnings]
type = internal/fs
interval = 25
mount-0 = /

; Warning thresholds
warn-percentage = 95
critical-percentage = 98

; Format with warnings
format-mounted = <label-mounted>
format-warn = <label-warn>
format-critical = <label-critical>

label-mounted = %{F#55aa55}%{T5}💾%{T-}%{F-} %percentage_used%%
label-warn = %{F#f5a70a}%{T5}⚠️%{T-}%{F-} %percentage_used%%
label-critical = %{F#ff5555}%{T5}🚨%{T-}%{F-} %percentage_used%%
```

### Custom Warning Scripts

```ini
[module/filesystem-smart]
type = custom/script
exec = ~/.config/polybar/configs/default/scripts/filesystem-check
interval = 30

; Custom script with emoji warnings
```

Example script (`~/.config/polybar/configs/default/scripts/filesystem-check`):

```bash
#!/usr/bin/env bash

usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

if [ "$usage" -gt 95 ]; then
    echo "%{F#ff5555}%{T5}🚨%{T-}%{F-} Critical: ${usage}%"
elif [ "$usage" -gt 80 ]; then
    echo "%{F#f5a70a}%{T5}⚠️%{T-}%{F-} Warning: ${usage}%"
else
    echo "%{F#55aa55}%{T5}💾%{T-}%{F-} Storage: ${usage}%"
fi
```

---

## 🔧 Advanced Features

### Clickable Actions

```ini
[module/filesystem-clickable]
type = internal/fs
interval = 25
mount-0 = /

format-mounted = <label-mounted>
label-mounted = %{A1:thunar /:}%{T5}💾%{T-} %percentage_used%%%{A}

; Click to open file manager
click-left = thunar /
click-right = baobab /  # Disk usage analyzer
```

### Multiple Format States

```ini
[module/filesystem-adaptive]
type = internal/fs
interval = 25
mount-0 = /

; Different formats based on usage
format-mounted = <label-mounted>
format-mounted-underline = ${colors.blue}

; High usage format
format-warn = <label-warn>
format-warn-underline = ${colors.orange}

; Critical usage format  
format-critical = <label-critical>
format-critical-underline = ${colors.red}
```

---

## 📊 Usage Examples

### Minimal System Monitor

```ini
modules-right = cpu memory filesystem
```

### Detailed Storage Panel

```ini
[module/storage-panel]
type = internal/fs
interval = 25

mount-0 = /
mount-1 = /home
mount-2 = /var

format-mounted = <label-mounted>
label-mounted = %{T5}💾%{T-} %mountpoint%: %used%/%total% (%percentage_used%%)
spacing = 2
```

### Home Lab Setup

```ini
[module/filesystem-homelab]
type = internal/fs
interval = 60

; Monitor multiple drives
mount-0 = /
mount-1 = /home
mount-2 = /media/data
mount-3 = /media/backup

label-mounted = %{T6}💾%{T-} %mountpoint% %percentage_used%%
separator = " | "
```

---

## 🛠️ Troubleshooting

### Common Issues

**Mount points not showing**:

- Verify mount point exists: `mount | grep /path`
- Check filesystem permissions
- Ensure mount point is accessible

**Incorrect usage values**:

- Check filesystem type support
- Verify permissions for filesystem access
- Update interval may be too fast for network mounts

**Performance issues**:

```ini
; Increase interval for network mounts
interval = 120

; Reduce mount points being monitored
mount-0 = /  ; Only monitor essential mounts
```

### Debugging

```bash
# Test filesystem access
df -h /
ls -la /mount/point

# Check polybar filesystem module
polybar-msg action filesystem hook 0
```

---

## 🎨 Customization Ideas

### Emoji-Enhanced Display

```ini
[module/filesystem-emoji]
type = internal/fs
interval = 25
mount-0 = /

label-mounted = %{T6}💽%{T-} Root: %percentage_used%% %{T6}📊%{T-} Free: %percentage_free%%
```

### Minimalist Design

```ini
[module/filesystem-minimal]
type = internal/fs
interval = 25
mount-0 = /

label-mounted = %percentage_used%%
format-mounted-prefix = "💾 "
format-mounted-prefix-foreground = ${colors.blue}
```

### Comprehensive Storage Info

```ini
[module/filesystem-detailed]
type = internal/fs
interval = 25
mount-0 = /

label-mounted = %{T5}💾%{T-} %mountpoint% • Used: %used% • Free: %free% • Total: %total%
```

---

## ✅ Integration

### Works With

- ✅ **All bar configurations** (top, bottom, i3)
- ✅ **Multiple mount points** simultaneously
- ✅ **Network filesystems** (with appropriate intervals)
- ✅ **Any file manager** for click actions

### Pairs Well With

- **System resource modules** (CPU, memory)
- **System tray** for disk utility access
- **Temperature monitoring** for drive health

---

Keep track of your storage health at a glance! 💽

> [!TIP]
> Position the filesystem module in your bottom bar alongside other system monitoring modules for a comprehensive system status overview.
