import "../services"
import qs.components
import qs.components.images
import qs.services
import qs.config
import QtQuick

Item {
    id: root

    required property Themes.Theme modelData
    required property var list

    implicitHeight: Config.launcher.sizes.itemHeight

    anchors.left: parent?.left
    anchors.right: parent?.right

    StateLayer {
        radius: Appearance.rounding.normal

        function onClicked(): void {
            root.modelData?.onClicked(root.list);
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: Appearance.padding.larger
        anchors.rightMargin: Appearance.padding.larger
        anchors.margins: Appearance.padding.smaller

        Loader {
            id: previewThumb

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            active: (root.modelData?.preview ?? "") !== ""

            sourceComponent: StyledClippingRect {
                implicitWidth: 40
                implicitHeight: 22
                radius: Appearance.rounding.small
                color: Colours.tPalette.m3surfaceContainer

                CachingImage {
                    anchors.fill: parent
                    path: root.modelData?.preview ?? ""
                    cache: true
                }
            }
        }

        MaterialIcon {
            id: icon

            text: "palette"
            font.pointSize: Appearance.font.size.extraLarge

            anchors.left: previewThumb.active ? previewThumb.right : parent.left
            anchors.leftMargin: previewThumb.active ? Appearance.spacing.small : 0
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            anchors.left: icon.right
            anchors.leftMargin: Appearance.spacing.larger
            anchors.verticalCenter: icon.verticalCenter

            width: parent.width - icon.implicitWidth - anchors.leftMargin - (previewThumb.active ? previewThumb.implicitWidth + Appearance.spacing.small : 0)
            spacing: 0

            StyledText {
                text: root.modelData?.name ?? ""
                font.pointSize: Appearance.font.size.normal
            }

            StyledText {
                text: root.modelData?.description ?? ""
                font.pointSize: Appearance.font.size.small
                color: Colours.palette.m3outline

                elide: Text.ElideRight
                anchors.left: parent.left
                anchors.right: parent.right
            }
        }
    }
}
