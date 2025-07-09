# 🪟 Openbox Configuration Guide

Openbox is a lightweight and highly configurable window manager that provides a simple yet powerful environment for managing windows in your desktop. With its flexibility and extensive customization options, Openbox allows you to create a personalized and efficient workflow.

> [!TIP]
> Everything in this setup is fully customizable. Whether it's the appearance, keybindings, or behavior — you have full control. All configuration files live in your dotfiles repo, versioned with chezmoi, and changes can be applied with `chezmoi apply`.

---

## 🗂️ Configuration Files Location

Your Openbox configuration files are located at:

```sh
~/.config/openbox
```

These files are managed via chezmoi. To edit them:

```sh
chezmoi edit ~/.config/openbox --source ~/.dotfiles
```

After editing, apply your changes with:

```sh
chezmoi apply
```

And restart Openbox for the modifications to take effect.

---

## 🔧 What You Can Customize

- **Window behavior** (e.g., focus models, stacking order)
- **Keybindings** (move, resize, switch windows, custom shortcuts)
- **Menus** (right-click desktop menus, application launchers)
- **Autostart applications** (programs that run when Openbox starts)
- **Appearance and theming**

### 📂 Key Configuration Files

- `rc.xml`: Main configuration file for keybindings and window behavior
- `menu.xml`: Right-click desktop menu definition
- `autostart`: List of applications to run on Openbox startup

> [!TIP]
> Use `chezmoi diff` to preview changes before applying.

---

## 🖼️ Graphical Configuration with `obconf`

To simplify configuration, you can use **`obconf`**, a GUI configuration tool for Openbox.

If it's available in your package manager, install it:

```sh
# Example for Arch Linux
sudo pacman -S obconf
```

Then launch it:

```sh
obconf
```

You can adjust:

- Themes and styles
- Window decorations
- Mouse behavior
- Desktops and workspaces

![Openbox Config](https://github.com/ulises-jeremias/dotfiles/blob/main/docs/images/obconf.jpg?raw=true)

> ✨ Great for quick changes without editing XML files.

---

## 🧩 Integration & Tips

- Use in combination with **Polybar**, **Rofi**, and **Zsh** for a full personalized desktop experience
- You can dynamically generate menus or autostart entries via scripts
- Combine with tools like `xrandr`, `feh`, or `picom` for wallpapers, transparency, and compositor support

---

## 🆘 Need Help?

If you get stuck or want to learn more:

- Refer to [Openbox documentation](http://openbox.org/wiki/Help:Configuration)
- Ask questions in the [Discussions](https://github.com/ulises-jeremias/dotfiles/discussions) section

Unleash the power of Openbox and create a unique desktop environment that reflects your style and optimizes your daily tasks!
