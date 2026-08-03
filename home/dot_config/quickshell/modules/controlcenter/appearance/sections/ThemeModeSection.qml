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
    description: qsTr("Light or dark — applies on toggle")
    showBackground: true

    readonly property bool darkChecked: previewController.pendingMode === "dark"
    readonly property string themeDefaultMode: {
        const id = previewController.pendingThemeId;
        if (!id)
            return "";
        const theme = Themes.themeById(id);
        if (!theme)
            return "";
        return theme.darkMode ? "dark" : "light";
    }
    readonly property bool modeDivergesFromTheme: themeDefaultMode !== "" && previewController.pendingMode !== themeDefaultMode

    SwitchRow {
        label: qsTr("Dark mode")
        checked: root.darkChecked
        onToggled: checked => {
            const mode = checked ? "dark" : "light";
            previewController.startModePreview(mode);
            previewController.stageModeApply(mode);
            previewController.commitPending();
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            hoverEnabled: true
            onEntered: previewController.startModePreview(root.darkChecked ? "dark" : "light")
        }
    }

    StyledText {
        visible: root.modeDivergesFromTheme
        text: qsTr("Differs from theme default (%1)").arg(root.themeDefaultMode)
        color: Colours.palette.m3outline
        font.pointSize: Appearance.font.size.small
    }
}
