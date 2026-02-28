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

- `scheme.json`: Material Design 3 palette for Quickshell
- `colors.sh`: Shell variables for scripts
- `colors.env`: Environment variables for applications

### 3. Application Integration

Smart colors are integrated with different applications using their native formats:

```css
/* Generic CSS export variables for web-based widgets */
--accent: #2e9ef4;
--info: #83a598;
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

3. **Hyprland Configuration**:
   - Colors loaded via environment variables
   - Immediate application without restart

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
- Quickshell scheme generation
- Hyprland integration verification

## Future Considerations

1. **Performance Optimization**: The centralized approach enables future optimizations
2. **Cache Invalidation**: Improved cache validation against wallpaper changes
3. **Application Support**: Easy to add new applications to the smart colors system
4. **Hot Reloading**: Better integration with theme switching workflows
