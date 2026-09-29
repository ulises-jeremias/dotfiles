import qs.components
import qs.modules.welcome
import QtQuick
import ".."

// Shortcuts reference page: the searchable keybinding cheatsheet lives
// in Welcome (not the dashboard) so first-run learners and veterans
// share one home for it. All layout lives in ShortcutList, keeping
// this page shell thin per the page contract; data comes from
// ShortcutHints.
PageView {
    id: root

    onVisibleChanged: {
        if (visible)
            list.focusSearch();
    }

    PageHeader {
        icon: "keyboard"
        title: qsTr("Shortcuts")
        subtitle: qsTr("Every key, one search away. Type to filter, pick a group to narrow.")
    }

    ShortcutList {
        id: list
    }
}
