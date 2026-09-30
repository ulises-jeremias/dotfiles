# Quickshell Parity Checklist

Use this checklist after each substantial shell change.

Contract C (HorneroOS/hornero#81): HorneroOS/shell is the authoritative
shell implementation and the installed `~/.config/quickshell` tree is the
runtime. Dotfiles keeps no shell mirror and chezmoi ignores the installed
tree, so a normal apply can never downgrade it.

## Update the installed shell and restart

Update the installed tree from HorneroOS/shell main (out of band from
chezmoi), verify the contract, then restart:

```bash
./scripts/check-shell-contract.sh
horneroctl shell restart --yes
```

Never `chezmoi apply` a shell tree into place: there is no shell source
left in this repo to apply, and the ignore guard exists to keep it
that way.

## Hyprland layout and exclusions

- [ ] Left rail does not overlap client windows.
- [ ] Top/bottom bar modes reserve space correctly (no window content under bar).
- [ ] Attached and dock modes reserve their visible thickness; floating mode overlays client space.
- [ ] Rounded desktop frame is visible for Hornero Left/Right and absent for frameless presets.
- [ ] Frameless presets reserve zero pixels on non-bar edges.
- [ ] Right-edge notch panels open inside their usable shell area and do not clip incorrectly.

## Core interaction flow

- [ ] `horneroctl shell ipc -- call launcher toggle` opens/closes launcher.
- [ ] `horneroctl shell ipc -- call dashboard toggle` toggles top control center.
- [ ] `horneroctl shell ipc -- call drawers toggle session` opens right quick actions rail.
- [ ] Scroll over rail triggers configured volume/brightness action.
- [ ] Escape closes temporary overlays/popouts where expected.

## Popouts and side controls

- [ ] Audio/network/bluetooth/battery popouts align to bar position.
- [ ] Top/bottom popouts use horizontal geometry rather than a mirrored side-rail shape.
- [ ] Popouts never render detached off-screen.
- [ ] OSD appears on right edge and updates for volume/brightness changes.

## Theming and wallpaper pipeline

- [ ] `horneroctl appearance colors generate --m3 --yes` regenerates `~/.cache/dots/smart-colors/scheme.json`.
- [ ] `horneroctl shell ipc -- call colours reload` updates shell palette live.
- [ ] Wallpaper changes update `~/.local/state/dots/wallpaper/path`.
- [ ] Light/dark mode follows generated scheme and keeps readable contrast.

## Notifications and session

- [ ] Notifications stack at top-right and keep shell style.
- [ ] Session buttons execute expected commands (logout/power/reload).

## Regression checks

- [ ] No duplicate IPC handler warnings at startup.
- [ ] No missing file warnings for battery/lock LEDs on current hardware.
- [ ] No missing dependency crash when optional tools are absent (`ddcutil`, etc.).
- [ ] Applying presets in different orders produces the same final owned fields.
- [ ] Config save and shell restart preserve bar position, style, floating margin, and frame state.
- [ ] Quickshell is never restarted while the session is locked.
