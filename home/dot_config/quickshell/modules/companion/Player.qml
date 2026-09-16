pragma ComponentBehavior: Bound

import QtQuick

// Reusable frame player: exactly one Timer core advances the frame
// list. Single-frame (or empty) animations never run the timer, so an
// idling companion costs nothing. Emits finished() when a non-looping
// animation plays through; looping animations run until paused,
// stopped, or given new frames.
Item {
    id: root

    // Full file paths (or qrc/source URLs) of the current animation.
    property list<string> frames: []
    // Shown when frames is empty; never blank.
    property string fallbackFrame: ""
    property int frameMs: 900
    property bool loop: true
    property bool playing: true
    property bool paused: false
    property int currentIndex: 0

    signal finished()

    readonly property bool advancing: root.playing && !root.paused && root.frames.length > 1
    readonly property string currentFrame: root.frames.length > 0 ? root.frames[Math.min(root.currentIndex, root.frames.length - 1)] : root.fallbackFrame

    function restart(): void {
        root.currentIndex = 0;
    }

    // Swap animation reels (resets to the first frame). Called by the
    // host whenever skin or animation changes.
    function setReel(frames: list<string>, frameMs: int, loop: bool): void {
        root.frames = frames;
        root.frameMs = (frameMs ?? 0) > 0 ? frameMs : 900;
        root.loop = loop ?? true;
        root.restart();
        // Single-frame (or empty) non-looping reels never run the timer,
        // so finished() would never fire and a one-shot override would
        // stick forever. Complete asynchronously instead.
        if (!root.loop && root.frames.length <= 1)
            Qt.callLater(root.finished);
    }

    Timer {
        id: advanceTimer

        interval: root.frameMs
        repeat: true
        running: root.advancing
        triggeredOnStart: false

        onTriggered: {
            if (root.currentIndex >= root.frames.length - 1) {
                if (root.loop) {
                    root.currentIndex = 0;
                } else {
                    root.playing = false;
                    root.finished();
                }
            } else {
                root.currentIndex = root.currentIndex + 1;
            }
        }
    }

    onFramesChanged: {
        if (root.currentIndex >= root.frames.length)
            root.currentIndex = 0;
    }
}
