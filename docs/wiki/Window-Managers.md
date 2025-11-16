# 🪟 Hyprland Configuration Guide

This guide provides an overview of how to customize Hyprland, the dynamic tiling Wayland compositor used in this dotfiles setup.

> [!TIP]
> Everything is fully customizable — from layout and keybindings to appearance and startup behavior. All configurations are version-controlled using `chezmoi`, making it easy to manage and sync.

---

## 🧱 General Customization Workflow

The general process is:

1. Locate the config directory
2. Edit files with `chezmoi edit`
3. Apply changes with `chezmoi apply`
4. Restart Hyprland or reload configurations

---

## 🌊 Hyprland Configuration

📁 **Config Path**: `~/.config/hypr`

The Hyprland configuration controls:

- Keybindings
- Window rules and behavior
- Workspace layout
- Animations and effects
- Wayland-specific settings

To edit:

```sh
chezmoi edit ~/.config/hypr/hyprland.conf
chezmoi apply
```

For more info, check the [Hyprland documentation](https://wiki.hyprland.org/).

---

## 🔧 Pro Tips

- Add compositor-specific autostart scripts
- Use Waybar for status bar integration
- Leverage Rofi for application launching
- Use `chezmoi diff` to preview config changes

---

## 🆘 Need Help?

If you run into issues or want to go deeper:

- Check the [Hyprland Wiki](https://wiki.hyprland.org/)
- Visit the [Dotfiles Discussions](https://github.com/ulises-jeremias/dotfiles/discussions)

Customizing your compositor is one of the best ways to boost your productivity and tailor your desktop to your style — make it yours! 🎨
