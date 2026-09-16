pragma Singleton

import Quickshell
import QtQuick

// Welcome controller: owns the top-level window lifecycle and the current
// page. Unknown or empty pages fall back to "start" with a warning, never
// a crash. Opening is idempotent; closing destroys the window.
Singleton {
    id: root

    readonly property list<string> pages: ["start", "navigate", "shell", "workspaces", "personalize", "tools", "system", "learn"]
    property string currentPage: "start"
    property bool opened: false
    property var _win: null

    function pageValid(page: string): bool {
        return root.pages.includes(page);
    }

    function open(page: string): void {
        const p = (page ?? "").toString().trim().toLowerCase();
        if (p !== "" && !root.pageValid(p))
            console.warn(`[welcome] Unknown page "${page}" — opening start`);
        root.currentPage = root.pageValid(p) ? p : "start";
        // Every opening (automatic or manual) records the session sighting,
        // so a later shell reload in the same session never auto-reopens.
        // Idempotent per process via Session.
        Session.noteAlreadySeen();
        if (root._win !== null) {
            root.opened = true;
            return;
        }
        const comp = Qt.createComponent(Qt.resolvedUrl("Window.qml"));
        if (comp.status !== Component.Ready) {
            console.warn("[welcome] Could not load Window.qml:", comp.errorString());
            return;
        }
        root._win = comp.createObject();
        if (root._win === null) {
            console.warn("[welcome] Could not create welcome window");
            return;
        }
        root.opened = true;
    }

    function close(): void {
        root.opened = false;
        if (root._win !== null) {
            const w = root._win;
            root._win = null;
            w.destroy();
        }
    }

    function toggle(page: string): void {
        if (root.opened)
            root.close();
        else
            root.open(page);
    }

    function status(): var {
        return {
            open: root.opened,
            page: root.currentPage,
            showOnLogin: State.showOnLogin
        };
    }
}
