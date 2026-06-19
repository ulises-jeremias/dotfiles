<div align="center">

<h1>HorneroConfig</h1>

<p>Hyprland + Quickshell desktop on Arch, kept portable with chezmoi.</p>

<a href="https://github.com/ulises-jeremias/dotfiles-template">
  <img src="./static/template-banner.svg" alt="Template Repository Available — start your own setup from this base" width="800"/>
</a>

<a href="https://github.com/ulises-jeremias/dotfiles/tree/x11-openbox-i3wm-xfce4">
  <img src="./static/x11-branch-banner.svg" alt="Classic X11 stack (i3, OpenBox, XFCE4) lives in the x11 branch" width="800"/>
</a>

<a href="https://github.com/ulises-jeremias/dotfiles/tree/wayland-hyprland-waybar-rofi-eww">
  <img src="./static/wayland-legacy-branch-banner.svg" alt="Previous Wayland stack (Hyprland + Waybar + Rofi + EWW) lives in the wayland-legacy branch" width="800"/>
</a>

[![AUR Stable](https://img.shields.io/aur/version/dots-stable?label=AUR+Stable&style=flat-square)](https://aur.archlinux.org/packages/dots-stable)
[![AUR Development](https://img.shields.io/aur/version/dots-git?label=AUR+Git&style=flat-square)](https://aur.archlinux.org/packages/dots-git)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)
[![Mentioned in Awesome Arch](https://awesome.re/mentioned-badge.svg)](https://github.com/PandaFoss/Awesome-Arch)

</div>

---

<img alt="HorneroConfig collage" align="right" width="380px" src="./static/collage.png"/>

The name comes from the *hornero*, an Argentinian bird that builds its own clay nest one piece at a time. That's what this repo is: a nest I take with me when I jump machines.

It's the setup I actually run day-to-day — Hyprland on Wayland with a Quickshell-based bar, launcher, dashboard, and lockscreen; Kitty + Zsh in the terminal; rices that swap the whole look in one command; and a wallpaper pipeline that regenerates colors for every running surface.

<br clear="right"/>

## Stack

- **Compositor** — [Hyprland](https://hyprland.org)
- **Shell** — [Quickshell](https://quickshell.org) (bar, launcher, dashboard, notifications, AI chat)
- **Terminal** — [Kitty](https://sw.kovidgoyal.net/kitty) + [Zsh](https://zsh.org) with [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- **Lockscreen** — [Hyprlock](https://github.com/hyprwm/hyprlock)
- **Files** — [Yazi](https://yazi-rs.github.io)
- **Config manager** — [chezmoi](https://chezmoi.io) (everything in `home/` is templated)
- **Rices** — ~20 themes wired to Material Design 3 colors via wpgtk

## Install

One-line install on a fresh Arch:

```bash
sh -c "$(curl -fsSL "https://github.com/ulises-jeremias/dotfiles/blob/main/scripts/install_dotfiles.sh?raw=true")"
```

From the AUR:

```bash
yay -S dots-stable      # tagged releases
yay -S dots-git         # main branch
```

The installer wires up [Chaotic-AUR](https://aur.chaotic.cx/) so Hyprland + Quickshell pull from prebuilt binaries instead of compiling from source.

If you already use chezmoi:

```bash
chezmoi init --apply ulises-jeremias --source ~/.dotfiles
```

Or clone and run the script directly:

```bash
git clone https://github.com/ulises-jeremias/dotfiles ~/.dotfiles
~/.dotfiles/install.sh
```

## Gallery

<details>
<summary>Screenshots</summary>

<div align="center">

Dark theme:

<img src="./static/screen.png" alt="Dark theme" width="800px"/>

Light theme:

<img src="./static/screen-2.jpg" alt="Light theme" width="800px"/>

Launchers:

<img src="./static/screenshot-launchpad.png" alt="App launcher" width="400px"/> <img src="./static/screenshot-spotlight-dark.png" alt="Spotlight (dark)" width="400px"/>

</div>

</details>

## Rices and wallpapers

A *rice* is a self-contained theme: colors, GTK theme, icon set, Hyprland animations, kitty opacity, and a folder of matching wallpapers. Each one lives under `home/dot_local/share/dots/rices/<name>/`.

```bash
dots rice list
dots rice apply neon-city
dots appearance apply flowers   # rice + wallpaper in one shot
```

Wallpapers come from two places. Each rice ships its own `backgrounds/` for theme-coherent picks. A second pool of generic wallpapers lives in `home/dot_local/share/dots/wallpapers/curated/` and gets linked to `~/Pictures/Wallpapers` on `chezmoi apply` — that's what the Quickshell launcher feeds from when you ask for a random one.

Changing the wallpaper with `dots-wallpaper-set` runs the full pipeline: wpgtk derives a palette, `dots-smart-colors` materialises Material 3 tokens, and Quickshell reloads every surface over IPC. The wiki has the [full diagram](https://github.com/ulises-jeremias/dotfiles/wiki/Smart-Colors-System).

## Scripts

Around 100 helpers live behind a single `dots` entrypoint:

```bash
dots --list
dots sysupdate
dots smart-colors --generate
dots security-audit
```

`dots-eject` extracts a single config so you can use it standalone; `dots-update` syncs your local copy with upstream. The full reference is in the [wiki](https://github.com/ulises-jeremias/dotfiles/wiki/Dots-Scripts).

## Try it without breaking your machine

There's a Vagrant playground for exactly this:

```bash
./bin/play                        # boot the VM
./bin/play --provision hyprland   # apply HorneroConfig inside it
./bin/play --remove               # tear it down
```

Details in [`docs/Testing-Strategy.md`](docs/Testing-Strategy.md).

## Branches

- `main` — Wayland with Hyprland + Quickshell (this README).
- [`x11-openbox-i3wm-xfce4`](https://github.com/ulises-jeremias/dotfiles/tree/x11-openbox-i3wm-xfce4) — the older X11 stack.
- [`wayland-hyprland-waybar-rofi-eww`](https://github.com/ulises-jeremias/dotfiles/tree/wayland-hyprland-waybar-rofi-eww) — Wayland before the Quickshell migration.

## Docs

- [`AGENTS.md`](AGENTS.md) — how AI agents should navigate the repo.
- [`docs/Architecture-Philosophy.md`](docs/Architecture-Philosophy.md) — why things are split the way they are.
- [`docs/adrs/`](docs/adrs/) — architecture decisions, dated.
- [Wiki](https://github.com/ulises-jeremias/dotfiles/wiki) — user-facing setup, rices, smart colors, Quickshell internals.

## Credits

The Quickshell side was adapted from [caelestia-dots/shell](https://github.com/caelestia-dots/shell) by [@soramane](https://github.com/soramane) — UI/UX, shell architecture, and the C++ plugin scaffolding all started there. The original GPL-3.0 license is preserved in `home/dot_config/quickshell/LICENSE`.

The rest of the repo is MIT — see [LICENSE](LICENSE).
