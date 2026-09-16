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
        description: qsTr("Log out, suspend, reboot or shut down.")
        onActivated: Actions.openSessionMenu()
    }
}
