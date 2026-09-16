"""Welcome static scans: hermetic guards for the foundation constraints.

- no `dots-*` runtime paths anywhere under modules/welcome/
- no `http` literals (no network at render; no openUrl use either)
- only `horneroctl welcome …` argv may reach a process spawner
- every user-visible literal goes through qsTr()
- only semantic Appearance tokens (no hardcoded hex colours)
- startup hook is present, single-shot, and spawns nothing itself
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
WELCOME = ROOT / "modules" / "welcome"
QML_FILES = sorted(WELCOME.rglob("*.qml"))
assert QML_FILES, "modules/welcome/ must contain QML"


def _read_all():
    return {p.relative_to(ROOT): p.read_text() for p in QML_FILES}


def test_no_dots_paths():
    hits = [str(rel) for rel, text in _read_all().items() if "dots-" in text]
    assert not hits, f"dots-* runtime paths in: {hits}"


def test_no_network_at_render():
    hits = [str(rel) for rel, text in _read_all().items() if "http" in text]
    assert not hits, f"network literals in: {hits}"


def test_only_horneroctl_spawns():
    # State/session singletons keep the single-writer rule: any process
    # argv they build must target horneroctl. Actions.qml owns the ONE
    # other spawn (openTerminal, app2unit shape), covered by
    # test_actions_allowlist_shape in test_welcome_content.py.
    for rel, text in _read_all().items():
        if rel.name == "Actions.qml":
            continue
        assert "execDetached" not in text, f"execDetached in {rel} (use the State writer)"
        for match in re.finditer(r"command\s*:\s*(\[.*?\])", text, re.DOTALL):
            assert "horneroctl" in match.group(1), f"non-horneroctl argv in {rel}"


def _strip_material_icons(text):
    return re.sub(r"MaterialIcon\s*\{[^}]*\}", "MaterialIcon{}", text)


def test_qstr_on_ui_literals():
    # Heuristic but deterministic: after removing MaterialIcon blocks
    # (glyph names, not user copy), every `text:` / `title:` string
    # literal on the same line must be wrapped in qsTr().
    violations = []
    for path in QML_FILES:
        rel = str(path.relative_to(ROOT))
        code = _strip_material_icons(path.read_text())
        for lineno, line in enumerate(code.splitlines(), 1):
            for prop in ("text", "title"):
                for match in re.finditer(rf"\b{prop}\s*:\s*(\"[^\"]*\")", line):
                    if "qsTr(" not in line:
                        violations.append(f"{rel}:{lineno}: {line.strip()}")
    assert not violations, "UI literals bypassing qsTr:\n" + "\n".join(violations)


def test_semantic_tokens_only():
    hits = []
    for path in QML_FILES:
        rel = str(path.relative_to(ROOT))
        for lineno, line in enumerate(path.read_text().splitlines(), 1):
            if re.search(r"#[0-9a-fA-F]{3,8}\b", line):
                hits.append(f"{rel}:{lineno}: {line.strip()}")
    assert not hits, "hardcoded colours (use Colours/Appearance tokens):\n" + "\n".join(hits)
    combined = "\n".join(_read_all().values())
    assert "Colours." in combined, "welcome UI must use the Colours singleton"
    assert "Appearance." in combined, "welcome UI must use Appearance tokens"


def test_every_literal_translatable_or_token():
    # No giant untranslatable corpus: every qsTr call site is a short UI
    # string, and font families come from Appearance.
    for rel, text in _read_all().items():
        assert "font.family" not in text, f"{rel}: font family must come from StyledText/Appearance"
        for literal in re.findall(r"qsTr\(\"([^\"]*)\"\)", text):
            assert len(literal) < 200, f"{rel}: suspiciously long literal: {literal[:60]}…"


def test_startup_hook_single_shot():
    shell = (ROOT / "shell.qml").read_text()
    assert 'import "modules/welcome"' in shell
    assert re.search(r"\bStartup\s*\{\s*\}", shell), "shell.qml must instantiate Startup"
    startup = (WELCOME / "Startup.qml").read_text()
    assert "State.ready" in startup
    assert "Session.markerKnown" in startup
    assert "Session.shouldAutoOpen" in startup
    assert 'Welcome.open("start")' in startup
    assert "_done" in startup, "startup evaluation must be single-shot"
    # The startup path itself spawns nothing and reads no CLI.
    assert "execDetached" not in startup
    assert "Process" not in startup
    assert "horneroctl" not in startup
    # Session sighting happens inside Welcome.open() so that EVERY opening
    # (automatic or manual) suppresses later same-session auto-opens.
    welcome = (WELCOME / "Welcome.qml").read_text()
    assert "Session.noteAlreadySeen" in welcome, \
        "Welcome.open must record the session sighting"


def test_launcher_picks_up_system_desktop_entries():
    apps = (ROOT / "modules" / "launcher" / "services" / "Apps.qml").read_text()
    assert "DesktopEntries.applications" in apps, (
        "launcher must keep reading system .desktop entries (no welcome-side registration)"
    )
