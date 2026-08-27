pragma ComponentBehavior: Bound

import qs.components.containers
import qs.config
import Quickshell
import QtQuick

Scope {
    id: root

    required property ShellScreen screen
    required property Item bar

    ExclusionZone {
        anchors.left: true
        exclusiveZone: root.bar.reservedLeft
    }

    ExclusionZone {
        anchors.top: true
        exclusiveZone: root.bar.reservedTop
    }

    ExclusionZone {
        anchors.right: true
        exclusiveZone: root.bar.reservedRight
    }

    ExclusionZone {
        anchors.bottom: true
        exclusiveZone: root.bar.reservedBottom
    }

    component ExclusionZone: StyledWindow {
        screen: root.screen
        name: "border-exclusion"
        exclusiveZone: 0
        mask: Region {}
        implicitWidth: 1
        implicitHeight: 1
    }
}
