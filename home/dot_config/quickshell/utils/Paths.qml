pragma Singleton

import qs.config
import Caelestia
import Quickshell

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string pictures: Quickshell.env("XDG_PICTURES_DIR") || `${home}/Pictures`
    readonly property string videos: Quickshell.env("XDG_VIDEOS_DIR") || `${home}/Videos`

    readonly property string data: `${Quickshell.env("DOTS_DATA_DIR") || `${Quickshell.env("XDG_DATA_HOME") || `${home}/.local/share`}/dots`}`
    readonly property string state: `${Quickshell.env("DOTS_STATE_DIR") || `${Quickshell.env("XDG_STATE_HOME") || `${home}/.local/state`}/dots`}`
    readonly property string cache: `${Quickshell.env("DOTS_CACHE_DIR") || `${Quickshell.env("XDG_CACHE_HOME") || `${home}/.cache`}/dots`}`
    readonly property string config: `${Quickshell.env("DOTS_CONFIG_DIR") || `${Quickshell.env("XDG_CONFIG_HOME") || `${home}/.config`}/hornero`}`

    readonly property string imagecache: `${cache}/imagecache`
    readonly property string notifimagecache: `${imagecache}/notifs`
    readonly property string wallsdir: Quickshell.env("CAELESTIA_WALLPAPERS_DIR") || absolutePath(Config.paths.wallpaperDir)
    readonly property string recsdir: Quickshell.env("CAELESTIA_RECORDINGS_DIR") || `${videos}/Recordings`
    readonly property string libdir: Quickshell.env("DOTS_LIB_DIR") || Quickshell.env("CAELESTIA_LIB_DIR") || "/usr/lib/caelestia"

    function toLocalFile(path: url): string {
        path = Qt.resolvedUrl(path);
        return path.toString() ? CUtils.toLocalFile(path) : "";
    }

    function absolutePath(path: string): string {
        return toLocalFile(path.replace(/~|(\$({?)HOME(}?))+/, home));
    }

    function shortenHome(path: string): string {
        return path.replace(home, "~");
    }
}
