"""Control-center pane contract: PaneRegistry entries must resolve to real
pane files, every registered pane must accept the shared Session, and no
pane may invoke a retired dots-* wrapper (all of them are retired now —
appearance included — every call goes through horneroctl)."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CC = ROOT / "modules" / "controlcenter"
REGISTRY = CC / "PaneRegistry.qml"

# Every dots-* wrapper the shell ever invoked, all superseded by horneroctl
# verbs (see docs/MIGRATION.md). None may appear in pane QML.
DEAD_WRAPPERS = [
    "dots-quickshell",
    "dots-launcher",
    "dots-power-menu",
    "dots-clipboard",
    "dots-snappy-switcher",
    "dots-hypr-layout",
    "dots-hyprland-plugins",
    "dots-battery-monitor",
    "dots-keyboard-help",
    "dots-keyboard-layout",
    "dots-lockscreen",
    "dots-screenshooter",
    "dots-sysupdate",
    "dots-theme-selector",
    "dots-gtk-theme",
    "dots-m3-colors",
    "dots-color-scheme",
    "dots-appearance",
    "dots-accent-override",
    "dots-night-mode",
    "dots-wallpaper-current",
    "dots-wallpaper-set",
    "dots-recorder",
    "dots-settings-gui",
    "dots-hyprlock-theme",
]


def _registry_entries():
    text = REGISTRY.read_text()
    return re.findall(
        r'readonly property string id:\s*"([^"]+)"\s*\n'
        r'\s*readonly property string label:\s*"([^"]+)"\s*\n'
        r'\s*readonly property string icon:\s*"([^"]+)"\s*\n'
        r'\s*readonly property string component:\s*"([^"]+)"',
        text,
    )


def test_registry_components_exist():
    entries = _registry_entries()
    assert entries, "no panes parsed from PaneRegistry.qml"
    for pid, _label, _icon, component in entries:
        assert (CC / component).is_file(), f"pane {pid}: missing {component}"


def test_registry_ids_unique_and_labels_sane():
    entries = _registry_entries()
    ids = [e[0] for e in entries]
    assert len(ids) == len(set(ids)), f"duplicate pane ids: {ids}"
    for _pid, label, _icon, _component in entries:
        assert re.fullmatch(r"[a-z]+", label), f"bad pane label: {label}"


def test_registered_panes_take_shared_session():
    for pid, _label, _icon, component in _registry_entries():
        text = (CC / component).read_text()
        assert ("required property Session session" in text
                or "required property CC.Session session" in text), (
            f"pane {pid}: must declare `required property [CC.]Session session`"
        )


def test_session_type_never_shadowed():
    # `import qs.modules.welcome` brings a second `Session` name (its
    # singleton) into scope. A pane that imports it must qualify the
    # session property (`CC.Session`); unqualified, the loader's session
    # value fails assignment and the pane renders blank (system pane).
    for _pid, _label, _icon, component in _registry_entries():
        text = (CC / component).read_text()
        if "import qs.modules.welcome" in text:
            assert "required property CC.Session session" in text, (
                f"pane {_pid}: imports qs.modules.welcome, so the session "
                "property must be qualified as `CC.Session`"
            )


def test_no_dead_wrappers_in_panes():
    hits = []
    for path in CC.rglob("*.qml"):
        text = path.read_text()
        for dead in DEAD_WRAPPERS:
            if dead in text:
                hits.append(f"{path.relative_to(ROOT)}: {dead}")
    assert not hits, f"retired wrappers invoked by panes:\n" + "\n".join(hits)
