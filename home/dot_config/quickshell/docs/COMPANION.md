# Companion

The Companion is the Hornero sidekick: a small skinned bird that idles,
ambles, flies, and greets across shell surfaces. This page documents the
production asset pipeline, not a mockup.

## Vocabulary (default skin first)

| Animation | Frames | Timing | Loop | Next | Anchor |
| --------- | ------ | ------ | ---- | ---- | ------ |
| `idle` | idle | 900 ms | yes | idle | feet |
| `walk` | walk, idle | 320 ms | yes | idle | feet |
| `fly` | fly | 500 ms | yes | idle | center |
| `greet` | walk | 650 ms | no | idle | feet |

Poses: `idle` (standing, wings folded), `fly` (airborne, wings raised),
`walk` (standing, wing raised, beak open; doubles as the greet key).

## Skins and fallback

`default` (Hornero, no clothing) ships the full vocabulary. The four
skins — `argentina`, `blue-gold`, `red`, `gaucho` — ship grounded poses
(`idle`, `walk`, `greet`) only; their `fly` resolves to the default fly
frame through the explicit per-skin `fallbackChain` (`[skin, default]`)
in `assets/companion/manifest.json`. Unknown skins/animations resolve to
default/idle and never fail.

Assistant states map to default-skin animations: `resting` → idle,
`listening` → greet, `thinking` → walk, `speaking` → fly.

## Normalization

Every frame is a 512x512 RGBA canvas, content fit to 448 px, real
transparency (no baked checkerboard, labels, or numbers):

- Grounded poses (`idle`, `walk`): feet baseline at canvas y = 472,
  horizontally centered (anchor `feet`).
- `fly`: content centered on (256, 256) (anchor `center`).

`manifest.json` (`manifestVersion: 1`) records per animation `id`,
`frames` (file, `size`, `offset`, `anchorPx`), `frameMs` timing, `loop`,
`next`, and `anchor`, plus canvas, baseline, skins, fallback chains,
and assistant states.

## Regenerating

```sh
scripts/derive-companion-assets.py            # slices sources, writes frames + manifest
scripts/preview-companion-assets              # writes assets/companion/preview/*.png
scripts/derive-companion-assets.py --check    # drift gate (also run by tests)
scripts/preview-companion-assets --check      # sheet drift gate
```

`preview/` holds three deterministic contact sheets committed for
review: `preview-default-animations.png`, `preview-skins.png`
(fallback cells tagged), `preview-assistant-states.png`. Source
provenance, hashes, and hand-traced seams live in
`assets/companion/SOURCES.md`.

## Consuming from QML

```qml
import qs.modules.companion

Image {
    source: Qt.resolvedUrl(Companion.frameSource("argentina", "walk"))
}
```

`Companion.resolve(skin, animation)` returns file, anchor, anchorPx,
frameMs, loop, next, and whether the frame fell back. A missing or
malformed manifest degrades to the default idle frame; UI should hide
the sprite until `Companion.ready`. `Companion.reel(skin, animation)`
returns the full frame-file list plus timing/loop/next for the
animation player, with the same fallback rules.

## Runtime

`modules/companion/` hosts exactly one companion (`CompanionHost`,
wired in `shell.qml`):

- `Player.qml` — reusable frame player on a single `Timer` core
  (timing, loop, `finished()`, fallback frame, pause). Single-frame
  reels never run the timer, so an idling companion costs nothing.
- `CompanionStore.qml` — behavior state machine plus persisted
  settings and position (`PersistentProperties`, id `companion`):
  `hidden`/`peeking`/`entering`/`idle`/`hovering`/`talking`/
  `excited`/`dragging`/`leaving`/`sleeping`, with the future
  assistant states (`listening`/`thinking`/`acting`/`success`/
  `warning`/`error`) accepted and mapped to animations only —
  reserved for a future assistant daemon, with no backend behind
  them today (see `docs/COMPANION_ASSISTANT.md` and
  `docs/adr/002-companion-assistant-boundary.md`).
- `CompanionHost.qml` — the overlay: hybrid frames-plus-transforms
  (idle bob, takeoff/fly/landing, landing bounce), drag with
  monitor-aware persisted position (screen-relative fractions plus
  monitor name, following the focused monitor when unplaced),
  speech bubble, right-click menu (tip / skin / reset / hide /
  settings), edge-summon peek/fly-in, and sleep after a long idle
  (default 10 min, any interaction wakes).
- `Bubble.qml` — wrapping text, 240 px max width, edge flipping,
  timed dismissal, `dark`/`light`/`pampa` themes (`auto` follows the
  shell theme).

Walk is a greeting motion, never locomotion: the companion only ever
moves for takeoff/fly/landing transitions and drags — it never
wanders on its own.

Suppression (all automatic): session lock, fullscreen windows, game
mode, and the area picker hide the companion; disabling it in
settings unloads every surface and timer (zero cost). The window is
an `Overlay`-layer, `Ignore`-exclusion surface with no keyboard focus
sized to the sprite, so it never steals clicks or input. Reduced
motion replaces bob/bounce/fly transitions with jump cuts.

Control Center › Companion exposes enable, character, size,
idle-to-sleep, tips, edge, bubble theme, summon, and position reset.
Everything is also adjustable over IPC (`qs ipc call companion …`):
`summon`/`hide`/`toggle`/`say`/`tip`/`play`/`setState`/`setSkin`/
`resetPosition`/`status` — see `docs/IPC.md`. (`summon`, not `show`: an
IPC function literally named `show` is unreachable through
`qs ipc call` — the token is swallowed as the `ipc show` subcommand.)
