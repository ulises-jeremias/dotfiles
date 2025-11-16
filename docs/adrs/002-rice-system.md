# ADR-002: Modular Rice System Architecture

## Status

Accepted

## Context

Desktop theming and customization is a core feature of HorneroConfig. Users need the ability to:

- Switch between different visual themes ("rices") easily
- Share and distribute custom themes
- Apply consistent theming across all applications
- Maintain theme-specific configurations for different use cases

Traditional dotfiles approaches often hardcode visual settings, making theme switching cumbersome and error-prone.

## Decision

We implemented a modular rice system with the following architecture:

- **Rice Directory Structure**: Each rice lives in `~/.local/share/dots/rices/<rice-name>/`
- **Configuration Files**: Each rice has a `config.sh` with theme-specific settings
- **Apply Scripts**: Each rice has an `apply.sh` script for theme activation
- **Central Management**: A `.current_rice` file tracks the active theme
- **Rofi Integration**: `dots rofi-rice-selector` provides visual theme switching

Key components:

- `dots-rice-config.sh` - Core rice management library
- Individual rice directories with modular configurations
- Integration with pywal, waybar, and other theming tools

## Consequences

### Positive

- **Easy Theme Switching**: Users can change entire desktop themes with one command
- **Modular Design**: Each rice is self-contained and portable
- **Consistency**: All applications follow the same theming approach
- **Extensibility**: New rices can be added without modifying core code
- **Sharing**: Rices can be easily shared between users

### Negative

- **Complexity**: More complex than simple configuration files
- **Duplication**: Some settings may be duplicated across rices
- **Learning Curve**: Users need to understand the rice system structure

### Neutral

- **Directory Structure**: Requires specific organization in user directories
- **Dependencies**: Relies on external tools like pywal for color generation
