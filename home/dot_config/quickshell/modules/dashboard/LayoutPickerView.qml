pragma ComponentBehavior: Bound

import qs.components
import qs.config
import qs.modules.layoutpicker
import QtQuick

// Dashboard tab hosting the shell layout picker grid.
Item {
    id: root

    implicitWidth: Math.max(grid.implicitWidth + Appearance.padding.large * 2, 840)
    implicitHeight: grid.implicitHeight + Appearance.padding.large * 2

    PresetGrid {
        id: grid

        anchors.centerIn: parent
    }
}
