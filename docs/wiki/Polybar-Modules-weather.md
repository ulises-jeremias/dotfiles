# 🌤️ Polybar Module: Weather

Display current weather conditions with temperature and weather icons in your polybar.

> [!TIP]
> The weather module fetches data from OpenWeatherMap and displays it with beautiful weather icons and current temperature.

---

## 📋 Module Overview

The weather module provides real-time weather information including:

- **Current temperature** in your preferred unit
- **Weather condition icons** (sunny, cloudy, rainy, etc.)
- **Automatic updates** every 10 minutes
- **Network connectivity check** before fetching data

---

## ⚙️ Configuration

### Basic Setup

```ini
[module/weather]
type = custom/script
exec = ~/.config/polybar/configs/default/scripts/weather-info
exec-if = ping openweathermap.org -c 1
interval = 600
```

### Configuration Options

| Property | Value | Description |
|----------|-------|-------------|
| `type` | `custom/script` | Uses external script for data |
| `exec` | `~/.config/polybar/configs/default/scripts/weather-info` | Script path |
| `exec-if` | `ping openweathermap.org -c 1` | Check connectivity first |
| `interval` | `600` | Update every 10 minutes |

---

## 🎨 Visual Appearance

### Default Display

```text
🌤️ 22°C
```

The module shows:

- **Weather icon** using Nerd Font weather symbols
- **Temperature** in Celsius or Fahrenheit
- **Colored output** using system color scheme

### Customization

You can customize the appearance by modifying the script or adding format options:

```ini
[module/weather-custom]
type = custom/script
exec = ~/.config/polybar/configs/default/scripts/weather-info
interval = 600
format = <label>
format-prefix = "Weather: "
format-prefix-foreground = ${colors.primary}
```

---

## 🔧 Script Details

### Weather Script (`weather-info`)

```bash
#!/usr/bin/env bash

weather_temp=$(dots-weather-info --temp)
weather_icon=$(dots-weather-info --icon)

foreground="$(xrdb -get "color7")"

echo " %{F${foreground}}%{T5}$weather_icon%{T-}%{F} $weather_temp"
```

### Dependencies

- **dots-weather-info**: Core weather data fetching utility
- **OpenWeatherMap API**: External weather service
- **Internet connection**: Required for data updates

---

## 🌡️ Weather Icons

The module displays appropriate icons based on weather conditions:

| Condition | Icon | Description |
|-----------|------|-------------|
| Clear | ☀️ | Sunny skies |
| Partly Cloudy | ⛅ | Some clouds |
| Cloudy | ☁️ | Overcast |
| Rain | 🌧️ | Precipitation |
| Snow | ❄️ | Snow conditions |
| Thunderstorm | ⛈️ | Storms |

---

## 🔧 Setup Requirements

### API Configuration

1. **Get OpenWeatherMap API key**:
   - Register at [openweathermap.org](https://openweathermap.org/api)
   - Generate a free API key

2. **Configure dots-weather-info**:

   ```bash
   # Set up your API key and location
   dots-weather-info --setup
   ```

### Network Requirements

- **Internet connection** for weather data
- **OpenWeatherMap access** (port 80/443)
- **DNS resolution** for openweathermap.org

---

## 📊 Usage Examples

### Basic Weather Display

```ini
modules-right = weather date
```

### Weather with Custom Styling

```ini
[module/weather-styled]
type = custom/script
exec = ~/.config/polybar/configs/default/scripts/weather-info
interval = 600
format = %{T6}🌤️%{T-} <label>
format-background = ${colors.background-alt}
format-padding = 2
```

### Weather in Bottom Bar

```ini
# In bottom bar configuration
modules-center = weather
```

---

## 🚨 Troubleshooting

### Common Issues

**No weather data displayed**:

- Check internet connection: `ping openweathermap.org`
- Verify API key configuration
- Check script permissions: `chmod +x ~/.config/polybar/configs/default/scripts/weather-info`

**Weather data is outdated**:

- Check the update interval (default: 10 minutes)
- Manually test the script: `~/.config/polybar/configs/default/scripts/weather-info`
- Verify network connectivity

**Script errors**:

```bash
# Test the underlying command
dots-weather-info --temp
dots-weather-info --icon

# Check script output
bash -x ~/.config/polybar/configs/default/scripts/weather-info
```

### Performance Optimization

**Reduce network requests**:

```ini
# Increase interval to 30 minutes
interval = 1800
```

**Add failure handling**:

```ini
# Only update if network is available
exec-if = ping -c 1 openweathermap.org && command -v dots-weather-info
```

---

## 🎯 Advanced Configuration

### Custom Weather Format

Create a custom weather display script:

```bash
#!/usr/bin/env bash
# ~/.config/polybar/configs/default/scripts/weather-custom

temp=$(dots-weather-info --temp)
condition=$(dots-weather-info --condition)
icon=$(dots-weather-info --icon)

case "$condition" in
    "clear") color="#ffcc02" ;;
    "rain") color="#4fc3f7" ;;
    "snow") color="#e3f2fd" ;;
    *) color="#ffffff" ;;
esac

echo "%{F$color}%{T5}$icon%{T-}%{F-} $temp"
```

### Conditional Display

Show weather only during specific hours:

```bash
#!/usr/bin/env bash
hour=$(date +%H)

# Only show weather between 6 AM and 10 PM
if [ "$hour" -ge 6 ] && [ "$hour" -le 22 ]; then
    ~/.config/polybar/configs/default/scripts/weather-info
fi
```

---

## ✅ Integration

### Works With

- ✅ **All bar configurations** (top, bottom, i3)
- ✅ **Any window manager** (i3, Openbox, etc.)
- ✅ **Multi-monitor setups**
- ✅ **Rice switching** (adapts to color schemes)

### Pairs Well With

- **Date/time modules** for complete status info
- **Network modules** for connectivity awareness
- **System tray** for weather app integration

---

Stay informed about the weather without leaving your desktop! 🌦️

> [!TIP]
> Position the weather module in your bottom bar or next to the date for quick reference throughout the day.
