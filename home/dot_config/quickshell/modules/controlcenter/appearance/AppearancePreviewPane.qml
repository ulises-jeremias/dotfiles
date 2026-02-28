pragma ComponentBehavior: Bound

import qs.components
import qs.components.images
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

StyledRect {
    id: root

    required property bool active
    required property string source
    required property string titleText
    required property string subtitleText
    required property string variantText
    required property string modeText
    required property string wallpaperPath
    required property var rootPane

    function previewColor(role: string, fallback: color): color {
        const p = root.rootPane.previewPalette;
        if (p && Object.prototype.hasOwnProperty.call(p, role))
            return p[role];
        return fallback;
    }

    radius: Appearance.rounding.normal
    color: previewColor("m3surfaceContainer", Colours.tPalette.m3surfaceContainer)

    Item {
        anchors.fill: parent
        anchors.margins: Appearance.padding.normal

        RowLayout {
            anchors.fill: parent
            spacing: Appearance.spacing.normal

            StyledClippingRect {
                Layout.preferredWidth: 220
                Layout.fillHeight: true
                radius: Appearance.rounding.normal
                color: previewColor("m3surfaceContainerHigh", Colours.tPalette.m3surfaceContainerHigh)

                Image {
                    anchors.fill: parent
                    source: root.wallpaperPath ? `file://${root.wallpaperPath}` : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                }

                MaterialIcon {
                    anchors.centerIn: parent
                    visible: !root.active
                    text: "visibility"
                    font.pointSize: Appearance.font.size.extraLarge
                    color: previewColor("m3outline", Colours.palette.m3outline)
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Appearance.spacing.small

                StyledText {
                    Layout.fillWidth: true
                    text: root.titleText || qsTr("Select an option")
                    font.pointSize: Appearance.font.size.normal
                    font.weight: 600
                    color: previewColor("m3onSurface", Colours.palette.m3onSurface)
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: root.subtitleText || qsTr("Preview updates here before applying")
                    color: previewColor("m3outline", Colours.palette.m3outline)
                    font.pointSize: Appearance.font.size.small
                    elide: Text.ElideRight
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.small

                    StyledRect {
                        radius: Appearance.rounding.full
                        color: previewColor("m3primary", Colours.palette.m3primary)
                        implicitHeight: 24
                        implicitWidth: 24
                    }

                    StyledRect {
                        radius: Appearance.rounding.full
                        color: previewColor("m3surface", Colours.palette.m3surface)
                        implicitHeight: 24
                        implicitWidth: 24
                    }

                    StyledRect {
                        radius: Appearance.rounding.full
                        color: previewColor("m3secondary", Colours.palette.m3secondary)
                        implicitHeight: 24
                        implicitWidth: 24
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    visible: !!root.variantText
                    text: qsTr("Variant: %1").arg(root.variantText)
                    font.pointSize: Appearance.font.size.small
                    color: previewColor("m3onSurfaceVariant", Colours.palette.m3onSurfaceVariant)
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    visible: !!root.modeText
                    text: qsTr("Mode: %1").arg(root.modeText)
                    font.pointSize: Appearance.font.size.small
                    color: previewColor("m3onSurfaceVariant", Colours.palette.m3onSurfaceVariant)
                    elide: Text.ElideRight
                }

                StyledRect {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Appearance.rounding.normal * root.rootPane.roundingScale
                    color: root.rootPane.transparencyEnabled ? Qt.alpha(previewColor("m3surfaceContainer", Colours.palette.m3surfaceContainer), root.rootPane.transparencyBase) : previewColor("m3surfaceContainer", Colours.palette.m3surfaceContainer)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Math.max(8, Appearance.padding.normal * root.rootPane.paddingScale)
                        spacing: Math.max(4, Appearance.spacing.small * root.rootPane.spacingScale)

                        StyledText {
                            text: qsTr("Typography Preview")
                            font.family: root.rootPane.fontFamilySans
                            font.pointSize: Appearance.font.size.normal * root.rootPane.fontSizeScale
                            font.weight: 600
                            color: previewColor("m3onSurface", Colours.palette.m3onSurface)
                        }

                        StyledText {
                            text: qsTr("Monospace: 1234 ABCD")
                            font.family: root.rootPane.fontFamilyMono
                            font.pointSize: Appearance.font.size.small * root.rootPane.fontSizeScale
                            color: previewColor("m3onSurfaceVariant", Colours.palette.m3onSurfaceVariant)
                        }

                        StyledText {
                            text: qsTr("Material font: %1").arg(root.rootPane.fontFamilyMaterial)
                            font.family: root.rootPane.fontFamilySans
                            font.pointSize: Appearance.font.size.small * root.rootPane.fontSizeScale
                            color: previewColor("m3outline", Colours.palette.m3outline)
                            elide: Text.ElideRight
                        }

                        StyledText {
                            text: qsTr("Scale r/s/p/f/a: %1 / %2 / %3 / %4 / %5").arg(root.rootPane.roundingScale.toFixed(2)).arg(root.rootPane.spacingScale.toFixed(2)).arg(root.rootPane.paddingScale.toFixed(2)).arg(root.rootPane.fontSizeScale.toFixed(2)).arg(root.rootPane.animDurationsScale.toFixed(2))
                            font.family: root.rootPane.fontFamilyMono
                            font.pointSize: Appearance.font.size.smaller * root.rootPane.fontSizeScale
                            color: previewColor("m3onSurfaceVariant", Colours.palette.m3onSurfaceVariant)
                            elide: Text.ElideRight
                        }

                        StyledText {
                            text: qsTr("Border: thickness %1 / rounding %2").arg(Math.round(root.rootPane.borderThickness)).arg(Math.round(root.rootPane.borderRounding))
                            font.family: root.rootPane.fontFamilySans
                            font.pointSize: Appearance.font.size.smaller * root.rootPane.fontSizeScale
                            color: previewColor("m3onSurfaceVariant", Colours.palette.m3onSurfaceVariant)
                        }

                        StyledText {
                            text: qsTr("Clock: %1 (%2) | Visualiser: %3").arg(root.rootPane.desktopClockEnabled ? "on" : "off").arg(root.rootPane.desktopClockPosition).arg(root.rootPane.visualiserEnabled ? "on" : "off")
                            font.family: root.rootPane.fontFamilySans
                            font.pointSize: Appearance.font.size.smaller * root.rootPane.fontSizeScale
                            color: previewColor("m3onSurfaceVariant", Colours.palette.m3onSurfaceVariant)
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
