#!/usr/bin/env python3
"""List appearance theme packs as JSON for Quickshell / CLI."""
from __future__ import annotations

import json
import os
import sys
from pathlib import Path

EXTS = {".png", ".jpg", ".jpeg", ".webp", ".gif", ".bmp"}


def wallpaper_names(theme_id: str, wallpaper_dir: str, walls_root: Path) -> list[str]:
    d = walls_root / (wallpaper_dir or theme_id)
    if not d.is_dir():
        return []
    return sorted(p.name for p in d.iterdir() if p.is_file() and p.suffix.lower() in EXTS)


def load_theme(theme_dir: Path, walls_root: Path) -> dict | None:
    path = theme_dir / "theme.json"
    if not path.is_file():
        return None
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return None
    theme_id = data.get("id") or theme_dir.name
    wallpaper_dir = data.get("wallpaperDir") or theme_id
    walls = wallpaper_names(theme_id, wallpaper_dir, walls_root)
    preview = ""
    for cand in ("preview.jpg", "preview.webp", "preview.png"):
        p = theme_dir / cand
        if p.is_file():
            preview = str(p)
            break
    default = data.get("defaultWallpaper") or (walls[0] if walls else "")
    wallpaper_path = ""
    if default:
        pics = Path.home() / "Pictures/Wallpapers" / wallpaper_dir / default
        data_path = walls_root / wallpaper_dir / default
        if pics.exists():
            wallpaper_path = str(pics)
        elif data_path.exists():
            wallpaper_path = str(data_path)
        else:
            # Canonical post-chezmoi target even if not linked yet.
            wallpaper_path = str(pics)
    return {
        "id": theme_id,
        "name": data.get("name") or theme_id,
        "description": data.get("description") or "",
        "tags": data.get("tags") or [],
        "darkMode": bool(data.get("darkMode", True)),
        "schemeType": data.get("schemeType") or "tonal-spot",
        "gtkTheme": data.get("gtkTheme") or "Orchis-Dark",
        "iconTheme": data.get("iconTheme") or "Numix-Circle",
        "defaultWallpaper": default,
        "wallpaperDir": wallpaper_dir,
        "wallpapers": walls,
        "preview": preview,
        "wallpaperPath": wallpaper_path,
    }


def _data_home() -> Path:
    return Path(os.environ.get("XDG_DATA_HOME") or Path.home() / ".local/share")


def main() -> int:
    themes_dir = Path(
        os.environ.get(
            "DOTS_THEMES_DIR",
            _data_home() / "dots/themes",
        )
    )
    if len(sys.argv) > 1:
        themes_dir = Path(sys.argv[1])
    walls_root = Path(
        os.environ.get(
            "DOTS_WALLPAPERS_DIR",
            _data_home() / "dots/wallpapers",
        )
    )
    themes: list[dict] = []
    if themes_dir.is_dir():
        for child in sorted(themes_dir.iterdir()):
            if not child.is_dir():
                continue
            item = load_theme(child, walls_root)
            if item:
                themes.append(item)
    json.dump(themes, sys.stdout, indent=2)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
