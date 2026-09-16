import qs.modules.welcome
import ".."

PageView {
    PageHeader {
        icon: "palette"
        title: qsTr("Personalize")
        subtitle: qsTr("Make Hornero yours. Everything previews live, nothing needs a restart.")
    }

    ActionCard {
        icon: "palette"
        title: qsTr("Look and feel")
        description: qsTr("Themes, wallpaper, colors and dark or light mode.")
        onActivated: Actions.openControlCenter("appearance")
    }

    ActionCard {
        icon: "dock_to_right"
        title: qsTr("Taskbar and dock")
        description: qsTr("What the bar shows, and where it lives.")
        onActivated: Actions.openControlCenter("taskbar")
    }

    ActionCard {
        icon: "dashboard_customize"
        title: qsTr("Bar layout")
        description: qsTr("Move and reshape the shell around your workflow.")
        onActivated: Actions.openLayoutPicker()
    }
}
