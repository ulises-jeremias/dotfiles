pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import Quickshell
import QtQuick

Item {
    id: root

    required property ShellScreen screen

    required property Repeater workspaces
    required property var occupied
    required property int groupOffset

    property list<var> pills: []

    onOccupiedChanged: {
        if (!occupied)
            return;
        let count = 0;
        const start = groupOffset;
        const end = start + Config.bar.workspaces.shown;
        for (const [ws, occ] of Object.entries(occupied)) {
            if (ws > start && ws <= end && occ) {
                const isFirstInGroup = Number(ws) === start + 1;
                const isLastInGroup = Number(ws) === end;
                if (isFirstInGroup || !occupied[ws - 1]) {
                    if (pills[count])
                        pills[count].start = ws;
                    else
                        pills.push(pillComp.createObject(root, {
                            start: ws
                        }));
                    count++;
                }
                if ((isLastInGroup || !occupied[ws + 1]) && pills[count - 1])
                    pills[count - 1].end = ws;
            }
        }
        if (pills.length > count)
            pills.splice(count, pills.length - count).forEach(p => p.destroy());
    }

    Repeater {
        model: ScriptModel {
            values: root.pills.filter(p => p)
        }

        StyledRect {
            id: rect

            required property var modelData

            readonly property bool vertical: Config.bar.isVerticalFor(screen.name)
            readonly property Workspace start: root.workspaces.count > 0 ? root.workspaces.itemAt(getWsIdx(modelData.start)) ?? null : null
            readonly property Workspace end: root.workspaces.count > 0 ? root.workspaces.itemAt(getWsIdx(modelData.end)) ?? null : null

            function getWsIdx(ws: int): int {
                let i = ws - 1;
                while (i < 0)
                    i += Config.bar.workspaces.shown;
                return i % Config.bar.workspaces.shown;
            }

            anchors.horizontalCenter: vertical ? root.horizontalCenter : undefined
            anchors.verticalCenter: vertical ? undefined : root.verticalCenter

            x: vertical ? 0 : (start?.x ?? 0) - 1
            y: vertical ? (start?.y ?? 0) - 1 : 0
            implicitWidth: vertical ? Config.bar.sizes.innerWidth - Appearance.padding.small * 2 + 2 : (start && end ? end.x + end.size - start.x + 2 : 0)
            implicitHeight: vertical ? (start && end ? end.y + end.size - start.y + 2 : 0) : Config.bar.sizes.innerWidth - Appearance.padding.small * 2 + 2

            color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)
            radius: Appearance.rounding.full

            scale: 0
            Component.onCompleted: scale = 1

            Behavior on scale {
                Anim {
                    easing.bezierCurve: Appearance.anim.curves.standardDecel
                }
            }

            Behavior on x {
                Anim {}
            }

            Behavior on y {
                Anim {}
            }

            Behavior on implicitWidth {
                Anim {}
            }

            Behavior on implicitHeight {
                Anim {}
            }
        }
    }

    component Pill: QtObject {
        property int start
        property int end
    }

    Component {
        id: pillComp

        Pill {}
    }
}
