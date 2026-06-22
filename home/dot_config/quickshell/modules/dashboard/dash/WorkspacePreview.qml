pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.utils
import qs.config
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

// Live preview of the focused window in a workspace.
// Uses ScreencopyView — same pattern as WindowInfo/Preview.qml.
Item {
    id: root

    required property int wsId

    readonly property var wsToplevels: Hypr.toplevels.values.filter(t => t.workspace?.id === root.wsId)
    readonly property HyprlandToplevel focusedToplevel: {
        return root.wsToplevels.find(t => t.wayland?.activated) ?? root.wsToplevels[0] ?? null;
    }

    implicitWidth: parent ? parent.width : 400
    implicitHeight: Config.dashboard.workspaces.previewHeight

    StyledClippingRect {
        id: preview

        anchors.fill: parent
        radius: Appearance.rounding.normal
        color: Colours.tPalette.m3surfaceContainerHigh

        ScreencopyView {
            id: view

            anchors.centerIn: parent

            captureSource: root.focusedToplevel?.wayland ?? null
            live: true

            constraintSize.width: root.focusedToplevel
                ? parent.height * Math.min(
                    Screen.width / Screen.height,
                    (root.focusedToplevel?.lastIpcObject?.size?.[0] ?? 1) / (root.focusedToplevel?.lastIpcObject?.size?.[1] ?? 1)
                )
                : parent.width
            constraintSize.height: parent.height
        }

        // Empty state
        Item {
            anchors.fill: parent
            visible: root.focusedToplevel === null

            ColumnLayout {
                anchors.centerIn: parent
                spacing: Appearance.spacing.small

                MaterialIcon {
                    Layout.alignment: Qt.AlignHCenter
                    text: "image_not_supported"
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.extraLarge * 2
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("No windows to preview")
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.normal
                }
            }
        }
    }
}
