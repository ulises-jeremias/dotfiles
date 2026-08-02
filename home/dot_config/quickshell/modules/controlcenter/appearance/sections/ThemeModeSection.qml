pragma ComponentBehavior: Bound

import ".."
import "../../../launcher/services"
import qs.components
import qs.components.controls
import qs.components.containers
import qs.services
import qs.config
import QtQuick

CollapsibleSection {
    id: root

    required property var previewController
    required property var session

    title: qsTr("Theme mode")
    description: qsTr("Light or dark — live preference (rices set a default on apply)")
    showBackground: true

    readonly property bool darkChecked: previewController.pendingMode === "dark"
    readonly property string riceDefaultMode: {
        const id = Appearances.currentId;
        const rice = (Appearances.list || []).find(a => a.id === id);
        if (!rice)
            return "";
        return rice.darkMode ? "dark" : "light";
    }
    readonly property bool modeDivergesFromRice: riceDefaultMode !== "" && previewController.pendingMode !== riceDefaultMode

    SwitchRow {
        label: qsTr("Dark mode")
        checked: root.darkChecked
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

    StyledText {
        visible: root.modeDivergesFromRice
        text: qsTr("Differs from current rice default (%1)").arg(root.riceDefaultMode)
        color: Colours.palette.m3outline
        font.pointSize: Appearance.font.size.small
    }
}
