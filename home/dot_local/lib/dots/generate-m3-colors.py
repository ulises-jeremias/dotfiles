#!/usr/bin/env python3
"""Generate Material Design 3 color scheme from a wallpaper image.

Uses the materialyoucolor library to extract HCT source color, generate
a full M3 scheme (60+ color roles), success colors, and 16 ANSI terminal
colors.  Outputs a single JSON file consumed by Quickshell's Colours service.

Requires: pip install materialyoucolor
"""

import argparse
import importlib
import json
import math
import sys
from pathlib import Path

SCHEME_MODULES = {
    "vibrant": ("materialyoucolor.scheme.scheme_vibrant", "SchemeVibrant"),
    "tonal-spot": ("materialyoucolor.scheme.scheme_tonal_spot", "SchemeTonalSpot"),
    "expressive": ("materialyoucolor.scheme.scheme_expressive", "SchemeExpressive"),
    "neutral": ("materialyoucolor.scheme.scheme_neutral", "SchemeNeutral"),
    "fidelity": ("materialyoucolor.scheme.scheme_fidelity", "SchemeFidelity"),
    "content": ("materialyoucolor.scheme.scheme_content", "SchemeContent"),
    "monochrome": ("materialyoucolor.scheme.scheme_monochrome", "SchemeMonochrome"),
}

ANSI_HUES = {
    1: 25,    # red
    2: 145,   # green
    3: 85,    # yellow
    4: 250,   # blue
    5: 310,   # magenta
    6: 190,   # cyan
}


def parse_args():
    parser = argparse.ArgumentParser(
        description="Generate M3 color scheme from wallpaper image",
    )
    parser.add_argument("--image", required=True, help="Path to wallpaper image")
    parser.add_argument(
        "--scheme-type",
        default="auto",
        choices=["auto", *SCHEME_MODULES],
        help="M3 scheme variant (default: auto)",
    )
    parser.add_argument(
        "--mode",
        default="dark",
        choices=["dark", "light"],
        help="Color mode (default: dark)",
    )
    parser.add_argument("--output", default=None, help="Output JSON file path")
    parser.add_argument(
        "--quality",
        type=int,
        default=5,
        help="Quantization quality — 1 uses every pixel, higher skips (default: 5)",
    )
    return parser.parse_args()


# ---------------------------------------------------------------------------
# Color extraction
# ---------------------------------------------------------------------------

def extract_source_color(image_path: str, quality: int = 5, max_colors: int = 128) -> int:
    """Return the best ARGB theme color from *image_path*."""

    # Fast path: cpp backend via ImageQuantizeCelebi
    try:
        from materialyoucolor.quantize import ImageQuantizeCelebi
        from materialyoucolor.score.score import Score

        histogram = ImageQuantizeCelebi(image_path, quality, max_colors)
        return Score.score(histogram)[0]
    except (ImportError, OSError):
        pass

    # Fallback: PIL + QuantizeCelebi
    from PIL import Image
    from materialyoucolor.quantize import QuantizeCelebi
    from materialyoucolor.score.score import Score

    img = Image.open(image_path)
    if getattr(img, "format", None) == "GIF":
        img.seek(1)
    if img.mode in ("L", "P", "LA", "PA"):
        img = img.convert("RGB")
    elif img.mode == "RGBA":
        img = img.convert("RGB")

    w, h = img.size
    target = 128 * 128
    if w * h > target:
        s = math.sqrt(target / (w * h))
        img = img.resize((max(1, round(w * s)), max(1, round(h * s))), Image.Resampling.BICUBIC)

    histogram = QuantizeCelebi(list(img.getdata()), max_colors)
    return Score.score(histogram)[0]


# ---------------------------------------------------------------------------
# Scheme helpers
# ---------------------------------------------------------------------------

def resolve_scheme_type(requested: str, hct) -> str:
    if requested != "auto":
        return requested

    chroma = hct.chroma
    if chroma < 10:
        return "monochrome"
    if chroma < 22:
        return "neutral"
    if chroma < 38:
        return "tonal-spot"
    return "vibrant"


def make_scheme(scheme_type: str, hct, dark: bool):
    mod_path, cls_name = SCHEME_MODULES[scheme_type]
    cls = getattr(importlib.import_module(mod_path), cls_name)
    try:
        return cls(hct, dark, 0.0, spec_version="2025")
    except TypeError:
        return cls(hct, dark, 0.0)


# ---------------------------------------------------------------------------
# M3 color roles
# ---------------------------------------------------------------------------

def _argb_to_hex6(argb: int) -> str:
    from materialyoucolor.utils.color_utils import rgba_from_argb

    r, g, b, *_ = rgba_from_argb(argb)
    return f"{round(r):02X}{round(g):02X}{round(b):02X}"


def _hct_to_hex6(hue: float, chroma: float, tone: float) -> str:
    from materialyoucolor.hct import Hct

    return _argb_to_hex6(Hct.from_hct(hue, chroma, tone).to_int())


def generate_material_colors(scheme) -> dict[str, str]:
    """Extract every M3 color role from *scheme* as ``{name: hex6}``."""
    colors: dict[str, str] = {}

    # v3 / 2025-spec API
    try:
        from materialyoucolor.dynamiccolor.color_spec import COLOR_NAMES
        from materialyoucolor.dynamiccolor.material_dynamic_colors import MaterialDynamicColors

        mdc = MaterialDynamicColors(spec="2025")
        for name in COLOR_NAMES:
            dc = getattr(mdc, name, None)
            if dc is None:
                continue
            raw = dc.get_hex(scheme)
            colors[name] = raw.lstrip("#")[:6]
        return colors
    except (ImportError, TypeError, AttributeError):
        pass

    # v2 / legacy API
    from materialyoucolor.dynamiccolor.material_dynamic_colors import MaterialDynamicColors

    for attr in sorted(vars(MaterialDynamicColors)):
        dc = getattr(MaterialDynamicColors, attr)
        if not hasattr(dc, "get_hct"):
            continue
        rgba = dc.get_hct(scheme).to_rgba()
        colors[attr] = f"{round(rgba[0]):02X}{round(rgba[1]):02X}{round(rgba[2]):02X}"

    return colors


# ---------------------------------------------------------------------------
# Success colors (green-based, harmonized toward source hue)
# ---------------------------------------------------------------------------

def _harmonize_hue(base: float, target: float, amount: float = 0.15) -> float:
    diff = target - base
    if diff > 180:
        diff -= 360
    elif diff < -180:
        diff += 360
    return (base + diff * amount) % 360


def generate_success_colors(source_hct, dark: bool) -> dict[str, str]:
    hue = _harmonize_hue(145, source_hct.hue, 0.15)
    if dark:
        return {
            "success": _hct_to_hex6(hue, 30, 80),
            "onSuccess": _hct_to_hex6(hue, 25, 20),
            "successContainer": _hct_to_hex6(hue, 25, 30),
            "onSuccessContainer": _hct_to_hex6(hue, 20, 90),
        }
    return {
        "success": _hct_to_hex6(hue, 35, 40),
        "onSuccess": _hct_to_hex6(hue, 0, 100),
        "successContainer": _hct_to_hex6(hue, 20, 90),
        "onSuccessContainer": _hct_to_hex6(hue, 25, 10),
    }


# ---------------------------------------------------------------------------
# Terminal colors (16 ANSI colors, harmonized toward source palette)
# ---------------------------------------------------------------------------

def generate_terminal_colors(source_hct, dark: bool) -> dict[str, str]:
    p_hue = source_hct.hue
    p_chr = max(source_hct.chroma, 20)

    colors: dict[str, str] = {}

    if dark:
        colors["term0"] = _hct_to_hex6(p_hue, min(p_chr * 0.3, 12), 20)
        colors["term7"] = _hct_to_hex6(p_hue, min(p_chr * 0.15, 8), 85)
        colors["term8"] = _hct_to_hex6(p_hue, min(p_chr * 0.2, 10), 45)
        colors["term15"] = _hct_to_hex6(p_hue, min(p_chr * 0.05, 5), 97)

        for idx, base_hue in ANSI_HUES.items():
            h = _harmonize_hue(base_hue, p_hue, 0.2)
            c = min(p_chr * 0.8, 55)
            colors[f"term{idx}"] = _hct_to_hex6(h, c, 72)
            colors[f"term{idx + 8}"] = _hct_to_hex6(h, c * 0.85, 85)
    else:
        colors["term0"] = _hct_to_hex6(p_hue, min(p_chr * 0.3, 12), 92)
        colors["term7"] = _hct_to_hex6(p_hue, min(p_chr * 0.15, 8), 25)
        colors["term8"] = _hct_to_hex6(p_hue, min(p_chr * 0.2, 10), 60)
        colors["term15"] = _hct_to_hex6(p_hue, min(p_chr * 0.05, 5), 5)

        for idx, base_hue in ANSI_HUES.items():
            h = _harmonize_hue(base_hue, p_hue, 0.2)
            c = min(p_chr * 0.8, 55)
            colors[f"term{idx}"] = _hct_to_hex6(h, c, 40)
            colors[f"term{idx + 8}"] = _hct_to_hex6(h, c * 0.85, 28)

    return colors


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    args = parse_args()

    image_path = Path(args.image).expanduser().resolve()
    if not image_path.is_file():
        print(f"Error: image not found: {image_path}", file=sys.stderr)
        sys.exit(1)

    try:
        from materialyoucolor.hct import Hct
    except ImportError:
        print(
            "Error: materialyoucolor is not installed.\n"
            "  pip install materialyoucolor --upgrade",
            file=sys.stderr,
        )
        sys.exit(1)

    source_argb = extract_source_color(str(image_path), args.quality)
    source_hct = Hct.from_int(source_argb)

    dark = args.mode == "dark"
    scheme_type = resolve_scheme_type(args.scheme_type, source_hct)
    scheme = make_scheme(scheme_type, source_hct, dark)

    colours = generate_material_colors(scheme)
    colours.update(generate_success_colors(source_hct, dark))
    colours.update(generate_terminal_colors(source_hct, dark))

    output = {
        "name": "dynamic",
        "flavour": scheme_type,
        "mode": args.mode,
        "colours": colours,
    }

    payload = json.dumps(output, indent=4) + "\n"

    if args.output:
        out = Path(args.output).expanduser().resolve()
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(payload)
    else:
        sys.stdout.write(payload)


if __name__ == "__main__":
    main()
