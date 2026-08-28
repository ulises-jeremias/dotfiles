pragma ComponentBehavior: Bound

import Quickshell
import qs.components
import qs.services
import qs.config
import Quickshell.Services.SystemTray
import QtQuick

StyledRect {
    id: root

    required property ShellScreen screen

    readonly property alias layout: layout
    readonly property alias expandIcon: expandIcon
    // Repeater of the active orientation (exposed by the loaded Column/Row)
    readonly property var items: layout.item?.trayItems ?? null

    readonly property bool vertical: Config.bar.isVerticalFor(screen.name)

    readonly property int padding: Config.bar.tray.background ? Appearance.padding.normal : Appearance.padding.small
    readonly property int spacing: Config.bar.tray.background ? Appearance.spacing.small : 0

    property bool expanded

    readonly property real nonAnimHeight: {
        if (!Config.bar.tray.compact)
            return layout.implicitHeight + padding * 2;
        return (expanded ? expandIcon.implicitHeight + layout.implicitHeight + spacing : expandIcon.implicitHeight) + padding * 2;
    }
    readonly property real nonAnimWidth: {
        if (!Config.bar.tray.compact)
            return layout.implicitWidth + padding * 2;
        return (expanded ? expandIcon.implicitWidth + layout.implicitWidth + spacing : expandIcon.implicitWidth) + padding * 2;
    }

    clip: true
    visible: vertical ? height > 0 : width > 0

    implicitWidth: vertical ? Config.bar.sizes.innerWidth : nonAnimWidth
    implicitHeight: vertical ? nonAnimHeight : Config.bar.sizes.innerWidth

    color: Qt.alpha(Colours.tPalette.m3surfaceContainer, (Config.bar.tray.background && items.count > 0) ? Colours.tPalette.m3surfaceContainer.a : 0)
    radius: Appearance.rounding.full

    Loader {
        id: layout

        anchors.horizontalCenter: root.vertical ? parent.horizontalCenter : undefined
        anchors.top: root.vertical ? parent.top : undefined
        anchors.topMargin: root.padding
        anchors.verticalCenter: root.vertical ? undefined : parent.verticalCenter
        anchors.left: root.vertical ? undefined : parent.left
        anchors.leftMargin: root.padding

        opacity: root.expanded || !Config.bar.tray.compact ? 1 : 0

        sourceComponent: root.vertical ? columnComp : rowComp

        Behavior on opacity {
            Anim {}
        }
    }

    Component {
        id: columnComp

        Column {
            readonly property alias trayItems: items

            spacing: Appearance.spacing.small

            add: Transition {
                Anim {
                    properties: "scale"
                    from: 0
                    to: 1
                    easing.bezierCurve: Appearance.anim.curves.standardDecel
                }
            }

            move: Transition {
                Anim {
                    properties: "scale"
                    to: 1
                    easing.bezierCurve: Appearance.anim.curves.standardDecel
                }
                Anim {
                    properties: "x,y"
                }
            }

            Repeater {
                id: items

                model: SystemTray.items

                TrayItem {}
            }
        }
    }

    Component {
        id: rowComp

        Row {
            readonly property alias trayItems: hItems

            spacing: Appearance.spacing.small

            add: Transition {
                Anim {
                    properties: "scale"
                    from: 0
                    to: 1
                    easing.bezierCurve: Appearance.anim.curves.standardDecel
                }
            }

            move: Transition {
                Anim {
                    properties: "scale"
                    to: 1
                    easing.bezierCurve: Appearance.anim.curves.standardDecel
                }
                Anim {
                    properties: "x,y"
                }
            }

            Repeater {
                id: hItems

                model: SystemTray.items

                TrayItem {}
            }
        }
    }

    Loader {
        id: expandIcon

        anchors.horizontalCenter: root.vertical ? parent.horizontalCenter : undefined
        anchors.bottom: root.vertical ? parent.bottom : undefined
        anchors.verticalCenter: root.vertical ? undefined : parent.verticalCenter
        anchors.right: root.vertical ? undefined : parent.right

        active: Config.bar.tray.compact && layout.children.length > 0

        sourceComponent: Item {
            implicitWidth: root.vertical ? expandIconInner.implicitWidth : expandIconInner.implicitWidth - Appearance.padding.small * 2
            implicitHeight: root.vertical ? expandIconInner.implicitHeight - Appearance.padding.small * 2 : expandIconInner.implicitHeight

            MaterialIcon {
                id: expandIconInner

                anchors.horizontalCenter: root.vertical ? parent.horizontalCenter : undefined
                anchors.bottom: root.vertical ? parent.bottom : undefined
                anchors.bottomMargin: root.vertical ? (Config.bar.tray.background ? Appearance.padding.small : -Appearance.padding.small) : 0
                anchors.verticalCenter: root.vertical ? undefined : parent.verticalCenter
                anchors.right: root.vertical ? undefined : parent.right
                anchors.rightMargin: root.vertical ? 0 : (Config.bar.tray.background ? Appearance.padding.small : -Appearance.padding.small)
                text: root.vertical ? "expand_less" : "chevron_right"
                font.pointSize: Appearance.font.size.large
                rotation: root.expanded ? 180 : 0

                Behavior on rotation {
                    Anim {}
                }

                Behavior on anchors.bottomMargin {
                    Anim {}
                }

                Behavior on anchors.rightMargin {
                    Anim {}
                }
            }
        }
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
}
