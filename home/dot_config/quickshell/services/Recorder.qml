pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property alias running: props.running
    readonly property alias paused: props.paused
    readonly property alias elapsed: props.elapsed
    property bool needsStart
    property list<string> startArgs
    property bool needsStop
    property bool needsPause

    function start(extraArgs = []): void {
        needsStart = true;
        startArgs = extraArgs;
        checkProc.running = true;
    }

    function stop(): void {
        needsStop = true;
        checkProc.running = true;
    }

    function togglePause(): void {
        needsPause = true;
        checkProc.running = true;
    }

    // horneroctl capture record speaks --region/--sound/--sr; translate the
    // legacy gpu-screen-recorder short flags callers still pass. Long flags
    // go through untouched; anything else is dropped loudly, never silently.
    function _recordArgs(extra: var): var {
        const out = [];
        for (const a of (extra ?? [])) {
            if (a === "-r")
                out.push("--region");
            else if (a === "-s")
                out.push("--sound");
            else if (a === "-sr")
                out.push("--sr");
            else if (typeof a === "string" && a.startsWith("--"))
                out.push(a);
            else
                console.warn("Recorder: dropping unsupported record flag:", a);
        }
        return out;
    }

    PersistentProperties {
        id: props

        property bool running: false
        property bool paused: false
        property real elapsed: 0 // Might get too large for int

        reloadableId: "recorder"
    }

    Process {
        id: checkProc

        running: true
        command: ["pidof", "gpu-screen-recorder"]
        onExited: code => {
            props.running = code === 0;

            if (code === 0) {
                if (root.needsStop) {
                    Quickshell.execDetached(["horneroctl", "capture", "record", "stop", "--yes"]);
                    props.running = false;
                    props.paused = false;
                } else if (root.needsPause) {
                    Quickshell.execDetached(["horneroctl", "capture", "record", "pause", "--yes"]);
                    props.paused = !props.paused;
                }
            } else if (root.needsStart) {
                Quickshell.execDetached(["horneroctl", "capture", "record", "start", ...root._recordArgs(root.startArgs), "--yes"]);
                props.running = true;
                props.paused = false;
                props.elapsed = 0;
            }

            root.needsStart = false;
            root.needsStop = false;
            root.needsPause = false;
        }
    }

    Connections {
        target: Time
        enabled: props.running && !props.paused

        function onSecondsChanged(): void {
            props.elapsed++;
        }
    }
}
