pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.config

StyledRect {
    id: root

    readonly property var colorPalette: [
        { id: "red", name: qsTr("Red"), hex: "#E53935" },
        { id: "orange", name: qsTr("Orange"), hex: "#FB8C00" },
        { id: "yellow", name: qsTr("Yellow"), hex: "#FDD835" },
        { id: "green", name: qsTr("Green"), hex: "#4CAF50" },
        { id: "blue", name: qsTr("Blue"), hex: "#2196F3" },
        { id: "purple", name: qsTr("Purple"), hex: "#9C27B0" },
        { id: "pink", name: qsTr("Pink"), hex: "#EC407A" },
        { id: "white", name: qsTr("White"), hex: "#FFFFFF" },
        { id: "black", name: qsTr("Black"), hex: "#1A1A1A" }
    ]

    readonly property string activeColorName: {
        if (!Wallpapers.colorFilter || Wallpapers.colorFilter === "")
            return qsTr("All");
        for (let i = 0; i < colorPalette.length; i++) {
            if (colorPalette[i].id === Wallpapers.colorFilter)
                return colorPalette[i].name;
        }
        return Wallpapers.colorFilter;
    }

    color: Qt.rgba(Colours.palette.m3surfaceContainerHigh.r, Colours.palette.m3surfaceContainerHigh.g, Colours.palette.m3surfaceContainerHigh.b, 0.9)
    radius: Appearance.rounding.large

    implicitWidth: layoutRow.implicitWidth + Appearance.padding.medium * 2
    implicitHeight: 38

    Row {
        id: layoutRow
        anchors.centerIn: parent
        spacing: Appearance.spacing.medium

        // Active filter badge & reset action
        StyledRect {
            id: labelBadge

            anchors.verticalCenter: parent.verticalCenter
            color: Wallpapers.colorFilter !== "" ? Colours.palette.m3secondaryContainer : "transparent"
            radius: Appearance.rounding.medium
            implicitWidth: badgeContent.implicitWidth + (Wallpapers.colorFilter !== "" ? Appearance.padding.medium : Appearance.padding.small)
            implicitHeight: 26

            Row {
                id: badgeContent
                anchors.centerIn: parent

                StyledText {
                    text: root.activeColorName
                    color: Wallpapers.colorFilter !== "" ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.small
                }

                MaterialIcon {
                    visible: Wallpapers.colorFilter !== ""
                    anchors.verticalCenter: parent.verticalCenter
                    text: "close"
                    color: Colours.palette.m3onSecondaryContainer
                    font.pointSize: Appearance.font.size.small

                    StateLayer {
                        radius: Appearance.rounding.full

                        onClicked: Wallpapers.colorFilter = ""
                    }
                }
            }

            StateLayer {
                radius: parent.radius

                onClicked: Wallpapers.colorFilter = ""
            }
        }

        // Color swatches
        Repeater {
            model: root.colorPalette

            StyledRect {
                id: swatch

                required property var modelData

                anchors.verticalCenter: parent.verticalCenter
                color: modelData.hex
                radius: Appearance.rounding.full
                implicitWidth: 22
                implicitHeight: 22
                border.width: Wallpapers.colorFilter === modelData.id ? 3 : 1
                border.color: Wallpapers.colorFilter === modelData.id ? Colours.palette.m3onSurface : Qt.alpha(Colours.palette.m3outline, 0.5)

                StateLayer {
                    radius: parent.radius

                    onClicked: Wallpapers.colorFilter = root.modelData.id
                }

                Behavior on border.width {
                    Anim {}
                }

                Behavior on border.color {
                    CAnim {}
                }
            }
        }
    }
}
