# 🔋 Polybar Module: Battery

The **Battery module** provides real-time updates about your system’s power level — right from your Polybar.

> [!TIP]
> This module is fully customizable and supports dynamic formatting for different battery states: charging, discharging, full, or low.

---

## ⚙️ Functionality

The battery module offers:

- **Battery Status**: Shows "Charging", "Discharging", or "Full"
- **Battery Percentage**: Displays the current remaining percentage
- **Low Battery Warning**: Alerts you visually when the battery level is low

> [!TIP]
> You can combine this module with other power-related scripts or notifications for a complete power management workflow.

---

## 🧩 Configuration Options

You can configure the battery module in your `config.ini` file or equivalent. Common options include:

- `format-charging`: Format displayed while charging (e.g., `Charging: %percentage%%`)
- `format-discharging`: Format while discharging
- `format-full`: Format for full battery
- `format-low`: Format and style when battery level is low (can be used to trigger warnings)

For a full list of configuration options, refer to the [Polybar battery module documentation](https://github.com/polybar/polybar/wiki/Module-battery).

---

## 🔧 Example Snippet

```ini
[module/battery]
type = internal/battery
battery = BAT0
format-charging = ⚡ %percentage%%
format-discharging = 🔋 %percentage%%
format-full = 💯 %percentage%%
format-low = 🚨 %percentage%%
```

---

## 📁 Integration

- Ensure your system exposes battery status through `/sys/class/power_supply/BAT0/` (or the equivalent path)
- Adjust the `battery` setting if your system uses `BAT1`, `BAT2`, etc.
- Include the module in your Polybar bar config under the appropriate position (`modules-left`, `modules-center`, `modules-right`)

---

Stay informed and in control of your power status at all times with this simple yet powerful module! ⚡
