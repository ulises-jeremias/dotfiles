pragma ComponentBehavior: Bound

import ".."
import "../components"
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.services
import qs.config
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Session session

    anchors.fill: parent

    function runTool(command: var): void {
        if (Array.isArray(command) && command.length > 0)
            Quickshell.execDetached(command);
    }

    component ActionTile: StyledRect {
        id: tile
        required property string icon
        required property string title
        required property string subtitle
        required property var action

        Layout.fillWidth: true
        radius: Appearance.rounding.normal
        color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)
        implicitHeight: actionRow.implicitHeight + Appearance.padding.normal * 2

        RowLayout {
            id: actionRow
            anchors.fill: parent
            anchors.margins: Appearance.padding.normal
            spacing: Appearance.spacing.normal

            StyledRect {
                radius: Appearance.rounding.normal
                color: Colours.layer(Colours.palette.m3primaryContainer, 2)
                implicitWidth: 36
                implicitHeight: 36

                MaterialIcon {
                    anchors.centerIn: parent
                    text: tile.icon
                    color: Colours.palette.m3onPrimaryContainer
                    font.pointSize: Appearance.font.size.large
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    text: tile.title
                    font.pointSize: Appearance.font.size.normal
                    font.weight: 600
                }

                StyledText {
                    text: tile.subtitle
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.smaller
                    elide: Text.ElideRight
                }
            }

            TextButton {
                text: qsTr("Open")
                type: TextButton.Tonal
                onClicked: tile.action()
            }
        }
    }

    ClippingRectangle {
        id: clipRect
        anchors.fill: parent
        anchors.margins: Appearance.padding.normal
        anchors.leftMargin: 0
        anchors.rightMargin: Appearance.padding.normal
        radius: border.innerRadius
        color: "transparent"

        StyledFlickable {
            id: flick
            anchors.fill: parent
            anchors.margins: Appearance.padding.large + Appearance.padding.normal
            anchors.leftMargin: Appearance.padding.large
            anchors.rightMargin: Appearance.padding.large
            flickableDirection: Flickable.VerticalFlick
            contentHeight: content.implicitHeight

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: flick
            }

            ColumnLayout {
                id: content
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: Appearance.spacing.normal

                RowLayout {
                    spacing: Appearance.spacing.smaller
                    StyledText {
                        text: qsTr("System")
                        font.pointSize: Appearance.font.size.large
                        font.weight: 500
                    }
                }

                StyledRect {
                    Layout.fillWidth: true
                    radius: Appearance.rounding.normal
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
                    implicitHeight: introContent.implicitHeight + Appearance.padding.large * 2

                    ColumnLayout {
                        id: introContent
                        anchors.fill: parent
                        anchors.margins: Appearance.padding.large
                        spacing: Appearance.spacing.smaller

                        RowLayout {
                            spacing: Appearance.spacing.small
                            MaterialIcon {
                                text: "build"
                                font.pointSize: Appearance.font.size.large
                            }
                            StyledText {
                                text: qsTr("System Tools")
                                font.pointSize: Appearance.font.size.normal
                                font.weight: 600
                            }
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: qsTr("Fast access to monitor, power-profile and shortcuts utilities without leaving Control Center.")
                            color: Colours.palette.m3onSurfaceVariant
                            wrapMode: Text.Wrap
                            font.pointSize: Appearance.font.size.smaller
                        }
                    }
                }

                StyledRect {
                    Layout.fillWidth: true
                    radius: Appearance.rounding.normal
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
                    implicitHeight: toolsColumn.implicitHeight + Appearance.padding.large * 2

                    ColumnLayout {
                        id: toolsColumn
                        anchors.fill: parent
                        anchors.margins: Appearance.padding.large
                        spacing: Appearance.spacing.small

                        StyledText {
                            text: qsTr("Actions")
                            font.pointSize: Appearance.font.size.normal
                            font.weight: 500
                        }

                        ActionTile {
                            icon: "monitor"
                            title: qsTr("Monitor layout")
                            subtitle: qsTr("Open monitor layout tool")
                            action: () => root.runTool(["env", "DOTS_BYPASS_QUICKSHELL=1", "dots-hypr-monitors"])
                        }

                        ActionTile {
                            icon: "battery_charging_full"
                            title: qsTr("Performance profile")
                            subtitle: qsTr("Change power profile quickly")
                            action: () => root.runTool(["env", "DOTS_BYPASS_QUICKSHELL=1", "dots-performance-mode"])
                        }

                        ActionTile {
                            icon: "keyboard"
                            title: qsTr("Keyboard shortcuts help")
                            subtitle: qsTr("Open current keybinding reference")
                            action: () => root.runTool(["env", "DOTS_BYPASS_QUICKSHELL=1", "dots-keyboard-help"])
                        }
                    }
                }

                StyledRect {
                    Layout.fillWidth: true
                    radius: Appearance.rounding.normal
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
                    implicitHeight: navButtons.implicitHeight + Appearance.padding.large * 2

                    ColumnLayout {
                        id: navButtons
                        anchors.fill: parent
                        anchors.margins: Appearance.padding.large
                        spacing: Appearance.spacing.small

                        StyledText {
                            text: qsTr("Navigate")
                            font.pointSize: Appearance.font.size.normal
                            font.weight: 500
                        }

                        TextButton {
                            Layout.fillWidth: true
                            text: qsTr("Open Appearance pane")
                            onClicked: root.session.active = "appearance"
                        }

                        TextButton {
                            Layout.fillWidth: true
                            text: qsTr("Open Launcher pane")
                            onClicked: root.session.active = "launcher"
                        }

                        TextButton {
                            Layout.fillWidth: true
                            text: qsTr("Open Dashboard pane")
                            onClicked: root.session.active = "dashboard"
                        }
                    }
                }
            }
        }
    }

    InnerBorder {
        id: border
        leftThickness: 0
        rightThickness: Appearance.padding.normal
    }
}
