import QtQuick
import qs.components

Image {
    id: root

    default property alias data: root.data
    property int fadeDuration: Appearance.anim.durations.normal
    property int fadeInType: Appearance.anim.type ?? 0

    property bool _hadPrevious: false
    property bool _fadingOut

    onSourceChanged: {
        if (!source && !_hadPrevious)
            return;

        if (root.status === Image.Ready || root.progress > 0) {
            root._hadPrevious = true;
            return;
        }

        if (_hadPrevious) {
            _fadingOut = true;
            fadeOutAnim.restart();
        }
        sourceLoader.sourceComponent = placeholderComponent;
    }

    Component {
        id: placeholderComponent

        Item {}
    }

    Loader {
        id: sourceLoader

        anchors.fill: parent
        sourceComponent: null
    }

    SequentialAnimation {
        id: fadeOutAnim

        PropertyAction {
            target: root
            property: "visible"
            value: true
        }
        Anim {
            target: root
            property: "opacity"
            to: 0
        }
        ScriptAction {
            script: {
                root._fadingOut = false;
            }
        }
    }

    onStatusChanged: {
        if (root.status !== Image.Ready)
            return;

        if (root._fadingOut) {
            fadeIn.restart();
            return;
        }

        if (root._hadPrevious) {
            fadeIn.restart();
            return;
        }

        sourceLoader.sourceComponent = null;
        root._hadPrevious = true;
        fadeIn.restart();
    }

    Anim {
        id: fadeIn

        target: root
        property: "opacity"
        from: 0
        to: 1
    }
}
