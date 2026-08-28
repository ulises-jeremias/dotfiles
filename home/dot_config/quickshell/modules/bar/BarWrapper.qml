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
    required property bool frameVisible

    readonly property string screenName: screen.name
    readonly property string position: Config.bar.positionFor(screenName)
    readonly property bool vertical: Config.bar.isVerticalFor(screenName)
    readonly property bool floating: Config.bar.isFloatingFor(screenName)
    readonly property bool reserves: Config.bar.reservesSpaceFor(screenName)
    readonly property int frameInset: frameVisible ? Config.border.thickness : 0
    readonly property int padding: Math.max(Appearance.padding.smaller, Config.border.thickness)
    // Size of the bar across its screen edge (including the float gap when floating)
    readonly property int thickness: Config.bar.sizes.innerWidth + padding * 2
    readonly property int contentWidth: thickness // kept for external references
    readonly property int exclusiveZone: reserves && !disabled && (Config.bar.persistent || visibilities.bar) ? thickness + (floating ? Config.bar.floatingMargin : 0) : frameInset
    readonly property bool shouldBeVisible: !disabled && (Config.bar.persistent || visibilities.bar || isHovered)
    property bool isHovered

    // Animated size along the bar's main axis
    readonly property int currentThickness: vertical ? implicitWidth : implicitHeight
    readonly property Item visualItem: content.item?.visualItem ?? null
    readonly property real visualX: x + (visualItem?.x ?? 0)
    readonly property real visualY: y + (visualItem?.y ?? 0)
    readonly property real visualWidth: visualItem?.width ?? 0
    readonly property real visualHeight: visualItem?.height ?? 0

    // Shell panels avoid the visible bar even when a floating bar overlays clients.
    readonly property int marginLeft: position === "left" ? currentThickness : frameInset
    readonly property int marginRight: position === "right" ? currentThickness : frameInset
    readonly property int marginTop: position === "top" ? currentThickness : frameInset
    readonly property int marginBottom: position === "bottom" ? currentThickness : frameInset

    // Layer-shell reservations are independent from shell panel placement.
    readonly property int reservedLeft: position === "left" ? exclusiveZone : frameInset
    readonly property int reservedRight: position === "right" ? exclusiveZone : frameInset
    readonly property int reservedTop: position === "top" ? exclusiveZone : frameInset
    readonly property int reservedBottom: position === "bottom" ? exclusiveZone : frameInset

    function containsVisualPoint(x: real, y: real): bool {
        if (!visualItem || !root.visible)
            return false;
        return x >= visualX && x <= visualX + visualWidth && y >= visualY && y <= visualY + visualHeight;
    }

    function closeTray(): void {
        content.item?.closeTray();
    }

    function checkPopout(pos: real): void {
        content.item?.checkPopout(pos);
    }

    function handleWheel(pos: real, angleDelta: point): void {
        content.item?.handleWheel(pos, angleDelta);
    }

    visible: (vertical ? width : height) > frameInset
    implicitWidth: frameInset
    implicitHeight: frameInset

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
