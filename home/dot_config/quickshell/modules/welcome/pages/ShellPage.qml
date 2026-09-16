import qs.modules.welcome
import ".."

PageView {
    PageHeader {
        icon: "terminal"
        title: qsTr("Shell")
        subtitle: qsTr("A terminal is always one key away, in the workspace where you need it.")
    }

    ActionCard {
        icon: "terminal"
        title: qsTr("Open a terminal")
        description: qsTr("Your configured terminal, ready in the current workspace.")
        shortcutId: "app-terminalemulator"
        onActivated: Actions.openTerminal()
    }

    ActionCard {
        icon: "terminal"
        title: qsTr("Kitty")
        description: qsTr("A second terminal with its own key, for side-by-side work.")
        shortcutId: "exec-kitty"
        interactive: false
    }
}
