import QtQuick
import qs.components
import qs.services
import qs.config

StyledTextField {
    id: root

    readonly property alias bg: bg
    readonly property alias searchIcon: searchIcon

    leftPadding: searchIcon.width + searchIcon.anchors.leftMargin + Appearance.spacing.medium
    rightPadding: clearIcon.width + clearIcon.anchors.rightMargin + Appearance.spacing.medium
    topPadding: Appearance.padding.large
    bottomPadding: Appearance.padding.large

    background: StyledRect {
        id: bg

        anchors.fill: parent
        color: Colours.tPalette.m3surfaceContainer
        radius: Appearance.rounding.full

        StateLayer {
            radius: parent.radius
            disabled: !root.enabled
        }

        MaterialIcon {
            id: searchIcon

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Appearance.spacing.medium
            text: "search"
            color: Colours.palette.m3onSurfaceVariant
        }
    }

    MaterialIcon {
        id: clearIcon

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Appearance.spacing.medium
        visible: root.text.length > 0
        color: Colours.palette.m3onSurfaceVariant
        text: "close"

        StateLayer {
            radius: Appearance.rounding.full

            onClicked: root.clear()
        }
    }
}
