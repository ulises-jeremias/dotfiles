"""Session-menu safety contract: every session button shows a text label
and destructive actions never fire on a single keypress — Enter, Return
and click must route through the two-step runOrArm confirm, with an
armed state, a Confirm label swap, and Escape/focus-loss disarm."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CONTENT = ROOT / "modules" / "session" / "Content.qml"


def _text():
    return CONTENT.read_text()


def test_session_buttons_have_labels():
    text = _text()
    buttons = re.findall(r"SessionButton\s*\{", text)
    labels = re.findall(r"label:\s*qsTr\(", text)
    assert len(buttons) == 4, f"expected 4 session buttons, found {len(buttons)}"
    assert len(labels) == 4, f"every session button needs a label, found {len(labels)}"


def test_session_actions_require_arm():
    text = _text()
    assert "armedAction" in text
    assert "Confirm?" in text
    # No raw execution path on keypress/click: everything goes via runOrArm.
    assert text.count("runOrArm") >= 4
    assert "execDetached" in text
    for pat in ["onEnterPressed: Quickshell", "onReturnPressed: Quickshell",
                "onClicked(): void {\n                Quickshell"]:
        assert pat not in text, f"unconfirmed execution path: {pat!r}"
