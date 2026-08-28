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

## 🧩 Modular Config Layout

`hyprland.conf` is a thin entrypoint that sources focused fragments from
`~/.config/hypr/hyprland.conf.d/`:

| Fragment            | Controls                                                |
| ------------------- | ------------------------------------------------------- |
| `monitors.conf`     | Output resolution, position, scaling                    |
| `autostart.conf`    | Startup services and apps                               |
| `environment.conf`  | Environment variables (IME, cursors, XDG portals)       |
| `input.conf`        | Keyboards, mice, touchpads, gestures                    |
| `layout.conf`       | Tiling gaps, borders, decorations                       |
| `keybindings.conf`  | All keybinds (see `dots keyboard-help`)                 |
| `window-rules.conf` | Per-window rules (floating, opacity, workspace pinning) |
| `animations.conf`   | Active animation profile                                |
| `colors.conf`       | Compositor colors and shadows                           |
| `plugins.conf`      | Plugin loading (e.g. ScrollOverview)                    |

### Animation Profiles

`animations.conf` is swappable — six profiles ship with the repo:

```sh
dots hypr-animations --list            # default cozy cyberpunk nature minimal vaporwave
dots hypr-animations --set=cozy        # slow, bouncy, gentle
dots hypr-animations --next            # cycle profiles
```

The selection persists and survives reloads (`--restore` re-applies it
after `hyprctl reload`).

### Keybindings Reference

`dots keyboard-help` prints every keybind grouped by section, with
filtering:

```sh
dots keyboard-help --category "Media"    # substring match on section
dots keyboard-help --search "workspace"  # search key or action
```

### Screen-Specific Config

`monitors.conf` supports per-monitor overrides; the Quickshell layer also
supports per-screen bar layouts via `bar.perScreen` — see
[Quickshell Shell](Quickshell-Shell).

---

## 🔧 Pro Tips

- Add compositor-specific autostart scripts
- Use Quickshell as the primary shell (bar/launcher/dashboard/control center)
- Keep launcher and power keybinds routed through `dots-quickshell ipc ...`
- Use `chezmoi diff` to preview config changes

---

## 🆘 Need Help?

If you run into issues or want to go deeper:

- Check the [Hyprland Wiki](https://wiki.hyprland.org/)
- Visit the [Dotfiles Discussions](https://github.com/ulises-jeremias/dotfiles/discussions)

Customizing your compositor is one of the best ways to boost your productivity and tailor your desktop to your style — make it yours! 🎨
