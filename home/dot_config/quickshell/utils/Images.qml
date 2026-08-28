pragma Singleton

import Quickshell

Singleton {
    readonly property list<string> validImageTypes: ["jpeg", "png", "webp", "tiff", "svg"]
    readonly property list<string> validImageExtensions: ["jpg", "jpeg", "png", "webp", "tif", "tiff", "svg"]
    readonly property list<string> validVideoExtensions: ["mp4", "mkv", "webm", "avi", "mov"]
    readonly property list<string> validWallpaperExtensions: validImageExtensions.concat(validVideoExtensions)

    function isVideo(name: string): bool {
        return validVideoExtensions.some(t => name.endsWith(`.${t}`));
    }

    function isValidImageByName(name: string): bool {
        return validImageExtensions.some(t => name.endsWith(`.${t}`)) || isVideo(name);
    }
}
