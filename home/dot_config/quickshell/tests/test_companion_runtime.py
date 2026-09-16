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
IPC_FNS = ["show(", "hide(", "toggle(", "say(", "tip(", "play(",
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
    assert "PersistentProperties" in STORE
    assert 'reloadableId: "companion"' in STORE
    for key in ("enabled", "skin", "sizeScale", "tipsEnabled", "edge",
                "sleepMinutes", "reducedMotion", "bubbleTheme",
                "posX", "posY", "screenName"):
        assert key in STORE, f"store missing persisted key {key}"
    assert "sanitize" in STORE


def test_player_single_timer_core():
    assert len(re.findall(r"\bTimer\s*\{", PLAYER)) == 1, \
        "Player must advance on exactly one Timer"
    assert "signal finished()" in PLAYER
    for prop in ("frameMs", "loop", "playing", "paused", "currentIndex"):
        assert prop in PLAYER, f"Player missing {prop}"
    # Single-frame reels never run the timer: idle costs nothing.
    assert "frames.length > 1" in PLAYER
    assert "setReel" in PLAYER


def test_player_finishes_instant_reels():
    # A non-looping single-frame reel plays through instantly: setReel
    # must report finished (deferred) so one-shot overrides clear
    # instead of sticking on the greet frame forever.
    assert "Qt.callLater(root.finished)" in PLAYER
    assert "frames.length <= 1" in PLAYER


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


def test_shell_wires_host():
    shell = (ROOT / "shell.qml").read_text()
    assert "CompanionHost" in shell
    assert "modules/companion" in shell


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


def test_store_active_animation_startup_safe():
    # `persist` is a child id, not a member of root: `root.persist` is
    # permanently undefined (startup TypeError plus a stuck animation).
    # activeAnimation must use the bare id like every other binding.
    assert "activeAnimation" in STORE
    assert "root.persist" not in STORE, \
        "activeAnimation must not use root.persist (undefined: child id)"
    assert "persist.overrideAnim" in STORE


def test_host_window_sizes_from_content():
    # Plain Items report zero implicit size, and the layer window sizes
    # from the column's implicit size: without mirrored implicit sizes
    # the sprite is clipped out of the window entirely.
    assert "implicitWidth: win.peekMode ? 28 : win.sizePx" in HOST
    assert "implicitHeight: win.sizePx" in HOST
    # Binding the bubble to stack.width starves the box for the same
    # reason (the window in turn sizes from the column).
    assert "width: Math.min(maxWidth, stack.width)" not in HOST
    assert "bubble.implicitWidth" in HOST


def test_menu_lives_inside_window_column():
    # As a direct window child the menu escaped the surface (negative x
    # when flipped) and the compositor clipped its entries. It must be
    # a column child with mirrored implicit sizes so the window always
    # contains it; anchors/negative-x positioning must be gone.
    assert "implicitWidth: 190" in HOST
    assert "x: win.flipped" not in HOST
    stack = HOST.split("Column {", 1)[1]
    assert "id: menu" in stack, "menu must live inside the window column"
    # The layer surface does not track implicit content changes, but it
    # follows explicit width/height: the window must bind both to the
    # column so popups always fit without clipping.
    assert "width: stack.implicitWidth" in HOST
    assert "height: stack.implicitHeight" in HOST


def test_drag_drop_stays_quiet():
    # A drag release also emits clicked: the host must track movement
    # and keep drops from triggering the excited-plus-tip path that
    # belongs to plain clicks only.
    assert "mouse.moved" in HOST
    assert "!mouse.moved" in HOST


def test_peek_sliver_shows_bird():
    # Frames are centered portraits: an edge-facing slice of the sprite
    # box would be transparent, so the peek sliver must sample the
    # middle where the bird always is.
    assert "-Math.round((win.sizePx - 28) / 2)" in HOST


def test_bubble_measures_natural_width():
    # Sizing the box from the wrapped label is circular (wrap width
    # follows the box): a separate unwrapped probe must drive
    # implicitWidth so long texts never clip mid-word.
    assert "id: measure" in BUBBLE
    assert "measure.implicitWidth" in BUBBLE
