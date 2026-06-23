pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.utils
import qs.config
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

// Workspace selector card — compact card for the bottom flow.
// Matches the visual style of forecast cards in Weather.qml.
Item {
    id: root

    required property HyprlandWorkspace modelData
    required property bool isSelected
    required property bool isActive

    signal clicked()

    readonly property int windowCount: root.modelData.lastIpcObject?.windows ?? 0
    readonly property var wsToplevels: Hypr.toplevels.values.filter(t => t.workspace?.id === root.modelData.id)

    implicitWidth: 150
    implicitHeight: card.implicitHeight

    StyledRect {
        id: card

        anchors.fill: parent

        radius: Appearance.rounding.normal
        color: root.isActive
            ? Colours.tPalette.m3primaryContainer
            : root.isSelected
                ? Colours.tPalette.m3secondaryContainer
                : Colours.tPalette.m3surfaceContainerHigh

        Behavior on color {
            ColorAnimation {
                duration: Appearance.anim.durations.small
            }
        }

        StateLayer {
            color: root.isActive
                ? Colours.palette.m3onPrimaryContainer
                : root.isSelected
                    ? Colours.palette.m3onSecondaryContainer
                    : Colours.palette.m3onSurface

            function onClicked(): void {
                root.clicked();
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Appearance.padding.normal

            spacing: Appearance.spacing.small / 2

            // Header: WS number + name
            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small

                StyledText {
                    text: root.modelData.id
                    font.pointSize: Appearance.font.size.normal
                    font.weight: 700
                    color: root.isActive
                        ? Colours.palette.m3onPrimaryContainer
                        : root.isSelected
                            ? Colours.palette.m3onSecondaryContainer
                            : Colours.palette.m3primary
                }

                StyledText {
                    Layout.fillWidth: true
                    text: root.modelData.name === String(root.modelData.id) ? "" : root.modelData.name
                    font.pointSize: Appearance.font.size.small
                    color: root.isActive
                        ? Colours.palette.m3onPrimaryContainer
                        : root.isSelected
                            ? Colours.palette.m3onSecondaryContainer
                            : Colours.palette.m3onSurfaceVariant
                    elide: Text.ElideRight
                    visible: text !== ""
                }

                // Window count
                StyledText {
                    text: root.windowCount > 0 ? String(root.windowCount) : ""
                    font.pointSize: Appearance.font.size.smaller
                    color: root.isActive
                        ? Colours.palette.m3onPrimaryContainer
                        : Colours.palette.m3onSurfaceVariant
                    visible: root.windowCount > 0
                }
            }

            // App icons
            Row {
                Layout.fillWidth: true
                spacing: 4

                Repeater {
                    model: Math.min(root.wsToplevels.length, Config.dashboard.workspaces.maxAppIcons)

                    MaterialIcon {
                        required property int index

                        text: Icons.getAppCategoryIcon(root.wsToplevels[index]?.lastIpcObject?.class ?? "", "terminal")
                        color: root.isActive
                            ? Colours.palette.m3onPrimaryContainer
                            : root.isSelected
                                ? Colours.palette.m3onSecondaryContainer
                                : Colours.palette.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.normal
                        opacity: 0.85
                    }
                }

                StyledText {
                    visible: root.wsToplevels.length > Config.dashboard.workspaces.maxAppIcons
                    text: qsTr("+%1").arg(root.wsToplevels.length - Config.dashboard.workspaces.maxAppIcons)
                    font.pointSize: Appearance.font.size.smaller
                    color: root.isActive
                        ? Colours.palette.m3onPrimaryContainer
                        : Colours.palette.m3onSurfaceVariant
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
