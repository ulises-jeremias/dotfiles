#!/usr/bin/env python3
"""One-shot removal of the retired Guitarix bank and legacy REAPER guitar chains.

REAPER replaced Guitarix (docs/REAPER-Vocal-Studio.md). The files this repo
used to manage are removed exactly once, only after the REAPER replacement is
deployed, without touching Guitarix's own state or files the user creates
later. Exercises the real script through `chezmoi apply` in a temporary
destination.
"""
from __future__ import annotations

import os
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "home/.chezmoiscripts/linux/run_after_remove-retired-guitarix-config.sh.tmpl"
REMOVE = ROOT / "home/.chezmoiremove"
TEMPLATE = ".config/REAPER/ProjectTemplates/Modern Rock & Metal - Vocal Studio.RPP"
RETIRED = (
    ".config/guitarix/banks/silentz0r.gx",
    ".config/REAPER/FXChains/Vocal Studio/Hard Stuff.RfxChain",
    ".config/REAPER/FXChains/Vocal Studio/Machine Head.RfxChain",
    ".config/REAPER/TrackTemplates/Vocal Studio/Electric Guitar - Hard Stuff.RTrackTemplate",
    ".config/REAPER/TrackTemplates/Vocal Studio/Electric Guitar - Machine Head.RTrackTemplate",
)
KEPT = (".config/guitarix/gx_head_rc", ".config/guitarix/banks/scratchpad.gx",
        ".config/REAPER/FXChains/Vocal Studio/Lead Clean.RfxChain")


def chezmoi() -> str:
    return shutil.which("chezmoi") or str(Path.home() / ".local/bin/chezmoi")


def test_sources_are_gone_and_removal_is_not_persistent() -> None:
    assert not (ROOT / "home/dot_config/guitarix").exists()
    for rel in RETIRED[1:]:
        src = ROOT / "home/dot_config" / rel.removeprefix(".config/")
        assert not src.exists(), src
    assert SCRIPT.name.startswith("run_after_"), "must re-run until the replacement exists"
    text = SCRIPT.read_text(encoding="utf-8")
    assert ".chezmoi.destDir" in text
    assert "guitarix-config-migration-done" in text
    assert "[ ! -L " in text
    assert "pacman" not in text and "sudo" not in text, "Guitarix stays installed"
    entries = [line.strip() for line in REMOVE.read_text(encoding="utf-8").splitlines()
               if line.strip() and not line.strip().startswith("#")]
    assert not any("guitarix" in e.lower() or "Hard Stuff" in e for e in entries), \
        "a persistent .chezmoiremove entry would delete files the user recreates"


def seed(dest: Path, with_template: bool) -> None:
    for rel in RETIRED + KEPT:
        path = dest / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("old\n", encoding="utf-8")
    if with_template:
        (dest / TEMPLATE).parent.mkdir(parents=True, exist_ok=True)
        (dest / TEMPLATE).write_text("<REAPER_PROJECT\n>\n", encoding="utf-8")


def apply(source: Path, dest: Path, config: Path) -> None:
    env = dict(os.environ, HOME=str(dest), XDG_CONFIG_HOME=str(dest / ".config"))
    subprocess.run([chezmoi(), "apply", "--source", str(source), "--destination", str(dest),
                    "--config", str(config), "--force"],
                   capture_output=True, text=True, check=True, env=env)


def test_apply_behaviour() -> None:
    with tempfile.TemporaryDirectory(prefix="guitarix-migration-") as temp:
        base = Path(temp)
        source = base / "source"
        (source / ".chezmoiscripts/linux").mkdir(parents=True)
        shutil.copy(SCRIPT, source / ".chezmoiscripts/linux" / SCRIPT.name)
        config = base / "chezmoi.toml"
        config.write_text("[data]\n", encoding="utf-8")
        marker = ".local/state/reaper-studio/guitarix-config-migration-done"

        # Replacement not deployed yet: pending, nothing removed.
        dest = base / "home"
        seed(dest, with_template=False)
        apply(source, dest, config)
        assert all((dest / rel).exists() for rel in RETIRED)
        assert not (dest / marker).exists()

        # Replacement present: retired files go, everything else stays.
        (dest / TEMPLATE).parent.mkdir(parents=True, exist_ok=True)
        (dest / TEMPLATE).write_text("<REAPER_PROJECT\n>\n", encoding="utf-8")
        apply(source, dest, config)
        for rel in RETIRED:
            assert not (dest / rel).exists(), rel
        for rel in KEPT:
            assert (dest / rel).read_text(encoding="utf-8") == "old\n", rel
        assert (dest / marker).exists()

        # A bank the user saves again afterwards is theirs: it survives.
        recreated = dest / RETIRED[0]
        recreated.write_text("mine\n", encoding="utf-8")
        apply(source, dest, config)
        assert recreated.read_text(encoding="utf-8") == "mine\n"

        # Symlinked banks directory: nothing behind it is deleted, stays pending.
        dest = base / "home-symlink"
        seed(dest, with_template=True)
        elsewhere = base / "elsewhere"
        shutil.move(str(dest / ".config/guitarix/banks"), elsewhere)
        (dest / ".config/guitarix/banks").symlink_to(elsewhere, target_is_directory=True)
        apply(source, dest, config)
        assert (elsewhere / "silentz0r.gx").exists()
        assert not (dest / marker).exists()


if __name__ == "__main__":
    test_sources_are_gone_and_removal_is_not_persistent()
    test_apply_behaviour()
    print("guitarix config migration OK")
