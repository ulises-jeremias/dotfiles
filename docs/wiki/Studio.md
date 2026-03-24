# 🎵 Studio — Audio Production Setup

This section covers the **audio production** stack installed by HorneroConfig, including DAW, guitar amp simulation, plugins, and Windows VST bridge support.

> [!TIP]
> The full studio stack is installed automatically via chezmoi on Arch Linux. The install script lives at:
> `home/.chezmoiscripts/linux/run_onchange_before_install-studio.sh.tmpl`

---

## 📁 Managed Config Files

The following REAPER files are tracked by chezmoi under `home/dot_config/REAPER/`:

| File | Description |
|---|---|
| `reaper-fxtags.ini` | FX plugin tags — user-curated organization of all plugins |
| `ProjectTemplates/Basic Vocal Tracking - Linux Scarlett.RPP` | Project template for vocal recording with Scarlett interface |

Everything else in `~/.config/REAPER/` (plugin scan caches, window positions, recent files, license info) is **intentionally excluded** — it is either machine-specific, auto-generated, or sensitive.

---

## 🔊 Audio Server — PipeWire

PipeWire is the foundation of the audio stack. It replaces PulseAudio and JACK while maintaining compatibility with both.

### Installed packages

| Package | Role |
|---|---|
| `pipewire` | Core audio/video server |
| `pipewire-alsa` | ALSA compatibility layer |
| `pipewire-pulse` | PulseAudio compatibility layer |
| `pipewire-jack` | JACK compatibility layer (low-latency audio) |
| `wireplumber` | Session/policy manager for PipeWire |
| `pavucontrol` | GTK volume control GUI |

### Manual install

```sh
sudo pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber pavucontrol
```

### Enable & start

```sh
systemctl --user enable --now pipewire pipewire-pulse wireplumber
```

> [!NOTE]
> On a fresh install, chezmoi handles package installation but you may need to log out and back in for PipeWire to fully replace PulseAudio.

### Verify PipeWire is active

After logging back in, confirm that PipeWire is serving as the PulseAudio backend:

```sh
pactl info
```

Look for this line in the output:

```
Server Name: PulseAudio (on PipeWire)
```

If you see `PulseAudio (on PipeWire)`, everything is wired up correctly. Any other value (e.g., plain `PulseAudio`) means PipeWire is not active — check that `pipewire-pulse` is installed and `wireplumber` is running:

```sh
systemctl --user status pipewire pipewire-pulse wireplumber
```

---

## 🎛️ DAW — REAPER

[REAPER](https://www.reaper.fm/) is a professional, lightweight, and highly customizable Digital Audio Workstation.

### Installed via

```sh
sudo pacman -S reaper
```

### Notes

- On Arch Linux, REAPER uses **PipeWire-JACK** for low-latency audio.
- Configure the audio device under `Options → Preferences → Audio → Device`.
- Set the device to **JACK** and start the session via PipeWire's JACK layer (no separate JACK daemon needed).

---

## 🎸 Guitar Amp Simulation — Guitarix

[Guitarix](https://guitarix.org/) is a virtual guitar amplifier running through the JACK audio system.

### Installed packages

| Package | Role |
|---|---|
| `guitarix` | Virtual guitar amp |
| `gxplugins.lv2` | Guitarix LV2 plugin set |

### Manual install

```sh
sudo pacman -S guitarix gxplugins.lv2
```

### Usage

Guitarix connects to the JACK graph. With PipeWire-JACK active, simply launch:

```sh
guitarix
```

Use `qpwgraph` or `helvum` to visualize and patch audio connections in the PipeWire graph.

---

## 🔌 LV2 / Audio Plugins

A curated set of open-source LV2 plugins is installed for mixing, mastering, and effects.

### Installed packages

| Package | Description |
|---|---|
| `calf` | Studio-quality LV2 effects (EQ, reverb, compressor, chorus…) |
| `lsp-plugins` | Linux Studio Plugins — professional mixing/mastering suite |
| `lsp-plugins-docs` | Documentation for LSP Plugins |
| `x42-plugins` | Collection of LV2 plugins by Robin Gareus (meters, MIDI tools…) |

### Manual install

```sh
sudo pacman -S calf lsp-plugins lsp-plugins-docs x42-plugins
```

---

## 🪟 Windows VST Bridge — yabridge + yabridgectl

[yabridge](https://github.com/robbert-vd-beest/yabridge) lets you run Windows VST2/VST3 plugins natively in Linux via Wine.

### Installed packages (AUR)

| Package | Role |
|---|---|
| `yabridge` | Wine-based VST bridge |
| `yabridgectl` | CLI tool to manage yabridge plugin installations |

### Manual install

```sh
yay -S yabridge yabridgectl
```

### Basic setup

1. Install Wine and your Windows VST plugins as usual.
2. Add plugin directories to yabridgectl:

   ```sh
   yabridgectl add "$HOME/.wine/drive_c/Program Files/Steinberg/VstPlugins"
   ```

3. Sync to generate bridge files:

   ```sh
   yabridgectl sync
   ```

4. Verify the setup:

   ```sh
   yabridgectl status
   ```

> [!TIP]
> Use `yabridgectl sync --prune` to remove bridges for plugins you've uninstalled.

### References

- [yabridge GitHub](https://github.com/robbert-vd-beest/yabridge)
- [Arch Wiki — yabridge](https://wiki.archlinux.org/title/Yabridge)

---

## 📦 Full Package Summary

All packages installed by the studio chezmoi script:

```sh
# Audio server
sudo pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber pavucontrol

# DAW + Guitar amp + LV2 plugins
sudo pacman -S guitarix gxplugins.lv2 reaper calf lsp-plugins lsp-plugins-docs x42-plugins

# Windows VST bridge (AUR)
yay -S yabridge yabridgectl
```

---

## 🆘 Resources

- [REAPER Linux Guide](https://www.reaper.fm/purchase.php)
- [Guitarix Docs](https://guitarix.org/manual/)
- [Arch Wiki — PipeWire](https://wiki.archlinux.org/title/PipeWire)
- [Arch Wiki — JACK](https://wiki.archlinux.org/title/JACK_Audio_Connection_Kit)
- [Linux Studio Plugins](https://lsp-plug.in/)
- [Calf Studio Gear](https://calf-studio-gear.org/)
- [x42 Plugins](https://x42-plugins.com/)
