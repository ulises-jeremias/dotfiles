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

    readonly property string themesDir: `${Quickshell.env("HOME")}/.local/share/dots/themes`
    readonly property string loaderScript: `${Quickshell.env("HOME")}/.local/lib/dots/list-themes.py`

    function transformSearch(search: string): string {
        const prefix = Config.launcher.actionPrefix;
        for (const cmd of ["theme", "appearance"]) {
            const full = `${prefix}${cmd}`;
            if (search === full)
                return "";
            if (search.startsWith(`${full} `))
                return search.slice(full.length + 1);
        }
        return search;
    }

    function selector(item: var): string {
        const tags = Array.isArray(item.tags) ? item.tags.join(" ") : "";
        return `${item.name} ${item.description} ${item.id} ${tags}`;
    }

    function reload(): void {
        loadProc.running = true;
    }

    function themeById(id: string): var {
        if (!id)
            return null;
        const items = themes.instances;
        for (let i = 0; i < items.length; i++) {
            if (items[i].id === id)
                return items[i];
        }
        return null;
    }

    list: themes.instances
    useFuzzy: Config.launcher.useFuzzy.actions
    keys: ["name", "description", "id", "tags"]
    weights: [0.5, 0.25, 0.15, 0.1]

    Variants {
        id: themes

        Theme {}
    }

    Process {
        id: loadProc

        running: true
        command: ["python3", root.loaderScript, root.themesDir]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(text);
                    themes.model = Array.isArray(parsed) ? parsed : [];
                } catch (e) {
                    console.warn("Themes.qml: failed to parse theme list:", e);
                    themes.model = [];
                }
            }
        }
    }

    component Theme: QtObject {
        required property var modelData

        readonly property string id: modelData.id
        readonly property string name: modelData.name
        readonly property string description: modelData.description
        readonly property string preview: modelData.preview ?? ""
        readonly property var wallpapers: modelData.wallpapers ?? []
        readonly property string wallpaperDir: modelData.wallpaperDir || id
        readonly property string defaultWallpaper: modelData.defaultWallpaper || ""
        readonly property string wallpaperPath: modelData.wallpaperPath ?? ""
        readonly property var wallpaperPaths: modelData.wallpaperPaths ?? ({})
        readonly property var tags: modelData.tags ?? []
        readonly property bool darkMode: modelData.darkMode !== undefined ? !!modelData.darkMode : true
        readonly property string schemeType: modelData.schemeType || "tonal-spot"
        readonly property string gtkTheme: modelData.gtkTheme || "Orchis-Light-Compact"
        readonly property string iconTheme: modelData.iconTheme || ""
        readonly property string gtkColorScheme: {
            const raw = (modelData.gtkColorScheme ?? "").toString().toLowerCase().replace(/_/g, "-");
            switch (raw) {
            case "follow":
            case "default":
            case "prefer-light":
            case "prefer-dark":
                return raw;
            }
            if (modelData.gtkPreferDark !== undefined)
                return modelData.gtkPreferDark ? "prefer-dark" : "prefer-light";
            const gtk = gtkTheme.toLowerCase();
            if (gtk.indexOf("light") >= 0)
                return "prefer-light";
            if (gtk.indexOf("dark") >= 0)
                return "prefer-dark";
            return darkMode ? "prefer-dark" : "prefer-light";
        }
        readonly property bool gtkPreferDark: gtkColorScheme === "prefer-dark" || gtkColorScheme === "follow" && darkMode
        function onClicked(list: AppList): void {
            list.visibilities.launcher = false;
            ThemePipeline.applyTheme(id, wallpaperPath || "");
        }
    }
}
