pragma Singleton

import qs.config
import qs.utils
import Caelestia
import Quickshell

Searcher {
    id: root

    function shellQuote(arg: var): string {
        return `'${String(arg).replace(/'/g, `'"'"'`)}'`;
    }

    function runDetachedWithFallback(commandArgs: list<string>, workingDirectory: string): void {
        const quoted = commandArgs.map(a => shellQuote(a)).join(" ");
        const script = `if command -v app2unit >/dev/null 2>&1; then exec app2unit -- ${quoted}; else exec ${quoted}; fi`;
        Quickshell.execDetached({
            command: ["sh", "-lc", script],
            workingDirectory: workingDirectory
        });
    }

    function launch(entry: DesktopEntry): void {
        appDb.incrementFrequency(entry.id);

        if (entry.runInTerminal) {
            runDetachedWithFallback([
                ...Config.general.apps.terminal,
                `${Quickshell.shellDir}/assets/wrap_term_launch.sh`,
                ...entry.command
            ], entry.workingDirectory);
        } else {
            runDetachedWithFallback([...entry.command], entry.workingDirectory);
        }
    }

    function search(search: string): list<var> {
        const prefix = Config.launcher.specialPrefix;

        if (search.startsWith(`${prefix}i `)) {
            keys = ["id", "name"];
            weights = [0.9, 0.1];
        } else if (search.startsWith(`${prefix}c `)) {
            keys = ["categories", "name"];
            weights = [0.9, 0.1];
        } else if (search.startsWith(`${prefix}d `)) {
            keys = ["comment", "name"];
            weights = [0.9, 0.1];
        } else if (search.startsWith(`${prefix}e `)) {
            keys = ["execString", "name"];
            weights = [0.9, 0.1];
        } else if (search.startsWith(`${prefix}w `)) {
            keys = ["startupClass", "name"];
            weights = [0.9, 0.1];
        } else if (search.startsWith(`${prefix}g `)) {
            keys = ["genericName", "name"];
            weights = [0.9, 0.1];
        } else if (search.startsWith(`${prefix}k `)) {
            keys = ["keywords", "name"];
            weights = [0.9, 0.1];
        } else {
            keys = ["name"];
            weights = [1];

            if (!search.startsWith(`${prefix}t `))
                return query(search).map(e => e.entry);
        }

        const results = query(search.slice(prefix.length + 2)).map(e => e.entry);
        if (search.startsWith(`${prefix}t `))
            return results.filter(a => a.runInTerminal);
        return results;
    }

    function selector(item: var): string {
        return keys.map(k => item[k]).join(" ");
    }

    list: appDb.apps
    useFuzzy: Config.launcher.useFuzzy.apps

    AppDb {
        id: appDb

        path: `${Paths.state}/apps.sqlite`
        favouriteApps: Config.launcher.favouriteApps
        entries: DesktopEntries.applications.values.filter(a => !Strings.testRegexList(Config.launcher.hiddenApps, a.id))
    }
}
