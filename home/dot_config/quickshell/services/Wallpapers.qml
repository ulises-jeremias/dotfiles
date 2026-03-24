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
    readonly property string wpgPointerPath: `${Quickshell.env("HOME")}/.config/wpg/.current`
    property bool showPreview: false
    readonly property string current: showPreview ? previewPath : actualCurrent
    property string previewPath
    property string actualCurrent
    property bool previewColourLock

    function setWallpaper(path: string): void {
        actualCurrent = path;
        Quickshell.execDetached(["dots-wallpaper-set", path]);
    }

    function preview(path: string): void {
        previewPath = path;
        showPreview = true;

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
        const t = pointerReadout.trim();
        if (t.length > 0)
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

    Process {
        id: resolveProc

        command: [`${Quickshell.env("HOME")}/.local/bin/dots-wallpaper-current`]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const t = text().trim();
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

    FileView {
        path: root.wpgPointerPath
        watchChanges: true
        onFileChanged: reloadWallpaperPath()
        onLoaded: reloadWallpaperPath()
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound)
                reloadWallpaperPath();
        }
    }

    FileSystemModel {
        id: wallpapers

        recursive: true
        path: Paths.wallsdir
        filter: FileSystemModel.Images
    }

    Component.onCompleted: Qt.callLater(() => reloadWallpaperPath())

    Process {
        id: getPreviewColoursProc

        command: [
            "python3",
            `${Quickshell.env("HOME")}/.local/lib/dots/generate-m3-colors.py`,
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
