import qs.modules.welcome
import ".."

PageView {
    PageHeader {
        icon: "explore"
        title: qsTr("Navigate")
        subtitle: qsTr("Move around Hornero with the keyboard — or the mouse. These three cover almost everything.")
    }

    ActionCard {
        icon: "apps"
        title: qsTr("Launcher")
        description: qsTr("Search apps, run commands and switch windows from one place.")
        shortcutId: "exec-launcher"
        onActivated: Actions.openLauncher()
    }

    ActionCard {
        icon: "dashboard"
        title: qsTr("Dashboard")
        description: qsTr("Calendar, media and quick toggles in a single glance.")
        shortcutId: "ipc-dashboard-toggle"
        onActivated: Actions.openDashboard()
    }

    ActionCard {
        icon: "grid_view"
        title: qsTr("Workspace overview")
        description: qsTr("Zoom out to every workspace, then pick one. Works from anywhere.")
        shortcutId: "scrolloverview-overview:toggle"
        interactive: false
    }
}
