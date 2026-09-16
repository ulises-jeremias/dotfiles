#!/usr/bin/env python3
"""Emit a test-only smart-colors scheme.json for the Welcome VM matrix.

Reads the shell's own built-in M3 tables (services/Colours.qml) so the
light scheme is exactly what the product ships; the Pampa scheme is the
dark table with Pampa theme.json tokens applied to the mappable roles
(surfaces, primaries, error/success). Output goes to stdout; the scenario
writes it to ~/.cache/hornero/smart-colors/scheme.json in the guest.

Usage: welcome-schemes.py --mode light|pampa
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

SHELL_ROOT = Path(__file__).resolve().parent.parent.parent.parent
COLOURS_QML = SHELL_ROOT / "services" / "Colours.qml"


def load_tables() -> dict[str, dict[str, str]]:
    text = COLOURS_QML.read_text(encoding="utf-8")
    tables = {}
    for name in ("Dark", "Light"):
        m = re.search(r"_hornero" + name + r"\s*:\s*\(\{(.*?)\}\)", text, re.DOTALL)
        if not m:
            raise SystemExit(f"built-in table _hornero{name} not found")
        pairs = re.findall(r'"([A-Za-z0-9]+)"\s*:\s*"(#[0-9a-fA-F]{6})"', m.group(1))
        if not pairs:
            raise SystemExit(f"no colours parsed for {name}")
        tables[name] = dict(pairs)
    return tables


def to_scheme_colours(qml: dict[str, str]) -> dict[str, str]:
    """Strip the QML m3/term prefix and the leading # (load() re-adds it)."""
    out = {}
    for key, value in qml.items():
        short = key if key.startswith("term") else re.sub(r"^m3", "", key, count=1)
        out[short] = value.lstrip("#")
    return out


PAMPA = {
    "background": "141B13",
    "surface": "1D271C",
    "surfaceVariant": "2B3A28",
    "onSurfaceVariant": "D9CBA7",
    "text": "F4ECDA",
    "textMuted": "B5A87F",
    "primary": "93B25E",
    "onPrimary": "141B0D",
    "secondary": "B3A24A",
    "onSecondary": "1A1508",
    "accent": "D9A441",
    "onAccent": "1A1408",
    "border": "4C5C40",
    "error": "E08A7E",
    "onError": "1C100D",
    "success": "A4C47A",
    "onSuccess": "141B0D",
}


def pampa_scheme(dark: dict[str, str]) -> dict[str, str]:
    base = to_scheme_colours(dark)
    p = PAMPA
    base.update(
        {
            "background": p["background"],
            "onBackground": p["text"],
            "surface": p["surface"],
            "surfaceDim": p["background"],
            "surfaceBright": p["surfaceVariant"],
            "surfaceContainerLowest": p["background"],
            "surfaceContainerLow": p["surface"],
            "surfaceContainer": p["surface"],
            "surfaceContainerHigh": p["surfaceVariant"],
            "surfaceContainerHighest": p["surfaceVariant"],
            "onSurface": p["text"],
            "surfaceVariant": p["surfaceVariant"],
            "onSurfaceVariant": p["onSurfaceVariant"],
            "inverseSurface": p["text"],
            "inverseOnSurface": p["background"],
            "outline": p["border"],
            "outlineVariant": p["surfaceVariant"],
            "surfaceTint": p["primary"],
            "primary": p["primary"],
            "onPrimary": p["onPrimary"],
            "primaryContainer": p["surfaceVariant"],
            "onPrimaryContainer": p["primary"],
            "inversePrimary": p["primary"],
            "secondary": p["secondary"],
            "onSecondary": p["onSecondary"],
            "secondaryContainer": p["surfaceVariant"],
            "onSecondaryContainer": p["secondary"],
            "tertiary": p["accent"],
            "onTertiary": p["onAccent"],
            "tertiaryContainer": p["surfaceVariant"],
            "onTertiaryContainer": p["accent"],
            "error": p["error"],
            "onError": p["onError"],
            "errorContainer": p["surfaceVariant"],
            "onErrorContainer": p["error"],
            "success": p["success"],
            "onSuccess": p["onSuccess"],
            "successContainer": p["surfaceVariant"],
            "onSuccessContainer": p["success"],
        }
    )
    return base


def main() -> None:
    parser = argparse.ArgumentParser(description="Emit a test scheme.json.")
    parser.add_argument("--mode", required=True, choices=["light", "pampa"])
    args = parser.parse_args()
    tables = load_tables()
    if args.mode == "light":
        doc = {
            "name": "hornero-light",
            "flavour": "tonal-spot",
            "mode": "light",
            "colours": to_scheme_colours(tables["Light"]),
        }
    else:
        doc = {
            "name": "pampa",
            "flavour": "tonal-spot",
            "mode": "dark",
            "colours": pampa_scheme(tables["Dark"]),
        }
    json.dump(doc, sys.stdout, indent=2)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
