# ADR-005: Smart Colors Centralized Integration

## Status

Accepted

## Context

The `dots-smart-colors` system was previously generating colors on-demand which caused performance issues when cache wasn't used. Additionally, the integration with i3, EWW, and Polybar was inconsistent and didn't follow a centralized approach.

### Key Issues Identified:

1. **Performance**: Without cache, `dots-smart-colors` was "super lento" (very slow)
2. **i3 Variable Limitation**: i3 cannot expand variables defined in included files
3. **Inconsistent Integration**: Each application had different ways of consuming smart colors
4. **Cache Strategy**: No unified cache management across applications

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

### 4. i3 Integration Solution

Since i3 cannot expand variables from included files, we generate actual color values:

```
# Instead of variables:
# set $smart_accent #color
# client.focused $smart_accent ...

# We generate direct values:
client.focused #2e9ef4 #2e9ef4 #191c21 #83a598 #2e9ef4
```

## Implementation Details

### Modified Components:

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
   - Fallback strategy: cache → generate → legacy export

## Consequences

### Positive:

- **Performance**: Smart colors are pre-generated and cached
- **Consistency**: All applications use the same centralized color source
- **Reliability**: No dependency on variable expansion limitations
- **Maintainability**: Single source of truth for smart colors

### Negative:

- **Complexity**: More files to manage in cache directory
- **i3 Limitation**: Cannot use elegant variable syntax in i3 config

### Migration Required:

- Users need to run `dots-smart-colors --generate` after applying changes
- Existing i3 configurations with smart color variables need updates

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

## References

- [i3 User Guide - Variables](https://i3wm.org/docs/userguide.html#variables)
- [i3 User Guide - Include directive](https://i3wm.org/docs/userguide.html#include)
- [GitHub Issue #4192 - i3 include limitations](https://github.com/i3/i3/issues/4192)
- [i3 FAQ - Variable limitations](https://faq.i3wm.org/question/5537/colors-from-xdefaults.1.html)
