import qs.utils
import Hornero.Internal
import Quickshell
import QtQuick

Image {
    id: root

    property alias path: manager.path

    asynchronous: true
    fillMode: Image.PreserveAspectCrop

    Connections {
        target: QsWindow.window

        function onDevicePixelRatioChanged(): void {
            manager.updateSource();
        }
    }

    CachingImageManager {
        id: manager

        item: root
        cacheDir: Qt.resolvedUrl(Paths.imagecache)
    }
}
