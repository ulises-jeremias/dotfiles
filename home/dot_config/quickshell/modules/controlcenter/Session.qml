import QtQuick
import "./state"
import qs.modules.controlcenter
import qs.config
import Quickshell

QtObject {
    readonly property list<string> panes: PaneRegistry.labels

    required property var root
    property bool floating: false
    property string active: {
        const pane = Config.controlCenter.startPane ?? "network";
        return PaneRegistry.getById(pane) ? pane : "network";
    }
    property int activeIndex: 0
    property bool navExpanded: false

    readonly property BluetoothState bt: BluetoothState {}
    readonly property NetworkState network: NetworkState {}
    readonly property EthernetState ethernet: EthernetState {}
    readonly property LauncherState launcher: LauncherState {}
    readonly property VpnState vpn: VpnState {}
    property var pendingActions: ({})
    readonly property bool hasPendingActions: Object.keys(pendingActions).length > 0

    function queueAction(key: string, command: var): void {
        const next = Object.assign({}, pendingActions);
        next[key] = command;
        pendingActions = next;
    }

    function clearPendingActions(): void {
        pendingActions = ({});
    }

    function applyPendingActions(): void {
        const entries = Object.entries(pendingActions);
        for (const [, cmd] of entries) {
            if (Array.isArray(cmd) && cmd.length > 0)
                Quickshell.execDetached(cmd);
        }
        clearPendingActions();
    }

    onActiveChanged: activeIndex = Math.max(0, panes.indexOf(active))
    onActiveIndexChanged: if (panes[activeIndex])
        active = panes[activeIndex]
}
