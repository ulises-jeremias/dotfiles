import qs.modules.welcome
import ".."

PageView {
    PageHeader {
        icon: "waving_hand"
        title: qsTr("Welcome to Hornero")
        subtitle: qsTr("Your desktop is ready. Open the launcher to start anything, or take the tour below — and switch off automatic opening at the bottom whenever you like.")
    }

    ActionCard {
        icon: "explore"
        title: qsTr("Take the tour")
        description: qsTr("Eight short sections: navigation, shell, workspaces, look and feel, tools, system and learning.")
        onActivated: Actions.openWelcome("navigate")
    }

    ActionCard {
        icon: "apps"
        title: qsTr("Open the launcher")
        description: qsTr("Every app, action and setting, one key away.")
        shortcutId: "exec-launcher"
        onActivated: Actions.openLauncher()
    }
}
