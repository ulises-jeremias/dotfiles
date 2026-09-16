"""Launcher actions: shipped defaults stay visible despite persisted overrides.

Static QML contract tests (no compositor needed): shell.json
wholesale-replaces Config.launcher.actions, so Actions.qml must merge
baked-in defaults by name instead of trusting the persisted list.
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ACTIONS = (ROOT / "modules" / "launcher" / "services" / "Actions.qml").read_text()
DEFAULTS = (ROOT / "config" / "LauncherConfig.qml").read_text()


def test_welcome_action_shipped_in_defaults():
    assert re.search(r'name:\s*"Welcome"', DEFAULTS), "no Welcome default action"
    # The welcome IPC handler requires its page argument: an arg-less
    # open is rejected ("Too few arguments"), so the shipped command
    # must name the start page explicitly.
    m = re.search(r'name:\s*"Welcome".*?command:\s*\[(.*?)\]',
                  DEFAULTS, re.DOTALL)
    assert m, "Welcome default has no command"
    assert '"start"' in m.group(1), \
        "Welcome command must pass the start page explicitly"


def test_actions_merge_baked_defaults_by_name():
    # A pristine defaults instance must exist alongside the live config.
    assert "bakedDefaults" in ACTIONS, "no baked-defaults instance"
    assert re.search(r"LauncherConfig\s*\{", ACTIONS), \
        "baked defaults must come from LauncherConfig"
    # Merge keyed by action name: persisted edits win, new defaults appear.
    assert "byName" in ACTIONS or "by_name" in ACTIONS, "no by-name merge"
    assert "bakedDefaults.actions" in ACTIONS, "defaults list not merged"


def test_actions_never_trust_persisted_list_alone():
    # The old wholesale-replace expression must be gone: every shipped
    # default would otherwise stay invisible for existing users.
    bare = re.search(r"model:\s*Config\.launcher\.actions\.filter", ACTIONS)
    assert bare is None, "persisted list used without defaults merge"
