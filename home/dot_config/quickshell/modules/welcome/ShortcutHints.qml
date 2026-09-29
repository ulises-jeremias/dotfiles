pragma Singleton

import qs.utils
import Quickshell
import Quickshell.Io
import QtQuick

// Shortcut badge resolver for the Welcome Center. Reads the generated
// manifest `$XDG_DATA_HOME/hornero/shortcuts.json` (owned by
// HorneroOS/config scripts/generate-shortcuts.py, installed by
// materialize.sh; schemaVersion 1) and exposes each curated entry as a
// human-readable badge ("SUPER + SHIFT + 1").
//
// Rules:
// - Unknown ids, a missing file, or malformed content resolve to "" and
//   the card renders NO badge — never a wrong shortcut.
// - When one id has several bindings, the first manifest entry wins. The
//   generator emits deterministic sorted output, so this is stable.
// - `curatedIds` is the single source of truth: Welcome pages must only
//   reference ids listed here (enforced by tests/test_welcome_content.py).
Singleton {
    id: root

    readonly property var curatedIds: [
        "exec-launcher",
        "ipc-dashboard-toggle",
        "scrolloverview-overview:toggle",
        "app-terminalemulator",
        "exec-kitty",
        "workspace:1",
        "movetoworkspace:1",
        "togglespecialworkspace:magic",
        "exec-screenshooter",
        "exec-clipboard",
        "exec-power-menu",
        "ipc-lock-lock",
        "exec-keyboard-help"
    ]

    property var badges: ({})
    // Full entry list for the Shortcuts reference page: every valid
    // global binding as { id, dispatcher, mods, key }. Badges stay the
    // curated first-wins view; entries feed the filterable cheatsheet.
    property var entries: []
    property bool ready: false

    readonly property string manifestPath: `${Paths.data}/shortcuts.json`

    function badge(id: string): string {
        const label = root.badges[(id ?? "").toString()];
        return label !== undefined ? label : "";
    }

    function has(id: string): bool {
        return root.badge(id) !== "";
    }

    // Tolerant parse mirroring the generator contract: any structural
    // problem (not JSON, wrong schemaVersion, entries not an array,
    // entries missing id/mods/key) yields an empty map without errors.
    function parse(text: string): void {
        const out = {};
        const all = [];
        try {
            const o = JSON.parse(text);
            if (o !== null && typeof o === "object" && !Array.isArray(o) && o.schemaVersion === 1 && Array.isArray(o.entries)) {
                for (const e of o.entries) {
                    if (e === null || typeof e !== "object" || Array.isArray(e))
                        continue;
                    if (typeof e.id !== "string" || e.id === "" || !Array.isArray(e.mods) || typeof e.key !== "string" || e.key === "")
                        continue;
                    const parts = [];
                    for (const m of e.mods) {
                        if (typeof m === "string" && m !== "")
                            parts.push(m);
                    }
                    parts.push(e.key);
                    if (out[e.id] === undefined)
                        out[e.id] = parts.join(" + ");
                    if (typeof e.submap === "string" && e.submap !== "")
                        continue;
                    all.push({ id: e.id, dispatcher: typeof e.dispatcher === "string" ? e.dispatcher : "", mods: parts.slice(0, -1), key: e.key });
                }
            }
        } catch (e) {
            // Malformed manifest: badges stay empty, UI shows no badges.
        }
        root.badges = out;
        root.entries = all;
        root.ready = true;
    }

    FileView {
        path: root.manifestPath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.parse(text())
        onLoadFailed: {
            root.badges = {};
            root.entries = [];
            root.ready = true;
        }
    }
}
