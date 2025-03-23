# 📅 Polybar Module: Date & Calendar

The **Date module** displays the current date and time in your Polybar. It comes in two flavors — one minimal, and one interactive with a popup calendar.

> [!TIP]
> This module is ideal for quick date/time checks, and the popup variant adds easy calendar access right from the bar.

---

## 📦 Available Variants

- `[module/date]` – Displays the current date and time only
- `[module/date-popup]` – Displays date/time and opens a calendar on click

---

## 🧩 Functionality

- **Real-Time Display**: Updates every second or minute (configurable) to reflect the current system time
- **Popup Calendar** *(only in `date-popup`)*: Left-click opens the XFCE4 calendar

---

## ⚙️ Configuration Example

```ini
[module/date]
type = internal/date
interval = 5
format =   %Y-%m-%d %H:%M
```

```ini
[module/date-popup]
type = custom/script
exec = date '+  %a, %d %b  %H:%M'
click-left = xfce4-calendar
interval = 60
```

> [!TIP]
> You can replace `xfce4-calendar` with your preferred calendar app or script.

---

## ✅ Requirements

- For `date`: No external dependencies (built-in module)
- For `date-popup`: Calendar application like `xfce4-calendar` must be installed

---

## 🔧 Customization Tips

- Change the date format to suit your locale or style using `strftime` format codes
- Customize icons (e.g., ``, ``) for visual variety
- Use underlines or colors to highlight time of day or work hours

---

Keep your desktop time-aware and calendar-ready with this flexible date module ⏰
