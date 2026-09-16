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

    // Runtime path contract row 10: cacheDir is the canonical
    // $XDG_CACHE_HOME/hornero/imagecache, so new entries are written there.
    // No dots/* read fallback is wired: cache entries are derived files that
    // regenerate on miss (see Paths.imagecacheFallback), and absolute legacy
    // source paths keep resolving directly.
    CachingImageManager {
        id: manager

        item: root
        cacheDir: Qt.resolvedUrl(Paths.imagecache)
    }
}
