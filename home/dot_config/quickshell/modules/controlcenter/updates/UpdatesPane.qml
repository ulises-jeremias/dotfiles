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

// Updates & backups pane: system update state plus config backups,
// both driven by horneroctl (read-only until an explicit action).
// Mirrors the Hub-style "update island": determinate state first,
// one clearly-marked mutating action second, refresh after every run.
Item {
    id: root

    required property Session session

    anchors.fill: parent

    // ── State ────────────────────────────────────────────────────────────────
    property int pendingCount: -1 // -1 = unknown yet
    property var pendingList: []
    property string updatesError: ""
    property string backupsError: ""
    property var backupList: []
    // The CLI exits nonzero on empty/error states it already reports as
    // JSON (ok:false + message): stdout wins over the exit code, so a
    // an answered query never shows a spurious "(exit N)" error.
    property bool updatesAnswered: false
    property bool backupsAnswered: false
    property bool busy: false
    property string lastAction: ""
    property string lastResult: ""
    // Two-step confirm for the mutating actions: first click arms, second
    // click runs. Any other click path resets.
    property string armedAction: ""

    function envelope(text: string): var {
        try {
            return JSON.parse(text);
        } catch (e) {
            return null;
        }
    }

    function refresh(): void {
        if (updatesProc.running || backupsProc.running)
            return;
        root.updatesError = "";
        root.backupsError = "";
        root.updatesAnswered = false;
        root.backupsAnswered = false;
        updatesProc.running = true;
        backupsProc.running = true;
    }

    function runMutating(action: string, argv: var): void {
        if (root.busy)
            return;
        if (root.armedAction !== action) {
            root.armedAction = action; // first click arms
            return;
        }
        root.armedAction = "";
        root.busy = true;
        root.lastAction = action;
        root.lastResult = "";
        mutProc.command = argv;
        mutProc.running = true;
    }

    Component.onCompleted: root.refresh()

    Process {
        id: updatesProc

        command: ["horneroctl", "--json", "package", "check"]
        stdout: StdioCollector {
            onStreamFinished: {
                const env = root.envelope(text);
                root.updatesAnswered = env !== null;
                if (!env || env.ok !== true) {
                    root.updatesError = (env && env.message) ? env.message : qsTr("Could not read pending updates.");
                    root.pendingCount = -1;
                    root.pendingList = [];
                    return;
                }
                const count = parseInt(env.data && env.data.count, 10);
                root.pendingCount = isNaN(count) ? 0 : count;
                const lines = String(env.message || "").split("\n").filter(l => l.trim().length > 0);
                // The summary line ("N update(s) pending") is the count, not
                // a package: keep only "old -> new" rows.
                root.pendingList = lines.filter(l => l.indexOf("->") !== -1);
            }
        }
        onExited: (exitCode, exitStatus) => {
            if ((exitCode !== 0 || exitStatus !== 0) && !root.updatesAnswered) {
                root.updatesError = qsTr("Update check failed (exit %1).").arg(exitCode);
                root.pendingCount = -1;
            }
        }
    }

    Process {
        id: backupsProc

        command: ["horneroctl", "--json", "backup", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const env = root.envelope(text);
                root.backupsAnswered = env !== null;
                if (!env || env.ok !== true) {
                    // No backups yet is a state, not an error: the CLI says
                    // so in message, and the empty state below explains it.
                    root.backupList = [];
                    root.backupsError = "";
                    return;
                }
                const lines = String(env.message || "").split("\n").filter(l => l.trim().length > 0);
                root.backupList = lines;
            }
        }
        onExited: (exitCode, exitStatus) => {
            if ((exitCode !== 0 || exitStatus !== 0) && !root.backupsAnswered)
                root.backupsError = qsTr("Backup list failed (exit %1).").arg(exitCode);
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

    // ── Main layout ──────────────────────────────────────────────────────────
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
                    icon: "system_update"
                    title: qsTr("Updates & backups")
                }

                // ── Status card ──────────────────────────────────────────
                StyledRect {
                    Layout.fillWidth: true
                    radius: Appearance.rounding.normal
                    color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)

                    implicitHeight: statusRow.implicitHeight + Appearance.padding.normal * 2

                    RowLayout {
                        id: statusRow

                        anchors.fill: parent
                        anchors.margins: Appearance.padding.normal
                        spacing: Appearance.spacing.normal

                        MaterialIcon {
                            text: root.pendingCount > 0 ? "update" : "check_circle"
                            color: root.pendingCount > 0 ? Colours.palette.m3tertiary : Colours.palette.m3primary
                            font.pointSize: Appearance.font.size.extraLarge
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            StyledText {
                                text: root.pendingCount < 0 ? qsTr("Checking for updates…") : root.pendingCount === 0 ? qsTr("System up to date") : qsTr("%n update(s) pending", "", root.pendingCount)
                                font.pointSize: Appearance.font.size.normal
                                font.weight: 600
                            }

                            StyledText {
                                visible: root.updatesError.length > 0
                                text: root.updatesError
                                color: Colours.palette.m3error
                                font.pointSize: Appearance.font.size.smaller
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                            }
                        }

                        TextButton {
                            text: qsTr("Refresh")
                            type: TextButton.Tonal
                            enabled: !updatesProc.running
                            onClicked: root.refresh()
                        }
                    }
                }

                // ── Pending list ─────────────────────────────────────────
                CollapsibleSection {
                    visible: root.pendingList.length > 0
                    title: qsTr("Pending packages (%1)").arg(root.pendingList.length)

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Repeater {
                            model: root.pendingList

                            StyledText {
                                required property string modelData

                                Layout.fillWidth: true
                                text: modelData
                                font.pointSize: Appearance.font.size.smaller
                                font.family: Appearance.font.family.mono
                                color: Colours.palette.m3onSurfaceVariant
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                // ── Upgrade (armed, mutating) ────────────────────────────
                TextButton {
                    Layout.fillWidth: true
                    text: root.armedAction === "upgrade" ? qsTr("Click again to upgrade now") : qsTr("Upgrade system now")
                    type: root.armedAction === "upgrade" ? TextButton.Filled : TextButton.Tonal
                    enabled: !root.busy && root.pendingCount > 0
                    onClicked: root.runMutating("upgrade", ["horneroctl", "package", "upgrade", "--yes"])
                }

                // ── Backups ──────────────────────────────────────────────
                StyledText {
                    text: qsTr("Backups")
                    font.pointSize: Appearance.font.size.normal
                    font.weight: 600
                }

                StyledText {
                    visible: root.backupList.length === 0 && root.backupsError.length === 0
                    text: qsTr("No backups yet. Create one before big changes — restore brings it back.")
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.smaller
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }

                StyledText {
                    visible: root.backupsError.length > 0
                    text: root.backupsError
                    color: Colours.palette.m3error
                    font.pointSize: Appearance.font.size.smaller
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }

                Repeater {
                    model: root.backupList

                    StyledText {
                        required property string modelData

                        Layout.fillWidth: true
                        text: modelData
                        font.pointSize: Appearance.font.size.smaller
                        font.family: Appearance.font.family.mono
                        color: Colours.palette.m3onSurfaceVariant
                        elide: Text.ElideRight
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.small

                    TextButton {
                        Layout.fillWidth: true
                        text: root.armedAction === "backup" ? qsTr("Click again to back up") : qsTr("Create backup")
                        type: TextButton.Tonal
                        enabled: !root.busy
                        onClicked: root.runMutating("backup", ["horneroctl", "backup", "create", "--yes"])
                    }

                    TextButton {
                        text: qsTr("Refresh")
                        type: TextButton.Text
                        enabled: !backupsProc.running
                        onClicked: root.refresh()
                    }
                }

                // ── Last action result ───────────────────────────────────
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
