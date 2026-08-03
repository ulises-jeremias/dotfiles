#!/usr/bin/env python3
"""One-shot migrator: rices → theme packs + themed wallpaper dirs.

Run from repo root. Idempotent: clears destination theme/wallpaper theme dirs first.
"""
from __future__ import annotations

import hashlib
import json
import shutil
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
RICES = ROOT / "home/dot_local/share/dots/rices"
THEMES = ROOT / "home/dot_local/share/dots/themes"
WALLS = ROOT / "home/dot_local/share/dots/wallpapers"
EXTS = {".png", ".jpg", ".jpeg", ".webp", ".gif"}
MAX_LONG = 2560
PREVIEW_W = 640
PREVIEW_MAX_KB = 200

# theme_id -> list of (source_rice, relative preferred names or "*")
# Ownership for shared hashes is decided by first writer in THEME_SOURCES order.
THEME_SOURCES: dict[str, list[str]] = {
    "vapor-dreams": ["vapor-dreams"],
    "neon-city": ["neon-city"],
    "gruvbox": ["gruvbox-anime", "gruvbox-pixelart", "gruvbox-minimalistic"],
    "landscape": ["landscape"],
    "warm-sunset": ["warm-sunset"],
    "soft-morning": ["soft-morning", "cozy-corner", "flowers", "pastel-dreams"],
    "catppuccin-mocha": ["catppuccin-mocha"],
    "catppuccin-latte": ["catppuccin-latte"],
    "rose-pine": ["rose-pine"],
    "nord-dreams": ["nord-dreams"],
    "everforest": ["everforest"],
    "monochrome": ["monochrome"],
}

THEME_META: dict[str, dict] = {
    "vapor-dreams": {
        "name": "Vapor Dreams",
        "description": "Nostalgic 80s/90s vaporwave with retro gradients",
        "tags": ["vaporwave", "retro", "synthwave", "dark"],
        "darkMode": True,
        "schemeType": "expressive",
        "gtkTheme": "Orchis-Dark",
        "iconTheme": "Numix-Circle",
    },
    "neon-city": {
        "name": "Neon City",
        "description": "Cyberpunk neon nights and futuristic streets",
        "tags": ["cyberpunk", "neon", "dark", "city"],
        "darkMode": True,
        "schemeType": "vibrant",
        "gtkTheme": "Orchis-Dark-Compact",
        "iconTheme": "Numix-Circle",
    },
    "gruvbox": {
        "name": "Gruvbox",
        "description": "Warm retro palette with anime and pixel art",
        "tags": ["gruvbox", "warm", "retro", "anime", "dark"],
        "darkMode": True,
        "schemeType": "expressive",
        "gtkTheme": "Orchis-Dark",
        "iconTheme": "Numix-Circle",
    },
    "landscape": {
        "name": "Landscape",
        "description": "Cinematic nature vistas and fantasy scenery",
        "tags": ["nature", "cinematic", "landscape", "dark"],
        "darkMode": True,
        "schemeType": "fidelity",
        "gtkTheme": "Orchis-Dark",
        "iconTheme": "Numix-Circle",
    },
    "warm-sunset": {
        "name": "Warm Sunset",
        "description": "Golden-hour landscapes with warm cinematic tones",
        "tags": ["sunset", "warm", "cinematic", "light"],
        "darkMode": False,
        "schemeType": "vibrant",
        "gtkTheme": "Orchis-Light",
        "iconTheme": "Numix-Circle",
    },
    "soft-morning": {
        "name": "Soft Morning",
        "description": "Calm mist, florals, and soft natural light",
        "tags": ["morning", "calm", "pastel", "light"],
        "darkMode": False,
        "schemeType": "neutral",
        "gtkTheme": "Orchis-Light",
        "iconTheme": "Numix-Circle",
    },
    "catppuccin-mocha": {
        "name": "Catppuccin Mocha",
        "description": "Cozy dark Catppuccin with soft pastels",
        "tags": ["catppuccin", "pastel", "cozy", "dark"],
        "darkMode": True,
        "schemeType": "tonal-spot",
        "gtkTheme": "Orchis-Dark",
        "iconTheme": "Papirus-Dark",
    },
    "catppuccin-latte": {
        "name": "Catppuccin Latte",
        "description": "Light Catppuccin mauve for soft daytime sessions",
        "tags": ["catppuccin", "pastel", "light"],
        "darkMode": False,
        "schemeType": "tonal-spot",
        "gtkTheme": "catppuccin-latte-mauve-compact",
        "iconTheme": "Papirus",
    },
    "rose-pine": {
        "name": "Rosé Pine",
        "description": "Elegant muted rose and pine dark palette",
        "tags": ["rose-pine", "muted", "dark"],
        "darkMode": True,
        "schemeType": "expressive",
        "gtkTheme": "Orchis-Dark",
        "iconTheme": "Numix-Circle",
    },
    "nord-dreams": {
        "name": "Nord Dreams",
        "description": "Cool arctic Nord tones and frosty calm",
        "tags": ["nord", "cool", "minimal", "dark"],
        "darkMode": True,
        "schemeType": "tonal-spot",
        "gtkTheme": "Orchis-Dark-Compact",
        "iconTheme": "Numix-Circle",
    },
    "everforest": {
        "name": "Everforest",
        "description": "Soft green forest fidelity theme",
        "tags": ["everforest", "nature", "green", "dark"],
        "darkMode": True,
        "schemeType": "fidelity",
        "gtkTheme": "Orchis-Dark",
        "iconTheme": "Numix-Circle",
    },
    "monochrome": {
        "name": "Monochrome",
        "description": "High-contrast black and white focus aesthetic",
        "tags": ["monochrome", "minimal", "a11y", "dark"],
        "darkMode": True,
        "schemeType": "monochrome",
        "gtkTheme": "Adwaita-dark",
        "iconTheme": "Papirus-Dark",
    },
}


def file_digest(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def is_valid_image(path: Path) -> bool:
    try:
        with Image.open(path) as im:
            im.verify()
        with Image.open(path) as im:
            im.load()
        return True
    except Exception:
        return False


def resize_max(im: Image.Image, max_long: int) -> Image.Image:
    w, h = im.size
    long = max(w, h)
    if long <= max_long:
        return im
    scale = max_long / long
    return im.resize((int(w * scale), int(h * scale)), Image.Resampling.LANCZOS)


def save_wallpaper(src: Path, dest: Path) -> Path:
    dest.parent.mkdir(parents=True, exist_ok=True)
    with Image.open(src) as im:
        im = im.convert("RGB") if im.mode in ("P", "RGBA", "LA") else im
        im = resize_max(im, MAX_LONG)
        # Prefer jpeg for photos; keep png for tiny/simple graphics under 300KB source
        # Build the output path explicitly — Path.with_suffix breaks on stems that contain dots.
        if src.suffix.lower() == ".png" and src.stat().st_size < 300_000 and max(im.size) <= 1920:
            out = Path(f"{dest}.png")
            im.save(out, format="PNG", optimize=True)
        else:
            out = Path(f"{dest}.jpg")
            im.save(out, format="JPEG", quality=88, optimize=True)
    return out


def save_preview(src: Path, dest: Path) -> Path:
    dest.parent.mkdir(parents=True, exist_ok=True)
    with Image.open(src) as im:
        im = im.convert("RGB")
        w, h = im.size
        scale = PREVIEW_W / w
        im = im.resize((PREVIEW_W, max(1, int(h * scale))), Image.Resampling.LANCZOS)
        out = Path(f"{dest}.jpg")
        quality = 82
        while quality >= 50:
            im.save(out, format="JPEG", quality=quality, optimize=True)
            if out.stat().st_size <= PREVIEW_MAX_KB * 1024:
                break
            quality -= 8
    return out


def collect_source_images(rice_ids: list[str]) -> list[Path]:
    files: list[Path] = []
    for rid in rice_ids:
        bg = RICES / rid / "backgrounds"
        if not bg.is_dir():
            continue
        for p in sorted(bg.iterdir()):
            if p.suffix.lower() in EXTS and p.is_file():
                files.append(p)
    return files


def main() -> None:
    seen_hashes: set[str] = set()
    THEMES.mkdir(parents=True, exist_ok=True)

    # Remove previous theme dirs / themed wallpaper dirs (keep curated/)
    if THEMES.exists():
        for child in THEMES.iterdir():
            if child.is_dir():
                shutil.rmtree(child)
    for child in WALLS.iterdir():
        if child.is_dir() and child.name != "curated":
            shutil.rmtree(child)

    for theme_id, sources in THEME_SOURCES.items():
        meta = THEME_META[theme_id]
        wall_dir = WALLS / theme_id
        theme_dir = THEMES / theme_id
        wall_dir.mkdir(parents=True, exist_ok=True)
        theme_dir.mkdir(parents=True, exist_ok=True)

        written: list[str] = []
        preview_src: Path | None = None

        for src in collect_source_images(sources):
            if not is_valid_image(src):
                print(f"SKIP corrupt: {src}")
                continue
            digest = file_digest(src)
            if digest in seen_hashes:
                print(f"SKIP dup: {src}")
                continue
            # Skip near-empty placeholders (< 80KB and tiny visual interest for monochrome keep if only option)
            if src.stat().st_size < 20_000:
                print(f"SKIP tiny: {src}")
                continue
            seen_hashes.add(digest)
            stem = src.stem
            # Avoid colliding names across merged sources
            dest_base = wall_dir / stem
            n = 2
            while any(Path(f"{dest_base}{ext}").exists() for ext in (".jpg", ".png", ".jpeg", ".webp")):
                dest_base = wall_dir / f"{stem}-{n}"
                n += 1
            out = save_wallpaper(src, dest_base)
            written.append(out.name)
            if preview_src is None:
                preview_src = out

        # Prefer original rice preview if valid and not huge-as-wallpaper only
        for rid in sources:
            rp = RICES / rid / "preview.png"
            if rp.is_file() and is_valid_image(rp) and rp.stat().st_size < 2_000_000:
                preview_src = rp
                break

        if not written:
            print(f"WARN: no wallpapers for {theme_id}")
            continue

        default = written[0]
        # Prefer a namesake default if present
        for name in written:
            if theme_id.replace("-", "") in name.replace("-", "").lower() or theme_id in name:
                default = name
                break

        if preview_src is None:
            preview_src = wall_dir / default
        save_preview(preview_src, theme_dir / "preview")

        theme = {
            "schemaVersion": 1,
            "id": theme_id,
            "name": meta["name"],
            "description": meta["description"],
            "tags": meta["tags"],
            "darkMode": meta["darkMode"],
            "schemeType": meta["schemeType"],
            "gtkTheme": meta["gtkTheme"],
            "iconTheme": meta["iconTheme"],
            "defaultWallpaper": default,
            "wallpaperDir": theme_id,
        }
        (theme_dir / "theme.json").write_text(json.dumps(theme, indent=2) + "\n")
        print(f"OK {theme_id}: {len(written)} wallpapers, default={default}")

    print("Done.")


if __name__ == "__main__":
    main()
