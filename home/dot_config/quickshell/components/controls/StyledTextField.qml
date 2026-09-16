pragma ComponentBehavior: Bound

import ".."
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls

TextField {
    id: root

    color: root.enabled ? Colours.palette.m3onSurface : Qt.alpha(Colours.palette.m3onSurface, 0.38)
    placeholderTextColor: root.enabled ? Colours.palette.m3outline : Qt.alpha(Colours.palette.m3outline, 0.38)
    selectionColor: Colours.palette.m3primary
    selectedTextColor: Colours.palette.m3onPrimary
    font.family: Appearance.font.family.sans
    font.pointSize: Appearance.font.size.smaller
    renderType: echoMode === TextField.Password ? TextField.QtRendering : TextField.NativeRendering
    cursorVisible: !readOnly

    background: null

    cursorDelegate: StyledRect {
        id: cursor

        property bool disableBlink

        implicitWidth: 2
        color: Colours.palette.m3primary
        radius: Appearance.rounding.normal

        Connections {
            target: root

            function onCursorPositionChanged(): void {
                if (root.activeFocus && root.cursorVisible) {
                    cursor.opacity = 1;
                    cursor.disableBlink = true;
                    enableBlink.restart();
                }
            }
        }

        Timer {
            id: enableBlink

            interval: 100
            onTriggered: cursor.disableBlink = false
        }

        Timer {
            running: root.activeFocus && root.cursorVisible && !cursor.disableBlink
            repeat: true
            triggeredOnStart: true
            interval: 500
            onTriggered: parent.opacity = parent.opacity === 1 ? 0 : 1
        }

        Binding {
            when: !root.activeFocus || !root.cursorVisible
            cursor.opacity: 0
        }

        Behavior on opacity {
            Anim {
                duration: Appearance.anim.durations.small
            }
        }
    }

    Behavior on color {
        CAnim {}
    }

    Behavior on placeholderTextColor {
        CAnim {}
    }
}
