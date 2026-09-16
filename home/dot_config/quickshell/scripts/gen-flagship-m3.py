#!/usr/bin/env python3
"""Generate the shell flagship M3 tables from canonical Hornero seeds.

One M3 source color feeds both modes (M3-correct: Fixed colors are
mode-independent, which two seeds would break). SOURCE is the
HorneroOS/config hornero-dark primary #E07856 ember terracotta, so the
shell flagship tables stay in the config brand hue family with
role-appropriate lightness per the M3 spec (a dark-mode primary is tone
80 by spec, hence lighter than the brand hex; this is intentional,
not drift).

SOURCE mirrors HorneroOS/config
profiles/themes/hornero-dark/theme.json `palette.primary`. If config
moves that primary, update SOURCE here and re-run; the --check gate
fails CI on drift. Non-M3 extras (scrim/shadow/success*/term*) are
hand-owned and untouched by this script.

Requires: pip install materialyoucolor==3.0.4
Usage: scripts/gen-flagship-m3.py --emit   # print QML table blocks
       scripts/gen-flagship-m3.py --check  # verify committed tables
SPDX-License-Identifier: MIT
"""
import re
import sys
from pathlib import Path

SOURCE = 0xE07856
MCU_VERSION = "3.0.4"

ROLES = [
    "primary", "onPrimary", "primaryContainer", "onPrimaryContainer",
    "secondary", "onSecondary", "secondaryContainer", "onSecondaryContainer",
    "tertiary", "onTertiary", "tertiaryContainer", "onTertiaryContainer",
    "background", "onBackground", "surface", "onSurface",
    "surfaceDim", "surfaceBright", "surfaceContainerLowest",
    "surfaceContainerLow", "surfaceContainer", "surfaceContainerHigh",
    "surfaceContainerHighest", "surfaceVariant", "onSurfaceVariant",
    "outline", "outlineVariant", "scrim", "shadow",
    "error", "onError", "errorContainer", "onErrorContainer",
    "inverseSurface", "inverseOnSurface", "inversePrimary", "surfaceTint",
    "primaryFixed", "primaryFixedDim", "onPrimaryFixed",
    "onPrimaryFixedVariant", "secondaryFixed", "secondaryFixedDim",
    "onSecondaryFixed", "onSecondaryFixedVariant", "tertiaryFixed",
    "tertiaryFixedDim", "onTertiaryFixed", "onTertiaryFixedVariant",
]
# scrim/shadow/success*/term* are hand-owned extras, not M3 roles.
GENERATED = [r for r in ROLES
             if r not in ("scrim", "shadow")]

ROOT = Path(__file__).resolve().parent.parent
COLOURS = ROOT / "services" / "Colours.qml"


def scheme_map(source_hex, dark):
    from materialyoucolor.dynamiccolor.material_dynamic_colors import (
        MaterialDynamicColors as MD,
    )
    from materialyoucolor.hct.hct import Hct
    from materialyoucolor.scheme.scheme_tonal_spot import SchemeTonalSpot
    import materialyoucolor

    assert materialyoucolor.__version__.split(".")[:2] == \
        MCU_VERSION.split(".")[:2], (
        f"need materialyoucolor {MCU_VERSION}, "
        f"have {materialyoucolor.__version__}")
    scheme = SchemeTonalSpot(
        source_color_hct=Hct.from_int(source_hex),
        is_dark=dark, contrast_level=0.0)
    out = {}
    for role in GENERATED:
        out[role] = f"#{getattr(MD, role).get_argb(scheme) & 0xFFFFFF:06x}"
    for palette, name in (
            (scheme.primary_palette, "primary"),
            (scheme.secondary_palette, "secondary"),
            (scheme.tertiary_palette, "tertiary"),
            (scheme.neutral_palette, "neutral"),
            (scheme.neutral_variant_palette, "neutral_variant")):
        out[f"{name}_paletteKeyColor"] = \
            f"#{palette.key_color.to_int() & 0xFFFFFF:06x}"
    return out


def flagship_maps():
    """Dark + light flagship maps. Fixed roles are pinned to the dark
    scheme values: M3 declares them mode-independent, but the generator
    library computes them per-mode, so the pin restores the invariant
    (enforced by test_mode_coherence_no_leakage)."""
    dark = scheme_map(SOURCE, True)
    light = scheme_map(SOURCE, False)
    for key in [k for k in dark if "Fixed" in k]:
        light[key] = dark[key]
    return dark, light


def table_entries(text, name):
    start = text.index(f"readonly property var {name}")
    region = text[start:]
    entries = {}
    for line in region.splitlines()[1:]:
        if line.strip() == "})":
            break
        match = re.match(
            r'\s*"([^"]+)":\s*"(#[0-9a-fA-F]{6})"\s*,?\s*$', line)
        if match:
            entries[match.group(1)] = match.group(2)
    return entries


def check():
    try:
        dark, light = flagship_maps()
    except ImportError as exc:
        print(f"SKIP: {exc} (pip install materialyoucolor=={MCU_VERSION})")
        return 0
    text = COLOURS.read_text()
    problems = []
    for name, expected in (("_horneroDark", dark),
                           ("_horneroLight", light)):
        committed = table_entries(text, name)
        for key, want in expected.items():
            got = committed.get(key)
            if got is None:
                problems.append(f"{name}: missing key {key}")
            elif got.lower() != want.lower():
                problems.append(
                    f"{name}.{key}: committed {got} != generated {want}")
    # M3Palette defaults track the dark flagship table.
    defaults = dict(re.findall(
        r'property color (m3\w+|term\d+):\s*"(#[0-9a-fA-F]{6})"', text))
    for key, want in dark.items():
        prop = f"m3{key}"
        got = defaults.get(prop)
        if got is None:
            problems.append(f"M3Palette: missing default {prop}")
        elif got.lower() != want.lower():
            problems.append(
                f"M3Palette.{prop}: {got} != generated {want}")
    if problems:
        print("DRIFT: flagship tables do not match generated schemes:")
        for problem in problems:
            print(f"  - {problem}")
        print("Re-run: scripts/gen-flagship-m3.py --emit, then paste.")
        return 1
    print(f"OK: flagship tables match generated schemes "
          f"(source #{SOURCE:06x})")
    return 0


def emit():
    dark, light = flagship_maps()
    for name, mapping in (("_horneroDark", dark),
                          ("_horneroLight", light)):
        print(f"    readonly property var {name}: ({{")
        for key, value in mapping.items():
            print(f'        "{key}": "{value}",')
        print("    })")


if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 else "--check"
    if mode == "--emit":
        emit()
    elif mode == "--check":
        sys.exit(check())
    else:
        print(f"usage: {Path(sys.argv[0]).name} [--emit|--check]",
              file=sys.stderr)
        sys.exit(2)
