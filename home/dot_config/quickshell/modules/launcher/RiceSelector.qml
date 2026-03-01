pragma ComponentBehavior: Bound

import "items"
import "services"
import qs.components
import qs.components.controls
import qs.components.containers
import qs.components.images
import qs.services
import qs.config
import Quickshell
import QtQuick

// Two-step rice + wallpaper selector.
//
// Step 1 ("rices"): scrollable list of rice cards with preview.png thumbnails.
// Step 2 ("wallpapers"): carousel of the selected rice's own wallpapers.
//
// Content.qml drives Enter via confirmCurrentRice() and currentWallpaperPath.
Item {
    id: root

    required property StyledTextField search
    required property PersistentProperties visibilities
    required property var panels
    required property var content

    property string step: "rices"
    property var selectedRice: null

    // Exposed for Content.qml keyboard handling.
    // In step "rices" this is the rice ListView; in "wallpapers" the PathView.
    readonly property Item currentList: step === "rices" ? riceList : wallpaperCarousel

    // The wallpaper path currently focused in the carousel (step 2 only).
    readonly property string currentWallpaperPath: step === "wallpapers" && wallpaperCarousel.currentItem ? wallpaperCarousel.currentItem.modelData : ""

    implicitWidth: step === "wallpapers" ? Math.max(Config.launcher.sizes.itemWidth, wallpaperCarouselArea.implicitWidth) : Config.launcher.sizes.itemWidth

    implicitHeight: step === "wallpapers" ? headerRow.implicitHeight + Appearance.spacing.normal + wallpaperCarousel.implicitHeight : riceList.implicitHeight

    function confirmCurrentRice(): void {
        if (step === "rices" && riceList.currentIndex >= 0) {
            const item = riceList.itemAtIndex(riceList.currentIndex);
            if (item) {
                root.selectedRice = item.modelData;
                root.step = "wallpapers";
                wallpaperCarousel.currentIndex = 0;
            }
        }
    }

    function goBack(): void {
        Wallpapers.stopPreview();
        root.step = "rices";
    }

    function applySelectedWallpaper(path: string): void {
        if (!root.selectedRice?.id || !path)
            return;
        if (Colours.scheme === "dynamic")
            Wallpapers.previewColourLock = true;
        Quickshell.execDetached(["dots-appearance", "apply", root.selectedRice.id, "--wallpaper", path]);
        root.visibilities.launcher = false;
    }

    function refreshRiceModel(): void {
        riceModel.values = Appearances.query(root.search.text);
    }

    Component.onCompleted: {
        Appearances.reload();
        refreshRiceModel();
    }

    Connections {
        target: Appearances

        function onListChanged(): void {
            root.refreshRiceModel();
        }
    }

    Connections {
        target: root.search

        function onTextChanged(): void {
            root.refreshRiceModel();
        }
    }

    // ── Step 1: rice list ────────────────────────────────────────────────────

    StyledListView {
        id: riceList

        visible: step === "rices"
        opacity: step === "rices" ? 1 : 0
        anchors.fill: parent

        model: ScriptModel {
            id: riceModel

            values: []
            onValuesChanged: riceList.currentIndex = 0
        }

        readonly property int previewWidth: 120
        readonly property int previewHeight: previewWidth / 16 * 9
        readonly property int cardHeight: previewHeight + Appearance.padding.normal * 2

        spacing: Appearance.spacing.small
        orientation: Qt.Vertical
        implicitHeight: (cardHeight + spacing) * Math.min(Config.launcher.maxShown, count) - spacing

        preferredHighlightBegin: 0
        preferredHighlightEnd: height
        highlightRangeMode: ListView.ApplyRange
        highlightFollowsCurrentItem: false

        highlight: StyledRect {
            radius: Appearance.rounding.normal
            color: Colours.palette.m3onSurface
            opacity: 0.08

            y: riceList.currentItem?.y ?? 0
            implicitWidth: riceList.width
            implicitHeight: riceList.currentItem?.implicitHeight ?? 0

            Behavior on y {
                Anim {
                    duration: Appearance.anim.durations.expressiveDefaultSpatial
                    easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                }
            }
        }

        StyledScrollBar.vertical: StyledScrollBar {
            flickable: riceList
        }

        delegate: Item {
            id: riceCard

            required property var modelData
            required property int index

            anchors.left: parent?.left
            anchors.right: parent?.right
            implicitHeight: riceList.cardHeight

            StateLayer {
                radius: Appearance.rounding.normal

                function onClicked(): void {
                    riceList.currentIndex = riceCard.index;
                    root.selectedRice = riceCard.modelData;
                    root.step = "wallpapers";
                    wallpaperCarousel.currentIndex = 0;
                }
            }

            Row {
                anchors.fill: parent
                anchors.margins: Appearance.padding.normal
                spacing: Appearance.spacing.normal

                StyledClippingRect {
                    id: thumbnail

                    width: riceList.previewWidth
                    height: riceList.previewHeight
                    anchors.verticalCenter: parent.verticalCenter
                    radius: Appearance.rounding.small
                    color: Colours.tPalette.m3surfaceContainer

                    MaterialIcon {
                        anchors.centerIn: parent
                        text: "palette"
                        color: Colours.tPalette.m3outline
                        font.pointSize: Appearance.font.size.large
                    }

                    CachingImage {
                        anchors.fill: parent
                        path: riceCard.modelData.preview ?? ""
                        cache: true
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - thumbnail.width - parent.spacing - (currentCheck.active ? currentCheck.width + Appearance.spacing.normal : 0)
                    spacing: 0

                    StyledText {
                        text: riceCard.modelData.name ?? riceCard.modelData.id ?? ""
                        font.pointSize: Appearance.font.size.normal
                    }

                    StyledText {
                        text: riceCard.modelData.style ?? riceCard.modelData.description ?? ""
                        font.pointSize: Appearance.font.size.small
                        color: Colours.palette.m3outline
                        elide: Text.ElideRight
                        anchors.left: parent.left
                        anchors.right: parent.right
                    }
                }
            }

            Loader {
                id: currentCheck

                anchors.right: parent.right
                anchors.rightMargin: Appearance.padding.larger
                anchors.verticalCenter: parent.verticalCenter
                active: riceCard.modelData.id === Appearances.currentId

                sourceComponent: MaterialIcon {
                    text: "check"
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.large
                }
            }
        }

        Behavior on opacity {
            Anim {
                duration: Appearance.anim.durations.small
            }
        }
    }

    // ── Step 2: header + wallpaper carousel ──────────────────────────────────

    Item {
        id: wallpaperCarouselArea

        visible: step === "wallpapers"
        opacity: step === "wallpapers" ? 1 : 0
        anchors.fill: parent

        implicitWidth: wallpaperCarousel.implicitWidth
        implicitHeight: headerRow.implicitHeight + Appearance.spacing.normal + wallpaperCarousel.implicitHeight

        // Back button + rice name
        Item {
            id: headerRow

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            implicitHeight: backIcon.implicitHeight + Appearance.padding.small * 2

            StateLayer {
                width: backIcon.implicitWidth + Appearance.padding.larger * 2
                height: parent.height
                radius: Appearance.rounding.full

                function onClicked(): void {
                    root.goBack();
                }
            }

            MaterialIcon {
                id: backIcon

                anchors.left: parent.left
                anchors.leftMargin: Appearance.padding.larger
                anchors.verticalCenter: parent.verticalCenter
                text: "arrow_back"
                color: Colours.palette.m3onSurface
                font.pointSize: Appearance.font.size.large
            }

            StyledText {
                anchors.left: backIcon.right
                anchors.leftMargin: Appearance.spacing.normal
                anchors.right: parent.right
                anchors.rightMargin: Appearance.padding.larger
                anchors.verticalCenter: parent.verticalCenter
                text: root.selectedRice?.name ?? ""
                font.pointSize: Appearance.font.size.normal
                font.weight: 500
                elide: Text.ElideRight
            }
        }

        PathView {
            id: wallpaperCarousel

            readonly property int itemWidth: Config.launcher.sizes.wallpaperWidth * 0.8 + Appearance.padding.larger * 2

            readonly property int numItems: {
                const screen = QsWindow.window?.screen;
                if (!screen)
                    return 0;
                const barMargins = Math.max(Config.border.thickness, root.panels.bar.implicitWidth);
                const maxWidth = screen.width - Config.border.rounding * 4 - barMargins * 2;
                if (maxWidth <= 0)
                    return 0;
                const visible = Math.min(Math.floor(maxWidth / itemWidth), Config.launcher.maxWallpapers, count);
                if (visible === 2)
                    return 1;
                if (visible > 1 && visible % 2 === 0)
                    return visible - 1;
                return visible;
            }

            anchors.top: headerRow.bottom
            anchors.topMargin: Appearance.spacing.normal
            anchors.horizontalCenter: parent.horizontalCenter

            model: ScriptModel {
                id: wallpaperModel

                values: root.selectedRice?.wallpapers ?? []
            }

            onCurrentItemChanged: {
                if (currentItem)
                    Wallpapers.preview(currentItem.modelData);
            }

            Component.onDestruction: Wallpapers.stopPreview()

            implicitWidth: Math.min(numItems, count) * itemWidth
            implicitHeight: Config.launcher.sizes.wallpaperHeight
            pathItemCount: numItems
            cacheItemCount: 4

            snapMode: PathView.SnapToItem
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5
            highlightRangeMode: PathView.StrictlyEnforceRange

            delegate: RiceWallpaperItem {
                visibilities: root.visibilities
                onActivated: path => root.applySelectedWallpaper(path)
            }

            path: Path {
                startY: wallpaperCarousel.height / 2

                PathAttribute {
                    name: "z"
                    value: 0
                }
                PathLine {
                    x: wallpaperCarousel.width / 2
                    relativeY: 0
                }
                PathAttribute {
                    name: "z"
                    value: 1
                }
                PathLine {
                    x: wallpaperCarousel.width
                    relativeY: 0
                }
            }
        }

        Behavior on opacity {
            Anim {
                duration: Appearance.anim.durations.small
            }
        }
    }
}
