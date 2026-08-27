pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Effects

Item {
    id: root

    required property Item bar

    readonly property bool barFloating: Config.bar.isFloating()
    readonly property string barPosition: Config.bar.position

    anchors.fill: parent

    StyledRect {
        anchors.fill: parent
        color: Colours.palette.m3surface

        layer.enabled: true
        layer.effect: MultiEffect {
            maskSource: mask
            maskEnabled: true
            maskInverted: true
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1
        }
    }

    Item {
        id: mask

        anchors.fill: parent
        layer.enabled: true
        visible: false

        // The cutout reaches the screen edge on the bar's edge when floating,
        // so the pill floats over the wallpaper instead of a solid frame strip
        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: root.barPosition === "left" && root.barFloating ? 0 : root.bar.marginLeft
            anchors.rightMargin: root.barPosition === "right" && root.barFloating ? 0 : root.bar.marginRight
            anchors.topMargin: root.barPosition === "top" && root.barFloating ? 0 : root.bar.marginTop
            anchors.bottomMargin: root.barPosition === "bottom" && root.barFloating ? 0 : root.bar.marginBottom
            radius: Config.border.rounding
        }
    }
}
