pragma ComponentBehavior: Bound

import qs.components
import qs.components.containers
import qs.components.controls
import qs.services
import qs.config
import "dash"
import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

// Dashboard Workspaces tab — matches the visual language of Dash.qml
// and Performance.qml (GridLayout, surfaceContainer cards, rounding.large).
//
// Top row: active workspace preview card (left) + window list card (right).
// Bottom row: workspace selector cards in a flow + special workspaces.
Item {
    id: root

    property int selectedWsId: Hypr.activeWsId

    readonly property var regularWorkspaces: {
        const all = Hypr.workspaces.values;
        return all.filter(w => !w.name.startsWith("special:")).sort((a, b) => a.id - b.id);
    }

    readonly property var specialWorkspaces: {
        return Hypr.workspaces.values.filter(w => w.name.startsWith("special:"));
    }

    readonly property HyprlandWorkspace selectedWorkspace: {
        return Hypr.workspaces.values.find(w => w.id === root.selectedWsId) ?? null;
    }

    readonly property string activeSpecialName: Hypr.focusedMonitor?.lastIpcObject?.specialWorkspace?.name ?? ""

    Component.onCompleted: root.selectedWsId = Hypr.activeWsId

    implicitWidth: Math.max(800, content.implicitWidth)
    implicitHeight: content.implicitHeight

    ColumnLayout {
        id: content

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        spacing: Appearance.spacing.normal

        // ── Top row: preview + window list ────────────────────────────
        RowLayout {
            Layout.fillWidth: true

            spacing: Appearance.spacing.normal

            // Left: active/selected workspace preview + actions
            StyledRect {
                Layout.fillWidth: true
                Layout.minimumWidth: 400
                Layout.preferredHeight: previewCol.implicitHeight + Appearance.padding.large * 2

                radius: Appearance.rounding.large
                color: Colours.tPalette.m3surfaceContainer

                ColumnLayout {
                    id: previewCol

                    anchors.fill: parent
                    anchors.margins: Appearance.padding.large

                    spacing: Appearance.spacing.normal

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Appearance.spacing.small

                        MaterialIcon {
                            text: "workspaces"
                            color: Colours.palette.m3primary
                            font.pointSize: Appearance.font.size.large
                        }

                        StyledText {
                            text: root.selectedWorkspace?.name ?? qsTr("Workspace %1").arg(root.selectedWsId)
                            font.pointSize: Appearance.font.size.larger
                            font.weight: 600
                            color: Colours.palette.m3onSurface
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        StyledText {
                            text: {
                                const n = root.selectedWorkspace?.lastIpcObject?.windows ?? 0;
                                return n === 0 ? qsTr("Empty") : qsTr("%1 windows").arg(n);
                            }
                            font.pointSize: Appearance.font.size.small
                            color: Colours.palette.m3onSurfaceVariant
                        }
                    }

                    // Live preview
                    Loader {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Config.dashboard.workspaces.previewHeight

                        active: Config.dashboard.workspaces.showLivePreview && root.selectedWorkspace !== null

                        sourceComponent: WorkspacePreview {
                            wsId: root.selectedWsId
                        }
                    }

                    // Actions bar
                    WsActionsBar {
                        Layout.fillWidth: true
                        wsId: root.selectedWsId
                    }
                }
            }

            // Right: window list
            StyledRect {
                Layout.fillWidth: true
                Layout.minimumWidth: 300
                Layout.preferredHeight: previewCol.implicitHeight + Appearance.padding.large * 2

                radius: Appearance.rounding.large
                color: Colours.tPalette.m3surfaceContainer

                WorkspaceDetail {
                    anchors.fill: parent
                    wsId: root.selectedWsId
                    workspace: root.selectedWorkspace
                }
            }
        }

        // ── Bottom: workspace selector cards ──────────────────────────
        StyledRect {
            Layout.fillWidth: true
            Layout.preferredHeight: wsFlowCol.implicitHeight + Appearance.padding.large * 2

            radius: Appearance.rounding.large
            color: Colours.tPalette.m3surfaceContainer

            ColumnLayout {
                id: wsFlowCol

                anchors.fill: parent
                anchors.margins: Appearance.padding.large

                spacing: Appearance.spacing.normal

                // Section header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.small

                    StyledText {
                        text: qsTr("Workspaces")
                        font.pointSize: Appearance.font.size.normal
                        font.weight: 600
                        color: Colours.palette.m3onSurface
                        Layout.fillWidth: true
                    }

                    // Special workspace chips
                    Row {
                        visible: Config.dashboard.workspaces.showSpecialWorkspaces && root.specialWorkspaces.length > 0
                        spacing: Appearance.spacing.small / 2

                        Repeater {
                            model: root.specialWorkspaces

                            delegate: SpecialWsCard {
                                isActive: modelData.name === root.activeSpecialName

                                onClicked: {
                                    Hypr.dispatch(`togglespecialworkspace ${modelData.name.slice("special:".length)}`);
                                }
                            }
                        }
                    }
                }

                // Workspace cards flow
                Flow {
                    Layout.fillWidth: true

                    spacing: Appearance.spacing.small

                    Repeater {
                        model: root.regularWorkspaces

                        delegate: WorkspaceCard {
                            isActive: modelData.id === Hypr.activeWsId
                            isSelected: modelData.id === root.selectedWsId

                            onClicked: {
                                root.selectedWsId = modelData.id;
                                Hypr.dispatch(`workspace ${modelData.id}`);
                            }
                        }
                    }

                    // Empty state
                    StyledText {
                        visible: root.regularWorkspaces.length === 0
                        text: qsTr("No workspaces open")
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.normal
                    }
                }
            }
        }
    }
}
