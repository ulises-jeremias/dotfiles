"""Static guarantees for the guitar tones (no REAPER or audio device required).

These encode decisions that were measured on the workstation (see
docs/REAPER-Vocal-Studio.md): NAM captures + LSP cabinet IRs replace the
Guitarix amp/cabinet plugins, assets come from pinned upstream sources and never
from Git, and the gate sits above the measured single-coil noise floor.
"""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REAPER = ROOT / "home" / "dot_config" / "REAPER"
BUILDER = ROOT / "scripts" / "reaper" / "build-vocal-studio.lua"
INSTALLER = ROOT / "home" / "dot_local" / "bin" / "executable_reaper-guitar-assets"
SWITCHER = REAPER / "Scripts" / "Vocal Studio" / "Guitar - Choose tone.lua"
TRIM = ROOT / "scripts" / "reaper" / "guitar-tones-trim.txt"
ASSET_PREFIX = "{{ .chezmoi.homeDir }}/.local/share/reaper-studio/guitar/"

TONES = {
    "Clean": ["Crystal Clean", "Warm Clean - Ambient"],
    "Rock": ["Classic Rock - Crunch", "Hard Rock - Heavy Lead"],
    "Metal": ["Modern Metal Rhythm", "Extreme Metal Rhythm", "Metalcore - Melodic Lead"],
}
GATED = {"Hard Rock - Heavy Lead", "Modern Metal Rhythm", "Extreme Metal Rhythm", "Metalcore - Melodic Lead"}
NOISE_PEAK_DBFS = -59.4  # measured on the real Squier DI at the current Scarlett gain
NAM_MODEL = re.compile(r"neural-amp-modeler-lv2#model (.+?) 3$", re.M)
IR_FILE = re.compile(r"impulse_responses_mono/ports#ifn (.+?) 3$", re.M)


def _tones():
    for cat, names in TONES.items():
        for name in names:
            yield cat, name


def _file(kind: str, cat: str, name: str) -> Path:
    folder, ext = ("FXChains", "RfxChain") if kind == "fx" else ("TrackTemplates", "RTrackTemplate")
    return REAPER / folder / "Guitar Tones" / cat / f"{name}.{ext}.tmpl"


def test_every_tone_has_a_templated_track_template_and_fx_chain() -> None:
    for cat, name in _tones():
        assert _file("tt", cat, name).is_file(), name
        assert _file("fx", cat, name).is_file(), name


def test_no_legacy_or_stale_tone_files_remain() -> None:
    expected = {f"{n}.{ext}.tmpl" for _, n in _tones() for ext in ("RfxChain", "RTrackTemplate")}
    found = {p.name for p in (REAPER / "FXChains" / "Guitar Tones").rglob("*") if p.is_file()}
    found |= {p.name for p in (REAPER / "TrackTemplates" / "Guitar Tones").rglob("*") if p.is_file()}
    assert found == expected


def test_tone_chains_are_balanced() -> None:
    for cat, name in _tones():
        text = _file("fx", cat, name).read_text()
        assert text.startswith("<FXCHAIN"), name
        opens = len(re.findall(r"^\s*<", text, flags=re.M))
        closes = len(re.findall(r"^\s*>\s*$", text, flags=re.M))
        assert opens == closes, f"{name}: unbalanced chain ({opens} open, {closes} close)"


def test_no_guitarix_amp_or_cabinet_convolvers() -> None:
    # Measured: GxCabinet had no effect, and several Guitarix convolvers in one
    # REAPER process crash in libfftw3f. Amps are NAM, cabinets are LSP IRs.
    for cat, name in _tones():
        text = _file("fx", cat, name).read_text()
        for banned in ("GxCabinet", "GxAmplifier-X", "GxMetalAmp", "GxMetalHead", "GxExpander"):
            assert banned not in text, f"{name} uses {banned}"


def test_each_tone_has_one_amp_capture_and_one_cabinet_ir_with_files() -> None:
    for cat, name in _tones():
        text = _file("fx", cat, name).read_text()
        models, irs = NAM_MODEL.findall(text), IR_FILE.findall(text)
        assert len(models) == 1, f"{name}: expected one NAM capture with a model, got {models}"
        assert len(irs) == 1, f"{name}: expected one cabinet IR with a file, got {irs}"
        for path in models + irs:
            assert path.startswith(ASSET_PREFIX), f"{name}: asset path not templated: {path}"
            # the rendered path (after the template prefix) must not contain spaces:
            # REAPER's LV2 state text is space-separated
            assert " " not in path.removeprefix(ASSET_PREFIX), f"{name}: spaces in asset path {path}"
        assert text.index("Neural Amp Modeler") < text.index("LSP Impulse Responses"), name


def test_no_personal_home_directory_in_reaper_files() -> None:
    for path in REAPER.rglob("*"):
        if path.is_file() and "Basic Vocal Tracking" not in path.name:
            assert "/home/" not in path.read_text(errors="ignore"), path.relative_to(ROOT)


def test_every_referenced_asset_is_pinned_in_the_installer() -> None:
    installer = INSTALLER.read_text()
    pinned_models = set(re.findall(r'"([\w.+-]+\.nam)\|[^|]+\|[0-9a-f]{64}"', installer))
    required_irs = set(re.findall(r'"((?:brutal|emerald)/[\w.-]+\.wav)"', installer))
    for cat, name in _tones():
        text = _file("fx", cat, name).read_text()
        model = NAM_MODEL.search(text).group(1).removeprefix(ASSET_PREFIX + "nam/")
        ir = IR_FILE.search(text).group(1).removeprefix(ASSET_PREFIX + "ir/")
        assert model in pinned_models, f"{name}: {model} not pinned in reaper-guitar-assets"
        assert ir in required_irs, f"{name}: {ir} not listed in reaper-guitar-assets"


def test_installer_pins_versions_and_never_writes_to_git_or_system() -> None:
    text = INSTALLER.read_text()
    assert "set -euo pipefail" in text
    assert re.search(r'NAM_LV2_SHA="[0-9a-f]{64}"', text)
    assert re.search(r'NAM_COMMIT="[0-9a-f]{40}"', text), "captures must come from a pinned commit"
    assert "checksum mismatch" in text and "refusing to install" in text
    assert "sudo" not in text and "pacman" not in text, "assets install at user level only"
    assert "dots-" not in text


def test_gate_thresholds_sit_above_the_measured_noise_peak() -> None:
    builder = BUILDER.read_text()
    thresholds = [int(t) for t in re.findall(r"guitar_gate\(tr, (-\d+), \d+\)", builder)]
    assert len(thresholds) == len(GATED)
    for t in thresholds:
        close_threshold = t - 6  # -6 dB hysteresis
        assert close_threshold > NOISE_PEAK_DBFS, f"gate closes at {close_threshold} dBFS, below noise peaks"
        assert t <= -40, "gate opens too high: it would chop quiet notes"


def test_nam_output_calibration_covers_every_tone() -> None:
    cal = {}
    for line in TRIM.read_text().splitlines():
        m = re.match(r"^nam:(.+)\|(-?[\d.]+)$", line)
        if m:
            cal[m.group(1)] = float(m.group(2))
    assert set(cal) == {n for _, n in _tones()}
    assert all(-20.0 <= v <= 20.0 for v in cal.values()), "NAM Output Lvl range is +/-20 dB"


def test_tone_switcher_lists_every_tone_and_bypasses_inactive_ones() -> None:
    script = SWITCHER.read_text()
    for _, name in _tones():
        assert f'"{name}"' in script, name
    assert "Hard Stuff" not in script and "Legacy" not in script
    assert "I_FXEN" in script and "B_MUTE" in script
    assert "I_RECARM" not in script and "1013" not in script, "switching tones must never record"
