pragma ComponentBehavior: Bound

import qs.components
import qs.components.containers
import qs.components.controls
import qs.services
import qs.config
import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

// Window list panel — sits inside a surfaceContainer card.
// No background of its own (parent provides the card background).
Item {
    id: root

    required property int wsId
    required property HyprlandWorkspace workspace

    readonly property var wsToplevels: Hypr.toplevels.values.filter(t => t.workspace?.id === root.wsId)

    implicitWidth: parent ? parent.width : 300
    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: Appearance.padding.large

        spacing: Appearance.spacing.normal

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            MaterialIcon {
                text: "select_window"
                color: Colours.palette.m3secondary
                font.pointSize: Appearance.font.size.large
            }

            StyledText {
                text: qsTr("Windows")
                font.pointSize: Appearance.font.size.normal
                font.weight: 600
                color: Colours.palette.m3onSurface
                Layout.fillWidth: true
            }

            StyledText {
                text: root.wsToplevels.length > 0
                    ? qsTr("%1").arg(root.wsToplevels.length)
                    : ""
                font.pointSize: Appearance.font.size.small
                color: Colours.palette.m3onSurfaceVariant
                visible: root.wsToplevels.length > 0
            }
        }

        // Window list or empty state
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Empty state
            ColumnLayout {
                anchors.centerIn: parent
                visible: root.wsToplevels.length === 0
                spacing: Appearance.spacing.small

                MaterialIcon {
                    Layout.alignment: Qt.AlignHCenter
                    text: "select_window_off"
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.extraLarge
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("No windows")
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.small
                }
            }

            // Window list
            StyledListView {
                id: winList

                anchors.fill: parent
                visible: root.wsToplevels.length > 0

                spacing: Appearance.spacing.small / 2
                clip: true

                model: ScriptModel {
                    values: root.wsToplevels
                }

                delegate: WindowListItem {
                    width: winList.width
                    isActive: modelData.wayland?.activated ?? false

                    onFocusRequested: {
                        Hypr.dispatch(`focuswindow address:0x${modelData.address}`);
                    }
                }

                StyledScrollBar.vertical: StyledScrollBar {
                    flickable: winList
                }
            }
        }
    }
}
