"""Keep the personal btop/Cava settings aligned with Hornero Config themes."""

from __future__ import annotations

import configparser
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_btop_uses_hornero_dynamic_theme_and_sensible_sampling_interval():
    config = {}
    for line in (ROOT / "home/dot_config/btop/btop.conf").read_text().splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or "=" not in stripped:
            continue
        key, value = stripped.split("=", 1)
        config[key.strip()] = value.strip().strip('"')

    assert config["color_theme"] == "Hornero Dynamic"
    assert int(config["update_ms"]) >= 2000


def test_cava_selects_the_generated_hornero_theme_without_static_gradient_overrides():
    parser = configparser.ConfigParser(interpolation=None)
    parser.read(ROOT / "home/dot_config/cava/config", encoding="utf-8")

    colors = parser["color"]
    assert colors["theme"].strip("'\"") == "Hornero Dynamic"
    assert not any(key.startswith("gradient_color_") for key in colors)
