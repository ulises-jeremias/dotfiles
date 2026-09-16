pragma Singleton

import qs.modules.welcome
import qs.modules.welcome as WelcomeModule
import Quickshell
import Quickshell.Io
import QtQuick

// Welcome session guard: auto-open fires at most once per login session.
// Identity is `XDG_SESSION_ID`, else `WAYLAND_DISPLAY`, else "default",
// sanitized to a safe filename suffix. The guard consults both an
// in-memory flag (same-process reloads) and a runtime marker file
// (survives a Quickshell reload; the runtime dir is per-session by
// definition). The marker is read via FileView; filesystem writes belong
// to the single writer (`horneroctl welcome mark-seen --yes`, issued by
// WelcomeModule.State.markSeen through noteAlreadySeen).
Singleton {
    id: root

    property bool _noted: false
    property bool markerExists: false
    property bool markerKnown: false

    function sanitize(raw: string): string {
        const clean = String(raw ?? "").replace(/[^A-Za-z0-9_-]/g, "_").slice(0, 64);
        return clean.length > 0 ? clean : "default";
    }

    readonly property string sessionId: {
        const a = Quickshell.env("XDG_SESSION_ID");
        const b = Quickshell.env("WAYLAND_DISPLAY");
        const raw = (a && a.length > 0) ? a : ((b && b.length > 0) ? b : "default");
        return root.sanitize(raw);
    }

    readonly property string markerPath: {
        const rt = Quickshell.env("XDG_RUNTIME_DIR");
        const base = (rt && rt.length > 0) ? rt : "/tmp";
        return `${base}/hornero/welcome/seen-${root.sessionId}`;
    }

    readonly property bool shouldAutoOpen: WelcomeModule.State.ready && root.markerKnown && WelcomeModule.State.showOnLogin && !root.markerExists && !root._noted

    // The runtime marker is shell-owned ephemeral plumbing (PATH_CONTRACT
    // row 13): `install -D` creates missing parents without a shell, and
    // the empty file is a pure presence flag (the session rides in the
    // name). A failed write only degrades to the in-memory guard for this
    // process and is logged, never fatal.
    function noteAlreadySeen(): void {
        if (root._noted)
            return;
        root._noted = true;
        markerWrite.command = ["install", "-D", "/dev/null", root.markerPath];
        markerWrite.running = true;
        WelcomeModule.State.markSeen();
    }

    Process {
        id: markerWrite

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 || exitStatus !== 0)
                console.warn(`[welcome] Could not write session marker ${root.markerPath} (exit ${exitCode}); in-memory guard only`);
        }
    }

    FileView {
        path: root.markerPath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            root.markerExists = true;
            root.markerKnown = true;
        }
        onLoadFailed: {
            root.markerExists = false;
            root.markerKnown = true;
        }
    }
}
