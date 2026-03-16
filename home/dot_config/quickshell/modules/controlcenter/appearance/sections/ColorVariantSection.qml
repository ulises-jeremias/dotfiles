pragma ComponentBehavior: Bound

import ".."
import "../../../launcher/services"
import qs.components
import qs.components.controls
import qs.components.containers
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Layouts

CollapsibleSection {
    required property var previewController
    required property var session

    title: qsTr("Color variant")
    description: qsTr("Material theme variant")
    showBackground: true

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.small / 2

        Repeater {
            model: M3Variants.list

            delegate: StyledRect {
                required property var modelData

                Layout.fillWidth: true

                color: Qt.alpha(Colours.tPalette.m3surfaceContainer, modelData.variant === previewController.pendingVariant ? Colours.tPalette.m3surfaceContainer.a : 0)
                radius: Appearance.rounding.normal
                border.width: modelData.variant === previewController.pendingVariant ? 1 : 0
                border.color: Colours.palette.m3primary

                StateLayer {
                    function onClicked(): void {
                        const variant = modelData.variant;

                        previewController.startVariantPreview(variant);
                        previewController.stageVariantApply(variant);
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    hoverEnabled: true
                    onEntered: previewController.startVariantPreview(modelData.variant)
                }

                RowLayout {
                    id: variantRow

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Appearance.padding.normal

                    spacing: Appearance.spacing.normal

                    MaterialIcon {
                        text: modelData.icon
                        font.pointSize: Appearance.font.size.large
                        fill: modelData.variant === previewController.pendingVariant ? 1 : 0
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: modelData.name
                        font.weight: modelData.variant === previewController.pendingVariant ? 500 : 400
                    }

                    MaterialIcon {
                        visible: modelData.variant === previewController.pendingVariant
                        text: "check"
                        color: Colours.palette.m3primary
                        font.pointSize: Appearance.font.size.large
                    }
                }

                implicitHeight: variantRow.implicitHeight + Appearance.padding.normal * 2
            }
        }

        // Accent color override
        Item {
            Layout.fillWidth: true
            implicitHeight: Appearance.spacing.normal
        }

        StyledRect {
            Layout.fillWidth: true
            color: Colours.tPalette.m3surfaceContainer
            radius: Appearance.rounding.normal
            implicitHeight: accentOverrideLayout.implicitHeight + Appearance.padding.normal * 2

            ColumnLayout {
                id: accentOverrideLayout

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: Appearance.padding.normal
                spacing: Appearance.spacing.small

                StyledText {
                    text: qsTr("Accent color override")
                    font.pointSize: Appearance.font.size.normal
                }

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Seed the M3 palette from a custom hex color instead of the wallpaper")
                    font.pointSize: Appearance.font.size.small
                    color: Colours.palette.m3onSurfaceVariant
                    wrapMode: Text.WordWrap
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.small

                    // Color preview swatch
                    StyledRect {
                        id: accentSwatch
                        width: 32
                        height: 32
                        radius: Appearance.rounding.small
                        border.width: 1
                        border.color: Qt.alpha(Colours.palette.m3outline, 0.4)
                        color: accentField.isValidHex ? `#${accentField.hexValue}` : Colours.palette.m3surfaceContainerHigh

                        Behavior on color {
                            CAnim {}
                        }
                    }

                    // Hex input field
                    StyledRect {
                        Layout.fillWidth: true
                        implicitHeight: 36
                        color: accentField.activeFocus
                            ? Colours.layer(Colours.palette.m3surfaceContainer, 3)
                            : Colours.layer(Colours.palette.m3surfaceContainer, 2)
                        radius: Appearance.rounding.small
                        border.width: 1
                        border.color: accentField.activeFocus ? Colours.palette.m3primary : Qt.alpha(Colours.palette.m3outline, 0.3)

                        Behavior on color { CAnim {} }
                        Behavior on border.color { CAnim {} }

                        StyledTextField {
                            id: accentField

                            anchors.centerIn: parent
                            width: parent.width - Appearance.padding.normal * 2
                            horizontalAlignment: TextInput.AlignLeft
                            placeholderText: qsTr("#RRGGBB — leave empty to use wallpaper")
                            maximumLength: 7

                            readonly property string hexValue: text.startsWith("#") ? text.slice(1) : text
                            readonly property bool isValidHex: /^[0-9a-fA-F]{6}$/.test(hexValue)

                            Keys.onReturnPressed: {
                                if (isValidHex)
                                    Quickshell.execDetached(["dots-accent-override", `#${hexValue}`]);
                            }
                            Keys.onEnterPressed: {
                                if (isValidHex)
                                    Quickshell.execDetached(["dots-accent-override", `#${hexValue}`]);
                            }
                        }
                    }

                    // Apply button
                    TextButton {
                        id: applyButton

                        text: qsTr("Apply")
                        enabled: accentField.isValidHex
                        activeColour: Colours.palette.m3primary
                        activeOnColour: Colours.palette.m3onPrimary
                        inactiveColour: Colours.palette.m3primary
                        inactiveOnColour: Colours.palette.m3onPrimary

                        onClicked: {
                            if (accentField.isValidHex) {
                                Quickshell.execDetached(["dots-accent-override", `#${accentField.hexValue}`]);
                            }
                        }
                    }

                    // Clear button
                    TextButton {
                        text: qsTr("Clear")
                        type: TextButton.Tonal

                        onClicked: {
                            accentField.text = "";
                            Quickshell.execDetached(["dots-accent-override", "--clear"]);
                        }
                    }
                }
            }
        }
    }
}
