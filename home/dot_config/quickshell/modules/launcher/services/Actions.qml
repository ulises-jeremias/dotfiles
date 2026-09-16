pragma Singleton

import ".."
import qs.services
import qs.config
import qs.utils
import Quickshell
import QtQuick

Searcher {
    id: root

    function transformSearch(search: string): string {
        return search.slice(Config.launcher.actionPrefix.length);
    }

    list: variants.instances
    useFuzzy: Config.launcher.useFuzzy.actions

    // Pristine compiled defaults. Config.launcher.actions is wholesale
    // replaced by the persisted shell.json list, so a new shipped action
    // (e.g. Welcome) would stay invisible for existing users. Merge by
    // name instead: every shipped default stays visible, persisted edits
    // win per action, and user-added custom entries are appended.
    LauncherConfig {
        id: bakedDefaults
    }

    Variants {
        id: variants

        model: {
            const live = Config.launcher.actions ?? [];
            const baked = bakedDefaults.actions ?? [];
            const byName = {};
            for (const a of live) {
                if (a && a.name)
                    byName[a.name] = a;
            }
            const bakedNames = {};
            const merged = baked.map(d => {
                if (!d || !d.name)
                    return d;
                bakedNames[d.name] = true;
                const o = byName[d.name] ?? {};
                return {
                    name: d.name,
                    icon: o.icon ?? d.icon,
                    description: o.description ?? d.description,
                    command: o.command ?? d.command,
                    enabled: o.enabled ?? d.enabled ?? true,
                    dangerous: o.dangerous ?? d.dangerous ?? false
                };
            });
            for (const a of live) {
                if (a && a.name && !bakedNames[a.name])
                    merged.push(a);
            }
            return merged.filter(a => (a.enabled ?? true) && (Config.launcher.enableDangerousActions || !(a.dangerous ?? false)));
        }

        Action {}
    }

    component Action: QtObject {
        required property var modelData
        readonly property string name: modelData.name ?? qsTr("Unnamed")
        readonly property string desc: modelData.description ?? qsTr("No description")
        readonly property string icon: modelData.icon ?? "help_outline"
        readonly property list<string> command: modelData.command ?? []
        readonly property bool enabled: modelData.enabled ?? true
        readonly property bool dangerous: modelData.dangerous ?? false

        function onClicked(list: AppList): void {
            if (command.length === 0)
                return;

            if (command[0] === "autocomplete" && command.length > 1) {
                list.search.text = `${Config.launcher.actionPrefix}${command[1]} `;
            } else if (command[0] === "setMode" && command.length > 1) {
                list.visibilities.launcher = false;
                Colours.setMode(command[1]);
            } else if (command[0] === "layoutpicker") {
                list.visibilities.launcher = false;
                Visibilities.getForActive().layoutPicker = true;
            } else {
                list.visibilities.launcher = false;
                Quickshell.execDetached(command);
            }
        }
    }
}
