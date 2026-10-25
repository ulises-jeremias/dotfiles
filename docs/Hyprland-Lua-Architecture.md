# Hyprland Lua migration architecture

This document defines the migration map for [#179](https://github.com/ulises-jeremias/dotfiles/issues/179).

## Status: migration complete (Lua-only)

`home/dot_config/hypr/hyprland.lua` is the only Hyprland entrypoint. It loads,
in order: monitors, autostart, environment, input, gestures, layout,
keybindings, window-rules, animations, smart-colors, and static. The legacy
hyprlang `hyprland.conf` + `hyprland.conf.d/` tree has been removed from the
source, and `.chezmoiremove` deletes it on existing hosts at apply time.
Keybindings were converted 1:1 (139 binds, verified against
`horneroctl hardware keyboard keys`). Window rules (44), animation profiles
(six), and factory Smart Colors values are regression-tested against frozen
legacy expectations in `tests/`. Animation profiles stay selectable at
runtime through horneroctl; `animations.lua` is the startup default.

Notes carried over from the migration:

- The gesture module expresses the three-finger horizontal workspace action
  through the current API; Hyprland 0.55+ replaced the old swipe tuning
  (distance, invert, speed, cancel-ratio), so the Lua form uses API defaults.
- Tablet-specific settings only set defaults; their typed vector
  representation remains unported.
- The shadow offset is omitted because the legacy value is the zero default.
- `smart-colors.lua` sets the Hornero Dark factory palette first, then
  optionally `pcall`-loads the generated
  `$HORNERO_SMART_COLORS_DIR/colors-hyprland.lua` (or the default
  `${XDG_CACHE_HOME:-~/.cache}/hornero/smart-colors/colors-hyprland.lua`)
  from `horneroctl appearance colors generate --yes`; a missing or malformed
  cache file leaves the factory colors in place.

## Module map (retired source → Lua module)

| Current source                                                         | Target module                             | Responsibility                                          |
|------------------------------------------------------------------------|-------------------------------------------|---------------------------------------------------------|
| `hyprland.conf`                                                        | `hyprland.lua`                            | Final ordered entrypoint; add only after full parity    |
| `hyprland.conf.d/monitors.conf`                                        | `hyprland.lua.d/monitors.lua`             | Monitor rules and fallback output                       |
| `hyprland.conf.d/autostart.conf`                                       | `hyprland.lua.d/autostart.lua`            | Session-start commands and ordering                     |
| `hyprland.conf.d/environment.conf`                                     | `hyprland.lua.d/environment.lua`          | Environment inherited by launched applications          |
| `hyprland.conf.d/input.conf`                                           | `hyprland.lua.d/input.lua`                | Keyboard, pointer, touchpad, tablet, and cursor         |
| `hyprland.conf.d/layout.conf`                                          | `hyprland.lua.d/layout.lua`               | Scrolling, dwindle, master, and shared layout settings  |
| `hyprland.conf.d/keybindings.conf`                                     | `hyprland.lua.d/keybindings.lua`          | Key, mouse, switch, and media bindings                  |
| `hyprland.conf.d/window-rules.conf`                                    | `hyprland.lua.d/window-rules.lua`         | Window matching rules and effects                       |
| `hyprland.conf.d/animations.conf`                                      | `hyprland.lua.d/animations.lua`           | Default animation curves and tree                       |
| `hyprland.conf.d/animations-cozy.conf`                                 | `hyprland.lua.d/animations-cozy.lua`      | Cozy animation profile                                  |
| `hyprland.conf.d/animations-cyberpunk.conf`                            | `hyprland.lua.d/animations-cyberpunk.lua` | Cyberpunk animation profile                             |
| `hyprland.conf.d/animations-minimal.conf`                              | `hyprland.lua.d/animations-minimal.lua`   | Minimal animation profile                               |
| `hyprland.conf.d/animations-nature.conf`                               | `hyprland.lua.d/animations-nature.lua`    | Nature animation profile                                |
| `hyprland.conf.d/animations-vaporwave.conf`                            | `hyprland.lua.d/animations-vaporwave.lua` | Vaporwave animation profile                             |
| `hyprland.conf.d/colors.conf`                                          | `hyprland.lua.d/smart-colors.lua`         | Factory palette plus optional generated theme colors    |
| `hyprland.conf.d/hornero-light.conf`                                   | Generated Lua color module                | Optional Hornero Light colors; preserve opt-in behavior |
| `hyprland.conf.d/debug.conf`                                           | `hyprland.lua.d/static.lua`               | Error-display configuration                             |
| Inline `general`, `decoration`, `misc`, `xwayland`, and `debug` blocks | `hyprland.lua.d/static.lua`               | Static compositor options and defaults                  |
| Inline `gestures` block                                                | `hyprland.lua.d/gestures.lua`             | Workspace swipe action; legacy tuning needs review      |

The generated color module must have a checked-in or packaged fallback so a
fresh install works before Smart Colors runs. `hyprlock.conf` and
`hypridle.conf` belong to separate applications and stay in their existing
formats.

## Conversion rules

- Translate global categories with `hl.config`, device rules with
  `hl.device`, outputs with `hl.monitor`, environment values with `hl.env`,
  and startup work with `hl.on`. Global keyboard and touchpad options belong
  under `hl.config({ input = { ... } })`; there is no `hl.input` API. Confirm
  all other typed APIs against the installed target-version stubs and official
  reference. Do not infer Lua field names from the legacy parser's names.
- Translate bindings to `hl.bind` and a matching `hl.dsp` helper when one
  exists. Keep dispatcher fallbacks explicit and covered by the keybinding
  inventory. Preserve locked and repeating semantics for `bindl`, `binde`,
  and `bindle`; preserve mouse semantics for `bindm`.
- Translate `windowrule` blocks to `hl.window_rule` with their original names,
  match properties, effect values, and declaration order. Validate Lua field
  support against the target version's installed descriptors; class and title
  regexes must remain byte-for-byte equivalent after Lua string decoding.
- Translate `bezier` entries to `hl.curve` and animation leaves to
  `hl.animation`. Hyprland's legacy `speed` and Lua `speed` both use
  deciseconds (100 ms units), so copy numeric values unchanged; comments in the
  current legacy files that describe them as frames are inaccurate. Keep
  same-named curves isolated by loading only the selected profile.
- Move `exec-once` behavior to `hl.on("hyprland.start", ...)`. Commands that
  rely on shell operators must preserve their ordering intentionally; pass
  fixed command strings only and do not interpolate untrusted values into a
  shell.
- Resolve environment values such as `HOME` and `XDG_RUNTIME_DIR` at runtime
  with `os.getenv`. Do not introduce a hard-coded numeric UID or machine-
  specific monitor name beyond the existing explicit rules.
- Keep runtime `hyprctl keyword` and `hyprctl dispatch` consumers separate
  from the config serialization format, but do not assume their legacy syntax
  survives the provider change. On the Lua provider, current Hyprland rejects
  `hyprctl keyword`; `dispatch` takes a Lua dispatcher expression; and
  `getoption` uses dotted option paths. Route maintained runtime operations
  through `hyprland-runtime`, which chooses syntax from the standard active config
  path. Audit every consumer before changing generated artifacts.
- Do not drop dynamic Smart Colors output, the optional Hornero Light variant,
  animation profiles, or Quickshell's rice switching. Each needs an explicit
  writer, loader, fallback, and reload path before its legacy counterpart is
  retired.
- Keep user-visible behavior and keybinding intent stable. Changes to
  bindings, window rules, or animation timing require a before/after inventory
  rather than a mechanical syntax conversion.

## Implementation sequence

All steps are complete: static/input/monitor/environment/autostart/layout
modules (#181), keybindings (#182), window rules (#183), animation profiles
(#184, switched at runtime by `horneroctl hypr animations`), Smart Colors
(#185), runtime-consumer audit (#186), documentation (#187), and final
activation with legacy removal (#188). `horneroctl hypr animations` reads the
Lua profile modules. Hyprland 0.55+ selects `hyprland.lua` when it exists and
never merges it with `hyprland.conf`, which is why activation waited until
every module had full parity. Live-session acceptance on the target host
(config errors, bindings, animation switching) remains the final rollout
check after `chezmoi apply`.

## Runtime consumer compatibility

The compatibility boundary is implemented by
`home/dot_local/bin/executable_hyprland-runtime`. It checks for the active
`${XDG_CONFIG_HOME:-~/.config}/hypr/hyprland.lua` entrypoint and uses only a
small allowlist of typed operations. With no Lua entrypoint, it retains the
legacy calls so the currently active hyprlang config behaves as before.
Creating the root Lua entrypoint switches these helper calls to the Lua API
without requiring callers to construct Lua expressions.

| Consumer               | Adapter operation                         | Lua behavior                                                         |
|------------------------|-------------------------------------------|----------------------------------------------------------------------|
| Interactive gap menu   | `get-gap`, `set-gap`                      | dotted `getoption` path; `hl.config` for integer gaps                |
| Smart Float            | `toggle-float`, `resize-active`, `center` | typed float, resize, and center dispatchers                          |
| Notification click     | `focus-class`                             | Lua focus selector; only simple application class names are accepted |
| Hypridle display power | `dpms on/off`                             | typed DPMS enable/disable dispatcher                                 |

Arguments are constrained before entering generated Lua: gaps are integers
from 0 through 1000 (adjustments clamp at both boundaries), dimensions are
positive integers up to 100000, and
application classes are limited to ASCII letters, digits, dot, underscore,
and hyphen. The helper does not evaluate arbitrary caller-provided Lua and
does not reload Hyprland. Other integrations (including external plugins and
Quickshell) remain subject to the audit below; source search cannot prove
runtime behavior.

This adapter follows the current Hyprland Lua-provider contract:
[Using hyprctl](https://wiki.hypr.land/configuring/core/advanced-configuration/using-hyprctl/)
documents Lua expressions for `dispatch` and `eval`, while its
[dispatcher reference](https://wiki.hypr.land/configuring/core/dispatchers/)
documents the float, resize, center, focus, and DPMS operations. The adapter
is covered by isolated fake-`hyprctl` tests. Live compositor
acceptance remains outstanding and is part of the final rollout gates in
issue #188.

Each implementation pull request must identify the source files it replaces,
show the relevant before/after behavior, run the static checks below, and state
what requires a live-session acceptance run.

## Validation and rollout gates

Run these non-disruptive checks for each applicable change:

```sh
luac -p path/to/changed.lua
bash -n path/to/changed-script.sh
shellcheck path/to/changed-script.sh
python3 -m pytest tests -q
./scripts/verify-delivery.sh
```

Use the [Lua configuration guide](https://wiki.hypr.land/0.56.0/Configuring/Start/),
[config options](https://wiki.hypr.land/0.56.0/Configuring/Basics/Variables/),
[devices](https://wiki.hypr.land/0.56.0/Configuring/Advanced-and-Cool/Devices/),
[monitors](https://wiki.hypr.land/0.56.0/Configuring/Basics/Monitors/), and
[autostart](https://wiki.hypr.land/0.56.0/Configuring/Basics/Autostart/) as
the API reference for the initial target. Use the [0.54 animation
syntax](https://wiki.hypr.land/0.54.0/Configuring/Animations/) to interpret
the legacy source and the [0.56 Lua animation
API](https://wiki.hypr.land/0.56.0/Configuring/Advanced-and-Cool/Animations/)
for its staged modules. Where local installed stubs disagree with a newer
wiki, pin implementation to the installed Hyprland version and record the
version-specific decision.

Before a host applies the migration, render chezmoi templates against both
managed-host and static configurations and inspect `chezmoi diff` without
applying it. A configuration syntax check is necessary but does not prove
that Hyprland accepts every option or that session behavior is preserved.
Live validation must check `hyprctl configerrors`, monitor state, layout,
keyboard bindings, autostart, Smart Colors, animation switching, and the
Quickshell reload path in an isolated test session or an explicitly approved
host rollout with a tested rollback. Never reload the user's active Hyprland
session as part of an automated test.

If a rollout fails, restore the known-good `hyprland.conf` and
`hyprland.conf.d/` source from the pre-migration commit, render it with
chezmoi, inspect the diff, then restart only inside the approved recovery
session. Do not describe `git switch main` as a rollback: `main` may already
contain the migration.
