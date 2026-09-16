import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

// Clickable (or informational) action card for Welcome pages.
// Callers pass already-translated strings (qsTr at the call site).
// A card with an empty shortcutId shows no badge; a non-interactive card
// renders description + badge only (no pointer, no focus).
StyledRect {
    id: root

    required property string icon
    required property string title
    required property string description
    property string shortcutId: ""
    property bool interactive: true

    signal activated()

    Layout.fillWidth: true
    implicitHeight: Math.max(88, content.implicitHeight + Appearance.padding.normal * 2)

    radius: Appearance.rounding.normal
    color: root.interactive && cardMouse.containsMouse ? Colours.layer(Colours.palette.m3surfaceContainerHigh, 1) : Colours.layer(Colours.palette.m3surfaceContainer, 1)
    border.width: root.activeFocus ? 2 : 0
    border.color: Colours.palette.m3primary

    activeFocusOnTab: root.interactive

    Keys.onReturnPressed: {
        if (root.interactive)
            root.activated();
    }
    Keys.onSpacePressed: {
        if (root.interactive)
            root.activated();
    }

    Behavior on color {
        CAnim {}
    }

    RowLayout {
        id: content

        anchors.fill: parent
        anchors.leftMargin: Appearance.padding.normal
        anchors.rightMargin: Appearance.padding.normal
        anchors.topMargin: Appearance.padding.small
        anchors.bottomMargin: Appearance.padding.small
        spacing: Appearance.spacing.normal

        MaterialIcon {
            text: root.icon
            color: Colours.palette.m3primary
            font.pointSize: Appearance.font.size.large
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.smaller

            StyledText {
                Layout.fillWidth: true
                text: root.title
                font.weight: 600
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                text: root.description
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.smaller
                wrapMode: Text.WordWrap
            }

            StyledRect {
                visible: root.shortcutId !== "" && ShortcutHints.has(root.shortcutId)
                radius: Appearance.rounding.full
                color: Colours.palette.m3secondaryContainer
                Layout.preferredHeight: badgeText.implicitHeight + 8
                Layout.preferredWidth: badgeText.implicitWidth + 20

                StyledText {
                    id: badgeText

                    anchors.centerIn: parent
                    text: ShortcutHints.badge(root.shortcutId)
                    color: Colours.palette.m3onSecondaryContainer
                    font.pointSize: Appearance.font.size.smaller
                    font.weight: 600
                }
            }
        }

        MaterialIcon {
            visible: root.interactive
            text: "chevron_right"
            color: Colours.palette.m3onSurfaceVariant
        }
    }

    MouseArea {
        id: cardMouse

        anchors.fill: parent
        hoverEnabled: root.interactive
        enabled: root.interactive
        onClicked: root.activated()
    }
}
