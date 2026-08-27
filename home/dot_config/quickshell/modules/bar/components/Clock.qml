pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property color colour: Colours.palette.m3tertiary
    readonly property bool vertical: Config.bar.isVertical()

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    GridLayout {
        id: layout

        anchors.centerIn: parent

        flow: root.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
        rows: root.vertical ? -1 : 1
        columns: root.vertical ? 1 : -1
        rowSpacing: Appearance.spacing.small
        columnSpacing: Appearance.spacing.small

        Loader {
            Layout.alignment: Qt.AlignCenter

            active: Config.bar.clock.showIcon
            visible: active

            sourceComponent: MaterialIcon {
                text: "calendar_month"
                color: root.colour
            }
        }

        StyledText {
            Layout.alignment: Qt.AlignCenter

            horizontalAlignment: StyledText.AlignHCenter
            text: {
                const twelve = Config.services.useTwelveHourClock;
                if (root.vertical)
                    return Time.format(twelve ? "hh\nmm\nA" : "hh\nmm");
                return Time.format(twelve ? "hh:mm A" : "hh:mm");
            }
            font.pointSize: Appearance.font.size.smaller
            font.family: Appearance.font.family.mono
            color: root.colour
        }
    }
}
