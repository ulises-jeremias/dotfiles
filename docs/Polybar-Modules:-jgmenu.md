# 🗂️ Polybar Module: Jgmenu

The **Jgmenu module** integrates [jgmenu](https://github.com/johanmalm/jgmenu) — a fast and highly configurable menu — into your Polybar setup.

> [!TIP]
> With one click, you get access to a custom menu that can be styled, scripted, and themed to fit your desktop.

---

## 🧭 Functionality

- **Left-click** → Launches the `jgmenu` menu
- **Right-click** → Opens the `jgmenurc` configuration file in your default editor for quick customization

This makes it super easy to open apps, tweak settings, or manage the layout of your jgmenu from the bar.

---

## ⚙️ Configuration Snippet

```ini
[module/jgmenu]
type = custom/script
exec = echo ""
click-left = jgmenu_run
click-right = $EDITOR ~/.config/jgmenu/jgmenurc
interval = once
```

> [!TIP]
> Customize the icon (``) based on your font set or theme.

---

## ✅ Requirements

- [jgmenu](https://github.com/johanmalm/jgmenu) must be installed
- A configured `~/.config/jgmenu/jgmenurc` file

Install on Arch-based distros:

```sh
sudo pacman -S jgmenu
```

---

## 🎨 Customization Tips

- Define custom menu entries, themes, and font settings in `jgmenurc`
- Create dynamic menus using scripts as sources
- Use a launcher icon that matches your theme or WM

---

With Jgmenu in your Polybar, you gain a powerful, keyboard-friendly menu system — right at your fingertips! 🖱️📜
