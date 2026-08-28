pragma ComponentBehavior: Bound

import QtQuick
import qs.components
import qs.components.effects

StyledListView {
    id: root

    property real fadeAmount: 0.2

    property real topFadeOpacity: fadeShouldBeActive(true) ? 0 : 1
    property real bottomFadeOpacity: fadeShouldBeActive(false) ? 0 : 1

    function fadeShouldBeActive(isStart: bool): bool {
        if (contentHeight + topMargin + bottomMargin < height && rebound.running && ((isStart ? verticalOvershoot > 0 : verticalOvershoot < 0)))
            return false;

        if (isStart)
            return visibleArea.yPosition > 0;
        return visibleArea.yPosition + visibleArea.heightRatio < 1;
    }

    flickableDirection: Flickable.VerticalFlick
    orientation: ListView.Vertical

    layer.enabled: true
    layer.effect: Mask {
        maskSource: mask

        Rectangle {
            id: mask

            layer.enabled: true
            visible: false
            implicitWidth: root.width
            implicitHeight: root.height

            gradient: Gradient {
                orientation: Gradient.Vertical

                GradientStop {
                    position: 0
                    color: Qt.rgba(0, 0, 0, root.topFadeOpacity)

                    Behavior on color {
                        CAnim {}
                    }
                }
                GradientStop {
                    position: root.fadeAmount
                    color: "black"

                    Behavior on color {
                        CAnim {}
                    }
                }
                GradientStop {
                    position: 1 - root.fadeAmount
                    color: "black"

                    Behavior on color {
                        CAnim {}
                    }
                }
                GradientStop {
                    position: 1
                    color: Qt.rgba(0, 0, 0, root.bottomFadeOpacity)

                    Behavior on color {
                        CAnim {}
                    }
                }
            }
        }
    }
}
