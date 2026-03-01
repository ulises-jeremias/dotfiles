pragma ComponentBehavior: Bound

import qs.components
import qs.components.effects
import qs.components.images
import qs.services
import qs.config
import Quickshell
import QtQuick

// Wallpaper item for the RiceSelector carousel.
// Accepts a plain string path instead of FileSystemEntry so it can be
// driven directly from the rice's wallpapers[] JSON array.
Item {
    id: root

    required property string modelData
    required property PersistentProperties visibilities
    signal activated(string path)

    scale: 0.5
    opacity: 0
    z: PathView.z ?? 0

    Component.onCompleted: {
        scale = Qt.binding(() => PathView.isCurrentItem ? 1 : PathView.onPath ? 0.8 : 0);
        opacity = Qt.binding(() => PathView.onPath ? 1 : 0);
    }

    implicitWidth: image.width + Appearance.padding.larger * 2
    implicitHeight: image.height + label.height + Appearance.spacing.small / 2 + Appearance.padding.large + Appearance.padding.normal

    StateLayer {
        radius: Appearance.rounding.normal

        function onClicked(): void {
            root.activated(root.modelData);
        }
    }

    Elevation {
        anchors.fill: image
        radius: image.radius
        opacity: root.PathView.isCurrentItem ? 1 : 0
        level: 4

        Behavior on opacity {
            Anim {}
        }
    }

    StyledClippingRect {
        id: image

        anchors.horizontalCenter: parent.horizontalCenter
        y: Appearance.padding.large
        color: Colours.tPalette.m3surfaceContainer
        radius: Appearance.rounding.normal

        implicitWidth: Config.launcher.sizes.wallpaperWidth
        implicitHeight: implicitWidth / 16 * 9

        MaterialIcon {
            anchors.centerIn: parent
            text: "image"
            color: Colours.tPalette.m3outline
            font.pointSize: Appearance.font.size.extraLarge * 2
            font.weight: 600
        }

        CachingImage {
            path: root.modelData
            smooth: !root.PathView.view.moving
            cache: true

            anchors.fill: parent
        }
    }

    StyledText {
        id: label

        anchors.top: image.bottom
        anchors.topMargin: Appearance.spacing.small / 2
        anchors.horizontalCenter: parent.horizontalCenter

        width: image.width - Appearance.padding.normal * 2
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        renderType: Text.QtRendering
        text: root.modelData.split("/").pop()
        font.pointSize: Appearance.font.size.normal
    }

    Behavior on scale {
        Anim {}
    }

    Behavior on opacity {
        Anim {}
    }
}
