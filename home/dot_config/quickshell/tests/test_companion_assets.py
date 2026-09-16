"""Companion production assets: manifest contract, frame validation, drift.

Stdlib only (struct/zlib PNG decode): runs in CI without Pillow.
Deterministic re-derivation gates (--check) run when Pillow is present.
"""
from __future__ import annotations

import json
import struct
import subprocess
import sys
import zlib
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parent.parent
COMPANION = ROOT / "assets" / "companion"
FRAMES = COMPANION / "frames"
MANIFEST = COMPANION / "manifest.json"
PREVIEW = COMPANION / "preview"

SKINS = ("default", "argentina", "blue-gold", "red", "gaucho")
ANIMATIONS = ("idle", "walk", "fly", "greet")
EXPECTED_ANIM = {
    "idle": {"nframes": 1, "anchor": "feet"},
    "walk": {"nframes": 2, "anchor": "feet"},
    "fly": {"nframes": 1, "anchor": "center"},
    "greet": {"nframes": 1, "anchor": "feet"},
}


def read_png(path: Path):
    """Return (width, height, alpha_bytes) for 8-bit RGBA PNGs."""
    data = path.read_bytes()
    assert data[:8] == b"\x89PNG\r\n\x1a\n", f"{path} not a PNG"
    pos, w, h, ctype = 8, None, None, None
    raw = b""
    while pos < len(data):
        (length,) = struct.unpack(">I", data[pos:pos + 4])
        ctype_raw = data[pos + 4:pos + 8]
        body = data[pos + 8:pos + 8 + length]
        if ctype_raw == b"IHDR":
            w, h, depth, ctype, _, _, _ = struct.unpack(">IIBBBBB", body)
            assert depth == 8, f"{path} bit depth {depth}"
            assert ctype == 6, f"{path} color type {ctype} (need RGBA)"
        elif ctype_raw == b"IDAT":
            raw += body
        pos += 12 + length
    assert w is not None
    px = zlib.decompress(raw)
    stride = w * 4
    alpha = bytearray()
    prev = bytearray(stride)
    p = 0
    for _ in range(h):
        f = px[p]
        p += 1
        line = bytearray(px[p:p + stride])
        p += stride
        if f == 1:
            for i in range(4, stride):
                line[i] = (line[i] + line[i - 4]) & 0xFF
        elif f == 2:
            for i in range(stride):
                line[i] = (line[i] + prev[i]) & 0xFF
        elif f == 3:
            for i in range(stride):
                a = line[i - 4] if i >= 4 else 0
                line[i] = (line[i] + ((a + prev[i]) >> 1)) & 0xFF
        elif f == 4:
            for i in range(stride):
                a = line[i - 4] if i >= 4 else 0
                b = prev[i]
                c = prev[i - 4] if i >= 4 else 0
                q = a + b - c
                pa, pb, pc = abs(q - a), abs(q - b), abs(q - c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[i] = (line[i] + pr) & 0xFF
        elif f != 0:
            raise AssertionError(f"{path} unknown filter {f}")
        alpha.extend(line[3::4])
        prev = line
    return w, h, bytes(alpha)


@pytest.fixture(scope="module")
def manifest():
    return json.loads(MANIFEST.read_text())


def test_manifest_version_and_shape(manifest):
    assert manifest["manifestVersion"] == 1
    assert manifest["canvas"] == {"width": 512, "height": 512}
    assert manifest["baseline"] == {"feetY": 472, "flyCenter": [256, 256]}
    assert sorted(manifest["skins"]) == sorted(SKINS)
    for skin in SKINS:
        entry = manifest["skins"][skin]
        assert entry["fallbackChain"][-1] == "default"
        assert sorted(entry["animations"]) == sorted(ANIMATIONS)
        for anim, want in EXPECTED_ANIM.items():
            a = entry["animations"][anim]
            assert a["id"] == anim
            assert len(a["frames"]) == want["nframes"]
            assert a["anchor"] == want["anchor"]
            assert isinstance(a["frameMs"], int) and a["frameMs"] > 0
            assert isinstance(a["loop"], bool)
            assert a["next"] in ANIMATIONS
            for frame in a["frames"]:
                assert frame["file"].startswith("frames/")
                assert len(frame["size"]) == 2
                assert len(frame["offset"]) == 2
                assert len(frame["anchorPx"]) == 2


def test_partial_skins_fall_back_to_default_fly(manifest):
    for skin in SKINS:
        if skin == "default":
            fly = manifest["skins"][skin]["animations"]["fly"]["frames"][0]
            assert fly["file"] == "frames/default-fly.png"
        else:
            chain = manifest["skins"][skin]["fallbackChain"]
            assert chain == [skin, "default"]
            fly = manifest["skins"][skin]["animations"]["fly"]["frames"][0]
            assert fly["file"] == "frames/default-fly.png"
    assert manifest["assistantStates"] == {
        "resting": "idle",
        "listening": "greet",
        "thinking": "walk",
        "speaking": "fly",
    }


def test_frames_exist_real_transparency_no_checkerboard():
    files = sorted(FRAMES.glob("*.png"))
    assert len(files) == 11, f"expected 11 frames, got {len(files)}"
    for path in files:
        w, h, alpha = read_png(path)
        assert (w, h) == (512, 512), f"{path.name} canvas {(w, h)}"
        n = len(alpha)
        lo, hi = min(alpha), max(alpha)
        assert lo == 0, f"{path.name} has no transparent pixel (min {lo})"
        assert hi >= 200, f"{path.name} max alpha {hi}"
        opaque = sum(1 for v in alpha if v == 255) / n
        clear = sum(1 for v in alpha if v == 0) / n
        assert opaque < 0.05, f"{path.name} {opaque:.2%} fully opaque"
        assert clear > 0.05, f"{path.name} only {clear:.2%} transparent"


def test_canvas_baseline_drift():
    """Feet-anchored frames share one baseline; fly shares one center."""
    manifest = json.loads(MANIFEST.read_text())
    seen = set()
    for skin, entry in manifest["skins"].items():
        for anim, a in entry["animations"].items():
            for frame in a["frames"]:
                key = frame["file"]
                ox, oy = frame["offset"]
                fw, fh = frame["size"]
                ax, ay = frame["anchorPx"]
                if a["anchor"] == "feet":
                    assert oy + fh == 472, f"{key} feet {oy + fh}"
                    assert ax == 256 and ay == 472, f"{key} anchor {ax, ay}"
                else:
                    assert [ox + fw / 2, oy + fh / 2] == pytest.approx(
                        [256, 256], abs=1.0), f"{key} center drift"
                seen.add((skin, key))
    # every skin x animation resolves to a real committed file
    for _, key in seen:
        assert (COMPANION / key).is_file(), f"missing {key}"


def test_no_personal_paths_or_markers():
    text = MANIFEST.read_text()
    assert "/home/" not in text and "ulises" not in text.lower()
    assert "{{" not in text
    qml = (ROOT / "modules" / "companion" / "Companion.qml").read_text()
    assert "/home/" not in qml and "{{" not in qml


def test_contact_sheets_committed():
    for name in ("preview-default-animations.png", "preview-skins.png",
                 "preview-assistant-states.png"):
        path = PREVIEW / name
        assert path.is_file(), f"missing sheet {name}"
        w, h, _ = read_png(path)
        assert w > 0 and h > 0


def test_qml_resolver_present():
    qml = ROOT / "modules" / "companion" / "Companion.qml"
    assert qml.is_file()
    text = qml.read_text()
    for token in ("resolve(", "frameSource(", "stateSource(", "fallbackChain",
                  "manifest.json", "FileView"):
        assert token in text, f"Companion.qml missing {token}"


def _needs_pil():
    try:
        import PIL  # noqa: F401
    except ImportError:
        pytest.skip("Pillow not installed")


def test_derive_check():
    _needs_pil()
    proc = subprocess.run([sys.executable, "scripts/derive-companion-assets.py",
                           "--check"], cwd=ROOT, capture_output=True, text=True,
                          timeout=300)
    assert proc.returncode == 0, proc.stderr


def test_preview_check():
    _needs_pil()
    proc = subprocess.run(["scripts/preview-companion-assets", "--check"],
                          cwd=ROOT, capture_output=True, text=True, timeout=300)
    assert proc.returncode == 0, proc.stderr
