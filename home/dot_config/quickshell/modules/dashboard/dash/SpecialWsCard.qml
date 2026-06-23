pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.utils
import qs.config
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

// Special workspace chip — compact pill for the workspace flow header.
Item {
    id: root

    required property HyprlandWorkspace modelData
    required property bool isActive

    signal clicked()

    readonly property int windowCount: root.modelData.lastIpcObject?.windows ?? 0
    readonly property string iconName: Icons.getSpecialWsIcon(root.modelData.name)
    readonly property string displayName: root.modelData.name.slice("special:".length)

    implicitWidth: chip.implicitWidth
    implicitHeight: chip.implicitHeight

    StyledRect {
        id: chip

        radius: Appearance.rounding.full
        color: root.isActive
            ? Colours.tPalette.m3tertiaryContainer
            : Colours.tPalette.m3surfaceContainerHigh

        implicitWidth: content.implicitWidth + Appearance.padding.normal * 2
        implicitHeight: content.implicitHeight + Appearance.padding.small

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
            id: content

            anchors.centerIn: parent

            spacing: Appearance.spacing.small / 2

            // Icon
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
                        font.pointSize: Appearance.font.size.normal
                    }
                }

                Component {
                    id: letterComp

                    StyledText {
                        text: root.iconName
                        color: root.isActive
                            ? Colours.palette.m3onTertiaryContainer
                            : Colours.palette.m3tertiary
                        font.pointSize: Appearance.font.size.small
                        font.weight: 600
                    }
                }
            }

            // Name
            StyledText {
                text: root.displayName
                font.pointSize: Appearance.font.size.small
                font.weight: root.isActive ? 600 : 400
                color: root.isActive
                    ? Colours.palette.m3onTertiaryContainer
                    : Colours.palette.m3onSurfaceVariant
            }

            // Window count
            StyledRect {
                visible: root.windowCount > 0
                radius: Appearance.rounding.full
                color: Qt.alpha(Colours.palette.m3onTertiaryContainer, 0.2)
                implicitWidth: wcText.implicitWidth + 6
                implicitHeight: wcText.implicitHeight + 2

                StyledText {
                    id: wcText
                    anchors.centerIn: parent
                    text: root.windowCount
                    font.pointSize: Appearance.font.size.smaller
                    color: root.isActive
                        ? Colours.palette.m3onTertiaryContainer
                        : Colours.palette.m3onSurfaceVariant
                }
            }
        }
    }
}
