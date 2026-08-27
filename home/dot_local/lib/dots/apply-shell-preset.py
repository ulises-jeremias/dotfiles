"""Validate and deterministically merge a Hornero shell layout preset."""

from __future__ import annotations

import fcntl
import json
import math
import os
import stat
import sys
import tempfile
from copy import deepcopy
from pathlib import Path
from typing import Any

VALID_POSITIONS = {"left", "right", "top", "bottom"}
VALID_STYLES = {"attached", "floating", "dock"}

OWNED_DEFAULTS: dict[str, Any] = {
    "bar": {
        "position": "left",
        "style": "attached",
        "floatingMargin": 8,
        "persistent": True,
        "showOnHover": True,
        "sizes": {"innerWidth": 40},
        "status": {
            "showAudio": False,
            "showMicrophone": False,
            "showKbLayout": False,
            "showNetwork": True,
            "showWifi": True,
            "showBluetooth": True,
            "showBattery": True,
            "showLockStatus": True,
        },
        "scrollActions": {
            "workspaces": True,
            "volume": True,
            "brightness": True,
        },
    },
    "border": {"frameEnabled": True},
    "appearance": {
        "rounding": {"scale": 1.0},
        "padding": {"scale": 1.0},
        "spacing": {"scale": 1.0},
        "transparency": {"enabled": False, "base": 0.85, "layers": 0.4},
    },
    "notifs": {"defaultExpireTimeout": 5000},
    "osd": {"hideDelay": 2000},
}


def deep_merge(base: dict[str, Any], override: dict[str, Any]) -> dict[str, Any]:
    result = deepcopy(base)
    for key, value in override.items():
        if key.startswith("_"):
            continue
        if isinstance(result.get(key), dict) and isinstance(value, dict):
            result[key] = deep_merge(result[key], value)
        else:
            result[key] = deepcopy(value)
    return result


def is_number(value: Any) -> bool:
    return type(value) in (int, float) and math.isfinite(value)


def normalize_preset(preset: dict[str, Any], path: Path) -> dict[str, Any]:
    if not preset.get("_name") or not isinstance(preset.get("bar"), dict):
        raise ValueError(f"{path}: missing _name or bar object")
    normalized = deep_merge(OWNED_DEFAULTS, preset)
    normalized["_name"] = preset["_name"]
    return normalized


def validate_preset(preset: dict[str, Any], path: Path) -> dict[str, Any]:
    normalized = normalize_preset(preset, path)
    bar = normalized["bar"]
    border = normalized["border"]
    appearance = normalized["appearance"]
    if bar.get("position") not in VALID_POSITIONS:
        raise ValueError(f"{path}: invalid bar.position")
    if bar.get("style") not in VALID_STYLES:
        raise ValueError(f"{path}: invalid bar.style")
    if (
        type(bar.get("floatingMargin")) is not int
        or not 0 <= bar["floatingMargin"] <= 256
    ):
        raise ValueError(f"{path}: bar.floatingMargin must be an integer from 0 to 256")
    if type(bar.get("showOnHover")) is not bool:
        raise ValueError(f"{path}: bar.showOnHover must be a boolean")
    if not isinstance(bar.get("entries"), list) or not bar["entries"]:
        raise ValueError(f"{path}: bar.entries must be a non-empty list")
    for entry in bar["entries"]:
        if (
            not isinstance(entry, dict)
            or not isinstance(entry.get("id"), str)
            or type(entry.get("enabled")) is not bool
        ):
            raise ValueError(
                f"{path}: each bar entry requires a string id and boolean enabled"
            )
    inner_width = bar.get("sizes", {}).get("innerWidth")
    if type(inner_width) is not int or not 16 <= inner_width <= 256:
        raise ValueError(
            f"{path}: bar.sizes.innerWidth must be an integer from 16 to 256"
        )
    if not isinstance(border, dict) or type(border.get("frameEnabled")) is not bool:
        raise ValueError(f"{path}: border.frameEnabled must be a boolean")
    for name in ("rounding", "padding", "spacing"):
        scale = appearance.get(name, {}).get("scale")
        if not is_number(scale) or not 0.25 <= scale <= 4:
            raise ValueError(
                f"{path}: appearance.{name}.scale must be finite and between 0.25 and 4"
            )
    transparency = appearance.get("transparency", {})
    if type(transparency.get("enabled")) is not bool:
        raise ValueError(f"{path}: appearance.transparency.enabled must be a boolean")
    for name in ("base", "layers"):
        value = transparency.get(name)
        if not is_number(value) or not 0 <= value <= 1:
            raise ValueError(
                f"{path}: appearance.transparency.{name} must be finite and between 0 and 1"
            )
    for section, field in (("notifs", "defaultExpireTimeout"), ("osd", "hideDelay")):
        value = normalized[section][field]
        if type(value) is not int or not 0 <= value <= 600_000:
            raise ValueError(
                f"{path}: {section}.{field} must be an integer from 0 to 600000"
            )
    return normalized


def apply_preset(
    config: dict[str, Any], preset: dict[str, Any], path: Path
) -> dict[str, Any]:
    normalized = validate_preset(preset, path)
    reset = deep_merge(config, OWNED_DEFAULTS)
    merged = deep_merge(reset, normalized)
    return {key: value for key, value in merged.items() if not key.startswith("_")}


def prepare_atomic_write(path: Path, content: str) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary_name = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    temporary = Path(temporary_name)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            handle.write(content)
            handle.flush()
            os.fsync(handle.fileno())
        mode = stat.S_IMODE(path.stat().st_mode) if path.exists() else 0o644
        temporary.chmod(mode)
        return temporary
    except BaseException:
        temporary.unlink(missing_ok=True)
        raise


def apply_preset_files(
    config_path: Path,
    preset_path: Path,
    marker_path: Path | None = None,
    preset_name: str | None = None,
) -> dict[str, Any]:
    lock_path = config_path.with_name(f".{config_path.name}.lock")
    lock_path.parent.mkdir(parents=True, exist_ok=True)
    with lock_path.open("a+", encoding="utf-8") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if config_path.exists():
            config = json.loads(config_path.read_text(encoding="utf-8"))
        else:
            config = {}
        preset = json.loads(preset_path.read_text(encoding="utf-8"))
        merged = apply_preset(config, preset, preset_path)
        content = f"{json.dumps(merged, indent=2, allow_nan=False)}\n"

        config_temp = prepare_atomic_write(config_path, content)
        marker_temp = None
        if marker_path is not None and preset_name is not None:
            marker_temp = prepare_atomic_write(marker_path, f"{preset_name}\n")
        try:
            os.replace(config_temp, config_path)
            if marker_temp is not None:
                os.replace(marker_temp, marker_path)
        finally:
            config_temp.unlink(missing_ok=True)
            if marker_temp is not None:
                marker_temp.unlink(missing_ok=True)
        return merged


def main() -> int:
    if len(sys.argv) not in (3, 5):
        print(
            "usage: apply-shell-preset.py CONFIG PRESET [MARKER NAME]", file=sys.stderr
        )
        return 2

    config_path = Path(sys.argv[1])
    preset_path = Path(sys.argv[2])
    marker_path = Path(sys.argv[3]) if len(sys.argv) == 5 else None
    preset_name = sys.argv[4] if len(sys.argv) == 5 else None
    apply_preset_files(config_path, preset_path, marker_path, preset_name)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
