import qs.components
import qs.components.controls
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    implicitWidth: row.implicitWidth + Appearance.padding.large * 2
    implicitHeight: row.implicitHeight + Appearance.padding.normal * 2

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Appearance.spacing.small

        // Night mode toggle
        ToggleChip {
            icon: "dark_mode"
            label: qsTr("Night")
            active: false  // No persistent service — just fire the script
            onToggled: Quickshell.execDetached(["dots-night-mode", "toggle"])
        }

        // Game mode toggle
        ToggleChip {
            icon: "sports_esports"
            label: qsTr("Game")
            active: GameMode.enabled
            onToggled: GameMode.toggle()
        }

        // Screen recorder toggle
        ToggleChip {
            icon: Recorder.running ? "stop_circle" : "fiber_manual_record"
            label: Recorder.running
                ? (Recorder.elapsed > 0
                    ? "%1:%2".arg(Math.floor(Recorder.elapsed / 60)).arg(String(Math.floor(Recorder.elapsed % 60)).padStart(2, "0"))
                    : qsTr("Rec"))
                : qsTr("Record")
            active: Recorder.running
            onToggled: {
                if (Recorder.running)
                    Recorder.stop();
                else
                    Recorder.start();
            }
        }
    }

    // ── Reusable pill toggle ──────────────────────────────────────────────────
    component ToggleChip: StyledRect {
        id: chip

        required property string icon
        required property string label
        required property bool active
        signal toggled

        radius: Appearance.rounding.full
        color: chip.active
            ? Colours.palette.m3primaryContainer
            : Colours.layer(Colours.palette.m3surfaceContainer, 2)
        implicitHeight: chipRow.implicitHeight + Appearance.padding.smaller * 2
        implicitWidth: chipRow.implicitWidth + Appearance.padding.normal * 2

        StateLayer {
            radius: parent.radius
            color: chip.active ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurface
            function onClicked() { chip.toggled(); }
        }

        RowLayout {
            id: chipRow
            anchors.centerIn: parent
            spacing: Appearance.spacing.small

            MaterialIcon {
                text: chip.icon
                color: chip.active
                    ? Colours.palette.m3onPrimaryContainer
                    : Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.normal
                animate: true
            }

            StyledText {
                text: chip.label
                color: chip.active
                    ? Colours.palette.m3onPrimaryContainer
                    : Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.smaller
                font.weight: chip.active ? 600 : 400
            }
        }
    }
}
