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

## Target module map

| Current source                                                                     | Target module                             | Responsibility                                          |
|------------------------------------------------------------------------------------|-------------------------------------------|---------------------------------------------------------|
| `hyprland.conf`                                                                    | `hyprland.lua`                            | Ordered entrypoint and module selection                 |
| `hyprland.conf.d/monitors.conf`                                                    | `hyprland.lua.d/monitors.lua`             | Monitor rules and fallback output                       |
| `hyprland.conf.d/autostart.conf`                                                   | `hyprland.lua.d/autostart.lua`            | Session-start commands and ordering                     |
| `hyprland.conf.d/environment.conf`                                                 | `hyprland.lua.d/environment.lua`          | Environment inherited by launched applications          |
| `hyprland.conf.d/input.conf`                                                       | `hyprland.lua.d/input.lua`                | Keyboard, pointer, touchpad, tablet, and cursor         |
| `hyprland.conf.d/layout.conf`                                                      | `hyprland.lua.d/layout.lua`               | Scrolling, dwindle, master, and shared layout settings  |
| `hyprland.conf.d/keybindings.conf`                                                 | `hyprland.lua.d/keybindings.lua`          | Key, mouse, switch, and media bindings                  |
| `hyprland.conf.d/window-rules.conf`                                                | `hyprland.lua.d/window-rules.lua`         | Window matching rules and effects                       |
| `hyprland.conf.d/animations.conf`                                                  | `hyprland.lua.d/animations.lua`           | Default animation curves and tree                       |
| `hyprland.conf.d/animations-cozy.conf`                                             | `hyprland.lua.d/animations-cozy.lua`      | Cozy animation profile                                  |
| `hyprland.conf.d/animations-cyberpunk.conf`                                        | `hyprland.lua.d/animations-cyberpunk.lua` | Cyberpunk animation profile                             |
| `hyprland.conf.d/animations-minimal.conf`                                          | `hyprland.lua.d/animations-minimal.lua`   | Minimal animation profile                               |
| `hyprland.conf.d/animations-nature.conf`                                           | `hyprland.lua.d/animations-nature.lua`    | Nature animation profile                                |
| `hyprland.conf.d/animations-vaporwave.conf`                                        | `hyprland.lua.d/animations-vaporwave.lua` | Vaporwave animation profile                             |
| `hyprland.conf.d/colors.conf`                                                      | Generated Lua color module                | Theme-derived border and group colors                   |
| `hyprland.conf.d/hornero-light.conf`                                               | Generated Lua color module                | Optional Hornero Light colors; preserve opt-in behavior |
| `hyprland.conf.d/debug.conf`                                                       | `hyprland.lua.d/static.lua`               | Error-display configuration                             |
| Inline `general`, `decoration`, `misc`, `gestures`, `xwayland`, and `debug` blocks | `hyprland.lua.d/static.lua`               | Static compositor options and defaults                  |

The generated color module must have a checked-in or packaged fallback so a
fresh install works before Smart Colors runs. `hyprlock.conf` and
`hypridle.conf` belong to separate applications and stay in their existing
formats.

## Conversion rules

- Translate configuration with `hl.config`, `hl.input`, `hl.monitor`,
  `hl.env`, `hl.window_rule`, `hl.curve`, and `hl.animation` using the current
  Hyprland stubs and official 0.55+ reference. Do not infer Lua field names
  from the legacy parser's names alone.
- Translate bindings to `hl.bind` and a matching `hl.dsp` helper when one
  exists. Keep dispatcher fallbacks explicit and covered by the keybinding
  inventory. Preserve locked and repeating semantics for `bindl`, `binde`,
  and `bindle`; preserve mouse semantics for `bindm`.
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

1. Port the entrypoint and static settings, input, monitor, environment,
   autostart, and layout configuration in #181.
2. Port keybindings and keyboard-help discovery in #182.
3. Port window rules in #183.
4. Port animation profiles and Quickshell rice switching in #184.
5. Port Smart Colors generation and its safe fallback in #185.
6. Audit runtime consumers and generated file paths in #186.
7. Update user documentation in #187.
8. Run the full rollout and validation matrix in #188 before removing legacy
   configuration.

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
