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
- The workstation configuration uses Hornero Shell's Dashboard for its
  system overview; no third-party compositor plugin is required at startup.

## Configuration format status

The only Hyprland configuration is the Lua entrypoint `hyprland.lua`, which
loads the modules in `hyprland.lua.d/` (monitors, autostart, environment,
input, gestures, layout, keybindings, window-rules, animations, smart-colors,
static). The legacy hyprlang `hyprland.conf` + `hyprland.conf.d/` tree was
retired; do not recreate it. See the
[Lua migration architecture](Hyprland-Lua-Architecture.md) for the module map
and validation notes.

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

Window swallowing is enabled for the Hornero-supported Kitty, Alacritty, and
Ghostty terminals. Selecting one of these in Control Center therefore keeps
the same terminal-to-application workflow; the matcher lives in
`home/dot_config/hypr/hyprland.lua.d/static.lua`.

For user-facing shortcuts, see the [HorneroOS shortcuts guide](https://horneroos.com/docs/desktop/shortcuts/). For themes and wallpaper colors, see the [Appearance guide](https://horneroos.com/docs/desktop/appearance/).
