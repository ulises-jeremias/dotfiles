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

// Dashboard Workspaces tab — split pane workspace manager.
//
// Left pane: scrollable flow of workspace cards + special workspaces section.
// Right pane: detail panel for the selected workspace (live preview, window list, actions).
// Bottom: status bar with monitor + window summary.
Item {
    id: root

    // Minimum matches dashboard panel width — avoids circular dependency
    implicitWidth: 800
    implicitHeight: layout.implicitHeight + Appearance.padding.large * 2

    // Selection state — independent from the active workspace.
    // Clicking a card switches the active WS AND selects it for the detail panel.
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

    readonly property int totalWindows: {
        return root.regularWorkspaces.reduce((acc, ws) => acc + (ws.lastIpcObject?.windows ?? 0), 0);
    }

    readonly property int floatingCount: {
        return Hypr.toplevels.values.filter(t =>
            t.workspace?.id === root.selectedWsId && t.lastIpcObject?.floating
        ).length;
    }

    // Reset selection to active when tab reopens
    Component.onCompleted: root.selectedWsId = Hypr.activeWsId

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Appearance.padding.large

        spacing: Appearance.spacing.normal

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.normal

            StyledText {
                text: qsTr("Workspaces")
                font.pointSize: Appearance.font.size.larger
                font.weight: 500
                Layout.fillWidth: true
            }

            // Status summary
            StyledText {
                text: qsTr("%1 windows · %2 floating").arg(root.totalWindows).arg(root.floatingCount)
                font.pointSize: Appearance.font.size.small
                color: Colours.palette.m3outline
            }
        }

        // Main split: left cards + right detail
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: Appearance.spacing.normal

            // ── Left pane: workspace cards ──────────────────────────────
            ColumnLayout {
                Layout.fillHeight: true
                Layout.preferredWidth: 340

                spacing: Appearance.spacing.small

                // Regular workspaces — scrollable flow
                StyledRect {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    radius: Appearance.rounding.normal
                    color: Colours.layer(Colours.tPalette.m3surfaceContainer, 1)

                    StyledFlickable {
                        id: wsFlick

                        anchors.fill: parent
                        anchors.margins: Appearance.padding.normal

                        flickableDirection: Flickable.VerticalFlick
                        contentHeight: wsFlow.implicitHeight
                        clip: true

                        Flow {
                            id: wsFlow

                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top

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
                                color: Colours.palette.m3outline
                                font.pointSize: Appearance.font.size.normal
                            }
                        }

                        StyledScrollBar.vertical: StyledScrollBar {
                            flickable: wsFlick
                        }
                    }
                }

                // Special workspaces section
                Loader {
                    Layout.fillWidth: true
                    active: Config.dashboard.workspaces.showSpecialWorkspaces && root.specialWorkspaces.length > 0

                    sourceComponent: ColumnLayout {
                        spacing: Appearance.spacing.small

                        StyledText {
                            text: qsTr("Special Workspaces")
                            font.pointSize: Appearance.font.size.normal
                            font.weight: 600
                            color: Colours.palette.m3tertiary
                        }

                        Flow {
                            Layout.fillWidth: true
                            spacing: Appearance.spacing.small

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
                }
            }

            // ── Right pane: workspace detail ────────────────────────────
            StyledRect {
                Layout.fillHeight: true
                Layout.fillWidth: true

                radius: Appearance.rounding.normal
                color: Colours.layer(Colours.tPalette.m3surfaceContainer, 1)

                Loader {
                    id: detailLoader

                    anchors.fill: parent
                    anchors.margins: Appearance.padding.normal

                    active: root.selectedWorkspace !== null

                    sourceComponent: WorkspaceDetail {
                        wsId: root.selectedWsId
                        workspace: root.selectedWorkspace
                    }
                }

                // Empty state when no workspace selected
                Item {
                    anchors.fill: parent
                    visible: root.selectedWorkspace === null

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Appearance.spacing.small

                        MaterialIcon {
                            Layout.alignment: Qt.AlignHCenter
                            text: "workspaces"
                            color: Colours.palette.m3outline
                            font.pointSize: Appearance.font.size.extraLarge * 2
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("Select a workspace")
                            color: Colours.palette.m3outline
                            font.pointSize: Appearance.font.size.normal
                        }
                    }
                }
            }
        }

        // ── Bottom status bar ──────────────────────────────────────────
        StyledRect {
            Layout.fillWidth: true
            radius: Appearance.rounding.normal
            color: Colours.layer(Colours.tPalette.m3surfaceContainer, 1)
            implicitHeight: statusRow.implicitHeight + Appearance.padding.small * 2

            RowLayout {
                id: statusRow

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: Appearance.padding.normal

                spacing: Appearance.spacing.normal

                MaterialIcon {
                    text: "monitor"
                    color: Colours.palette.m3primary
                    font.pointSize: Appearance.font.size.normal
                }

                StyledText {
                    text: {
                        const mon = Hypr.focusedMonitor;
                        if (mon)
                            return qsTr("Monitor: %1 · Active: WS %2").arg(mon.name).arg(Hypr.activeWsId);
                        return qsTr("Active: WS %1").arg(Hypr.activeWsId);
                    }
                    font.pointSize: Appearance.font.size.small
                    color: Colours.palette.m3onSurfaceVariant
                    Layout.fillWidth: true
                }

                // Monitor count badge (multi-monitor)
                StyledRect {
                    visible: Hypr.monitors.values.length > 1
                    radius: Appearance.rounding.full
                    color: Qt.alpha(Colours.palette.m3primary, 0.15)
                    implicitWidth: monCount.implicitWidth + Appearance.padding.small * 2
                    implicitHeight: monCount.implicitHeight + 2

                    StyledText {
                        id: monCount
                        anchors.centerIn: parent
                        text: qsTr("%1 monitors").arg(Hypr.monitors.values.length)
                        font.pointSize: Appearance.font.size.small
                        color: Colours.palette.m3primary
                    }
                }
            }
        }
    }
}
