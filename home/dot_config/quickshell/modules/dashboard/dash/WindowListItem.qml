pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.utils
import qs.config
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

// Window list item for the workspace detail panel.
//
// Shows app icon, title, state badges (floating/fullscreen/pinned),
// and action buttons (float/tile, pin, kill, move-to-WS).
Item {
    id: root

    required property HyprlandToplevel modelData
    required property bool isActive

    signal focusRequested()

    readonly property string addr: `0x${root.modelData.address}`
    readonly property bool floating: root.modelData.lastIpcObject?.floating ?? false
    readonly property bool pinned: root.modelData.lastIpcObject?.pinned ?? false
    readonly property int fullscreen: root.modelData.lastIpcObject?.fullscreen ?? 0

    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight

    StyledRect {
        id: card

        anchors.fill: parent

        radius: Appearance.rounding.small
        color: root.isActive
            ? Qt.alpha(Colours.palette.m3primary, 0.12)
            : Colours.layer(Colours.tPalette.m3surfaceContainerHigh, 1)
        border.width: root.isActive ? 1 : 0
        border.color: Colours.palette.m3primary

        Behavior on color {
            ColorAnimation {
                duration: Appearance.anim.durations.small
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: Appearance.padding.small

            spacing: Appearance.spacing.small

            // App icon
            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                text: Icons.getAppCategoryIcon(root.modelData.lastIpcObject?.class ?? "", "terminal")
                color: root.isActive ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.normal
            }

            // Title + badges
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: root.modelData.title ?? qsTr("Unknown")
                    font.pointSize: Appearance.font.size.small
                    font.weight: root.isActive ? 600 : 400
                    color: root.isActive ? Colours.palette.m3primary : Colours.palette.m3onSurface
                    elide: Text.ElideRight
                }

                // Badges row
                Row {
                    visible: Config.dashboard.workspaces.showWindowBadges
                    spacing: 2

                    // Floating badge
                    MaterialIcon {
                        visible: root.floating
                        text: "picture_in_picture"
                        color: Colours.palette.m3tertiary
                        font.pointSize: Appearance.font.size.small
                    }

                    // Fullscreen badge
                    MaterialIcon {
                        visible: root.fullscreen > 0
                        text: "fullscreen"
                        color: Colours.palette.m3secondary
                        font.pointSize: Appearance.font.size.small
                    }

                    // Pinned badge
                    MaterialIcon {
                        visible: root.pinned
                        text: "keep"
                        color: Colours.palette.m3secondary
                        font.pointSize: Appearance.font.size.small
                    }
                }
            }

            // Action buttons (only when window actions enabled)
            Row {
                visible: Config.dashboard.workspaces.enableWindowActions
                spacing: 2

                // Float/Tile toggle
                IconButton {
                    type: IconButton.Text
                    icon: root.floating ? "select_window" : "select_window_off"
                    padding: Appearance.padding.small / 2
                    font.pointSize: Appearance.font.size.small

                    onClicked: Hypr.dispatch(`togglefloating address:${root.addr}`)
                }

                // Pin/Unpin
                IconButton {
                    type: IconButton.Text
                    icon: root.pinned ? "push_pin" : "push_pin"
                    padding: Appearance.padding.small / 2
                    font.pointSize: Appearance.font.size.small
                    internalChecked: root.pinned
                    toggle: true

                    onClicked: Hypr.dispatch(`pin address:${root.addr}`)
                }

                // Kill
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
}
