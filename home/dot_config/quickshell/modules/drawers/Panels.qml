import qs.config
import qs.modules.osd as Osd
import qs.modules.notifications as Notifications
import qs.modules.session as Session
import qs.modules.launcher as Launcher
import qs.modules.dashboard as Dashboard
import qs.modules.layoutpicker as LayoutPicker
import qs.modules.bar.popouts as BarPopouts
import qs.modules.utilities as Utilities
import qs.modules.utilities.toasts as Toasts
import qs.modules.sidebar as Sidebar
import Quickshell
import QtQuick

Item {
    id: root

    required property ShellScreen screen
    required property PersistentProperties visibilities
    required property Item bar

    readonly property alias osd: osd
    readonly property alias notifications: notifications
    readonly property alias session: session
    readonly property alias launcher: launcher
    readonly property alias dashboard: dashboard
    readonly property alias popouts: popouts
    readonly property alias utilities: utilities
    readonly property alias toasts: toasts
    readonly property alias sidebar: sidebar
    readonly property alias layoutPicker: layoutPicker

    anchors.fill: parent
    anchors.leftMargin: bar.marginLeft + (bar.floating && bar.position === "left" ? Appearance.spacing.normal : 0)
    anchors.rightMargin: bar.marginRight + (bar.floating && bar.position === "right" ? Appearance.spacing.normal : 0)
    anchors.topMargin: bar.marginTop + (bar.floating && bar.position === "top" ? Appearance.spacing.normal : 0)
    anchors.bottomMargin: bar.marginBottom + (bar.floating && bar.position === "bottom" ? Appearance.spacing.normal : 0)

    Osd.Wrapper {
        id: osd

        clip: session.width > 0 || sidebar.width > 0
        screen: root.screen
        visibilities: root.visibilities

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: session.width + sidebar.width
    }

    Notifications.Wrapper {
        id: notifications

        visibilities: root.visibilities
        panels: root

        anchors.top: parent.top
        anchors.right: parent.right
    }

    Session.Wrapper {
        id: session

        clip: sidebar.width > 0
        visibilities: root.visibilities
        panels: root

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: sidebar.width
    }

    Launcher.Wrapper {
        id: launcher

        screen: root.screen
        visibilities: root.visibilities
        panels: root

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
    }

    Dashboard.Wrapper {
        id: dashboard

        visibilities: root.visibilities

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
    }

    BarPopouts.Wrapper {
        id: popouts

        screen: root.screen

        x: {
            if (isDetached)
                return (root.width - nonAnimWidth) / 2;
            if (Config.bar.isVerticalFor(root.screen.name))
                return Config.bar.positionFor(root.screen.name) === "right" ? root.width - nonAnimWidth : 0;

            const off = currentCenter - bar.marginLeft - nonAnimWidth / 2;
            const diff = root.width - Math.floor(off + nonAnimWidth);
            if (diff < 0)
                return off + diff;
            return Math.max(off, 0);
        }
        y: {
            if (isDetached)
                return (root.height - nonAnimHeight) / 2;
            if (!Config.bar.isVerticalFor(root.screen.name))
                return Config.bar.positionFor(root.screen.name) === "bottom" ? root.height - nonAnimHeight : 0;

            const off = currentCenter - bar.marginTop - nonAnimHeight / 2;
            const diff = root.height - Math.floor(off + nonAnimHeight);
            if (diff < 0)
                return off + diff;
            return Math.max(off, 0);
        }
    }

    Utilities.Wrapper {
        id: utilities

        visibilities: root.visibilities
        sidebar: sidebar
        popouts: popouts

        anchors.bottom: parent.bottom
        anchors.right: parent.right
    }

    Toasts.Toasts {
        id: toasts

        anchors.bottom: sidebar.visible ? parent.bottom : utilities.top
        anchors.right: sidebar.left
        anchors.margins: Appearance.padding.normal
    }

    Sidebar.Wrapper {
        id: sidebar

        visibilities: root.visibilities
        panels: root

        anchors.top: notifications.bottom
        anchors.bottom: utilities.top
        anchors.right: parent.right
    }

    LayoutPicker.Wrapper {
        id: layoutPicker

        visibilities: root.visibilities
        panels: root

        anchors.centerIn: parent
    }
}
