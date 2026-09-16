import qs.modules.welcome
import ".."

PageView {
    PageHeader {
        icon: "school"
        title: qsTr("Learn")
        subtitle: qsTr("Hornero teaches itself. Keep this window around as a reference.")
    }

    ActionCard {
        icon: "keyboard"
        title: qsTr("Every shortcut")
        description: qsTr("A searchable cheatsheet of every key, one key away.")
        shortcutId: "exec-keyboard-help"
        interactive: false
    }

    ActionCard {
        icon: "replay"
        title: qsTr("Restart the tour")
        description: qsTr("Walk the eight sections again from the beginning.")
        onActivated: Actions.openWelcome("start")
    }

    ActionCard {
        icon: "bookmark"
        title: qsTr("Reopen anytime")
        description: qsTr("Launcher → Hornero Welcome, Control Center → System, or run: horneroctl welcome open")
        interactive: false
    }
}
