#!/usr/bin/env python3
"""Guarded .chezmoiremove cleanup for native HorneroOS.

Static contracts plus a behavioural test: a miniature chezmoi source
carrying the real `.chezmoiremove.tmpl` is applied to a temporary HOME.
Retired Kitty targets (sources deleted in #347, now owned by
hornero-config) must be removed only when `horneroNative` is true;
personal and unrelated files must survive; a second apply is a no-op.
"""
from __future__ import annotations

import os
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REMOVE_TMPL = ROOT / "home/.chezmoiremove.tmpl"

KITTY_TARGETS = (
    ".config/kitty/kitty.conf",
    ".config/kitty/hornero-dark.conf",
    ".config/kitty/hornero-light.conf",
    ".config/kitty/pampa.conf",
)
GLOBAL_TARGETS = (
    ".config/hypr/hyprland.conf",
    ".config/hypr/scripts/gaps-interactive.sh",
    ".local/bin/hyprland-runtime",
)


def chezmoi() -> str:
    return shutil.which("chezmoi") or str(Path.home() / ".local/bin/chezmoi")


def render(config: Path) -> str:
    result = subprocess.run(
        [chezmoi(), "execute-template", "--config", str(config),
         "--file", str(REMOVE_TMPL)],
        capture_output=True, text=True, check=True,
    )
    return result.stdout


def write_config(path: Path, native: bool) -> Path:
    path.write_text(
        "[data]\n"
        f"    horneroNative = {str(native).lower()}\n",
        encoding="utf-8",
    )
    return path


def test_static_contracts() -> None:
    assert REMOVE_TMPL.exists(), ".chezmoiremove.tmpl missing"
    assert not (ROOT / "home/.chezmoiremove").exists(), \
        "plain .chezmoiremove must not coexist with the template"
    text = REMOVE_TMPL.read_text(encoding="utf-8")
    for entry in GLOBAL_TARGETS:
        assert entry in text, entry
    guard = '{{ if get . "horneroNative" }}'
    assert guard in text, "native guard missing"
    guarded = text.split(guard, 1)[1]
    for entry in KITTY_TARGETS:
        assert entry in guarded, f"{entry} must be inside the native guard"
        assert entry not in text.split(guard, 1)[0], \
            f"{entry} must not be removed on legacy hosts"


def test_render_respects_guard() -> None:
    with tempfile.TemporaryDirectory(prefix="chezmoiremove-render-") as temp:
        base = Path(temp)
        native = render(write_config(base / "native.toml", True))
        legacy = render(write_config(base / "legacy.toml", False))
        for entry in KITTY_TARGETS:
            assert entry in native, entry
            assert entry not in legacy, entry
        for entry in GLOBAL_TARGETS:
            assert entry in native and entry in legacy, entry


def apply_once(source: Path, dest: Path, config: Path) -> None:
    env = dict(os.environ, HOME=str(dest))
    subprocess.run(
        [chezmoi(), "apply", "--source", str(source),
         "--destination", str(dest), "--config", str(config), "--force"],
        capture_output=True, text=True, check=True, env=env,
    )


def test_apply_removes_only_guarded_targets() -> None:
    with tempfile.TemporaryDirectory(prefix="chezmoiremove-apply-") as temp:
        base = Path(temp)
        source = base / "source"
        source.mkdir()
        shutil.copy(REMOVE_TMPL, source / ".chezmoiremove.tmpl")

        for native, kitty_survives in ((True, False), (False, True)):
            dest = base / ("home-native" if native else "home-legacy")
            for rel in KITTY_TARGETS + GLOBAL_TARGETS:
                target = dest / rel
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text("stale override\n", encoding="utf-8")
            personal = dest / ".config/kitty/personal-notes.txt"
            personal.write_text("mine\n", encoding="utf-8")
            config = write_config(base / f"cfg-{native}.toml", native)

            apply_once(source, dest, config)
            for rel in KITTY_TARGETS:
                assert (dest / rel).exists() is kitty_survives, rel
            for rel in GLOBAL_TARGETS:
                assert not (dest / rel).exists(), rel
            assert personal.read_text(encoding="utf-8") == "mine\n"

            # Idempotence: a second apply changes nothing further.
            apply_once(source, dest, config)
            assert personal.read_text(encoding="utf-8") == "mine\n"


def main() -> None:
    test_static_contracts()
    test_render_respects_guard()
    test_apply_removes_only_guarded_targets()
    print("chezmoiremove native cleanup OK")


if __name__ == "__main__":
    main()
