pragma Singleton

import ".."
import qs.config
import qs.services
import qs.utils
import Quickshell
import Quickshell.Io
import QtQuick

Searcher {
    id: root

    property string currentId: Rice.currentId

    readonly property string ricesDir: `${Quickshell.env("HOME")}/.local/share/dots/rices`
    readonly property string loaderScript: `${Quickshell.env("HOME")}/.local/lib/dots/list-rices.py`

    function transformSearch(search: string): string {
        const prefix = Config.launcher.actionPrefix;
        const riceCmd = `${prefix}rice`;
        const appearanceCmd = `${prefix}appearance`;
        if (search === riceCmd)
            return "";
        if (search.startsWith(`${riceCmd} `))
            return search.slice(riceCmd.length + 1);
        if (search === appearanceCmd)
            return "";
        if (search.startsWith(`${appearanceCmd} `))
            return search.slice(appearanceCmd.length + 1);
        return search;
    }

    function selector(item: var): string {
        return `${item.name} ${item.style} ${item.id}`;
    }

    function reload(): void {
        loadProc.running = true;
    }

    function styleIcon(style: string): string {
        const s = (style || "").toLowerCase();
        if (s.includes("cyber") || s.includes("neon"))
            return "neurology";
        if (s.includes("nature") || s.includes("landscape"))
            return "forest";
        if (s.includes("cosmic") || s.includes("space"))
            return "rocket_launch";
        if (s.includes("retro") || s.includes("vapor"))
            return "history_edu";
        if (s.includes("cozy") || s.includes("warm"))
            return "local_fire_department";
        return "palette";
    }

    list: appearances.instances
    useFuzzy: Config.launcher.useFuzzy.actions
    keys: ["name", "style", "id", "desc"]
    weights: [0.6, 0.2, 0.1, 0.1]

    Variants {
        id: appearances

        Appearance {}
    }

    // Load all rice config.json files via dedicated Python script (no heredoc escaping issues)
    Process {
        id: loadProc

        running: true
        command: ["python3", root.loaderScript, root.ricesDir]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(text);
                    appearances.model = Array.isArray(parsed) ? parsed : [];
                } catch (e) {
                    console.warn("Appearances.qml: failed to parse rice list:", e);
                    appearances.model = [];
                }
            }
        }
    }

    // Reload when Rice applies a new rice
    Connections {
        target: Rice

        function onCurrentIdChanged(): void {
            root.currentId = Rice.currentId;
        }
    }

    component Appearance: QtObject {
        required property var modelData
        readonly property string id: modelData.id
        readonly property string name: modelData.name
        readonly property string style: modelData.style
        readonly property string desc: modelData.description
        readonly property string icon: root.styleIcon(style)
        readonly property string preview: modelData.preview ?? ""
        readonly property var wallpapers: modelData.wallpapers ?? []
        readonly property var tags: modelData.tags ?? []

        function onClicked(list: AppList): void {
            list.visibilities.launcher = false;
            root.currentId = id;
            Rice.apply(id, "");
        }
    }
}
