pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.utils
import qs.config
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

// Workspace card for the dashboard Workspaces tab.
//
// Shows workspace name, app icons (up to maxAppIcons), window count badge,
// and optional monitor badge. Clicking switches to the workspace and
// selects it for the detail panel.
Item {
    id: root

    required property HyprlandWorkspace modelData
    required property bool isSelected
    required property bool isActive

    signal clicked()

    readonly property int windowCount: root.modelData.lastIpcObject?.windows ?? 0
    readonly property var wsToplevels: Hypr.toplevels.values.filter(t => t.workspace?.id === root.modelData.id)
    readonly property string monitorName: {
        const mon = Hypr.monitors.values.find(m => m.activeWorkspace?.id === root.modelData.id);
        return mon?.name ?? "";
    }

    implicitWidth: 130
    implicitHeight: wsCard.implicitHeight

    StyledRect {
        id: wsCard

        anchors.fill: parent

        radius: Appearance.rounding.normal
        color: root.isActive
            ? Colours.tPalette.m3primaryContainer
            : root.isSelected
                ? Colours.tPalette.m3secondaryContainer
                : Colours.layer(Colours.tPalette.m3surfaceContainer, 1)
        border.width: root.isActive || root.isSelected ? 1 : 0
        border.color: root.isActive ? Colours.palette.m3primary : Colours.palette.m3secondary

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
            id: content

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Appearance.padding.normal

            spacing: Appearance.spacing.small / 2

            // Header: WS name + monitor badge + window count
            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small

                StyledText {
                    text: root.modelData.name
                    font.pointSize: Appearance.font.size.normal
                    font.weight: root.isActive ? 700 : 500
                    color: root.isActive
                        ? Colours.palette.m3onPrimaryContainer
                        : root.isSelected
                            ? Colours.palette.m3onSecondaryContainer
                            : Colours.palette.m3onSurface
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                // Monitor badge (only if multi-monitor and config enabled)
                StyledRect {
                    visible: root.monitorName !== "" && Config.dashboard.workspaces.showMonitorBadge && Hypr.monitors.values.length > 1
                    radius: Appearance.rounding.full
                    color: Qt.alpha(Colours.palette.m3outline, 0.15)
                    implicitWidth: monLabel.implicitWidth + Appearance.padding.small
                    implicitHeight: monLabel.implicitHeight + 2

                    StyledText {
                        id: monLabel
                        anchors.centerIn: parent
                        text: root.monitorName
                        font.pointSize: Appearance.font.size.small
                        color: root.isActive
                            ? Colours.palette.m3onPrimaryContainer
                            : Colours.palette.m3onSurfaceVariant
                    }
                }

                // Window count badge
                StyledRect {
                    visible: root.windowCount > 0
                    radius: Appearance.rounding.full
                    color: root.isActive
                        ? Qt.alpha(Colours.palette.m3onPrimaryContainer, 0.2)
                        : Colours.layer(Colours.tPalette.m3surfaceContainerHigh, 1)
                    implicitWidth: winCount.implicitWidth + Appearance.padding.small * 2
                    implicitHeight: winCount.implicitHeight + 2

                    StyledText {
                        id: winCount
                        anchors.centerIn: parent
                        text: root.windowCount
                        font.pointSize: Appearance.font.size.smaller
                        color: root.isActive
                            ? Colours.palette.m3onPrimaryContainer
                            : Colours.palette.m3onSurfaceVariant
                    }
                }
            }

            // App icons row (up to maxAppIcons)
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

                // Overflow indicator
                StyledText {
                    visible: root.wsToplevels.length > Config.dashboard.workspaces.maxAppIcons
                    text: qsTr("+%1").arg(root.wsToplevels.length - Config.dashboard.workspaces.maxAppIcons)
                    font.pointSize: Appearance.font.size.smaller
                    color: root.isActive
                        ? Colours.palette.m3onPrimaryContainer
                        : Colours.palette.m3outline
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Active check mark
            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                visible: root.isActive
                text: "check_circle"
                color: Colours.palette.m3onPrimaryContainer
                font.pointSize: Appearance.font.size.small
            }
        }
    }
}
