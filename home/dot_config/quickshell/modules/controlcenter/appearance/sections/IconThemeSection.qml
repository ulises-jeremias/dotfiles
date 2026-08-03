pragma ComponentBehavior: Bound

import ".."
import qs.components
import qs.components.controls
import qs.components.containers
import qs.services
import qs.config
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

CollapsibleSection {
    id: root

    required property var previewController
    required property var session

    title: qsTr("Icon theme")
    description: qsTr("Desktop icon set — staged until Apply")
    showBackground: true

    property var iconNames: []

    function reloadIcons(): void {
        listProc.running = true;
    }

    Component.onCompleted: reloadIcons()

    Process {
        id: listProc

        command: ["dots-gtk-theme", "-q", "-p", "icons"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.iconNames = text.split("\n").map(line => line.trim()).filter(line => line.length > 0);
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.small / 2

        Repeater {
            model: root.iconNames

            delegate: StyledRect {
                required property string modelData

                Layout.fillWidth: true

                readonly property bool isCurrent: modelData === previewController.pendingIconTheme

                color: Qt.alpha(Colours.tPalette.m3surfaceContainer, isCurrent ? Colours.tPalette.m3surfaceContainer.a : 0)
                radius: Appearance.rounding.normal
                border.width: isCurrent ? 1 : 0
                border.color: Colours.palette.m3primary

                StateLayer {
                    function onClicked(): void {
                        previewController.stageIconTheme(modelData);
                    }
                }

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Appearance.padding.normal

                    StyledText {
                        Layout.fillWidth: true
                        text: modelData
                        font.pointSize: Appearance.font.size.normal
                    }

                    MaterialIcon {
                        visible: isCurrent
                        text: "check"
                        color: Colours.palette.m3primary
                        font.pointSize: Appearance.font.size.large
                    }
                }

                implicitHeight: Appearance.padding.normal * 2 + Appearance.font.size.normal * 1.4
            }
        }
    }
}
