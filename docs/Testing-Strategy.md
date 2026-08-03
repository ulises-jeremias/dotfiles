# Testing Strategy

## Testing Philosophy

Testing ensures reliability across diverse environments:

- Multiple Linux distributions (Arch, Ubuntu, Fedora)
- Hyprland window manager (Wayland)
- Appearance theme packs (apply-once recipes)
- Multiple hardware configurations (laptop, desktop, VM)
- Light and dark modes
- Different monitor setups (single, dual, triple)

## Playground Environment

**Purpose**: Safe testing without affecting production system.

**Available Environments:**

1. **Docker** (`playground/compose.yml`): Fast, lightweight, CLI testing
2. **Vagrant** (`bin/play`): Full GUI, complete desktop environment

**Usage Principles:**

- Test all visual changes in Vagrant (GUI required)
- Test installation and CLI scripts in Docker (faster iteration)
- Verify Hyprland integration in Wayland session
- Check theme switching in both light and dark modes

**Provision Commands:**

```bash
./bin/play                       # Start default environment
./bin/play --provision hyprland  # Test with Hyprland
./bin/play --remove              # Clean up environment
```

## What to Test

### Before Committing

1. **Script syntax**: `shellcheck script.sh`
2. **Script execution**: Run with various arguments
3. **Error handling**: Test with invalid inputs
4. **Dependencies**: Verify behavior with missing deps
5. **Integration**: Check interaction with other components
6. **Appearance contract**: `./scripts/test-appearance-consistency.sh --source`

### For Visual Changes

1. Light theme appearance
2. Dark theme appearance
3. Color contrast and readability
4. Multi-monitor behavior
5. Different screen resolutions

### For Appearance Theme Packs

1. `theme.json` schema is complete (`schemaVersion`, `id`, `schemeType`, GTK/icons, wallpaper)
2. Preview asset exists (`preview.jpg` / `.png` / `.webp`)
3. Apply via CLI and Control Center without errors
4. Wallpaper loads; `~/.cache/wal/wal` remains a text path file
5. `dots appearance doctor` reports OK
6. GTK/icons go through `dots-gtk-theme`
7. Quickshell Control Center: stage → Apply shows busy/error feedback

## Testing Checklist

**For Scripts:**

- [ ] Passes shellcheck
- [ ] Handles missing dependencies gracefully
- [ ] Includes error handling
- [ ] Logs appropriately
- [ ] Cleans up resources
- [ ] Works with EasyOptions (when applicable)
- [ ] Help text is clear

**For Visual Components:**

- [ ] Works in light mode
- [ ] Works in dark mode
- [ ] Colors are readable
- [ ] Scales to different resolutions
- [ ] Handles multiple monitors
- [ ] Integrates with window manager

**For Theme Packs:**

- [ ] Apply is idempotent (no sticky current id written)
- [ ] All assets load correctly
- [ ] Colors applied consistently via smart-colors / M3
- [ ] Wallpaper sets correctly
- [ ] Preview screenshot included
- [ ] `list-themes.py` exposes `wallpaperPaths` for every listed wallpaper

## Quickshell Appearance UI checklist

- [ ] Theme stage shows **Staged** chip; Apply commits via `ThemePipeline`
- [ ] Apply disabled while pipeline busy; footer shows Applying… / error
- [ ] GTK/icon live seed does not overwrite staged selections
- [ ] Preview shows “Generating palette…” while M3 preview runs
- [ ] System pane GTK tile opens Appearance (`dots-theme-selector`)

## Continuous Integration

The project uses GitHub Actions for automated testing:

- Syntax validation (shellcheck)
- Installation script testing
- Docker environment verification
- Documentation link checking
- Appearance source consistency (`test-appearance-consistency.sh --source`)

See `.github/workflows/` for CI configuration.
