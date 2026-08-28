import ".."
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

StyledRect {
    id: root

    enum Type {
        Filled,
        Tonal,
        Text
    }

    property alias icon: iconLabel.text
    property alias text: label.text
    property alias font: label.font
    property bool checked
    property bool toggle
    property int type: ButtonBase.Filled
    property real horizontalPadding: Appearance.padding.normal
    property real verticalPadding: Appearance.padding.smaller
    property color activeColour: type === ButtonBase.Filled ? Colours.palette.m3primary : Colours.palette.m3secondary
    property color inactiveColour: type === ButtonBase.Filled ? Colours.tPalette.m3surfaceContainer : Colours.palette.m3secondaryContainer
    property color activeOnColour: type === ButtonBase.Filled ? Colours.palette.m3onPrimary : Colours.palette.m3onSecondary
    property color inactiveOnColour: type === ButtonBase.Filled ? Colours.palette.m3onSurface : Colours.palette.m3onSecondaryContainer

    signal clicked

    property bool internalChecked
    onCheckedChanged: internalChecked = checked

    radius: internalChecked ? Appearance.rounding.small : implicitHeight / 2 * Math.min(1, Appearance.rounding.scale)
    color: type === ButtonBase.Text ? "transparent" : internalChecked ? activeColour : inactiveColour
    implicitWidth: Math.max(row.implicitWidth + horizontalPadding * 2, implicitHeight)
    implicitHeight: row.implicitHeight + verticalPadding * 2

    property alias stateLayer: stateLayer
    property alias iconLabel: iconLabel
    property alias label: label

    StateLayer {
        id: stateLayer

        color: root.internalChecked ? root.activeOnColour : root.inactiveOnColour

        onClicked: {
            if (root.toggle)
                root.internalChecked = !root.internalChecked;
            root.clicked();
        }
    }

    RowLayout {
        id: row

        anchors.centerIn: parent
        spacing: Appearance.spacing.small

        MaterialIcon {
            id: iconLabel

            Layout.alignment: Qt.AlignVCenter
            color: root.internalChecked ? root.activeOnColour : root.inactiveOnColour
            fill: root.internalChecked ? 1 : 0

            Behavior on fill {
                Anim {}
            }
        }

        StyledText {
            id: label

            Layout.alignment: Qt.AlignVCenter
            color: root.internalChecked ? root.activeOnColour : root.inactiveOnColour
        }
    }

    Behavior on radius {
        Anim {}
    }
}
