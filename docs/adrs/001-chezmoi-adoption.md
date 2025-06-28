# ADR-001: Use Chezmoi for Dotfiles Management

## Status

Accepted

## Context

Managing dotfiles across multiple machines and environments is challenging. We needed a solution that could:

- Handle templating for machine-specific configurations
- Manage secrets securely
- Work across different operating systems
- Provide version control integration
- Allow easy customization and forking

Previous approaches using symlinks or simple git repositories lacked the flexibility needed for a comprehensive dotfiles framework.

## Decision

We adopted [Chezmoi](https://www.chezmoi.io/) as our primary dotfiles management tool.

Key factors in this decision:

- **Template Support**: Powerful Go templating for dynamic configurations
- **Secret Management**: Built-in support for password managers and encrypted files  
- **Cross-Platform**: Works on Linux, macOS, Windows
- **Git Integration**: Seamless integration with version control
- **Active Development**: Well-maintained with regular updates

## Consequences

### Positive

- Simplified multi-machine setup with single command installation
- Template-based configurations reduce duplication
- Secure handling of sensitive data
- Easy forking and customization for users
- Professional-grade dotfiles management

### Negative

- Additional dependency (chezmoi must be installed)
- Learning curve for contributors unfamiliar with chezmoi
- Some file naming conventions (dot_ prefix) may be confusing initially

### Neutral

- Migration required from previous dotfiles structure
- Documentation updates needed to explain chezmoi-specific features
