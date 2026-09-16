pragma Singleton

import qs.utils
import Quickshell
import QtQuick

// Companion behavior store: the single source of truth for the Hornero
// sidekick's presentation state. Mirrors the Welcome module's State.qml
// pattern (tolerant persisted state, allowlisted transitions) but stays
// presentation-only: it never touches the network and never reaches past
// the running shell.
//
// Durability is two-layer and both layers matter:
// - PersistentProperties (reloadableId below) carries state across
//   in-process config reloads only. Upstream quickshell implements it as
//   an in-memory handoff on reload (see persistentprops.cpp: onReload
//   copies from the old instance) — it never touches disk, so a process
//   restart used to reset skin, position, and every preference.
// - `$XDG_STATE_HOME/hornero/companion/state.json` (canonical Paths.state
//   root, same layout as Welcome) carries state across restarts through
//   CompanionPersist: tolerant versioned parse on load, debounced
//   single-child atomic-rename writes when dirty. Anything structurally
//   wrong on restore is sanitized back to defaults without touching disk.
//   The writer lives outside this store so the store itself never spawns
//   processes.
Singleton {
    id: root

    // Long-lived behavior states owned by the runtime.
    readonly property list<string> behaviorStates: ["hidden", "peeking", "entering", "idle", "hovering", "talking", "excited", "dragging", "leaving", "sleeping"]
    // Reserved assistant states (see docs/COMPANION_ASSISTANT.md). They
    // are accepted by requestState/setState and mapped to animations so
    // a future Assistant daemon can drive the companion over IPC, but no
    // AI backend exists behind them today.
    readonly property list<string> futureStates: ["listening", "thinking", "acting", "success", "warning", "error"]

    // Behavior state -> manifest animation. Grounded states stay on the
    // skinned idle frame; walk only ever plays for greet/talk/think
    // moments — the companion never relocates on its own.
    function animationFor(state: string): string {
        switch ((state ?? "").toString()) {
        case "entering":
        case "leaving":
            return "fly";
        case "talking":
        case "excited":
        case "listening":
        case "success":
            return "greet";
        case "thinking":
        case "acting":
        case "warning":
        case "error":
            return "walk";
        default:
            return "idle";
        }
    }

    function isKnownState(state: string): bool {
        const s = (state ?? "").toString();
        return root.behaviorStates.indexOf(s) !== -1 || root.futureStates.indexOf(s) !== -1;
    }

    // Built-in tip catalog. Tips deep-link into Welcome pages (reusing
    // the Welcome catalog: validated against Welcome.pages by the host
    // before opening, unknown pages never open).
    readonly property var tips: [
        { text: "Open the launcher with Super+Space — see Welcome › shell for the tour.", page: "shell" },
        { text: "Make the shell yours: Welcome › personalize walks through themes.", page: "personalize" },
        { text: "Workspaces keep things tidy — peek at Welcome › workspaces.", page: "workspaces" },
        { text: "Handy tools live one click away — see Welcome › tools.", page: "tools" },
        { text: "Curious what changed? Welcome › learn has the notes.", page: "learn" },
        { text: "Right-click me for skins, tips, and settings.", page: "start" }
    ]

    // Suppression inputs. The host binds these to live shell state
    // (session lock, fullscreen, game mode); AreaPicker sets
    // areaPickerOpen directly while open.
    property bool suppressLocked: false
    property bool suppressFullscreen: false
    property bool suppressGameMode: false
    property bool areaPickerOpen: false

    readonly property bool suppressed: root.suppressLocked || root.suppressFullscreen || root.suppressGameMode || root.areaPickerOpen
    readonly property bool visible: persist.enabled && !root.suppressed && persist.state !== "hidden"

    property string bubbleText: ""
    property bool bubbleOpen: false

    PersistentProperties {
        id: persist

        property bool enabled: true
        property string state: "idle"
        property string skin: "default"
        property real sizeScale: 1.0
        property bool tipsEnabled: true
        property string edge: "right"
        property int sleepMinutes: 10
        property bool reducedMotion: false
        property string bubbleTheme: "auto"
        property real posX: 0.85
        property real posY: 0.72
        property string screenName: ""
        property int tipIndex: 0
        // One-shot animation override (e.g. greet on click). Cleared by
        // the host when the player reports finished.
        property string overrideAnim: ""
        property double lastActiveMs: 0

        reloadableId: "companion"
    }

    property alias enabled: persist.enabled
    property alias state: persist.state
    property alias skin: persist.skin
    property alias sizeScale: persist.sizeScale
    property alias tipsEnabled: persist.tipsEnabled
    property alias edge: persist.edge
    property alias sleepMinutes: persist.sleepMinutes
    property alias reducedMotion: persist.reducedMotion
    property alias bubbleTheme: persist.bubbleTheme
    property alias posX: persist.posX
    property alias posY: persist.posY
    property alias screenName: persist.screenName
    property alias overrideAnim: persist.overrideAnim

    // The animation the player should show right now.
    // NOTE: bare `persist` (not `root.persist`): qualified access through
    // the Singleton root fails at startup (TypeError) and leaves the
    // animation stuck on the fallback.
    readonly property string activeAnimation: persist.overrideAnim !== "" ? persist.overrideAnim : root.animationFor(persist.state)

    function sanitize(): void {
        if (!root.isKnownState(persist.state))
            persist.state = "idle";
        if (persist.sizeScale < 0.5 || persist.sizeScale > 2.0)
            persist.sizeScale = 1.0;
        if (persist.posX < 0.0 || persist.posX > 1.0)
            persist.posX = 0.85;
        if (persist.posY < 0.0 || persist.posY > 1.0)
            persist.posY = 0.72;
        if (persist.sleepMinutes < 0 || persist.sleepMinutes > 120)
            persist.sleepMinutes = 10;
        if (persist.edge !== "left" && persist.edge !== "right")
            persist.edge = "right";
        if (persist.bubbleTheme !== "auto" && persist.bubbleTheme !== "dark" && persist.bubbleTheme !== "light" && persist.bubbleTheme !== "pampa")
            persist.bubbleTheme = "auto";
        if (persist.tipIndex < 0 || persist.tipIndex > 1000000)
            persist.tipIndex = 0;
        persist.overrideAnim = "";
        if (persist.lastActiveMs <= 0)
            persist.lastActiveMs = Date.now();
    }

    Component.onCompleted: root.sanitize()

    // Any genuine interaction wakes the companion and resets the idle clock.
    function markActive(): void {
        persist.lastActiveMs = Date.now();
        if (persist.state === "sleeping")
            persist.state = "idle";
    }

    function requestState(state: string): void {
        const s = (state ?? "").toString();
        if (!root.isKnownState(s)) {
            console.warn(`[companion] Unknown state "${state}" — ignoring`);
            return;
        }
        if (s !== "sleeping")
            root.markActive();
        persist.state = s;
        root.markDirty();
    }

    // One-shot animation (greet/fly/walk/idle). Unknown names fall back
    // to idle with a warning, never a crash.
    function play(animation: string): void {
        const a = (animation ?? "").toString();
        if (Companion.isKnownAnimation(a))
            persist.overrideAnim = a;
        else {
            console.warn(`[companion] Unknown animation "${animation}" — playing idle`);
            persist.overrideAnim = "idle";
        }
        root.markActive();
        root.markDirty();
    }

    function clearOverride(): void {
        persist.overrideAnim = "";
        root.markDirty();
    }

    function show(): void {
        if (persist.state === "hidden" || persist.state === "leaving")
            persist.state = "peeking";
        root.markActive();
        root.markDirty();
    }

    function hide(): void {
        if (persist.state !== "hidden")
            persist.state = "leaving";
        root.dismissBubble();
        root.markDirty();
    }

    function toggle(): void {
        if (persist.state === "hidden")
            root.show();
        else
            root.hide();
        root.markDirty();
    }

    // Edge summon: peek from the configured edge, then fly in.
    function summon(): void {
        if (persist.state === "hidden" || persist.state === "sleeping")
            persist.state = "peeking";
        root.markActive();
        root.markDirty();
    }

    function setSkin(skin: string): void {
        const s = (skin ?? "").toString();
        if (!Companion.isKnownSkin(s)) {
            console.warn(`[companion] Unknown skin "${skin}" — keeping "${persist.skin}"`);
            return;
        }
        persist.skin = s;
        root.markActive();
        root.markDirty();
    }

    function nextSkin(): void {
        const i = Companion.knownSkins.indexOf(persist.skin);
        persist.skin = Companion.knownSkins[(i + 1) % Companion.knownSkins.length];
        root.markActive();
        root.markDirty();
    }

    function resetPosition(): void {
        persist.posX = 0.85;
        persist.posY = 0.72;
        persist.screenName = "";
        root.markActive();
        root.markDirty();
    }

    function say(text: string, timeoutMs: int): void {
        const t = (text ?? "").toString().trim().slice(0, 280);
        if (t === "")
            return;
        root.bubbleText = t;
        root.bubbleOpen = true;
        bubbleTimer.interval = (timeoutMs ?? 0) > 0 ? timeoutMs : 6000;
        bubbleTimer.restart();
        if (persist.state === "idle" || persist.state === "hovering")
            persist.state = "talking";
        root.markActive();
        root.markDirty();
    }

    function dismissBubble(): void {
        root.bubbleOpen = false;
        root.bubbleText = "";
        bubbleTimer.stop();
        if (persist.state === "talking")
            persist.state = "idle";
        root.markDirty();
    }

    // Next tip (round-robin). Returns "" when tips are off or suppressed.
    function tip(): string {
        if (!persist.tipsEnabled)
            return "";
        const entry = root.tips[persist.tipIndex % root.tips.length];
        persist.tipIndex = (persist.tipIndex + 1) % root.tips.length;
        root.markActive();
        root.markDirty();
        return entry.text;
    }

    function tipPage(): string {
        const i = (persist.tipIndex + root.tips.length - 1) % root.tips.length;
        return root.tips[i].page;
    }

    // Called on a slow poll by the host: sleep after a long idle.
    function checkIdle(): void {
        if (persist.sleepMinutes <= 0 || !persist.enabled)
            return;
        if (persist.state !== "idle" && persist.state !== "hovering")
            return;
        if (Date.now() - persist.lastActiveMs > persist.sleepMinutes * 60000)
            persist.state = "sleeping";
        root.markDirty();
    }

    // Read-only status for IPC.
    function status(): var {
        return {
            enabled: persist.enabled,
            state: persist.state,
            skin: persist.skin,
            animation: root.activeAnimation,
            suppressed: root.suppressed,
            bubbleOpen: root.bubbleOpen
        };
    }

    Timer {
        id: bubbleTimer
        interval: 6000
        onTriggered: root.dismissBubble()
    }

    // -- Restart durability (file-backed, see header) -------------------
    readonly property string stateFilePath: `${Paths.state}/companion/state.json`
    readonly property int stateSchemaVersion: 1
    // First apply wins: the on-disk snapshot must never clobber live
    // interaction that happened before the async load completed.
    property bool _restored: false
    property string _lastSaved: ""

    // Fixed key order so the dirty comparison is stable.
    function serialize(): string {
        return JSON.stringify({
            schemaVersion: root.stateSchemaVersion,
            enabled: persist.enabled,
            state: persist.state,
            skin: persist.skin,
            sizeScale: persist.sizeScale,
            tipsEnabled: persist.tipsEnabled,
            edge: persist.edge,
            sleepMinutes: persist.sleepMinutes,
            reducedMotion: persist.reducedMotion,
            bubbleTheme: persist.bubbleTheme,
            posX: persist.posX,
            posY: persist.posY,
            screenName: persist.screenName,
            tipIndex: persist.tipIndex
        });
    }

    // Dirty flag consumed by CompanionPersist (which owns the snapshot
    // child process, so this store stays process-free). Suppressed while
    // a restore is applying its snapshot.
    property bool dirty: false
    property bool _restoring: false

    function markDirty(): void {
        if (!root._restoring)
            root.dirty = true;
    }

    function clearDirty(): void {
        root.dirty = false;
    }

    // Live interaction won the race against the async snapshot load:
    // later loads must not clobber it.
    function adoptCurrent(): void {
        root._restored = true;
    }

    // Tolerant versioned parse mirroring Welcome/State.qml: wrong types
    // and ranges fall back per key, unknown keys are ignored, and
    // transient motion states (which need a live animation context the
    // host only starts on state *changes*) settle to idle. A fresh
    // process is a fresh activity signal, so the idle clock restarts.
    function restore(text: string): void {
        if (root._restored)
            return;
        root._restoring = true;
        try {
            const o = JSON.parse(text);
            if (o !== null && typeof o === "object" && !Array.isArray(o) && o.schemaVersion === root.stateSchemaVersion) {
                if (typeof o.enabled === "boolean")
                    persist.enabled = o.enabled;
                if (typeof o.skin === "string" && Companion.isKnownSkin(o.skin))
                    persist.skin = o.skin;
                if (typeof o.sizeScale === "number")
                    persist.sizeScale = o.sizeScale;
                if (typeof o.tipsEnabled === "boolean")
                    persist.tipsEnabled = o.tipsEnabled;
                if (typeof o.edge === "string")
                    persist.edge = o.edge;
                if (typeof o.sleepMinutes === "number")
                    persist.sleepMinutes = o.sleepMinutes;
                if (typeof o.reducedMotion === "boolean")
                    persist.reducedMotion = o.reducedMotion;
                if (typeof o.bubbleTheme === "string")
                    persist.bubbleTheme = o.bubbleTheme;
                if (typeof o.posX === "number")
                    persist.posX = o.posX;
                if (typeof o.posY === "number")
                    persist.posY = o.posY;
                if (typeof o.screenName === "string")
                    persist.screenName = o.screenName;
                if (typeof o.tipIndex === "number")
                    persist.tipIndex = o.tipIndex;
                if (typeof o.state === "string") {
                    switch (o.state) {
                    case "hidden":
                    case "sleeping":
                    case "idle":
                    case "hovering":
                        persist.state = o.state;
                        break;
                    default:
                        persist.state = "idle";
                        break;
                    }
                }
            }
        } catch (e) {
            // Malformed snapshot: sanitize() below recovers to defaults.
        }
        persist.lastActiveMs = Date.now();
        root.sanitize();
        root._restoring = false;
        root._restored = true;
    }

    // Direct-assigned preference keys (bound straight from the settings
    // UI, bypassing the mutating functions below) still mark the
    // snapshot dirty through their change signals.
    onEnabledChanged: root.markDirty()
    onTipsEnabledChanged: root.markDirty()
    onReducedMotionChanged: root.markDirty()
    onSizeScaleChanged: root.markDirty()
    onSleepMinutesChanged: root.markDirty()
    onEdgeChanged: root.markDirty()
    onBubbleThemeChanged: root.markDirty()
}
