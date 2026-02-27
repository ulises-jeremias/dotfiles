pragma ComponentBehavior: Bound

import ".."
import "../../../launcher/services"
import qs.components
import qs.components.controls
import qs.components.containers
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Layouts

CollapsibleSection {
    title: qsTr("Appearances")
    description: qsTr("Apply full desktop appearance presets")
    showBackground: true

    Component.onCompleted: Appearances.reload()

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.small / 2

        Repeater {
            model: Appearances.list

            delegate: StyledRect {
                required property var modelData

                Layout.fillWidth: true

                readonly property bool isCurrent: modelData.id === Appearances.currentId

                color: Qt.alpha(Colours.tPalette.m3surfaceContainer, isCurrent ? Colours.tPalette.m3surfaceContainer.a : 0)
                radius: Appearance.rounding.normal
                border.width: isCurrent ? 1 : 0
                border.color: Colours.palette.m3primary

                StateLayer {
                    function onClicked(): void {
                        const appearanceId = modelData.id;
                        Appearances.currentId = appearanceId;
                        Quickshell.execDetached(["dots-appearance", "apply", appearanceId]);
                        Qt.callLater(() => {
                            Appearances.reload();
                            Schemes.reload();
                        });
                    }
                }

                RowLayout {
                    id: appearanceRow

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Appearance.padding.normal

                    spacing: Appearance.spacing.normal

                    MaterialIcon {
                        text: Appearances.styleIcon(modelData.style || "")
                        font.pointSize: Appearance.font.size.large
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 0

                        StyledText {
                            text: modelData.name ?? modelData.id ?? ""
                            font.pointSize: Appearance.font.size.normal
                        }

                        StyledText {
                            text: modelData.style ?? modelData.description ?? ""
                            font.pointSize: Appearance.font.size.small
                            color: Colours.palette.m3outline

                            elide: Text.ElideRight
                            anchors.left: parent.left
                            anchors.right: parent.right
                        }
                    }

                    MaterialIcon {
                        visible: isCurrent
                        text: "check"
                        color: Colours.palette.m3primary
                        font.pointSize: Appearance.font.size.large
                    }
                }

                implicitHeight: appearanceRow.implicitHeight + Appearance.padding.normal * 2
            }
        }
    }
}
