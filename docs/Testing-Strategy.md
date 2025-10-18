# Testing Strategy

## Testing Philosophy

Testing ensures reliability across diverse environments:

- Multiple Linux distributions (Arch, Ubuntu, Fedora)
- Different window managers (i3, Openbox, XFCE4)
- Various hardware configurations (laptop, desktop, VM)
- Light and dark themes
- Different monitor setups (single, dual, triple)

## Playground Environment

**Purpose**: Safe testing without affecting production system.

**Available Environments:**

1. **Docker** (`playground/compose.yml`): Fast, lightweight, CLI testing
2. **Vagrant** (`bin/play`): Full GUI, complete desktop environment

**Usage Principles:**

- Test all visual changes in Vagrant (GUI required)
- Test installation and CLI scripts in Docker (faster iteration)
- Verify window manager integration in appropriate WM
- Check theme switching in both light and dark modes

**Provision Commands:**

```bash
./bin/play                    # Start default environment
./bin/play --provision i3     # Test with i3 window manager
./bin/play --provision openbox # Test with Openbox
./bin/play --remove           # Clean up environment
```

## What to Test

### Before Committing

1. **Script syntax**: `shellcheck script.sh`
2. **Script execution**: Run with various arguments
3. **Error handling**: Test with invalid inputs
4. **Dependencies**: Verify behavior with missing deps
5. **Integration**: Check interaction with other components

### For Visual Changes

1. Light theme appearance
2. Dark theme appearance
3. Color contrast and readability
4. Multi-monitor behavior
5. Different screen resolutions

### For Rice Themes

1. Apply script executes without errors
2. All applications receive correct colors
3. Wallpaper loads correctly
4. Polybar uses correct profile
5. EWW widgets display properly

## Testing Checklist

**For Scripts:**

- [ ] Passes shellcheck
- [ ] Handles missing dependencies gracefully
- [ ] Includes error handling
- [ ] Logs appropriately
- [ ] Cleans up resources
- [ ] Works with EasyOptions
- [ ] Help text is clear

**For Visual Components:**

- [ ] Works in light theme
- [ ] Works in dark theme
- [ ] Colors are readable
- [ ] Scales to different resolutions
- [ ] Handles multiple monitors
- [ ] Integrates with window manager

**For Themes (Rices):**

- [ ] Apply script is idempotent
- [ ] All assets load correctly
- [ ] Colors applied consistently
- [ ] Polybar profile loads
- [ ] EWW widgets display
- [ ] Wallpaper sets correctly
- [ ] Preview screenshot included

## Continuous Integration

The project uses GitHub Actions for automated testing:

- Syntax validation (shellcheck)
- Installation script testing
- Docker environment verification
- Documentation link checking

See `.github/workflows/` for CI configuration.
