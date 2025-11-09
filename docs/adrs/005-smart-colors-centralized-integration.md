# ADR-005: Smart Colors Centralized Integration

## Status

Accepted

## Context

The `dots-smart-colors` system generates theme colors for all applications in the HorneroConfig environment.

### Key Requirements

1. **Performance**: Fast color generation with efficient caching
2. **Centralized Management**: Unified approach for all applications
3. **Cache Strategy**: Consistent cache management across applications
4. **Format Support**: Different output formats for various applications

## Decision

We implemented a centralized smart colors system with the following architecture:

### 1. Centralized Output Directory

- All smart color files are generated in `~/.cache/dots/smart-colors/`
- Consistent with pywal's approach (`~/.cache/wal/`)

### 2. Format-Specific Files

- `colors-i3.conf`: i3 client color directives with actual color values (not variables)
- `colors-eww.scss`: SCSS variables for EWW widgets
- `colors.sh`: Shell variables for scripts
- `colors.env`: Environment variables for applications like Polybar

### 3. Symbolic Links Strategy

- `~/.config/i3/config.d/smart-colors.conf` → centralized i3 file
- `~/.config/eww/dashboard/smart-colors.scss` → centralized EWW file
- `~/.config/eww/powermenu/smart-colors.scss` → centralized EWW file

### 4. Application Integration

Smart colors are integrated with different applications using their native formats:

```sh
# Direct color values for immediate application
client.focused #2e9ef4 #2e9ef4 #191c21 #83a598 #2e9ef4
```

## Implementation Details

### Modified Components

1. **`dots-smart-colors`**:

   - Added `--generate` flag for all formats
   - Centralized cache directory: `~/.cache/dots/`
   - Generate format-specific files with symbolic link creation

2. **`dots-wal-reload`**:

   - Uses `dots-smart-colors --generate` instead of `--export`
   - Sources `colors.env` for environment variables
   - Enhanced application reloading logic

3. **i3 Configuration**:

   - `colors.conf` includes `smart-colors.conf` with actual color directives
   - No variable expansion required

4. **EWW Configuration**:

   - Dashboard and powermenu import `smart-colors.scss`
   - SCSS variables work correctly with @import

5. **Polybar Configuration**:
   - Enhanced smart colors loading in `default.sh` profile
   - Fallback strategy: cache → generate → default export

## Consequences

### Positive

- **Performance**: Smart colors are pre-generated and cached
- **Consistency**: All applications use the same centralized color source
- **Reliability**: Direct color values for immediate application
- **Maintainability**: Single source of truth for smart colors

### Negative

- **Complexity**: More files to manage in cache directory
- **File Management**: Multiple format-specific files need coordination

## Testing

A comprehensive test script (`scripts/test-smart-colors-integration.sh`) verifies:

- Smart color file generation
- Symbolic link creation
- i3 configuration syntax validation
- EWW configuration validation
- Polybar integration verification

## Future Considerations

1. **Performance Optimization**: The centralized approach enables future optimizations
2. **Cache Invalidation**: Improved cache validation against wallpaper changes
3. **Application Support**: Easy to add new applications to the smart colors system
4. **Hot Reloading**: Better integration with theme switching workflows
