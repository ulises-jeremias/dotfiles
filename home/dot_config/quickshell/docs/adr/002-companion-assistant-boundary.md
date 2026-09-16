# ADR 002 — Companion is presentation, the Assistant is a future daemon

Date: 2026-09-15
Status: accepted

## Context

The Hornero companion (sidekick bird: `modules/companion/`, assets in
`assets/companion/`, PRs #37–#39) needs a behavior vocabulary today —
idle, greet, think, celebrate, warn — while the actual assistant (speech
recognition, LLM, skills, actions) does not exist yet. The risk is
growing presentation code that secretly assumes a backend, or backend
code that reaches into shell UI internals.

## Decision

1. **The Companion is presentation-only and stays in HorneroOS/shell.**
   It owns skins, frames, timing, bubbles, menus, position, and the
   behavior state machine. It never spawns processes, never touches the
   network, and never blocks on anything outside the running shell.
   (`tests/test_companion_runtime.py` enforces this statically.)

2. **The Assistant will be a separate daemon in its own lifecycle**
   (own repository/process, own release cadence), driving the companion
   exclusively over the stable `companion` IPC surface (`show`/`hide`/
   `toggle`/`say`/`tip`/`play`/`setState`/`setSkin`/`resetPosition`/
   `status`, see `docs/IPC.md`). No shared QML singletons, no direct
   function calls, no private file formats between them.

3. **The six future states are a reserved mapping, not a backend.**
   `listening`/`thinking`/`acting`/`success`/`warning`/`error` are
   accepted by `requestState`/`setState` today and mapped to existing
   animations (`docs/COMPANION_ASSISTANT.md`). They change nothing but
   the sprite until a daemon exists to set them deliberately.

## Split (extraction boundary)

Shell-owned forever (never migrates): frame assets + manifest, the
animation player, bubble/menu/overlay chrome, position + settings
persistence, suppression rules, tip catalog.

Daemon-owned when it exists: microphone/TTS, model calls, skills and
tool use, conversation memory, proactive triggers. It may *request*
companion states and *say* text; it may never reach into
`CompanionStore` internals — IPC is the whole interface.

## Consequences

- The companion ships and is fully useful with no assistant running.
- A future daemon can be developed, tested, and released without
  touching the shell, against `companion status()` as its only probe.
- If the daemon never ships, nothing in the shell is dead code: every
  reserved state already renders as a real animation.
