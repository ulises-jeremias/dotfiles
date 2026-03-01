pragma Singleton

import ".."
import qs.config
import qs.utils
import Quickshell
import Quickshell.Io
import QtQuick

Searcher {
    id: root

    property string currentId: ""

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
        getAppearances.running = true;
        getCurrent.running = true;
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

    Process {
        id: getAppearances

        running: true
        command: ["dots-appearance", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(text);
                    if (Array.isArray(parsed))
                        appearances.model = parsed;
                    else
                        appearances.model = [];
                } catch (e) {
                    appearances.model = [];
                }
            }
        }
    }

    Process {
        id: getCurrent

        running: true
        command: ["dots-appearance", "current"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.currentId = text.trim();
            }
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

        function onClicked(list: AppList): void {
            list.visibilities.launcher = false;
            root.currentId = id;
            Quickshell.execDetached(["dots-appearance", "apply", id]);
            Qt.callLater(() => {
                root.reload();
            });
        }
    }
}
