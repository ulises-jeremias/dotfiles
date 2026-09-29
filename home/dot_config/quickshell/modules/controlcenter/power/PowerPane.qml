pragma ComponentBehavior: Bound

import ".."
import "../components"
import qs.components
import qs.components.controls
import qs.components.containers
import qs.components.effects
import qs.services
import qs.config
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

// Power & session pane: lock, suspend, reboot, shutdown and logout,
// all through `horneroctl power` with a two-step confirm. Nothing here
// runs on a single click: first click arms the exact action, the
// second click runs it, and arming expires when the pane reloads.
Item {
    id: root

    required property Session session

    anchors.fill: parent

    property string compositor: ""
    property string lockBackend: ""
    property string statusError: ""
    property bool busy: false
    property string armedAction: ""
    property string lastResult: ""

    function envelope(text: string): var {
        try {
            return JSON.parse(text);
        } catch (e) {
            return null;
        }
    }

    function refresh(): void {
        if (statusProc.running)
            return;
        root.statusError = "";
        statusProc.running = true;
    }

    function runPower(action: string): void {
        if (root.busy)
            return;
        if (root.armedAction !== action) {
            root.armedAction = action; // first click arms
            return;
        }
        root.armedAction = "";
        root.busy = true;
        root.lastResult = "";
        mutProc.command = ["horneroctl", "power", action, "--yes"];
        mutProc.running = true;
    }

    Component.onCompleted: root.refresh()

    Process {
        id: statusProc

        command: ["horneroctl", "--json", "power", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                const env = root.envelope(text);
                if (!env || env.ok !== true) {
                    root.statusError = (env && env.message) ? env.message : qsTr("Could not read power state.");
                    return;
                }
                const data = env.data || {};
                root.compositor = data.compositor || "";
                const lock = data.lockscreen && data.lockscreen !== "missing" ? data.lockscreen : data.hyprlock || "";
                root.lockBackend = lock;
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 || exitStatus !== 0)
                root.statusError = qsTr("Power status failed (exit %1).").arg(exitCode);
        }
    }

    Process {
        id: mutProc

        stdout: StdioCollector {
            onStreamFinished: root.lastResult = text.trim()
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0)
                    root.lastResult = text.trim();
            }
        }
        onExited: (exitCode, exitStatus) => {
            root.busy = false;
            if ((exitCode !== 0 || exitStatus !== 0) && root.lastResult.length === 0)
                root.lastResult = qsTr("Action failed (exit %1).").arg(exitCode);
            root.refresh();
        }
    }

    component PowerTile: StyledRect {
        id: tile

        required property string icon
        required property string label
        required property string action

        Layout.fillWidth: true
        radius: Appearance.rounding.normal
        color: tile.armed ? Colours.layer(Colours.palette.m3errorContainer, 2) : Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)
        implicitHeight: row.implicitHeight + Appearance.padding.normal * 2

        readonly property bool armed: root.armedAction === tile.action

        RowLayout {
            id: row

            anchors.fill: parent
            anchors.margins: Appearance.padding.normal
            spacing: Appearance.spacing.normal

            MaterialIcon {
                text: tile.icon
                color: tile.armed ? Colours.palette.m3onErrorContainer : Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.extraLarge
            }

            StyledText {
                Layout.fillWidth: true
                text: tile.armed ? qsTr("Click again to %1").arg(tile.label.toLowerCase()) : tile.label
                font.pointSize: Appearance.font.size.normal
                font.weight: tile.armed ? 600 : 400
            }

            TextButton {
                text: tile.armed ? qsTr("Confirm") : qsTr("Run")
                type: tile.armed ? TextButton.Filled : TextButton.Tonal
                enabled: !root.busy
                onClicked: root.runPower(tile.action)
            }
        }
    }

    ClippingRectangle {
        anchors.fill: parent
        anchors.margins: Appearance.padding.normal
        anchors.leftMargin: 0
        anchors.rightMargin: Appearance.padding.normal
        radius: border.innerRadius
        color: "transparent"

        StyledFlickable {
            id: flick

            anchors.fill: parent
            anchors.margins: Appearance.padding.large + Appearance.padding.normal
            anchors.leftMargin: Appearance.padding.large
            anchors.rightMargin: Appearance.padding.large
            flickableDirection: Flickable.VerticalFlick
            contentHeight: content.implicitHeight

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: flick
            }

            ColumnLayout {
                id: content

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: Appearance.spacing.normal

                SettingsHeader {
                    icon: "power_settings_new"
                    title: qsTr("Power & session")
                }

                // ── Backend state ────────────────────────────────────
                StyledText {
                    visible: root.compositor.length > 0 || root.lockBackend.length > 0
                    text: [root.compositor.length > 0 ? qsTr("Compositor: %1").arg(root.compositor) : "", root.lockBackend.length > 0 ? qsTr("Lock via %1").arg(root.lockBackend) : ""].filter(s => s.length > 0).join(" · ")
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.smaller
                    Layout.fillWidth: true
                }

                StyledText {
                    visible: root.statusError.length > 0
                    text: root.statusError
                    color: Colours.palette.m3error
                    font.pointSize: Appearance.font.size.smaller
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }

                PowerTile {
                    icon: "lock"
                    label: qsTr("Lock screen")
                    action: "lock"
                }

                PowerTile {
                    icon: "logout"
                    label: qsTr("Log out")
                    action: "logout"
                }

                PowerTile {
                    icon: "bedtime"
                    label: qsTr("Suspend")
                    action: "suspend"
                }

                PowerTile {
                    icon: "restart_alt"
                    label: qsTr("Reboot")
                    action: "reboot"
                }

                PowerTile {
                    icon: "power_settings_new"
                    label: qsTr("Shut down")
                    action: "shutdown"
                }

                // ── Last action result ───────────────────────────────
                StyledText {
                    visible: root.lastResult.length > 0
                    text: root.lastResult
                    font.pointSize: Appearance.font.size.smaller
                    font.family: Appearance.font.family.mono
                    color: Colours.palette.m3onSurfaceVariant
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }
            }
        }
    }

    InnerBorder {
        id: border

        leftThickness: 0
        rightThickness: Appearance.padding.normal
    }
}
