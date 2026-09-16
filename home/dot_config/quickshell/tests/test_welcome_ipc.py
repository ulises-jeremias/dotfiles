"""Welcome IPC: `welcome` target handlers plus the `controlCenter open
[pane]` deep link with registry validation."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SHORTCUTS = ROOT / "modules" / "Shortcuts.qml"
WELCOME_QML = ROOT / "modules" / "welcome" / "Welcome.qml"
FACTORY = ROOT / "modules" / "controlcenter" / "WindowFactory.qml"
REGISTRY = ROOT / "modules" / "controlcenter" / "PaneRegistry.qml"

WELCOME_PAGES = ["start", "navigate", "shell", "workspaces",
                 "personalize", "tools", "system", "learn"]


def _handler_block(text, target):
    match = re.search(r"IpcHandler\s*\{\s*target:\s*\"" + re.escape(target) + r"\"(.*?)\n    \}",
                      text, re.DOTALL)
    assert match, f'IpcHandler target "{target}" missing'
    return match.group(1)


def test_welcome_ipc_target_handlers():
    block = _handler_block(SHORTCUTS.read_text(), "welcome")
    for fn in ("function open(", "function close(", "function status("):
        assert fn in block, f"welcome IPC missing {fn}"
    assert "Welcome.open" in block
    assert "Welcome.close" in block
    assert "JSON.stringify(Welcome.status())" in block


def test_welcome_controller_shape():
    text = WELCOME_QML.read_text()
    for fn in ("function open(", "function close(", "function toggle(",
               "function status(", "function pageValid("):
        assert fn in text, f"Welcome.qml missing {fn}"
    for page in WELCOME_PAGES:
        assert f'"{page}"' in text, f"Welcome.qml missing page {page}"
    assert len(WELCOME_PAGES) == 8
    # status() exposes open/page; unknown pages fall back, never throw.
    assert "open: " in text and "page: " in text
    assert "console.warn" in text


def test_controlcenter_open_accepts_pane():
    block = _handler_block(SHORTCUTS.read_text(), "controlCenter")
    assert "function open(pane" in block
    assert "PaneRegistry.getById" in block
    assert "WindowFactory.create" in block
    # Invalid pane = default window + warning, never a crash.
    assert "console.warn" in block
    assert "throw" not in block


def test_factory_applies_validated_pane():
    text = FACTORY.read_text()
    assert "property string pane" in text
    assert "PaneRegistry.getById" in text
    assert "cc.active = " in text


def test_registry_covers_documented_panes():
    text = REGISTRY.read_text()
    for pane in ("network", "system", "appearance", "audio"):
        assert f'id: "{pane}"' in text, f"registry missing pane {pane}"
    assert "function getById" in text
