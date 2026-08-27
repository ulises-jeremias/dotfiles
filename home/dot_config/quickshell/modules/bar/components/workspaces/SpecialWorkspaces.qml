pragma ComponentBehavior: Bound

import qs.components
import qs.components.effects
import qs.services
import qs.utils
import qs.config
import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property ShellScreen screen
    readonly property HyprlandMonitor monitor: Hypr.monitorFor(screen)
    readonly property string activeSpecial: (Config.bar.workspaces.perMonitorWorkspaces ? monitor : Hypr.focusedMonitor)?.lastIpcObject?.specialWorkspace?.name ?? ""
    readonly property bool vertical: Config.bar.isVertical()

    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: mask
    }

    Item {
        id: mask

        anchors.fill: parent
        layer.enabled: true
        visible: false

        Rectangle {
            anchors.fill: parent
            radius: Appearance.rounding.full

            gradient: Gradient {
                orientation: root.vertical ? Gradient.Vertical : Gradient.Horizontal

                GradientStop {
                    position: 0
                    color: Qt.rgba(0, 0, 0, 0)
                }
                GradientStop {
                    position: 0.3
                    color: Qt.rgba(0, 0, 0, 1)
                }
                GradientStop {
                    position: 0.7
                    color: Qt.rgba(0, 0, 0, 1)
                }
                GradientStop {
                    position: 1
                    color: Qt.rgba(0, 0, 0, 0)
                }
            }
        }

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: root.vertical ? parent.right : undefined
            anchors.bottom: root.vertical ? undefined : parent.bottom

            radius: Appearance.rounding.full
            implicitHeight: parent.height / 2
            implicitWidth: parent.width / 2
            opacity: root.vertical ? (view.contentY > 0 ? 0 : 1) : (view.contentX > 0 ? 0 : 1)

            Behavior on opacity {
                Anim {}
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: root.vertical ? parent.left : undefined
            anchors.right: root.vertical ? parent.right : undefined
            anchors.top: root.vertical ? undefined : parent.top

            radius: Appearance.rounding.full
            implicitHeight: parent.height / 2
            implicitWidth: parent.width / 2
            opacity: root.vertical ? (view.contentY < view.contentHeight - parent.height + Appearance.padding.small ? 0 : 1) : (view.contentX < view.contentWidth - parent.width + Appearance.padding.small ? 0 : 1)

            Behavior on opacity {
                Anim {}
            }
        }
    }

    ListView {
        id: view

        anchors.fill: parent
        spacing: Appearance.spacing.normal
        interactive: false
        orientation: root.vertical ? ListView.Vertical : ListView.Horizontal

        currentIndex: model.values.findIndex(w => w.name === root.activeSpecial)
        onCurrentIndexChanged: currentIndex = Qt.binding(() => model.values.findIndex(w => w.name === root.activeSpecial))

        model: ScriptModel {
            values: Hypr.workspaces.values.filter(w => w.name.startsWith("special:") && (!Config.bar.workspaces.perMonitorWorkspaces || w.monitor === root.monitor))
        }

        preferredHighlightBegin: 0
        preferredHighlightEnd: root.vertical ? height : width
        highlightRangeMode: ListView.StrictlyEnforceRange

        highlightFollowsCurrentItem: false
        highlight: Item {
            x: root.vertical ? 0 : view.currentItem?.x ?? 0
            y: root.vertical ? view.currentItem?.y ?? 0 : 0
            implicitWidth: root.vertical ? 0 : view.currentItem?.size ?? 0
            implicitHeight: root.vertical ? view.currentItem?.size ?? 0 : 0

            Behavior on x {
                Anim {}
            }

            Behavior on y {
                Anim {}
            }
        }

        delegate: GridLayout {
            id: ws

            required property HyprlandWorkspace modelData
            readonly property int size: root.vertical ? label.Layout.preferredHeight + (hasWindows ? windows.implicitHeight + Appearance.padding.small : 0) : label.Layout.preferredWidth + (hasWindows ? windows.implicitWidth + Appearance.padding.small : 0)
            property int wsId
            property string icon
            property bool hasWindows

            anchors.left: root.vertical ? view.contentItem.left : undefined
            anchors.right: root.vertical ? view.contentItem.right : undefined
            anchors.top: root.vertical ? undefined : view.contentItem.top
            anchors.bottom: root.vertical ? undefined : view.contentItem.bottom

            flow: root.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
            rows: root.vertical ? -1 : 1
            columns: root.vertical ? 1 : -1
            rowSpacing: 0
            columnSpacing: 0

            Component.onCompleted: {
                wsId = modelData.id;
                icon = Icons.getSpecialWsIcon(modelData.name);
                hasWindows = Config.bar.workspaces.showWindowsOnSpecialWorkspaces && modelData.lastIpcObject.windows > 0;
            }

            // Hacky thing cause modelData gets destroyed before the remove anim finishes
            Connections {
                target: ws.modelData

                function onIdChanged(): void {
                    if (ws.modelData)
                        ws.wsId = ws.modelData.id;
                }

                function onNameChanged(): void {
                    if (ws.modelData)
                        ws.icon = Icons.getSpecialWsIcon(ws.modelData.name);
                }

                function onLastIpcObjectChanged(): void {
                    if (ws.modelData)
                        ws.hasWindows = Config.bar.workspaces.showWindowsOnSpecialWorkspaces && ws.modelData.lastIpcObject.windows > 0;
                }
            }

            Connections {
                target: Config.bar.workspaces

                function onShowWindowsOnSpecialWorkspacesChanged(): void {
                    if (ws.modelData)
                        ws.hasWindows = Config.bar.workspaces.showWindowsOnSpecialWorkspaces && ws.modelData.lastIpcObject.windows > 0;
                }
            }

            Loader {
                id: label

                Layout.alignment: root.vertical ? Qt.AlignHCenter | Qt.AlignTop : Qt.AlignVCenter | Qt.AlignLeft
                Layout.preferredHeight: root.vertical ? Config.bar.sizes.innerWidth - Appearance.padding.small * 2 : implicitHeight
                Layout.preferredWidth: root.vertical ? implicitWidth : Config.bar.sizes.innerWidth - Appearance.padding.small * 2

                sourceComponent: ws.icon.length === 1 ? letterComp : iconComp

                Component {
                    id: iconComp

                    MaterialIcon {
                        fill: 1
                        text: ws.icon
                        verticalAlignment: Qt.AlignVCenter
                    }
                }

                Component {
                    id: letterComp

                    StyledText {
                        text: ws.icon
                        verticalAlignment: Qt.AlignVCenter
                    }
                }
            }

            Loader {
                id: windows

                Layout.alignment: root.vertical ? Qt.AlignHCenter : Qt.AlignVCenter
                Layout.fillHeight: root.vertical
                Layout.fillWidth: !root.vertical
                Layout.preferredHeight: root.vertical ? implicitHeight : -1
                Layout.preferredWidth: root.vertical ? -1 : implicitWidth

                visible: active
                active: ws.hasWindows

                sourceComponent: root.vertical ? vIconsComp : hIconsComp
                onLoaded: item.wsId = Qt.binding(() => ws.wsId)

                Behavior on Layout.preferredHeight {
                    Anim {}
                }

                Behavior on Layout.preferredWidth {
                    Anim {}
                }
            }
        }

        add: Transition {
            Anim {
                properties: "scale"
                from: 0
                to: 1
                easing.bezierCurve: Appearance.anim.curves.standardDecel
            }
        }

        remove: Transition {
            Anim {
                property: "scale"
                to: 0.5
                duration: Appearance.anim.durations.small
            }
            Anim {
                property: "opacity"
                to: 0
                duration: Appearance.anim.durations.small
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

        displaced: Transition {
            Anim {
                properties: "scale"
                to: 1
                easing.bezierCurve: Appearance.anim.curves.standardDecel
            }
            Anim {
                properties: "x,y"
            }
        }
    }

    Component {
        id: vIconsComp

        Column {
            property int wsId

            spacing: 0

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
                model: ScriptModel {
                    values: Hypr.toplevels.values.filter(c => c.workspace?.id === wsId)
                }

                MaterialIcon {
                    required property var modelData

                    grade: 0
                    text: Icons.getAppCategoryIcon(modelData.lastIpcObject.class, "terminal")
                    color: Colours.palette.m3onSurfaceVariant
                }
            }
        }
    }

    Component {
        id: hIconsComp

        Row {
            property int wsId

            spacing: 0

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
                model: ScriptModel {
                    values: Hypr.toplevels.values.filter(c => c.workspace?.id === wsId)
                }

                MaterialIcon {
                    required property var modelData

                    grade: 0
                    text: Icons.getAppCategoryIcon(modelData.lastIpcObject.class, "terminal")
                    color: Colours.palette.m3onSurfaceVariant
                }
            }
        }
    }

    Loader {
        active: Config.bar.workspaces.activeIndicator
        anchors.fill: parent

        sourceComponent: Item {
            StyledClippingRect {
                id: indicator

                anchors.left: root.vertical ? parent.left : undefined
                anchors.right: root.vertical ? parent.right : undefined
                anchors.top: root.vertical ? undefined : parent.top
                anchors.bottom: root.vertical ? undefined : parent.bottom

                x: root.vertical ? 0 : (view.currentItem?.x ?? 0) - view.contentX
                y: root.vertical ? (view.currentItem?.y ?? 0) - view.contentY : 0
                implicitWidth: root.vertical ? 0 : view.currentItem?.size ?? 0
                implicitHeight: root.vertical ? view.currentItem?.size ?? 0 : 0

                color: Colours.palette.m3tertiary
                radius: Appearance.rounding.full

                Colouriser {
                    source: view
                    sourceColor: Colours.palette.m3onSurface
                    colorizationColor: Colours.palette.m3onTertiary

                    anchors.horizontalCenter: root.vertical ? parent.horizontalCenter : undefined
                    anchors.verticalCenter: root.vertical ? undefined : parent.verticalCenter

                    x: root.vertical ? 0 : -indicator.x
                    y: root.vertical ? -indicator.y : 0
                    implicitWidth: view.width
                    implicitHeight: view.height
                }

                Behavior on x {
                    Anim {
                        easing.bezierCurve: Appearance.anim.curves.emphasized
                    }
                }

                Behavior on y {
                    Anim {
                        easing.bezierCurve: Appearance.anim.curves.emphasized
                    }
                }

                Behavior on implicitWidth {
                    Anim {
                        easing.bezierCurve: Appearance.anim.curves.emphasized
                    }
                }

                Behavior on implicitHeight {
                    Anim {
                        easing.bezierCurve: Appearance.anim.curves.emphasized
                    }
                }
            }
        }
    }

    MouseArea {
        property real startPos

        anchors.fill: view

        drag.target: view.contentItem
        drag.axis: root.vertical ? Drag.YAxis : Drag.XAxis
        drag.maximumY: root.vertical ? 0 : 0
        drag.minimumY: root.vertical ? Math.min(0, view.height - view.contentHeight - Appearance.padding.small) : 0
        drag.maximumX: root.vertical ? 0 : 0
        drag.minimumX: root.vertical ? 0 : Math.min(0, view.width - view.contentWidth - Appearance.padding.small)

        onPressed: event => startPos = root.vertical ? event.y : event.x

        onClicked: event => {
            if (Math.abs((root.vertical ? event.y : event.x) - startPos) > drag.threshold)
                return;

            const ws = view.itemAt(event.x, event.y);
            if (ws?.modelData)
                Hypr.dispatch(`togglespecialworkspace ${ws.modelData.name.slice(8)}`);
            else
                Hypr.dispatch("togglespecialworkspace special");
        }
    }
}
