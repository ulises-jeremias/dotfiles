pragma ComponentBehavior: Bound

import ".."
import "../components"
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.components.misc
import qs.services
import qs.config
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Session session

    anchors.fill: parent

    function run(command: var): void {
        if (Array.isArray(command) && command.length > 0) {
            Quickshell.execDetached(command);
            root.session.root.close();
        }
    }

    // Activate polling services while this pane is visible
    Ref {
        service: SystemUsage
    }

    Ref {
        service: NetworkUsage
    }

    // ── Reusable tile ────────────────────────────────────────────────────────
    component ActionTile: StyledRect {
        id: tile

        required property string icon
        required property string label
        required property string description
        required property var action

        Layout.fillWidth: true
        radius: Appearance.rounding.normal
        color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)
        implicitHeight: row.implicitHeight + Appearance.padding.normal * 2

        RowLayout {
            id: row

            anchors.fill: parent
            anchors.margins: Appearance.padding.normal
            spacing: Appearance.spacing.normal

            StyledRect {
                radius: Appearance.rounding.normal
                color: Colours.layer(Colours.palette.m3primaryContainer, 2)
                implicitWidth: 36
                implicitHeight: 36

                MaterialIcon {
                    anchors.centerIn: parent
                    text: tile.icon
                    color: Colours.palette.m3onPrimaryContainer
                    font.pointSize: Appearance.font.size.large
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    text: tile.label
                    font.pointSize: Appearance.font.size.normal
                    font.weight: 600
                }

                StyledText {
                    Layout.fillWidth: true
                    text: tile.description
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.smaller
                    elide: Text.ElideRight
                }
            }

            TextButton {
                text: qsTr("Run")
                type: TextButton.Tonal
                onClicked: tile.action()
            }
        }
    }

    // ── Stat row ─────────────────────────────────────────────────────────────
    component StatBar: ColumnLayout {
        id: bar

        required property string label
        required property real value  // 0–1
        required property string detail

        Layout.fillWidth: true
        spacing: 4

        RowLayout {
            Layout.fillWidth: true

            StyledText {
                text: bar.label
                font.pointSize: Appearance.font.size.smaller
                color: Colours.palette.m3onSurfaceVariant
            }

            Item {
                Layout.fillWidth: true
            }

            StyledText {
                text: bar.detail
                font.pointSize: Appearance.font.size.smaller
                color: Colours.palette.m3onSurfaceVariant
            }
        }

        StyledRect {
            Layout.fillWidth: true
            implicitHeight: 6
            radius: Appearance.rounding.full
            color: Colours.layer(Colours.palette.m3surfaceContainerHighest, 1)

            StyledRect {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * Math.min(bar.value, 1)
                radius: parent.radius
                color: bar.value > 0.85 ? Colours.palette.m3error : bar.value > 0.6 ? Colours.palette.m3tertiary : Colours.palette.m3primary

                Behavior on width {
                    Anim {
                        duration: Appearance.anim.durations.large
                    }
                }
            }
        }
    }

    // ── Main layout ──────────────────────────────────────────────────────────
    ClippingRectangle {
        id: clipRect

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

                StyledText {
                    text: qsTr("System")
                    font.pointSize: Appearance.font.size.large
                    font.weight: 500
                }

                // ── Live stats ───────────────────────────────────────────────
                StyledRect {
                    Layout.fillWidth: true
                    radius: Appearance.rounding.normal
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
                    implicitHeight: statsCol.implicitHeight + Appearance.padding.large * 2

                    ColumnLayout {
                        id: statsCol

                        anchors.fill: parent
                        anchors.margins: Appearance.padding.large
                        spacing: Appearance.spacing.normal

                        StyledText {
                            text: qsTr("Resources")
                            font.pointSize: Appearance.font.size.normal
                            font.weight: 500
                        }

                        StatBar {
                            label: SystemUsage.cpuName !== "" ? `CPU — ${SystemUsage.cpuName}` : qsTr("CPU")
                            value: SystemUsage.cpuPerc
                            detail: {
                                const pct = `${Math.round(SystemUsage.cpuPerc * 100)}%`;
                                return SystemUsage.cpuTemp > 0 ? `${pct} · ${Math.round(SystemUsage.cpuTemp)}°C` : pct;
                            }
                        }

                        StatBar {
                            visible: SystemUsage.gpuType !== "NONE"
                            label: SystemUsage.gpuName !== "" ? `GPU — ${SystemUsage.gpuName}` : qsTr("GPU")
                            value: SystemUsage.gpuPerc
                            detail: {
                                const pct = `${Math.round(SystemUsage.gpuPerc * 100)}%`;
                                return SystemUsage.gpuTemp > 0 ? `${pct} · ${Math.round(SystemUsage.gpuTemp)}°C` : pct;
                            }
                        }

                        StatBar {
                            label: qsTr("RAM")
                            value: SystemUsage.memPerc
                            detail: {
                                const used = SystemUsage.formatKib(SystemUsage.memUsed);
                                const total = SystemUsage.formatKib(SystemUsage.memTotal);
                                return `${used.value.toFixed(1)} / ${total.value.toFixed(1)} ${total.unit}`;
                            }
                        }

                        Repeater {
                            model: SystemUsage.disks

                            StatBar {
                                required property var modelData

                                label: qsTr("Disk — %1").arg(modelData.mount)
                                value: modelData.perc
                                detail: {
                                    const used = SystemUsage.formatKib(modelData.used);
                                    const total = SystemUsage.formatKib(modelData.total);
                                    return `${used.value.toFixed(1)} / ${total.value.toFixed(1)} ${total.unit}`;
                                }
                            }
                        }

                        StatBar {
                            visible: UPower.displayDevice.isLaptopBattery
                            label: UPower.displayDevice.state === UPowerDeviceState.Charging || UPower.displayDevice.state === UPowerDeviceState.PendingCharge ? qsTr("Battery — Charging") : UPower.displayDevice.state === UPowerDeviceState.FullyCharged ? qsTr("Battery — Full") : qsTr("Battery")
                            value: UPower.displayDevice.percentage
                            detail: {
                                const pct = `${Math.round(UPower.displayDevice.percentage * 100)}%`;
                                const s = UPower.displayDevice.timeToEmpty;
                                if (s > 0)
                                    return `${pct} · ~${Math.floor(s / 3600)}h ${Math.floor((s % 3600) / 60)}m`;
                                return pct;
                            }
                        }

                        StatBar {
                            readonly property real dl: NetworkUsage.downloadSpeed
                            readonly property real ul: NetworkUsage.uploadSpeed

                            function fmtSpeed(bps: real): string {
                                const fmt = NetworkUsage.formatBytes(bps);
                                return `${fmt.value.toFixed(1)} ${fmt.unit}`;
                            }

                            label: qsTr("Network")
                            value: Math.min(dl / 125000000, 1)
                            detail: `↓ ${fmtSpeed(dl)}  ↑ ${fmtSpeed(ul)}`
                        }
                    }
                }

                // ── Actions ──────────────────────────────────────────────────
                StyledRect {
                    Layout.fillWidth: true
                    radius: Appearance.rounding.normal
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
                    implicitHeight: actionsCol.implicitHeight + Appearance.padding.large * 2

                    ColumnLayout {
                        id: actionsCol

                        anchors.fill: parent
                        anchors.margins: Appearance.padding.large
                        spacing: Appearance.spacing.small

                        StyledText {
                            text: qsTr("Quick actions")
                            font.pointSize: Appearance.font.size.normal
                            font.weight: 500
                        }

                        ActionTile {
                            icon: "lock"
                            label: qsTr("Lock screen")
                            description: qsTr("Activate hyprlock immediately")
                            action: () => root.run(["dots-lockscreen", "--lock"])
                        }

                        ActionTile {
                            icon: "screenshot_monitor"
                            label: qsTr("Screenshot")
                            description: qsTr("Capture the screen with selection")
                            action: () => root.run(["dots-screenshooter"])
                        }

                        ActionTile {
                            icon: "fiber_manual_record"
                            label: qsTr("Screen recorder")
                            description: qsTr("Open GPU screen recorder")
                            action: () => root.run(["gsr-ui", "launch-hide-announce"])
                        }

                        ActionTile {
                            icon: "content_paste"
                            label: qsTr("Clipboard")
                            description: qsTr("Open clipboard history")
                            action: () => root.run(["copyq", "show"])
                        }

                        ActionTile {
                            icon: "dark_mode"
                            label: qsTr("Night mode")
                            description: qsTr("Toggle blue-light filter")
                            action: () => root.run(["dots-night-mode", "toggle"])
                        }

                        ActionTile {
                            icon: "system_update_alt"
                            label: qsTr("Check updates")
                            description: qsTr("Open terminal with system update")
                            action: () => root.run(["foot", "-e", "sh", "-c", "dots-sysupdate"])
                        }
                    }
                }

                // ── Tools ────────────────────────────────────────────────────
                StyledRect {
                    Layout.fillWidth: true
                    radius: Appearance.rounding.normal
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
                    implicitHeight: toolsCol.implicitHeight + Appearance.padding.large * 2

                    ColumnLayout {
                        id: toolsCol

                        anchors.fill: parent
                        anchors.margins: Appearance.padding.large
                        spacing: Appearance.spacing.small

                        StyledText {
                            text: qsTr("Tools")
                            font.pointSize: Appearance.font.size.normal
                            font.weight: 500
                        }

                        ActionTile {
                            icon: "monitor"
                            label: qsTr("Monitor layout")
                            description: qsTr("Configure display arrangement")
                            action: () => root.run(["nwg-displays"])
                        }

                        ActionTile {
                            icon: "bolt"
                            label: qsTr("Performance profile")
                            description: qsTr("CPU frequency and power mode")
                            action: () => root.run(["auto-cpufreq-gtk"])
                        }

                        ActionTile {
                            icon: "palette"
                            label: qsTr("GTK theme")
                            description: qsTr("Pick GTK theme, icons and cursors")
                            action: () => root.run(["nwg-look"])
                        }

                        ActionTile {
                            icon: "keyboard"
                            label: qsTr("Keyboard shortcuts")
                            description: qsTr("Show current keybinding reference")
                            action: () => root.run(["foot", "-e", "sh", "-c", "DOTS_BYPASS_QUICKSHELL=1 dots-keyboard-help"])
                        }
                    }
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
