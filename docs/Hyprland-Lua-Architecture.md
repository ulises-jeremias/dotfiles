# Hyprland Lua migration architecture

This document defines the migration map for [#179](https://github.com/ulises-jeremias/dotfiles/issues/179).
It covers the current `home/dot_config/hypr/hyprland.conf` entrypoint and every
file under `home/dot_config/hypr/hyprland.conf.d/`. The migration follows
Hyprland 0.55+'s Lua configuration API; Hyprland 0.54 and earlier continue to
use the existing hyprlang configuration.

The work is split into small changes so static settings, runtime integrations,
and behavior-heavy features can be reviewed independently. The legacy files
remain available as rollback material until the converted configuration has
passed the complete acceptance matrix. Do not add `.chezmoiremove` entries or
delete the legacy source as part of an early migration slice.

## Staged implementation status

The `hyprland.lua.d/` source currently contains staged equivalents for monitor
rules, session environment, startup commands, keyboard/pointer/touchpad/cursor
settings, layout profiles, non-generated compositor options, all six animation
profiles, and window rules. A gesture module expresses the three-finger
horizontal workspace action through the current API. The window-rule module
mirrors all 43 legacy rules in order. These modules are inert:
there is deliberately no root `hyprland.lua` and no `require(...)` call in the
active `hyprland.conf`. Hyprland therefore continues to load the existing
hyprlang configuration. The staged modules have Lua syntax validation, but
they have not been loaded by Hyprland or accepted in a separate session.

The staged gesture action does not reproduce the old swipe distance, invert,
speed, cancel-ratio, or continue-forever tuning; Hyprland 0.55+ replaced those
settings with the gesture API, so equivalence requires isolated-session review.
Tablet-specific settings in the current fragment only set defaults; their Lua
form remains unported until the typed vector representation has been validated.
The shadow offset is also omitted because the legacy value is the zero default;
it is not serialized as an unverified Lua vector.
Generated border and shadow colors and the opt-in light variant remain
separate. The staged `smart-colors.lua` module sets the Hornero Dark factory
palette first, then optionally requires
`$HORNERO_SMART_COLORS_DIR/colors-hyprland.lua` or the default
`${XDG_CACHE_HOME:-~/.cache}/hornero/smart-colors/colors-hyprland.lua` output
from `horneroctl appearance colors generate --yes`. The generated module is
optional and protected with `pcall`, so a missing or malformed cache file
leaves the factory colors in place. This module is inert until the final Lua
entrypoint loads it; the active legacy configuration is unchanged.
Window-rule names, match expressions, effects, values, and order are
statically compared with the legacy source; named-rule precedence and runtime
matching still require isolated-session review. Keybindings, animations, Smart
Colors consumers, and final activation remain separate acceptance steps below.
Each animation profile has its own module because profiles reuse curve names;
the final entrypoint must load exactly one. Animation leaves, curves, styles,
and speed values are statically checked against all six legacy profiles.

## Target module map

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
| `hyprland.conf.d/colors.conf`                                          | `hyprland.lua.d/smart-colors.lua`          | Factory palette plus optional generated theme colors    |
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
  from the config serialization format. Audit every consumer before changing
  file paths or generated artifacts.
- Do not drop dynamic Smart Colors output, the optional Hornero Light variant,
  animation profiles, or Quickshell's rice switching. Each needs an explicit
  writer, loader, fallback, and reload path before its legacy counterpart is
  retired.
- Keep user-visible behavior and keybinding intent stable. Changes to
  bindings, window rules, or animation timing require a before/after inventory
  rather than a mechanical syntax conversion.

## Implementation sequence

1. Port static settings, input, monitor, environment, autostart, and layout
   modules in #181 without installing a root `hyprland.lua` entrypoint.
2. Port keybindings and keyboard-help discovery in #182.
3. Stage window rules in #183 and validate rule order and matching statically;
   confirm runtime named-rule precedence in the isolated target session.
4. Port animation profiles in #184. The current runtime selector is
   `horneroctl hypr animations`, which reads the legacy profile files; retain
   that path while Lua modules remain staged and audit its Lua-era behavior in
   #186. The previously listed Quickshell `Rice.qml` path is not present in
   this repository.
5. Port Smart Colors generation and its safe fallback in #185.
6. Audit runtime consumers and generated file paths in #186.
7. Update user documentation in #187.
8. In #188, add the root `hyprland.lua` that loads every migrated module,
   validate full behavior in the target-version test session, then remove
   legacy configuration only after the acceptance matrix passes.

Hyprland 0.55+ selects `hyprland.lua` when it exists; it does not merge that
file with `hyprland.conf`. Adding a partial root Lua file would silently stop
loading any legacy bindings, window rules, animation profiles, and generated
colors that had not yet been migrated. Staged modules therefore remain inert
until #188 activates the complete Lua tree. This keeps intermediate changes
from changing the desktop's active configuration.

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
