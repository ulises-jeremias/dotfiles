pragma ComponentBehavior: Bound

import ".."
import "../../../launcher/services"
import qs.components
import qs.components.controls
import qs.components.containers
import qs.components.images
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Layouts

CollapsibleSection {
    id: sectionRoot

    required property var previewController
    required property var session

    title: qsTr("Appearances")
    description: qsTr("Apply full desktop appearance presets")
    showBackground: true

    property string selectedRiceId: ""

    Component.onCompleted: Appearances.reload()

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.small / 2

        Repeater {
            model: Appearances.list

            delegate: ColumnLayout {
                id: riceItem

                required property var modelData

                Layout.fillWidth: true
                spacing: 0

                readonly property bool isCurrent: modelData.id === previewController.pendingAppearanceId
                readonly property bool isExpanded: modelData.id === sectionRoot.selectedRiceId

                StyledRect {
                    Layout.fillWidth: true

                    color: Qt.alpha(Colours.tPalette.m3surfaceContainer, riceItem.isCurrent ? Colours.tPalette.m3surfaceContainer.a : 0)
                    radius: Appearance.rounding.normal
                    border.width: riceItem.isCurrent ? 1 : 0
                    border.color: Colours.palette.m3primary

                    StateLayer {
                        function onClicked(): void {
                            sectionRoot.selectedRiceId = riceItem.modelData.id;
                            previewController.stageAppearanceApply(riceItem.modelData.id);
                            previewController.startAppearancePreview(riceItem.modelData);
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        hoverEnabled: true
                        onEntered: previewController.startAppearancePreview(riceItem.modelData)
                    }

                    RowLayout {
                        id: appearanceRow

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: Appearance.padding.normal

                        spacing: Appearance.spacing.normal

                        Loader {
                            active: (modelData.preview ?? "") !== ""
                            Layout.alignment: Qt.AlignVCenter

                            sourceComponent: StyledClippingRect {
                                implicitWidth: 56
                                implicitHeight: 32
                                radius: Appearance.rounding.small
                                color: Colours.tPalette.m3surfaceContainer

                                CachingImage {
                                    anchors.fill: parent
                                    path: modelData.preview ?? ""
                                    cache: true
                                }
                            }
                        }

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
                            visible: riceItem.isCurrent
                            text: "check"
                            color: Colours.palette.m3primary
                            font.pointSize: Appearance.font.size.large
                        }
                    }

                    implicitHeight: appearanceRow.implicitHeight + Appearance.padding.normal * 2
                }

                // Step 2: inline wallpaper thumbnails shown when rice is selected
                Item {
                    Layout.fillWidth: true
                    visible: riceItem.isExpanded && (riceItem.modelData.wallpapers?.length ?? 0) > 0
                    implicitHeight: wallpaperFlow.implicitHeight + Appearance.padding.small * 2

                    Flow {
                        id: wallpaperFlow

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: Appearance.padding.small

                        spacing: Appearance.spacing.small

                        Repeater {
                            model: riceItem.modelData.wallpapers ?? []

                            delegate: Item {
                                id: wallpaperThumb

                                required property string modelData

                                implicitWidth: 72
                                implicitHeight: 40

                                StyledClippingRect {
                                    anchors.fill: parent
                                    radius: Appearance.rounding.small
                                    color: Colours.tPalette.m3surfaceContainer

                                    CachingImage {
                                        anchors.fill: parent
                                        path: wallpaperThumb.modelData
                                        cache: true
                                    }
                                }

                                StateLayer {
                                    radius: Appearance.rounding.small

                                    function onClicked(): void {
                                        previewController.stageAppearanceApplyWithWallpaper(sectionRoot.selectedRiceId, wallpaperThumb.modelData);
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.NoButton
                                    hoverEnabled: true
                                    onEntered: previewController.startWallpaperPreview(wallpaperThumb.modelData, "")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
