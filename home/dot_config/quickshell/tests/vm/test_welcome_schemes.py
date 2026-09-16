"""Unit tests for the Welcome VM matrix generator (no hypervisor needed).

welcome-schemes.py reads the shell's own built-in M3 tables, so these
tests pin the exact contract the guest consumes: scheme names, modes,
key shapes, and bare-hex values (Colours.qml prepends `#` on load).
"""

from __future__ import annotations

import json
import subprocess
from pathlib import Path

LIB = Path(__file__).resolve().parent / "lib"
GEN = LIB / "welcome-schemes.py"

EXPECTED_KEYS = {
    "background", "onBackground", "surface", "surfaceDim", "surfaceBright",
    "surfaceContainerLowest", "surfaceContainerLow", "surfaceContainer",
    "surfaceContainerHigh", "surfaceContainerHighest", "onSurface",
    "surfaceVariant", "onSurfaceVariant", "inverseSurface",
    "inverseOnSurface", "outline", "outlineVariant", "shadow", "scrim",
    "surfaceTint", "primary", "onPrimary", "primaryContainer",
    "onPrimaryContainer", "inversePrimary", "secondary", "onSecondary",
    "secondaryContainer", "onSecondaryContainer", "tertiary", "onTertiary",
    "tertiaryContainer", "onTertiaryContainer", "error", "onError",
    "errorContainer", "onErrorContainer", "success", "onSuccess",
    "successContainer", "onSuccessContainer", "primaryFixed",
    "primaryFixedDim", "onPrimaryFixed", "onPrimaryFixedVariant",
    "secondaryFixed", "secondaryFixedDim", "onSecondaryFixed",
    "onSecondaryFixedVariant", "tertiaryFixed", "tertiaryFixedDim",
    "onTertiaryFixed", "onTertiaryFixedVariant",
    *[f"term{i}" for i in range(16)],
}


def _generate(mode: str) -> dict:
    proc = subprocess.run(
        ["python3", str(GEN), "--mode", mode],
        capture_output=True, text=True, timeout=60,
    )
    assert proc.returncode == 0, proc.stderr
    return json.loads(proc.stdout)


def _assert_shape(doc: dict, name: str, mode: str) -> None:
    assert doc["name"] == name
    assert doc["flavour"] == "tonal-spot"
    assert doc["mode"] == mode
    colours = doc["colours"]
    assert set(colours) == EXPECTED_KEYS, \
        f"missing: {EXPECTED_KEYS - set(colours)}, extra: {set(colours) - EXPECTED_KEYS}"
    for key, value in colours.items():
        assert isinstance(value, str) and len(value) == 6, f"{key}: {value!r}"
        int(value, 16)  # bare hex, no leading '#'
        assert not value.startswith("#"), f"{key} must be bare hex"


def test_light_scheme_matches_builtin():
    _assert_shape(_generate("light"), "hornero-light", "light")


def test_pampa_scheme_applies_tokens():
    doc = _generate("pampa")
    _assert_shape(doc, "pampa", "dark")
    colours = doc["colours"]
    assert colours["primary"] == "93B25E"
    assert colours["onPrimary"] == "141B0D"
    assert colours["secondary"] == "B3A24A"
    assert colours["tertiary"] == "D9A441"
    assert colours["surface"] == "1D271C"
    assert colours["background"] == "141B13"
    assert colours["onSurface"] == "F4ECDA"
