pragma ComponentBehavior: Bound

import Quickshell
import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property ShellScreen screen

    property color colour: Colours.palette.m3tertiary
    readonly property bool vertical: Config.bar.isVerticalFor(screen.name)
    readonly property bool isTop: Config.bar.positionFor(screen.name) === "top"

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    StyledRect {
        visible: Config.bar.clock.background && !root.vertical
        anchors.fill: parent
        anchors.margins: -Appearance.padding.normal
        color: Colours.tPalette.m3surfaceContainer
        radius: Appearance.rounding.normal
    }

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

        // Date line (horizontal bars only, above the time)
        StyledText {
            Layout.alignment: Qt.AlignCenter
            visible: Config.bar.clock.showDate && !root.vertical

            horizontalAlignment: StyledText.AlignHCenter
            text: Time.format("ddd d MMM")
            font.pointSize: Appearance.font.size.smaller
            font.family: Appearance.font.family.sans
            color: Colours.palette.m3onSurfaceVariant
        }

        // Time: split into two texts with anti-jitter equalisation
        // (Caelestia Clock.qml pattern — prevents width jitter on "11" vs "10")
        RowLayout {
            Layout.alignment: Qt.AlignCenter
            spacing: Appearance.spacing.small / 2

            visible: !root.vertical

            TextMetrics {
                id: hourMetrics

                text: "00"
                font.pointSize: Appearance.font.size.smaller
                font.family: Appearance.font.family.mono
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter

                text: Time.hourStr
                font.pointSize: Appearance.font.size.smaller
                font.family: Appearance.font.family.mono
                color: root.colour
                Layout.preferredWidth: hourMetrics.width
                horizontalAlignment: StyledText.AlignRight
            }

            StyledText {
                text: ":"
                font.pointSize: Appearance.font.size.smaller
                font.family: Appearance.font.family.mono
                color: root.colour
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter

                text: Time.minuteStr
                font.pointSize: Appearance.font.size.smaller
                font.family: Appearance.font.family.mono
                color: root.colour
                Layout.preferredWidth: hourMetrics.width
                horizontalAlignment: StyledText.AlignLeft
            }

            StyledText {
                visible: Config.services.useTwelveHourClock
                text: Time.amPmStr
                font.pointSize: Appearance.font.size.smaller
                font.family: Appearance.font.family.sans
                color: Colours.palette.m3onSurfaceVariant
            }
        }

        // Vertical time (for vertical bars)
        StyledText {
            Layout.alignment: Qt.AlignCenter
            visible: root.vertical

            horizontalAlignment: StyledText.AlignHCenter
            text: {
                const twelve = Config.services.useTwelveHourClock;
                return Time.format(twelve ? "hh\nmm\nA" : "hh\nmm");
            }
            font.pointSize: Appearance.font.size.smaller
            font.family: Appearance.font.family.mono
            color: root.colour
        }
    }
}
