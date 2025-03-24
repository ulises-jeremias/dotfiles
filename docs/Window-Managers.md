# 🪟 Window Managers Configuration Guide

This guide provides an overview of how to customize the supported window managers in this dotfiles setup: **i3**, **Openbox**, and **XFCE4**.

> [!TIP]
> Everything is fully customizable — from layout and keybindings to appearance and startup behavior. All configurations are version-controlled using `chezmoi`, making it easy to manage and sync.

---

## 🧱 General Customization Workflow

Regardless of the window manager, the general process is:

1. Locate the config directory
2. Edit files with `chezmoi edit`
3. Apply changes with `chezmoi apply`
4. Restart your WM or re-source configurations (if applicable)

---

## 🔲 i3 Window Manager

📁 **Config Path**: `~/.config/i3`

The i3 configuration controls:

- Keybindings
- Workspace layout
- Application launching
- Status bar integration (e.g., Polybar)

To edit:

```sh
chezmoi edit ~/.config/i3/config
chezmoi apply
```

For more info, check the [i3 customization documentation](i3).

---

## ⚫ Openbox Window Manager

📁 **Config Path**: `~/.config/openbox`

Openbox is a lightweight and highly customizable WM. You can tweak:

- Window behavior and focus model
- Desktop menus
- Keybindings
- Autostart applications

To edit configs:

```sh
chezmoi edit ~/.config/openbox/rc.xml
chezmoi apply
```

GUI alternative: Use `obconf` for quick edits to appearance and themes.

Explore more in the [Openbox customization documentation](Openbox).

---

## 🖥️ XFCE4 Desktop Environment

📁 **Config Path**: `~/.config/xfce4`

XFCE4 is a full-featured desktop environment. Customizations here are **global** and apply across all your installed WMs.

Use the built-in Settings Manager:

```sh
xfce4-settings-manager
```

From there, configure:

- Panels
- Keybindings
- Appearance
- Power management
- Preferred apps

You can also edit config files manually via chezmoi:

```sh
chezmoi edit ~/.config/xfce4 --source ~/.dotfiles
chezmoi apply
```

More details in the [XFCE4 customization documentation](Xfce4).

---

## 🔧 Pro Tips

- Add WM-specific autostart scripts or shared components
- Mix and match (e.g., run Openbox with Polybar and Rofi)
- Use `chezmoi diff` to preview config changes

---

## 🆘 Need Help?

If you run into issues or want to go deeper:

- Check the documentation for each WM: [i3](i3), [Openbox](Openbox), [XFCE4](Xfce4)
- Visit the [Dotfiles Discussions](https://github.com/ulises-jeremias/dotfiles/discussions)

Customizing your window manager is one of the best ways to boost your productivity and tailor your desktop to your style — make it yours! 🎨
