pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

// Reload cover: a standalone quickshell config (`qs --path
// <conf>/reloadcover/shell.qml`) that paints every screen while
// `horneroctl shell restart` swaps the main shell underneath.
// Deliberately dependency-free (no shell modules): it must load even
// when the main config is broken. The orchestrator kills this process
// by PID after the new shell is up; a 60 s watchdog quits it anyway so
// a failed restart can never leave a permanent black screen.
ShellRoot {
    id: root

    property int dots: 0

    Timer {
        interval: 400
        running: true
        repeat: true
        onTriggered: root.dots = (root.dots + 1) % 4
    }

    // Safety net: never cover the desktop forever.
    Timer {
        interval: 60000
        running: true
        repeat: false
        onTriggered: Qt.quit()
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property ShellScreen modelData

            screen: modelData

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            color: "#0a0d18"

            Column {
                anchors.centerIn: parent
                spacing: 16

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "⌂"
                    color: "#22d3ee"
                    font.pixelSize: 72
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Restarting Hornero shell") + ".".repeat(root.dots)
                    color: "#eef1ff"
                    font.pixelSize: 22
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Your windows are untouched — the bar is just catching up.")
                    color: "#9aa3c7"
                    font.pixelSize: 14
                }
            }
        }
    }
}
