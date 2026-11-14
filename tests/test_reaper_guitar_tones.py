"""Static guarantees for the seven guitar tones (no REAPER required)."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REAPER = ROOT / "home" / "dot_config" / "REAPER"
TONES = {
    "Clean": ["Crystal Clean", "Warm Clean - Ambient"],
    "Rock": ["Classic Rock - Crunch", "Hard Rock - Heavy Lead"],
    "Metal": ["Modern Metal Rhythm", "Metalcore - Modern Lead"],
    "Legacy": ["Hard Stuff (Legacy)"],
}


def _all_tones():
    for cat, names in TONES.items():
        for name in names:
            yield cat, name


def test_every_tone_has_a_track_template_and_fx_chain() -> None:
    for cat, name in _all_tones():
        tt = REAPER / "TrackTemplates" / "Guitar Tones" / cat / f"{name}.RTrackTemplate"
        fx = REAPER / "FXChains" / "Guitar Tones" / cat / f"{name}.RfxChain"
        assert tt.is_file(), tt.relative_to(ROOT)
        assert fx.is_file(), fx.relative_to(ROOT)


def test_tone_chains_are_balanced_and_nonempty() -> None:
    for cat, name in _all_tones():
        text = (REAPER / "FXChains" / "Guitar Tones" / cat / f"{name}.RfxChain").read_text()
        assert text.startswith("<FXCHAIN"), name
        opens = len(re.findall(r"^\s*<", text, flags=re.M))
        closes = len(re.findall(r"^>\s*$", text, flags=re.M))
        assert opens == closes and opens > 1, f"{name}: unbalanced or empty chain"


def test_no_tone_combines_the_amp_with_guitarix_cabinet() -> None:
    # Reproduced REAPER crash: GxAmplifier-X and GxCabinet saved in one project.
    for cat, name in _all_tones():
        text = (REAPER / "FXChains" / "Guitar Tones" / cat / f"{name}.RfxChain").read_text()
        if "GxAmplifier-X" in text:
            assert "GxCabinet" not in text, f"{name} combines GxAmplifier-X with GxCabinet"


def test_trim_file_covers_all_seven_tones_and_no_clipping_margin() -> None:
    trims = {}
    for line in (ROOT / "scripts" / "reaper" / "guitar-tones-trim.txt").read_text().splitlines():
        if line.startswith("#") or "|" not in line:
            continue
        name, db = line.rsplit("|", 1)
        trims[name] = float(db)
    expected = {name for _, name in _all_tones()}
    assert set(trims) == expected
    assert all(-12.0 <= v <= 12.0 for v in trims.values()), "trims must stay within +/-12 dB"


def test_tone_switcher_only_changes_mute_state() -> None:
    script = (REAPER / "Scripts" / "Vocal Studio" / "Guitar - Choose tone.lua").read_text()
    assert "B_MUTE" in script
    assert "I_RECARM" not in script and "Transport" not in script and "1013" not in script
    for _, name in _all_tones():
        assert f'"{name}"' in script, name
