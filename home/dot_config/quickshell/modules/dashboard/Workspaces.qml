pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    // Minimum matches dashboard panel width — avoids circular dependency
    // with anchors.fill on the inner ColumnLayout
    implicitWidth: 800
    implicitHeight: layout.implicitHeight + Appearance.padding.large * 2

    readonly property var regularWorkspaces: {
        const all = Hypr.workspaces.values;
        return all.filter(w => !w.name.startsWith("special:")).sort((a, b) => a.id - b.id);
    }

    ColumnLayout {
        id: layout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.normal

        StyledText {
            text: qsTr("Workspaces")
            font.pointSize: Appearance.font.size.larger
            font.weight: 500
        }

        Flow {
            id: wsGrid
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            Repeater {
                model: root.regularWorkspaces

                Item {
                    id: wsItem
                    required property HyprlandWorkspace modelData
                    readonly property bool isActive: wsItem.modelData.id === Hypr.activeWsId
                    readonly property int windowCount: wsItem.modelData.lastIpcObject?.windows ?? 0

                    implicitWidth: wsCard.implicitWidth
                    implicitHeight: wsCard.implicitHeight

                    StyledRect {
                        id: wsCard
                        radius: Appearance.rounding.normal
                        color: wsItem.isActive
                            ? Colours.palette.m3primaryContainer
                            : Colours.layer(Colours.palette.m3surfaceContainer, 1)
                        implicitWidth: 120
                        implicitHeight: wsContent.implicitHeight + Appearance.padding.normal * 2

                        StateLayer {
                            color: wsItem.isActive
                                ? Colours.palette.m3onPrimaryContainer
                                : Colours.palette.m3onSurface
                            function onClicked() {
                                Hypr.dispatch(`workspace ${wsItem.modelData.id}`);
                            }
                        }

                        ColumnLayout {
                            id: wsContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: Appearance.padding.normal
                            spacing: Appearance.spacing.small / 2

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Appearance.spacing.small

                                StyledText {
                                    text: wsItem.modelData.name
                                    font.pointSize: Appearance.font.size.normal
                                    font.weight: wsItem.isActive ? 700 : 500
                                    color: wsItem.isActive
                                        ? Colours.palette.m3onPrimaryContainer
                                        : Colours.palette.m3onSurface
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                StyledRect {
                                    visible: wsItem.windowCount > 0
                                    radius: Appearance.rounding.full
                                    color: wsItem.isActive
                                        ? Qt.alpha(Colours.palette.m3onPrimaryContainer, 0.2)
                                        : Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)
                                    implicitWidth: winCount.implicitWidth + Appearance.padding.small * 2
                                    implicitHeight: winCount.implicitHeight + 2

                                    StyledText {
                                        id: winCount
                                        anchors.centerIn: parent
                                        text: wsItem.windowCount
                                        font.pointSize: Appearance.font.size.smaller
                                        color: wsItem.isActive
                                            ? Colours.palette.m3onPrimaryContainer
                                            : Colours.palette.m3onSurfaceVariant
                                    }
                                }
                            }

                            // Window indicators (dots for each window)
                            Row {
                                visible: wsItem.windowCount > 0 && wsItem.windowCount <= 8
                                spacing: 3

                                Repeater {
                                    model: Math.min(wsItem.windowCount, 8)
                                    Rectangle {
                                        width: 5
                                        height: 5
                                        radius: width / 2
                                        color: wsItem.isActive
                                            ? Colours.palette.m3onPrimaryContainer
                                            : Colours.palette.m3outline
                                        opacity: 0.7
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Empty state when no workspaces
            StyledText {
                visible: root.regularWorkspaces.length === 0
                text: qsTr("No workspaces open")
                color: Colours.palette.m3outline
                font.pointSize: Appearance.font.size.normal
            }
        }

        // Active workspace info
        StyledRect {
            Layout.fillWidth: true
            radius: Appearance.rounding.normal
            color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
            implicitHeight: activeInfo.implicitHeight + Appearance.padding.normal * 2
            visible: Hypr.focusedWorkspace !== null

            RowLayout {
                id: activeInfo
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: Appearance.padding.normal
                spacing: Appearance.spacing.normal

                MaterialIcon {
                    text: "monitor"
                    color: Colours.palette.m3primary
                    font.pointSize: Appearance.font.size.large
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    StyledText {
                        text: qsTr("Workspace %1").arg(Hypr.activeWsId)
                        font.pointSize: Appearance.font.size.normal
                        font.weight: 600
                        color: Colours.palette.m3primary
                    }

                    StyledText {
                        text: {
                            const ws = Hypr.workspaces.values.find(w => w.id === Hypr.activeWsId);
                            const n = ws?.lastIpcObject?.windows ?? 0;
                            return n === 0 ? qsTr("Empty") : qsTr("%1 window(s)").arg(n);
                        }
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.small
                    }
                }
            }
        }
    }
}
