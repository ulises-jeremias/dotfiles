# 🧠 Polybar Module: CPU

The **CPU module** gives you real-time insights into your system's processor load and temperature — directly from your Polybar.

> [!TIP]
> Great for monitoring system performance at a glance, especially on laptops and lightweight setups.

---

## 📦 Features

- **CPU Usage**: Shows current CPU usage as a percentage
- **CPU Temperature**: Displays the current temperature of your CPU

These metrics are updated at a configurable interval, providing fresh performance data every few seconds.

---

## ⚙️ Configuration Tips

Common options include:

```ini
[module/cpu]
type = internal/cpu
interval = 2
format =   %percentage:2%%
format-underline = #f1c40f
```

> 🧠 Some setups may include temperature info directly in the same module, or use a separate one depending on the available sensors.

---

## ✅ Requirements

- For CPU usage: none (built-in Polybar support)
- For temperature: requires `lm_sensors`

Install with:

```sh
sudo pacman -S lm_sensors
sudo sensors-detect
```

Then restart Polybar and check the output.

---

## 🧠 Pro Tip

You can combine this module with alert thresholds (e.g., underline or color change) to visually notify when CPU load gets too high.

Stay informed about your system's health without leaving your workspace! 🚀
