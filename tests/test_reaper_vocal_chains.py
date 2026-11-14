"""Static guarantees for the vocal chains (docs/REAPER-Vocal-Studio.md, "Vocal presets").

Measured on a synthetic test signal (not a real performance): compression,
de-essing and tone are documented in the guide; listening on a real take is
still pending. These tests pin the structural decisions behind those numbers.
"""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FX = ROOT / "home/dot_config/REAPER/FXChains/Vocal Studio"
TT = ROOT / "home/dot_config/REAPER/TrackTemplates/Vocal Studio"
VOCALS = ["Lead Clean", "Lead Clean FX", "Grit Vocal", "Harsh Vocal", "Double L", "Double R", "Harmonies"]
OPTIONAL = ["High Harsh", "Low Harsh - Growl"]


def _plugins(text: str) -> list[str]:
    out = []
    for line in text.splitlines():
        m = re.match(r'^<(?:VST|LV2) "(?:VST|LV2): ([^"(]+?) \(', line) or re.match(r"^<JS (\S+)", line)
        if m:
            out.append(m.group(1))
    return out


def _chain(name: str, optional: bool = False) -> str:
    return (FX / ("Optional" if optional else "") / f"{name}.RfxChain").read_text()


def test_every_vocal_chain_order_and_dynamic_deesser() -> None:
    for name in VOCALS + OPTIONAL:
        plugins = _plugins(_chain(name, name in OPTIONAL))
        assert plugins[:3] == ["ReaGate", "ReaEQ", "ReaComp"], (name, plugins)
        assert "Calf Deesser" in plugins, f"{name}: dynamic de-esser missing"
        assert plugins.index("Calf Deesser") > plugins.index("ReaComp"), f"{name}: de-esser must follow the compressor"


def test_gate_ships_bypassed() -> None:
    for name in VOCALS:
        first = re.search(r"^BYPASS (\d)", _chain(name), flags=re.M).group(1)
        assert first == "1", f"{name}: ReaGate must start bypassed until the room is measured"


def test_no_waveshaper_distortion_and_saturation_is_parallel() -> None:
    for name in VOCALS + OPTIONAL:
        text = _chain(name, name in OPTIONAL)
        assert "waveShapingDstr" not in text, f"{name}: no fuzz-style waveshaper on vocals"
        assert "Liteon/deesser" not in text, f"{name}: Liteon de-esser measured too weak"
        if "loser/Saturation" in text:
            wet = float(re.search(r"^WET ([\d.]+)", text.split("loser/Saturation", 1)[1], flags=re.M).group(1))
            assert 0 < wet <= 0.4, f"{name}: saturation must be blended in parallel (got {wet})"
    assert "loser/Saturation" not in _chain("Lead Clean"), "natural clean: no artificial saturation"


def test_presets_are_differentiated() -> None:
    fx = _plugins(_chain("Lead Clean FX"))
    assert fx.count("ReaComp") == 2, "powerful clean: serial density compression"
    assert _plugins(_chain("Lead Clean")).count("ReaComp") == 1
    assert "loser/Saturation" in _plugins(_chain("Grit Vocal"))
    assert len({_chain(n) for n in VOCALS if not n.startswith("Double")}) == 5


def test_optional_variants_are_templates_not_project_tracks() -> None:
    project = (ROOT / "home/dot_config/REAPER/ProjectTemplates/Music Studio.RPP.tmpl").read_text()
    for name in OPTIONAL:
        assert (TT / "Optional" / f"{name}.RTrackTemplate").is_file()
        assert f"NAME \"{name}\"" not in project
        assert re.search(r"^\s*REC 0 0 ", (TT / "Optional" / f"{name}.RTrackTemplate").read_text(), flags=re.M), \
            f"{name}: mono Input 1, disarmed"


def test_short_room_return_exists() -> None:
    assert "ReaVerbate" in (FX / "Vocal Room.RfxChain").read_text()
