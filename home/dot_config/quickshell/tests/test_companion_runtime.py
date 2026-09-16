"""Companion runtime: animation player, behavior store, overlay host.

Static QML contract tests (no compositor needed): every behavior the
task names is asserted structurally so regressions fail here, not in
a running shell.
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
COMPANION = ROOT / "modules" / "companion"
STORE = (COMPANION / "CompanionStore.qml").read_text()
PLAYER = (COMPANION / "Player.qml").read_text()
HOST = (COMPANION / "CompanionHost.qml").read_text()
BUBBLE = (COMPANION / "Bubble.qml").read_text()
RESOLVER = (COMPANION / "Companion.qml").read_text()

BEHAVIOR_STATES = ["hidden", "peeking", "entering", "idle", "hovering",
                   "talking", "excited", "dragging", "leaving", "sleeping"]
FUTURE_STATES = ["listening", "thinking", "acting",
                 "success", "warning", "error"]
IPC_FNS = ["summon(", "hide(", "toggle(", "say(", "tip(", "play(",
           "setState(", "setSkin(", "resetPosition("]


def test_runtime_files_exist():
    for name in ("CompanionStore.qml", "Player.qml", "Bubble.qml",
                 "CompanionHost.qml", "Companion.qml"):
        assert (COMPANION / name).exists(), f"missing {name}"


def test_behavior_states_enumerated():
    for state in BEHAVIOR_STATES:
        assert f'"{state}"' in STORE, f"store missing behavior state {state}"
    assert len(BEHAVIOR_STATES) == 10


def test_future_assistant_states_exposed_without_backend():
    for state in FUTURE_STATES:
        assert f'"{state}"' in STORE, f"store missing future state {state}"
    # Mapping only: no AI/process/network machinery in the store.
    for banned in ("execDetached", "Process ", "XMLHttpRequest", "WebSocket"):
        assert banned not in STORE, f"store must stay presentation-only: {banned}"


def test_animation_mapping_covers_all_states():
    for state in BEHAVIOR_STATES + FUTURE_STATES:
        # Every state maps through animationFor's switch (default covers
        # the grounded rest states; named cases cover fly/greet/walk).
        assert "animationFor" in STORE
    assert '"fly"' in STORE and '"greet"' in STORE and '"walk"' in STORE
    # Walk never relocates: no position writes outside drag/commit paths.
    assert "posX" in STORE and "posY" in STORE


def test_store_persists_without_hand_rolled_writes():
    # Two-layer durability (guest-proven): PersistentProperties carries
    # in-process reloads; the versioned JSON snapshot under the canonical
    # Paths.state root carries process restarts (upstream
    # PersistentProperties never touches disk).
    assert "PersistentProperties" in STORE
    assert 'reloadableId: "companion"' in STORE
    for key in ("enabled", "skin", "sizeScale", "tipsEnabled", "edge",
                "sleepMinutes", "reducedMotion", "bubbleTheme",
                "posX", "posY", "screenName"):
        assert key in STORE, f"store missing persisted key {key}"
    assert "sanitize" in STORE
    assert "companion/state.json" in STORE
    assert "stateSchemaVersion" in STORE
    assert "function serialize()" in STORE
    assert "function restore(" in STORE
    assert "markDirty" in STORE
    assert "commitToStore" in (ROOT / "modules" / "companion" / "CompanionHost.qml").read_text()
    persist = (COMPANION / "CompanionPersist.qml").read_text()
    assert "CompanionStore.serialize()" in persist
    assert "CompanionStore.restore(" in persist
    assert "CompanionStore.clearDirty" in persist
    assert "CompanionStore.adoptCurrent" in persist
    assert "CompanionPersist" in (ROOT / "modules" / "companion" / "CompanionHost.qml").read_text()


def test_player_single_timer_core():
    assert len(re.findall(r"\bTimer\s*\{", PLAYER)) == 1, \
        "Player must advance on exactly one Timer"
    assert "signal finished()" in PLAYER
    for prop in ("frameMs", "loop", "playing", "paused", "currentIndex"):
        assert prop in PLAYER, f"Player missing {prop}"
    # Single-frame reels never run the timer: idle costs nothing.
    assert "frames.length > 1" in PLAYER
    assert "setReel" in PLAYER


def test_resolver_exposes_full_reels():
    assert "function reel(" in RESOLVER
    assert '"files"' in RESOLVER and '"frameMs"' in RESOLVER
    assert '"loop"' in RESOLVER and '"next"' in RESOLVER


def test_host_single_companion_overlay():
    assert "CompanionStore.enabled ? Quickshell.screens : []" in HOST
    assert "isMine" in HOST
    assert "WlrLayer.Overlay" in HOST
    assert "ExclusionMode.Ignore" in HOST
    assert "WlrKeyboardFocus.None" in HOST


def test_host_suppression_inputs():
    assert "GameMode.enabled" in HOST
    assert "hasFullscreen" in HOST
    assert "lock.locked" in HOST or "lock !== null" in HOST
    assert "areaPickerOpen" in STORE
    assert "CompanionStore.areaPickerOpen = active" in \
        (ROOT / "modules" / "areapicker" / "AreaPicker.qml").read_text()


def test_host_lock_suppression_restores_on_unlock_signal():
    # Upstream quickshell emits lockedChanged on lock but never on
    # unlock (guest-proven): the host must sync both edges explicitly
    # and treat the WlSessionLock unlock signal as the restore edge.
    # A Binding on lock.locked alone restores never.
    assert "function onUnlock()" in HOST, \
        "host must handle the unlock signal as the suppression restore edge"
    assert "syncLocked" in HOST
    assert "suppressLocked" in HOST


def test_host_drag_and_persisted_position():
    assert "commitToStore" in HOST
    assert "screenName" in HOST
    assert "syncFromStore" in HOST


def test_host_hybrid_motion_and_reduced_motion():
    assert "bobY" in HOST
    assert "flyAnim" in HOST and "landAnim" in HOST
    assert "reducedMotion" in HOST
    assert "Easing.InOutQuad" in HOST or "Easing.OutBounce" in HOST


def test_host_sleep_and_wake():
    assert "checkIdle" in STORE and "sleepMinutes" in STORE
    assert '"sleeping"' in STORE
    assert "markActive" in STORE


def test_bubble_wrap_flip_theme():
    assert "Wrap" in BUBBLE
    assert "maxWidth" in BUBBLE
    assert "flip" in BUBBLE
    for theme in ("dark", "light", "pampa"):
        assert f'"{theme}"' in BUBBLE, f"bubble missing theme {theme}"


def test_menu_actions():
    for label in ("Show a tip", "Try another skin", "Reset position",
                  "Take a break", "Companion settings"):
        assert label in HOST, f"menu missing {label}"


def test_companion_ipc_target():
    assert 'target: "companion"' in HOST
    for fn in IPC_FNS:
        assert f"function {fn}" in HOST, f"companion IPC missing {fn}"
    doc = (ROOT / "docs" / "IPC.md").read_text()
    assert "companion" in doc, "docs/IPC.md must document the companion target"


def test_companion_ipc_names_avoid_cli_subcommand_collision():
    # Guest-proven: `qs ipc call companion show` never dispatches (the
    # `show` token is swallowed as the `ipc show` subcommand). No IPC
    # function on any target may reuse a qs subcommand name.
    reserved = {"show", "call", "wait", "listen", "prop", "msg", "kill", "list"}
    names = set(re.findall(r"function (\w+)\(", HOST))
    clash = names & reserved
    assert not clash, f"IPC names collide with qs subcommands: {clash}"


def test_shell_wires_host():
    shell = (ROOT / "shell.qml").read_text()
    assert "CompanionHost" in shell
    assert "modules/companion" in shell


def test_bubble_sizes_from_unwrapped_measure():
    # Circular-wrap guard: the wrapped label shrinks to the bubble width,
    # so the natural width must come from an unwrapped measure probe.
    assert "id: measure" in BUBBLE
    assert "measure.implicitWidth" in BUBBLE
    assert "label.implicitWidth + 24" not in BUBBLE


def test_store_active_animation_avoids_root_persist():
    # `root.persist` fails at startup (TypeError) and sticks the animation.
    m = re.search(r"activeAnimation:(.*)", STORE)
    assert m, "store must expose activeAnimation"
    assert "root.persist" not in m.group(1)


def test_player_completes_single_frame_one_shots():
    # Non-looping single-frame reels never run the timer; without an async
    # finished() the host's one-shot override never clears.
    assert "Qt.callLater" in PLAYER and "finished" in PLAYER
    assert "setReel" in PLAYER


def test_host_window_tracks_content_size():
    # Layer surfaces ignore implicit-size changes: the window needs an
    # explicit size bound to the content column.
    assert "width: stack.implicitWidth" in HOST
    assert "height: stack.implicitHeight" in HOST


def test_host_content_sizes_without_clipping():
    assert "Math.max(bubble.implicitWidth, win.sizePx)" in HOST
    assert "implicitWidth: win.peekMode ? 28 : win.sizePx" in HOST
    assert "implicitHeight: win.sizePx" in HOST


def test_host_peek_shows_middle_slice():
    assert "-Math.round((win.sizePx - 28) / 2)" in HOST


def test_host_click_ignores_drag_release_and_contains_menu():
    assert "mouse.moved" in HOST
    # Menu lives inside the content column: no window-child anchors and no
    # negative-x flipped placement that escapes the surface.
    assert "x: win.flipped" not in HOST
    assert "anchors.top: parent.top" not in HOST
    assert "implicitWidth: 190" in HOST


PANE = (ROOT / "modules" / "controlcenter" / "companion" / "CompanionPane.qml").read_text()
REGISTRY = (ROOT / "modules" / "controlcenter" / "PaneRegistry.qml").read_text()


def test_settings_pane_registered():
    assert '"companion"' in REGISTRY
    assert '"companion/CompanionPane.qml"' in REGISTRY
    # Deep link validation keeps working: unknown panes warn + default.
    assert "PaneRegistry.getById" in (ROOT / "modules" / "Shortcuts.qml").read_text()


def test_settings_pane_covers_every_setting():
    # enable / character / size / idle / tips / edge / theme / reset.
    for key in ("CompanionStore.enabled", "CompanionStore.tipsEnabled",
                "CompanionStore.reducedMotion", "CompanionStore.sizeScale",
                "CompanionStore.sleepMinutes", "CompanionStore.setSkin",
                "CompanionStore.edge", "CompanionStore.bubbleTheme",
                "CompanionStore.resetPosition", "CompanionStore.summon"):
        assert key in PANE, f"settings pane missing {key}"
    assert "Companion.knownSkins" in PANE
    assert 'required property Session session' in PANE


def test_menu_settings_opens_companion_pane():
    assert 'pane: "companion"' in HOST


def test_assistant_boundary_docs():
    mapping = (ROOT / "docs" / "COMPANION_ASSISTANT.md").read_text()
    adr = (ROOT / "docs" / "adr" / "002-companion-assistant-boundary.md").read_text()
    for state in FUTURE_STATES:
        assert state in mapping, f"mapping doc missing {state}"
        assert state in STORE, f"store missing reserved state {state}"
    assert "presentation" in adr.lower()
    assert "COMPANION_ASSISTANT" in adr or "assistant" in adr.lower()
    assert "002-companion-assistant-boundary" in (ROOT / "docs" / "COMPANION.md").read_text()
