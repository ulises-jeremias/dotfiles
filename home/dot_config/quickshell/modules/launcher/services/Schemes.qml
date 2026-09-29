pragma Singleton

import ".."
import qs.config
import qs.utils
import Quickshell
import Quickshell.Io
import QtQuick

Searcher {
    id: root

    property string currentScheme
    property string currentVariant

    function transformSearch(search: string): string {
        return search.slice(`${Config.launcher.actionPrefix}scheme `.length);
    }

    function selector(item: var): string {
        return `${item.name} ${item.flavour}`;
    }

    function reload(): void {
        getCurrent.running = true;
    }

    // Mirror the scheme backend's normalize_variant: the hyphenated
    // "tonal-spot" flavour addresses the "tonalspot" variant; every other
    // flavour is already its own variant name.
    function flavourToVariant(flavour: string): string {
        return (flavour ?? "").toLowerCase() === "tonal-spot" ? "tonalspot" : (flavour ?? "");
    }

    list: schemes.instances
    useFuzzy: Config.launcher.useFuzzy.schemes
    keys: ["name", "flavour"]
    weights: [0.9, 0.1]

    Variants {
        id: schemes

        Scheme {}
    }

    // Native scheme store: list/current read the canonical state, set runs
    // through `scheme set-variant` (flavour maps to its variant; name is
    // kept server-side). See docs/NATIVE-APPEARANCE.md.
    Process {
        id: getSchemes

        running: true
        command: ["horneroctl", "scheme", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const schemeData = JSON.parse(text);
                const list = Object.entries(schemeData).map(([name, f]) => Object.entries(f).map(([flavour, colours]) => ({
                                name,
                                flavour,
                                colours
                            })));

                const flat = [];
                for (const s of list)
                    for (const f of s)
                        flat.push(f);

                schemes.model = flat.sort((a, b) => (a.name + a.flavour).localeCompare((b.name + b.flavour)));
            }
        }
    }

    Process {
        id: getCurrent

        running: true
        command: ["horneroctl", "scheme", "current"]
        stdout: StdioCollector {
            onStreamFinished: {
                const [name, flavour, variant] = text.trim().split("\n");
                root.currentScheme = `${name} ${flavour}`;
                root.currentVariant = variant;
            }
        }
    }

    component Scheme: QtObject {
        required property var modelData
        readonly property string name: modelData.name
        readonly property string flavour: modelData.flavour
        readonly property var colours: modelData.colours

        function onClicked(list: AppList): void {
            list.visibilities.launcher = false;
            // set-variant persists variant + derived flavour and regenerates,
            // which is exactly what `set -n <name> -f <flavour>` did; the
            // single "dynamic" scheme name is kept server-side.
            Quickshell.execDetached(["horneroctl", "scheme", "set-variant", root.flavourToVariant(flavour), "--yes"]);
        }
    }
}
