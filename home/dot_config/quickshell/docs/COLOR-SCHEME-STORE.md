# Color-scheme / M3 store decision — track 3a

Question: keep scheme and M3 palette state behind the `dots-color-scheme` /
`dots-m3-colors` CLIs, or add a native palette store in the shell?

## Decision: keep the CLI, no native store

Scheme list/current/set/mode/variant ops stay on `dots-color-scheme` and
full M3 palette generation stays on `dots-m3-colors` (thin, debt-marked
compat adapters; see `docs/COMPAT.md` disposition A). The shell adds no
palette persistence of its own.

## Why

1. **Generation dependency lives outside this repo.** Full M3 palettes need
   `materialyoucolor`, which the shell cannot import (QML-only runtime).
   A native store would still shell out for generation, gaining nothing.
2. **Persistence already has an owner.** `dots-color-scheme` owns scheme
   persistence; the shell reads the cached result (`scheme.json` under
   `Paths.cache/smart-colors/`) through a `FileView` watcher, so the UI
   stays live without owning writes.
3. **Latency-sensitive paths are already native.** Instant wallpaper tone
   (translucency layering, preview swatches) comes from the `ImageAnalyser`
   plugin via `services/WallpaperAnalysis.qml` and
   `Colours.wallLuminance`/`wallDominantColour` — no CLI round-trip. Only
   the full generated palette waits on the CLI job.
4. **No format fork.** A shell-side store would duplicate the scheme file
   format and its mode/flavour/variant semantics across two writers.

## Explicit non-goals (unchanged)

- **No sticky theme.** Theme packs remain apply-once recipes (wallpaper +
  colors + GTK + icons applied once, no "current theme" state). This
  decision changes nothing about apply-once semantics.
- **No IPC contract change.** No new `IpcHandler` targets or functions;
  `docs/IPC.md` and `tests/test_ipc_mapping.py` are untouched. The
  `colours` (`reload`/`mode`/`flavour`) and `appearance`
  (`applyTheme`/`reload`/`setWallpaper`) surfaces are unchanged.

## Revisit when

A HorneroOS-owned palette generator exists in-repo (or as a versioned
library the shell can link), and scheme persistence moves to a HorneroOS
service with a versioned contract. Until then, follow-ups stay limited to
keeping the compat adapters thin and marked.
