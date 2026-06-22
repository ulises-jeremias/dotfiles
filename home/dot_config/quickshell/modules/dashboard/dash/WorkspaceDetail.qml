pragma ComponentBehavior: Bound

import qs.components
import qs.components.containers
import qs.components.controls
import qs.services
import qs.config
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

// Detail panel for the selected workspace.
//
// Shows a live preview of the focused window (ScreencopyView),
// a scrollable list of windows with badges and actions,
// and a workspace action bar (rename / new / close-all).
Item {
    id: root

    required property int wsId
    required property HyprlandWorkspace workspace

    readonly property var wsToplevels: Hypr.toplevels.values.filter(t => t.workspace?.id === root.wsId)
    readonly property HyprlandToplevel focusedToplevel: {
        return root.wsToplevels.find(t => t.wayland?.activated) ?? root.wsToplevels[0] ?? null;
    }
    readonly property int windowCount: root.workspace?.lastIpcObject?.windows ?? 0
    readonly property string wsName: root.workspace?.name ?? qsTr("Workspace %1").arg(root.wsId)

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout

        anchors.fill: parent

        spacing: Appearance.spacing.normal

        // Header: workspace name + window count
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            StyledText {
                text: root.wsName
                font.pointSize: Appearance.font.size.larger
                font.weight: 600
                color: Colours.palette.m3primary
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            StyledText {
                text: root.windowCount === 0
                    ? qsTr("Empty")
                    : qsTr("%1 window(s)").arg(root.windowCount)
                font.pointSize: Appearance.font.size.small
                color: Colours.palette.m3outline
            }
        }

        // Live preview of the focused window
        Loader {
            id: previewLoader

            Layout.fillWidth: true
            Layout.preferredHeight: Config.dashboard.workspaces.previewHeight

            active: Config.dashboard.workspaces.showLivePreview && root.focusedToplevel !== null

            sourceComponent: StyledClippingRect {
                id: preview

                anchors.fill: parent
                radius: Appearance.rounding.normal
                color: Colours.tPalette.m3surfaceContainer

                ScreencopyView {
                    id: view

                    anchors.centerIn: parent

                    captureSource: root.focusedToplevel?.wayland ?? null
                    live: true

                    constraintSize.width: root.focusedToplevel
                        ? parent.height * Math.min(
                            Screen.width / Screen.height,
                            root.focusedToplevel?.lastIpcObject?.size?.[0] / root.focusedToplevel?.lastIpcObject?.size?.[1] ?? 1
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
                            color: Colours.palette.m3outline
                            font.pointSize: Appearance.font.size.extraLarge * 2
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("No windows to preview")
                            color: Colours.palette.m3outline
                            font.pointSize: Appearance.font.size.normal
                        }
                    }
                }
            }
        }

        // Window list
        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true

            radius: Appearance.rounding.normal
            color: Colours.layer(Colours.tPalette.m3surfaceContainer, 1)

            implicitHeight: winList.implicitHeight + Appearance.padding.normal * 2

            // Empty state
            Item {
                anchors.fill: parent
                visible: root.wsToplevels.length === 0

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Appearance.spacing.small

                    MaterialIcon {
                        Layout.alignment: Qt.AlignHCenter
                        text: "select_window_off"
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.extraLarge
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("No windows in this workspace")
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.normal
                    }
                }
            }

            StyledListView {
                id: winList

                anchors.fill: parent
                anchors.margins: Appearance.padding.normal

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

        // Workspace actions bar
        WsActionsBar {
            Layout.fillWidth: true
            wsId: root.wsId
        }
    }
}
