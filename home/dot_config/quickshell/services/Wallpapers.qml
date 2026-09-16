pragma Singleton

import qs.config
import qs.services
import qs.utils
import Hornero.Models
import Quickshell
import Quickshell.Io
import QtQuick

Searcher {
    id: root

    readonly property string wallpaperPointerPath: Paths.wallpaperPointer
    property bool showPreview: false
    readonly property string current: showPreview ? previewPath : actualCurrent
    property string previewPath
    property string actualCurrent
    property bool previewColourLock
    property string colorFilter: ""

    function setWallpaper(path: string): void {
        actualCurrent = path;
        ThemePipeline.setWallpaper(path);
    }

    // Instant native tone analysis for the preview path (issue #2, step
    // (b)). The full M3 preview palette below still needs dots-m3-colors.
    readonly property color previewDominantColour: WallpaperAnalysis.dominantColour
    readonly property real previewLuminance: WallpaperAnalysis.luminance
    readonly property bool previewNativeReady: WallpaperAnalysis.ready

    function preview(path: string): void {
        previewPath = path;
        showPreview = true;
        WallpaperAnalysis.analyze(path);

        if (Colours.scheme === "dynamic")
            getPreviewColoursProc.running = true;
    }

    function stopPreview(): void {
        showPreview = false;
        if (!previewColourLock)
            Colours.showPreview = false;
    }

    function reloadWallpaperPath(): void {
        resolveProc.running = true;
    }

    /** Raw pointer file content; avoids empty UI if dots-wallpaper-current fails (env/PATH). */
    function applyPointerFromFileView(pointerReadout: string): void {
        let t = pointerReadout.trim();
        if (!t.length)
            return;
        // Normalize file:// URIs written by some tools / drag-drop paths.
        if (t.startsWith("file://"))
            t = Paths.toLocalFile(t) || t.replace(/^file:\/\//, "");
        // Reject self-referential pointer corruption (pointer path written into itself).
        if (t === root.wallpaperPointerPath || t === Paths.wallpaperPointer)
            return;
        actualCurrent = t;
    }

    list: wallpapers.entries
    key: "relativePath"
    useFuzzy: Config.launcher.useFuzzy.wallpapers
    extraOpts: useFuzzy ? ({}) : ({
            forward: false
        })

    IpcHandler {
        target: "wallpaper"

        function get(): string {
            return root.actualCurrent;
        }

        function set(path: string): void {
            root.setWallpaper(path);
        }

        function list(): string {
            return root.list.map(w => w.path).join("\n");
        }
    }

    // TODO(hornero-compat): dots-wallpaper-current is an external runtime CLI
    // with a FileView pointer fallback below; see docs/COMPAT.md (A, B).
    Process {
        id: resolveProc

        command: [`${Quickshell.env("HOME")}/.local/bin/dots-wallpaper-current`]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const t = text.trim();
                if (t.length > 0)
                    root.actualCurrent = t;
                root.previewColourLock = false;
            }
        }
    }

    FileView {
        path: root.wallpaperPointerPath
        watchChanges: true
        onFileChanged: {
            root.applyPointerFromFileView(text());
            reloadWallpaperPath();
        }
        onLoaded: {
            root.applyPointerFromFileView(text());
            reloadWallpaperPath();
        }
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound)
                reloadWallpaperPath();
        }
    }

    FileSystemModel {
        id: wallpapers

        recursive: true
        path: Paths.wallsdir
        filter: FileSystemModel.Files
    }

    Component.onCompleted: Qt.callLater(() => reloadWallpaperPath())

    // TODO(hornero-compat): full M3 preview palette needs materialyoucolor
    // via dots-m3-colors; native dominant/luminance comes from
    // WallpaperAnalysis above. Thin compat adapter; see
    // docs/NATIVE-APPEARANCE.md.
    Process {
        id: getPreviewColoursProc

        command: [
            `${Quickshell.env("HOME")}/.local/bin/dots-m3-colors`,
            "--image",
            root.previewPath,
            "--mode",
            Colours.currentLight ? "light" : "dark"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                Colours.load(text, true);
                Colours.showPreview = true;
            }
        }
    }
}
