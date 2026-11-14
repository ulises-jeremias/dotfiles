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
TT_DIR = REAPER / "TrackTemplates" / "Vocal Studio"
FX_DIR = REAPER / "FXChains" / "Vocal Studio"

EXPECTED_TRACKS = [
    "BACKING", "Backing Track", "VOCAL ROUTING", "Vocal Bus", "LEAD VOCALS",
    "Lead Clean", "Lead Clean FX", "Grit Vocal", "Harsh Vocal", "VOCAL LAYERS",
    "Double L", "Double R", "Harmonies", "FX RETURNS", "Vocal Reverb", "Vocal Delay",
    "ELECTRIC GUITAR", "Electric Guitar DI", "Crystal Clean", "Warm Clean - Ambient",
    "Classic Rock - Crunch", "Hard Rock - Heavy Lead", "Modern Metal Rhythm",
    "Extreme Metal Rhythm", "Metalcore - Melodic Lead",
]


def _track_blocks(text: str) -> list[str]:
    return re.findall(r"^  <TRACK .*?^  >", text, flags=re.S | re.M)


def test_project_template_exists_and_has_expected_tracks() -> None:
    text = PROJECT.read_text()
    names = re.findall(r'^    NAME (?:"([^"]*)"|(\S+))$', text, flags=re.M)
    got = [a or b for a, b in names]
    assert got == EXPECTED_TRACKS


def test_project_template_has_no_media_or_private_paths() -> None:
    text = PROJECT.read_text()
    assert "<ITEM" not in text, "template must contain no media items"
    assert "/home/" not in text, "template must not contain absolute private paths"
    assert "SOURCE WAVE" not in text and "SOURCE MP3" not in text


def test_every_track_is_disarmed() -> None:
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
        if name in EXPECTED_TRACKS[EXPECTED_TRACKS.index("Crystal Clean"):]:
            assert re.search(r"^    REC 0 -1", block, flags=re.M), f"{name} must have no record input"


def test_only_the_default_tone_is_active_in_the_template() -> None:
    # Inactive tones are muted and FX-bypassed so only one amp capture uses CPU.
    active = []
    for block in _track_blocks(PROJECT.read_text()):
        name = re.search(r'^    NAME "?([^"\n]+)"?$', block, flags=re.M).group(1)
        if name in EXPECTED_TRACKS[EXPECTED_TRACKS.index("Crystal Clean"):]:
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
    assert active == ["Crystal Clean"]


def test_track_templates_and_chains_are_nonempty_and_balanced() -> None:
    for path in list(TT_DIR.glob("*.RTrackTemplate")) + list(FX_DIR.glob("*.RfxChain")):
        text = path.read_text()
        assert text.strip(), f"{path.name} is empty"
        opens = len(re.findall(r"^\s*<", text, flags=re.M))
        closes = len(re.findall(r"^>\s*$", text, flags=re.M))
        assert opens == closes, f"{path.name}: unbalanced blocks ({opens} open, {closes} close)"
