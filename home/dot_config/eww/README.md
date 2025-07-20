# Enhanced EWW Launch Scripts

This directory contains improved, robust launch scripts for managing EWW (ElKowar's Wacky Widgets) components in your dotfiles setup.

## Overview

The enhanced scripts provide comprehensive widget management with advanced features like logging, error handling, state management, and cleanup capabilities.

## Components

### 📦 Available Components

1. **Dashboard** (`~/.config/eww/dashboard/`)

   - Main dashboard interface with system information, weather, music, shortcuts
   - Widgets: background, profile, system, clock, uptime, music, github, youtube, weather, mail, power controls, folders, placeholder

2. **Powermenu** (`~/.config/eww/powermenu/`)

   - Power management interface for lock, logout, sleep, reboot, shutdown
   - Widgets: background, clock, uptime, lock, logout, sleep, reboot, poweroff, placeholder

3. **Sidebar** (`~/.config/eww/sidebar/`)

   - Side panel interface (currently under development)
   - Widgets: main, toggle, calendar, weather, system-info, shortcuts

4. **Universal Manager** (`~/.config/eww/eww-manager.sh`)
   - Centralized management for all EWW components
   - Cross-component operations and system-wide status

## Script Features

### 🚀 Enhanced Capabilities

- **Robust Error Handling**: Comprehensive error checking and graceful failures
- **Advanced Logging**: Detailed logging with automatic rotation and cleanup
- **Process Management**: Lock files prevent multiple instances and handle cleanup
- **State Management**: Track widget states and validate operations
- **Daemon Management**: Intelligent EWW daemon handling with retry logic
- **Resource Cleanup**: Automatic cleanup of orphaned processes and stale files
- **Flexible Operations**: Support for individual widgets or batch operations
- **Status Monitoring**: Real-time status of all components and widgets

### 📝 Logging System

All scripts maintain detailed logs in `~/.cache/eww/`:

- `dashboard.log` - Dashboard operations
- `powermenu.log` - Powermenu operations
- `sidebar.log` - Sidebar operations
- `manager.log` - Universal manager operations

Logs automatically rotate when they exceed 1MB and old logs are cleaned after 7 days.

## Usage Examples

### Individual Component Management

```bash
# Dashboard
~/.config/eww/dashboard/launch.sh                    # Toggle all dashboard widgets
~/.config/eww/dashboard/launch.sh open              # Open all dashboard widgets
~/.config/eww/dashboard/launch.sh close             # Close all dashboard widgets
~/.config/eww/dashboard/launch.sh status            # Show dashboard status
~/.config/eww/dashboard/launch.sh open dashboard-clock  # Open specific widget

# Powermenu
~/.config/eww/powermenu/launch.sh                   # Toggle powermenu
~/.config/eww/powermenu/launch.sh status            # Show powermenu status

# Sidebar
~/.config/eww/sidebar/launch.sh status              # Check sidebar configuration
```

### Universal Manager

```bash
# System-wide operations
~/.config/eww/eww-manager.sh status                 # Show all component status
~/.config/eww/eww-manager.sh list                   # List all components and widgets
~/.config/eww/eww-manager.sh toggle dashboard       # Toggle dashboard
~/.config/eww/eww-manager.sh open powermenu         # Open powermenu
~/.config/eww/eww-manager.sh -a toggle              # Toggle all components
~/.config/eww/eww-manager.sh daemon restart         # Restart EWW daemon
~/.config/eww/eww-manager.sh cleanup                # Clean up all processes
```

### Advanced Options

```bash
# Debug mode
./launch.sh -d toggle                               # Enable debug logging

# Quiet mode
./launch.sh -q open                                 # Suppress output

# Force operation
./launch.sh -f toggle                               # Force even if locked

# Help
./launch.sh --help                                  # Show detailed help
```

## Daemon Management

### Automatic Daemon Handling

All scripts automatically:

- Check if EWW daemon is running
- Start daemon if needed with retry logic
- Handle daemon failures gracefully
- Provide daemon restart capabilities

### Manual Daemon Control

```bash
# Start daemon
./launch.sh daemon start

# Stop daemon
./launch.sh daemon stop

# Restart daemon
./launch.sh daemon restart
```

## Integration with Window Manager

### i3 Integration

The scripts are integrated with your i3 configuration:

```bash
# Dashboard toggle (Mod+d)
bindsym $Mod+d exec --no-startup-id ~/.config/eww/dashboard/launch.sh

# Powermenu toggle (Mod+x)
bindsym $Mod+x exec --no-startup-id ~/.config/eww/powermenu/launch.sh
```

### Additional Keybindings

Consider adding these keybindings to your i3 config:

```bash
# Sidebar toggle
bindsym $Mod+s exec --no-startup-id ~/.config/eww/sidebar/launch.sh

# EWW status
bindsym $Mod+Shift+e exec --no-startup-id ~/.config/eww/eww-manager.sh status

# EWW cleanup
bindsym $Mod+Shift+Ctrl+e exec --no-startup-id ~/.config/eww/eww-manager.sh cleanup
```

## Troubleshooting

### Common Issues

1. **Daemon Won't Start**

   ```bash
   ~/.config/eww/eww-manager.sh daemon restart
   ~/.config/eww/eww-manager.sh cleanup
   ```

2. **Widgets Not Appearing**

   ```bash
   ~/.config/eww/dashboard/launch.sh status
   ~/.config/eww/dashboard/launch.sh -d open        # Debug mode
   ```

3. **Multiple Instances Running**

   ```bash
   ~/.config/eww/eww-manager.sh cleanup
   ~/.config/eww/dashboard/launch.sh -f toggle      # Force operation
   ```

4. **Check Logs**
   ```bash
   tail -f ~/.cache/eww/dashboard.log
   tail -f ~/.cache/eww/manager.log
   ```

### Process Management

```bash
# Check running EWW processes
ps aux | grep eww

# Kill all EWW processes (emergency)
pkill -f eww

# Clean up automatically
~/.config/eww/eww-manager.sh cleanup
```

## Configuration Structure

```
~/.config/eww/
├── dashboard/
│   ├── launch.sh*          # Enhanced dashboard launcher
│   ├── eww.yuck           # Dashboard widgets
│   ├── eww.scss           # Dashboard styles
│   └── scripts/           # Dashboard helper scripts
├── powermenu/
│   ├── launch.sh*          # Enhanced powermenu launcher
│   ├── eww.yuck           # Powermenu widgets
│   ├── eww.scss           # Powermenu styles
│   └── scripts/           # Powermenu helper scripts
├── sidebar/
│   ├── launch.sh*          # Enhanced sidebar launcher
│   ├── assets/            # Sidebar assets
│   └── scripts/           # Sidebar scripts
└── eww-manager.sh*         # Universal EWW manager

~/.cache/eww/
├── dashboard.log           # Dashboard operation logs
├── powermenu.log          # Powermenu operation logs
├── sidebar.log            # Sidebar operation logs
└── manager.log            # Universal manager logs
```

## Development Notes

### Script Architecture

Each launch script follows a consistent architecture:

- Configuration constants at the top
- Utility functions for common operations
- Main function with argument parsing
- Modular design for easy maintenance

### Adding New Components

To add a new EWW component:

1. Create component directory: `~/.config/eww/newcomponent/`
2. Copy and modify an existing launch script
3. Update widget lists and configuration paths
4. Add component to `eww-manager.sh` mappings
5. Test thoroughly with status and debug modes

### Customization

Scripts are designed to be easily customizable:

- Widget lists are defined as arrays at the top
- Configuration paths use variables
- Logging and behavior can be modified in utility functions

## Performance Considerations

- Lock files prevent resource conflicts
- Automatic cleanup prevents resource leaks
- Log rotation prevents disk space issues
- Efficient daemon management minimizes startup time
- Widget validation prevents unnecessary operations

## Security Notes

- Scripts use `set -euo pipefail` for safe execution
- Lock files include PID validation
- Process cleanup is careful to avoid killing unrelated processes
- Logging doesn't expose sensitive information

---

For more information about EWW itself, visit: https://github.com/elkowar/eww
