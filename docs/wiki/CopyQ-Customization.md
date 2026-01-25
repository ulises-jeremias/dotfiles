# 📋 CopyQ Clipboard Manager Customization

CopyQ is a powerful clipboard manager integrated with HorneroConfig's smart-colors system, providing theme-adaptive styling that automatically matches your current color scheme.

> [!TIP]
> CopyQ automatically adapts to your current theme colors when you change wallpapers via `wpg` or run `dots-wal-reload`.

---

## 🎨 Visual Customization

### Smart Colors Integration

CopyQ's appearance is automatically themed using the **smart-colors system**:

- **Automatic Theme Adaptation**: Colors update when you change wallpapers
- **Semantic Colors**: Uses theme-adaptive error, warning, success, info, and accent colors
- **Consistent Design**: Follows HorneroConfig design principles (rounded corners, spacing, etc.)

### Design Principles

The CopyQ theme follows HorneroConfig's visual guidelines:

- **Rounded Corners**: 12px border-radius matching Hyprland decoration
- **Consistent Spacing**: 8px padding and margins for comfortable UI
- **Smooth Transitions**: 0.2s ease transitions for interactive elements
- **Theme-Adaptive Colors**: All colors adapt to light/dark themes automatically

---

## ⚙️ Configuration

### Files Location

- **Configuration**: `~/.config/copyq/copyq.conf` (managed by chezmoi)
- **Theme File**: `~/.config/copyq/themes/hornero-smart-colors.ini` (auto-generated)
- **Cache**: `~/.cache/dots/smart-colors/colors-copyq.ini` (source file)

### Automatic Generation

The CopyQ theme file (`.ini` format) is automatically generated when you:

1. Change wallpapers via `wpg`
2. Run `dots-wal-reload`
3. Run `dots-smart-colors --generate`

The generated theme file is cached in `~/.cache/dots/smart-colors/colors-copyq.ini` and symlinked to `~/.config/copyq/themes/hornero-smart-colors.ini`.

### Applying the Theme

To use the smart-colors theme in CopyQ:

1. **Via GUI**: Open CopyQ → Preferences → Appearance → Select "hornero-smart-colors" from the theme dropdown
2. **Via Configuration**: The theme will be available in CopyQ's appearance settings after generation

---

## 🔧 Customization

### Modifying the Theme

To customize CopyQ's appearance:

1. **Regenerate the theme**:
   ```bash
   dots-smart-colors --generate
   ```

2. **Edit the theme file** (if needed):
   ```bash
   $EDITOR ~/.config/copyq/themes/hornero-smart-colors.ini
   ```

3. **Reload CopyQ**:
   - Open CopyQ → Preferences → Appearance → Click "OK" to reload
   - Or restart CopyQ: `copyq exit && copyq &`

### Available Theme Variables

The theme file uses these smart-colors placeholders:

- `bg` - Primary background color
- `fg` - Primary foreground/text color
- `alt_bg` - Alternative background color
- `alt_fg` - Alternative foreground color
- `sel_bg` - Selection background color (uses accent color)
- `sel_fg` - Selection foreground color
- `edit_bg`, `edit_fg` - Editor colors
- `find_bg`, `find_fg` - Search bar colors
- `notes_bg`, `notes_fg` - Notes editor colors
- `num_fg` - Number color

### Customizing CSS Files

CopyQ uses CSS files from `/usr/share/copyq/themes/` (or `~/.config/copyq/themes/` for overrides). The CSS files use placeholders like `${bg}`, `${fg}`, etc. that are defined in the `.ini` theme file.

To customize CSS:

1. Copy the CSS file you want to modify:
   ```bash
   cp /usr/share/copyq/themes/items.css ~/.config/copyq/themes/
   ```

2. Edit the CSS file (it will use placeholders from the theme `.ini`)

3. Reload CopyQ to apply changes

---

## 🚀 Usage

### Basic Commands

```bash
# Show CopyQ window
copyq show

# Hide CopyQ window
copyq hide

# Toggle visibility
copyq toggle

# Open context menu
copyq menu

# Exit CopyQ server
copyq exit
```

### Integration with Dots Scripts

CopyQ is integrated with the `dots-clipboard` script:

```bash
# Launch clipboard manager (auto-detects CopyQ)
dots-clipboard

# Force CopyQ backend
dots-clipboard --backend=copyq
```

---

## 📋 Features

### Visual Features

- **Theme-Adaptive Colors**: Automatically matches your current theme
- **Rounded Corners**: Modern 12px border-radius
- **Smooth Animations**: 0.2s transitions for all interactive elements
- **Hover Effects**: Visual feedback on hover
- **Focus Indicators**: Clear focus states using accent color

### Functional Features

- **Clipboard History**: Stores up to 200 items (configurable)
- **Search**: Filter items by text content
- **Tags**: Organize items with tags
- **Pinned Items**: Pin important items
- **Encryption**: Encrypt sensitive clipboard items
- **Sync**: Sync clipboard across devices

---

## 🔄 Automatic Updates

CopyQ's theme automatically updates when:

1. **Wallpaper Changes**: Running `wpg` or changing wallpapers triggers `dots-wal-reload`
2. **Manual Reload**: Running `dots-wal-reload` manually
3. **Smart Colors Regeneration**: Running `dots-smart-colors --generate`

The CSS is regenerated from the template with current theme colors and symlinked to CopyQ's config directory.

---

## 🐛 Troubleshooting

### Theme Not Applying

If CopyQ's theme doesn't update:

1. **Check theme file exists**:
   ```bash
   ls -la ~/.config/copyq/themes/hornero-smart-colors.ini
   ```

2. **Regenerate theme**:
   ```bash
   dots-smart-colors --generate
   ```

3. **Select theme in CopyQ**:
   - Open CopyQ → Preferences → Appearance
   - Select "hornero-smart-colors" from theme dropdown
   - Click "OK" to apply

4. **Restart CopyQ** (if needed):
   ```bash
   copyq exit
   copyq &
   ```

### Colors Not Matching Theme

If colors don't match your current theme:

1. **Regenerate smart colors**:
   ```bash
   dots-smart-colors --generate
   ```

2. **Check theme file**:
   ```bash
   cat ~/.cache/dots/smart-colors/colors-copyq.ini
   ```

3. **Reload theme in CopyQ**:
   - Open Preferences → Appearance → Click "OK"

---

## 📚 Related Documentation

- [Smart Colors System](Smart-Colors-System.md) - Theme-adaptive color system
- [Dots Scripts](Dots-Scripts.md) - Clipboard management scripts
- [Hyprland Setup](Hyprland-Setup.md) - Window manager configuration

---

## 🎯 Design Alignment

CopyQ's theme aligns with HorneroConfig's design principles:

- ✅ **Theme-Adaptive**: Colors adapt to any palette automatically
- ✅ **Modular**: CSS template can be customized independently
- ✅ **Single Source of Truth**: Colors come from smart-colors system
- ✅ **Graceful Degradation**: Falls back to default Qt styling if CSS fails
- ✅ **Security by Default**: No hardcoded secrets or sensitive data

---

## 📝 Notes

- CopyQ uses a theme system with `.ini` files that define color placeholders
- CSS files use placeholders like `${bg}`, `${fg}`, etc. that reference the theme `.ini`
- The theme file is generated by `dots-smart-colors --generate` with current smart-colors
- The generated theme is cached in `~/.cache/dots/smart-colors/` and symlinked to CopyQ's themes directory
- CopyQ must reload the theme (via Preferences → Appearance → OK) or restart for changes to take effect
- The theme file follows CopyQ's standard `.ini` format with placeholders for colors, fonts, and CSS customizations
