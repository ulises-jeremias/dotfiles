"""Static invariants for the REAPER Vocal Studio template (no REAPER required).

The live reload checks live in scripts/reaper/verify-vocal-studio.lua and must
be run inside REAPER. These tests catch template regressions in CI-friendly form.
"""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REAPER = ROOT / "home" / "dot_config" / "REAPER"
# The project references guitar assets by path, so it is a chezmoi template.
PROJECT = REAPER / "ProjectTemplates" / "Modern Rock & Metal - Vocal Studio.RPP.tmpl"
# Same project, REAPER's default template: opens ready to play (DI + Lead Clean armed).
LIVE = REAPER / "ProjectTemplates" / "Music Studio.RPP.tmpl"
TT_DIR = REAPER / "TrackTemplates" / "Vocal Studio"
FX_DIR = REAPER / "FXChains" / "Vocal Studio"

EXPECTED_TRACKS = [
    "BACKING", "Backing Track", "VOCAL ROUTING", "Vocal Bus", "LEAD VOCALS",
    "Lead Clean", "Lead Clean FX", "Grit Vocal", "Harsh Vocal", "VOCAL LAYERS",
    "Double L", "Double R", "Harmonies", "FX RETURNS", "Vocal Reverb", "Vocal Delay",
    "ELECTRIC GUITAR", "Electric Guitar DI", "Crystal Clean", "Warm Clean - Ambient",
    "AC-DC - Classic Crunch", "Avenged Sevenfold - Lead", "Machine Head - Groove Thrash",
    "Lamb of God - Groove Metal", "Slipknot - Nu Metal", "Asking Alexandria - Metalcore",
    "Discord Lesson Bus",
]
TONES = EXPECTED_TRACKS[EXPECTED_TRACKS.index("Crystal Clean"):EXPECTED_TRACKS.index("Discord Lesson Bus")]


def _track_blocks(text: str) -> list[str]:
    return re.findall(r"^  <TRACK .*?^  >", text, flags=re.S | re.M)


def _names(text: str) -> list[str]:
    return [a or b for a, b in re.findall(r'^    NAME (?:"([^"]*)"|(\S+))$', text, flags=re.M)]


def _blocks_by_name(text: str) -> dict[str, str]:
    out = {}
    for block in _track_blocks(text):
        out[re.search(r'^    NAME "?([^"\n]+)"?$', block, flags=re.M).group(1)] = block
    return out


def test_project_template_exists_and_has_expected_tracks() -> None:
    assert _names(PROJECT.read_text()) == EXPECTED_TRACKS
    assert _names(LIVE.read_text()) == EXPECTED_TRACKS


def test_music_studio_active_tone_keeps_its_amp_and_cabinet() -> None:
    # regression: the active tone was once saved before NAM reloaded -> silent guitar
    block = _blocks_by_name(LIVE.read_text())["Machine Head - Groove Thrash"]
    assert re.search(r"neural-amp-modeler-lv2#model .+?\.nam 3$", block, flags=re.M)
    assert re.search(r"impulse_responses_mono/ports#ifn .+?\.wav 3$", block, flags=re.M)


def test_music_studio_opens_ready_to_play_and_records_nothing_by_itself() -> None:
    # Arming only monitors: Input 2 is heard through the active tone and Input 1
    # reaches the lesson bus. Nothing records until Record is pressed.
    for name, block in _blocks_by_name(LIVE.read_text()).items():
        rec = re.search(r"^    REC (\d+) (-?\d+) (\d+)", block, flags=re.M)
        if name in ("Electric Guitar DI", "Lead Clean"):
            assert rec.group(1) == "1" and rec.group(3) == "1", f"{name} must ship armed with monitoring"
        else:
            assert rec.group(1) == "0", f"{name} must ship disarmed"
    assert "<ITEM" not in LIVE.read_text()


def test_output_buses_keep_backing_and_metronome_out_of_discord() -> None:
    for path in (PROJECT, LIVE):
        text = path.read_text()
        # master: out 1-2 (headphones) and out 5-6 (REAPER Program, OBS)
        assert re.findall(r"^  MASTERHWOUT (\d+) ", text, flags=re.M) == ["0", "4"], path.name
        blocks = _blocks_by_name(text)
        lesson = blocks["Discord Lesson Bus"]
        assert re.search(r"^    MAINSEND 0", lesson, flags=re.M), "lesson bus must not reach headphones/OBS"
        assert re.findall(r"^    HWOUT (\d+) ", lesson, flags=re.M) == ["2"], "lesson bus -> out 3-4 only"
        # receives: tracks are referenced by index in AUXRECV
        sources = {EXPECTED_TRACKS[int(i)] for i in re.findall(r"^    AUXRECV (\d+) ", lesson, flags=re.M)}
        assert sources == {"Vocal Bus", *TONES}, sources
        # no metronome redirection: REAPER plays it on hardware 1-2 only
        assert "METRONOMEOUT" not in text or re.search(r"METRONOMEOUT 0\b", text)


def test_project_template_has_no_media_or_private_paths() -> None:
    text = PROJECT.read_text()
    assert "<ITEM" not in text, "template must contain no media items"
    assert "/home/" not in text, "template must not contain absolute private paths"
    assert "SOURCE WAVE" not in text and "SOURCE MP3" not in text


def test_recording_template_ships_every_track_disarmed() -> None:
    for block in _track_blocks(PROJECT.read_text()):
        rec = re.search(r"^    REC (\d+)", block, flags=re.M)
        assert rec and rec.group(1) == "0", "no track may ship record-armed"


def test_vocal_tracks_use_mono_input_1_and_guitar_di_uses_input_2() -> None:
    inputs = {}
    for block in _track_blocks(PROJECT.read_text()):
        name = re.search(r'^    NAME "?([^"\n]+)"?$', block, flags=re.M).group(1)
        rec = re.search(r"^    REC \d+ (-?\d+)", block, flags=re.M)
        inputs[name] = int(rec.group(1))
    for vocal in ["Lead Clean", "Lead Clean FX", "Grit Vocal", "Harsh Vocal",
                  "Double L", "Double R", "Harmonies"]:
        assert inputs[vocal] == 0, f"{vocal} must record Scarlett Input 1 (mono index 0)"
    assert inputs["Electric Guitar DI"] == 1, "guitar DI must record Scarlett Input 2 (mono index 1)"
    assert inputs["Backing Track"] == -1, "backing track must have no input"


def test_guitar_di_has_no_direct_master_route_and_tones_are_not_recordable() -> None:
    for block in _track_blocks(PROJECT.read_text()):
        name = re.search(r'^    NAME "?([^"\n]+)"?$', block, flags=re.M).group(1)
        if name == "Electric Guitar DI":
            assert re.search(r"^    MAINSEND 0", block, flags=re.M), "DI must not send to master"
        if name in TONES or name == "Discord Lesson Bus":
            assert re.search(r"^    REC 0 -1", block, flags=re.M), f"{name} must have no record input"


def test_only_the_default_tone_is_active_in_the_template() -> None:
    assert _active_tones(PROJECT) == ["Crystal Clean"]
    # Music Studio opens on a distorted tone so the guitar sounds like an amp at once
    assert _active_tones(LIVE) == ["Machine Head - Groove Thrash"]


def _active_tones(path: Path) -> list[str]:
    # Inactive tones are muted and FX-bypassed so only one amp capture uses CPU.
    active = []
    for block in _track_blocks(path.read_text()):
        name = re.search(r'^    NAME "?([^"\n]+)"?$', block, flags=re.M).group(1)
        if name in TONES:
            mute = re.search(r"^    MUTESOLO (\d)", block, flags=re.M).group(1)
            fx_on = re.search(r"^    FX (\d)", block, flags=re.M).group(1)
            offline = re.findall(r"^\s+BYPASS \d (\d) \d$", block, flags=re.M)
            assert offline, f"{name}: no FX found"
            if mute == "0":
                active.append(name)
                assert fx_on == "1", f"{name} is active but its FX are bypassed"
                assert set(offline) == {"0"}, f"{name} is active but some FX are offline"
            else:
                assert fx_on == "0", f"{name} is muted but still processing (CPU)"
                # offline: state kept, plugin not loaded -> one amp model loads at project open
                assert set(offline) == {"1"}, f"{name} is inactive but its FX are loaded"
    return active


def test_track_templates_and_chains_are_nonempty_and_balanced() -> None:
    for path in list(TT_DIR.glob("*.RTrackTemplate")) + list(FX_DIR.glob("*.RfxChain")):
        text = path.read_text()
        assert text.strip(), f"{path.name} is empty"
        opens = len(re.findall(r"^\s*<", text, flags=re.M))
        closes = len(re.findall(r"^>\s*$", text, flags=re.M))
        assert opens == closes, f"{path.name}: unbalanced blocks ({opens} open, {closes} close)"
