pragma ComponentBehavior: Bound

import ".."
import "../components"
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.modules.companion
import qs.config
import qs.services
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

// Control Center › Companion: enable, character, size, idle-to-sleep,
// tips, edge, bubble theme, and position reset. Binds straight onto
// CompanionStore (persisted via PersistentProperties, no save step).
Item {
    id: root

    required property Session session

    anchors.fill: parent

    ClippingRectangle {
        id: clipRect

        anchors.fill: parent
        anchors.margins: Appearance.padding.normal
        anchors.leftMargin: 0
        anchors.rightMargin: Appearance.padding.normal
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
                    text: qsTr("Companion")
                    font.pointSize: Appearance.font.size.large
                    font.weight: 500
                }

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("A small Hornero sidekick that idles, greets, and shows tips. Never wanders on its own.")
                    font.pointSize: Appearance.font.size.small
                    color: Colours.palette.m3outline
                    wrapMode: Text.Wrap
                }

                StyledRect {
                    Layout.fillWidth: true
                    radius: Appearance.rounding.normal
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
                    implicitHeight: generalCol.implicitHeight + Appearance.padding.large * 2

                    ColumnLayout {
                        id: generalCol

                        anchors.fill: parent
                        anchors.margins: Appearance.padding.large
                        spacing: Appearance.spacing.small

                        StyledText {
                            text: qsTr("General")
                            font.pointSize: Appearance.font.size.normal
                            font.weight: 500
                        }

                        SwitchRow {
                            label: qsTr("Enabled")
                            checked: CompanionStore.enabled
                            onToggled: checked => CompanionStore.enabled = checked
                        }

                        SwitchRow {
                            label: qsTr("Show tips on click")
                            checked: CompanionStore.tipsEnabled
                            onToggled: checked => CompanionStore.tipsEnabled = checked
                        }

                        SwitchRow {
                            label: qsTr("Reduced motion")
                            checked: CompanionStore.reducedMotion
                            onToggled: checked => CompanionStore.reducedMotion = checked
                        }

                        SliderInput {
                            Layout.fillWidth: true

                            label: qsTr("Size")
                            value: CompanionStore.sizeScale
                            from: 0.5
                            to: 2.0
                            stepSize: 0.05
                            suffix: "×"
                            decimals: 2
                            onValueModified: newValue => CompanionStore.sizeScale = newValue
                        }

                        SliderInput {
                            Layout.fillWidth: true

                            label: qsTr("Sleep after idle")
                            value: CompanionStore.sleepMinutes
                            from: 0
                            to: 30
                            stepSize: 1
                            suffix: "min"
                            validator: IntValidator {
                                bottom: 0
                                top: 30
                            }
                            formatValueFunction: val => val === 0 ? qsTr("never") : `${Math.round(val)} min`
                            parseValueFunction: text => parseInt(text)
                            onValueModified: newValue => CompanionStore.sleepMinutes = Math.round(newValue)
                        }
                    }
                }

                StyledRect {
                    Layout.fillWidth: true
                    radius: Appearance.rounding.normal
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
                    implicitHeight: charCol.implicitHeight + Appearance.padding.large * 2

                    ColumnLayout {
                        id: charCol

                        anchors.fill: parent
                        anchors.margins: Appearance.padding.large
                        spacing: Appearance.spacing.small

                        StyledText {
                            text: qsTr("Character")
                            font.pointSize: Appearance.font.size.normal
                            font.weight: 500
                        }

                        StyledText {
                            text: qsTr("Skin")
                            font.pointSize: Appearance.font.size.small
                            color: Colours.palette.m3outline
                        }

                        Flow {
                            Layout.fillWidth: true
                            spacing: Appearance.spacing.small

                            Repeater {
                                model: Companion.knownSkins

                                TextButton {
                                    required property int index
                                    required property string modelData

                                    text: modelData
                                    toggle: true
                                    checked: CompanionStore.skin === modelData
                                    type: TextButton.Tonal
                                    onClicked: CompanionStore.setSkin(modelData)
                                }
                            }
                        }

                        StyledText {
                            text: qsTr("Summon edge")
                            font.pointSize: Appearance.font.size.small
                            color: Colours.palette.m3outline
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Appearance.spacing.small

                            TextButton {
                                text: qsTr("Left")
                                toggle: true
                                checked: CompanionStore.edge === "left"
                                type: TextButton.Tonal
                                Layout.fillWidth: true
                                onClicked: CompanionStore.edge = "left"
                            }
                            TextButton {
                                text: qsTr("Right")
                                toggle: true
                                checked: CompanionStore.edge === "right"
                                type: TextButton.Tonal
                                Layout.fillWidth: true
                                onClicked: CompanionStore.edge = "right"
                            }
                        }

                        StyledText {
                            text: qsTr("Speech bubble theme")
                            font.pointSize: Appearance.font.size.small
                            color: Colours.palette.m3outline
                        }

                        Flow {
                            Layout.fillWidth: true
                            spacing: Appearance.spacing.small

                            Repeater {
                                model: ["auto", "dark", "light", "pampa"]

                                TextButton {
                                    required property int index
                                    required property string modelData

                                    text: modelData
                                    toggle: true
                                    checked: CompanionStore.bubbleTheme === modelData
                                    type: TextButton.Tonal
                                    onClicked: CompanionStore.bubbleTheme = modelData
                                }
                            }
                        }
                    }
                }

                StyledRect {
                    Layout.fillWidth: true
                    radius: Appearance.rounding.normal
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
                    implicitHeight: actionCol.implicitHeight + Appearance.padding.large * 2

                    ColumnLayout {
                        id: actionCol

                        anchors.fill: parent
                        anchors.margins: Appearance.padding.large
                        spacing: Appearance.spacing.small

                        StyledText {
                            text: qsTr("Actions")
                            font.pointSize: Appearance.font.size.normal
                            font.weight: 500
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Appearance.spacing.small

                            TextButton {
                                text: CompanionStore.state === "hidden" ? qsTr("Summon") : qsTr("Peek out")
                                type: TextButton.Filled
                                Layout.fillWidth: true
                                onClicked: CompanionStore.summon()
                            }
                            TextButton {
                                text: qsTr("Reset position")
                                type: TextButton.Tonal
                                Layout.fillWidth: true
                                onClicked: CompanionStore.resetPosition()
                            }
                        }
                    }
                }
            }
        }
    }
}
