pragma Singleton

import qs.utils
import qs.services
import Hornero
import Quickshell
import Quickshell.Io
import QtQuick

// Welcome state reader. Mirrors the Hornero-wide contract owned by
// HorneroOS/hornero (state schema, file location, mutation semantics):
// the shell reads `$XDG_STATE_HOME/hornero/welcome/state.json` DIRECTLY
// through this FileView (never a subprocess before first paint) and
// writes ONLY through `horneroctl welcome ... --yes` below (single
// writer, atomic renames on the CLI side). The shell never writes the
// file itself. Missing / malformed / wrong-version content recovers to
// defaults without touching the file.
Singleton {
    id: root

    // Default content revision. Must track the CLI-side current revision;
    // used only when the file is absent or unreadable.
    readonly property string defaultContentRevision: "p1"

    property bool showOnLogin: true
    property string contentRevision: defaultContentRevision
    property string lastSeenContentRevision: ""
    property bool ready: false

    // Write health: set when a horneroctl write fails or times out. The UI
    // keeps the in-memory preference and surfaces this as a warning.
    property bool writeFailed: false
    property string lastWriteError: ""
    property bool horneroctlMissing: false

    readonly property string stateFilePath: `${Paths.state}/welcome/state.json`

    // Tolerant parse mirroring the CLI decoder: any structural problem
    // (not JSON, not an object, wrong schemaVersion, missing or wrongly
    // typed showOnLogin) recovers to defaults. Unknown extra keys are
    // ignored. A missing or wrongly typed contentRevision falls back to
    // the default revision without discarding showOnLogin.
    function parse(text: string): void {
        let show = true;
        let rev = root.defaultContentRevision;
        let seen = "";
        let ok = false;
        try {
            const o = JSON.parse(text);
            if (o !== null && typeof o === "object" && !Array.isArray(o) && o.schemaVersion === 1) {
                if (typeof o.showOnLogin === "boolean") {
                    show = o.showOnLogin;
                    rev = typeof o.contentRevision === "string" ? o.contentRevision : root.defaultContentRevision;
                    seen = typeof o.lastSeenContentRevision === "string" ? o.lastSeenContentRevision : "";
                    ok = true;
                }
            }
        } catch (e) {
            ok = false;
        }
        if (!ok) {
            show = true;
            rev = root.defaultContentRevision;
            seen = "";
        }
        root.showOnLogin = show;
        root.contentRevision = rev;
        root.lastSeenContentRevision = seen;
    }

    // Single-writer queue: at most one horneroctl child at a time, pending
    // writes run in order. UI state updates optimistically in memory.
    property var _queue: []

    function _enqueue(argv: var): void {
        root._queue.push(argv);
        root._pump();
    }

    function _pump(): void {
        if (writer.running || root._queue.length === 0)
            return;
        writer.command = root._queue.shift();
        watchdog.restart();
        writer.running = true;
    }

    function _fail(message: string, missing: bool): void {
        watchdog.stop();
        root.writeFailed = true;
        if (missing)
            root.horneroctlMissing = true;
        root.lastWriteError = message;
        Toaster.toast(qsTr("Welcome"), message, "sync_problem", Toast.Warning);
        console.warn("[welcome]", message);
    }

    function writeShowOnLogin(value: bool): void {
        root.showOnLogin = value;
        root.writeFailed = false;
        root.lastWriteError = "";
        root._enqueue(["horneroctl", "welcome", "set-show-on-login", value ? "true" : "false", "--yes"]);
    }

    function markSeen(): void {
        root._enqueue(["horneroctl", "welcome", "mark-seen", "--yes"]);
    }

    Process {
        id: writer

        onExited: (exitCode, exitStatus) => {
            watchdog.stop();
            if (exitCode !== 0 || exitStatus !== 0) {
                // Exit 127 / crash-exit strongly suggests the binary is
                // absent; anything else is reported as a plain write error.
                root._fail(qsTr("Welcome: could not save (horneroctl exit %1)").arg(exitCode), exitCode === 127 || exitStatus !== 0);
            } else {
                root.writeFailed = false;
                root.lastWriteError = "";
                root.horneroctlMissing = false;
            }
            root._pump();
        }
    }

    Timer {
        id: watchdog

        interval: 10000
        repeat: false
        onTriggered: {
            if (writer.running)
                writer.running = false;
            root._fail(qsTr("Welcome: horneroctl did not respond; preference kept for this session"), true);
            root._pump();
        }
    }

    FileView {
        path: root.stateFilePath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            root.parse(text());
            root.ready = true;
        }
        onLoadFailed: {
            root.parse("");
            root.ready = true;
        }
    }
}
