pragma ComponentBehavior: Bound

import qs.components
import qs.config
import "popouts" as BarPopouts
import Quickshell
import QtQuick

Item {
    id: root

    required property ShellScreen screen
    required property PersistentProperties visibilities
    required property BarPopouts.Wrapper popouts
    required property bool disabled

    readonly property string position: Config.bar.position
    readonly property bool vertical: Config.bar.isVertical()
    readonly property bool floating: Config.bar.isFloating()
    readonly property int padding: Math.max(Appearance.padding.smaller, Config.border.thickness)
    // Size of the bar across its screen edge (including the float gap when floating)
    readonly property int thickness: Config.bar.sizes.innerWidth + padding * 2 + (floating ? Config.bar.floatingMargin : 0)
    readonly property int contentWidth: thickness // kept for external references
    readonly property int exclusiveZone: !disabled && (Config.bar.persistent || visibilities.bar) ? thickness : Config.border.thickness
    readonly property bool shouldBeVisible: !disabled && (Config.bar.persistent || visibilities.bar || isHovered)
    property bool isHovered

    // Animated size along the bar's main axis
    readonly property int currentThickness: vertical ? implicitWidth : implicitHeight

    // Margins reserved on each screen edge (used by drawers mask, panels, border, backgrounds)
    readonly property int marginLeft: position === "left" ? currentThickness : Config.border.thickness
    readonly property int marginRight: position === "right" ? currentThickness : Config.border.thickness
    readonly property int marginTop: position === "top" ? currentThickness : Config.border.thickness
    readonly property int marginBottom: position === "bottom" ? currentThickness : Config.border.thickness

    function closeTray(): void {
        content.item?.closeTray();
    }

    function checkPopout(pos: real): void {
        content.item?.checkPopout(pos);
    }

    function handleWheel(pos: real, angleDelta: point): void {
        content.item?.handleWheel(pos, angleDelta);
    }

    visible: (vertical ? width : height) > Config.border.thickness
    implicitWidth: Config.border.thickness
    implicitHeight: Config.border.thickness

    states: [
        State {
            name: "visibleV"
            when: root.vertical && root.shouldBeVisible

            PropertyChanges {
                root.implicitWidth: root.thickness
            }
        },
        State {
            name: "visibleH"
            when: !root.vertical && root.shouldBeVisible

            PropertyChanges {
                root.implicitHeight: root.thickness
            }
        }
    ]

    transitions: [
        Transition {
            from: ""
            to: "visibleV,visibleH"

            Anim {
                target: root
                properties: "implicitWidth,implicitHeight"
                duration: Appearance.anim.durations.expressiveDefaultSpatial
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
            }
        },
        Transition {
            from: "visibleV,visibleH"
            to: ""

            Anim {
                target: root
                properties: "implicitWidth,implicitHeight"
                easing.bezierCurve: Appearance.anim.curves.emphasized
            }
        }
    ]

    Loader {
        id: content

        // The bar always fills the wrapper (which is the edge strip). Bar.qml
        // positions its inner "pill" itself, which keeps anchors static and
        // avoids anchor conflicts during live config reloads.
        anchors.fill: parent

        active: root.shouldBeVisible || root.visible

        sourceComponent: Bar {
            screen: root.screen
            visibilities: root.visibilities
            popouts: root.popouts
        }
    }
}
