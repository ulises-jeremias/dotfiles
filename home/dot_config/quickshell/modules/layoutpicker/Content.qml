pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.config
import qs.utils
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

// Cozy grid of shell layout presets with mini previews.
// Data comes from `dots-quickshell preset list --json`; applying a preset
// deep-merges into shell.json and live-reloads (no shell restart needed).
Item {
    id: root

    required property PersistentProperties visibilities

    property var presets: []
    property string currentName: ""
    property int focusIndex: 0

    readonly property int count: presets.length
    readonly property int columns: Math.max(2, Math.min(4, Math.ceil(Math.sqrt(count))))

    implicitWidth: mainColumn.implicitWidth + Appearance.padding.large * 2
    implicitHeight: mainColumn.implicitHeight + Appearance.padding.large * 2

    function reload(): void {
        listProc.running = true;
    }

    function apply(name: string): void {
        if (applyProc.running)
            return;
        currentName = name; // optimistic; the file watch/sync corrects if it failed
        applyProc.command = ["dots-quickshell", "preset", "apply", name];
        applyProc.running = true;
    }

    Component.onCompleted: reload()

    Process {
        id: listProc

        command: ["dots-quickshell", "preset", "list", "--json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const list = JSON.parse(text);
                    root.presets = list;
                    const active = list.find(p => p.active);
                    if (active)
                        root.currentName = active.name;
                } catch (e) {
                    console.warn("[layoutpicker] Failed to parse preset list:", e);
                }
            }
        }
    }

    Process {
        id: applyProc

        onExited: (exitCode, exitStatus) => {
            // Re-sync the active marker from disk (source of truth)
            root.reload();
        }
    }

    focus: true

    function applyFocused(): void {
        const p = root.presets[root.focusIndex];
        if (p)
            root.apply(p.name);
    }

    Keys.onEscapePressed: root.visibilities.layoutPicker = false
    Keys.onReturnPressed: root.applyFocused()
    Keys.onEnterPressed: root.applyFocused()
    Keys.onLeftPressed: root.focusIndex = (root.focusIndex - 1 + root.count) % root.count
    Keys.onRightPressed: root.focusIndex = (root.focusIndex + 1) % root.count
    Keys.onUpPressed: root.focusIndex = (root.focusIndex - root.columns + root.count) % root.count
    Keys.onDownPressed: root.focusIndex = (root.focusIndex + root.columns) % root.count
    Keys.onTabPressed: root.focusIndex = (root.focusIndex + 1) % root.count
    Keys.onBacktabPressed: root.focusIndex = (root.focusIndex - 1 + root.count) % root.count

    StyledClippingRect {
        anchors.fill: parent
        color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
        radius: Appearance.rounding.large

        ColumnLayout {
            id: mainColumn

            anchors.fill: parent
            anchors.margins: Appearance.padding.large
            spacing: Appearance.spacing.large

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.normal

                StyledRect {
                    implicitWidth: 44
                    implicitHeight: 44
                    radius: Appearance.rounding.full
                    color: Colours.layer(Colours.palette.m3primaryContainer, 2)

                    MaterialIcon {
                        anchors.centerIn: parent
                        text: "dashboard_customize"
                        color: Colours.palette.m3onPrimaryContainer
                        font.pointSize: Appearance.font.size.large
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    StyledText {
                        text: qsTr("Shell layout")
                        font.pointSize: Appearance.font.size.large
                        font.weight: Font.Medium
                        color: Colours.palette.m3onSurface
                    }

                    StyledText {
                        text: qsTr("Pick a bar arrangement — it applies instantly, no restart")
                        font.pointSize: Appearance.font.size.small
                        color: Colours.palette.m3onSurfaceVariant
                    }
                }

                IconButton {
                    icon: "close"
                    type: IconButton.Text
                    Accessible.name: qsTr("Close layout picker")
                    onClicked: root.visibilities.layoutPicker = false
                }
            }

            // Preset grid
            GridLayout {
                Layout.alignment: Qt.AlignHCenter
                columns: root.columns
                rowSpacing: Appearance.spacing.normal
                columnSpacing: Appearance.spacing.normal

                Repeater {
                    model: root.presets

                    delegate: StyledRect {
                        id: card

                        required property var modelData
                        required property int index

                        readonly property bool isActive: modelData.name === root.currentName
                        readonly property bool isFocused: index === root.focusIndex

                        implicitWidth: 210
                        implicitHeight: 168
                        radius: Appearance.rounding.normal
                        color: isActive ? Colours.layer(Colours.palette.m3secondaryContainer, 2) : Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)
                        border.color: isFocused ? Colours.palette.m3primary : isActive ? Colours.palette.m3secondary : Qt.alpha(Colours.palette.m3outline, 0.25)
                        border.width: isFocused || isActive ? 2 : 1

                        Behavior on color {
                            CAnim {}
                        }

                        Behavior on border.color {
                            CAnim {}
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Appearance.padding.normal
                            spacing: Appearance.spacing.small

                            LayoutPreview {
                                Layout.alignment: Qt.AlignHCenter
                                position: card.modelData.position
                                barStyle: card.modelData.style
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Appearance.spacing.small

                                MaterialIcon {
                                    text: card.modelData.iconMaterial || "widgets"
                                    color: card.isActive ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: card.modelData.display
                                        font.pointSize: Appearance.font.size.normal
                                        font.weight: card.isActive ? Font.Medium : Font.Normal
                                        color: Colours.palette.m3onSurface
                                        elide: Text.ElideRight
                                    }

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: `${card.modelData.position} · ${card.modelData.style}`
                                        font.pointSize: Appearance.font.size.smaller
                                        color: Colours.palette.m3onSurfaceVariant
                                        elide: Text.ElideRight
                                    }
                                }

                                MaterialIcon {
                                    visible: card.isActive
                                    text: "check_circle"
                                    fill: 1
                                    color: Colours.palette.m3primary
                                }
                            }
                        }

                        StateLayer {
                            radius: card.radius
                            onClicked: {
                                root.focusIndex = card.index;
                                root.apply(card.modelData.name);
                            }
                            onEntered: root.focusIndex = card.index
                        }
                    }
                }
            }

            // Empty state
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                visible: root.count === 0
                text: qsTr("No presets found — check ~/.local/share/dots/shell-presets")
                color: Colours.palette.m3onSurfaceVariant
            }

            // Footer hint
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("←→↑↓ navigate · Enter applies · Esc closes")
                font.pointSize: Appearance.font.size.smaller
                color: Colours.layer(Colours.palette.m3onSurfaceVariant, 2)
            }
        }
    }

    // Mini screen mockup showing where the bar sits for a preset
    component LayoutPreview: StyledRect {
        id: preview

        required property string position
        required property string barStyle

        readonly property bool vertical: position === "left" || position === "right"
        readonly property bool floating: barStyle !== "attached"

        implicitWidth: 132
        implicitHeight: 76
        radius: Appearance.rounding.small
        color: Colours.layer(Colours.palette.m3surfaceContainerHighest, 1)

        // Content window hint
        StyledRect {
            readonly property int barT: preview.floating ? 13 : 11

            x: preview.position === "left" ? barT + 6 : 6
            y: preview.position === "top" ? barT + 6 : 6
            width: preview.width - 12 - (preview.vertical ? barT : 0)
            height: preview.height - 12 - (preview.vertical ? 0 : barT)
            radius: Appearance.rounding.small * 0.6
            color: Colours.layer(Colours.palette.m3surface, 2)
        }

        // Bar
        StyledRect {
            color: Colours.palette.m3primary
            opacity: 0.85
            radius: preview.floating ? Appearance.rounding.full : 0

            width: preview.vertical ? 11 : (preview.floating ? 84 : preview.width)
            height: preview.vertical ? (preview.floating ? 48 : preview.height) : 11

            x: {
                if (preview.vertical)
                    return preview.position === "left" ? (preview.floating ? 4 : 0) : preview.width - width - (preview.floating ? 4 : 0);
                return preview.floating ? Math.round((preview.width - width) / 2) : 0;
            }
            y: {
                if (!preview.vertical)
                    return preview.position === "top" ? (preview.floating ? 4 : 0) : preview.height - height - (preview.floating ? 4 : 0);
                return preview.floating ? Math.round((preview.height - height) / 2) : 0;
            }
        }
    }
}
