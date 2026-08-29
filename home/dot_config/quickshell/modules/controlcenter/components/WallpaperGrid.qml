pragma ComponentBehavior: Bound

import ".."
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.images
import qs.services
import qs.config
import qs.utils
import Hornero.Models
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Session session
    required property var previewController

    property string wallpaperScopeDir: ""
    property bool showAllWallpapers: false
    signal toggleShowAllRequested()

    readonly property string scopeBasePath: wallpaperScopeDir ? `${Paths.pictures}/Wallpapers/${wallpaperScopeDir}` : ""
    readonly property string scopeDataPath: wallpaperScopeDir ? `${Paths.data}/wallpapers/${wallpaperScopeDir}` : ""
    readonly property var displayModel: {
        let entries = Wallpapers.list;
        const filter = Wallpapers.colorFilter;
        if (filter) {
            entries = entries.filter(entry => {
                const name = (entry?.name || entry?.relativePath || "").toLowerCase();
                return name.includes(filter);
            });
        }
        if (showAllWallpapers || !wallpaperScopeDir)
            return entries;
        const pics = scopeBasePath;
        const data = scopeDataPath;
        return entries.filter(entry => {
            const p = entry?.path ?? "";
            return p.startsWith(`${pics}/`) || p === pics || p.startsWith(`${data}/`) || p === data
                || p.includes(`/Wallpapers/${wallpaperScopeDir}/`)
                || p.includes(`/wallpapers/${wallpaperScopeDir}/`);
        });
    }

    readonly property int minCellWidth: 200 + Appearance.spacing.normal

    implicitWidth: grid.implicitWidth
    implicitHeight: scopeHeader.visible ? scopeHeader.implicitHeight + grid.implicitHeight : grid.implicitHeight

    anchors.fill: parent

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            id: scopeHeader

            Layout.fillWidth: true
            visible: wallpaperScopeDir !== ""
            spacing: Appearance.spacing.small

            StyledText {
                Layout.fillWidth: true
                text: showAllWallpapers
                    ? qsTr("All wallpapers")
                    : qsTr("Theme wallpapers: %1").arg(wallpaperScopeDir)
                font.pointSize: Appearance.font.size.small
                color: Colours.palette.m3outline
            }

            TextButton {
                text: showAllWallpapers ? qsTr("Show theme only") : qsTr("Show all")
                onClicked: root.toggleShowAllRequested()
            }
        }

        GridView {
            id: grid

            Layout.fillWidth: true
            Layout.fillHeight: true

            readonly property int columnsCount: Math.max(1, Math.floor(width / root.minCellWidth))
            property string pendingPreviewPath: ""
            property string pendingPreviewName: ""

            cellWidth: width / columnsCount
            cellHeight: 140 + Appearance.spacing.normal

            model: root.displayModel

            clip: true

            StyledText {
                anchors.centerIn: parent
                visible: grid.count === 0
                text: root.wallpaperScopeDir && !root.showAllWallpapers
                    ? qsTr("No wallpapers found for this theme")
                    : qsTr("No wallpapers found")
                color: Colours.palette.m3outline
                font.pointSize: Appearance.font.size.normal
            }

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: grid
            }

            Timer {
                id: previewDebounce
                interval: 120
                onTriggered: {
                    if (grid.pendingPreviewPath)
                        root.previewController.startWallpaperPreview(grid.pendingPreviewPath, grid.pendingPreviewName);
                }
            }

            delegate: Item {
                required property var modelData
                required property int index

                width: grid.cellWidth
                height: grid.cellHeight

                readonly property bool isCurrent: modelData && modelData.path === root.previewController.pendingWallpaperPath
        readonly property real itemMargin: Appearance.spacing.normal / 2
        readonly property real itemRadius: Appearance.rounding.normal

        StateLayer {
            anchors.fill: parent
            anchors.leftMargin: itemMargin
            anchors.rightMargin: itemMargin
            anchors.topMargin: itemMargin
            anchors.bottomMargin: itemMargin
            radius: itemRadius

            function onClicked(): void {
                root.previewController.startWallpaperPreview(modelData.path, modelData.name);
                root.previewController.stageWallpaperApply(modelData.path);
                root.previewController.commitPending();
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            hoverEnabled: true
            onEntered: {
                grid.pendingPreviewPath = modelData.path;
                grid.pendingPreviewName = modelData.name;
                previewDebounce.restart();
            }
            onExited: {
                grid.pendingPreviewPath = "";
                grid.pendingPreviewName = "";
                previewDebounce.stop();
            }
        }

        StyledClippingRect {
            id: image

            anchors.fill: parent
            anchors.leftMargin: itemMargin
            anchors.rightMargin: itemMargin
            anchors.topMargin: itemMargin
            anchors.bottomMargin: itemMargin
            color: Colours.tPalette.m3surfaceContainer
            radius: itemRadius
            antialiasing: true
            layer.enabled: true
            layer.smooth: true

            CachingImage {
                id: cachingImage

                path: modelData.path
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                cache: true
                visible: opacity > 0
                antialiasing: true
                smooth: true
                sourceSize: Qt.size(width, height)

                opacity: status === Image.Ready ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 1000
                        easing.type: Easing.OutQuad
                    }
                }
            }

            // Fallback if CachingImage fails to load
            Image {
                id: fallbackImage

                anchors.fill: parent
                source: fallbackTimer.triggered && cachingImage.status !== Image.Ready ? modelData.path : ""
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
                cache: true
                visible: opacity > 0
                antialiasing: true
                smooth: true
                sourceSize: Qt.size(width, height)

                opacity: status === Image.Ready && cachingImage.status !== Image.Ready ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 1000
                        easing.type: Easing.OutQuad
                    }
                }
            }

            Timer {
                id: fallbackTimer

                property bool triggered: false
                interval: 800
                running: cachingImage.status === Image.Loading || cachingImage.status === Image.Null
                onTriggered: triggered = true
            }

            // Gradient overlay for filename
            Rectangle {
                id: filenameOverlay

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                implicitHeight: filenameText.implicitHeight + Appearance.padding.normal * 1.5
                radius: 0

                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: Qt.rgba(Colours.palette.m3surface.r, Colours.palette.m3surface.g, Colours.palette.m3surface.b, 0)
                    }
                    GradientStop {
                        position: 0.3
                        color: Qt.rgba(Colours.palette.m3surface.r, Colours.palette.m3surface.g, Colours.palette.m3surface.b, 0.7)
                    }
                    GradientStop {
                        position: 0.6
                        color: Qt.rgba(Colours.palette.m3surface.r, Colours.palette.m3surface.g, Colours.palette.m3surface.b, 0.9)
                    }
                    GradientStop {
                        position: 1.0
                        color: Qt.rgba(Colours.palette.m3surface.r, Colours.palette.m3surface.g, Colours.palette.m3surface.b, 0.95)
                    }
                }

                opacity: 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 1000
                        easing.type: Easing.OutCubic
                    }
                }

                Component.onCompleted: {
                    opacity = 1;
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: itemMargin
            anchors.rightMargin: itemMargin
            anchors.topMargin: itemMargin
            anchors.bottomMargin: itemMargin
            color: "transparent"
            radius: itemRadius + border.width
            border.width: isCurrent ? 2 : 0
            border.color: Colours.palette.m3primary
            antialiasing: true
            smooth: true

            Behavior on border.width {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutQuad
                }
            }

            MaterialIcon {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Appearance.padding.small

                visible: isCurrent
                text: "check_circle"
                color: Colours.palette.m3primary
                font.pointSize: Appearance.font.size.large
            }
        }

        StyledText {
            id: filenameText
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: Appearance.padding.normal + Appearance.spacing.normal / 2
            anchors.rightMargin: Appearance.padding.normal + Appearance.spacing.normal / 2
            anchors.bottomMargin: Appearance.padding.normal

            text: modelData.name
            font.pointSize: Appearance.font.size.smaller
            font.weight: 500
            color: isCurrent ? Colours.palette.m3primary : Colours.palette.m3onSurface
            elide: Text.ElideMiddle
            maximumLineCount: 1
            horizontalAlignment: Text.AlignHCenter

            opacity: 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 1000
                    easing.type: Easing.OutCubic
                }
            }

            Component.onCompleted: {
                opacity = 1;
            }
        }
            }
        }
    }

    Component.onDestruction: root.previewController.clearPreviewFor("wallpaper")
}
