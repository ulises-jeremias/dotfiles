pragma Singleton

import qs.services
import qs.utils
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Runtime path contract rows 1/11: canonical hornero/* first, legacy
    // dots/* fallback (reads only). Writes (schemeJson output, wallpaper
    // pointer) always target the canonical location.
    readonly property string themesDir: `${Paths.data}/themes`
    readonly property string themesDirFallback: `${Paths.dataFallback}/themes`
    readonly property string wallpapersDir: `${Paths.data}/wallpapers`
    readonly property string wallpapersDirFallback: `${Paths.dataFallback}/wallpapers`
    readonly property string picturesWallpapers: `${Paths.pictures}/Wallpapers`
    readonly property string wallpaperPointer: Paths.wallpaperPointer
    // Prefer dots-m3-colors so pyenv shims do not hide Arch python-materialyoucolor.
    // GTK application is native-first via GtkSettings (gsettings); the
    // dots-gtk-theme compat fallback lives there. Remaining dots-* calls
    // below are thin compat adapters for tooling this repo does not own yet.
    // TODO(hornero-compat): dots-m3-colors / dots-color-scheme remain
    // external runtime CLIs; see docs/COMPAT.md (disposition A) and
    // docs/NATIVE-APPEARANCE.md.
    readonly property string m3Bin: `${Quickshell.env("HOME")}/.local/bin/dots-m3-colors`
    // Contract row 4: canonical scheme.json (written by m3Proc below).
    readonly property string schemeJson: `${Paths.cache}/smart-colors/scheme.json`
    readonly property string schemeJsonFallback: `${Paths.cacheFallback}/smart-colors/scheme.json`

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
    // "true" | "false" | "" (infer from gtk theme name / shell mode)
    property string _pendingGtkPreferDark: ""
    // follow | default | prefer-light | prefer-dark | "" (wallpaper jobs sync live policy)
    property string _pendingGtkColorScheme: ""
    property bool _runThemeSideEffects: false
    property string _lastError: ""
    readonly property string lastError: _lastError
    property bool _startupRestored: false
    // True while a GTK apply is delegated to the native GtkSettings layer.
    property bool _awaitingGtk: false

    signal applyFinished(bool ok)

    function resolveGtkPreferDark(cfg: var, darkMode: bool): string {
        const scheme = root.resolveGtkColorScheme(cfg, darkMode);
        return scheme === "prefer-light" || scheme === "default" ? "false" : "true";
    }

    function resolveGtkPreferFromName(gtkTheme: string, darkMode: bool): string {
        const gtk = (gtkTheme || "").toLowerCase();
        if (gtk.indexOf("light") >= 0)
            return "false";
        if (gtk.indexOf("dark") >= 0)
            return "true";
        return darkMode ? "true" : "false";
    }

    function normalizeGtkColorScheme(value: string): string {
        const raw = (value ?? "").toLowerCase().replace(/_/g, "-");
        switch (raw) {
        case "follow":
        case "follow-mode":
        case "follow-theme":
        case "follow-theme-mode":
            return "follow";
        case "default":
        case "auto":
        case "apps":
        case "apps-decide":
            return "default";
        case "prefer-light":
        case "light":
        case "false":
        case "0":
        case "no":
            return "prefer-light";
        case "prefer-dark":
        case "dark":
        case "true":
        case "1":
        case "yes":
            return "prefer-dark";
        default:
            return "";
        }
    }

    function resolveGtkColorScheme(cfg: var, darkMode: bool): string {
        const fromField = root.normalizeGtkColorScheme((cfg && cfg.gtkColorScheme) ? String(cfg.gtkColorScheme) : "");
        if (fromField)
            return fromField;
        if (cfg && cfg.gtkPreferDark !== undefined && cfg.gtkPreferDark !== null && cfg.gtkPreferDark !== "")
            return cfg.gtkPreferDark ? "prefer-dark" : "prefer-light";
        const gtk = ((cfg && cfg.gtkTheme) ? cfg.gtkTheme : "").toLowerCase();
        if (gtk.indexOf("light") >= 0)
            return "prefer-light";
        if (gtk.indexOf("dark") >= 0)
            return "prefer-dark";
        return darkMode ? "prefer-dark" : "prefer-light";
    }

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

    function setGtkColorScheme(policy: string): void {
        const normalized = root.normalizeGtkColorScheme(policy);
        if (!normalized)
            return;
        _enqueue({
            kind: "gtk-color-scheme",
            gtkColorScheme: normalized
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
        if (tail && tail.kind === job.kind && tail.themeId === job.themeId && tail.wallpaper === job.wallpaper && tail.gtkTheme === job.gtkTheme && tail.iconTheme === job.iconTheme && tail.gtkColorScheme === job.gtkColorScheme)
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
        _pendingGtkPreferDark = "";
        _pendingGtkColorScheme = "";

        if (job.kind === "theme") {
            _runThemeSideEffects = true;
            _pendingThemeId = job.themeId || "";
            if (Colours.isBuiltInTheme(job.themeId || "")) {
                root._applyBuiltInTheme(job.themeId, job.wallpaper || "");
                return;
            }
            themeLoader.themeId = job.themeId;
            themeLoader.wallpaperOverride = job.wallpaper || "";
            themeLoader.fallbackRunning = false;
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
            _awaitingGtk = true;
            GtkSettings.applyGtkTheme(job.gtkTheme || "");
        } else if (job.kind === "gtk-color-scheme") {
            _awaitingGtk = true;
            GtkSettings.applyColorScheme(job.gtkColorScheme || "follow", !Colours.currentLight);
        } else if (job.kind === "icons") {
            _awaitingGtk = true;
            GtkSettings.applyIconTheme(job.iconTheme || "");
        } else {
            _finishJob(false, "unknown job kind");
        }
    }

    // First-class built-in themes (hornero-dark / hornero-light): the full
    // semantic palette lives in Colours, so apply needs no wallpaper, wal,
    // or dots-m3-colors round-trip — correct switching with no light/dark
    // leakage. GTK follows natively (empty themeId keeps GtkSettings off
    // the dots-owned registry path); only the color-scheme policy applies.
    // dots-owned extras (snappy switcher packs) are skipped for built-ins.
    function _applyBuiltInTheme(id: string, wallpaper: string): void {
        const darkMode = id !== "hornero-light";
        Colours.applyBuiltInTheme(id);
        _pendingThemeName = darkMode ? "Hornero Dark" : "Hornero Light";
        _pendingSchemeType = "tonal-spot";
        _pendingDarkMode = darkMode;
        _pendingGtkTheme = "";
        _pendingIconTheme = "";
        _pendingGtkPreferDark = darkMode ? "true" : "false";
        _pendingGtkColorScheme = darkMode ? "prefer-dark" : "prefer-light";
        if (wallpaper) {
            _pendingWallpaper = wallpaper;
            writeWallpaperPointer.running = true;
        }
        hyprlockProc.running = true;
        hyprReloadProc.running = true;
        if (_pendingThemeName) {
            notifyProc.themeName = _pendingThemeName;
            notifyProc.running = true;
        }
        _awaitingGtk = true;
        GtkSettings.applyFull("", "", "", _pendingGtkColorScheme, _pendingDarkMode);
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

    // TODO(hornero-compat): dots-color-scheme owns scheme persistence; no
    // native equivalent yet. Thin compat adapter; see docs/NATIVE-APPEARANCE.md.
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
        property bool fallbackRunning: false
        property string resolvedWallpaper: ""
        property var pendingConfig: ({})
    }

    // Shared theme.json handling for the canonical and fallback FileViews.
    function _handleThemeText(rawText: string): void {
        themeLoader.running = false;
        themeLoader.fallbackRunning = false;

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
        root._pendingGtkPreferDark = root.resolveGtkPreferDark(cfg, root._pendingDarkMode);
        root._pendingGtkColorScheme = root.resolveGtkColorScheme(cfg, root._pendingDarkMode);

        const wp = themeLoader.wallpaperOverride;
        if (wp) {
            themeLoader.resolvedWallpaper = wp;
            root._pendingWallpaper = wp;
            root._startWalFromTheme();
        } else {
            resolveWallpaperProc.running = true;
        }
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
            root._handleThemeText(rawText);
        }

        onLoadFailed: err => {
            themeLoader.running = false;
            if (err === FileViewError.FileNotFound && !themeLoader.fallbackRunning) {
                themeLoader.fallbackRunning = true;
            } else {
                root._finishJob(false, `theme.json not found for ${themeLoader.themeId}`);
            }
        }
    }

    // Legacy dots/* theme packs (contract row 1, fallback read only).
    FileView {
        id: themeFileViewFallback
        path: themeLoader.fallbackRunning ? `${root.themesDirFallback}/${themeLoader.themeId}/theme.json` : ""

        onLoaded: {
            let rawText = "";
            try {
                rawText = text();
            } catch (e) {
                console.warn("ThemePipeline: failed to read fallback theme.json for", themeLoader.themeId, e);
                themeLoader.fallbackRunning = false;
                root._finishJob(false, `failed to read theme.json for ${themeLoader.themeId}`);
                return;
            }
            root._handleThemeText(rawText);
        }

        onLoadFailed: {
            themeLoader.fallbackRunning = false;
            root._finishJob(false, `theme.json not found for ${themeLoader.themeId}`);
        }
    }

    Process {
        id: resolveWallpaperProc
        command: ["sh", "-c", `
cfg_default="$DOTS_DEFAULT"
theme_dir="$DOTS_WALLPAPER_DIR"
// Contract row 11: canonical hornero/* wallpapers first, legacy dots/* fallback.
for base in "$DOTS_PIC/$theme_dir" "$DOTS_DATA/$theme_dir" "$DOTS_DATA_FALLBACK/$theme_dir"; do
  if [ -n "$cfg_default" ] && [ -f "$base/$cfg_default" ]; then
    readlink -f "$base/$cfg_default"
    exit 0
  fi
done
for base in "$DOTS_PIC/$theme_dir" "$DOTS_DATA/$theme_dir" "$DOTS_DATA_FALLBACK/$theme_dir"; do
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
            "DOTS_DATA": root.wallpapersDir,
            "DOTS_DATA_FALLBACK": root.wallpapersDirFallback
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
        _pendingGtkPreferDark = root.resolveGtkPreferDark(cfg, _pendingDarkMode);
        _pendingGtkColorScheme = root.resolveGtkColorScheme(cfg, _pendingDarkMode);
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

    // TODO(hornero-compat): full M3 palette generation needs materialyoucolor
    // via dots-m3-colors; the native ImageAnalyser layer (WallpaperAnalysis,
    // Colours.wallLuminance/wallDominantColour) covers instant tone analysis.
    Process {
        id: m3Proc
        readonly property string image: root._pendingWallpaper || Wallpapers.actualCurrent
        readonly property string mode: root._pendingDarkMode ? "dark" : "light"
        readonly property string schemeType: root._pendingSchemeType || "tonal-spot"
        command: [
            root.m3Bin,
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

    // TODO(hornero-compat): dots-color-scheme owns scheme persistence; no
    // native equivalent yet. Thin compat adapter; see docs/NATIVE-APPEARANCE.md.
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
            // Finalize GTK through the native GtkSettings layer (gsettings
            // first, dots-gtk-theme compat fallback inside). Completes via
            // the GtkSettings connection below.
            root._awaitingGtk = true;
            GtkSettings.applyFull(root._runThemeSideEffects ? (root._pendingGtkTheme || "") : "", root._runThemeSideEffects ? (root._pendingIconTheme || "") : "", root._runThemeSideEffects ? (root._pendingThemeId || "") : "", root._runThemeSideEffects ? (root._pendingGtkColorScheme || "") : "", root._pendingDarkMode);
        }
    }

    Process {
        id: touchSchemeProc
        command: ["touch", root.schemeJson]
    }

    // GTK applies run through the native GtkSettings layer (gsettings first,
    // dots-gtk-theme compat fallback inside) and complete via its signal.
    Connections {
        target: GtkSettings

        function onApplyFinished(ok: bool, error: string): void {
            if (!root._awaitingGtk)
                return;
            root._awaitingGtk = false;
            root._finishJob(ok, error);
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

    // TODO(hornero-compat): dots-snappy-switcher is a dots-owned side effect
    // with no native equivalent yet; see docs/NATIVE-APPEARANCE.md.
    Process {
        id: snappyProc
        property string themeId: ""
        command: ["dots-snappy-switcher", "apply-theme-pack", snappyProc.themeId]
    }

    // TODO(hornero-compat): dots-hyprlock-theme is a dots-owned side effect
    // with no native equivalent yet; see docs/NATIVE-APPEARANCE.md.
    Process {
        id: hyprlockProc
        command: ["dots-hyprlock-theme"]
    }

    Process {
        id: notifyProc
        property string themeName: ""
        command: ["notify-send", "Hornero Shell", `${notifyProc.themeName} theme applied`]
    }

    Process {
        id: notifyFailProc
        property string message: ""
        command: ["notify-send", "-u", "critical", "Hornero Shell", notifyFailProc.message || "Appearance apply failed"]
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

        function setGtkColorScheme(policy: string): void {
            root.setGtkColorScheme(policy);
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
