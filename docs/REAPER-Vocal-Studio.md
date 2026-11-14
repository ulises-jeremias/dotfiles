# REAPER Music Studio (vocals, guitar, Discord lessons, OBS)

A music workstation built from application-native configuration. Daily use
needs **no terminal commands**:

1. **Open REAPER** from the app menu. It starts on the *Music Studio* template
   with the guitar DI and Lead Clean armed for monitoring: play and you hear the
   active tone (Machine Head) in your headphones.
2. **Open Discord** and pick the input device **REAPER Lesson Mic** (once).
3. **Open OBS**, pick the scene collection **Music Studio** and profile
   **Music Studio** (once), then record (or start the virtual camera, see below).

REAPER is the only audio-processing application. Guitarix is not launched,
configured or required (its package stays installed for the Gx LV2 pedals).

Current state and what is still unverified are listed at the end. Read them.

## How it fits together

| Layer | Owner | Configuration (all in this repo) |
|-------|-------|----------------------------------|
| Guitar and vocal processing, recording, buses | REAPER | `ProjectTemplates/Music Studio.RPP` (default), `Modern Rock & Metal - Vocal Studio.RPP` (recording) |
| Low latency for REAPER only | PipeWire JACK | `~/.config/pipewire/jack.conf.d/60-reaper-low-latency.conf` (256/48000 for the `reaper` process) |
| Permanent virtual endpoints | PipeWire | `~/.config/pipewire/pipewire.conf.d/60-reaper-music-studio.conf` |
| Saved links between REAPER and the endpoints | qpwgraph patchbay (autostarts minimized) | `~/.config/qpwgraph/music-studio.qpwgraph`, `~/.config/autostart/qpwgraph-music-studio.desktop` |
| Scenes, recording profile, virtual camera | OBS Studio | scene collection and profile *Music Studio* |
| Call | Discord | input device *REAPER Lesson Mic*, output device *Discord Call* |

REAPER's six JACK outputs (set once by
`.chezmoiscripts/linux/run_after_configure-reaper-music-studio.sh.tmpl`, the same
values as *Preferences > Audio > Device*; it also disables JACK auto-connect and
makes *Music Studio* the default template):

```text
Input 1 (mic)  -> vocal tracks -> Vocal Bus --+--> master -> out 1-2 -> headphones
Input 2 (DI)   -> Electric Guitar DI -> sends -> active tone --+   (+ metronome, hardware 1-2 only)
                                              |            master -> out 5-6 -> "REAPER Program" (OBS)
                    Vocal Bus + every tone ---+--> Discord Lesson Bus -> out 3-4 -> "REAPER Lesson Mic" (Discord)
Discord output -> "Discord Call" sink -> headphones   (+ OBS track 3)
```

What reaches Discord: processed guitar and your voice only. Not the backing
track, not the metronome, not desktop audio, not Discord itself (measured: a
test tone on the Backing Track is 57 dB above the noise in *REAPER Program* and
indistinguishable from silence in *REAPER Lesson Mic*).

Feedback cannot happen: the lesson mic input never auto-connects (only the
patchbay links REAPER out 3-4 to it), the raw DI has no route to any output, and
Discord's output goes to *Discord Call*, which plays only to your headphones.

To change the headphone output (for example a USB headset instead of the
Scarlett), open **qpwgraph**, drag REAPER out1/out2 to the new device and
*Patchbay > Save*. chezmoi never overwrites that file once it exists.

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

## Recording in REAPER

- **Record a vocal:** `Actions` > `Show action list` > run *Vocal Studio -
  Choose take* and type the style (`Lead Clean`, `Lead Clean FX`, `Grit Vocal`,
  `Harsh Vocal`, `Double L`, `Double R`, `Harmonies`). It arms exactly that
  track. Then press **Record** in the transport.
- **Record guitar:** the Electric Guitar DI is armed on open. It records the raw
  DI; the tone is only monitored, so you can re-amp later (play the DI item with
  the track disarmed).
- **Change tone:** run *Guitar - Choose tone* and type a band (`machine head`,
  `slipknot`, `lamb of god`, ...).
- **Backing track:** import an MP3/WAV onto **Backing Track**. It is never armed
  and never reaches Discord.
- **Recording template:** *File > New project from template > Modern Rock &
  Metal - Vocal Studio* opens the same project with every track disarmed.

## Guitar lesson (Discord)

Nothing to start: with REAPER open, Discord's input **REAPER Lesson Mic** carries
your voice and the processed guitar. Discord, once (Settings > Voice & Video):

1. **Input Device:** `REAPER Lesson Mic`.
2. **Output Device:** `Discord Call` (it plays in your headphones, and OBS can
   record it separately).
3. **Input Mode:** Voice Activity, automatic sensitivity **off**, slider at minimum.
4. Turn **off** Noise Suppression, Echo Cancellation and Automatic Gain Control
   (they would treat the guitar as noise).

OBS is optional for audio-only lessons. For video, start the OBS virtual camera
and pick it as Discord's camera; it carries **video only**, the audio is always
the REAPER Lesson Mic.

## OBS: Music Studio

Scene collection *Music Studio*: **Guitar Lesson** (camera + REAPER window),
**Guitar Performance** (camera full screen), **Music Tutorial** (screen +
camera picture-in-picture). Global audio: *REAPER Program* (the REAPER mix) and
*Discord Call* (the other people on the call). Audio monitoring is off on every
source, so OBS never plays anything back.

Profile *Music Studio*: 1080p30, 48 kHz, hybrid MP4 in `~/Videos`, NVENC, three
audio tracks: **1** full mix, **2** REAPER only, **3** Discord only, so a lesson
recording can be remixed later.

The first time a scene with *Screen* or *REAPER Window* is shown, OBS asks
(desktop portal) which screen or window to capture and remembers it. *Camera*
needs your webcam selected once in its properties.

## Diagnostics and recovery (not needed daily)

```sh
reaper-studio doctor   # inputs, headphones, Discord/OBS buses, feedback safety
reaper-studio repair   # recreate REAPER's links if qpwgraph is not running
```

Rollback: remove the files listed in *How it fits together*, restore
`~/.local/state/reaper-backups/reaper.ini.pre-music-studio` to
`~/.config/REAPER/reaper.ini` (REAPER closed), and run
`systemctl --user restart pipewire pipewire-pulse wireplumber`.

## Guitar tones (Squier Stratocaster, Scarlett Input 2)

Eight tones in REAPER categories (`TrackTemplates/Guitar Tones/<Category>/` and
`FXChains/Guitar Tones/<Category>/`). Every tone is a real amp capture
(Neural Amp Modeler) into a real 4x12 cabinet impulse response. The rock and
metal tones are named after the band whose sound they aim at, and use the amp
family that band's guitarists are documented playing:

| Tone | Band rig it follows | Chain |
|------|---------------------|-------|
| Crystal Clean | (generic Fender clean) | ReaComp → **NAM Fender Twin Reverb (Normal, Bright)** → IR Greenback 4x12 (*Don Spinacio*, SM57) → ReaEQ (low shelf +3 dB, top tamed) → ReaVerbate |
| Warm Clean - Ambient | (generic ambient clean) | GxChorus → **NAM Vox AC15** (input -6 dB, stays clean) → IR Greenback (*Kill Dill*) → ReaEQ (dark top) → GxEcho → GxReverb |
| AC-DC - Classic Crunch | Marshall crunch into Greenbacks, low gain | **NAM Marshall JCM2000 crunch** (input -6 dB) → IR Greenback (*Wasabi Warrior*) → ReaEQ → ReaVerbate |
| Avenged Sevenfold - Lead | Synyster Gates: SD-1 into a high-gain head, V30 4x12 [1] | hum notch → gate → ReaComp → **SD-1 boost** → **NAM Marshall JVM OD2 red** (+6 dB in) → IR **V30** (*World Collider*) → ReaEQ → 1/4 delay → reverb |
| Machine Head - Groove Thrash | Robb Flynn: Peavey 5150/6505 with an SD-1, Marshall cabs [2] | hum notch → fast gate → **SD-1 boost** → **NAM Peavey 5150 (block letter)** → IR **V30** (*Cookie Monster*) → ReaEQ (low shelf -5 dB at 130 Hz, -2.5 dB at 280 Hz, +1.5 dB at 1.4 kHz) |
| Lamb of God - Groove Metal | Mark Morton / Willie Adler: Mesa/Boogie Mark IV [3] | hum notch → fast gate → Tube Screamer (drive 0) → **NAM Mesa/Boogie Mark IV** → IR **V30** (*World Collider*) → ReaEQ (+2 dB at 800 Hz) |
| Slipknot - Nu Metal | Jim Root: Orange Rockerverb [4] | hum notch → fastest gate → Tube Screamer (drive 0) → **NAM Orange Rockerverb** (+3 dB in) → IR **V30/Rockdriver** (*Iceburn Suicide*) → ReaEQ (-3 dB at 500 Hz, +2 dB at 2.5 kHz) |
| Asking Alexandria - Metalcore | Ben Bruce: Peavey 6534+ [5] | hum notch → gate → **NAM Peavey 6534+ with OD808** (boost captured with the amp) → IR **V30** (*Cookie Monster*) → ReaEQ → dotted-1/8 delay → reverb |

Gear sources: [1] Line 6 "Beast and the Harlot" rig template and Seymour Duncan,
"The Sound of Synyster Gates"; [2] Peavey via Equipboard, Robb Flynn on
*Unto the Locust* ("a 5150 amp that I've used forever"); [3] Mesa/Boogie
Amplitudes blog and Premier Guitar *Rig Rundown: Lamb of God*; [4] Mix Online
(tech: two Orange Rockerverb 100s) and MusicRadar Slipknot rig tour; [5] Guitar
World and Reverb interviews (Peavey 6534 heads). These are the players' amps,
not their exact settings, which are not published.

**What a preset cannot copy:** these players use high-output humbuckers (often
active) and drop tunings. A Strat with single coils has less output and a
thinner low end. The chains add gain before the amp to compensate, but tune
down (drop D / drop C) to get closer to those records.

Switching: run *Guitar - Choose tone* (Actions). The chosen tone is unmuted and
its FX brought online; the others are muted and **offline** (their settings are
kept, the plugins are unloaded). The new amp needs about a second to load.

### What changed in the sound, and why (measured)

This audit compared the original Guitarix chains with the first NAM chains
(then named Modern Metal Rhythm and Metalcore - Melodic Lead; the band tones
above replaced them). The previous metal presets were audited stage by stage on the same DI
(`scripts/reaper/render-tones.lua` + `scripts/reaper/analyze-tones.py`):

| Finding (old Guitarix chains) | Evidence |
|---|---|
| The amp barely distorted a Strat DI | crest factor during chords 15.9–18.7 dB, the dry DI is 18.0 |
| **GxCabinet did nothing** | bypassing it gave identical results |
| The gate destroyed sustain | GxExpander ATTACK is in **seconds**; it was set to 0.995 s. A held note fell -20 dB |
| The gate threshold was below the real noise | real Squier noise peaks reach -59.4 dBFS; the gate sat at -62/-66 |
| Several Guitarix convolvers crash REAPER | segfaults in `libfftw3f` (planner not thread-safe) whenever two cab convolvers load in one process |

Same DI, new chains, matched loudness:

| | chord crest (lower = more saturation) | sustain of a held note | low-end decay per chug |
|---|---|---|---|
| old Modern Metal | 15.9 dB | -20.4 dB | -6.0 dB |
| **new Modern Metal Rhythm** | **11.0 dB** | **-2.9 dB** | **-8.9 dB** (tighter) |
| old Metalcore | 16.3 dB | -21.2 dB | -5.4 dB |
| **new Metalcore - Melodic Lead** | **10.3 dB** | **-4.0 dB** | -2.5 dB (lead: it rings) |

Noise between notes with the real Squier, after the gate fix: 93–118 dB below
the playing level on the four gated tones (it was 11–37 dB before the fix).

Gain staging: each chain's level is set **inside the chain** (NAM Output Lvl,
`scripts/reaper/guitar-tones-trim.txt`) so every high-gain tone lands at
-24 dBFS RMS on the same real Squier recording, cleans lower, peaks ≤ -6.7 dBFS. No fader
compensation. With a hotter (humbucker-level) DI the distorted tones stay at the
same level, as a saturated amp should.

**Not proven:** that these sound like Machine Head, Lamb of God, Slipknot,
Asking Alexandria, Avenged Sevenfold or AC/DC. They use those bands' amp families;
the numbers show matched levels, no clipping and no doubled cabinet. Whether each
one sounds like the band needs your ears.

### Amp captures and cabinet IRs (assets, not in Git)

Installed by `reaper-guitar-assets install` (pinned versions and SHA-256, user
level only, no root); `reaper-guitar-assets verify` checks them.

| What | Source | License |
|------|--------|---------|
| Neural Amp Modeler LV2 v0.2.3 (`~/.lv2/`) | github.com/mikeoliphant/neural-amp-modeler-lv2 (release binary, x86-64-v3) | GPL-3.0 |
| 8 NAM amp captures | github.com/pelennor2170/NAM_models @ `944ca671` (NAM community captures) | GPL-3.0 |
| Brutal IR pack (BG412S: Vintage 30 / Rockdriver Jr / DV-77) | jester-dyne-productions.com | CC0 (stated in the pack handbook) |
| Emerald IR pack (Marshall 1960AX, Greenback G12M) | jester-dyne-productions.com (via darwinscat.com) | CC0 (stated in the pack handbook) |

Not used, and why:

- **TONE3000:** downloads need your account (email code) and the T3K license
  forbids redistributing the files. You can add captures from it yourself; put
  them in `~/.local/share/reaper-studio/guitar/nam/` without spaces in the name.
- **NAMix:** very new (28 stars); the official LV2 plugin does everything needed.
- **Guitarix amps and cabinets:** see the audit above. Guitarix pedals that do not
  convolve (Tube Screamer, chorus, echo, reverb) are still used.

All captures are amp-only (measured: lots of energy above 5 kHz without a cab),
so each gets exactly one cabinet IR. There is no double cabinet.

### Latency, CPU and stability (measured on this host, 48 kHz)

- `reaper-studio` launches REAPER with `PIPEWIRE_QUANTUM=256/48000` for that
  process only (no global PipeWire setting, nothing persistent). REAPER output
  latency: **32 ms at the default quantum 1024 → 8 ms at 256**, 0 xruns.
  If your hardware xruns, set `REAPER_QUANTUM=512` in
  `~/.config/reaper-studio/monitor.env`.
- Every plugin in the chains reports **0 samples** of latency (REAPER PDC).
- CPU while playing any tone: about **28–30 % of one core** for all of REAPER
  (24 threads available).
- Known NAM issue: loading many NAM models at the same instant crashed the NAM LV2
  model loader once (about 21 simultaneous loads in a test harness). Opening the
  template (3/3) and normal tone switching were fine; inactive tones ship offline
  so the template loads one model at a time.

### Gate calibration

The gate sits before the amp (best signal-to-noise). It opens at -50 dBFS and
closes at -56 dBFS (Slipknot: -48/-54), measured on your Squier at the current
Input 2 gain: noise peaks reach -59.4 dBFS, playing peaks are near -28 dBFS. A held
note keeps ringing until it falls near the noise floor.

**If you raise the Scarlett Input 2 gain, raise the gate thresholds by the same
number of dB** (otherwise the gate opens on hum, but never cuts notes).

### Physical checklist (only you can do these)

1. **Pickups.** SSS or HSS? The presets work with both; tell me which so the gate
   and gain can be re-measured.
2. **Input 2:** press **INST**. Your DI currently peaks at about -22 dBFS, which is
   low (34 dB above the noise). Aim for about -12 dBFS on the loudest strum, and
   then raise the gate thresholds by the same amount (see above).
3. **Direct Monitor OFF.**
4. **Tuning and setup** first: no amp or EQ fixes detuned strings or bad intonation.
5. **Listen** to each band tone with palm mutes, open chords and a solo, ideally
   with a song by that band playing on the Backing Track. Tell me what is off (too much or
   too little gain, mud, fizz, thin) and I adjust.

## Files

- Templates: `~/.config/REAPER/ProjectTemplates/Music Studio.RPP` (default) and
  `Modern Rock & Metal - Vocal Studio.RPP` (chezmoi templates in the repo: asset
  paths use `{{ .chezmoi.homeDir }}`)
- Track templates and FX chains: `TrackTemplates/` and `FXChains/` under
  `~/.config/REAPER/`, folders `Vocal Studio` and `Guitar Tones/<Category>`
- ReaScripts: `~/.config/REAPER/Scripts/Vocal Studio/`
- Native routing: `~/.config/pipewire/{pipewire,jack}.conf.d/60-*.conf`,
  `~/.config/qpwgraph/music-studio.qpwgraph`, `~/.config/autostart/qpwgraph-music-studio.desktop`
- REAPER preferences (install time): `.chezmoiscripts/linux/run_after_configure-reaper-music-studio.sh.tmpl`
- OBS: `~/.config/obs-studio/basic/scenes/Music_Studio.json`,
  `basic/profiles/Music_Studio/basic.ini` (generated by `scripts/obs/build-music-studio-collection.py`)
- Diagnostics/recovery: `~/.local/bin/reaper-studio`, helpers `~/.local/share/reaper-studio/common.sh`
- Guitar assets: `~/.local/bin/reaper-guitar-assets`,
  `~/.local/share/reaper-studio/guitar/` (with `SOURCES.txt`)
- Developer tools (run inside REAPER): `scripts/reaper/build-vocal-studio.lua`
  (builder), `verify-vocal-studio.lua` (reload verifier), `render-tones.lua` (A/B
  renderer), `analyze-tones.py` (metrics), `templatize-assets.py` (post-build)
- Tests: `tests/test_reaper_vocal_studio.py`, `tests/test_reaper_guitar_tones.py`,
  `tests/test_reaper_routing.py`, `tests/test_music_studio_native.py`

## Status

Verified on the host:

- Builder: 460 checks, 0 failures; every tone keeps all its plugins, and its amp
  capture and cabinet IR are loaded and saved.
- Deployed files: 183 reload checks, 0 failures; each tone's track template and FX
  chain loads with its amp capture and IR (loaded one at a time).
- Routing: REAPER `in1` = Input 1, `in2` = Input 2, loopback excluded; studio and
  lesson doctors pass; lesson start/stop is idempotent.
- Re-amp, gain staging, gate and noise measurements described above.

Pending (needs you):

- **Your listening approval of every tone.** Nothing here proves they sound right
  to you.
- Pickup type and the Input 2 gain from the checklist (then the gate thresholds).
- Discord end to end, and vocal calibration with a real take.
- Installed REAPER is an evaluation copy.

The Guitarix configuration is no longer in this repo: the `silentz0r` bank and
the REAPER "Hard Stuff" / "Machine Head" chains that copied it were removed when
the NAM tones replaced them. On existing hosts the one-shot script
`home/.chezmoiscripts/linux/run_after_remove-retired-guitarix-config.sh.tmpl`
deletes those leftover files once (it never touches Guitarix's own state or a
bank you save again later). The bank is still in Git history:

```sh
git log --diff-filter=D --format=%h -1 -- home/dot_config/guitarix/banks/silentz0r.gx
git show <that-commit>^:home/dot_config/guitarix/banks/silentz0r.gx > silentz0r.gx
```

The `guitarix` package stays installed: it provides the LV2 pedals the tones use
(GxTubeScreamer, GxChorus, GxEcho, GxReverb). The standalone Guitarix app is not
launched or configured by anything here.
