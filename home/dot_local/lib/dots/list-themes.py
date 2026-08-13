#!/usr/bin/env python3
"""List appearance theme packs as JSON for Quickshell / CLI."""
from __future__ import annotations

import json
import os
import sys
from pathlib import Path

EXTS = {".png", ".jpg", ".jpeg", ".webp", ".gif", ".bmp"}


def resolve_wallpaper_file(wallpaper_dir: str, filename: str, walls_root: Path) -> str:
    """Prefer Pictures (chezmoi link), then data dir."""
    pics = Path.home() / "Pictures/Wallpapers" / wallpaper_dir / filename
    data_path = walls_root / wallpaper_dir / filename
    if pics.is_file():
        return str(pics)
    if data_path.is_file():
        return str(data_path)
    # Canonical post-chezmoi target even if not linked yet.
    return str(pics)


def wallpaper_index(theme_id: str, wallpaper_dir: str, walls_root: Path) -> dict[str, str]:
    """Map wallpaper filename → absolute path across Pictures + data roots."""
    paths: dict[str, str] = {}
    pics_root = Path.home() / "Pictures/Wallpapers"
    dir_name = wallpaper_dir or theme_id
    for root in (pics_root, walls_root):
        d = root / dir_name
        if not d.is_dir():
            continue
        for p in d.iterdir():
            if not p.is_file() or p.suffix.lower() not in EXTS:
                continue
            # Prefer Pictures when both roots expose the same name.
            if p.name in paths and root == walls_root:
                continue
            paths[p.name] = str(p.resolve()) if p.exists() else str(p)
    return dict(sorted(paths.items()))


def _gtk_color_scheme(data: dict) -> str:
    raw = str(data.get("gtkColorScheme") or "").strip().lower().replace("_", "-")
    if raw in {"follow", "default", "prefer-light", "prefer-dark"}:
        return raw
    if raw in {"light"}:
        return "prefer-light"
    if raw in {"dark"}:
        return "prefer-dark"
    if raw in {"auto", "apps"}:
        return "default"
    if "gtkPreferDark" in data and data["gtkPreferDark"] is not None:
        return "prefer-dark" if data["gtkPreferDark"] else "prefer-light"
    gtk = str(data.get("gtkTheme") or "").lower()
    if "light" in gtk:
        return "prefer-light"
    if "dark" in gtk:
        return "prefer-dark"
    return "prefer-dark" if data.get("darkMode", True) else "prefer-light"


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
    wallpaper_paths = wallpaper_index(theme_id, wallpaper_dir, walls_root)
    walls = list(wallpaper_paths.keys())
    preview = ""
    for cand in ("preview.jpg", "preview.webp", "preview.png"):
        p = theme_dir / cand
        if p.is_file():
            preview = str(p)
            break
    default = data.get("defaultWallpaper") or (walls[0] if walls else "")
    wallpaper_path = ""
    if default:
        wallpaper_path = wallpaper_paths.get(default) or resolve_wallpaper_file(
            wallpaper_dir, default, walls_root
        )
    return {
        "id": theme_id,
        "name": data.get("name") or theme_id,
        "description": data.get("description") or "",
        "tags": data.get("tags") or [],
        "darkMode": bool(data.get("darkMode", True)),
        "schemeType": data.get("schemeType") or "tonal-spot",
        "gtkTheme": data.get("gtkTheme") or "Orchis-Light-Compact",
        "iconTheme": data.get("iconTheme") or "Numix-Circle",
        "gtkPreferDark": (
            bool(data["gtkPreferDark"])
            if "gtkPreferDark" in data and data["gtkPreferDark"] is not None
            else (
                False
                if "light" in str(data.get("gtkTheme") or "").lower()
                else True
                if "dark" in str(data.get("gtkTheme") or "").lower()
                else bool(data.get("darkMode", True))
            )
        ),
        "gtkColorScheme": _gtk_color_scheme(data),
        "defaultWallpaper": default,
        "wallpaperDir": wallpaper_dir,
        "wallpapers": walls,
        "wallpaperPaths": wallpaper_paths,
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
