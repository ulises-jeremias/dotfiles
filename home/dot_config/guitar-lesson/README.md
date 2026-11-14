# Guitar Lesson Audio (HorneroOS / PipeWire)

One command builds the whole lesson graph on this host. Hardware detected
2026-11-13: **Focusrite Scarlett 2i2 4th Gen** (USB `1235:8219`, ALSA card
`Gen`), PipeWire 1.6.11, WirePlumber 0.5.19, Guitarix 0.47.0, Discord 1.0.169.

## Commands

```sh
dots-guitar-lesson start     # build graph, launch Guitarix, set defaults (idempotent)
dots-guitar-lesson stop      # tear down, restore previous default sink/source
dots-guitar-lesson restart
dots-guitar-lesson wire      # re-create links only (after replug / stray autoconnect)
dots-guitar-lesson levels 0.85 0.75   # voice / guitar levels into the Discord mix
dots-guitar-lesson status
dots-guitar-lesson doctor
Live-hardware regression check (run on the workstation, not CI):
#   dots-guitar-lesson doctor && dots-guitar-lesson status
```

## Graph

```text
Scarlett Input 1 (mic)    ──> lesson.voicebus ──> lesson.voice ──┐
Scarlett Input 2 (guitar) ──> Guitarix ──> lesson.guitarbus ──> lesson.guitar ──┤
                                                    lesson.guitar ──> Built-in output (your headphones)
                                                    lesson.mixbus <── voice + guitar
lesson.mix (virtual mic)  ──> Discord input
Discord output            ──> Built-in output only (default sink; never into lesson.mix)
```

- Buses are Pulse `module-null-sink` + `module-remap-source` pairs on
  PipeWire: correct stereo ports, stable names (`lesson.mix`,
  `lesson.voice`, `lesson.guitar`), per-bus volume via `wpctl`.
- The mono mic is linked to both channels of `lesson.voicebus`, so voice is
  centered in the stereo virtual mic.
- Raw guitar DI only ever reaches Guitarix. Discord output and every sink
  monitor are structurally excluded from `lesson.mixbus`; `dots-guitar-lesson
  wire` re-enforces this and removes Guitarix autoconnects.
- Never use Scarlett "Monitor Input 3+4" (`HiFi__Line2__source`): that is
  the interface's hardware loopback of outputs 1-2.

## Latency

48 kHz, forced quantum 256 (≈5.3 ms per graph stage; ~128 also ran with
zero `pw-top` errors, 256 kept as the safe default). Override per run:
`GUITAR_LESSON_QUANTUM=128 dots-guitar-lesson start`. Persistent defaults live
in `~/.config/pipewire/pipewire.conf.d/10-guitar-lesson.conf` (delete it
and restart PipeWire to revert). Expect a few ms per bus hop on top of the
quantum; fine for lessons, not a studio-tracking rig.

## Discord setup (one-time, manual — the Linux client stores this in UI state)

1. Settings → Voice & Video → Input Device: **Guitar Lesson Mix
   (Voice+Guitar for Discord)** (`lesson.mix`). Output Device:
   **Built-in Audio Analog Stereo**.
2. Input Mode: **Push to Talk** off; use Voice Activity with the
   sensitivity slider low, or Push-to-Talk — VAD can clip sustained notes.
   For music, disable: Noise Suppression (Krisp/Standard → None),
   Echo Cancellation, Automatic Gain Control, and noise reduction.
3. `dots-guitar-lesson start` already makes `lesson.mix` the system default
   source and the Built-in output the default sink, so "Default" in
   Discord also works.

Wayland note: Discord screen-share audio is not used; the virtual mic is
the only lesson audio path, which avoids portal/capture flakiness.

## Physical controls on the Scarlett (only you can do these)

- Input 2: press **INST** for the guitar; set gain so strumming peaks
  below clipping (ring stays green, never red).
- Input 1: mic gain likewise; **48V** only if your mic is a condenser.
- **Direct Monitor: OFF** — monitoring comes from Guitarix through the
  Built-in output; direct monitor would double the guitar (dry + wet).
- Headphones plug into the **laptop/built-in output**, per current setup.
  To use the Scarlett phones instead:
  `GUITAR_LESSON_PHONES=alsa_output.usb-Focusrite_Scarlett_2i2_4th_Gen_T23KTXD3603210-00.HiFi__Line1__sink dots-guitar-lesson restart`

## Recovery

- Scarlett replugged: `dots-guitar-lesson start` (safe to re-run any time).
- Something sounds wrong: `dots-guitar-lesson doctor`, then
  `dots-guitar-lesson restart`.
- Full undo: `dots-guitar-lesson stop`, delete
  `~/.config/pipewire/pipewire.conf.d/10-guitar-lesson.conf`, and
  `systemctl --user restart pipewire wireplumber`.

Files: script `~/.local/bin/dots-guitar-lesson` (chezmoi source
`home/dot_local/bin/executable_dots-guitar-lesson`), state/logs
`~/.local/state/guitar-lesson/`.
