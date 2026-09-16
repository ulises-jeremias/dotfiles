pragma Singleton

import qs.config
import Hornero
import Quickshell

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string pictures: Quickshell.env("XDG_PICTURES_DIR") || `${home}/Pictures`
    readonly property string videos: Quickshell.env("XDG_VIDEOS_DIR") || `${home}/Videos`

    // Runtime path contract (binding interface: HorneroOS/hornero
    // docs/PATH_CONTRACT.md). New writes go to hornero/*; readers check the
    // canonical hornero/* location first and fall back to the legacy dots/*
    // location (reads only, never written). Base resolution everywhere is
    // explicit env override -> XDG -> $HOME default. The DOTS_*_DIR
    // overrides below pin the legacy dots/* roots only.
    readonly property string dataHome: Quickshell.env("XDG_DATA_HOME") || `${home}/.local/share`
    readonly property string stateHome: Quickshell.env("XDG_STATE_HOME") || `${home}/.local/state`
    readonly property string cacheHome: Quickshell.env("XDG_CACHE_HOME") || `${home}/.cache`
    readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || `${home}/.config`

    // Canonical hornero/* roots: all new writes go here.
    readonly property string data: `${dataHome}/hornero`
    readonly property string state: `${stateHome}/hornero`
    readonly property string cache: `${cacheHome}/hornero`
    readonly property string config: `${Quickshell.env("DOTS_CONFIG_DIR") || `${configHome}/hornero`}`

    // Legacy dots/* roots: fallback reads only during the migration window.
    readonly property string dataFallback: `${Quickshell.env("DOTS_DATA_DIR") || `${dataHome}/dots`}`
    readonly property string stateFallback: `${Quickshell.env("DOTS_STATE_DIR") || `${stateHome}/dots`}`
    readonly property string cacheFallback: `${Quickshell.env("DOTS_CACHE_DIR") || `${cacheHome}/dots`}`

    /** Persistent wallpaper path pointer (one line); must match wallpaper-resolver.sh */
    readonly property string wallpaperPointer: `${state}/wallpaper/path`
    /** Legacy pointer location (contract row 9, fallback read only). */
    readonly property string wallpaperPointerFallback: `${stateFallback}/wallpaper/path`

    readonly property string imagecache: `${cache}/imagecache`
    /** Legacy image cache (contract row 10, fallback read only). */
    readonly property string imagecacheFallback: `${cacheFallback}/imagecache`
    readonly property string notifimagecache: `${imagecache}/notifs`
    /** Legacy notification image cache (contract row 10, fallback read only). */
    readonly property string notifimagecacheFallback: `${imagecacheFallback}/notifs`
    readonly property string wallsdir: Quickshell.env("HORNERO_WALLPAPERS_DIR") || absolutePath(Config.paths.wallpaperDir)
    readonly property string recsdir: Quickshell.env("HORNERO_RECORDINGS_DIR") || `${videos}/Recordings`
    readonly property string libdir: Quickshell.env("DOTS_LIB_DIR") || Quickshell.env("HORNERO_LIB_DIR") || "/usr/lib/hornero"

    function toLocalFile(path: url): string {
        path = Qt.resolvedUrl(path);
        return path.toString() ? CUtils.toLocalFile(path) : "";
    }

    function absolutePath(path: string): string {
        const expanded = path.replace(/~|(\$({?)HOME(}?))+/, home);

        // Keep plain absolute paths untouched. Resolving them as QML URLs can
        // produce non-local schemes depending on import context.
        if (expanded.startsWith("/"))
            return expanded;

        // Already a file URL.
        if (expanded.startsWith("file://"))
            return CUtils.toLocalFile(expanded);

        return toLocalFile(expanded);
    }

    function shortenHome(path: string): string {
        return path.replace(home, "~");
    }
}
