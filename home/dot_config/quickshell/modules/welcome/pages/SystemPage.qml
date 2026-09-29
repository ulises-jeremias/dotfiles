import qs.modules.welcome
import ".."

PageView {
    PageHeader {
        icon: "settings"
        title: qsTr("System")
        subtitle: qsTr("Power, sessions and settings live here.")
    }

    ActionCard {
        icon: "settings"
        title: qsTr("System settings")
        description: qsTr("Network, sound, power — and this Welcome Center.")
        onActivated: Actions.openControlCenter("system")
    }

    ActionCard {
        icon: "lock"
        title: qsTr("Lock the screen")
        description: qsTr("One key locks; your session waits for you.")
        shortcutId: "ipc-lock-lock"
        interactive: false
    }

    ActionCard {
        icon: "power_settings_new"
        title: qsTr("Power and session")
        description: qsTr("Quick power menu: log out, suspend, reboot or shut down.")
        onActivated: Actions.openSessionMenu()
    }

    ActionCard {
        icon: "settings_power"
        title: qsTr("Power controls")
        description: qsTr("Steady power actions with a confirm step, plus backend state.")
        onActivated: Actions.openControlCenter("power")
    }

    ActionCard {
        icon: "system_update"
        title: qsTr("Updates & backups")
        description: qsTr("Pending system updates and config backups, in one place.")
        onActivated: Actions.openControlCenter("updates")
    }
}
