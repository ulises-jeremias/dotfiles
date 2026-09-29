pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import qs.utils
import Quickshell
import QtQuick

// Session menu: one armed action per button — first press arms (with a
// confirm label), second press runs. Mirrors the control-center
// PowerTile pattern so destructive actions never fire on a stray key.
Column {
    id: root

    required property PersistentProperties visibilities

    padding: Appearance.padding.large
    spacing: Appearance.spacing.normal

    // Two-step confirm for every action: first press arms, second press
    // runs. Focus loss or Escape resets.
    property string armedAction: ""

    function runOrArm(action: string, command: var): void {
        if (root.armedAction !== action) {
            root.armedAction = action; // first press arms
            return;
        }
        root.armedAction = "";
        Quickshell.execDetached(command);
    }

    SessionButton {
        id: logout

        action: "logout"
        label: qsTr("Log out")
        icon: Config.session.icons.logout
        command: Config.session.commands.logout

        KeyNavigation.down: shutdown

        Component.onCompleted: forceActiveFocus()

        Connections {
            target: root.visibilities

            function onLauncherChanged(): void {
                if (!root.visibilities.launcher)
                    logout.forceActiveFocus();
            }
        }
    }

    SessionButton {
        id: shutdown

        action: "shutdown"
        label: qsTr("Shut down")
        icon: Config.session.icons.shutdown
        command: Config.session.commands.shutdown

        KeyNavigation.up: logout
        KeyNavigation.down: hibernate
    }

    AnimatedImage {
        width: Config.session.sizes.button
        height: Config.session.sizes.button
        sourceSize.width: width
        sourceSize.height: height

        playing: visible
        asynchronous: true
        speed: Appearance.anim.sessionGifSpeed
        source: Paths.absolutePath(Config.paths.sessionGif)
    }

    SessionButton {
        id: hibernate

        action: "hibernate"
        label: qsTr("Hibernate")
        icon: Config.session.icons.hibernate
        command: Config.session.commands.hibernate

        KeyNavigation.up: shutdown
        KeyNavigation.down: reboot
    }

    SessionButton {
        id: reboot

        action: "reboot"
        label: qsTr("Restart")
        icon: Config.session.icons.reboot
        command: Config.session.commands.reboot

        KeyNavigation.up: hibernate
    }

    component SessionButton: Column {
        id: entry

        required property string action
        required property string label
        required property string icon
        required property list<string> command

        readonly property bool armed: root.armedAction === entry.action

        spacing: 4
        focus: true

        Keys.onEnterPressed: root.runOrArm(entry.action, entry.command)
        Keys.onReturnPressed: root.runOrArm(entry.action, entry.command)
        Keys.onEscapePressed: event => {
            if (root.armedAction.length > 0) {
                root.armedAction = ""; // first Escape disarms
                event.accepted = true;
            } else {
                root.visibilities.session = false;
            }
        }
        Keys.onPressed: event => {
            if (!Config.session.vimKeybinds)
                return;

            if (event.modifiers & Qt.ControlModifier) {
                if (event.key === Qt.Key_J && KeyNavigation.down) {
                    KeyNavigation.down.focus = true;
                    event.accepted = true;
                } else if (event.key === Qt.Key_K && KeyNavigation.up) {
                    KeyNavigation.up.focus = true;
                    event.accepted = true;
                }
            } else if (event.key === Qt.Key_Tab && KeyNavigation.down) {
                KeyNavigation.down.focus = true;
                event.accepted = true;
            } else if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                if (KeyNavigation.up) {
                    KeyNavigation.up.focus = true;
                    event.accepted = true;
                }
            }
        }

        onActiveFocusChanged: {
            if (!activeFocus && root.armedAction === entry.action)
                root.armedAction = "";
        }

        StyledRect {
            id: button

            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth: Config.session.sizes.button
            implicitHeight: Config.session.sizes.button

            radius: Appearance.rounding.large
            color: entry.armed ? Colours.palette.m3errorContainer : entry.activeFocus ? Colours.palette.m3secondaryContainer : Colours.tPalette.m3surfaceContainer

            StateLayer {
                radius: parent.radius
                color: entry.armed ? Colours.palette.m3onErrorContainer : entry.activeFocus ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface

                function onClicked(): void {
                    entry.forceActiveFocus();
                    root.runOrArm(entry.action, entry.command);
                }
            }

            MaterialIcon {
                anchors.centerIn: parent

                text: entry.icon
                color: entry.armed ? Colours.palette.m3onErrorContainer : entry.activeFocus ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                font.pointSize: Appearance.font.size.extraLarge
                font.weight: 500
            }
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: entry.armed ? qsTr("Confirm?") : entry.label
            color: entry.armed ? Colours.palette.m3error : Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.smaller
        }
    }
}
