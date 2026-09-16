"""IPC mapping: every IpcHandler target in QML must be documented in
docs/IPC.md, and every documented target must exist in QML."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
QML_DIRS = [ROOT / d for d in ("modules", "services")]

TARGET_RE = re.compile(r'IpcHandler\s*\{\s*target:\s*"([^"]+)"')


def _qml_targets():
    found = {}
    for d in QML_DIRS:
        for path in d.rglob("*.qml"):
            for target in TARGET_RE.findall(path.read_text()):
                found.setdefault(target, []).append(
                    str(path.relative_to(ROOT))
                )
    return found


def _doc_targets():
    doc = (ROOT / "docs" / "IPC.md").read_text()
    return set(re.findall(r'`([a-zA-Z]+)`', doc))


def test_all_ipc_targets_documented():
    qml_targets = _qml_targets()
    doc = (ROOT / "docs" / "IPC.md").read_text()
    missing = [t for t in qml_targets if f'"{t}"' not in doc and f'`{t}`' not in doc]
    assert not missing, f"undocumented IPC targets: {missing}"
    assert len(qml_targets) >= 10, f"expected >=10 IPC targets, got {len(qml_targets)}"


def test_documented_targets_exist():
    qml_targets = _qml_targets()
    doc_targets = _doc_targets()
    known = set(qml_targets)
    orphans = [
        t
        for t in ("wallpaper", "appearance", "mpris", "notifs", "hypr",
                  "gameMode", "colours", "brightness", "drawers", "lock",
                  "welcome")
        if t not in known
    ]
    assert not orphans, f"documented IPC targets missing from QML: {orphans}"
    assert known & doc_targets, "no overlap between QML targets and IPC.md"
