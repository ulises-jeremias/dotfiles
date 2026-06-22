pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.utils
import qs.config
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

// Special workspace card for the dashboard Workspaces tab.
//
// Shows the special workspace icon, name, and window count.
// Clicking toggles the special workspace.
Item {
    id: root

    required property HyprlandWorkspace modelData
    required property bool isActive

    signal clicked()

    readonly property int windowCount: root.modelData.lastIpcObject?.windows ?? 0
    readonly property string iconName: Icons.getSpecialWsIcon(root.modelData.name)
    readonly property string displayName: root.modelData.name.slice("special:".length)

    implicitWidth: 130
    implicitHeight: wsCard.implicitHeight

    StyledRect {
        id: wsCard

        anchors.fill: parent

        radius: Appearance.rounding.normal
        color: root.isActive
            ? Colours.tPalette.m3tertiaryContainer
            : Colours.layer(Colours.tPalette.m3surfaceContainer, 1)
        border.width: root.isActive ? 1 : 0
        border.color: Colours.palette.m3tertiary

        Behavior on color {
            ColorAnimation {
                duration: Appearance.anim.durations.small
            }
        }

        StateLayer {
            color: root.isActive
                ? Colours.palette.m3onTertiaryContainer
                : Colours.palette.m3onSurface

            function onClicked(): void {
                root.clicked();
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: Appearance.padding.normal

            spacing: Appearance.spacing.small

            // Icon or letter
            Loader {
                Layout.alignment: Qt.AlignVCenter
                sourceComponent: root.iconName.length === 1 ? letterComp : iconComp

                Component {
                    id: iconComp

                    MaterialIcon {
                        text: root.iconName
                        color: root.isActive
                            ? Colours.palette.m3onTertiaryContainer
                            : Colours.palette.m3tertiary
                        font.pointSize: Appearance.font.size.large
                    }
                }

                Component {
                    id: letterComp

                    StyledText {
                        text: root.iconName
                        color: root.isActive
                            ? Colours.palette.m3onTertiaryContainer
                            : Colours.palette.m3tertiary
                        font.pointSize: Appearance.font.size.normal
                        font.weight: 600
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: root.displayName
                    font.pointSize: Appearance.font.size.normal
                    font.weight: root.isActive ? 700 : 500
                    color: root.isActive
                        ? Colours.palette.m3onTertiaryContainer
                        : Colours.palette.m3onSurface
                    elide: Text.ElideRight
                }

                StyledText {
                    text: root.windowCount > 0
                        ? qsTr("%1 window(s)").arg(root.windowCount)
                        : qsTr("Empty")
                    font.pointSize: Appearance.font.size.small
                    color: root.isActive
                        ? Colours.palette.m3onTertiaryContainer
                        : Colours.palette.m3outline
                }
            }
        }
    }
}
