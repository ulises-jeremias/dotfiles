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
        exclusiveZone: Config.bar.position === "left" ? root.bar.exclusiveZone : Config.border.thickness
    }

    ExclusionZone {
        anchors.top: true
        exclusiveZone: Config.bar.position === "top" ? root.bar.exclusiveZone : Config.border.thickness
    }

    ExclusionZone {
        anchors.right: true
        exclusiveZone: Config.bar.position === "right" ? root.bar.exclusiveZone : Config.border.thickness
    }

    ExclusionZone {
        anchors.bottom: true
        exclusiveZone: Config.bar.position === "bottom" ? root.bar.exclusiveZone : Config.border.thickness
    }

    component ExclusionZone: StyledWindow {
        screen: root.screen
        name: "border-exclusion"
        exclusiveZone: Config.border.thickness
        mask: Region {}
        implicitWidth: 1
        implicitHeight: 1
    }
}
