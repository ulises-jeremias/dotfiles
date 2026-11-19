"""Static guarantees for the application-native music studio configuration.

Daily use needs no custom commands: PipeWire config provides permanent virtual
endpoints, the qpwgraph patchbay (autostarted, editable in its GUI) keeps the
links, REAPER opens its default "Music Studio" template, OBS has a "Music
Studio" scene collection and profile. These tests pin the safety properties:
nothing but REAPER can feed the Discord mic, no global latency change, no
loopback input, OBS never monitors audio back.
"""

from __future__ import annotations

import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HOME = ROOT / "home"
PW_CONF = HOME / "dot_config/pipewire/pipewire.conf.d/60-reaper-music-studio.conf"
JACK_CONF = HOME / "dot_config/pipewire/jack.conf.d/60-reaper-low-latency.conf"
PATCHBAY = HOME / "dot_config/qpwgraph/create_music-studio.qpwgraph"
AUTOSTART = HOME / "dot_config/autostart/qpwgraph-music-studio.desktop.tmpl"
OBS_SCENES = HOME / "dot_config/obs-studio/basic/scenes/create_Music_Studio.json"
OBS_PROFILE = HOME / "dot_config/obs-studio/basic/profiles/Music_Studio/create_basic.ini.tmpl"
REAPER_SETUP = HOME / ".chezmoiscripts/linux/run_after_configure-reaper-music-studio.sh.tmpl"


def _loopbacks() -> list[str]:
    text = PW_CONF.read_text()
    return text.split("name = libpipewire-module-loopback")[1:]


def test_pipewire_endpoints_are_permanent_and_never_change_defaults_or_latency() -> None:
    text = PW_CONF.read_text()
    assert "context.properties" not in text, "no global clock/quantum change"
    assert "default.clock" not in text
    loops = _loopbacks()
    assert len(loops) == 3
    names = re.findall(r'node.name\s*=\s*"([^"]+)"', text)
    assert {"reaper_lesson.input", "reaper_lesson_mic", "reaper_program.input", "reaper_program",
            "discord_call", "discord_call.output"} <= set(names)
    for loop in loops:
        # every endpoint an app can pick has zero priority: never the default device
        for cls in re.findall(r'media.class\s*=\s*"([^"]+)"', loop):
            assert cls in ("Audio/Source", "Audio/Sink")
        assert loop.count("priority.session = 0") >= 1
        # channel layout on both sides, or the source has no output ports
        assert loop.count("audio.position") == 2


def test_reaper_bus_inputs_never_auto_connect() -> None:
    # Only the patchbay links REAPER out 3-6 here: the lesson mic can never pick
    # up the default microphone, a sink monitor or Discord's own output.
    for loop in _loopbacks()[:2]:
        capture = loop.split("capture.props")[1].split("playback.props")[0]
        assert "node.autoconnect   = false" in capture or "node.autoconnect = false" in capture
        assert "media.class" not in capture, "bus input must not be a selectable sink"


def test_reaper_latency_is_per_application() -> None:
    text = JACK_CONF.read_text()
    assert 'application.process.binary = "reaper"' in text
    assert "node.latency = 256/48000" in text
    assert "context.properties" not in text


def _links() -> list[tuple[str, str, str, str]]:
    root = ET.parse(PATCHBAY).getroot()
    out = []
    for item in root.iter("item"):
        o, i = item.find("output"), item.find("input")
        out.append((o.get("node"), o.get("port"), i.get("node"), i.get("port")))
    return out


def test_patchbay_routes_exactly_the_studio_graph() -> None:
    links = _links()
    assert len(links) == 8
    into_reaper = {(p, ip) for n, p, inode, ip in links if inode == "REAPER"}
    assert into_reaper == {("Scarlett 2i2 4th Gen:capture_AUX0", "REAPER:in1"),
                           ("Scarlett 2i2 4th Gen:capture_AUX1", "REAPER:in2")}
    assert not any("AUX2" in p or "AUX3" in p for _, p, _, _ in links), "hardware loopback never used"
    lesson = {(p, ip) for n, p, inode, ip in links if inode == "REAPER Lesson Bus input"}
    assert lesson == {("REAPER:out3", "REAPER Lesson Bus input:input_FL"),
                      ("REAPER:out4", "REAPER Lesson Bus input:input_FR")}
    program = {p for n, p, inode, _ in links if inode == "REAPER Program input"}
    assert program == {"REAPER:out5", "REAPER:out6"}
    for n, p, inode, ip in links:
        assert "Discord" not in n, "nothing from Discord may be linked into REAPER or its buses"


def test_patchbay_is_gui_owned_and_autostarted() -> None:
    assert PATCHBAY.name.startswith("create_"), "chezmoi must not overwrite edits saved in qpwgraph"
    text = AUTOSTART.read_text()
    assert "--activated" in text and "--minimized" in text
    assert ".config/qpwgraph/music-studio.qpwgraph" in text


def test_obs_collection_scenes_and_audio() -> None:
    assert OBS_SCENES.name.startswith("create_") and OBS_PROFILE.name.startswith("create_")
    data = json.loads(OBS_SCENES.read_text())
    assert data["name"] == "Music Studio"
    assert [s["name"] for s in data["scene_order"]] == ["Guitar Lesson", "Guitar Performance", "Music Tutorial"]
    reaper_src, discord_src = data["AuxAudioDevice1"], data["DesktopAudioDevice1"]
    assert reaper_src["settings"]["device_id"] == "reaper_program" and reaper_src["mixers"] == 1 | 2
    assert discord_src["settings"]["device_id"] == "discord_call.monitor" and discord_src["mixers"] == 1 | 4
    every = [reaper_src, discord_src, *data["sources"]]
    assert all(s["monitoring_type"] == 0 for s in every), "OBS must never monitor audio back"
    assert not any(s["settings"].get("device_id") == "default" for s in every), "no default mic/desktop capture"
    names = {s["name"] for s in data["sources"]}
    for s in data["sources"]:
        for it in s["settings"].get("items", []):
            assert it["name"] in names, it["name"]


def test_obs_profile_records_three_tracks() -> None:
    text = OBS_PROFILE.read_text()
    assert re.search(r"(?m)^RecTracks=7$", text)
    assert "SampleRate=48000" in text


def test_reaper_preferences_setup_is_install_time_only() -> None:
    text = REAPER_SETUP.read_text()
    for key in ("linux_audio_nch_in", "linux_audio_nch_out", "jack_options", "newprojtmpl", "loadlastproj"):
        assert key in text
    assert "linux_audio_nch_out=6" in text
    assert "pgrep -x reaper" in text, "never edit reaper.ini under a running REAPER"
    assert "reaper.ini.pre-music-studio" in text, "rollback copy"
    assert "sudo" not in text and "systemctl" not in text


def test_patchbay_can_start_minimized() -> None:
    # measured: without its tray icon, `qpwgraph --minimized` exits at once
    text = REAPER_SETUP.read_text()
    for key in ("SystemTray=true", "StartMinimized=true", "SystemTrayQueryClose=false"):
        assert key in text
    assert "pgrep -x qpwgraph" in text, "qpwgraph rewrites its config on exit: edit only while it is not running"


def test_templates_record_48k_24bit_wav() -> None:
    import base64
    for name in ("Music Studio.RPP.tmpl", "Modern Rock & Metal - Vocal Studio.RPP.tmpl"):
        text = (HOME / "dot_config/REAPER/ProjectTemplates" / name).read_text()
        cfg = re.search(r"<RECORD_CFG\n\s+(\S+)", text).group(1)
        raw = base64.b64decode(cfg)
        assert raw[:4] == b"evaw" and raw[4] == 24, f"{name}: recording must be 24-bit WAV"
        assert re.search(r"^  SAMPLERATE 48000 1 ", text, flags=re.M), f"{name}: 48 kHz"


# --- behaviour of the install script, through `chezmoi apply` in a temp destination

def _chezmoi() -> str:
    import shutil
    from pathlib import Path as _P
    return shutil.which("chezmoi") or str(_P.home() / ".local/bin/chezmoi")


def _run_setup(dest: Path, base: Path, running: bool) -> str:
    import os
    import shutil
    import subprocess
    source = base / "source"
    if not source.exists():
        (source / ".chezmoiscripts/linux").mkdir(parents=True)
        shutil.copy(REAPER_SETUP, source / ".chezmoiscripts/linux" / REAPER_SETUP.name)
        (base / "chezmoi.toml").write_text("[data]\n", encoding="utf-8")
    stub = base / ("stub-running" if running else "stub-idle")
    stub.mkdir(exist_ok=True)
    (stub / "pgrep").write_text("#!/bin/sh\nexit %d\n" % (0 if running else 1), encoding="utf-8")
    (stub / "pgrep").chmod(0o755)
    env = dict(os.environ, HOME=str(dest), PATH=f"{stub}:{os.environ['PATH']}")
    out = subprocess.run([_chezmoi(), "apply", "--source", str(source), "--destination", str(dest),
                          "--config", str(base / "chezmoi.toml"), "--force"],
                         capture_output=True, text=True, check=True, env=env)
    return out.stdout + out.stderr


def _seed(dest: Path) -> None:
    (dest / ".config/REAPER/ProjectTemplates").mkdir(parents=True)
    (dest / ".config/REAPER/ProjectTemplates/Music Studio.RPP").write_text("<REAPER_PROJECT\n>\n")
    (dest / ".config/REAPER/reaper.ini").write_text(
        "[.swell]\nui_scale=1.0\n\n[reaper]\njack_options=8\nwnd_w=1105\n\n[verchk]\nlastt=1\n")
    (dest / ".config/rncbc.org").mkdir(parents=True)
    (dest / ".config/rncbc.org/qpwgraph.conf").write_text("[GraphNodePos]\nREAPER=@Variant(x)\n")


def test_setup_merges_preferences_once_and_keeps_everything_else() -> None:
    import tempfile
    with tempfile.TemporaryDirectory(prefix="music-studio-setup-") as tmp:
        base = Path(tmp)
        dest = base / "home"
        _seed(dest)
        _run_setup(dest, base, running=False)
        ini = (dest / ".config/REAPER/reaper.ini").read_text()
        assert "[.swell]\nui_scale=1.0" in ini and "[verchk]\nlastt=1" in ini, "other sections kept"
        assert "wnd_w=1105" in ini
        for line in ("linux_audio_nch_in=2", "linux_audio_nch_out=6", "loadlastproj=0",
                     f"newprojtmpl={dest}/.config/REAPER/ProjectTemplates/Music Studio.RPP"):
            assert line in ini.splitlines(), line
        assert "jack_options=10" in ini.splitlines(), "existing JACK option bits are kept (8 | 2)"
        assert (dest / ".local/state/reaper-backups/reaper.ini.pre-music-studio").read_text().startswith("[.swell]")
        qpw = (dest / ".config/rncbc.org/qpwgraph.conf").read_text()
        assert "REAPER=@Variant(x)" in qpw and "SystemTray=true" in qpw and "StartMinimized=true" in qpw

        # The user changes the default template in REAPER: a later apply keeps it.
        custom = ini.replace("loadlastproj=0", "loadlastproj=1")
        (dest / ".config/REAPER/reaper.ini").write_text(custom)
        _run_setup(dest, base, running=False)
        assert (dest / ".config/REAPER/reaper.ini").read_text() == custom, "applied once: GUI changes survive"
        assert not list((dest / ".config/REAPER").glob("*.tmp")), "no temp file left behind"


def test_setup_waits_while_the_apps_are_running() -> None:
    import tempfile
    with tempfile.TemporaryDirectory(prefix="music-studio-setup-") as tmp:
        base = Path(tmp)
        dest = base / "home"
        _seed(dest)
        before = (dest / ".config/REAPER/reaper.ini").read_text()
        out = _run_setup(dest, base, running=True)
        assert (dest / ".config/REAPER/reaper.ini").read_text() == before
        assert "SystemTray" not in (dest / ".config/rncbc.org/qpwgraph.conf").read_text()
        assert "close REAPER" in out
        assert not (dest / ".local/state/reaper-studio/reaper-prefs-v1-done").exists(), "stays pending"
        _run_setup(dest, base, running=False)
        assert (dest / ".local/state/reaper-studio/reaper-prefs-v1-done").exists()


def test_setup_on_a_fresh_install_creates_reaper_ini() -> None:
    import tempfile
    with tempfile.TemporaryDirectory(prefix="music-studio-setup-") as tmp:
        base = Path(tmp)
        dest = base / "home"
        (dest / ".config/REAPER/ProjectTemplates").mkdir(parents=True)
        (dest / ".config/REAPER/ProjectTemplates/Music Studio.RPP").write_text("<REAPER_PROJECT\n>\n")
        _run_setup(dest, base, running=False)
        ini = (dest / ".config/REAPER/reaper.ini").read_text().splitlines()
        assert "[reaper]" in ini and "linux_audio_nch_out=6" in ini and "jack_options=2" in ini
        assert not (dest / ".local/state/reaper-backups/reaper.ini.pre-music-studio").exists()
