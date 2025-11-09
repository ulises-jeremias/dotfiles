# ADR 006: Use XDG Default Applications with handlr

**Status**: Accepted  
**Date**: 2025-11-08  
**Deciders**: Ulises Jeremias Cornejo Fandos  
**Related**: [ADR 002: Rice System](002-rice-system.md), [Development Standards](../Development-Standards.md)

## Context

HorneroConfig initially implemented custom application selection logic in `dots-file-manager` with hardcoded fallback chains and preference storage. This created several issues:

1. **Reinventing the wheel** - XDG MIME associations already provide system-wide default application management
2. **Inconsistent behavior** - Custom logic didn't integrate with system-wide defaults
3. **Maintenance burden** - Need to maintain application lists, preferences, and fallback logic
4. **Limited scope** - Only handled file managers, not browsers, terminals, editors, etc.
5. **Poor integration** - Tools like `exo-open` and `xdg-open` couldn't use our preferences

The question arose: Should we continue building custom application launchers, or leverage existing community tools?

## Decision

**Use XDG default applications system with `handlr` as the management tool**, and `exo-open` as the launcher:

### Architecture

```text
User Configuration Layer
├── dots-default-apps (GUI/CLI wrapper)
│   └── handlr (MIME associations)
│       └── ~/.config/handlr/handlr.toml
│
Launch Layer
├── exo-open --launch {FileManager|TerminalEmulator|WebBrowser}
├── handlr open <file/url>
└── xdg-open <file/url>
```

### Components

1. **handlr-regex** - Modern Rust tool for XDG MIME handling
   - Installed via `pacman -S handlr-regex`
   - Provides `handlr set`, `handlr get`, `handlr list` commands
   - Stores configuration in `~/.config/handlr/handlr.toml`
   - Improved UX for XDG MIME management

2. **dots-default-apps** - HorneroConfig wrapper
   - GUI with rofi for category-based selection (no MIME types needed)
   - CLI interface matching dots-* standards (EasyOptions, error handling)
   - Categories: file-manager, terminal, web-browser, text-editor, etc.
   - Integrated into `dots-settings-gui`

3. **exo-open** - Lightweight launcher from XFCE
   - Already installed (XFCE dependency)
   - Respects XDG MIME associations
   - Simple API: `exo-open --launch FileManager`
   - Used in: JGMenu, Hyprland keybindings, Waybar, EWW

4. **dots-file-manager** - Simplified wrapper
   - Delegates to `exo-open --launch FileManager`
   - Provides `--select` flag to open configuration
   - Fallback to `handlr`/`xdg-open` if exo not available
   - Maintains consistent dots-* interface

### Integration Points

- **JGMenu**: Uses `exo-open --launch {FileManager|TerminalEmulator|WebBrowser}`
- **Hyprland**: Keybindings use `exo-open` for quick access
- **Waybar**: Module actions use `exo-open`
- **EWW Dashboard**: Widgets use `exo-open`
- **dots-settings-gui**: "Default Applications" entry launches `dots-default-apps`

## Consequences

### Positive

- ✅ **Standard compliance** - Uses XDG MIME system respected by all applications
- ✅ **Community tools** - Leverages `handlr` (proven, maintained) instead of custom code
- ✅ **Consistency** - System-wide defaults work everywhere (Thunar, file dialogs, etc.)
- ✅ **Less code** - Removed ~200 lines of custom fallback logic
- ✅ **Better UX** - GUI hides MIME type complexity behind categories
- ✅ **Flexibility** - Users can use `handlr` CLI, `nwg-look` GUI, or `dots-default-apps`
- ✅ **Lightweight** - `exo-open` is fast and small (~50KB)

### Negative

- ⚠️ **New dependency** - Adds `handlr-regex` package (but small: ~2MB)
- ⚠️ **Learning curve** - Users need to understand `handlr` usage

### Neutral

- ℹ️ **exo-open** - Technically from XFCE, but it's just a thin XDG wrapper (no desktop environment coupling)
- ℹ️ **Backwards compatibility** - Old `dots file-manager` command still works (just delegates)

## Implementation

### Files Changed

1. **Installation**:
   - `home/.chezmoiscripts/linux/run_onchange_before_install-xdg.tmpl`
     - Added `handlr-regex` to pacman installation

2. **New Scripts**:
   - `home/dot_local/bin/executable_dots-default-apps`
     - Full EasyOptions implementation
     - GUI with category selection
     - CLI for scripting (`--list`, `--set`, `--type=<category>`)

3. **Modified Scripts**:
   - `home/dot_local/bin/executable_dots-file-manager`
     - Simplified to 90 lines (from 241)
     - Uses `exo-open --launch FileManager`
     - `--select` opens `dots-default-apps --type=file-manager`

   - `home/dot_local/bin/executable_dots-settings-gui`
     - Added "🎯 Default Applications" entry
     - Launches `dots-default-apps --gui`

4. **Configuration**:
   - `home/dot_config/jgmenu/prepend.csv`
     - Changed to `exo-open --launch {FileManager|TerminalEmulator|WebBrowser}`
     - Removed `dots launcher --type=webbrowser` (redundant)

5. **Documentation**:
   - `docs/wiki/Dots-Scripts.md`
     - Added `default-apps` section with examples
     - Updated `file-manager` to reflect new architecture
     - Added "How it works" explanation

### Usage Examples

```bash
# Configure defaults via GUI
dots default-apps --gui

# Configure specific category
dots default-apps --type=file-manager
dots default-apps --type=web-browser

# CLI configuration
dots default-apps --set inode/directory thunar.desktop
dots default-apps --set x-scheme-handler/http firefox.desktop

# Check current defaults
dots default-apps --list
dots default-apps --info

# Launch file manager (respects XDG defaults)
dots file-manager
exo-open --launch FileManager
handlr open ~/Documents
```

### Alternative Tools

Users can also configure defaults with:

- **nwg-look** - GTK settings GUI with "Default Applications" tab
- **handlr** - Direct CLI: `handlr set <MIME> <APP.desktop>`
- **xdg-mime** - CLI tool: `xdg-mime default <APP.desktop> <MIME>`

All methods write to the same XDG MIME database, ensuring consistency.

## References

- [XDG MIME Applications spec](https://specifications.freedesktop.org/mime-apps-spec/mime-apps-spec-latest.html)
- [handlr GitHub](https://github.com/chmln/handlr)
- [exo documentation](https://docs.xfce.org/xfce/exo/start)
- [Development Standards - Tool Selection](../Development-Standards.md#tool-selection)

## Future Considerations

1. **Terminal launcher**: Create `dots-terminal` wrapper for `exo-open --launch TerminalEmulator`
2. **Web browser launcher**: Create `dots-webbrowser` wrapper for `exo-open --launch WebBrowser`
3. **Per-rice defaults**: Rice system could suggest default apps (e.g., cyberpunk rice suggests neon terminals)
4. **Validation**: Add checks in `dots-default-apps` to ensure selected apps are installed

## See Also

- [ADR 003: EasyOptions Standard](003-easyoptions-standard.md) - dots-default-apps follows these patterns
- [Integration Patterns](../Integration-Patterns.md) - XDG integration guidelines
- [Security Guidelines](../Security-Guidelines.md) - Input validation for MIME types
