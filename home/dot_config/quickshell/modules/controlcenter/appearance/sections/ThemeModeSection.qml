pragma ComponentBehavior: Bound

import ".."
import qs.components
import qs.components.controls
import qs.components.containers
import qs.services
import qs.config
import QtQuick

CollapsibleSection {
    required property var previewController
    required property var session

    title: qsTr("Theme mode")
    description: qsTr("Light or dark theme")
    showBackground: true

    readonly property bool darkChecked: previewController.pendingMode === "dark"

    SwitchRow {
        label: qsTr("Dark mode")
        checked: darkChecked
        onToggled: checked => {
            const mode = checked ? "dark" : "light";
            previewController.startModePreview(mode);
            previewController.stageModeApply(mode);
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            hoverEnabled: true
            onEntered: previewController.startModePreview(root.darkChecked ? "dark" : "light")
        }
    }
}
