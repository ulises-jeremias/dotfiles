# Documentation Index

> **📚 HorneroConfig documentation directory**

## 📑 Technical Documentation

### For AI Agents & Developers

- **[Architecture Philosophy](Architecture-Philosophy.md)** - Design principles and the Hornero Bird philosophy
- **[System Architecture](System-Architecture.md)** - Detailed architecture of major subsystems
- **[Development Standards](Development-Standards.md)** - Shell script requirements and best practices
- **[Integration Patterns](Integration-Patterns.md)** - Chezmoi, window managers, daemons, and color systems
- **[Testing Strategy](Testing-Strategy.md)** - Playground environment and testing requirements
- **[Security Guidelines](Security-Guidelines.md)** - Secret management, validation, and permissions
- **[Performance Guidelines](Performance-Guidelines.md)** - Caching strategies and optimization

### Architecture Decision Records (ADRs)

- **[ADR-001: Chezmoi Adoption](adrs/001-chezmoi-adoption.md)** - Dotfiles management approach
- **[ADR-002: Appearance System and Theme Packs](adrs/002-rice-system.md)** - Modular theme system design
- **[ADR-003: EasyOptions Standard](adrs/003-easyoptions-standard.md)** - CLI argument parsing
- **[ADR-004: Testing Strategy](adrs/004-testing-strategy.md)** - Docker vs Vagrant environments
- **[ADR-005: Smart Colors Integration](adrs/005-smart-colors-centralized-integration.md)** - Color caching system

## 📖 User Documentation

### Wiki

The `wiki/` directory contains comprehensive user-facing guides:

- **Window Manager**: Hyprland
- **Components**: Quickshell (primary shell), Hyprland, Kitty
- **Theming**: Appearance themes, smart colors, wallpapers
- **Tools**: Dots scripts, backup, security
- **Customization**: Personalization guides

See [wiki/Home.md](wiki/Home.md) for the complete wiki index.

## 🚀 Quick Navigation

### For Users

- [Main README](../README.md) - Project overview
- [Installation Guide](wiki/Home.md#-quick-installation) - Get started
- [Contributing Guide](../CONTRIBUTING.md) - How to contribute
- [Security Policy](../SECURITY.md) - Security practices

### For AI Agents

- [AGENTS.md](../AGENTS.md) - AI agent quick reference
- Technical docs (above) - Architectural deep-dives

## 📂 Directory Structure

```txt
docs/
├── README.md                    # This file
├── Architecture-Philosophy.md   # Design principles
├── System-Architecture.md       # System components
├── Development-Standards.md     # Coding standards
├── Integration-Patterns.md      # Integration guides
├── Testing-Strategy.md          # Testing approach
├── Security-Guidelines.md       # Security practices
├── Performance-Guidelines.md    # Optimization strategies
├── adrs/                        # Architecture Decision Records
│   ├── README.md
│   ├── 001-chezmoi-adoption.md
│   ├── 002-rice-system.md
│   ├── 003-easyoptions-standard.md
│   ├── 004-testing-strategy.md
│   └── 005-smart-colors-centralized-integration.md
├── images/                      # Documentation images
└── wiki/                        # User-facing documentation
    ├── Home.md
    ├── Customization.md
    ├── Smart-Colors-System.md
    └── ... (100+ wiki pages)
```

## External Resources

- [Chezmoi Documentation](https://www.chezmoi.io/)
- [Arch Wiki - Window Manager](https://wiki.archlinux.org/title/Window_manager)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Quickshell Documentation](https://quickshell.org/docs/)
- [Arch Wiki](https://wiki.archlinux.org/)

---

*For questions, see [GitHub Discussions](https://github.com/ulises-jeremias/dotfiles/discussions)*
