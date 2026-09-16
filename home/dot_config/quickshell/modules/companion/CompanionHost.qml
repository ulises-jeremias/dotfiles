pragma ComponentBehavior: Bound

import qs.modules.companion
import qs.modules.controlcenter
import qs.modules.welcome
import qs.services
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

// Companion overlay host: exactly ONE companion window on exactly one
// monitor (Variants over screens, a single delegate visible). Wires the
// store's behavior states to the animation player, hybrid frame-plus-
// transform motion (bob, takeoff/fly/landing, bounce), drag with
// monitor-aware persisted position, speech bubble, right-click menu,
// edge-summon peek/fly-in, sleep-after-idle, and every suppression
// input (session lock, fullscreen, game mode, area picker).
//
// Input-region safety: Overlay layer, Ignore exclusion, no keyboard
// focus, and a window sized to the sprite (plus bubble/menu only while
// open), so the companion never steals clicks or keyboard input.
// Disabled (CompanionStore.enabled == false) unloads every window:
// zero surfaces, zero timers, zero cost.
Scope {
    id: root

    // WlSessionLock passed from shell.qml (Lock exposes it as `lock`).
    required property var lock

    readonly property bool hasFullscreen: Hypr.focusedWorkspace?.toplevels.values.some(t => t.lastIpcObject.fullscreen === 2) ?? false

    // Session-lock suppression without a Binding: upstream quickshell
    // emits lockedChanged on lock but never on unlock (guest-proven with
    // an onLockedChanged probe), so a Binding restores never. Both edges
    // are synced explicitly instead: lockedChanged covers locking, and
    // the WlSessionLock unlock signal — emitted on every unlock path
    // (IPC, shortcut, PAM) — is the restore edge.
    function syncLocked(): void {
        CompanionStore.suppressLocked = root.lock !== null && root.lock !== undefined && root.lock.locked;
    }

    Connections {
        target: root.lock
        function onLockedChanged(): void {
            root.syncLocked();
        }
        function onUnlock(): void {
            CompanionStore.suppressLocked = false;
        }
    }

    Component.onCompleted: root.syncLocked()

    Binding {
        target: CompanionStore
        property: "suppressFullscreen"
        value: root.hasFullscreen
    }

    Binding {
        target: CompanionStore
        property: "suppressGameMode"
        value: GameMode.enabled
    }

    // Slow idle poll: sleep after a long idle. 30 s granularity keeps
    // the steady-state cost at zero (no per-frame work while idling).
    Timer {
        interval: 30000
        running: CompanionStore.enabled
        repeat: true
        onTriggered: CompanionStore.checkIdle()
    }

    // Restart durability for the store (snapshot file I/O lives here,
    // never in the store itself).
    CompanionPersist {}

    Variants {
        model: CompanionStore.enabled ? Quickshell.screens : []

        PanelWindow {
            id: win

            required property ShellScreen modelData

            readonly property int sizePx: Math.round(128 * CompanionStore.sizeScale)
            readonly property int screenW: win.modelData.width
            readonly property int screenH: win.modelData.height
            readonly property bool screenKnown: Quickshell.screens.some(s => s.name === CompanionStore.screenName)
            readonly property string targetScreen: (CompanionStore.screenName !== "" && win.screenKnown) ? CompanionStore.screenName : (Hypr.focusedMonitor !== null && Hypr.focusedMonitor !== undefined ? Hypr.focusedMonitor.name : Quickshell.screens[0].name)
            readonly property bool isMine: win.modelData.name === win.targetScreen
            readonly property bool peekMode: CompanionStore.state === "peeking"
            readonly property bool menuOpen: menu.visible
            readonly property bool flipped: (win.px + win.sizePx / 2) > win.screenW / 2
            readonly property string resolvedTheme: CompanionStore.bubbleTheme === "auto" ? (Colours.light ? "light" : "dark") : CompanionStore.bubbleTheme

            // Free position inside the screen, committed to the store
            // (as fractions + monitor name) on drag release.
            property int px: 0
            property int py: 0
            property real bobY: 0
            property bool dragging: false

            function clampPos(): void {
                win.px = Math.max(0, Math.min(win.px, win.screenW - win.sizePx));
                win.py = Math.max(0, Math.min(win.py, win.screenH - win.sizePx));
                win.updateMirror();
            }

            // Smart orientation: face the screen center. Hysteresis
            // (0.44/0.56) so a bird parked near the middle does not
            // flicker. Runs inside clampPos, the funnel for every
            // position change (drag, sync, fly-in/landing).
            property bool mirrored: false

            function updateMirror(): void {
                const c = (win.px + win.sizePx / 2) / Math.max(1, win.screenW);
                if (c > 0.56)
                    win.mirrored = true;
                else if (c < 0.44)
                    win.mirrored = false;
            }

            function syncFromStore(): void {
                if (win.dragging)
                    return;
                win.px = Math.round(CompanionStore.posX * win.screenW - win.sizePx / 2);
                win.py = Math.round(CompanionStore.posY * win.screenH - win.sizePx);
                win.clampPos();
            }

            function commitToStore(): void {
                CompanionStore.posX = (win.px + win.sizePx / 2) / win.screenW;
                CompanionStore.posY = (win.py + win.sizePx) / win.screenH;
                CompanionStore.screenName = win.modelData.name;
                CompanionStore.markDirty();
            }

            // Cross-monitor drag: if the release point's global center
            // lands on another screen, adopt it so the companion can be
            // moved across the whole layout, not just its origin monitor.
            // Returns true when it committed (caller then skips
            // commitToStore, which would restore the old screen).
            function migrateScreen(): bool {
                const gx = (win.modelData.x ?? 0) + win.px + win.sizePx / 2;
                const gy = (win.modelData.y ?? 0) + win.py + win.sizePx / 2;
                for (let i = 0; i < Quickshell.screens.length; ++i) {
                    const s = Quickshell.screens[i];
                    const sx = s.x ?? 0;
                    const sy = s.y ?? 0;
                    if (gx >= sx && gx < sx + s.width && gy >= sy && gy < sy + s.height) {
                        if (s.name !== win.modelData.name) {
                            CompanionStore.screenName = s.name;
                            CompanionStore.posX = (gx - sx) / s.width;
                            CompanionStore.posY = (gy - sy) / s.height;
                            CompanionStore.markDirty();
                            return true;
                        }
                        return false;
                    }
                }
                return false;
            }

            // Takeoff: hop to the edge, fly to the stored perch, land
            // with a bounce. Reduced motion skips straight to the perch.
            function startFlyIn(): void {
                flyAnim.stop();
                if (CompanionStore.reducedMotion) {
                    win.syncFromStore();
                    CompanionStore.requestState("idle");
                    return;
                }
                win.px = CompanionStore.edge === "left" ? 8 : win.screenW - win.sizePx - 8;
                win.py = Math.round(win.screenH * 0.45);
                flyTargetX = Math.round(CompanionStore.posX * win.screenW - win.sizePx / 2);
                flyTargetY = Math.round(CompanionStore.posY * win.screenH - win.sizePx);
                flyAnim.start();
            }

            function startFlyOut(): void {
                flyOutAnim.stop();
                if (CompanionStore.reducedMotion) {
                    CompanionStore.requestState("hidden");
                    return;
                }
                flyOutTargetX = CompanionStore.edge === "left" ? -win.sizePx : win.screenW;
                flyOutAnim.start();
            }

            property int flyTargetX: 0
            property int flyTargetY: 0
            property int flyOutTargetX: 0

            ParallelAnimation {
                id: flyAnim

                NumberAnimation {
                    target: win
                    property: "px"
                    to: win.flyTargetX
                    duration: 1100
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: win
                    property: "py"
                    to: win.flyTargetY
                    duration: 1100
                    easing.type: Easing.InOutQuad
                }
                onFinished: {
                    win.clampPos();
                    win.commitToStore();
                    landAnim.start();
                }
            }

            // Landing bounce: quick squash-and-settle on the sprite.
            SequentialAnimation {
                id: landAnim

                NumberAnimation {
                    target: sprite
                    property: "scale"
                    to: 1.18
                    duration: 120
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: sprite
                    property: "scale"
                    to: 1.0
                    duration: 260
                    easing.type: Easing.OutBounce
                }
                onFinished: {
                    if (CompanionStore.state === "entering")
                        CompanionStore.requestState("idle");
                }
            }

            ParallelAnimation {
                id: flyOutAnim

                NumberAnimation {
                    target: win
                    property: "px"
                    to: win.flyOutTargetX
                    duration: 700
                    easing.type: Easing.InQuad
                }
                onFinished: {
                    if (CompanionStore.state === "leaving")
                        CompanionStore.requestState("hidden");
                }
            }

            // Idle bob: gentle float while resting. Never runs under
            // reduced motion, while sleeping, or while busy.
            SequentialAnimation {
                id: bobAnim

                loops: Animation.Infinite
                running: !CompanionStore.reducedMotion && (CompanionStore.state === "idle" || CompanionStore.state === "hovering") && !win.dragging

                NumberAnimation {
                    target: win
                    property: "bobY"
                    to: -4
                    duration: 1400
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    target: win
                    property: "bobY"
                    to: 4
                    duration: 1400
                    easing.type: Easing.InOutSine
                }
            }

            Timer {
                id: peekTimer
                interval: 1100
                onTriggered: {
                    if (CompanionStore.state === "peeking")
                        CompanionStore.requestState("entering");
                }
            }

            Timer {
                id: excitedTimer
                interval: 2500
                onTriggered: {
                    if (CompanionStore.state === "excited")
                        CompanionStore.requestState("idle");
                }
            }

            Connections {
                target: CompanionStore
                function onStateChanged(): void {
                    const s = CompanionStore.state;
                    if (s === "entering")
                        win.startFlyIn();
                    else if (s === "leaving")
                        win.startFlyOut();
                    else if (s === "peeking")
                        peekTimer.restart();
                    else if (s === "excited")
                        excitedTimer.restart();
                    if (s !== "dragging" && !win.dragging)
                        win.syncFromStore();
                }
                function onActiveAnimationChanged(): void {
                    win.loadReel();
                }
                function onSkinChanged(): void {
                    win.loadReel();
                }
                function onPosXChanged(): void {
                    win.syncFromStore();
                }
                function onPosYChanged(): void {
                    win.syncFromStore();
                }
            }

            function loadReel(): void {
                const r = Companion.reel(CompanionStore.skin, CompanionStore.activeAnimation);
                player.setReel(r.files, r.frameMs, r.loop);
                player.playing = true;
            }

            screen: win.modelData
            color: "transparent"
            WlrLayershell.namespace: "hornero-companion"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            anchors.top: true
            anchors.left: true
            margins.top: win.py + Math.round(win.bobY)
            margins.left: win.px

            // Explicit surface size from the content column: the layer
            // surface ignores implicit-size changes, so popups sized only
            // implicitly get clipped.
            width: stack.implicitWidth
            height: stack.implicitHeight

            visible: win.isMine && CompanionStore.visible

            Component.onCompleted: {
                win.syncFromStore();
                win.loadReel();
            }

            // Bubble above, sprite below; the window hugs both.
            Column {
                id: stack

                spacing: 2

                Bubble {
                    id: bubble

                    visible: CompanionStore.bubbleOpen
                    // Content-sized (natural width up to maxWidth, at
                    // least the sprite width): binding to stack.width
                    // starves the box because the window in turn sizes
                    // from the column, clipping the sprite out.
                    width: Math.min(bubble.maxWidth, Math.max(bubble.implicitWidth, win.sizePx))
                    text: CompanionStore.bubbleText
                    theme: win.resolvedTheme
                    flip: win.flipped

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        onClicked: CompanionStore.dismissBubble()
                    }
                }

                Item {
                    id: spriteRow

                    // Peek mode: a slim on-edge sliver instead of the
                    // full sprite, so summoning never covers content.
                    // Plain Items report zero implicit size, so mirror
                    // the explicit size: the window sizes from the
                    // column's implicit size and would otherwise clip
                    // the sprite out entirely.
                    width: win.peekMode ? 28 : win.sizePx
                    height: win.sizePx
                    implicitWidth: win.peekMode ? 28 : win.sizePx
                    implicitHeight: win.sizePx
                    clip: true

                    Player {
                        id: player

                        anchors.fill: parent
                        fallbackFrame: Companion.frameSource("default", "idle")
                        onFinished: CompanionStore.clearOverride()
                    }

                    Image {
                        id: sprite

                        width: win.sizePx
                        height: win.sizePx
                        // Peek sliver shows the middle slice: centered
                        // portraits stay visible while the edge-facing
                        // slice is transparent padding on most skins.
                        x: win.peekMode ? -Math.round((win.sizePx - 28) / 2) : 0
                        // Smart orientation (see updateMirror): frames
                        // face right, so mirror on the right half to face
                        // the screen center. Peek sliver is unaffected.
                        mirror: win.mirrored
                        source: player.currentFrame
                        fillMode: Image.PreserveAspectFit
                        cache: true
                        asynchronous: true
                        opacity: CompanionStore.state === "sleeping" ? 0.55 : 1.0
                    }

                    MouseArea {
                        id: mouse

                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: win.dragging ? Qt.ClosedHandCursor : Qt.OpenHandCursor

                        property int lastX: 0
                        property int lastY: 0
                        // Set once the pointer actually moves: a
                        // drag-release also emits clicked, which must not
                        // misfire the excited-plus-tip path.
                        property bool moved: false

                        onPressed: function (ev) {
                            if (ev.button === Qt.RightButton)
                                return;
                            mouse.moved = false;
                            CompanionStore.markActive();
                            if (CompanionStore.state === "peeking") {
                                CompanionStore.summon();
                                return;
                            }
                            // Draggable from any settled visible state, including
                            // while a bubble is open ("talking"): only
                            // hidden/leaving/entering/peeking refuse.
                            if (CompanionStore.state === "idle" || CompanionStore.state === "hovering" || CompanionStore.state === "sleeping" || CompanionStore.state === "excited" || CompanionStore.state === "talking") {
                                win.dragging = true;
                                CompanionStore.requestState("dragging");
                                mouse.lastX = ev.x;
                                mouse.lastY = ev.y;
                            }
                        }
                        onPositionChanged: function (ev) {
                            if (!win.dragging)
                                return;
                            const dx = Math.round(ev.x - mouse.lastX);
                            const dy = Math.round(ev.y - mouse.lastY);
                            if (dx !== 0 || dy !== 0)
                                mouse.moved = true;
                            win.px = win.px + dx;
                            win.py = win.py + dy;
                            mouse.lastX = ev.x;
                            mouse.lastY = ev.y;
                            win.clampPos();
                        }
                        onReleased: function (ev) {
                            if (ev.button === Qt.RightButton) {
                                menu.open();
                                return;
                            }
                            if (win.dragging) {
                                win.dragging = false;
                                // migrateScreen commits directly when the
                                // release lands on another monitor.
                                if (!win.migrateScreen())
                                    win.commitToStore();
                                CompanionStore.requestState("idle");
                            }
                        }
                        onClicked: function (ev) {
                            if (ev.button === Qt.RightButton) {
                                menu.open();
                                return;
                            }
                            // Plain click (no drag): excited + a tip.
                            if (!win.dragging && !mouse.moved && CompanionStore.state !== "peeking") {
                                CompanionStore.requestState("excited");
                                const t = CompanionStore.tip();
                                if (t !== "")
                                    CompanionStore.say(t, 7000);
                                else
                                    CompanionStore.play("greet");
                            }
                        }
                        onEntered: {
                            if (CompanionStore.state === "idle" || CompanionStore.state === "sleeping")
                                CompanionStore.requestState("hovering");
                        }
                        onExited: {
                            if (CompanionStore.state === "hovering")
                                CompanionStore.requestState("idle");
                        }
                    }
                }

                // Right-click menu: tip, skin, reset, hide, settings.
                // Lives inside the column (below the sprite) so the window
                // always contains it: as a direct window child it escaped
                // the surface bounds (negative x when flipped) and the
                // compositor clipped its entries. Hidden menus take no
                // space in a positioner, and the sprite never moves.
                Rectangle {
                    id: menu

                    visible: false
                    width: 190
                    height: menuCol.implicitHeight + 16
                    implicitWidth: 190
                    implicitHeight: menuCol.implicitHeight + 16
                    color: win.resolvedTheme === "light" ? "#fffdf7" : win.resolvedTheme === "pampa" ? "#faf3e3" : "#211d17"
                    border.color: win.resolvedTheme === "pampa" ? "#74acdf" : "#4a4438"
                    border.width: 1
                    radius: 10
                    z: 10

                    function open(): void {
                        menu.visible = true;
                    }
                    function close(): void {
                        menu.visible = false;
                    }

                    function fg(): color {
                        return win.resolvedTheme === "dark" ? "#f5f1e8" : "#201d18";
                    }

                    Column {
                        id: menuCol

                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 2

                        component Entry: Text {
                            required property string label
                            signal chosen()
                            width: menuCol.width
                            leftPadding: 8
                            rightPadding: 8
                            topPadding: 6
                            bottomPadding: 6
                            text: label
                            color: menu.fg()
                            font.pixelSize: 13
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.opacity = 0.6
                                onExited: parent.opacity = 1.0
                                onClicked: parent.chosen()
                            }
                        }

                        Entry {
                            label: qsTr("Show a tip")
                            onChosen: {
                                menu.close();
                                const t = CompanionStore.tip();
                                if (t !== "")
                                    CompanionStore.say(t, 7000);
                            }
                        }
                        Entry {
                            label: qsTr("Try another skin")
                            onChosen: {
                                menu.close();
                                CompanionStore.nextSkin();
                                CompanionStore.play("greet");
                            }
                        }
                        Entry {
                            label: qsTr("Reset position")
                            onChosen: {
                                menu.close();
                                CompanionStore.resetPosition();
                            }
                        }
                        Entry {
                            label: qsTr("Take a break")
                            onChosen: {
                                menu.close();
                                CompanionStore.hide();
                            }
                        }
                        Entry {
                            label: qsTr("Companion settings")
                            onChosen: {
                                menu.close();
                                WindowFactory.create(null, {
                                    pane: "companion"
                                });
                            }
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "companion"

        // NOTE: this entry is `summon`, not `show`: a function literally
        // named `show` can never be invoked through `qs ipc call`
        // (upstream CLI quirk, guest-proven — the `show` token is
        // swallowed as the `ipc show` subcommand and the call prints the
        // target listing instead of dispatching; `qs ipc call companion
        // -- show` is the only spelling that reaches it). `summon` wakes
        // from hidden AND sleeping into the edge peek, which is the
        // useful "show me the bird" semantic over IPC.
        function summon(): void {
            CompanionStore.summon();
        }

        function hide(): void {
            CompanionStore.hide();
        }

        function toggle(): void {
            CompanionStore.toggle();
        }

        function say(text: string, timeoutMs: int): void {
            CompanionStore.say((text ?? "").toString(), (timeoutMs ?? 0) > 0 ? timeoutMs : 6000);
        }

        function tip(): string {
            const t = CompanionStore.tip();
            if (t !== "")
                CompanionStore.say(t, 7000);
            return t;
        }

        function play(animation: string): void {
            CompanionStore.play((animation ?? "").toString());
        }

        function setState(state: string): void {
            CompanionStore.requestState((state ?? "").toString());
        }

        function setSkin(skin: string): void {
            CompanionStore.setSkin((skin ?? "").toString());
        }

        function resetPosition(): void {
            CompanionStore.resetPosition();
        }

        function status(): string {
            return JSON.stringify(CompanionStore.status());
        }
    }
}
