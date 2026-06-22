pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.utils
import qs.config
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

// Window list item — flat row inside the window list card.
// No own background (transparent), uses parent's surfaceContainer.
Item {
    id: root

    required property HyprlandToplevel modelData
    required property bool isActive

    signal focusRequested()

    readonly property string addr: `0x${root.modelData.address}`
    readonly property bool floating: root.modelData.lastIpcObject?.floating ?? false
    readonly property bool pinned: root.modelData.lastIpcObject?.pinned ?? false
    readonly property int fullscreen: root.modelData.lastIpcObject?.fullscreen ?? 0

    implicitWidth: parent ? parent.width : 300
    implicitHeight: row.implicitHeight + Appearance.padding.small

    // Highlight background for active window
    StyledRect {
        anchors.fill: parent
        radius: Appearance.rounding.small
        color: root.isActive
            ? Qt.alpha(Colours.palette.m3primary, 0.12)
            : "transparent"
        visible: root.isActive
    }

    RowLayout {
        id: row

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: Appearance.padding.small

        spacing: Appearance.spacing.small

        // App icon
        MaterialIcon {
            Layout.alignment: Qt.AlignVCenter
            text: Icons.getAppCategoryIcon(root.modelData.lastIpcObject?.class ?? "", "terminal")
            color: root.isActive ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.normal
        }

        // Title
        StyledText {
            Layout.fillWidth: true
            text: root.modelData.title ?? qsTr("Unknown")
            font.pointSize: Appearance.font.size.small
            font.weight: root.isActive ? 600 : 400
            color: root.isActive ? Colours.palette.m3primary : Colours.palette.m3onSurface
            elide: Text.ElideRight
        }

        // State badges
        Row {
            visible: Config.dashboard.workspaces.showWindowBadges
            spacing: 2

            MaterialIcon {
                visible: root.floating
                text: "picture_in_picture"
                color: Colours.palette.m3tertiary
                font.pointSize: Appearance.font.size.small
            }

            MaterialIcon {
                visible: root.fullscreen > 0
                text: "fullscreen"
                color: Colours.palette.m3secondary
                font.pointSize: Appearance.font.size.small
            }

            MaterialIcon {
                visible: root.pinned
                text: "keep"
                color: Colours.palette.m3secondary
                font.pointSize: Appearance.font.size.small
            }
        }

        // Action buttons
        Row {
            visible: Config.dashboard.workspaces.enableWindowActions
            spacing: 2

            IconButton {
                type: IconButton.Text
                icon: root.floating ? "select_window" : "select_window_off"
                padding: Appearance.padding.small / 2
                font.pointSize: Appearance.font.size.small

                onClicked: Hypr.dispatch(`togglefloating address:${root.addr}`)
            }

            IconButton {
                type: IconButton.Text
                icon: "close"
                padding: Appearance.padding.small / 2
                font.pointSize: Appearance.font.size.small

                onClicked: Hypr.dispatch(`killwindow address:${root.addr}`)
            }
        }
    }

    // Click to focus
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        propagateComposedEvents: true
        onClicked: event => {
            root.focusRequested();
            event.accepted = false;
        }
    }
}
