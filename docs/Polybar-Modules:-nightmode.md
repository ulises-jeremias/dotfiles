# 🌙 Polybar Module: Night Mode Toggle

The **Night Mode module** provides a simple and effective toggle to switch between light and dark themes. It's perfect for reducing eye strain and adapting your desktop to ambient lighting conditions.

> [!TIP]
> Switch modes with a single click — whether you're working late or stepping into daylight.

---

## 🔄 Functionality

- **Click Button** → Toggles between light mode and dark mode
- The module displays an icon or label indicating the current mode (e.g., sun/moon icons)

---

## ⚙️ Configuration Example

```ini
[module/nightmode]
type = custom/script
exec = dots night-mode --status
click-left = dots night-mode --toggle
interval = 5
```

> 🧠 The `dots night-mode` script handles both the status display and the toggle logic.

---

## ✅ Requirements

- `dots night-mode` script (included in the dotfiles)
- Optional: Scripts or theme switchers that apply GTK, terminal, or WM-specific themes

---

## 🎨 Customization Tips

- Adjust icons or labels returned by the `--status` flag in the script
- Combine with `pywal`, `gtk-theme`, or `qt5ct` for full environment theming
- Set different icons, fonts, or color changes in your Polybar config to reflect the mode visually

---

Add some balance to your workspace with an elegant light/dark toggle — right from your bar. 🌘
