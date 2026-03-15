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
    required property var previewController
    required property var session

    title: qsTr("Color scheme")
    description: qsTr("Available color schemes")
    showBackground: true

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.small / 2

        Repeater {
            model: Schemes.list

            delegate: StyledRect {
                required property var modelData

                Layout.fillWidth: true

                readonly property string schemeKey: `${modelData.name} ${modelData.flavour}`
                readonly property bool isCurrent: schemeKey === previewController.pendingSchemeKey

                color: Qt.alpha(Colours.tPalette.m3surfaceContainer, isCurrent ? Colours.tPalette.m3surfaceContainer.a : 0)
                radius: Appearance.rounding.normal
                border.width: isCurrent ? 1 : 0
                border.color: Colours.palette.m3primary

                StateLayer {
                    function onClicked(): void {
                        const name = modelData.name;
                        const flavour = modelData.flavour;
                        previewController.startSchemePreview(modelData);
                        previewController.stageSchemeApply(name, flavour);
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    hoverEnabled: true
                    onEntered: previewController.startSchemePreview(modelData)
                }

                RowLayout {
                    id: schemeRow

                    anchors.fill: parent
                    anchors.margins: Appearance.padding.normal

                    spacing: Appearance.spacing.normal

                    Row {
                        id: paletteDots

                        Layout.alignment: Qt.AlignVCenter
                        spacing: 4

                        readonly property var schemeColours: modelData.colours

                        Repeater {
                            model: ["primary", "secondary", "tertiary", "surface", "error", "onBackground"]

                            delegate: StyledRect {
                                required property string modelData

                                width: 12
                                height: 12
                                radius: Appearance.rounding.full
                                color: paletteDots.schemeColours?.[modelData] ? `#${paletteDots.schemeColours[modelData]}` : Colours.palette.m3surfaceContainerHigh
                                border.width: modelData === "surface" ? 1 : 0
                                border.color: Qt.alpha(Colours.palette.m3outline, 0.4)
                            }
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 0

                        StyledText {
                            text: modelData.flavour ?? ""
                            font.pointSize: Appearance.font.size.normal
                        }

                        StyledText {
                            text: modelData.name ?? ""
                            font.pointSize: Appearance.font.size.small
                            color: Colours.palette.m3outline

                            elide: Text.ElideRight
                            anchors.left: parent.left
                            anchors.right: parent.right
                        }
                    }

                    Loader {
                        active: isCurrent

                        sourceComponent: MaterialIcon {
                            text: "check"
                            color: Colours.palette.m3onSurfaceVariant
                            font.pointSize: Appearance.font.size.large
                        }
                    }
                }

                implicitHeight: schemeRow.implicitHeight + Appearance.padding.normal * 2
            }
        }
    }
}
