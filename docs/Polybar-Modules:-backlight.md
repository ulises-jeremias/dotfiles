# 🔆 Polybar Module: Backlight

The **Backlight modules** in this setup allow you to display and control your screen brightness directly from your Polybar.

> [!TIP]
> These modules support different backends (`xbacklight`, `acpi`) to adapt to your hardware configuration. Choose the one that fits your system.

---

## 📦 Available Modules

- `modules/xbacklight` – Uses [`xbacklight`](https://linux.die.net/man/1/xbacklight) to read and set brightness
- `modules/backlight-acpi` – Uses [`acpi`](https://wiki.archlinux.org/title/Backlight#ACPI) for systems with ACPI backlight support
- `modules/backlight-acpi-bar` – Same as above, but includes a visual progress bar in the module

---

## ⚙️ Functionality

Each module offers interactive features:

- **Scroll Up**: Increase brightness by 5% per scroll
- **Scroll Down**: Decrease brightness by 5% per scroll
- **Left Click**: Toggle Redshift (night mode)

> [!TIP]
> Behavior may vary depending on whether your system supports `xbacklight` or `acpi`. You may need to test and switch modules based on your setup.

---

## 📁 Configuration Path

You can find these modules in your dotfiles under:

```sh
~/.config/polybar/modules/
```

To enable one of them, reference it in your Polybar config file (e.g., `config.ini`).

---

## 🆘 Troubleshooting

- Ensure the appropriate backend (`xbacklight` or `acpi`) is installed and supported by your system
- Check permissions for backlight control in `/sys/class/backlight`

---

Enjoy quick and intuitive brightness control — with a Redshift toggle baked right into your bar! 🌅
