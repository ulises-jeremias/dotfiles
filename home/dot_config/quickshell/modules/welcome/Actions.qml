pragma Singleton

import qs.config
import qs.modules.controlcenter
import qs.services
import Quickshell
import QtQuick

// Allowlisted in-shell actions for the Welcome Center. Pages must trigger
// ONLY these functions: no ad-hoc execDetached, no Process, no horneroctl,
// no URLs. Everything here stays inside the running shell except
// openTerminal, which mirrors the launcher's app2unit launch shape
// (modules/launcher/services/Apps.qml) using the configured terminal.
Singleton {
    id: root

    // Fullscreen guard shared by drawer toggles (mirrors Shortcuts.qml):
    // opening drawers over an exclusive fullscreen surface is refused.
    readonly property bool hasFullscreen: Hypr.focusedWorkspace?.toplevels.values.some(t => t.lastIpcObject.fullscreen === 2) ?? false

    function openLauncher(): void {
        if (root.hasFullscreen)
            return;
        const v = Visibilities.getForActive();
        if (v)
            v.launcher = true;
    }

    function openDashboard(): void {
        if (root.hasFullscreen)
            return;
        const v = Visibilities.getForActive();
        if (v)
            v.dashboard = true;
    }

    function openSessionMenu(): void {
        if (root.hasFullscreen)
            return;
        const v = Visibilities.getForActive();
        if (v)
            v.session = true;
    }

    function openUtilities(): void {
        if (root.hasFullscreen)
            return;
        const v = Visibilities.getForActive();
        if (v)
            v.utilities = true;
    }

    function openLayoutPicker(): void {
        if (root.hasFullscreen)
            return;
        const v = Visibilities.getForActive();
        if (v)
            v.layoutPicker = true;
    }

    // Pane ids are validated against PaneRegistry (same rule as the
    // `controlCenter` IPC target): unknown panes open the default view.
    function openControlCenter(pane: string): void {
        const id = (pane ?? "").toString().trim();
        if (id !== "" && PaneRegistry.getById(id))
            WindowFactory.create(null, {
                pane: id
            });
        else
            WindowFactory.create();
    }

    function shellQuote(arg: var): string {
        return `'${String(arg).replace(/'/g, `'\"'\"'`)}'`;
    }

    function openTerminal(): void {
        const quoted = [...Config.general.apps.terminal].map(a => root.shellQuote(a)).join(" ");
        const script = `if command -v app2unit >/dev/null 2>&1; then exec app2unit -- ${quoted}; else exec ${quoted}; fi`;
        Quickshell.execDetached({
            command: ["sh", "-lc", script]
        });
    }

    function openWelcome(page: string): void {
        Welcome.open(page ?? "start");
    }
}
