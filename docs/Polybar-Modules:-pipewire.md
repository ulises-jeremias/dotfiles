# 🔊 Polybar Module: PipeWire Volume

The **PipeWire Volume module** shows the current volume level and mute state of your default audio sink. It comes in two variants — a clean icon display or a full visual bar.

> [!TIP]
> Designed for users using PipeWire, this module lets you monitor and control sound output directly from Polybar.

---

## 🎛️ Available Variants

### 1. `pipewire`

A minimalist wrapper around the [`internal/pipewire`](https://github.com/polybar/polybar/wiki/Module:-pipewire) module.

Displays:

- Volume percentage (e.g., 75%)
- Mute state

**Example Previews:**

| Muted | 75% | 100% |
|-------|-----|------|
| ![](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/pipewire-muted.jpg?raw=true) | ![](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/pipewire-75.jpg?raw=true) | ![](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/pipewire-100.jpg?raw=true) |

---

### 2. `pipewire-bar`

Wraps the `pipewire` module to show a visual bar-style representation of volume.

**Example Previews:**

| Muted | 75% | 100% |
|-------|-----|------|
| ![](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/pipewire-muted.jpg?raw=true) | ![](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/pipewire-bar-75.jpg?raw=true) | ![](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/pipewire-bar-100.jpg?raw=true) |

---

## ⚙️ Configuration Tips

Basic example for `pipewire`:

```ini
[module/pipewire]
type = internal/pipewire
format-volume = 🔊  %percentage%%
format-muted = 🔇  muted
```

And for `pipewire-bar`:

```ini
[module/pipewire-bar]
type = internal/pipewire
format-volume = <label-volume> <bar-volume>
bar-volume-width = 10
bar-volume-gradient = true
```

> 🧠 Both variants use the same data source — only the format and visualization differ.

---

## ✅ Requirements

- [PipeWire](https://pipewire.org/) properly installed and running
- Polybar with `internal/pipewire` module support (v3.5+)

---

Choose the flavor that fits your setup — whether you prefer a sleek icon or a detailed volume bar. 🔈📊
