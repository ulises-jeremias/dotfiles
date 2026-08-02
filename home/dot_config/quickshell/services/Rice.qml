pragma Singleton

import qs.services
import qs.utils
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string ricesDir: `${Paths.data}/rices`
    readonly property string stateFile: `${Paths.state}/rice/current`
    readonly property string wallpaperPointer: Paths.wallpaperPointer
    readonly property string m3Script: `${Quickshell.env("HOME")}/.local/lib/dots/generate-m3-colors.py`
    readonly property string schemeJson: `${Paths.cache}/smart-colors/scheme.json`
    readonly property string hyprAnimDir: `${Quickshell.env("HOME")}/.config/hypr/hyprland.conf.d`

    property string currentId: ""
    property var currentConfig: ({})
    readonly property bool busy: _busy

    property bool _startupRestored: false
    property bool _busy: false
    property var _queue: []
    property string _jobKind: ""

    property string _pendingWallpaper: ""
    property string _pendingSchemeType: "tonal-spot"
    property bool _pendingDarkMode: true
    property string _pendingRiceId: ""
    property string _applyRiceId: ""
    property bool _persistRiceOnSuccess: false
    property string _lastError: ""

    signal applyFinished(bool ok)

    // ── Public API ──────────────────────────────────────────────────────────

    /**
     * Apply a rice by id, optionally with an explicit wallpaper path.
     * If wallpaperPath is empty the first image from the rice's backgrounds/ is used.
     */
    function apply(id: string, wallpaperPath: string): void {
        if (!id)
            return;
        _enqueue({
            kind: "apply",
            riceId: id,
            wallpaper: wallpaperPath || ""
        });
    }

    /**
     * Re-run wal -R and regenerate scheme without changing the rice or wallpaper.
     */
    function reload(): void {
        _enqueue({
            kind: "reload"
        });
    }

    /**
     * Set wallpaper only (no rice switch). Runs wal -i + updates pointer + regenerates scheme.
     */
    function setWallpaper(path: string): void {
        if (!path)
            return;
        _enqueue({
            kind: "wallpaper",
            wallpaper: path
        });
    }

    function _enqueue(job: var): void {
        _queue = _queue.concat([job]);
        _pump();
    }

    function _pump(): void {
        if (_busy || _queue.length === 0)
            return;
        const job = _queue[0];
        _queue = _queue.slice(1);
        _busy = true;
        _lastError = "";
        _jobKind = job.kind || "";

        if (job.kind === "apply") {
            _pendingRiceId = job.riceId;
            _applyRiceId = job.riceId;
            _persistRiceOnSuccess = true;
            configLoader.riceId = job.riceId;
            configLoader.wallpaperOverride = job.wallpaper || "";
            configLoader.running = true;
        } else if (job.kind === "wallpaper") {
            _persistRiceOnSuccess = false;
            _applyRiceId = root.currentId;
            _pendingWallpaper = job.wallpaper;
            // Wallpaper-only: live mode + flavour from Colours/state, not rice defaults.
            _pendingSchemeType = Colours.flavour || currentConfig.schemeType || "tonal-spot";
            _pendingDarkMode = !Colours.currentLight;
            walProc.running = true;
        } else if (job.kind === "reload") {
            _persistRiceOnSuccess = false;
            _applyRiceId = root.currentId;
            _pendingWallpaper = Wallpapers.actualCurrent || "";
            _pendingSchemeType = Colours.flavour || currentConfig.schemeType || "tonal-spot";
            _pendingDarkMode = !Colours.currentLight;
            walReloadProc.running = true;
        } else {
            _finishJob(false, "unknown job kind");
        }
    }

    function _finishJob(ok: bool, err: string): void {
        if (!ok) {
            _lastError = err || "appearance apply failed";
            console.warn("Rice.qml:", _lastError);
            notifyFailProc.message = _lastError;
            notifyFailProc.running = true;
        }
        _busy = false;
        _persistRiceOnSuccess = false;
        root.applyFinished(ok);
        Qt.callLater(() => root._pump());
    }

    // ── Restore current rice id from state file on startup ──────────────────

    FileView {
        id: riceStateFile

        path: root.stateFile
        watchChanges: true
        // Must call FileView.reload — root.reload() would re-run wal.
        onFileChanged: riceStateFile.reload()
        onLoaded: {
            const id = text().trim();
            if (id && id !== root.currentId)
                root.currentId = id;
            if (id && !root._startupRestored) {
                root._startupRestored = true;
                ensureSchemeProc.running = true;
            }
        }
        onLoadFailed: console.warn("Rice.qml: state file not found:", root.stateFile)
    }

    Component.onCompleted: {
        Qt.callLater(() => {
            if (root.currentId && !root._startupRestored) {
                root._startupRestored = true;
                ensureSchemeProc.running = true;
            }
        });
    }

    Process {
        id: ensureSchemeProc

        command: ["dots-color-scheme", "regenerate"]

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                console.warn("Rice.qml: scheme regeneration failed (exit", exitCode, ")");
        }
    }

    // ── Step 1: load config.json for the requested rice ────────────────────

    QtObject {
        id: configLoader

        property string riceId: ""
        property string wallpaperOverride: ""
        property bool running: false
        property string resolvedWallpaper: ""
        property var pendingConfig: ({})
    }

    FileView {
        id: configFileView

        path: configLoader.running ? `${root.ricesDir}/${configLoader.riceId}/config.json` : ""

        onLoaded: {
            // Read text() BEFORE clearing configLoader.running, because the
            // `path` binding evaluates to "" when running is false, causing
            // text() to return an empty string and JSON.parse to fail.
            let rawText = "";
            try {
                rawText = text();
            } catch (e) {
                console.warn("Rice.qml: failed to read config.json for", configLoader.riceId, e);
                configLoader.running = false;
                root._finishJob(false, `failed to read config.json for ${configLoader.riceId}`);
                return;
            }

            configLoader.running = false;

            let cfg = {};
            try {
                cfg = JSON.parse(rawText);
            } catch (e) {
                console.warn("Rice.qml: failed to parse config.json for", configLoader.riceId, e);
                root._finishJob(false, `invalid config.json for ${configLoader.riceId}`);
                return;
            }

            // Stash config for this apply; promote to currentConfig only after
            // wal + M3 succeed so wallpaper-only changes do not use a failed rice.
            configLoader.pendingConfig = cfg;
            root._pendingRiceId = configLoader.riceId;
            root._pendingSchemeType = cfg.schemeType || "tonal-spot";
            root._pendingDarkMode = cfg.darkMode !== undefined ? !!cfg.darkMode : true;

            const wp = configLoader.wallpaperOverride;
            if (wp) {
                configLoader.resolvedWallpaper = wp;
                root._startWalWithConfig();
            } else {
                firstWallpaperProc.running = true;
            }
        }

        onLoadFailed: {
            console.warn("Rice.qml: config.json not found for rice", configLoader.riceId);
            configLoader.running = false;
            root._finishJob(false, `config.json not found for ${configLoader.riceId}`);
        }
    }

    // Persist current rice id (canonical only) and purge legacy pointers
    Process {
        id: persistRiceProc

        property string riceId: ""

        command: ["sh", "-c", 'mkdir -p "$(dirname "$DOTS_RICE_CANON")" && printf "%s\\n" "$DOTS_RICE_ID" > "$DOTS_RICE_CANON" && rm -f "$HOME/.local/share/dots/rices/.current_rice" "$HOME/.cache/dots/current_rice"']
        environment: ({
            "DOTS_RICE_ID": persistRiceProc.riceId || root.currentId,
            "DOTS_RICE_CANON": root.stateFile
        })
    }

    // Find first wallpaper in the rice's backgrounds/ directory (follow symlinks)
    Process {
        id: firstWallpaperProc

        command: ["sh", "-c", `
find -L "$DOTS_BG_DIR" -maxdepth 1 \\( -type f -o -type l \\) \\( \
  -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \
  -o -iname "*.gif" -o -iname "*.bmp" \
\\) 2>/dev/null | sort | head -n 1
`]
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
                    root._finishJob(false, `no wallpapers found for rice ${configLoader.riceId}`);
                }
            }
        }
    }

    function _startWalWithConfig(): void {
        _pendingWallpaper = configLoader.resolvedWallpaper;
        const cfg = configLoader.pendingConfig || {};
        _pendingSchemeType = cfg.schemeType || "tonal-spot";
        _pendingDarkMode = cfg.darkMode !== undefined ? !!cfg.darkMode : true;
        walProc.running = true;
    }

    // ── Step 2a: wal -i (set new wallpaper) ────────────────────────────────

    Process {
        id: walProc

        command: root._pendingDarkMode
            ? ["wal", "-i", root._pendingWallpaper, "-q"]
            : ["wal", "-i", root._pendingWallpaper, "-q", "-l"]

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root._finishJob(false, `wal failed (exit ${exitCode})`);
                return;
            }
            writeWallpaperPointer.running = true;
            m3Proc.running = true;
        }
    }

    // Write wallpaper pointer + realign ~/.cache/wal/wal (shell apply parity)
    Process {
        id: writeWallpaperPointer

        command: ["sh", "-c", 'mkdir -p "$(dirname "$DOTS_WALLPAPER_PTR")" "$HOME/.cache/wal" && printf "%s\\n" "$DOTS_WALLPAPER_PATH" > "$DOTS_WALLPAPER_PTR" && ln -sfn "$DOTS_WALLPAPER_PATH" "$HOME/.cache/wal/wal"']
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
            if (exitCode !== 0) {
                root._finishJob(false, `wal -R failed (exit ${exitCode})`);
                return;
            }
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
            if (exitCode !== 0) {
                root._finishJob(false, `M3 colour generation failed (exit ${exitCode})`);
                return;
            }
            syncStateProc.running = true;
        }
    }

    // Sync scheme/state.json from scheme.json so boot regenerate cannot drift
    Process {
        id: syncStateProc

        command: ["dots-color-scheme", "sync-state"]

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                console.warn("Rice.qml: sync-state failed (exit", exitCode, ")");
            touchSchemeProc.running = true;
            if (root._persistRiceOnSuccess && root._pendingRiceId) {
                if (configLoader.pendingConfig && Object.keys(configLoader.pendingConfig).length)
                    root.currentConfig = configLoader.pendingConfig;
                root.currentId = root._pendingRiceId;
                persistRiceProc.riceId = root._pendingRiceId;
                persistRiceProc.running = true;
            }
            root._runSideEffects();
            root._finishJob(true, "");
        }
    }

    Process {
        id: touchSchemeProc

        command: ["touch", root.schemeJson]
    }

    // ── Step 4: side effects (Hyprland, kitty, GTK, snappy, hyprlock, notify)

    function _runSideEffects(): void {
        const cfg = root.currentConfig;
        const riceId = root._applyRiceId || root.currentId;
        const fullApply = root._jobKind === "apply";

        // Always refresh lockscreen colours from the new palette.
        hyprlockProc.running = true;

        if (fullApply && cfg && cfg.hyprlandAnimations) {
            hyprAnimProc.animProfile = cfg.hyprlandAnimations;
            hyprAnimProc.running = true;
        }

        hyprReloadProc.running = true;

        // Wallpaper-only / reload must not snap GTK/snappy back to rice defaults
        // after the user flipped live Theme mode.
        if (fullApply) {
            if (cfg && cfg.kittyOpacity !== null && cfg.kittyOpacity !== undefined) {
                kittyProc.kittyOpacity = String(cfg.kittyOpacity);
                kittyProc.running = true;
            }
            if (riceId) {
                gtkProc.riceId = riceId;
                gtkProc.running = true;
                snappyProc.riceId = riceId;
                snappyProc.running = true;
            }
            if (cfg && (cfg.name || riceId)) {
                notifyProc.riceName = cfg.name || riceId;
                notifyProc.running = true;
            }
        }
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

        property string riceId: ""

        command: ["dots-gtk-theme", "rice", gtkProc.riceId]
    }

    Process {
        id: snappyProc

        property string riceId: ""

        command: ["bash", "-c", 'source "$HOME/.local/lib/dots/snappy-switcher-manager.sh" 2>/dev/null || exit 0; declare -f apply_rice_snappy_switcher_theme >/dev/null 2>&1 && apply_rice_snappy_switcher_theme "$DOTS_RICE_ID" || true']
        environment: ({
            "DOTS_RICE_ID": snappyProc.riceId
        })
    }

    Process {
        id: hyprlockProc

        command: ["dots-hyprlock-theme"]
    }

    Process {
        id: notifyProc

        property string riceName: ""

        command: ["notify-send", "HorneroConfig", `${notifyProc.riceName} rice applied`]
    }

    Process {
        id: notifyFailProc

        property string message: ""

        command: ["notify-send", "-u", "critical", "HorneroConfig", notifyFailProc.message || "Appearance apply failed"]
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

        function isBusy(): string {
            return root._busy ? "1" : "0";
        }

        function lastError(): string {
            return root._lastError;
        }
    }
}
