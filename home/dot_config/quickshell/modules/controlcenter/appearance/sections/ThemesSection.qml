pragma ComponentBehavior: Bound

import ".."
import "../../../launcher/services"
import qs.components
import qs.components.controls
import qs.components.containers
import qs.components.images
import qs.services
import qs.config
import qs.utils
import Quickshell
import QtQuick
import QtQuick.Layouts

CollapsibleSection {
    id: sectionRoot

    required property var previewController
    required property var session

    title: qsTr("Themes")
    description: qsTr("Apply-once theme packs — wallpaper, colors, GTK, and icons")
    showBackground: true

    property string selectedThemeId: ""

    function wallpaperPathFor(theme: var, filename: string): string {
        if (!theme || !filename)
            return "";
        const mapped = theme.wallpaperPaths?.[filename];
        if (mapped)
            return mapped;
        if (theme.wallpaperPath && theme.defaultWallpaper === filename)
            return theme.wallpaperPath;
        const dir = theme.wallpaperDir || theme.id || "";
        // Prefer Pictures (post-chezmoi link); list-themes wallpaperPath already
        // falls back to the data dir for the default wallpaper.
        return `${Paths.pictures}/Wallpapers/${dir}/${filename}`;
    }

    Component.onCompleted: Themes.reload()

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.small / 2

        Repeater {
            model: Themes.list

            delegate: ColumnLayout {
                id: themeItem

                required property var modelData

                Layout.fillWidth: true
                spacing: 0

                readonly property bool isStaged: modelData.id === previewController.pendingThemeId
                readonly property bool isExpanded: modelData.id === sectionRoot.selectedThemeId

                StyledRect {
                    Layout.fillWidth: true

                    color: Qt.alpha(Colours.tPalette.m3surfaceContainer, themeItem.isStaged ? Colours.tPalette.m3surfaceContainer.a : 0)
                    radius: Appearance.rounding.normal
                    border.width: themeItem.isStaged ? 1 : 0
                    border.color: Colours.palette.m3primary

                    StateLayer {
                        function onClicked(): void {
                            sectionRoot.selectedThemeId = themeItem.modelData.id;
                            previewController.stageThemeApply(themeItem.modelData.id);
                            previewController.startThemePreview(themeItem.modelData);
                            previewController.commitPending();
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        hoverEnabled: true
                        onEntered: previewController.startThemePreview(themeItem.modelData)
                    }

                    ColumnLayout {
                        id: themeCard

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: Appearance.padding.normal

                        spacing: Appearance.spacing.small

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Appearance.spacing.normal

                            Loader {
                                active: (themeItem.modelData.preview ?? "") !== ""
                                Layout.alignment: Qt.AlignVCenter

                                sourceComponent: StyledClippingRect {
                                    implicitWidth: 72
                                    implicitHeight: 40
                                    radius: Appearance.rounding.small
                                    color: Colours.tPalette.m3surfaceContainer

                                    CachingImage {
                                        anchors.fill: parent
                                        path: themeItem.modelData.preview ?? ""
                                        cache: true
                                    }
                                }
                            }

                            Column {
                                Layout.fillWidth: true
                                spacing: 2

                                StyledText {
                                    text: modelData.name ?? modelData.id ?? ""
                                    font.pointSize: Appearance.font.size.normal
                                    font.weight: 500
                                }

                                StyledText {
                                    width: parent.width
                                    text: modelData.description ?? ""
                                    font.pointSize: Appearance.font.size.small
                                    color: Colours.palette.m3outline
                                    elide: Text.ElideRight
                                    maximumLineCount: 2
                                    wrapMode: Text.WordWrap
                                }

                                StyledText {
                                    width: parent.width
                                    text: {
                                        const bits = [];
                                        if (modelData.schemeType)
                                            bits.push(modelData.schemeType);
                                        if (modelData.gtkTheme)
                                            bits.push(modelData.gtkTheme);
                                        const scheme = modelData.gtkColorScheme || "";
                                        if (scheme)
                                            bits.push(scheme);
                                        if (modelData.iconTheme)
                                            bits.push(modelData.iconTheme);
                                        return bits.join(" · ");
                                    }
                                    font.pointSize: Appearance.font.size.smaller
                                    color: Colours.palette.m3outlineVariant
                                    elide: Text.ElideRight
                                    visible: !!(modelData.schemeType || modelData.gtkTheme || modelData.iconTheme)
                                }
                            }

                            StyledRect {
                                radius: Appearance.rounding.full
                                color: Qt.alpha(Colours.palette.m3secondaryContainer, 0.6)
                                implicitWidth: modeChip.implicitWidth + Appearance.padding.small * 2
                                implicitHeight: modeChip.implicitHeight + Appearance.padding.smaller * 2

                                StyledText {
                                    id: modeChip
                                    anchors.centerIn: parent
                                    text: modelData.darkMode ? qsTr("Dark") : qsTr("Light")
                                    font.pointSize: Appearance.font.size.smaller
                                    color: Colours.palette.m3onSecondaryContainer
                                }
                            }

                            StyledRect {
                                visible: themeItem.isStaged
                                radius: Appearance.rounding.full
                                color: Qt.alpha(Colours.palette.m3primaryContainer, 0.85)
                                implicitWidth: stagedChip.implicitWidth + Appearance.padding.small * 2
                                implicitHeight: stagedChip.implicitHeight + Appearance.padding.smaller * 2

                                StyledText {
                                    id: stagedChip
                                    anchors.centerIn: parent
                                    text: previewController.themeDirty ? qsTr("Pending") : qsTr("Selected")
                                    font.pointSize: Appearance.font.size.smaller
                                    color: Colours.palette.m3onPrimaryContainer
                                }
                            }
                        }

                        Flow {
                            Layout.fillWidth: true
                            visible: (modelData.tags?.length ?? 0) > 0
                            spacing: Appearance.spacing.smaller

                            Repeater {
                                model: modelData.tags ?? []

                                delegate: StyledRect {
                                    required property var modelData

                                    radius: Appearance.rounding.full
                                    color: Qt.alpha(Colours.palette.m3surfaceVariant, 0.35)
                                    implicitWidth: tagLabel.implicitWidth + Appearance.padding.small * 2
                                    implicitHeight: tagLabel.implicitHeight + Appearance.padding.smaller

                                    StyledText {
                                        id: tagLabel
                                        anchors.centerIn: parent
                                        text: modelData
                                        font.pointSize: Appearance.font.size.smaller
                                        color: Colours.palette.m3onSurfaceVariant
                                    }
                                }
                            }
                        }
                    }

                    implicitHeight: themeCard.implicitHeight + Appearance.padding.normal * 2
                }

                Item {
                    Layout.fillWidth: true
                    visible: themeItem.isExpanded && (themeItem.modelData.wallpapers?.length ?? 0) > 0
                    implicitHeight: wallpaperFlow.implicitHeight + Appearance.padding.small * 2

                    Flow {
                        id: wallpaperFlow

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: Appearance.padding.small

                        spacing: Appearance.spacing.small

                        Repeater {
                            model: themeItem.modelData.wallpapers ?? []

                            delegate: Item {
                                id: wallpaperThumb

                                required property string modelData

                                readonly property string fullPath: sectionRoot.wallpaperPathFor(themeItem.modelData, wallpaperThumb.modelData)

                                implicitWidth: 72
                                implicitHeight: 40

                                StyledClippingRect {
                                    anchors.fill: parent
                                    radius: Appearance.rounding.small
                                    color: Colours.tPalette.m3surfaceContainer

                                    CachingImage {
                                        anchors.fill: parent
                                        path: wallpaperThumb.fullPath
                                        cache: true
                                    }
                                }

                                StateLayer {
                                    radius: Appearance.rounding.small

                                    function onClicked(): void {
                                        previewController.stageThemeApplyWithWallpaper(sectionRoot.selectedThemeId, wallpaperThumb.fullPath);
                                        previewController.commitPending();
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.NoButton
                                    hoverEnabled: true
                                    onEntered: previewController.startWallpaperPreview(wallpaperThumb.fullPath, wallpaperThumb.modelData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
