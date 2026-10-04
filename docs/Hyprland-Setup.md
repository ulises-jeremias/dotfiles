# Hyprland workstation notes

This personal source configures Hyprland around Hornero Shell. Hornero Shell
owns launcher, bars, Dashboard, session controls, notifications, and Control
Center. `horneroctl` owns supported lifecycle and compositor operations.

## Configuration ownership

- User compositor files are managed under `~/.config/hypr/`.
- Hornero Shell configuration and presets come from the installed
  HorneroOS packages; chezmoi does not mirror the Shell tree.
- Appearance packs are owned by Hornero Config. Wallpaper media may be
  provided separately under `~/.local/share/hornero/wallpapers/`.
- Optional compositor plugins require a compatible Hyprland release and
  installed build tools; check `horneroctl hypr plugins --help` before
  changing them.

## Useful entry points

```sh
horneroctl doctor
horneroctl shell status
horneroctl shell --help
horneroctl hypr --help
horneroctl appearance --help
```

Use the Shell's Control Center for common settings. Use `horneroctl` for
supported command-line operations and `hyprctl` only for compositor-level
diagnostics or documented configuration reloads.

For user-facing shortcuts, see the [HorneroOS shortcuts guide](https://hornero-os.vercel.app/docs/desktop/shortcuts/). For themes and wallpaper colors, see the [Appearance guide](https://hornero-os.vercel.app/docs/desktop/appearance/).
