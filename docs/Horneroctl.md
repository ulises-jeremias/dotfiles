# horneroctl Dependency

> **Required dependency** for the `dots-*` script ecosystem.
> Migration complete (#294–#302): deleted wrappers were remapped to native
> verbs; the retained `dots-*` scripts are thin UIs, required backends, or
> engines with no native equivalent (see table below).

## What it is

[horneroctl](https://github.com/HorneroOS/hornero) is the Hornero OS
system CLI. Deleted `dots-*` wrappers now resolve to native verbs;
callers (keybindings, autostart, `.desktop` entries, QML) invoke
`horneroctl` directly. Things break when `horneroctl` is absent —
install it first.

## Install

```sh
git clone https://github.com/HorneroOS/hornero
cd hornero/cli
./make.vsh build-cli
install -m0755 horneroctl ~/.local/bin/horneroctl
```

The installer (`scripts/install_dotfiles.sh`) prints a warning — not an
error — when `horneroctl` is missing from `PATH`.

## `HORNEROCTL_BIN` override

Retained shims resolve the binary through the `HORNEROCTL_BIN`
environment variable, defaulting to `horneroctl` on `PATH`:

```sh
# Use a custom build instead of the one on PATH.
export HORNEROCTL_BIN="$HOME/src/hornero/horneroctl"
```

Unset or empty `HORNEROCTL_BIN` means plain `horneroctl` from `PATH`.

## Migration map (deleted → native)

| Deleted wrapper | Native replacement |
|---|---|
| `dots-wallpaper-set` / `-current` / `dots-wal-reload` | `horneroctl wallpaper set <path> --yes` / `current` / `reload --yes` |
| `dots-screenshooter` / `dots-clipboard` / `dots-recorder` | `horneroctl capture screenshot --yes` / `clipboard` / `record … --yes` |
| `dots-battery-monitor` / `dots-brightness` / `dots-microphone` / `dots-check-network` | `horneroctl hardware battery monitor` / `brightness …` / `mic toggle --yes` / `network status` |
| `dots-hypr-layout` / `dots-hypr-animations` / `dots-next-workspace` | `horneroctl hypr layout …` / `animations …` / `workspace next\|prev --yes` |
| `dots-checkupdates` / `dots-updates` | `horneroctl package check` / `updates` (+ `upgrade --yes` for the dead `dots-sysupdate` tile) |
| `dots-hyprlock-theme` | `horneroctl appearance hyprlock --yes` (byte-identical output) |
| `dots-performance` / `dots-keyboard-layout` / `dots-security-audit` | `horneroctl apps performance …` / `hardware keyboard layout` / `apps audit [--fix\|--report\|--json]` |
| `dots-backup`, `dots-launcher`, `dots-toggle`, `dots-file-manager`, `dots-keyboard-settings`, `dots-weather-info`, `dots-hyprland-plugins`, `dots-dependencies` (#294/#295) | `horneroctl backup` / `apps launch` / `apps toggle` / `apps files` / `hardware keyboard settings` / `apps weather` / `hypr plugins` / `package deps` |

Run `dots --list` for the live registry: entries marked `RETIRED`
point at their native replacement.

## Retained wrappers (not useless)

| Wrapper | Why it stays |
|---|---|
| `dots-appearance`, `dots-color-scheme`, `dots-gtk-theme`, `dots-m3-colors` | Deep Quickshell integration; repo tests assert the QML call sites; no native palette store yet |
| `dots-accent-override` | Paired with `dots-color-scheme` (reads the `dots/*` seed path; native writes canonical-first) |
| `dots-night-mode` | Multi-backend toggle orchestrator (redshift/gammastep/wlsunset + state files) |
| `dots-smart-colors` | Palette engine owning the `dots/*` cache contract consumed by app configs (hypr/kitty/waybar); native writes `hornero/*` |
| `dots-theme-selector`, `dots-keyboard-help` | Picker/router UI (quickshell forward + terminal fallback) |
| `dots-hypr-monitors`, `dots-power-menu`, `dots-performance-mode` | Interactive menus with no native menu verb (set-ops already delegate) |
| `dots-lockscreen` | Lock-effect image pipeline (only bare `--lock` has a native counterpart) |
| `dots-default-apps` | Settings GUI (native `config default-apps set` stays a deferral) |
| `dots-git-notify`, `dots-yazi`, `dots-snappy-switcher` | Required native backends (`apps git-status` / `terminal-file` / `switcher` fail without them) |
| `dots-quickshell`, `dots-settings-gui` | Shell infra: preset apply, `config set`, control-center bridge |
| `dots-config-manager` | `--diff` / `--auto` / `--cleanup` (snapshots already delegate) |
