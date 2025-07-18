# 🎵 Polybar Module: Music Player

Control and monitor music playback from various media players directly in your polybar.

> [!TIP]
> The music player modules provide comprehensive media control with support for multiple players via MPRIS and custom integrations.

---

## 📋 Module Overview

The music player system includes multiple modules:

- **player**: Universal media control buttons (play/pause/next/prev)
- **playing**: Current song title display
- **spotify**: Dedicated Spotify integration
- **mpd**: Music Player Daemon support

---

## 🎮 Player Control Module

### Configuration

```ini
[module/player]
type = custom/script
interval = 1
exec = ~/.config/polybar/scripts/player
```

### Visual Display

**Playing State**:

```text
󰒮 󰏥 󰒭
```

**Paused State**:

```text
󰒮 󰐌 󰒭
```

**No Player Active**:

```text
(empty - module hides)
```

### Features

- **Click controls**: Previous, play/pause, next
- **Universal support**: Works with any MPRIS-compatible player
- **Automatic detection**: Only shows when media is playing/paused
- **Color-coded status**: Different colors for playing vs paused

---

## 🎤 Song Title Module

### Setup

```ini
[module/playing]
type = custom/script
interval = 1
exec = ~/.config/polybar/scripts/player --title
```

### Display Format

```text
Current Song Title (truncated to 30 chars)
```

### Capabilities

- **Smart truncation**: Long titles are automatically shortened
- **Multi-player support**: Shows active player's current track
- **Colored output**: Uses theme-appropriate colors
- **Real-time updates**: Updates every second during playback

---

## 🎧 Advanced Configuration

### Combined Player Display

```ini
[module/media-player]
type = custom/script
interval = 1
exec = ~/.config/polybar/scripts/player
format = <label>

[module/media-title]
type = custom/script
interval = 1
exec = ~/.config/polybar/scripts/player --title
format = <label>

; In bar configuration
modules-center = media-title media-player
```

### Custom Player Script Options

The player script supports various options:

```bash
# Show only the title
~/.config/polybar/scripts/player --title

# Show control buttons (default)
~/.config/polybar/scripts/player

# Get help
~/.config/polybar/scripts/player --help
```

---

## 🎨 Customization

### Color Customization

The player script uses hardcoded colors that you can modify:

```bash
# In the script file
status_label=""
if [ "${player_status}" = "Playing" ]; then
  status_label="%{F#ebcb8b}󰏥%{F}"  # Playing color (yellow)
elif [ "${player_status}" = "Paused" ]; then
  status_label="%{F#a3be8c}󰐌%{F}"  # Paused color (green)
fi

# Button colors
prev_label="%{T4}%{A1:playerctl prev:}%{F#b48ead}󰒮%{F}%{A}%{T-}"   # Purple
next_label="%{T4}%{A1:playerctl next:}%{F#b48ead}󰒭%{F}%{A}%{T-}"   # Purple
```

### Title Length Customization

Modify the truncation length in the script:

```bash
# Change from 30 to your preferred length
current_song="$(playerctl metadata -s --format '{{trunc(title, 50)}}' | awk 'NR==1 {print; exit}')"
```

### Icon Customization

Replace the Nerd Font icons with your preferred symbols:

```bash
# Replace these icons in the script
󰒮  # Previous (nf-md-skip_previous)
󰏥  # Play (nf-md-play)  
󰐌  # Pause (nf-md-pause)
󰒭  # Next (nf-md-skip_next)
```

---

## 🎵 MPD Module

### MPD Configuration

```ini
[module/mpd]
type = internal/mpd
host = 127.0.0.1
port = 6600

format-online = <label-song> <icon-prev> <icon-seekb> <icon-stop> <toggle> <icon-seekf> <icon-next>
format-offline = <label-offline>

label-song = %artist% - %title%
label-offline = 🎵 mpd is offline

icon-prev = 󰒮
icon-stop = 󰓛
icon-play = 󰏥
icon-pause = 󰐌
icon-next = 󰒭
icon-seekb = 󰒪
icon-seekf = 󰒫
```

### MPD Integration Benefits

- **Direct connection** to Music Player Daemon
- **Rich metadata** access (artist, album, etc.)
- **Playlist control** and seeking
- **Connection status** monitoring

---

## 🔧 Supported Players

### MPRIS-Compatible Players

The universal player module works with:

- **Spotify**: Full playback control
- **VLC**: Media player integration
- **Firefox**: Web audio/video control
- **Chromium/Chrome**: Browser media control
- **Rhythmbox**: GNOME music player
- **Amarok**: KDE music player
- **Clementine**: Cross-platform music player
- **And many more**: Any MPRIS-compliant application

### Player Detection

```bash
# List active players
playerctl -l

# Check current player status
playerctl status

# Get metadata from specific player
playerctl -p spotify metadata
```

---

## 📊 Usage Examples

### Minimal Media Bar

```ini
modules-center = playing player
```

### Full Media Experience

```ini
# Top bar
modules-center = playing

# Bottom bar
modules-left = player spotify volume
```

### Developer Setup

```ini
# Focus on productivity
modules-right = player github cpu memory date
```

---

## 🛠️ Troubleshooting

### Common Issues

**No player controls showing**:

- Check if any media player is running: `playerctl status`
- Verify playerctl is installed: `which playerctl`
- Test script manually: `~/.config/polybar/scripts/player`

**Controls not working**:

- Test playerctl commands: `playerctl play-pause`
- Check player MPRIS support: `playerctl -l`
- Verify script permissions: `chmod +x ~/.config/polybar/scripts/player`

**Title not updating**:

- Check update interval (should be 1 second for real-time)
- Test title command: `~/.config/polybar/scripts/player --title`
- Verify metadata availability: `playerctl metadata`

### Debugging

```bash
# Test playerctl functionality
playerctl status
playerctl metadata

# Test script output
bash -x ~/.config/polybar/scripts/player
bash -x ~/.config/polybar/scripts/player --title

# Check active MPRIS players
busctl --user list | grep mpris
```

---

## 🎯 Advanced Features

### Player Priority

If multiple players are active, playerctl follows this priority:

1. **Most recently active** player
2. **Spotify** (if available)
3. **First detected** player

### Custom Player Selection

```bash
# Force specific player
playerctl -p spotify play-pause
playerctl -p vlc next
```

### Integration with Other Modules

```ini
# Combine with volume control
[module/media-controls]
type = custom/script
exec = echo "$(~/.config/polybar/scripts/player) | Vol: $(pamixer --get-volume)%"
interval = 1
```

---

## 🎨 Layout Ideas

### Centered Media Display

```ini
# Perfect for ultrawide monitors
modules-left = workspaces
modules-center = playing player volume
modules-right = network battery date
```

### Sidebar Media Panel

```ini
# For vertical bars or side panels
modules = playing player spotify
```

### Minimal Workflow

```ini
# Clean, distraction-free
modules-right = player date
```

---

## ✅ Integration

### Works With

- ✅ **All MPRIS players** (Spotify, VLC, browsers, etc.)
- ✅ **Multiple players** simultaneously
- ✅ **All bar configurations** and window managers
- ✅ **Remote control** via playerctl commands

### Pairs Well With

- **Volume controls** for complete audio management
- **Spotify module** for detailed track information
- **System tray** for player application access

---

Control your music without leaving your workflow! 🎶

> [!TIP]
> Place media controls in your center modules for easy access, or keep them minimal in the corner if you prefer keyboard shortcuts for music control.
