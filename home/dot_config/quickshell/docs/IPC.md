# IPC surface — HorneroOS/shell

Quickshell IPC (`qs ipc call <target> <fn> [args…]`). Targets are declared
with `IpcHandler` in the listed QML files. This document is the contract
other HorneroOS components script against; renames must update
`tests/test_ipc_mapping.py` in the same commit.

## Services

| Target | Defined in | Functions |
|---|---|---|
| `wallpaper` | `services/Wallpapers.qml` | `get()`, `set(path)`, `list()` |
| `appearance` | `services/ThemePipeline.qml` | `applyTheme(id, wallpaper)`, `reload()`, `setWallpaper(path)` |
| `mpris` | `services/Players.qml` | `getActive(prop)`, `list()`, `play()` (+ pause/next/previous per file) |
| `notifs` | `services/Notifs.qml` | `clear()`, `isDndEnabled()`, `toggleDnd()` (+ per-file extras) |
| `idleInhibitor` | `services/IdleInhibitor.qml` | `isEnabled()`, `toggle()`, `enable()` (+ `disable()` per file) |
| `hypr` | `services/Hypr.qml` | `refreshDevices()`, `cycleSpecialWorkspace(direction)`, `listSpecialWorkspaces()` |
| `gameMode` | `services/GameMode.qml` | `isEnabled()`, `toggle()`, `enable()`, `disable()` |
| `colours` | `services/Colours.qml` | `reload()`, `mode()`, `flavour()` |
| `brightness` | `services/Brightness.qml` | `get()`, `getFor(query)`, `set(value)` (+ `setFor` per file) |

## Shell chrome

| Target | Defined in | Functions |
|---|---|---|
| `drawers` | `modules/Shortcuts.qml` | `toggle(drawer)`, `list()`, `state(drawer)` |
| `controlCenter` | `modules/Shortcuts.qml` | `open([pane])` |
| `welcome` | `modules/Shortcuts.qml` (controller `modules/welcome/Welcome.qml`) | `open([page])`, `close()`, `status()` |
| `toaster` | `modules/Shortcuts.qml` | `info/success/warn/error(title, message, icon)` |
| `picker` | `modules/areapicker/AreaPicker.qml` | `open()`, `openFreeze()` (+ close variants per file) |
| `lock` | `modules/lock/Lock.qml` | `lock()`, `unlock()` |
| `companion` | `modules/companion/CompanionHost.qml` | `summon()`, `hide()`, `toggle()`, `say(text, timeoutMs)`, `tip()`, `play(animation)`, `setState(state)`, `setSkin(skin)`, `resetPosition()`, `status()` |
| `debug` | `modules/drawers/Drawers.qml` | `borders()`, `dump()` (debug only) |

Drawer names accepted by `drawers toggle` are the boolean keys of
`Visibilities` for the active monitor (e.g. `launcher`, `dashboard`,
`controlCenter`, `session`, `sidebar`, `utilities`, `layoutPicker`);
`drawers list` prints them, `drawers state <name>` prints `true`/`false`
(`""` for an unknown name). Unknown names log `[IPC] Drawer "…" does not
exist` and are ignored. Toggles for `launcher`/`session`/`dashboard` are
suppressed while a fullscreen window has focus.

`controlCenter open [pane]` deep-links into a Control Center pane
(validated against the pane registry: an unknown pane logs a warning
and opens the default pane, never crashes). `welcome open [page]`
opens the Welcome Center (`start`, `navigate`, `shell`, `workspaces`,
`personalize`, `tools`, `system`, `learn`; unknown pages open `start`
with a warning); `welcome close()` closes it; `welcome status()`
prints JSON (`{"open": bool, "page": string, "showOnLogin": bool}`).
Every opening records the session sighting, so a shell reload in the
same session never auto-reopens. The Welcome window state
itself lives in HorneroOS/hornero (`horneroctl welcome …`); see
`docs/adr/001-welcome.md`.

`companion say <text> [timeoutMs]` shows a timed speech bubble (280
chars max, 6 s default); `tip` shows the next Welcome-linked tip and
also returns it; `play <animation>` one-shots a known animation
(`idle`/`walk`/`fly`/`greet`, unknown names warn and play `idle`);
`setState <state>` requests a behavior state (unknown states warn and
are ignored) including the reserved future assistant states, which
only change the animation — no backend exists behind them;
`setSkin` keeps the current skin on unknown names; `status()` prints
JSON (`{"enabled", "state", "skin", "animation", "suppressed",
"bubbleOpen"}`). See `docs/COMPANION.md`.

## Global shortcuts

`modules/Shortcuts.qml` wires `CustomShortcut` (`components/misc/`,
a `GlobalShortcut`) entries for bar, launcher, dashboard, utilities, etc.
Compositor-side bindings live in HorneroOS/config, not here.

## Process (outbound) contracts

The shell also *spawns* processes; the stable outbound contracts are:

- Appearance (native first, see `docs/NATIVE-APPEARANCE.md`):
  `gsettings set/get org.gnome.desktop.interface …` (via
  `services/GtkSettings.qml`) and the native `ImageAnalyser` plugin
  (`dominantColour`/`luminance`, via `services/WallpaperAnalysis.qml` and
  `Colours.wallLuminance`/`wallDominantColour`).
- Appearance compat fallbacks (thin, debt-marked, disposition A):
  `dots-m3-colors …`, `dots-gtk-theme -q …`, `dots-color-scheme …`
  (see `docs/COMPAT.md`).
- Optional integrations: `dots-recorder start/stop/pause`,
  `dots-wallpaper-current`, `dots-wallpaper-set …`,
  `dots-quickshell preset list/apply`, `dots-night-mode toggle`,
  `notify-send …`, `systemctl …`, `foot -e sh -c …`.
