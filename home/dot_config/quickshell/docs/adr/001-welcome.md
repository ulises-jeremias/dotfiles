# ADR 001 — Hornero Welcome: first frontend in HorneroOS/shell, state in HorneroOS/hornero

Date: 2026-09-15
Status: accepted

## Context

HorneroOS needs a first-login Welcome Center: an interactive entry point
where a new user discovers what the system can do and tries it. The
Welcome concept must outlive any single desktop session type, but Phase 1
ships exactly one session: Hyprland + Hornero Shell.

## Decision

1. **The first frontend lives in HorneroOS/shell** (`modules/welcome/`,
   a dedicated top-level window, not a Control Center pane). The shell
   already owns the desktop UI components, the Appearance System,
   launcher/dashboard/control-center integration, live Shell IPC, and the
   graphical VM harness. A new repository would duplicate all of that for
   one window.

2. **The persistent Welcome contract is NOT Shell-owned.** State schema,
   file location, and mutation semantics live in HorneroOS/hornero
   (`cli/modules/hornero_core/welcome.v`, `horneroctl welcome ...`,
   `docs/PATH_CONTRACT.md` row 13). The state file
   (`$XDG_STATE_HOME/hornero/welcome/state.json`) is the single source of
   truth every frontend reads; the Shell reads it directly at startup
   (never a subprocess before first paint) and writes through
   `horneroctl welcome ... --yes` (single writer, atomic renames).

3. **No new `HorneroOS/welcome` repository yet.** The concept earns a
   standalone cross-desktop component only when a second desktop/session
   needs a frontend or independent lifecycle/versioning — not before.

## Split (extraction boundary)

Hornero-wide (moves with the concept, never migrated):
state schema + file path, show-on-login semantics, content revisions,
generic capability IDs (`shell.hornero`, `compositor.hyprland`, ...),
the `horneroctl welcome` contract, shortcut-manifest schema.

Hornero Shell-specific (stays if Welcome is extracted):
Quickshell window + navigation + visual components, the QML content
catalog, the shell feature provider, Shell IPC actions
(`welcome.open/close/status`, `controlCenter.open(pane)` deep links),
the `$XDG_RUNTIME_DIR` session guard, the `.desktop` entry Exec target.

## Consequences

- A future frontend reimplements only the Shell-specific half against
  the unchanged state file; `showOnLogin=false` keeps winning across
  frontends and content updates.
- The Shell must degrade when `horneroctl` is absent (in-memory
  preference, warning) and never crash on malformed state.
- Content stays data-driven with typed allowlisted actions; no arbitrary
  commands, no network at render, no telemetry, no `dots-*` paths.
