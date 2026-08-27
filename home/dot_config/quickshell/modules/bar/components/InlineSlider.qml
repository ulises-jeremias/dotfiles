pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Layouts

// Inline volume/brightness slider for the bar (horizontal layouts).
// Mirrors the classic Hornero top/bottom bar look: icon + slim slider.
RowLayout {
    id: root

    required property ShellScreen screen
    required property string kind // "audio" | "brightness"

    readonly property bool isAudio: kind === "audio"
    readonly property Brightness.Monitor monitor: Brightness.getMonitorForScreen(screen)

    spacing: Appearance.spacing.small
    implicitWidth: icon.implicitWidth + spacing + slider.implicitWidth
    implicitHeight: Math.max(icon.implicitHeight, slider.implicitHeight)

    MaterialIcon {
        id: icon

        Layout.alignment: Qt.AlignVCenter
        text: {
            if (!root.isAudio)
                return "brightness_6";
            if (Audio.muted || Audio.volume === 0)
                return "volume_off";
            return "volume_up";
        }
        color: Colours.palette.m3onSurfaceVariant

        Behavior on text {
            Anim {}
        }
    }

    StyledSlider {
        id: slider

        Layout.alignment: Qt.AlignVCenter
        implicitWidth: 110
        implicitHeight: Appearance.font.size.normal * 1.6
        from: 0
        to: 1
        value: root.isAudio ? Audio.volume : (root.monitor?.brightness ?? 0)

        onMoved: {
            if (root.isAudio)
                Audio.setVolume(value);
            else if (root.monitor)
                root.monitor.setBrightness(value);
        }

        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => {
                if (root.isAudio) {
                    if (event.angleDelta.y > 0)
                        Audio.incrementVolume();
                    else
                        Audio.decrementVolume();
                } else if (root.monitor) {
                    const delta = Config.services.brightnessIncrement * (event.angleDelta.y > 0 ? 1 : -1);
                    root.monitor.setBrightness(Math.max(0, Math.min(1, root.monitor.brightness + delta)));
                }
                event.accepted = true;
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
            z: -1
        }
    }
}
