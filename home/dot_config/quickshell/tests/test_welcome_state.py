"""Welcome state contract: tolerant parse/default matrix plus the
single-writer and session-guard static guarantees.

The Python mirrors below (welcome_parse, sanitize_session) reimplement the
exact rules in modules/welcome/State.qml and modules/welcome/Session.qml,
which themselves mirror the Hornero-wide contract owned by
HorneroOS/hornero (state schema + tolerant decode). Fixture cases cover
the full matrix: missing / true / false / malformed / wrong version /
missing keys / wrong types / extra keys.
"""
import json
import re
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parent.parent
WELCOME = ROOT / "modules" / "welcome"
STATE_QML = WELCOME / "State.qml"
SESSION_QML = WELCOME / "Session.qml"

SCHEMA_VERSION = 1
DEFAULT_REVISION = "p1"


def welcome_parse(raw):
    """Python mirror of State.qml parse() / hornero welcome_parse()."""
    show, rev, seen = True, DEFAULT_REVISION, ""
    try:
        o = json.loads(raw)
    except (ValueError, TypeError):
        return show, rev, seen
    if not isinstance(o, dict) or o.get("schemaVersion") != SCHEMA_VERSION:
        return show, rev, seen
    if "showOnLogin" not in o or not isinstance(o["showOnLogin"], bool):
        return True, DEFAULT_REVISION, ""
    show = o["showOnLogin"]
    rev = o["contentRevision"] if isinstance(o.get("contentRevision"), str) else DEFAULT_REVISION
    seen = o["lastSeenContentRevision"] if isinstance(o.get("lastSeenContentRevision"), str) else ""
    return show, rev, seen


def sanitize_session(raw):
    """Python mirror of Session.qml sanitize() plus the env fallback."""
    if isinstance(raw, (list, tuple)):
        for candidate in list(raw) + ["default"]:
            if candidate:
                raw = candidate
                break
    clean = re.sub(r"[^A-Za-z0-9_-]", "_", str(raw or ""))[:64]
    return clean or "default"


def encode_canonical(show, rev="p1", seen="", first="", last=""):
    """Canonical file bytes (hornero-owned writer format; the shell only
    asserts it never produces these itself)."""
    return (
        "{\n"
        f'  "schemaVersion": {SCHEMA_VERSION},\n'
        f'  "showOnLogin": {str(show).lower()},\n'
        f'  "contentRevision": "{rev}",\n'
        f'  "lastSeenContentRevision": "{seen}",\n'
        f'  "firstOpenedAt": "{first}",\n'
        f'  "lastOpenedAt": "{last}"\n'
        "}\n"
    )


PARSE_CASES = [
    # (name, raw, expected (show, rev, seen))
    ("missing_file", None, (True, "p1", "")),
    ("empty_file", "", (True, "p1", "")),
    ("explicit_true", encode_canonical(True), (True, "p1", "")),
    ("explicit_false", encode_canonical(False), (False, "p1", "")),
    ("malformed", "{not json", (True, "p1", "")),
    ("json_array", "[1, 2]", (True, "p1", "")),
    ("json_null", "null", (True, "p1", "")),
    ("json_string", '"hello"', (True, "p1", "")),
    ("wrong_version", encode_canonical(True).replace('"schemaVersion": 1', '"schemaVersion": 2'), (True, "p1", "")),
    ("missing_version", '{"showOnLogin": false}', (True, "p1", "")),
    ("missing_show", '{"schemaVersion": 1}', (True, "p1", "")),
    ("show_wrong_type", '{"schemaVersion": 1, "showOnLogin": "yes"}', (True, "p1", "")),
    ("show_null", '{"schemaVersion": 1, "showOnLogin": null}', (True, "p1", "")),
    ("extra_keys_ignored", '{"schemaVersion": 1, "showOnLogin": false, "future": {"x": 1}, "v": 2}', (False, "p1", "")),
    ("revision_missing_keeps_show", '{"schemaVersion": 1, "showOnLogin": false}', (False, "p1", "")),
    ("revision_wrong_type_keeps_show", '{"schemaVersion": 1, "showOnLogin": false, "contentRevision": 7}', (False, "p1", "")),
    ("revision_seen", '{"schemaVersion": 1, "showOnLogin": true, "contentRevision": "p1", "lastSeenContentRevision": "p1"}', (True, "p1", "p1")),
    ("seen_wrong_type", '{"schemaVersion": 1, "showOnLogin": true, "lastSeenContentRevision": 3}', (True, "p1", "")),
    ("opt_out_wins_over_new_content", '{"schemaVersion": 1, "showOnLogin": false, "contentRevision": "p2"}', (False, "p2", "")),
]


@pytest.mark.parametrize(("name", "raw", "expected"),
                         [(n, r, e) for n, r, e in PARSE_CASES],
                         ids=[n for n, _, _ in PARSE_CASES])
def test_parse_matrix(name, raw, expected):
    assert welcome_parse(raw) == expected, name


def test_encode_key_order_is_canonical():
    text = encode_canonical(False, rev="p2", seen="p1")
    keys = re.findall(r'"(\w+)":', text)
    assert keys == ["schemaVersion", "showOnLogin", "contentRevision",
                    "lastSeenContentRevision", "firstOpenedAt", "lastOpenedAt"]
    assert welcome_parse(text) == (False, "p2", "p1")


SANITIZE_CASES = [
    ("wayland-1", "wayland-1"),
    ("c1", "c1"),
    ("a/b:c.d", "a_b_c_d"),
    ("wayland 1", "wayland_1"),
    ("", "default"),
    ("!!!", "___"),
    ("x" * 100, "x" * 64),
    ("sess-01_ok", "sess-01_ok"),
]


@pytest.mark.parametrize(("raw", "expected"), SANITIZE_CASES)
def test_sanitize_cases(raw, expected):
    assert sanitize_session(raw) == expected


def test_session_env_fallback_order():
    assert sanitize_session(["", "", ""]) == "default"
    assert sanitize_session(["sess", "wayland-1", "default"]) == "sess"
    assert sanitize_session(["", "wayland-1", "default"]) == "wayland-1"


# ── Static guarantees on the QML implementation ──────────────────────────

def test_state_qml_tolerant_reader():
    text = STATE_QML.read_text()
    assert "FileView" in text
    assert 'Paths.state' in text and '/welcome/state.json' in text
    for marker in ("try {", "catch", "schemaVersion", "JSON.parse",
                   "showOnLogin", "contentRevision"):
        assert marker in text, f"State.qml missing tolerant-parse marker: {marker}"
    # Defaults on any failure path.
    assert text.count("defaultContentRevision") >= 3


def _strip_comments(text):
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.DOTALL)
    return "\n".join(line.split("//")[0] for line in text.splitlines())


def test_state_qml_single_writer_only_horneroctl():
    text = _strip_comments(STATE_QML.read_text())
    # The shell never writes state.json itself: no file-writing APIs, only
    # horneroctl argv may reach a process spawner. Comments may discuss
    # the contract, so they are stripped before scanning.
    for banned in ("rename", "writeFile", "write(", "DataStream", "TextStream",
                   "openUrl", "state.json\" +", "state.json' +"):
        assert banned not in text, f"State.qml must not write directly ({banned})"
    # All writes flow through the single-writer queue: the only argv
    # literals enqueued must be `horneroctl welcome … --yes`, and the only
    # place a process command is assigned is the queue pump.
    assert "execDetached" not in text, "State.qml must use the queued Process writer"
    enqueued = re.findall(r"_enqueue\(\s*\[(.*?)\]", text, re.DOTALL)
    assert enqueued, "expected horneroctl writes enqueued in State.qml"
    for argv in enqueued:
        assert "horneroctl" in argv, f"non-horneroctl spawn: {argv}"
        assert "welcome" in argv, f"horneroctl spawn outside welcome contract: {argv}"
        assert "--yes" in argv, f"mutation without --yes: {argv}"
    pumps = re.findall(r"writer\.command\s*=", text)
    assert len(pumps) == 1, f"single writer must assign command exactly once, found {len(pumps)}"


def test_state_qml_qml_parse_matches_python_mirror():
    # The QML decoder must implement the same rules the matrix asserts:
    # strict version check, boolean-typed showOnLogin, string revisions,
    # extra keys ignored (no key enumeration beyond the known three).
    text = STATE_QML.read_text()
    assert "o.schemaVersion === 1" in text
    assert 'typeof o.showOnLogin === "boolean"' in text
    assert 'typeof o.contentRevision === "string"' in text
    assert 'typeof o.lastSeenContentRevision === "string"' in text


def test_session_qml_guard_shape():
    text = _strip_comments(SESSION_QML.read_text())
    assert "FileView" in text
    assert "seen-" in text, "runtime marker name must contain seen-<session>"
    assert "XDG_SESSION_ID" in text
    assert "WAYLAND_DISPLAY" in text
    assert "shouldAutoOpen" in text
    assert "noteAlreadySeen" in text
    assert "showOnLogin" in text
    assert "[^A-Za-z0-9_-]" in text, "sanitize character class must match the tested mirror"
    # The guard's only process use is the queued runtime-marker writer
    # (touch/install of a session-scoped file under $XDG_RUNTIME_DIR).
    # No shell evaluation, no destructive commands, no horneroctl writes.
    assert "execDetached" not in text
    assert "Process" in text, "marker write requires the queued Process writer"
    for banned in ("rm ", "rm\"", "sudo", "sh -c", "bash -c", "eval ", "$("):
        assert banned not in text, f"Session.qml must not run {banned!r}"
    assert "horneroctl" not in text
