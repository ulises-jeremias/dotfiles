# horneroctl Dependency

> **Required dependency** for the Hornero scripts.
> Migration complete (#294–#305): all wrappers were remapped to native
> verbs and deleted; only `dots-settings-gui` and `dots-snappy-switcher`
> stay as required native backends (see table below).

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

The retained backends resolve the binary through the `HORNEROCTL_BIN`
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
| `dots-appearance`, `dots-color-scheme`, `dots-gtk-theme`, `dots-m3-colors`, `dots-smart-colors`, `dots-accent-override` | `horneroctl appearance …` / `scheme regenerate` / `gtk …` / `colors m3` / `colors generate` |
| `dots-night-mode` | `horneroctl appearance night-mode …` |
| `dots-theme-selector`, `dots-keyboard-help` | `horneroctl config gui --pane appearance` / `hardware keyboard keys` |
| `dots-hypr-monitors`, `dots-power-menu`, `dots-performance-mode` | `horneroctl hypr monitors status` / shell session drawer / `apps performance mode` |
| `dots-lockscreen` | `horneroctl power lock --yes` (bare hyprlock fallback) |
| `dots-default-apps`, `dots-config-manager` | `horneroctl config default-apps list` / `snapshot create --dry-run` |
| `dots-git-notify`, `dots-yazi` | `horneroctl apps git-status` / `terminal-file` |
| `dots-quickshell` | `horneroctl shell …` / `preset apply` / edit `~/.config/hornero/shell.json` |
| `dots` (dispatcher) | `horneroctl --help` |

Run `horneroctl --help` for the live registry.

## Retained wrappers (not useless)

| Wrapper | Why it stays |
|---|---|
| `dots-settings-gui` | Required backend: `horneroctl config gui` delegates to it |
| `dots-snappy-switcher` | Required backend: `horneroctl apps switcher apply-theme*` delegates to it |
