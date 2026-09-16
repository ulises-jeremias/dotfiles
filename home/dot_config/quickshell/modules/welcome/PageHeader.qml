import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

// Shared hero header for Welcome pages: icon, title, subtitle.
// Callers pass already-translated strings (qsTr at the call site).
ColumnLayout {
    id: root

    required property string icon
    required property string title
    required property string subtitle

    Layout.fillWidth: true
    spacing: Appearance.spacing.small

    MaterialIcon {
        Layout.alignment: Qt.AlignHCenter
        text: root.icon
        color: Colours.palette.m3primary
        font.pointSize: Appearance.font.size.large * 2
    }

    StyledText {
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        text: root.title
        font.pointSize: Appearance.font.size.large
        font.weight: 600
        horizontalAlignment: Text.AlignHCenter
    }

    StyledText {
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        Layout.maximumWidth: 520
        text: root.subtitle
        color: Colours.palette.m3onSurfaceVariant
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }
}
