# Hyprland 0.55+ Lua Migration Plan

> Part of `ulises-jeremias/dotfiles#179` — tracks `ulises-jeremias/dotfiles#180`

## Summary

Hyprland 0.55 deprecates hyprlang in favor of Lua (`hl.*` API). HorneroConfig's
active Hyprland configuration lives in `home/dot_config/hypr/` and interacts with
Smart Colors, Quickshell rice switching, keyboard help, and runtime helper scripts.

This document defines the migration architecture, conversion rules, module layout,
and provides acceptance criteria for each implementation PR.

## Module Layout

```
home/dot_config/hypr/
├── hyprland.lua                       # Entrypoint — loads all modules
└── hyprland.lua.d/                    # Modules directory (require path)
    ├── static.lua                     # general, decoration, gestures, misc, xwayland, debug
    ├── input.lua                      # input + cursor settings
    ├── monitors.lua                   # monitor configuration
    ├── environment.lua                # environment variables (hl.env)
    ├── autostart.lua                  # autostart (hl.on hyprland.start)
    ├── layout.lua                     # scrolling/dwindle/master layout profiles
    ├── keybindings.lua                # all binds + submaps
    ├── window-rules.lua               # window rules (hl.window_rule)
    ├── animations.lua                 # shared curves + default animation tree
    ├── animations-cyberpunk.lua       # cyberpunk animation profile
    ├── animations-cozy.lua            # cozy animation profile
    ├── animations-vaporwave.lua       # vaporwave animation profile
    ├── animations-nature.lua          # nature animation profile
    ├── animations-minimal.lua         # minimal animation profile
    ├── colors.lua                     # —generated— by Smart Colors (cache)
    └── colors-manual.lua              # —fallback— hardcoded default colors
```

The `require` path is relative to `hyprland.lua`'s directory, so:

```lua
require("hyprland.lua.d.static")
require("hyprland.lua.d.input")
-- etc.
```

## hyprlang → Lua Conversion Rules

| hyprlang                                     | Lua                                                                                                    | Notes                                       |
|----------------------------------------------|--------------------------------------------------------------------------------------------------------|---------------------------------------------|
| `source = ~/.../foo.conf`                    | `require("hyprland.lua.d.foo")`                                                                        | `.conf.d` → `.lua.d`                        |
| `exec-once = cmd`                            | `hl.on("hyprland.start", function() hl.exec_cmd("cmd") end)`                                           |                                             |
| `exec-once = cmd1 && cmd2`                   | Multiple `hl.exec_cmd()` calls in one `hl.on` block                                                    |                                             |
| `env = KEY,value`                            | `hl.env("KEY", "value")`                                                                               | Use `os.getenv()` for runtime refs          |
| `bind = mod, key, disp`                      | `hl.bind("mod + key", hl.dsp.disp())`                                                                  |                                             |
| `binde = ...`                                | `hl.bind(..., { repeating = true })`                                                                   | Repeating flag                              |
| `bindl = ...`                                | `hl.bind(..., { locked = true })`                                                                      | Locked flag                                 |
| `bindle = ...`                               | `hl.bind(..., { locked = true, repeating = true })`                                                    | Both flags                                  |
| `bindm = mod, mouse:N, action`               | `hl.bind("mod + mouse:N", hl.dsp.window.action(), { mouse = true })`                                   |                                             |
| `submap = name` / `submap = reset`           | `hl.dsp.submap("name")` / `hl.dsp.submap("reset")`                                                     |                                             |
| `windowrule { ... }`                         | `hl.window_rule({ ... })`                                                                              | Preserve name, match, effects               |
| `bezier = name, x1, y1, x2, y2`              | `hl.curve(name, { type = "bezier", points = {{x1, y1}, {x2, y2}} })`                                   |                                             |
| `animation = leaf, on, frames, curve, style` | `hl.animation({ leaf = "...", enabled = true, speed = frames*0.0167, bezier = "...", style = "..." })` | `speed` is deciseconds (1 = 100ms) in 0.55+ |
| `$mainMod = SUPER`                           | `local mainMod = "SUPER"`                                                                              |                                             |
| `general { key = val }`                      | `hl.config({ general = { key = val } })`                                                               |                                             |
| `col.active_border = rgba(...)`              | `col = { active_border = "rgba(...)" }`                                                                | String format                               |
| `monitor = name,pref,pos,sc`                 | `hl.monitor({ output = "name", mode = "preferred", position = "pos", scale = sc })`                    |                                             |

### Animation speed conversion

Hyprland 0.55 animation `speed` uses deciseconds (1 = 100ms). Old hyprlang used
"frames" at nominal 60fps refresh. Each frame was ≈ 16.67ms. Conversion:

- 2 frames (~33ms) → speed ≈ 0.33
- 4 frames (~67ms) → speed ≈ 0.67
- 6 frames (100ms) → speed = 1.0
- 8 frames (133ms) → speed ≈ 1.33
- 10 frames (167ms) → speed ≈ 1.67
- 12 frames (200ms) → speed = 2.0

Upper layers inherit from `global` if not explicitly set.

### Window rule changes

Current `windows-rules.conf` already uses the Hyprland 0.53+ block syntax which
maps directly to `hl.window_rule({...})`:

```hyprlang
windowrule {
    name = example
    match:class = (regex)
    float = true
    center = true
    size = 40% 50%
}
```

becomes:

```lua
hl.window_rule({
    name = "example",
    match = { class = "(regex)" },
    float = true,
    center = true,
    size = { "40%", "50%" },
})
```

Order of rules is preserved. Named rules take precedence over anonymous ones
in Hyprland Lua as documented.

### Layout profiles

Layout profiles `scrolling { ... }`, `dwindle { ... }`, `master { ... }` are
set via `hl.config()` subcategories:

```lua
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
        column_width = 0.62,
        -- etc
    },
    dwindle = {
        preserve_split = true,
        -- etc
    },
    master = {
        new_status = "master",
        -- etc
    },
})
```

The runtime layout switcher (`dots-hypr-layout`) continues to use
`hyprctl keyword general:layout ...` — this affects the live session, not the
config file, so no migration is needed there.

## Key Decisions

### 1. Module path uses `.lua.d/` suffix

All modules live in `hyprland.lua.d/` to keep them grouped with the entrypoint.
The `require()` calls use relative syntax: `require("hyprland.lua.d.static")`.

### 2. Animation profiles remain modular

Rice switching currently symlinks `animations-{profile}.conf` to
`animations-current.conf`. After migration:

- Each profile is a Lua module at `hyprland.lua.d/animations-{profile}.lua`.
- `Rice.qml` will manage the active profile path to point into `hyprland.lua.d/`
  instead of `hyprland.conf.d/`.
- The animation-switching process uses `ln -sf` to create a symlink that
  `hyprland.lua` requires.

### 3. Smart Colors generates Lua output

`dots-smart-colors` currently generates `colors-hyprland.conf` in
`~/.cache/dots/smart-colors/`. After migration:

- Generate `colors.lua` instead, using `hl.config({ general = { col = ... },
  group = { ... } })` format.
- The entrypoint or `colors-manual.lua` tries to load it with `pcall`:

```lua
local ok, colors = pcall(dofile, os.getenv("HOME") .. "/.cache/dots/smart-colors/colors.lua")
if not ok then
    dofile(os.getenv("HOME") .. "/.config/hypr/hyprland.lua.d/colors-manual.lua")
end
```

- If Smart Colors hasn't run yet (fresh install), `colors-manual.lua` provides
  safe fallback values.

### 4. `dots-keyboard-help` needs a new source of truth

Currently parses `hyprland.conf.d/keybindings.conf` directly. Options:

- (A) Generate a static JSON metadata file alongside the Lua keybindings module
  and read that in the help script.
- (B) Use `hyprctl binds` output as the fallback source.
- (C) Add a `dots-hypr-binds` command that dumps a parseable format.

Recorded as sub-issue `#182`.

### 5. Hyprlock and Hypridle stay in hyprlang

Only `hyprland` itself is migrating to Lua. `hyprlock.conf` and `hypridle.conf`
are separate programs and remain in hyprlang.

### 6. Runtime `hyprctl keyword` consumers do not need changes

Scripts that use `hyprctl keyword` or `hyprctl dispatch` modify the *live session*
state — they work regardless of the config file format. Consumers:

- `dots-hypr-layout`: `hyprctl keyword general:layout ...`
- `dots-hypr-monitors`: `hyprctl keyword monitor ...`
- `gaps-interactive.sh`: `hyprctl keyword general:gaps_in/out ...`
- Quickshell GameMode: `Hypr.extras.applyOptions({...})`
- Quickshell Rice.qml: `hyprctl reload`

All continue to work without changes, but `Rice.qml` must update animation
profile paths as described in decision 2.

### 7. Dispatcher fallback strategy

When a dispatcher has no clean `hl.dsp.*` helper, use a `hyprctl dispatch`
fallback inside `hl.bind()`:

```lua
hl.bind("mod + key", function()
    -- try Lua-native dispatcher, fallback to hyprctl
    hl.dispatch(hl.dsp.whatever(...))
end)
```

If only `hyprctl dispatch` works:

```lua
hl.bind("mod + key", hl.dsp.exec_cmd("hyprctl dispatch ..."))
```

## Implementation Order

| Order | Issue  | Scope                                                                                                  | Branch prefix                        |
|-------|--------|--------------------------------------------------------------------------------------------------------|--------------------------------------|
| 1     | `#181` | Entrypoint + static settings (`hyprland.lua`, static, input, monitors, environment, autostart, layout) | `feat-hyprland-lua-static-181`       |
| 2     | `#182` | Keybindings + keyboard help                                                                            | `feat-hyprland-lua-binds-182`        |
| 3     | `#183` | Window rules                                                                                           | `feat-hyprland-lua-windowrules-183`  |
| 4     | `#184` | Animation curves + profiles + rice switching                                                           | `feat-hyprland-lua-animations-184`   |
| 5     | `#185` | Smart Colors Lua output generation                                                                     | `feat-hyprland-lua-smartcolors-185`  |
| 6     | `#186` | Runtime integrations audit (Rice.qml paths, QS integrations)                                           | `feat-hyprland-lua-integrations-186` |
| 7     | `#187` | Documentation update                                                                                   | `docs-hyprland-lua-docs-187`         |
| 8     | `#188` | Validation + rollout (final CI checks)                                                                 | `chore-hyprland-lua-rollout-188`     |

## Validation per PR

| Check         | Command                                       | When                           |
|---------------|-----------------------------------------------|--------------------------------|
| Lua syntax    | `luac -p file.lua`                            | Each Lua file created/modified |
| Shell lint    | `shellcheck script.sh`                        | Shell scripts touched          |
| Shell format  | `shfmt -d script.sh`                          | Shell scripts touched          |
| Pre-commit    | `pre-commit run --files <changed>`            | Before every commit            |
| chezmoi apply | `chezmoi apply --dry-run --refresh-externals` | Dry-run before final commit    |
| Live reload   | `hyprctl reload` + visual check               | Host only — operator-approved  |

## Rollout

1. After all sub-issues are merged to `main`, apply chezmoi:

   ```sh
   chezmoi update
   chezmoi apply
   ```

2. Reload Hyprland:

   ```sh
   hyprctl reload
   ```

3. Verify:
   - Quickshell bar appears
   - Keybindings work (workspace switching, terminal, launcher)
   - Window rules apply (floating pavucontrol, firefox on ws 1)
   - Smart Colors border colors match current theme
   - Animation profile switching via rice change
   - Game Mode toggle
4. If reload fails, Hyprland falls back to emergency binds (`SUPER+Q`, `+R`, `+M`).
   Rollback: `git revert` the merge commit(s) and re-run `chezmoi apply`.
