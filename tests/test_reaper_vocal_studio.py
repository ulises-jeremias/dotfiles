"""Static invariants for the REAPER Vocal Studio template (no REAPER required).

The live reload checks live in scripts/reaper/verify-vocal-studio.lua and must
be run inside REAPER. These tests catch template regressions in CI-friendly form.
"""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REAPER = ROOT / "home" / "dot_config" / "REAPER"
PROJECT = REAPER / "ProjectTemplates" / "Modern Rock & Metal - Vocal Studio.RPP"
TT_DIR = REAPER / "TrackTemplates" / "Vocal Studio"
FX_DIR = REAPER / "FXChains" / "Vocal Studio"

EXPECTED_TRACKS = [
    "BACKING", "Backing Track", "VOCAL ROUTING", "Vocal Bus", "LEAD VOCALS",
    "Lead Clean", "Lead Clean FX", "Grit Vocal", "Harsh Vocal", "VOCAL LAYERS",
    "Double L", "Double R", "Harmonies", "FX RETURNS", "Vocal Reverb", "Vocal Delay",
    "ELECTRIC GUITAR", "Electric Guitar DI", "Crystal Clean", "Warm Clean - Ambient",
    "Classic Rock - Crunch", "Hard Rock - Heavy Lead", "Modern Metal Rhythm",
    "Metalcore - Modern Lead", "Hard Stuff (Legacy)",
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


def test_guitar_di_has_no_direct_master_route_and_hard_stuff_is_not_recordable() -> None:
    for block in _track_blocks(PROJECT.read_text()):
        name = re.search(r'^    NAME "?([^"\n]+)"?$', block, flags=re.M).group(1)
        if name == "Electric Guitar DI":
            assert re.search(r"^    MAINSEND 0", block, flags=re.M), "DI must not send to master"
        if name == "Hard Stuff (Legacy)":
            assert re.search(r"^    REC 0 -1", block, flags=re.M), "Hard Stuff must have no input"


def test_exported_fx_chain_for_hard_stuff_has_four_guitarix_or_native_plugins() -> None:
    chain = (REAPER / "FXChains" / "Guitar Tones" / "Legacy" / "Hard Stuff (Legacy).RfxChain").read_text()
    assert chain.startswith("<FXCHAIN"), "RfxChain must start with <FXCHAIN"
    assert "GxFuzz" in chain and "GxSaturator" in chain and "GxCabinet" in chain
    assert "ReaEQ" in chain


def test_track_templates_and_chains_are_nonempty_and_balanced() -> None:
    for path in list(TT_DIR.glob("*.RTrackTemplate")) + list(FX_DIR.glob("*.RfxChain")):
        text = path.read_text()
        assert text.strip(), f"{path.name} is empty"
        opens = len(re.findall(r"^\s*<", text, flags=re.M))
        closes = len(re.findall(r"^>\s*$", text, flags=re.M))
        assert opens == closes, f"{path.name}: unbalanced blocks ({opens} open, {closes} close)"
