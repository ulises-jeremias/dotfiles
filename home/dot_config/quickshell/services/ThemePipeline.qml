pragma Singleton

import qs.services
import qs.utils
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string themesDir: `${Paths.data}/themes`
    readonly property string wallpapersDir: `${Paths.data}/wallpapers`
    readonly property string picturesWallpapers: `${Paths.pictures}/Wallpapers`
    readonly property string wallpaperPointer: Paths.wallpaperPointer
    readonly property string m3Script: `${Quickshell.env("HOME")}/.local/lib/dots/generate-m3-colors.py`
    readonly property string schemeJson: `${Paths.cache}/smart-colors/scheme.json`

    readonly property bool busy: _busy || _queue.length > 0
    property bool _busy: false
    property var _queue: []
    property string _jobKind: ""
    property string _pendingWallpaper: ""
    property string _pendingSchemeType: "tonal-spot"
    property bool _pendingDarkMode: true
    property string _pendingGtkTheme: ""
    property string _pendingIconTheme: ""
    property string _pendingThemeName: ""
    property string _pendingThemeId: ""
    property bool _runThemeSideEffects: false
    property string _lastError: ""
    readonly property string lastError: _lastError
    property bool _startupRestored: false

    signal applyFinished(bool ok)

    function applyTheme(id: string, wallpaperPath: string): void {
        if (!id)
            return;
        _enqueue({
            kind: "theme",
            themeId: id,
            wallpaper: wallpaperPath || ""
        });
    }

    function reload(): void {
        _enqueue({
            kind: "reload"
        });
    }

    function setWallpaper(path: string): void {
        if (!path)
            return;
        _enqueue({
            kind: "wallpaper",
            wallpaper: path
        });
    }

    function setGtk(theme: string): void {
        if (!theme)
            return;
        _enqueue({
            kind: "gtk",
            gtkTheme: theme
        });
    }

    function setIcons(theme: string): void {
        if (!theme)
            return;
        _enqueue({
            kind: "icons",
            iconTheme: theme
        });
    }

    function _enqueue(job: var): void {
        const tail = _queue.length ? _queue[_queue.length - 1] : null;
        if (tail && tail.kind === job.kind && tail.themeId === job.themeId && tail.wallpaper === job.wallpaper && tail.gtkTheme === job.gtkTheme && tail.iconTheme === job.iconTheme)
            return;
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
        _runThemeSideEffects = false;
        _pendingGtkTheme = "";
        _pendingIconTheme = "";
        _pendingThemeName = "";
        _pendingThemeId = "";

        if (job.kind === "theme") {
            _runThemeSideEffects = true;
            _pendingThemeId = job.themeId || "";
            themeLoader.themeId = job.themeId;
            themeLoader.wallpaperOverride = job.wallpaper || "";
            themeLoader.running = true;
        } else if (job.kind === "wallpaper") {
            _pendingWallpaper = job.wallpaper;
            _pendingSchemeType = Colours.flavour || "tonal-spot";
            _pendingDarkMode = !Colours.currentLight;
            walPrepProc.running = true;
        } else if (job.kind === "reload") {
            _pendingWallpaper = Wallpapers.actualCurrent || "";
            _pendingSchemeType = Colours.flavour || "tonal-spot";
            _pendingDarkMode = !Colours.currentLight;
            walReloadProc.running = true;
        } else if (job.kind === "gtk") {
            gtkStandaloneProc.themeName = job.gtkTheme || "";
            gtkStandaloneProc.mode = Colours.currentLight ? "light" : "dark";
            gtkStandaloneProc.running = true;
        } else if (job.kind === "icons") {
            iconOnlyProc.themeName = job.iconTheme || "";
            iconOnlyProc.running = true;
        } else {
            _finishJob(false, "unknown job kind");
        }
    }

    function _finishJob(ok: bool, err: string): void {
        if (!ok) {
            _lastError = err || "appearance apply failed";
            console.warn("ThemePipeline:", _lastError);
            notifyFailProc.message = _lastError;
            notifyFailProc.running = true;
        }
        _busy = false;
        _runThemeSideEffects = false;
        root.applyFinished(ok);
        Qt.callLater(() => root._pump());
    }

    Component.onCompleted: {
        Qt.callLater(() => {
            if (!root._startupRestored) {
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
                console.warn("ThemePipeline: scheme regeneration failed (exit", exitCode, ")");
        }
    }

    QtObject {
        id: themeLoader
        property string themeId: ""
        property string wallpaperOverride: ""
        property bool running: false
        property string resolvedWallpaper: ""
        property var pendingConfig: ({})
    }

    FileView {
        id: themeFileView
        path: themeLoader.running ? `${root.themesDir}/${themeLoader.themeId}/theme.json` : ""

        onLoaded: {
            let rawText = "";
            try {
                rawText = text();
            } catch (e) {
                console.warn("ThemePipeline: failed to read theme.json for", themeLoader.themeId, e);
                themeLoader.running = false;
                root._finishJob(false, `failed to read theme.json for ${themeLoader.themeId}`);
                return;
            }
            themeLoader.running = false;

            let cfg = {};
            try {
                cfg = JSON.parse(rawText);
            } catch (e) {
                root._finishJob(false, `invalid theme.json for ${themeLoader.themeId}`);
                return;
            }

            themeLoader.pendingConfig = cfg;
            root._pendingSchemeType = cfg.schemeType || "tonal-spot";
            root._pendingDarkMode = cfg.darkMode !== undefined ? !!cfg.darkMode : true;
            root._pendingGtkTheme = cfg.gtkTheme || "";
            root._pendingIconTheme = cfg.iconTheme || "";
            root._pendingThemeName = cfg.name || themeLoader.themeId;

            const wp = themeLoader.wallpaperOverride;
            if (wp) {
                themeLoader.resolvedWallpaper = wp;
                root._pendingWallpaper = wp;
                root._startWalFromTheme();
            } else {
                resolveWallpaperProc.running = true;
            }
        }

        onLoadFailed: {
            themeLoader.running = false;
            root._finishJob(false, `theme.json not found for ${themeLoader.themeId}`);
        }
    }

    Process {
        id: resolveWallpaperProc
        command: ["sh", "-c", `
cfg_default="$DOTS_DEFAULT"
theme_dir="$DOTS_WALLPAPER_DIR"
for base in "$DOTS_PIC/$theme_dir" "$DOTS_DATA/$theme_dir"; do
  if [ -n "$cfg_default" ] && [ -f "$base/$cfg_default" ]; then
    readlink -f "$base/$cfg_default"
    exit 0
  fi
done
for base in "$DOTS_PIC/$theme_dir" "$DOTS_DATA/$theme_dir"; do
  [ -d "$base" ] || continue
  find -L "$base" -maxdepth 1 \\( -type f -o -type l \\) \\( \
    -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \
    -o -iname "*.gif" -o -iname "*.bmp" \
  \\) 2>/dev/null | sort | head -n 1
  break
done
`]
        environment: ({
            "DOTS_DEFAULT": themeLoader.pendingConfig.defaultWallpaper || "",
            "DOTS_WALLPAPER_DIR": themeLoader.pendingConfig.wallpaperDir || themeLoader.themeId,
            "DOTS_PIC": root.picturesWallpapers,
            "DOTS_DATA": root.wallpapersDir
        })

        stdout: StdioCollector {
            onStreamFinished: {
                const wp = text.trim();
                if (wp) {
                    themeLoader.resolvedWallpaper = wp;
                    root._startWalFromTheme();
                } else {
                    root._finishJob(false, `no wallpapers found for theme ${themeLoader.themeId}`);
                }
            }
        }
    }

    function _startWalFromTheme(): void {
        _pendingWallpaper = themeLoader.resolvedWallpaper;
        const cfg = themeLoader.pendingConfig || {};
        _pendingSchemeType = cfg.schemeType || "tonal-spot";
        _pendingDarkMode = cfg.darkMode !== undefined ? !!cfg.darkMode : true;
        walPrepProc.running = true;
    }

    Process {
        id: walPrepProc
        command: ["sh", "-c", 'mkdir -p "$HOME/.cache/wal" && rm -f "$HOME/.cache/wal/wal"']
        onExited: () => {
            walProc.running = true;
        }
    }

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

    Process {
        id: writeWallpaperPointer
        // ~/.cache/wal/wal must be a text path file, not a symlink to the image —
        // echoing into a symlink follows it and truncates the wallpaper asset.
        command: ["sh", "-c", 'mkdir -p "$(dirname "$DOTS_WALLPAPER_PTR")" "$HOME/.cache/wal" && printf "%s\\n" "$DOTS_WALLPAPER_PATH" > "$DOTS_WALLPAPER_PTR" && rm -f "$HOME/.cache/wal/wal" && printf "%s\\n" "$DOTS_WALLPAPER_PATH" > "$HOME/.cache/wal/wal"']
        environment: ({
            "DOTS_WALLPAPER_PTR": root.wallpaperPointer,
            "DOTS_WALLPAPER_PATH": root._pendingWallpaper
        })
    }

    Process {
        id: walReloadProc
        command: ["wal", "-R", "-q"]
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root._finishJob(false, `wal -R failed (exit ${exitCode})`);
                return;
            }
            // wal -R may recreate ~/.cache/wal/wal as an image symlink; rewrite
            // it as a text path file before anything echoes into that path.
            writeWallpaperPointer.running = true;
            m3Proc.running = true;
        }
    }

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

    Process {
        id: syncStateProc
        command: ["dots-color-scheme", "sync-state"]
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root._finishJob(false, `sync-state failed (exit ${exitCode})`);
                return;
            }
            touchSchemeProc.running = true;
            root._runSideEffects();
            // Finalize GTK via the canonical dots-gtk-theme CLI before completing.
            gtkFinalizeProc.themeName = root._runThemeSideEffects ? (root._pendingGtkTheme || "") : "";
            gtkFinalizeProc.iconTheme = root._runThemeSideEffects ? (root._pendingIconTheme || "") : "";
            gtkFinalizeProc.themeId = root._runThemeSideEffects ? (root._pendingThemeId || "") : "";
            gtkFinalizeProc.mode = root._pendingDarkMode ? "dark" : "light";
            gtkFinalizeProc.running = true;
        }
    }

    Process {
        id: touchSchemeProc
        command: ["touch", root.schemeJson]
    }

    // Apply GTK via dots-gtk-theme (canonical CLI) then complete the job.
    Process {
        id: gtkFinalizeProc
        property string themeName: ""
        property string iconTheme: ""
        property string themeId: ""
        property string mode: "dark"
        command: ["bash", "-c", `
set -euo pipefail
prefer=$([[ "\${DOTS_MODE}" == "light" ]] && echo false || echo true)
if [[ -n "\${DOTS_THEME_ID:-}" && ( -z "\${DOTS_GTK_THEME:-}" || "\${DOTS_GTK_THEME}" == "auto" ) ]]; then
  dots-gtk-theme -q theme "\${DOTS_THEME_ID}" || true
  dots-gtk-theme -q color-scheme "\${DOTS_MODE}" || true
elif [[ -n "\${DOTS_GTK_THEME:-}" && "\${DOTS_GTK_THEME}" != "auto" ]]; then
  if [[ -n "\${DOTS_ICON_THEME:-}" ]]; then
    dots-gtk-theme -q apply "\${DOTS_GTK_THEME}" "\${DOTS_ICON_THEME}" "\$prefer" || true
  else
    # Omit icon: dots-gtk-theme apply resolves the live icon theme.
    dots-gtk-theme -q apply "\${DOTS_GTK_THEME}" "" "\$prefer" || true
  fi
elif [[ -n "\${DOTS_ICON_THEME:-}" ]]; then
  dots-gtk-theme -q set-icons "\${DOTS_ICON_THEME}" || true
  dots-gtk-theme -q color-scheme "\${DOTS_MODE}" || true
else
  dots-gtk-theme -q color-scheme "\${DOTS_MODE}" || true
fi
`]
        environment: ({
            "DOTS_GTK_THEME": gtkFinalizeProc.themeName,
            "DOTS_ICON_THEME": gtkFinalizeProc.iconTheme,
            "DOTS_THEME_ID": gtkFinalizeProc.themeId,
            "DOTS_MODE": gtkFinalizeProc.mode
        })
        onExited: (exitCode, exitStatus) => {
            root._finishJob(true, "");
        }
    }

    // Queued GTK override through dots-gtk-theme.
    Process {
        id: gtkStandaloneProc
        property string themeName: ""
        property string mode: "dark"
        command: ["bash", "-c", `
set -euo pipefail
prefer=$([[ "\${DOTS_MODE}" == "light" ]] && echo false || echo true)
# Omit icon: dots-gtk-theme apply resolves the live icon theme.
dots-gtk-theme -q apply "\${DOTS_GTK_THEME}" "" "\$prefer"
`]
        environment: ({
            "DOTS_GTK_THEME": gtkStandaloneProc.themeName,
            "DOTS_MODE": gtkStandaloneProc.mode
        })
        onExited: (exitCode, exitStatus) => {
            root._finishJob(exitCode === 0, exitCode === 0 ? "" : `setGtk failed (exit ${exitCode})`);
        }
    }

    function _runSideEffects(): void {
        hyprlockProc.running = true;
        hyprReloadProc.running = true;

        if (root._runThemeSideEffects && root._pendingThemeId) {
            snappyProc.themeId = root._pendingThemeId;
            snappyProc.running = true;
        }

        if (root._runThemeSideEffects && root._pendingThemeName) {
            notifyProc.themeName = root._pendingThemeName;
            notifyProc.running = true;
        }
    }

    Process {
        id: hyprReloadProc
        command: ["hyprctl", "reload"]
    }

    Process {
        id: snappyProc
        property string themeId: ""
        command: ["dots-snappy-switcher", "apply-theme-pack", snappyProc.themeId]
    }

    Process {
        id: iconOnlyProc
        property string themeName: ""
        command: ["dots-gtk-theme", "-q", "set-icons", iconOnlyProc.themeName]
        onExited: (exitCode, exitStatus) => {
            root._finishJob(exitCode === 0, exitCode === 0 ? "" : `setIcons failed (exit ${exitCode})`);
        }
    }

    Process {
        id: hyprlockProc
        command: ["dots-hyprlock-theme"]
    }

    Process {
        id: notifyProc
        property string themeName: ""
        command: ["notify-send", "HorneroConfig", `${notifyProc.themeName} theme applied`]
    }

    Process {
        id: notifyFailProc
        property string message: ""
        command: ["notify-send", "-u", "critical", "HorneroConfig", notifyFailProc.message || "Appearance apply failed"]
    }

    IpcHandler {
        target: "appearance"

        function applyTheme(id: string, wallpaper: string): void {
            root.applyTheme(id, wallpaper || "");
        }

        function reload(): void {
            root.reload();
        }

        function setWallpaper(path: string): void {
            root.setWallpaper(path);
        }

        function setGtk(theme: string): void {
            root.setGtk(theme);
        }

        function setIcons(theme: string): void {
            root.setIcons(theme);
        }

        function isBusy(): string {
            return root._busy ? "1" : "0";
        }

        function lastError(): string {
            return root._lastError;
        }

        function status(): string {
            return Wallpapers.actualCurrent || "";
        }
    }
}
