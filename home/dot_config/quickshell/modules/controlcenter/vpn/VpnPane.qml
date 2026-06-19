pragma ComponentBehavior: Bound

import ".."
import "../components"
import "../network"
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Session session

    anchors.fill: parent

    SplitPaneLayout {
        anchors.fill: parent

        leftContent: Component {
            StyledFlickable {
                id: leftFlickable

                flickableDirection: Flickable.VerticalFlick
                contentHeight: leftCol.implicitHeight

                StyledScrollBar.vertical: StyledScrollBar {
                    flickable: leftFlickable
                }

                ColumnLayout {
                    id: leftCol

                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: Appearance.spacing.normal

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Appearance.spacing.small

                        StyledText {
                            Layout.fillWidth: true
                            text: qsTr("VPN")
                            font.pointSize: Appearance.font.size.large
                            font.weight: 500
                        }

                        StyledRect {
                            visible: VPN.connected || VPN.connecting
                            radius: Appearance.rounding.full
                            color: VPN.connected ? Colours.palette.m3primary : Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)
                            implicitWidth: connLabel.implicitWidth + Appearance.padding.normal * 2
                            implicitHeight: connLabel.implicitHeight + Appearance.padding.smaller

                            StyledText {
                                id: connLabel
                                anchors.centerIn: parent
                                text: VPN.connecting ? qsTr("…") : qsTr("On")
                                color: VPN.connected ? Colours.palette.m3onPrimary : Colours.palette.m3onSurfaceVariant
                                font.pointSize: Appearance.font.size.smaller
                                font.weight: 600
                            }
                        }
                    }

                    VpnList {
                        Layout.fillWidth: true
                        session: root.session
                        showHeader: false
                    }
                }
            }
        }

        rightContent: Component {
            Item {
                id: rightPane

                readonly property bool hasActive: root.session.vpn.active !== null
                property string paneId: root.session.vpn.active ? (root.session.vpn.active.name ?? "") : "settings"
                property Component targetComponent: settingsComp
                property Component nextComponent: settingsComp

                function getTargetComponent() {
                    return rightPane.hasActive ? detailsComp : settingsComp;
                }

                Component.onCompleted: {
                    targetComponent = getTargetComponent();
                    nextComponent = targetComponent;
                }

                Connections {
                    target: root.session.vpn
                    function onActiveChanged() {
                        rightPane.nextComponent = rightPane.getTargetComponent();
                        rightPane.paneId = root.session.vpn.active ? (root.session.vpn.active.name ?? "") : "settings";
                    }
                }

                Loader {
                    id: rightLoader
                    anchors.fill: parent
                    sourceComponent: rightPane.targetComponent
                }

                Behavior on paneId {
                    PaneTransition {
                        target: rightLoader
                        propertyActions: [
                            PropertyAction {
                                target: rightPane
                                property: "targetComponent"
                                value: rightPane.nextComponent
                            }
                        ]
                    }
                }
            }
        }
    }

    Component {
        id: settingsComp

        StyledFlickable {
            id: settingsFlickable

            flickableDirection: Flickable.VerticalFlick
            contentHeight: settingsInner.implicitHeight

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: settingsFlickable
            }

            VpnSettings {
                id: settingsInner
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                session: root.session
            }
        }
    }

    Component {
        id: detailsComp

        StyledFlickable {
            id: detailsFlickable

            flickableDirection: Flickable.VerticalFlick
            contentHeight: detailsInner.implicitHeight

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: detailsFlickable
            }

            VpnDetails {
                id: detailsInner
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                session: root.session
            }
        }
    }
}
