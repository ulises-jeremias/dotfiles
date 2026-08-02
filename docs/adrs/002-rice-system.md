# ADR-002: Modular Rice System Architecture

## Status

Accepted (updated 2026-08-02 — legacy shell rice path removed)

## Context

Desktop theming is a core HorneroConfig feature. The earlier shell-centric design (`config.sh`, `apply.sh`, `.current_rice`) duplicated state with the Quickshell-first path and caused desync. We keep modular rices but drop the legacy shell dual-write model.

## Decision

- **Rice directory**: `~/.local/share/dots/rices/<rice-name>/`
- **Sole config**: `config.json`
- **Orchestrator**: Quickshell `Rice.qml` (IPC) + `apply-appearance.sh` shell fallback
- **State**:
  - Rice id: `~/.local/state/dots/rice/current` only
  - Wallpaper: `~/.local/state/dots/wallpaper/path`
  - Palette: `~/.cache/dots/smart-colors/scheme.json`
  - Scheme prefs: `~/.local/state/dots/scheme/state.json` synced via `dots-color-scheme sync-state`
- **CLI**: `dots appearance …` (+ `dots rice …` alias), `dots appearance doctor`

Removed from the maintained path: `.current_rice`, `~/.cache/dots/current_rice`, per-rice `config.sh` / `apply.sh`, wallpaper cache pointer fallback.

## Consequences

### Positive

- One source of truth for rice / wallpaper / scheme meta
- QS UI, CLI, boot regenerate, lockscreen, GTK, snappy share the same pointers
- Offline apply without Quickshell

### Negative

- Shell helpers that previously sourced `config.sh` must read JSON
- Existing external forks that still ship only `config.sh` need a `config.json`

### Neutral

- `dots rice` naming remains as a thin alias
