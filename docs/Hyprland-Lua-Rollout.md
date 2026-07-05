# Hyprland Lua Migration — Rollout Guide

> Part of `ulises-jeremias/dotfiles#179` — closes `ulises-jeremias/dotfiles#188`

## Prerequisites

- Hyprland >= 0.55 installed
- chezmoi configured with this dotfiles repo
- All 8 migration PRs reviewed and merged to `main`

## PR merge order

The sub-issues were designed to be merged in order, but are intentionally
independent. They can be reviewed in any order. For best results, merge:

1. `#181` — Entrypoint + static settings (creates `hyprland.lua`, modules, stubs)
2. `#182` — Keybindings + keyboard help
3. `#183` — Window rules
4. `#184` — Animation profiles + rice switching
5. `#185` — Smart Colors Lua output
6. `#186` — Runtime integrations audit (doc-only)
7. `#187` — Documentation update
8. `#188` — This rollout guide

## Apply to host

After all PRs are merged:

```sh
# 1. Get latest config
chezmoi update

# 2. Preview changes
chezmoi diff

# 3. Apply
chezmoi apply

# 4. Reload Hyprland
hyprctl reload
```

## Verify

After reload, confirm:

- [ ] Quickshell bar appears
- [ ] Terminal opens (`SUPER + Return`)
- [ ] Workspace switching works (`SUPER + 1,2,3`)
- [ ] Application launcher opens (`CTRL + Space`)
- [ ] Window rules apply (e.g., `pavucontrol` floats)
- [ ] Smart Colors border colors match current theme
- [ ] Animation profile switching works via rice change
- [ ] Game Mode toggle still works
- [ ] Keyboard help (`SUPER + /`) shows keybindings

## Rollback

If `hyprctl reload` fails or the desktop is unusable:

1. Use emergency keybinds (`SUPER + Q` = close window, `SUPER + R` = launcher,
   `SUPER + M` = exit) to open a terminal.
2. Roll back to the previous config state:

```sh
chezmoi apply --force-refresh
```

Or if using git directly:

```sh
cd ~/.dotfiles
git revert HEAD~8..HEAD  # Revert all migration commits
chezmoi apply
hyprctl reload
```

1. If all else fails, the old `hyprland.conf` files are still present in
   `~/.config/hypr/` and can be restored manually:

```sh
# Temporarily rename the Lua entrypoint
mv ~/.config/hypr/hyprland.lua ~/.config/hypr/hyprland.lua.bak
# hyprland 0.55+ will fall back to hyprlang if no .lua is found
hyprctl reload
```

## Validation checks

| Check                    | Command                                   | Expected                 |
|--------------------------|-------------------------------------------|--------------------------|
| Lua entrypoint exists    | `test -f ~/.config/hypr/hyprland.lua`     | `true`                   |
| Modules directory exists | `test -d ~/.config/hypr/hyprland.lua.d`   | `true`                   |
| Keybindings load         | `hyprctl binds`                           | Lists all binds          |
| Monitor config           | `hyprctl monitors`                        | Monitors configured      |
| Animations active        | `hyprctl getoption animations:enabled -j` | `"str": "true"`          |
| Old conf not primary     | `test -f ~/.config/hypr/hyprland.conf`    | May still exist (legacy) |
