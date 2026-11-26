"""Verify HorneroOS desktop base seeding, systemd slices, and recommended plugins."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DESKTOP_BASE = (
    ROOT / "home/.chezmoiscripts/linux/run_onchange_after_configure-hornero-desktop-base.sh.tmpl"
)
PLUGINS_SCRIPT = (
    ROOT / "home/.chezmoiscripts/linux/run_onchange_after_configure-hornero-plugins.sh.tmpl"
)


def test_desktop_base_wires_seed_user_and_systemd_slices():
    script = DESKTOP_BASE.read_text()

    assert "/usr/share/hornero/scripts/seed-user.sh --dest" in script
    for unit in (
        "app-models.slice",
        "app-agents.slice",
        "ollama.service.d/10-hornero.conf",
        "llama-server@.service.d/10-hornero.conf",
    ):
        assert unit in script
    assert "systemctl --user daemon-reload" in script
    # Contract C: product slice files are fetched/owned upstream, never mirrored in dotfiles.
    assert not (ROOT / "home/dot_config/systemd/user/app-models.slice").exists()
    assert not (ROOT / "home/dot_config/systemd/user/app-agents.slice").exists()


def test_recommended_pluginkit3_extensions_are_installed_and_enabled_via_horneroctl():
    script = PLUGINS_SCRIPT.read_text()

    assert "horneroctl plugin list --json" in script
    assert 'horneroctl plugin catalog install "${plugin}" --yes' in script
    assert 'horneroctl plugin enable "${plugin}" --yes' in script
    for plugin in (
        "hornero-tailscale",
        "hornero-elsewhen",
        "hornero-containers",
        "hornero-ai-usage",
        "hornero-github-stats",
        "hornero-pomodoro",
        "hornero-clipboard",
    ):
        assert plugin in script
