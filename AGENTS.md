# AI Agent Guidelines for HorneroConfig

> **For AI coding assistants and automated tools**  
> **Last Updated**: 2026-02-27

## Purpose

This is the authoritative guide for AI agents working on HorneroConfig. Follow the Hornero Bird philosophy: build **robust**, **functional**, **adaptable**, **beautiful**, and **modular** environments.

## Quick Reference

### Core Principles (The Hornero Way)

1. **Theme-Adaptive** - All visuals adapt to any color palette automatically
2. **Modular** - Components work independently yet integrate seamlessly  
3. **Single Source of Truth** - Configuration flows from centralized sources
4. **Graceful Degradation** - Function even with missing dependencies
5. **Security by Default** - Never commit secrets, validate all inputs

See [Architecture Philosophy](docs/Architecture-Philosophy.md) for detailed principles.

### Essential Standards

**Scripts Must:**
- Use EasyOptions for CLI parsing
- Include `set -euo pipefail`
- Follow naming: `dots-*` for user scripts, `snake_case` for functions/vars
- Handle errors gracefully with logging
- Work without optional dependencies (fallbacks required)

See [Development Standards](docs/Development-Standards.md) for complete requirements.

### Key Systems

- **Rice System** - Self-contained themes in `~/.local/share/dots/rices/`
- **Smart Colors** - Semantic color adaptation cached in `~/.cache/dots/smart-colors/`
- **Quickshell** - Unified QML desktop shell (bar, launcher, dashboard, notifications, AI chat)
- **Hornero C++ Plugin** - Performance-critical Quickshell extensions (image analysis, audio, calculator)
- **Dots CLI** - Unified script interface
- **Chaotic-AUR** - Precompiled AUR packages for faster installation

See [System Architecture](docs/System-Architecture.md) for detailed architecture.

### Installation & Package Management

**Chezmoi Scripts Execution Order:**

- `000-aaa-chaotic-aur.sh` - Configure Chaotic-AUR repository first
- `000-aur-helper.sh` - Install yay AUR helper
- Other scripts follow alphabetically

**Chaotic-AUR Benefits:**

- Precompiled binaries for popular AUR packages
- 50-70% faster installation times
- Automatically configured during `chezmoi apply`
- No manual intervention required

See [Chaotic-AUR docs](https://aur.chaotic.cx/docs) for repository details.

## Documentation Index

- **[Architecture Philosophy](docs/Architecture-Philosophy.md)** - Design principles and philosophy
- **[System Architecture](docs/System-Architecture.md)** - Major subsystems explained
- **[Development Standards](docs/Development-Standards.md)** - Script templates, naming, error handling
- **[Integration Patterns](docs/Integration-Patterns.md)** - Chezmoi, WM detection, daemons, colors
- **[Testing Strategy](docs/Testing-Strategy.md)** - Playground usage, test requirements
- **[Security Guidelines](docs/Security-Guidelines.md)** - Secret management, validation, permissions
- **[Performance Guidelines](docs/Performance-Guidelines.md)** - Caching, optimization, best practices

For architectural decisions, see [ADRs](docs/adrs/).  
For human contributors, see [CONTRIBUTING.md](CONTRIBUTING.md).
