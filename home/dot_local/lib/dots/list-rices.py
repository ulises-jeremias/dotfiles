#!/usr/bin/env python3
"""List all rices from their config.json files.

Usage: list-rices.py <rices_dir>

Outputs a JSON array of rice objects compatible with Quickshell's Appearances service.
"""

import json
import os
import sys

IMAGE_EXTS = {".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp"}

DEFAULTS = {
    "id": "",
    "name": "",
    "description": "",
    "style": "Unknown",
    "tags": [],
    "schemeType": "tonal-spot",
    "darkMode": True,
    "barPosition": "left",
    "accentColor": "",
    "primaryColor": "",
    "secondaryColor": "",
    "gtkTheme": "auto",
    "iconTheme": "",
    "cursorTheme": "",
    "hyprlandAnimations": "",
    "kittyOpacity": None,
}


def list_rices(rices_dir: str) -> list:
    if not os.path.isdir(rices_dir):
        return []

    records = []
    for name in sorted(os.listdir(rices_dir)):
        rice_dir = os.path.join(rices_dir, name)
        if not os.path.isdir(rice_dir):
            continue

        config_path = os.path.join(rice_dir, "config.json")
        try:
            with open(config_path, encoding="utf-8") as f:
                cfg = json.load(f)
        except Exception:
            cfg = {}

        # Apply defaults for missing keys
        for key, default in DEFAULTS.items():
            cfg.setdefault(key, default)

        # Always use directory name as canonical id
        cfg["id"] = name

        # Scan backgrounds/ for wallpaper images
        bg_dir = os.path.join(rice_dir, "backgrounds")
        wallpapers = []
        if os.path.isdir(bg_dir):
            wallpapers = sorted(
                os.path.join(bg_dir, f)
                for f in os.listdir(bg_dir)
                if os.path.splitext(f)[1].lower() in IMAGE_EXTS
            )

        preview = os.path.join(rice_dir, "preview.png")
        cfg["preview"] = preview if os.path.isfile(preview) else ""
        cfg["wallpapers"] = wallpapers
        cfg["wallpaper"] = wallpapers[0] if wallpapers else ""

        records.append(cfg)

    return records


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: list-rices.py <rices_dir>", file=sys.stderr)
        sys.exit(1)

    rices_dir = os.path.expanduser(sys.argv[1])
    records = list_rices(rices_dir)
    print(json.dumps(records, separators=(",", ":")))


if __name__ == "__main__":
    main()
