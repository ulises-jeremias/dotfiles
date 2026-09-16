#!/usr/bin/env python3
"""Derive normalized Companion frames + manifest from vendored source plates.

Pipeline (deterministic, Pillow only):
  sources (assets/companion/sources/*.png, 1448x1086 RGBA plates, 3 poses
  each) -> vertical slice at hand-traced seams -> autocrop alpha bbox + pad
  -> scale to fit 448px -> place on a 512x512 canvas (feet baseline for
  grounded poses, optical center for fly) -> optimized RGBA PNG frames +
  versioned manifest.json.

Pose order on every plate is left-to-right: idle, fly, walk.

  idle: standing, wings folded, feet on ground  (anchor: feet)
  fly:  airborne, wings raised, feet tucked     (anchor: center)
  walk: standing, wing raised, beak open        (anchor: feet)

Skins ship idle + walk + greet locally; fly resolves through the explicit
fallbackChain to the default Hornero fly frame (partial-skin contract;
see docs/COMPANION.md).

Usage:
  scripts/derive-companion-assets.py            # write frames + manifest
  scripts/derive-companion-assets.py --check    # verify committed output
"""
from __future__ import annotations

import argparse
import hashlib
import json
import sys
import tempfile
from pathlib import Path

try:
    from PIL import Image
except ImportError:  # pragma: no cover
    print("derive-companion-assets: SKIP (Pillow not installed)", file=sys.stderr)
    sys.exit(3)

ROOT = Path(__file__).resolve().parent.parent
COMPANION = ROOT / "assets" / "companion"
SOURCES = COMPANION / "sources"
FRAMES = "frames"

CANVAS = 512
FIT = 448
PAD = 6
FEET_Y = 472  # grounded-pose feet baseline in canvas px
FLY_CENTER = (256, 256)
MANIFEST_VERSION = 1

# Hand-traced vertical seams (x of the alpha-minimum column between poses).
# Measured with alpha>8 column profiles; seam1 sits in a true zero gap,
# seam2 at the local minimum where wingtip/beak feathers touch.
SEAMS = {
    "hornero-default.png": (491, 985),
    "skin-argentina.png": (478, 1010),
    "skin-blue-gold.png": (488, 993),
    "skin-red.png": (492, 988),
    "skin-gaucho.png": (470, 1009),
}

# source plate -> (skin id, skin label)
SKINS = {
    "hornero-default.png": ("default", "Hornero"),
    "skin-argentina.png": ("argentina", "Argentina"),
    "skin-blue-gold.png": ("blue-gold", "Blue-Gold"),
    "skin-red.png": ("red", "Rojo"),
    "skin-gaucho.png": ("gaucho", "Gaucho"),
}

POSES = ("idle", "fly", "walk")  # left-to-right on every plate
GROUND_ANCHOR = {"idle", "walk"}

ANIMATIONS = {
    # animation id -> (frame pose order, frameMs, loop, next, anchor)
    "idle": (("idle",), 900, True, "idle", "feet"),
    "walk": (("walk", "idle"), 320, True, "idle", "feet"),
    "fly": (("fly",), 500, True, "idle", "center"),
    "greet": (("walk",), 650, False, "idle", "feet"),
}

# Assistant states resolve to default-skin animations (preview + QML demo).
ASSISTANT_STATES = {
    "resting": "idle",
    "listening": "greet",
    "thinking": "walk",
    "speaking": "fly",
}

# Skins that ship only grounded poses; fly falls back to default.
SKIN_POSES = {"default": ("idle", "fly", "walk")}
for _src, (_sid, _label) in SKINS.items():
    if _sid != "default":
        SKIN_POSES[_sid] = ("idle", "walk")


def slice_poses(plate: Image.Image, seams: tuple[int, int]) -> list[Image.Image]:
    s1, s2 = seams
    w = plate.width
    return [
        plate.crop((0, 0, s1 + 1, plate.height)),
        plate.crop((s1 + 1, 0, s2 + 1, plate.height)),
        plate.crop((s2 + 1, 0, w, plate.height)),
    ]


def autocrop(strip: Image.Image) -> Image.Image:
    alpha = strip.getchannel("A")
    bbox = alpha.getbbox()
    if bbox is None:  # pragma: no cover - every strip has content
        raise ValueError("empty pose strip")
    x0, y0, x1, y1 = bbox
    x0 = max(0, x0 - PAD)
    y0 = max(0, y0 - PAD)
    x1 = min(strip.width, x1 + PAD)
    y1 = min(strip.height, y1 + PAD)
    return strip.crop((x0, y0, x1, y1))


def normalize(content: Image.Image, anchor: str) -> tuple[Image.Image, dict]:
    scale = min(1.0, FIT / max(content.width, content.height))
    nw = max(1, round(content.width * scale))
    nh = max(1, round(content.height * scale))
    resized = content.resize((nw, nh), Image.LANCZOS)
    canvas = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    if anchor == "feet":
        ox = (CANVAS - nw) // 2
        oy = FEET_Y - nh
        anchor_px = [CANVAS // 2, FEET_Y]
    else:
        ox = FLY_CENTER[0] - nw // 2
        oy = FLY_CENTER[1] - nh // 2
        anchor_px = [FLY_CENTER[0], FLY_CENTER[1]]
    canvas.paste(resized, (ox, oy), resized)
    geometry = {"size": [nw, nh], "offset": [ox, oy], "anchorPx": anchor_px}
    return canvas, geometry


def derive(out_dir: Path) -> dict:
    frames_dir = out_dir / FRAMES
    frames_dir.mkdir(parents=True, exist_ok=True)
    manifest_skins: dict[str, dict] = {}
    geometries: dict[str, dict] = {}
    for src_name, (skin_id, label) in sorted(SKINS.items()):
        plate = Image.open(SOURCES / src_name).convert("RGBA")
        assert plate.size == (1448, 1086), f"{src_name}: {plate.size}"
        strips = slice_poses(plate, SEAMS[src_name])
        for pose, strip in zip(POSES, strips):
            if pose not in SKIN_POSES[skin_id]:
                continue  # partial skin: resolved via fallbackChain
            anchor = "feet" if pose in GROUND_ANCHOR else "center"
            frame, geometry = normalize(autocrop(strip), anchor)
            fname = f"{skin_id}-{pose}.png"
            frame.save(frames_dir / fname, optimize=True)
            geometries[f"{skin_id}/{pose}"] = {"file": f"{FRAMES}/{fname}", **geometry}
    for skin_id, label in sorted({v[0]: v[1] for v in SKINS.values()}.items()):
        chain = [skin_id] if skin_id == "default" else [skin_id, "default"]
        animations: dict[str, dict] = {}
        for anim_id, (poses, ms, loop, nxt, anchor) in ANIMATIONS.items():
            frames = []
            for pose in poses:
                owner = skin_id if pose in SKIN_POSES[skin_id] else "default"
                frames.append(geometries[f"{owner}/{pose}"])
            animations[anim_id] = {
                "id": anim_id,
                "frames": frames,
                "frameMs": ms,
                "loop": loop,
                "next": nxt,
                "anchor": anchor,
            }
        manifest_skins[skin_id] = {
            "label": label,
            "fallbackChain": chain,
            "animations": animations,
        }
    manifest = {
        "manifestVersion": MANIFEST_VERSION,
        "canvas": {"width": CANVAS, "height": CANVAS},
        "baseline": {"feetY": FEET_Y, "flyCenter": list(FLY_CENTER)},
        "skins": manifest_skins,
        "assistantStates": dict(ASSISTANT_STATES),
    }
    (out_dir / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    return manifest


def _sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def check() -> int:
    with tempfile.TemporaryDirectory() as tmp:
        fresh = Path(tmp)
        derive(fresh)
        problems = []
        for rel in ["manifest.json"] + sorted(
            str(p.relative_to(COMPANION)) for p in (COMPANION / FRAMES).glob("*.png")
        ):
            a, b = fresh / rel, COMPANION / rel
            if not b.exists():
                problems.append(f"missing committed file: {rel}")
            elif _sha(a) != _sha(b):
                problems.append(f"drift: {rel}")
        fresh_frames = sorted(str(p.relative_to(fresh)) for p in (fresh / FRAMES).glob("*.png"))
        committed_frames = sorted(
            str(p.relative_to(COMPANION)) for p in (COMPANION / FRAMES).glob("*.png")
        )
        if fresh_frames != committed_frames:
            problems.append(f"frame set changed: {fresh_frames} != {committed_frames}")
        if problems:
            print("derive-companion-assets --check: FAIL", file=sys.stderr)
            for p in problems:
                print(f"  {p}", file=sys.stderr)
            return 1
    print("derive-companion-assets --check: PASS")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    if args.check:
        return check()
    derive(COMPANION)
    print("derive-companion-assets: wrote frames + manifest.json")
    return 0


if __name__ == "__main__":
    sys.exit(main())
