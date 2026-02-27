# Quickshell Parity Checklist

Use this checklist after each substantial shell change.

## Apply and restart

```bash
cd ~/.dotfiles
chezmoi apply --source=. --force
dots-quickshell restart
```

## Hyprland layout and exclusions

- [ ] Left rail does not overlap client windows.
- [ ] Top/bottom bar modes reserve space correctly (no window content under bar).
- [ ] Rounded desktop frame is visible on all monitors.
- [ ] Right-edge notch panels open inside shell frame and do not clip incorrectly.

## Core interaction flow

- [ ] `dots-quickshell ipc launcher toggle` opens/closes launcher.
- [ ] `dots-quickshell ipc dashboard toggle` toggles top control center.
- [ ] `dots-quickshell ipc session toggle` opens right quick actions rail.
- [ ] Scroll over rail triggers configured volume/brightness action.
- [ ] Escape closes temporary overlays/popouts where expected.

## Popouts and side controls

- [ ] Audio/network/bluetooth/battery popouts align to bar position.
- [ ] Popouts never render detached off-screen.
- [ ] OSD appears on right edge and updates for volume/brightness changes.

## Theming and wallpaper pipeline

- [ ] `dots-smart-colors --m3` regenerates `~/.cache/dots/smart-colors/scheme.json`.
- [ ] `dots-quickshell ipc colours reload` updates shell palette live.
- [ ] Wallpaper changes update `~/.local/state/dots/wallpaper/path.txt`.
- [ ] Light/dark mode follows generated scheme and keeps readable contrast.

## Notifications and session

- [ ] Notifications stack at top-right and keep shell style.
- [ ] Session buttons execute expected commands (logout/power/reload).

## Regression checks

- [ ] No duplicate IPC handler warnings at startup.
- [ ] No missing file warnings for battery/lock LEDs on current hardware.
- [ ] No missing dependency crash when optional tools are absent (`ddcutil`, etc.).
