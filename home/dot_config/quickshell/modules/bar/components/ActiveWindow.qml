pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.utils
import qs.config
import QtQuick

Item {
    id: root

    required property var bar
    required property Brightness.Monitor monitor
    property color colour: Colours.palette.m3primary

    readonly property bool vertical: Config.bar.isVerticalFor(bar.screen.name)

    readonly property int maxLength: {
        const children = bar.container.children;
        const otherModules = children.filter(c => c.id && c.item !== this && c.id !== "spacer");
        const otherLength = otherModules.reduce((acc, curr) => acc + ((root.vertical ? curr.item.nonAnimHeight : curr.item.nonAnimWidth) ?? (root.vertical ? curr.height : curr.width)), 0);
        // Length - 1 cause repeater counts as a child
        return (root.vertical ? bar.height : bar.width) - otherLength - Appearance.spacing.normal * (children.length - 1) - bar.vPadding * 2;
    }
    property Title current: text1

    clip: true
    implicitWidth: root.vertical ? Math.max(icon.implicitWidth, current.implicitHeight) : icon.implicitWidth + current.implicitWidth + current.anchors.leftMargin
    implicitHeight: root.vertical ? icon.implicitHeight + current.implicitWidth + current.anchors.topMargin : Math.max(icon.implicitHeight, current.implicitHeight)

    MaterialIcon {
        id: icon

        anchors.horizontalCenter: root.vertical ? parent.horizontalCenter : undefined
        anchors.verticalCenter: root.vertical ? undefined : parent.verticalCenter

        animate: true
        text: Icons.getAppCategoryIcon(Hypr.activeToplevel?.lastIpcObject.class, "desktop_windows")
        color: root.colour
    }

    Title {
        id: text1
    }

    Title {
        id: text2
    }

    TextMetrics {
        id: metrics

        readonly property string rawTitle: Hypr.activeToplevel?.title ?? qsTr("Desktop")
        readonly property string compactTitle: {
            const idx = Math.max(rawTitle.lastIndexOf(" — "), rawTitle.lastIndexOf(" - "), rawTitle.lastIndexOf(" – "));
            return idx > 0 ? rawTitle.slice(idx + 3).trim() : rawTitle;
        }
        text: Config.bar.activeWindow.compact ? compactTitle : rawTitle
        font.pointSize: Appearance.font.size.smaller
        font.family: Appearance.font.family.mono
        elide: Qt.ElideRight
        elideWidth: root.maxLength - (root.vertical ? icon.height : icon.width + Appearance.spacing.small)

        onTextChanged: {
            const next = root.current === text1 ? text2 : text1;
            next.text = elidedText;
            root.current = next;
        }
        onElideWidthChanged: root.current.text = elidedText
    }

    Behavior on implicitHeight {
        Anim {
            duration: Appearance.anim.durations.expressiveDefaultSpatial
            easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
        }
    }

    Behavior on implicitWidth {
        Anim {
            duration: Appearance.anim.durations.expressiveDefaultSpatial
            easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
        }
    }

    component Title: StyledText {
        id: text

        anchors.horizontalCenter: root.vertical ? icon.horizontalCenter : undefined
        anchors.top: root.vertical ? icon.bottom : undefined
        anchors.topMargin: Appearance.spacing.small
        anchors.verticalCenter: root.vertical ? undefined : icon.verticalCenter
        anchors.left: root.vertical ? undefined : icon.right
        anchors.leftMargin: Appearance.spacing.small

        font.pointSize: metrics.font.pointSize
        font.family: metrics.font.family
        color: root.colour
        opacity: root.current === this ? 1 : 0

        transform: root.vertical ? [vertTranslate, vertRotation] : []

        width: root.vertical ? implicitHeight : implicitWidth
        height: root.vertical ? implicitWidth : implicitHeight

        Translate {
            id: vertTranslate

            x: Config.bar.activeWindow.inverted ? -text.implicitWidth + text.implicitHeight : 0
        }

        Rotation {
            id: vertRotation

            angle: Config.bar.activeWindow.inverted ? 270 : 90
            origin.x: text.implicitHeight / 2
            origin.y: text.implicitHeight / 2
        }

        Behavior on opacity {
            Anim {}
        }
    }
}
