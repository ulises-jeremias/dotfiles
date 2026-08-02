# ADR-002: Modular Rice System Architecture

## Status

Accepted (updated 2026-08-02)

## Context

Desktop theming and customization is a core feature of HorneroConfig. Users need the ability to:

- Switch between different visual themes ("rices") easily
- Share and distribute custom themes
- Apply consistent theming across all applications
- Maintain theme-specific configurations for different use cases

Traditional dotfiles approaches often hardcode visual settings, making theme switching cumbersome and error-prone. An earlier shell-centric design used per-rice `apply.sh` scripts and a single `.current_rice` file; the maintained path is now Quickshell-first.

## Decision

We keep a modular rice system with the following architecture:

- **Rice Directory Structure**: Each rice lives in `~/.local/share/dots/rices/<rice-name>/`
- **Canonical config**: `config.json` (Quickshell + `list-rices.py`); `config.sh` remains a shell mirror for GTK/snappy/lockscreen helpers
- **Orchestrator**: Quickshell `Rice.qml` (IPC) with a shared shell fallback (`apply-appearance.sh`) when QS is down
- **Central state**:
  - Rice id: `~/.local/state/dots/rice/current` (mirrored to `.current_rice` for legacy readers)
  - Wallpaper: `~/.local/state/dots/wallpaper/path`
  - Scheme prefs: `~/.local/state/dots/scheme/state.json` kept in sync with `scheme.json` via `dots-color-scheme sync-state`
- **CLI**: `dots appearance …` (canonical) / `dots rice …` (compat), plus `dots appearance doctor`

Key components:

- `Rice.qml` / `Wallpapers.qml` / `Colours.qml`
- `dots-appearance`, `dots-rice`, `dots-wallpaper-set`, `dots-color-scheme`
- `rice-state.sh`, `apply-appearance.sh`, `wallpaper-resolver.sh`
- Integration with pywal + Material You (`generate-m3-colors.py`)

## Consequences

### Positive

- **Easy Theme Switching**: One command / control-center Apply changes the desktop theme
- **Modular Design**: Each rice is self-contained and portable
- **Consistency**: QS UI, CLI, boot regenerate, lockscreen, and GTK share the same pointers
- **Offline apply**: Shell fallback works without Quickshell

### Negative

- **Complexity**: More moving parts than a single config file
- **Dual config formats**: `config.json` + `config.sh` must stay aligned for shell consumers
- **Learning Curve**: Contributors need to understand the state table above

### Neutral

- Legacy `.current_rice` is a **mirror**, not an independent source of truth
- Per-rice `apply.sh` is **not** part of the maintained path
