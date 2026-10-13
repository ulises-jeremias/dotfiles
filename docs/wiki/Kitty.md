# Kitty Terminal

[Kitty](https://sw.kovidgoyal.net/kitty/) is a GPU-accelerated terminal
emulator with tabs, layouts, scripting, and the Kitty graphics protocol. In
HorneroOS, Kitty is the factory terminal choice when installed; Alacritty and
Ghostty are supported alternatives.

> [!NOTE]
> This repository no longer owns Kitty's Hornero defaults. The `hornero-config`
> package supplies the factory configuration and appearance palettes. This
> page documents how Kitty fits into the personal workstation workflow.

## Open Kitty

- **Super + Return** opens the terminal associated with `TerminalEmulator`.
- **Super + E** opens Yazi in a separate window using that same configured
  terminal.
- From the Launcher, search for Kitty when it is installed.

Choose a terminal with:

```sh
horneroctl config default-apps set terminal kitty --yes
horneroctl config default-apps list
```

The supported choices are Kitty, Alacritty, and Ghostty. The Yazi workflow is
documented in [Yazi File Manager](Yazi.md) and the
[HorneroOS terminal guide](https://horneroos.com/docs/applications/terminal/).

## Choose another terminal

Kitty is installed by this workstation profile. Alacritty and Ghostty are
optional: install either from the enabled Arch package source, then open
**Control Center → Settings → Terminal**. The selector lists only supported
emulators found on the machine. You can make the same change from a terminal:

```sh
sudo pacman -S --needed alacritty
horneroctl config default-apps list
horneroctl config default-apps set terminal alacritty --yes
```

For Ghostty, install and select it instead:

```sh
sudo pacman -S --needed ghostty
horneroctl config default-apps set terminal ghostty --yes
```

Use `kitty`, `alacritty`, or `ghostty` as the final command argument to select
the corresponding installed emulator. The selection applies to the desktop's
terminal association and Yazi launch workflow. It does not install or remove
terminal packages.

For consistent colors, keep Hornero's factory terminal configuration supplied
by `hornero-config`; this dotfiles repository intentionally does not shadow
those files. Applying an appearance writes a native palette for each supported
terminal. Custom user configs remain yours to maintain and may need to import
the Hornero palette explicitly. See the linked HorneroOS guide for each
emulator's config path and Yazi preview differences.

## Configuration and appearance

Hornero Config provides factory defaults under `/etc/xdg/kitty/`; Kitty also
reads user configuration from `~/.config/kitty/kitty.conf`. Use
`kitty --debug-config` to inspect which configuration Kitty loads. A personal
user config can override factory settings, so keep any overrides focused and
review them after changing the Hornero appearance.

The factory configuration uses Hornero's terminal palette integration. When
Hornero applies an appearance, its generated Kitty palette is refreshed along
with the other supported terminal formats. The source of truth is HorneroOS
Config, not `kitty-themes`, pywal, or a cloned theme repository.

Do not use the retired instructions from older versions of this page that
clone `kitty-themes`, run `wal`, or edit a dotfiles-owned Kitty config. They
describe a previous workstation setup.

## Useful Kitty features

- **Tabs and layouts** organize local work without adding a multiplexer.
- **`kitten icat image.png`** displays an image using Kitty's graphics
  protocol.
- **`kitty --debug-config`** prints the effective configuration and
  diagnostics.
- **`kitty +list-fonts`** lists fonts available to Kitty.

For remote or resumable terminal sessions, use a multiplexer such as tmux;
Kitty tabs do not persist across SSH connections.

## Troubleshooting

### Hornero colors do not appear

Confirm the selected appearance is applied, then run `kitty --debug-config`
and check for user overrides that replace factory settings. Kitty is optional;
if it is not installed, set the configured terminal to another supported
emulator.

### Yazi image previews are missing

Kitty supports the graphics protocol used by Yazi. Run `ya env` inside the
terminal to check which adapter Yazi detected, then use
`horneroctl apps terminal-file --fix-previews` to inspect preview helpers.

## Upstream references

- [Kitty documentation](https://sw.kovidgoyal.net/kitty/)
- [Kitty configuration reference](https://sw.kovidgoyal.net/kitty/conf/)
- [Kitty graphics protocol](https://sw.kovidgoyal.net/kitty/graphics-protocol/)
