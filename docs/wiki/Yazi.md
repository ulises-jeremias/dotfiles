# Yazi File Manager

Yazi is an optional, keyboard-driven terminal file manager. This page describes
the personal workstation configuration in this repository; it is not a
HorneroOS package or product contract. HorneroOS owns the supported desktop
workflow through `horneroctl` and the configured terminal association.

> [!NOTE]
> Older copies of this page used the retired `dots yazi` command and described
> Kitty-only image previews and pywal color generation. Those instructions no
> longer describe the current setup.

## Launch Yazi

From a terminal, run:

```sh
horneroctl apps terminal-file
horneroctl apps terminal-file --last-dir
horneroctl apps terminal-file --path ~/Projects
horneroctl apps terminal-file --cheatsheet
horneroctl apps terminal-file --fix-previews
```

The `ycd` Zsh helper runs the last-directory workflow and changes the current
shell directory to the directory where Yazi exits:

```sh
ycd
ycd ~/Projects
```

In the Hornero desktop, **Super + E** opens Yazi in a separate window using the
configured terminal. Kitty is the factory terminal; Alacritty and Ghostty are
supported alternatives. Set the terminal with
`horneroctl config default-apps set terminal <kitty|alacritty|ghostty> --yes`.

Thunar's **Open in Yazi** context action also uses the configured terminal and
opens the selected directory. Yazi remains an optional application; install it
before using these workflows. See the [Hornero files guide](https://horneroos.com/docs/applications/files/)
and [terminal guide](https://horneroos.com/docs/applications/terminal/).

## Personal configuration

The configuration lives in `~/.config/yazi/` and is managed by this chezmoi
source:

| File | Purpose |
| --- | --- |
| `yazi.toml` | Columns, sorting, preview bounds, openers, and MIME rules |
| `keymap.toml` | Custom keybindings layered on Yazi defaults |
| `theme.toml` | Dark/light Catppuccin flavors |
| `init.lua` | Personal Lua initialization hooks |

The current setup shows hidden files, sorts directories first, uses Miller
columns, and opens text in `$EDITOR`, media in `mpv`, and other files through
`xdg-open`. `Alt + T` opens the current selection in Thunar. The `g` chords
provide quick navigation to common personal directories; see
[`keymap.toml`](../../home/dot_config/yazi/keymap.toml) for the maintained list.

Hornero Config owns Kitty, Alacritty, and Ghostty factory palettes. The current
Yazi config separately selects Catppuccin Mocha/Latte flavors, so Yazi's UI and
syntax colors do not automatically become a Hornero appearance palette when
the wallpaper changes. Change the Yazi flavor in `theme.toml` if you want a
different Yazi-specific look.

## Image previews

Yazi detects the available image adapter from the running terminal and
environment. Preview support therefore depends on which terminal you selected:

| Terminal / environment | Yazi preview path |
| --- | --- |
| Kitty | Built-in Kitty graphics protocol support |
| Ghostty | Built-in Kitty graphics protocol support |
| Alacritty on Hyprland or Niri | Wayland adapter through Überzug++ (`ueberzugpp`) |
| Other environments | Chafa can provide an ASCII-art fallback when installed |

Yazi does not require all previews to use Kitty's protocol. Diagnose the
current environment with:

```sh
ya env
horneroctl apps terminal-file --fix-previews
```

`ya env` reports the detected terminal and image adapter. For PDF, video, and
other specialized previews, install the helper tools reported by the
diagnostic. The exact set depends on the file type and installed preview
backend. The Arch chezmoi setup installs `ueberzugpp` when Alacritty is
installed; on a manually configured system, install the Arch package
`ueberzugpp` to enable Alacritty's Wayland image previews.

## Troubleshooting

### Images do not preview

Run `ya env` in the same terminal where you launch Yazi and check the selected
adapter. Kitty and Ghostty support Yazi's Kitty graphics path; Alacritty needs
Überzug++ for graphical Wayland previews. `horneroctl apps terminal-file
--fix-previews` reports available and missing helper tools.

### Yazi fails to open from the desktop

Check that Yazi and the selected terminal are installed, then inspect the
selected terminal with `horneroctl config default-apps list`. The desktop
shortcut and Thunar action both depend on the packaged `horneroctl` command.

### Colors do not match the Hornero appearance

The terminal palette follows Hornero's appearance integration; Yazi uses the
Catppuccin flavor selected in `theme.toml`. These are separate color layers.
Select or configure a Yazi flavor that complements the active Hornero palette.

## Upstream references

- [Yazi documentation](https://yazi-rs.github.io/docs/)
- [Yazi image preview support](https://yazi-rs.github.io/docs/image-preview/)
- [Yazi theme configuration](https://yazi-rs.github.io/docs/configuration/theme/)
- [Yazi flavors](https://yazi-rs.github.io/docs/flavors/overview/)
