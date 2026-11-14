# REAPER Vocal & Guitar Studio

One REAPER template for vocals and electric guitar, plus a lesson mode that
sends the processed guitar and your microphone to Discord. REAPER is the only
audio-processing application. Guitarix is not launched, configured or required
by anything here.

Current state and what is still unverified are listed at the end. Read them.

## Hardware (Focusrite Scarlett 2i2 4th Gen, USB `1235:8219`)

| Physical input | PipeWire source (HiFi profile)  | REAPER input | Used for                    |
|----------------|---------------------------------|--------------|-----------------------------|
| Input 1        | `HiFi__Mic1__source` (AUX0)     | channel 1    | microphone, vocal tracks    |
| Input 2        | `HiFi__Mic2__source` (AUX1)     | channel 2    | electric guitar DI          |
| Monitor 3+4    | `HiFi__Line4__source` (AUX2/3)  | never used   | hardware loopback, excluded |

Headphones: `HiFi__Line1__sink` (Scarlett "Headphones / Line 1-2"). Never use the
loopback as an input: it carries the interface's own outputs back to you.

Set the Scarlett **Direct Monitor to OFF**. REAPER monitors the signal, so
hardware direct monitoring would double every sound.

## Studio mode

```sh
reaper-studio start     # opens REAPER on the template and wires it to the headphones
reaper-studio doctor    # checks inputs, outputs and the loopback exclusion
```

Inside REAPER (the template is ready to use):

- **Record a vocal:** `Actions` > `Show action list` > run the script
  *Vocal Studio - Choose take* and type `Lead Clean` (or `Lead Clean FX`,
  `Grit Vocal`, `Harsh Vocal`, `Double L`, `Double R`, `Harmonies`). It arms
  exactly that track. Then press the red **Record** button in the transport.
- **Record guitar:** arm **Electric Guitar DI** (record button on its track
  header). You hear the Hard Stuff tone. The DI track records the raw, dry
  signal; the processed tone is only monitored.
- **Record both at once:** arm a vocal track and the DI track, then Record.
  Each lands on its own track.
- **Re-amp:** the recorded DI item sits on the Electric Guitar DI track. Press
  Play with that track not armed and the item plays through the Hard Stuff chain,
  so you can change the tone later without re-recording.
- **Backing track:** import an MP3/WAV onto **Backing Track**. It can never be
  armed.
- **Styles:** every vocal style is a separate track with its own chain
  (ReaGate is bypassed by default; enable it only after measuring the room).

## Guitar lesson mode (Discord)

```sh
reaper-lesson start     # REAPER + virtual mic + lesson monitoring (idempotent)
reaper-lesson doctor    # verifies the whole lesson graph
reaper-lesson stop      # removes the virtual mic and disarms the tracks
```

Signal path:

```
Input 1 (mic)  -> Lead Clean (monitored) -> REAPER out 1-2 --+--> headphones
Input 2 (DI)   -> Electric Guitar DI     -> send -> Hard Stuff -> out 1-2 --+--> reaper.lesson.mix -> "REAPER_Lesson_Mic" (virtual mic)
```

Discord, one time (Settings > Voice & Video):

1. **Input Device:** `REAPER_Lesson_Mic`.
2. **Output Device:** the Scarlett headphones (so you hear participants).
3. **Input Mode:** Voice Activity, automatic sensitivity **off**, slider at minimum.
4. Turn **off** Noise Suppression, Echo Cancellation and Automatic Gain Control.

Why it cannot loop back: the virtual mic is fed only by REAPER's output. Discord's
output goes to your headphones only, and nothing captures the headphones. `doctor`
fails if anything else feeds the virtual mic (monitors, Discord, the loopback or a
raw input).

Why raw DI never reaches Discord: the DI track has **no direct master route**. Its
only output is the send into Hard Stuff.

Levels: REAPER faders. Vocal and guitar gains are independent.

## Hard Stuff tone (migrated from `silentz0r.gx`, preset "Hard Stuff")

The main amp is **off** in the bank (`amp.on_off = 0`), so no amp head is used.
Enabled blocks, in signal order:

| Bank block (enabled)        | REAPER stage                          | Status                                  |
|-----------------------------|---------------------------------------|-----------------------------------------|
| AstroFuzz (Attack 0.48, Tone 0.51, Volume 0.855) | `GxFuzz` (genuine Guitarix LV2): TONE 0.51, OUTPUT 85.5, DRIVE 1 | **substitute**: no LV2 build of AstroFuzz exists here; Attack mapping is a guess |
| Tone stack M-Lead (Bass 0.50, Middle 0.71, Treble 0.525) | native ReaEQ: 100 Hz shelf 0 dB, 700 Hz +2 dB, 6 kHz shelf 0 dB | **approximation** (see below) |
| Shaper (Sharper 10)         | `GxSaturator` (genuine Guitarix LV2): INTENSITY 10, SATURATE 60 | **substitute**: no LV2 build of the Shaper exists here |
| Cabinet 4x12 (Level 3.4925, Bass 6.7, Treble 3.4) | `GxCabinet` (genuine): values exactly as in the bank | exact parameter values |
| Master output -6.4 dB      | track fader -6.4 dB                   | exact                                   |

Why the tone stack is not Guitarix's: `GxAmplifier-X` (which contains the M-Lead
tone stack) crashes REAPER when a project containing it and `GxCabinet` is
reopened. The crash is reproducible, so it is not used. Equivalence is **not**
established: no listening test or measured A/B has been completed against the
original Guitarix (see the status section).

## Files

- Template: `~/.config/REAPER/ProjectTemplates/Modern Rock & Metal - Vocal Studio.RPP`
- Track templates: `~/.config/REAPER/TrackTemplates/Vocal Studio/`
- FX chains: `~/.config/REAPER/FXChains/Vocal Studio/` (`Hard Stuff.RfxChain` is the migrated chain)
- ReaScripts: `~/.config/REAPER/Scripts/Vocal Studio/`
- Routing: `~/.local/bin/reaper-studio`, `~/.local/bin/reaper-lesson`, shared helpers
  `~/.local/share/reaper-studio/common.sh`
- Builder and reload verifier (developer tools, run inside REAPER):
  `scripts/reaper/build-vocal-studio.lua`, `scripts/reaper/verify-vocal-studio.lua`
- Static tests: `tests/test_reaper_vocal_studio.py`

## Status (what is verified and what is not)

Verified on the host:

- Template reload: 106 checks, 0 failures, repeated twice. Every track template
  and FX chain reloads with its FX and saved parameter values.
- Routing: REAPER `in1` = Input 1 (AUX0), `in2` = Input 2 (AUX1); the loopback is
  not linked; outputs go to the headphones and not to the USB dongle.
- Lesson graph: start, second start (no duplicate modules or links), stop, and
  restart all behave. `doctor` passes.
- Re-amp path: a DI item played in REAPER reaches the virtual lesson mic through
  the Hard Stuff chain (about -33 dBFS RMS at the mic, peak -22 dBFS).
- Monitoring state: after start, Lead Clean and the guitar DI are armed and
  monitoring with no items and the transport stopped. After stop, all are disarmed.

Not verified (needs you, or a further session):

- **Tone equivalence to Guitarix.** Not established. The headless Guitarix reference
  rang after the input stopped, so it is not a valid reference yet. Substitutes are
  guesses. Listening test needed.
- **Real guitar and vocal capture.** Input 2 and Input 1 were checked at the link
  level only. Nothing was recorded from a real instrument.
- **Discord itself.** The virtual mic exists and `doctor` checks it, but Discord was
  not tested end to end.
- **Vocal calibration.** Gate and compressor thresholds still need a real take.
- **Mic at -83 dBFS RMS** in the one test recording: gain is not set for a mic yet.
- **REAPER on the GeneralPlus USB dongle.** It is the system default sink. REAPER's
  outputs are routed explicitly; the system default is not changed.
- **Installed REAPER is an evaluation copy.**
- **Buffer.** REAPER runs at 512 samples on JACK (about 10 ms). The brief asked for
  256; that is not set.

Guitarix stays installed and unchanged.
