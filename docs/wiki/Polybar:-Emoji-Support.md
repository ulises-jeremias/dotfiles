# 😀 Polybar: Emoji Support

Polybar in this dotfiles setup includes **full emoji support** using Noto Color Emoji fonts. You can now use colorful emojis alongside traditional Nerd Font icons to create visually appealing status bars.

> [!TIP]
> Emoji support is available across all polybar configurations without modifying existing modules. Simply use the new font tags to display emojis in your custom scripts and modules.

---

## 🎨 Available Emoji Fonts

Four emoji font sizes have been added to all polybar configurations:

| Font Tag | Size | Usage |
|----------|------|-------|
| `%{T6}` | Small (size=10) | Inline icons that match text size |
| `%{T7}` | Medium (pixelsize=15) | Slightly larger emphasis |
| `%{T8}` | Large (pixelsize=20) | Module headers or important status |
| `%{T9}` | Extra Large (pixelsize=25) | Dashboard-style displays |

Remember to use `%{T-}` to reset back to the default font.

---

## 🚀 Quick Start Examples

### Simple Emoji Usage

```bash
# Display battery with emoji
echo "%{T6}🔋%{T-} 85%"

# Weather with different sizes
echo "%{T7}🌤️%{T-} 22°C"
echo "%{T8}☀️%{T-} Sunny"
```

### Custom Script Example

```bash
#!/usr/bin/env bash
# Weather script with emoji support

case "$(dots-weather-info --condition)" in
    "sunny") echo "%{T7}☀️%{T-} $(dots-weather-info --temp)" ;;
    "cloudy") echo "%{T7}☁️%{T-} $(dots-weather-info --temp)" ;;
    "rain") echo "%{T7}🌧️%{T-} $(dots-weather-info --temp)" ;;
    *) echo "%{T7}🌤️%{T-} $(dots-weather-info --temp)" ;;
esac
```

---

## 📦 Module Integration

### Direct Module Format

Use emojis directly in polybar module formats:

```ini
[module/cpu-emoji]
type = internal/cpu
interval = 2
format = %{T6}💻%{T-} %percentage:2%%

[module/memory-emoji]
type = internal/memory
interval = 2
format = %{T6}🧠%{T-} %percentage_used%%

[module/date-emoji]
type = internal/date
interval = 5
format = %{T6}📅%{T-} %date% %{T6}🕐%{T-} %time%
```

### Script-Based Modules

Create enhanced scripts for existing modules:

```ini
[module/battery-emoji]
type = custom/script
exec = ~/.config/polybar/scripts/battery-emoji
interval = 60

[module/volume-emoji]
type = custom/script
exec = ~/.config/polybar/scripts/volume-emoji
interval = 1
click-left = pamixer --toggle-mute
```

---

## 🎯 Popular Emoji Collections

### System Monitoring

- 💻 CPU usage
- 🧠 Memory/RAM
- 💾 Storage/Disk space
- 🔥 Temperature
- ⚡ Power/Performance

### Connectivity

- 📶 WiFi signal
- 🌐 Internet connection
- 📡 Network activity
- 🔗 Connection status

### Audio & Media

- 🔊 High volume
- 🔉 Medium volume
- 🔈 Low volume
- 🔇 Muted
- 🎵 Music playing
- ⏸️ Paused
- ⏭️ Next track

### Weather

- ☀️ Sunny
- ⛅ Partly cloudy
- ☁️ Cloudy
- 🌧️ Rain
- ❄️ Snow
- ⛈️ Thunderstorm

### Power & Battery

- 🔋 Battery levels
- 🪫 Low battery
- 🔌 Charging
- 💡 Brightness

---

## 🔧 Advanced Usage

### Color Coordination

Combine emojis with polybar color formatting:

```bash
echo "%{F#ff6b6b}%{T7}🔥%{T-}%{F-} High CPU Usage"
echo "%{F#4ecdc4}%{T6}💾%{T-}%{F-} Storage OK"
echo "%{F#ffcc02}%{T6}⚠️%{T-}%{F-} Warning"
```

### Dynamic Emoji Selection

Create smart scripts that choose emojis based on values:

```bash
#!/usr/bin/env bash
# Smart battery emoji script

battery_level=$(cat /sys/class/power_supply/BAT0/capacity)
status=$(cat /sys/class/power_supply/BAT0/status)

if [ "$status" = "Charging" ]; then
    emoji="🔌"
elif [ "$battery_level" -gt 75 ]; then
    emoji="🔋"
elif [ "$battery_level" -gt 25 ]; then
    emoji="🔋"
else
    emoji="🪫"
fi

echo "%{T6}$emoji%{T-} $battery_level%"
```

---

## 📁 Updated Configuration Files

Emoji support has been added to these polybar configurations:

- `~/.config/polybar/bars/common-top.conf`
- `~/.config/polybar/bars/common-bottom.conf`
- `~/.config/polybar/bars/i3-top.conf`
- `~/.config/polybar/bars/i3-bottom.conf`
- `~/.config/polybar/bars/i3-top-multipart.conf`

---

## 🧪 Testing Emoji Support

Test if emojis are working correctly:

1. **Restart Polybar**:

   ```sh
   ~/.config/polybar/launch.sh
   ```

2. **Create a Test Module**:

   ```ini
   [module/emoji-test]
   type = custom/script
   exec = echo "%{T6}🔋%{T-} %{T7}📶%{T-} %{T8}🌤️%{T-} %{T9}💻%{T-}"
   interval = 60
   ```

3. **Add to Bar Configuration**:

   ```ini
   modules-right = emoji-test
   ```

---

## ✅ Compatibility

- ✅ **Rice Support**: Works with all existing rice configurations
- ✅ **Font Compatibility**: Compatible with current Nerd Font icons
- ✅ **Module Safety**: No changes needed to existing modules
- ✅ **Backward Compatible**: Existing setup continues to work
- ✅ **Window Manager**: Works with both Openbox and i3

---

## 💡 Best Practices

### Accessibility

- Always include descriptive text alongside emojis
- Use consistent emoji meanings across modules
- Consider colorblind-friendly alternatives

### Performance

- Avoid excessive emoji usage in high-frequency modules
- Use appropriate font sizes for your display resolution
- Test emoji rendering on different screen sizes

### Design

- Maintain visual consistency across your polybar setup
- Use emojis to enhance, not replace, informative text
- Consider your overall theme when choosing emojis

---

Ready to add some personality to your status bar with emojis! 🎉

> [!TIP]
> Start with simple emojis in low-frequency modules like weather or battery, then expand to other areas as you get comfortable with the syntax.
