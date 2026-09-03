pragma Singleton

import Quickshell

Singleton {
    readonly property list<string> validImageTypes: ["jpeg", "png", "webp", "tiff", "svg", "gif"]
    readonly property list<string> validImageExtensions: ["jpg", "jpeg", "png", "webp", "tif", "tiff", "svg", "gif"]
    readonly property list<string> validVideoExtensions: ["mp4", "mkv", "webm", "avi", "mov"]
    // Animated raster formats: rendered with a live Image (QtQuick plays
    // these natively), never through the static thumbnail cache.
    readonly property list<string> animatedImageExtensions: ["gif", "apng"]
    readonly property list<string> validWallpaperExtensions: validImageExtensions.concat(validVideoExtensions)

    function isVideo(name: string): bool {
        return validVideoExtensions.some(t => name.endsWith(`.${t}`));
    }

    function isAnimatedImage(name: string): bool {
        return animatedImageExtensions.some(t => name.toLowerCase().endsWith(`.${t}`));
    }

    function isValidImageByName(name: string): bool {
        return validImageExtensions.some(t => name.endsWith(`.${t}`)) || isVideo(name);
    }
}
