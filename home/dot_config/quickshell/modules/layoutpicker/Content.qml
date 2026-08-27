pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Layouts

// Modal layout picker: header + reusable preset grid + keyboard hints.
Item {
    id: root

    required property PersistentProperties visibilities

    implicitWidth: mainColumn.implicitWidth + Appearance.padding.large * 2
    implicitHeight: mainColumn.implicitHeight + Appearance.padding.large * 2

    focus: true
    Keys.onEscapePressed: root.visibilities.layoutPicker = false

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

            PresetGrid {
                Layout.alignment: Qt.AlignHCenter
                keyboardNav: true
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
}
