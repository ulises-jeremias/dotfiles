pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Layouts

StyledRect {
    id: root

    required property Notifs.Notif modelData
    required property Props props
    required property bool expanded
    required property var visibilities

    readonly property StyledText body: expandedContent.item?.body ?? null
    readonly property real nonAnimHeight: expanded ? summary.implicitHeight + expandedContent.implicitHeight + expandedContent.anchors.topMargin + Appearance.padding.normal * 2 : summaryHeightMetrics.height

    // Urgency-driven color roles
    readonly property bool isCritical: root.modelData.urgency === "critical"
    readonly property bool isLow: root.modelData.urgency === "low"
    readonly property color bgColor: {
        if (isCritical)
            return Colours.palette.m3errorContainer;
        if (isLow)
            return Colours.layer(Colours.palette.m3surfaceContainerLow, 2);
        return Colours.layer(Colours.palette.m3surfaceContainerHigh, 2);
    }
    readonly property color accentColor: {
        if (isCritical)
            return Colours.palette.m3error;
        if (isLow)
            return Colours.palette.m3outline;
        return Colours.palette.m3secondary;
    }
    readonly property color textColor: {
        if (isCritical)
            return Colours.palette.m3onErrorContainer;
        return Colours.palette.m3onSurface;
    }
    readonly property color bodyColor: {
        if (isCritical)
            return Colours.palette.m3onErrorContainer;
        if (isLow)
            return Qt.alpha(Colours.palette.m3outline, 0.7);
        return Colours.palette.m3outline;
    }

    implicitHeight: nonAnimHeight

    radius: Appearance.rounding.small
    color: expanded ? bgColor : Qt.alpha(bgColor, 0)

    // Urgency stripe: colored left border for visual hierarchy
    StyledRect {
        id: urgencyStripe

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left

        width: 3
        radius: Appearance.rounding.full
        color: root.accentColor
        opacity: root.expanded ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            Anim {}
        }
    }

    // Critical urgency border
    Loader {
        active: root.isCritical && root.expanded
        visible: active
        anchors.fill: parent

        sourceComponent: StyledRect {
            color: "transparent"
            radius: Appearance.rounding.small
            border.width: 1
            border.color: Qt.alpha(Colours.palette.m3error, 0.6)
        }
    }

    states: State {
        name: "expanded"
        when: root.expanded

        PropertyChanges {
            summary.anchors.leftMargin: urgencyStripe.width + Appearance.padding.normal
            summary.anchors.margins: Appearance.padding.normal
            dummySummary.anchors.leftMargin: urgencyStripe.width + Appearance.padding.normal
            dummySummary.anchors.margins: Appearance.padding.normal
            compactBody.anchors.margins: Appearance.padding.normal
            timeStr.anchors.margins: Appearance.padding.normal
            expandedContent.anchors.leftMargin: urgencyStripe.width + Appearance.padding.normal
            expandedContent.anchors.margins: Appearance.padding.normal
            summary.width: root.width - Appearance.padding.normal * 2 - urgencyStripe.width - timeStr.implicitWidth - Appearance.spacing.small
            summary.maximumLineCount: Number.MAX_SAFE_INTEGER
        }
    }

    transitions: Transition {
        Anim {
            properties: "margins,leftMargin,width,maximumLineCount"
        }
    }

    TextMetrics {
        id: summaryHeightMetrics

        font: summary.font
        text: " " // Use this height to prevent weird characters from changing the line height
    }

    StyledText {
        id: summary

        anchors.top: parent.top
        anchors.left: parent.left

        width: parent.width
        text: root.modelData.summary
        color: root.textColor
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        maximumLineCount: 1
    }

    StyledText {
        id: dummySummary

        anchors.top: parent.top
        anchors.left: parent.left

        visible: false
        text: root.modelData.summary
    }

    WrappedLoader {
        id: compactBody

        shouldBeActive: !root.expanded
        anchors.top: parent.top
        anchors.left: dummySummary.right
        anchors.right: parent.right
        anchors.leftMargin: Appearance.spacing.small

        sourceComponent: StyledText {
            text: root.modelData.body.replace(/\n/g, " ")
            color: root.bodyColor
            elide: Text.ElideRight
        }
    }

    WrappedLoader {
        id: timeStr

        shouldBeActive: root.expanded
        anchors.top: parent.top
        anchors.right: parent.right

        sourceComponent: StyledText {
            animate: true
            text: root.modelData.timeStr
            color: Colours.palette.m3outline
            font.pointSize: Appearance.font.size.small
        }
    }

    WrappedLoader {
        id: expandedContent

        shouldBeActive: root.expanded
        anchors.top: summary.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Appearance.spacing.small / 2

        sourceComponent: ColumnLayout {
            readonly property alias body: body

            spacing: Appearance.spacing.smaller

            StyledText {
                id: body

                Layout.fillWidth: true
                textFormat: Text.MarkdownText
                text: root.modelData.body.replace(/(.)\n(?!\n)/g, "$1\n\n") || qsTr("No body here! :/")
                color: root.bodyColor
                wrapMode: Text.WordWrap

                onLinkActivated: link => {
                    Quickshell.execDetached(["app2unit", "-O", "--", link]);
                    root.visibilities.sidebar = false;
                }
            }

            NotifActionList {
                notif: root.modelData
            }
        }
    }

    Behavior on implicitHeight {
        Anim {
            duration: Appearance.anim.durations.expressiveDefaultSpatial
            easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
        }
    }

    component WrappedLoader: Loader {
        required property bool shouldBeActive

        opacity: shouldBeActive ? 1 : 0
        active: opacity > 0

        Behavior on opacity {
            Anim {}
        }
    }
}
