pragma ComponentBehavior: Bound

import ".."
import "../components"
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.services
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

                RowLayout {
                    spacing: Appearance.spacing.normal

                    StyledText {
                        text: qsTr("VPN")
                        font.pointSize: Appearance.font.size.large
                        font.weight: 500
                    }

                    StyledRect {
                        radius: Appearance.rounding.full
                        color: VPN.connected ? Colours.palette.m3primary : Colours.palette.m3surfaceContainerHigh
                        implicitWidth: statusText.implicitWidth + Appearance.padding.normal * 2
                        implicitHeight: statusText.implicitHeight + Appearance.padding.smaller

                        StyledText {
                            id: statusText

                            anchors.centerIn: parent
                            text: VPN.connecting ? qsTr("Connecting…") : VPN.connected ? qsTr("Connected") : qsTr("Disconnected")
                            color: VPN.connected ? Colours.palette.m3onPrimary : Colours.palette.m3onSurfaceVariant
                            font.pointSize: Appearance.font.size.smaller
                            font.weight: 600
                        }

                        Behavior on color {
                            CAnim {}
                        }
                    }
                }

                // ── No provider configured ───────────────────────────────────
                StyledRect {
                    visible: !VPN.enabled
                    Layout.fillWidth: true
                    radius: Appearance.rounding.normal
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
                    implicitHeight: emptyCol.implicitHeight + Appearance.padding.large * 2

                    ColumnLayout {
                        id: emptyCol

                        anchors.fill: parent
                        anchors.margins: Appearance.padding.large
                        spacing: Appearance.spacing.small

                        MaterialIcon {
                            Layout.alignment: Qt.AlignHCenter
                            text: "vpn_key_off"
                            color: Colours.palette.m3outline
                            font.pointSize: Appearance.font.size.extraLarge * 2
                        }

                        StyledText {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("No VPN provider configured")
                            color: Colours.palette.m3outline
                            horizontalAlignment: Text.AlignHCenter
                            font.pointSize: Appearance.font.size.normal
                        }

                        StyledText {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("Add a provider under utilities.vpn.provider in shell.json")
                            color: Colours.palette.m3outlineVariant
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                            font.pointSize: Appearance.font.size.smaller
                        }
                    }
                }

                // ── Provider card ────────────────────────────────────────────
                StyledRect {
                    visible: VPN.enabled
                    Layout.fillWidth: true
                    radius: Appearance.rounding.normal
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
                    implicitHeight: providerCol.implicitHeight + Appearance.padding.large * 2

                    ColumnLayout {
                        id: providerCol

                        anchors.fill: parent
                        anchors.margins: Appearance.padding.large
                        spacing: Appearance.spacing.normal

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Appearance.spacing.normal

                            StyledRect {
                                radius: Appearance.rounding.normal
                                color: Colours.layer(VPN.connected ? Colours.palette.m3primaryContainer : Colours.palette.m3surfaceContainerHigh, 2)
                                implicitWidth: 40
                                implicitHeight: 40

                                MaterialIcon {
                                    anchors.centerIn: parent
                                    text: "vpn_key"
                                    color: VPN.connected ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurfaceVariant
                                    font.pointSize: Appearance.font.size.large
                                }

                                Behavior on color {
                                    CAnim {}
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                StyledText {
                                    text: VPN.currentConfig?.displayName || VPN.providerName
                                    font.pointSize: Appearance.font.size.normal
                                    font.weight: 600
                                }

                                StyledText {
                                    visible: VPN.connected && VPN.interfaceName !== ""
                                    text: VPN.interfaceName
                                    color: Colours.palette.m3onSurfaceVariant
                                    font.pointSize: Appearance.font.size.smaller
                                }
                            }

                            TextButton {
                                enabled: !VPN.connecting
                                text: VPN.connected ? qsTr("Disconnect") : qsTr("Connect")
                                type: VPN.connected ? TextButton.Filled : TextButton.Tonal
                                onClicked: {
                                    if (VPN.connected)
                                        VPN.disconnect();
                                    else
                                        VPN.connect();
                                }
                            }
                        }
                    }
                }

                // ── Provider info ────────────────────────────────────────────
                StyledRect {
                    visible: VPN.enabled
                    Layout.fillWidth: true
                    radius: Appearance.rounding.normal
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
                    implicitHeight: infoCol.implicitHeight + Appearance.padding.large * 2

                    ColumnLayout {
                        id: infoCol

                        anchors.fill: parent
                        anchors.margins: Appearance.padding.large
                        spacing: Appearance.spacing.small

                        StyledText {
                            text: qsTr("Provider details")
                            font.pointSize: Appearance.font.size.normal
                            font.weight: 500
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Appearance.spacing.normal

                            StyledText {
                                text: qsTr("Type")
                                color: Colours.palette.m3outline
                                font.pointSize: Appearance.font.size.small
                            }

                            Item { Layout.fillWidth: true }

                            StyledText {
                                text: VPN.providerName
                                font.pointSize: Appearance.font.size.small
                            }
                        }

                        RowLayout {
                            visible: VPN.interfaceName !== ""
                            Layout.fillWidth: true
                            spacing: Appearance.spacing.normal

                            StyledText {
                                text: qsTr("Interface")
                                color: Colours.palette.m3outline
                                font.pointSize: Appearance.font.size.small
                            }

                            Item { Layout.fillWidth: true }

                            StyledText {
                                text: VPN.interfaceName
                                font.pointSize: Appearance.font.size.small
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
