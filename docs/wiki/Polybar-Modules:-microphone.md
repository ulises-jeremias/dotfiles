# 🎙️ Polybar Module: Microphone

The **Microphone module** is a custom script-based Polybar module that displays the mute/unmute status of your system microphone in real-time.

> [!TIP]
> This module is useful for keeping track of your microphone state during meetings, recordings, or voice calls — right from your status bar.

---

## 🧩 How It Works

This module is built using the `custom/script` Polybar type and is powered by the `dots microphone` script.

It detects the microphone's mute state and updates its icon accordingly. It refreshes on a set interval and can be configured to toggle the mic on click.

---

## 📸 Visual Indicators

| Muted | Unmuted |
|-------|---------|
| ![Muted](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/microphone-muted.jpg?raw=true) | ![Unmuted](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/microphone-unmuted.jpg?raw=true) |

---

## ⚙️ Configuration Example

```ini
[module/microphone]
type = custom/script
exec = dots microphone
click-left = dots microphone --toggle
interval = 2
```

> [!TIP]
> Icons and refresh intervals can be adjusted to suit your theme or responsiveness needs.

---

## ✅ Requirements

- The `dots microphone` script (included in the dotfiles setup)
- Microphone control tools (like `pamixer`, `pactl`, or `amixer`) as dependencies

---

## 🎨 Customization Tips

- Change the icons used for muted/unmuted states in the `dots microphone` script
- Use hover or tooltip support (if available in your Polybar fork) for more context

---

Stay aware of your mic state at all times — avoid the classic “you’re muted!” moment 🎤
