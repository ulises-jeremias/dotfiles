import qs.components
import qs.services
import qs.config
import qs.modules.osd as Osd
import qs.modules.notifications as Notifications
import qs.modules.session as Session
import qs.modules.launcher as Launcher
import qs.modules.dashboard as Dashboard
import qs.modules.bar.popouts as BarPopouts
import qs.modules.utilities as Utilities
import qs.modules.sidebar as Sidebar
import QtQuick
import QtQuick.Shapes

Shape {
    id: root

    required property Panels panels
    required property Item bar

    anchors.fill: parent
    anchors.leftMargin: bar.marginLeft
    anchors.rightMargin: bar.marginRight
    anchors.topMargin: bar.marginTop
    anchors.bottomMargin: bar.marginBottom
    preferredRendererType: Shape.CurveRenderer

    Osd.Background {
        wrapper: root.panels.osd

        startX: root.width - root.panels.session.width - root.panels.sidebar.width
        startY: (root.height - wrapper.height) / 2 - rounding
    }

    Notifications.Background {
        wrapper: root.panels.notifications
        sidebar: sidebar

        startX: root.width
        startY: 0
    }

    Session.Background {
        wrapper: root.panels.session

        startX: root.width - root.panels.sidebar.width
        startY: (root.height - wrapper.height) / 2 - rounding
    }

    Launcher.Background {
        wrapper: root.panels.launcher

        // Track the wrapper's outer edge: identical to the panel edge when the
        // bar is attached, but stops at the wrapper when the bar floats
        // (otherwise the connection "wings" dangle next to the floating pill)
        startX: (root.width - wrapper.width) / 2 - rounding
        startY: wrapper.y + wrapper.height
    }

    Dashboard.Background {
        wrapper: root.panels.dashboard

        startX: (root.width - wrapper.width) / 2 - rounding
        startY: wrapper.y
    }

    BarPopouts.Background {
        wrapper: root.panels.popouts
        invertBottomRounding: wrapper.y + wrapper.height + 1 >= root.height

        startX: wrapper.x
        startY: wrapper.y - rounding * sideRounding
    }

    StyledRect {
        readonly property BarPopouts.Wrapper wrapper: root.panels.popouts

        x: wrapper.x
        y: wrapper.y
        width: wrapper.width
        height: wrapper.height
        visible: wrapper.visible && !wrapper.usesConnectedBackground
        color: Colours.palette.m3surface
        radius: wrapper.isDetached ? Appearance.rounding.normal : Config.border.rounding

        Behavior on color {
            CAnim {}
        }
    }

    Utilities.Background {
        wrapper: root.panels.utilities
        sidebar: sidebar

        startX: root.width
        startY: wrapper.y + wrapper.height
    }

    Sidebar.Background {
        id: sidebar

        wrapper: root.panels.sidebar
        panels: root.panels

        startX: root.width
        startY: root.panels.notifications.height
    }
}
