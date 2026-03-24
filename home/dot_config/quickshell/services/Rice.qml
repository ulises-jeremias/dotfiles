pragma Singleton

import qs.services
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string ricesDir: `${Quickshell.env("HOME")}/.local/share/dots/rices`
    readonly property string stateFile: `${Quickshell.env("HOME")}/.local/state/dots/rice/current`
    readonly property string wallpaperPointer: `${Quickshell.env("HOME")}/.local/state/dots/wallpaper/path`
    readonly property string m3Script: `${Quickshell.env("HOME")}/.local/lib/dots/generate-m3-colors.py`
    readonly property string schemeJson: `${Quickshell.env("HOME")}/.cache/dots/smart-colors/scheme.json`
    readonly property string hyprAnimDir: `${Quickshell.env("HOME")}/.config/hypr/hyprland.conf.d`

    property string currentId: ""
    property var currentConfig: ({})

    property string _pendingWallpaper: ""
    property string _pendingSchemeType: "tonal-spot"
    property bool _pendingDarkMode: true
    property string _pendingRiceId: ""

    // ── Public API ──────────────────────────────────────────────────────────

    /**
     * Apply a rice by id, optionally with an explicit wallpaper path.
     * If wallpaperPath is empty the first image from the rice's backgrounds/ is used.
     */
    function apply(id: string, wallpaperPath: string): void {
        if (!id)
            return;
        _pendingRiceId = id;
        configLoader.riceId = id;
        configLoader.wallpaperOverride = wallpaperPath || "";
        configLoader.running = true;
    }

    /**
     * Re-run wal -R and regenerate scheme without changing the rice or wallpaper.
     * Equivalent to the old dots-wal-reload.
     */
    function reload(): void {
        walReloadProc.running = true;
    }

    /**
     * Set wallpaper only (no rice switch). Runs wal -i + updates pointer + regenerates scheme.
     */
    function setWallpaper(path: string): void {
        if (!path)
            return;
        _pendingWallpaper = path;
        _pendingSchemeType = currentConfig.schemeType || "tonal-spot";
        _pendingDarkMode = currentConfig.darkMode !== undefined ? !!currentConfig.darkMode : true;
        walProc.running = true;
    }

    // ── Restore current rice id from state file on startup ──────────────────

    FileView {
        path: root.stateFile
        onLoaded: {
            const id = text().trim();
            if (id)
                root.currentId = id;
        }
    }

    // ── Step 1: load config.json for the requested rice ────────────────────

    QtObject {
        id: configLoader

        property string riceId: ""
        property string wallpaperOverride: ""
        property bool running: false
        property string resolvedWallpaper: ""
    }

    FileView {
        id: configFileView

        path: configLoader.running ? `${root.ricesDir}/${configLoader.riceId}/config.json` : ""

        onLoaded: {
            configLoader.running = false;
            let cfg = {};
            try {
                cfg = JSON.parse(text());
            } catch (e) {
                console.warn("Rice.qml: failed to parse config.json for", configLoader.riceId, e);
                return;
            }

            root.currentConfig = cfg;
            root.currentId = configLoader.riceId;

            // Persist current rice id via shell write
            persistRiceProc.running = true;

            const wp = configLoader.wallpaperOverride;
            if (wp) {
                configLoader.resolvedWallpaper = wp;
                _startWalWithConfig();
            } else {
                firstWallpaperProc.running = true;
            }
        }

        onLoadFailed: {
            console.warn("Rice.qml: config.json not found for rice", configLoader.riceId);
            configLoader.running = false;
        }
    }

    // Persist current rice id to state file
    Process {
        id: persistRiceProc

        // Pass values via env so paths/ids with special chars are safe
        command: ["sh", "-c", 'mkdir -p "$(dirname "$DOTS_STATE_FILE")" && printf "%s\\n" "$DOTS_RICE_ID" > "$DOTS_STATE_FILE"']
        environment: ({
            "DOTS_STATE_FILE": root.stateFile,
            "DOTS_RICE_ID": root.currentId
        })
    }

    // Find first wallpaper in the rice's backgrounds/ directory
    Process {
        id: firstWallpaperProc

        command: ["sh", "-c", 'find "$DOTS_BG_DIR" -maxdepth 1 -type f \\( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \\) 2>/dev/null | sort | head -n 1']
        environment: ({
            "DOTS_BG_DIR": `${root.ricesDir}/${configLoader.riceId}/backgrounds`
        })

        stdout: StdioCollector {
            onStreamFinished: {
                const wp = text.trim();
                if (wp) {
                    configLoader.resolvedWallpaper = wp;
                    root._startWalWithConfig();
                } else {
                    console.warn("Rice.qml: no wallpapers found for rice", configLoader.riceId);
                }
            }
        }
    }

    function _startWalWithConfig(): void {
        _pendingWallpaper = configLoader.resolvedWallpaper;
        _pendingSchemeType = root.currentConfig.schemeType || "tonal-spot";
        _pendingDarkMode = root.currentConfig.darkMode !== undefined ? !!root.currentConfig.darkMode : true;
        walProc.running = true;
    }

    // ── Step 2a: wal -i (set new wallpaper) ────────────────────────────────

    Process {
        id: walProc

        // Build the command inline so QML's dependency tracker picks up _pendingWallpaper
        // and _pendingDarkMode correctly. var array literals break reactivity.
        command: root._pendingDarkMode
            ? ["wal", "-i", root._pendingWallpaper, "-q"]
            : ["wal", "-i", root._pendingWallpaper, "-q", "-l"]

        onExited: (exitCode, exitStatus) => {
            writeWallpaperPointer.running = true;
            m3Proc.running = true;
        }
    }

    // Write wallpaper pointer state file
    Process {
        id: writeWallpaperPointer

        command: ["sh", "-c", 'mkdir -p "$(dirname "$DOTS_WALLPAPER_PTR")" && printf "%s\\n" "$DOTS_WALLPAPER_PATH" > "$DOTS_WALLPAPER_PTR"']
        environment: ({
            "DOTS_WALLPAPER_PTR": root.wallpaperPointer,
            "DOTS_WALLPAPER_PATH": root._pendingWallpaper
        })
    }

    // ── Step 2b: wal -R (reload colors only, no wallpaper change) ──────────

    Process {
        id: walReloadProc

        command: ["wal", "-R", "-q"]

        onExited: (exitCode, exitStatus) => {
            m3Proc.running = true;
        }
    }

    // ── Step 3: generate M3 scheme.json ────────────────────────────────────

    Process {
        id: m3Proc

        readonly property string image: root._pendingWallpaper || Wallpapers.actualCurrent
        readonly property string mode: root._pendingDarkMode ? "dark" : "light"
        readonly property string schemeType: root._pendingSchemeType || "tonal-spot"

        command: [
            "python3", root.m3Script,
            "--image", image,
            "--scheme-type", schemeType,
            "--mode", mode,
            "--output", root.schemeJson
        ]

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0)
                touchSchemeProc.running = true;
            _runSideEffects();
        }
    }

    // Touch scheme.json so Colours.qml FileView triggers onFileChanged
    Process {
        id: touchSchemeProc

        command: ["touch", root.schemeJson]
    }

    // ── Step 4: side effects (Hyprland, kitty, GTK, notify) ────────────────

    function _runSideEffects(): void {
        const cfg = root.currentConfig;
        if (!cfg || !cfg.id)
            return;

        const anim = cfg.hyprlandAnimations || "";
        if (anim) {
            hyprAnimProc.animProfile = anim;
            hyprAnimProc.running = true;
        }

        hyprReloadProc.running = true;

        const opacity = cfg.kittyOpacity;
        if (opacity !== null && opacity !== undefined) {
            kittyProc.kittyOpacity = String(opacity);
            kittyProc.running = true;
        }

        const gtkTheme = cfg.gtkTheme || "";
        if (gtkTheme && gtkTheme !== "auto") {
            gtkProc.gtkTheme = gtkTheme;
            gtkProc.running = true;
        }

        notifyProc.riceName = cfg.name || root.currentId;
        notifyProc.running = true;
    }

    Process {
        id: hyprAnimProc

        property string animProfile: ""

        command: ["sh", "-c", '[ -f "$DOTS_ANIM_SRC" ] && ln -sf "$DOTS_ANIM_SRC" "$DOTS_ANIM_DST" || true']
        environment: ({
            "DOTS_ANIM_SRC": `${root.hyprAnimDir}/animations-${hyprAnimProc.animProfile}.conf`,
            "DOTS_ANIM_DST": `${root.hyprAnimDir}/animations-current.conf`
        })
    }

    Process {
        id: hyprReloadProc

        command: ["hyprctl", "reload"]
    }

    Process {
        id: kittyProc

        property string kittyOpacity: "0.9"

        command: ["kitty", "@", "set-colors", "--all", `background_opacity=${kittyProc.kittyOpacity}`]
    }

    Process {
        id: gtkProc

        property string gtkTheme: ""

        command: ["dots-gtk-theme", "apply", gtkProc.gtkTheme]
    }

    Process {
        id: notifyProc

        property string riceName: ""

        command: ["notify-send", "HorneroConfig", `${notifyProc.riceName} rice applied`]
    }

    // ── IPC ─────────────────────────────────────────────────────────────────

    IpcHandler {
        target: "rice"

        function apply(id: string, wallpaper: string): void {
            root.apply(id, wallpaper || "");
        }

        function reload(): void {
            root.reload();
        }

        function current(): string {
            return root.currentId;
        }

        function setWallpaper(path: string): void {
            root.setWallpaper(path);
        }
    }
}
