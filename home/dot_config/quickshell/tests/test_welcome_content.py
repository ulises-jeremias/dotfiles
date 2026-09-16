"""Welcome Center part 2: content pages, allowlisted actions, shortcut badges.

Static contract checks (the QML engine itself is exercised in CI by
scripts/lint_qml.sh and at runtime in the VM matrix, docs/VM_TESTING.md):

- Pages trigger ONLY Actions.* / ShortcutHints.* / Welcome.* — no ad-hoc
  process spawning, no horneroctl, no external URLs.
- Every shortcutId used by a page is in ShortcutHints.curatedIds
  (single source of truth; unknown ids render no badge at runtime).
- Actions.qml exposes exactly the allowlisted in-shell actions.
- Window.qml hosts the eight real pages in nav order (no stubs).
- Every page ships translatable copy (qsTr).
"""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
WELCOME = ROOT / "modules" / "welcome"
PAGES = WELCOME / "pages"

PAGE_FILES = sorted(PAGES.glob("*Page.qml"))
EXPECTED_PAGES = [
    "StartPage",
    "NavigatePage",
    "ShellPage",
    "WorkspacesPage",
    "PersonalizePage",
    "ToolsPage",
    "SystemPage",
    "LearnPage",
]

# Tokens that must never appear in page-level QML: pages describe and
# trigger, they never spawn, write state, or leave the shell.
BANNED_PAGE_TOKENS = (
    "execDetached",
    "Process {",
    "horneroctl",
    "openUrlExternally",
    "XMLHttpRequest",
)

# Dotted callables pages may invoke: the Actions allowlist, the badge
# resolver, and window navigation.
ALLOWED_CALLABLE_ROOTS = ("Actions.", "ShortcutHints.", "Welcome.")


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _strip_comments(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.DOTALL)
    return re.sub(r"(^|\s)//.*$", r"\1", text, flags=re.MULTILINE)


def _curated_ids() -> list[str]:
    text = _read(WELCOME / "ShortcutHints.qml")
    m = re.search(r"readonly property var curatedIds:\s*\[(.*?)\]", text, re.DOTALL)
    assert m, "ShortcutHints.qml must define curatedIds"
    return re.findall(r'"([^"]+)"', m.group(1))



def test_pages_use_allowlisted_callables_only():
    for page in PAGE_FILES:
        code = _strip_comments(_read(page))
        # User-facing copy may name the CLI ("run: horneroctl welcome open");
        # only executable references are banned, so blank string literals.
        code = re.sub(r'"(?:[^"\\]|\\.)*"', '""', code)
        for token in BANNED_PAGE_TOKENS:
            assert token not in code, f"{page.name}: banned token {token!r}"
        for callee in set(re.findall(r"\b([A-Z][A-Za-z0-9]*)\.[a-zA-Z]", code)):
            roots = {f"{callee}."}
            assert roots <= set(ALLOWED_CALLABLE_ROOTS) or callee in (
                "Appearance", "Colours", "Qt"), \
                f"{page.name}: callable root {callee}.* is not allowlisted"


def test_shortcut_ids_single_sourced():
    curated = _curated_ids()
    assert len(curated) == len(set(curated)), "curatedIds must not repeat"
    for cid in curated:
        assert re.fullmatch(r"[a-z0-9][a-z0-9:._-]*", cid), f"bad id shape: {cid!r}"
    for page in PAGE_FILES:
        used = re.findall(r'shortcutId:\s*"([^"]+)"', _read(page))
        for cid in used:
            assert cid in curated, f"{page.name}: {cid!r} not in ShortcutHints.curatedIds"
    # Every curated id is exercised by at least one card (docs/WELCOME.md
    # tables all of them; an unexercised id is dead weight — drop it).
    exercised = {c for p in PAGE_FILES for c in re.findall(r'shortcutId:\s*"([^"]+)"', _read(p))}
    assert set(exercised) == set(curated), \
        f"unexercised curated ids: {set(curated) - set(exercised)}"


def test_actions_allowlist_shape():
    text = _strip_comments(_read(WELCOME / "Actions.qml"))
    funcs = re.findall(r"function\s+([a-zA-Z]+)\s*\(", text)
    expected = ["openLauncher", "openDashboard", "openSessionMenu", "openUtilities",
                "openLayoutPicker", "openControlCenter", "shellQuote", "openTerminal",
                "openWelcome"]
    assert funcs == expected, f"Actions.qml must expose exactly {expected}, got {funcs}"
    for token in ("horneroctl", "Process {", "openUrlExternally", "XMLHttpRequest"):
        assert token not in text, f"Actions.qml: banned token {token!r}"
    assert text.count("execDetached") == 1, "only openTerminal may spawn (app2unit shape)"
    assert "app2unit" in text and "Config.general.apps.terminal" in text
    assert "PaneRegistry.getById" in text, "openControlCenter must validate panes"
    assert "Visibilities.getForActive" in text
    assert "Welcome.open" in text


def test_badge_gating_shape():
    card = _read(WELCOME / "ActionCard.qml")
    assert "ShortcutHints.has(root.shortcutId)" in card
    assert "ShortcutHints.badge(root.shortcutId)" in card
    assert 'shortcutId !== ""' in card, "empty shortcutId must hide the badge pill"
    hints = _read(WELCOME / "ShortcutHints.qml")
    assert "schemaVersion === 1" in hints
    assert "first" in hints.lower() or "continue" in hints, \
        "duplicate manifest entries must resolve deterministically"
    assert 'return label !== undefined ? label : ""' in hints, \
        "unknown ids must resolve to an empty badge"


def test_pages_are_translatable():
    for page in PAGE_FILES:
        text = _read(page)
        assert len(re.findall(r"qsTr\(", text)) >= 2, f"{page.name}: needs qsTr copy"
        # Titles/descriptions arrive pre-translated; cards take plain strings.
        assert "required property string title" in _read(WELCOME / "ActionCard.qml")


def test_page_set_matches_nav():
    stems = [p.stem for p in PAGE_FILES]
    assert sorted(stems) == sorted(EXPECTED_PAGES), \
        f"pages/ must be exactly {EXPECTED_PAGES}, got {stems}"
    window = _read(WELCOME / "Window.qml")
    assert "StubPage" not in window, "Window.qml must not reference stubs anymore"
    stack = window.split("StackLayout", 1)[1]
    order = re.findall(r"^\s{16}([A-Z][A-Za-z]*Page)\s*\{\s*\}", stack, re.MULTILINE)
    assert order == EXPECTED_PAGES, f"StackLayout order must follow nav, got {order}"
    nav_ids = re.findall(r'id:\s*"([a-z]+)"', window.split("navPages", 1)[1].split("]", 1)[0])
    assert nav_ids == ["start", "navigate", "shell", "workspaces",
                       "personalize", "tools", "system", "learn"]

