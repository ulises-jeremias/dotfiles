pragma ComponentBehavior: Bound

import ".."
import "../components"
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.config
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

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
                    text: qsTr("On-Screen Display")
                    font.pointSize: Appearance.font.size.large
                    font.weight: 500
                }

                StyledRect {
                    Layout.fillWidth: true
                    radius: Appearance.rounding.normal
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
                    implicitHeight: settingsCol.implicitHeight + Appearance.padding.large * 2

                    ColumnLayout {
                        id: settingsCol

                        anchors.fill: parent
                        anchors.margins: Appearance.padding.large
                        spacing: Appearance.spacing.small

                        StyledText {
                            text: qsTr("Visibility")
                            font.pointSize: Appearance.font.size.normal
                            font.weight: 500
                        }

                        SwitchRow {
                            label: qsTr("Enabled")
                            checked: Config.osd.enabled
                            onToggled: checked => {
                                Config.osd.enabled = checked;
                                Config.osd.saveConfig();
                            }
                        }

                        SwitchRow {
                            label: qsTr("Brightness indicator")
                            checked: Config.osd.enableBrightness
                            onToggled: checked => {
                                Config.osd.enableBrightness = checked;
                                Config.osd.saveConfig();
                            }
                        }

                        SwitchRow {
                            label: qsTr("Microphone indicator")
                            checked: Config.osd.enableMicrophone
                            onToggled: checked => {
                                Config.osd.enableMicrophone = checked;
                                Config.osd.saveConfig();
                            }
                        }
                    }
                }

                StyledRect {
                    Layout.fillWidth: true
                    radius: Appearance.rounding.normal
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
                    implicitHeight: timingCol.implicitHeight + Appearance.padding.large * 2

                    ColumnLayout {
                        id: timingCol

                        anchors.fill: parent
                        anchors.margins: Appearance.padding.large
                        spacing: Appearance.spacing.small

                        StyledText {
                            text: qsTr("Timing")
                            font.pointSize: Appearance.font.size.normal
                            font.weight: 500
                        }

                        SliderInput {
                            Layout.fillWidth: true

                            label: qsTr("Hide after")
                            value: Config.osd.hideDelay
                            from: 500
                            to: 10000
                            stepSize: 100
                            suffix: "ms"
                            validator: IntValidator {
                                bottom: 500
                                top: 10000
                            }
                            formatValueFunction: val => Math.round(val).toString()
                            parseValueFunction: text => parseInt(text)
                            onValueModified: val => {
                                Config.osd.hideDelay = Math.round(val);
                                Config.osd.saveConfig();
                            }
                        }
                    }
                }

                StyledRect {
                    Layout.fillWidth: true
                    radius: Appearance.rounding.normal
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
                    implicitHeight: sizeCol.implicitHeight + Appearance.padding.large * 2

                    ColumnLayout {
                        id: sizeCol

                        anchors.fill: parent
                        anchors.margins: Appearance.padding.large
                        spacing: Appearance.spacing.small

                        StyledText {
                            text: qsTr("Slider size")
                            font.pointSize: Appearance.font.size.normal
                            font.weight: 500
                        }

                        SliderInput {
                            Layout.fillWidth: true

                            label: qsTr("Width")
                            value: Config.osd.sizes.sliderWidth
                            from: 20
                            to: 80
                            stepSize: 2
                            suffix: "px"
                            validator: IntValidator {
                                bottom: 20
                                top: 80
                            }
                            formatValueFunction: val => Math.round(val).toString()
                            parseValueFunction: text => parseInt(text)
                            onValueModified: val => {
                                Config.osd.sizes.sliderWidth = Math.round(val);
                                Config.osd.saveConfig();
                            }
                        }

                        SliderInput {
                            Layout.fillWidth: true

                            label: qsTr("Height")
                            value: Config.osd.sizes.sliderHeight
                            from: 80
                            to: 300
                            stepSize: 10
                            suffix: "px"
                            validator: IntValidator {
                                bottom: 80
                                top: 300
                            }
                            formatValueFunction: val => Math.round(val).toString()
                            parseValueFunction: text => parseInt(text)
                            onValueModified: val => {
                                Config.osd.sizes.sliderHeight = Math.round(val);
                                Config.osd.saveConfig();
                            }
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
