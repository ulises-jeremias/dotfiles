pragma ComponentBehavior: Bound

import ".."
import "../../../launcher/services"
import qs.components
import qs.components.controls
import qs.components.containers
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

CollapsibleSection {
    id: root

    required property var previewController
    required property var session

    title: qsTr("GTK color scheme")
    description: qsTr("Libadwaita / portals — independent from Theme mode. Auto lets apps decide.")
    showBackground: true

    readonly property var schemeOptions: [
        {
            id: "follow",
            icon: "sync",
            name: qsTr("Follow theme mode")
        },
        {
            id: "default",
            icon: "contrast",
            name: qsTr("Auto (apps decide)")
        },
        {
            id: "prefer-light",
            icon: "light_mode",
            name: qsTr("Prefer light")
        },
        {
            id: "prefer-dark",
            icon: "dark_mode",
            name: qsTr("Prefer dark")
        }
    ]

    readonly property string themeDefaultScheme: {
        const id = previewController.pendingThemeId;
        if (!id)
            return "";
        const theme = Themes.themeById(id);
        if (!theme)
            return "";
        return theme.gtkColorScheme || "";
    }

    readonly property bool schemeDivergesFromTheme: themeDefaultScheme !== "" && previewController.pendingGtkColorScheme !== themeDefaultScheme

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.small / 2

        Repeater {
            model: root.schemeOptions

            delegate: StyledRect {
                required property var modelData

                Layout.fillWidth: true

                readonly property bool isCurrent: modelData.id === previewController.pendingGtkColorScheme

                color: Qt.alpha(Colours.tPalette.m3surfaceContainer, isCurrent ? Colours.tPalette.m3surfaceContainer.a : 0)
                radius: Appearance.rounding.normal
                border.width: isCurrent ? 1 : 0
                border.color: Colours.palette.m3primary

                StateLayer {
                    function onClicked(): void {
                        previewController.startGtkColorSchemePreview(modelData.id);
                        previewController.stageGtkColorScheme(modelData.id);
                        previewController.commitPending();
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    hoverEnabled: true
                    onEntered: previewController.startGtkColorSchemePreview(modelData.id)
                }

                RowLayout {
                    id: schemeRow

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Appearance.padding.normal

                    spacing: Appearance.spacing.normal

                    MaterialIcon {
                        text: modelData.icon
                        font.pointSize: Appearance.font.size.large
                        fill: isCurrent ? 1 : 0
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: modelData.name
                        font.weight: isCurrent ? 500 : 400
                    }

                    MaterialIcon {
                        visible: isCurrent
                        text: "check"
                        color: Colours.palette.m3primary
                        font.pointSize: Appearance.font.size.large
                    }
                }

                implicitHeight: schemeRow.implicitHeight + Appearance.padding.normal * 2
            }
        }

        StyledText {
            visible: root.schemeDivergesFromTheme
            text: qsTr("Differs from theme default (%1)").arg(root.themeDefaultScheme)
            color: Colours.palette.m3outline
            font.pointSize: Appearance.font.size.small
        }
    }
}
