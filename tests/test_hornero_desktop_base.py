"""Verify HorneroOS desktop base seeding, systemd slices, recommended plugins, and studio audio assets."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DESKTOP_BASE = (
    ROOT / "home/.chezmoiscripts/linux/run_onchange_after_configure-hornero-desktop-base.sh.tmpl"
)
PLUGINS_SCRIPT = (
    ROOT / "home/.chezmoiscripts/linux/run_onchange_after_configure-hornero-plugins.sh.tmpl"
)
STUDIO_INSTALL = (
    ROOT / "home/.chezmoiscripts/linux/run_onchange_before_install-studio.sh.tmpl"
)
GUITAR_ASSETS_SCRIPT = (
    ROOT / "home/.chezmoiscripts/linux/run_onchange_after_install-reaper-guitar-assets.sh.tmpl"
)


def test_desktop_base_wires_seed_user_hypr_refresh_and_systemd_slices():
    script = DESKTOP_BASE.read_text()

    assert "/usr/share/hornero/seed-user.sh" in script
    assert "/usr/share/hornero/scripts/seed-user.sh" in script
    assert '--dest "${HOME}"' in script
    assert "horneroctl config refresh-hypr --yes" in script
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


def test_recommended_pluginkit3_extensions_are_installed_updated_and_enabled_via_horneroctl():
    script = PLUGINS_SCRIPT.read_text()

    assert "horneroctl plugin list --json" in script
    assert 'horneroctl plugin catalog install "${plugin}" --yes' in script
    assert 'horneroctl plugin catalog update "${plugin}" --yes' in script
    assert 'horneroctl plugin enable "${plugin}" --yes' in script
    for plugin in (
        "hornero-tailscale",
        "hornero-elsewhen",
        "hornero-containers",
        "hornero-ai-usage",
        "hornero-github-stats",
        "hornero-pomodoro",
        "hornero-clipboard",
        "hornero-weather",
        "hornero-uptime",
        "hornero-quick-notes",
        "hornero-studio-audio",
        "hornero-microphone",
        "hornero-metronome",
        "hornero-audio-deck",
        "hornero-volume",
        "hornero-bitin",
        "hornero-capi",
    ):
        assert plugin in script


def test_studio_install_and_reaper_guitar_assets_automation():
    studio = STUDIO_INSTALL.read_text()
    assert "pipewire-jack" in studio
    assert "qpwgraph" in studio
    assert "sudo pacman -S --noconfirm --needed reaper" in studio

    assets = GUITAR_ASSETS_SCRIPT.read_text()
    assert "reaper-guitar-assets" in assets
    assert '"${helper}" verify' in assets
    assert '"${helper}" install' in assets
    assert "sudo" not in assets
