pragma ComponentBehavior: Bound

import QtQuick

// Companion speech bubble: wrapping text, a max width, edge flipping,
// timed dismissal (owned by CompanionStore), and three themes
// (dark / light / pampa). Purely presentational.
Item {
    id: root

    property string text: ""
    // Resolved theme name: "dark", "light", or "pampa".
    property string theme: "dark"
    property int maxWidth: 240
    // When true the bubble grows leftwards (companion near right edge).
    property bool flip: false

    readonly property color bg: root.theme === "light" ? "#fffdf7" : root.theme === "pampa" ? "#faf3e3" : "#211d17"
    readonly property color fg: root.theme === "light" ? "#201d18" : root.theme === "pampa" ? "#1a1a1a" : "#f5f1e8"
    readonly property color edge: root.theme === "pampa" ? "#74acdf" : root.theme === "light" ? "#d8d2c4" : "#4a4438"

    // Natural (unwrapped) text width, capped at maxWidth: sizing the
    // box from the wrapped label is circular (the wrap width follows
    // the box), so measure separately to avoid a too-narrow box that
    // clips its own text.
    implicitWidth: Math.min(root.maxWidth, Math.max(80, measure.implicitWidth + 24))
    implicitHeight: label.implicitHeight + 20

    Rectangle {
        id: box

        anchors.fill: parent
        radius: 12
        color: root.bg
        border.color: root.edge
        border.width: 1
        opacity: 0.97

        // Hidden natural-width probe: same text and font as the label
        // but never wrapped, so the box can size to the content.
        Text {
            id: measure

            visible: false
            text: root.text
            font.pixelSize: 13
        }

        Text {
            id: label

            anchors.fill: parent
            anchors.margins: 12
            anchors.topMargin: 10
            anchors.bottomMargin: 10
            text: root.text
            color: root.fg
            font.pixelSize: 13
            wrapMode: Text.Wrap
            maximumLineCount: 6
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        // Little tail pointing down at the companion.
        Rectangle {
            width: 12
            height: 12
            color: root.bg
            border.color: root.edge
            border.width: 1
            rotation: 45
            anchors.top: parent.bottom
            anchors.topMargin: -7
            x: root.flip ? parent.width - 34 : 22
        }
    }
}
