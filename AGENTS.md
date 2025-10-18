# AI Agent Guidelines for HorneroConfig

> **For AI coding assistants and automated tools**  
> **Last Updated**: 2025-10-18

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
- **Polybar** - Profile-based modular status bar
- **EWW** - Declarative widgets with SCSS styling
- **Dots CLI** - Unified script interface

See [System Architecture](docs/System-Architecture.md) for detailed architecture.

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
