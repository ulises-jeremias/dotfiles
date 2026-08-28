# 🔊 Audio Devices Guide

HorneroConfig ships a PipeWire-first audio stack driven by the Quickshell
**Audio** service, with `pamixer` and `playerctl` as the CLI layer.

---

## 🧱 The Stack

| Layer           | Component                       | Role                                            |
| --------------- | ------------------------------- | ----------------------------------------------- |
| Server          | PipeWire                        | Low-latency capture/playback, Bluetooth (bluez) |
| Session manager | WirePlumber                     | Device routing and profiles                     |
| Shell           | Quickshell `services/Audio`     | Volume, mute, devices, OSD popouts              |
| CLI             | `pamixer`, `pactl`, `playerctl` | Scripted control (media keybinds)               |

> [!TIP]
> `dots dependencies` verifies PipeWire is installed as part of the stack.

---

## ⌨️ Keybinds (Media Keys)

| Keys                            | Action                |
| ------------------------------- | --------------------- |
| `XF86AudioRaiseVolume`          | Volume +5%            |
| `XF86AudioLowerVolume`          | Volume -5%            |
| `XF86AudioMute`                 | Mute output           |
| `XF86AudioMicMute`              | Mute microphone       |
| `XF86AudioPlay/Pause/Next/Prev` | MPRIS via `playerctl` |

These map to `pamixer` / `playerctl` calls in
`hyprland.conf.d/keybindings.conf` — edit them with
`chezmoi edit ~/.config/hypr/hyprland.conf.d/keybindings.conf`.

---

## 🖥️ Selecting Devices

- **Bar**: click the speaker status icon → the audio popout lists every
  output/input device; pick one and drag the volume slider
- **Click "Open settings"** in that popout → detaches the full audio panel
- **CLI**:

```bash
pactl list sinks short              # outputs
pactl set-default-sink <name>       # switch default
pamixer --list-sources              # microphones
pamixer --default-source -i 10      # mic +10%
```

---

## 🎚️ OSD Behaviour

Volume/mic/brightness changes raise the on-screen display
(`modules/osd`) automatically; it hides after `Config.osd.hideDelay`
(configurable in the control center → On-Screen Display).

---

## 🌈 Extras

- The **cava visualizer** (`background.visualiser`) feeds from the same
  PipeWire graph — enable it per preset or via
  `dots-quickshell config set background.visualiser.enabled true`
- **Now Playing** widgets (dashboard Media tab, lockscreen) read MPRIS
  metadata through `playerctl`

---

## 🆘 Troubleshooting

- No sound after suspend: `systemctl --user restart wireplumber`
- Bluetooth headphones missing: ensure `bluez` + `bluez-utils` (the
  bluetooth install fragment covers them) and `rfkill unblock bluetooth`
- Device not defaulting: check `pactl get-default-sink` vs your Desktop
  profile in the audio popout
