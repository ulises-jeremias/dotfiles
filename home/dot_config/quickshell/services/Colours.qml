pragma Singleton
pragma ComponentBehavior: Bound

import qs.config
import qs.utils
import Hornero
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool showPreview
    property string scheme
    property string flavour
    // Canonical first-class themes (P2 appearance tokens): hornero-dark /
    // hornero-light are fully described by the built-in semantic tables
    // below, so the shell is coherent before any external scheme.json
    // arrives and switches mode without light/dark leakage.
    property string themeId: "hornero-dark"

    function isBuiltInTheme(id: string): bool {
        return id === "hornero-dark" || id === "hornero-light";
    }

    function applyBuiltInTheme(id: string): void {
        if (!isBuiltInTheme(id))
            return;
        const table = id === "hornero-light" ? _horneroLight : _horneroDark;
        for (const [name, colour] of Object.entries(table)) {
            const propName = name.startsWith("term") ? name : `m3${name}`;
            if (current.hasOwnProperty(propName))
                current[propName] = colour;
        }
        themeId = id;
        scheme = id;
        flavour = "tonal-spot";
        currentLight = id === "hornero-light";
        // A live built-in supersedes any wallpaper-preview palette.
        showPreview = false;
    }
    readonly property bool light: showPreview ? previewLight : currentLight
    property bool currentLight
    property bool previewLight
    readonly property M3Palette palette: showPreview ? preview : current
    readonly property M3TPalette tPalette: M3TPalette {}
    readonly property M3Palette current: M3Palette {}
    readonly property M3Palette preview: M3Palette {}
    readonly property Transparency transparency: Transparency {}
    // Canonical semantic token tables. Keys mirror scheme.json colour names
    // (the `m3` / `term` prefix mapping matches load()). Both tables are
    // GENERATED from the HorneroOS/config brand seed #E07856 (config
    // hornero-dark theme.json primary) -- via scripts/gen-flagship-m3.py
    // (M3 tonal-spot, one source for both modes). Same hue family as the
    // config palettes by construction; role-appropriate lightness follows
    // M3 spec (e.g. a dark-mode primary is tone 80). Do not hand-edit:
    // re-run the generator. scrim/shadow/success*/term* are hand-owned
    // extras outside the M3 roles. _horneroDark is byte-identical to the
    // M3Palette defaults below; fixed colours are mode-independent per M3
    // and shared by both tables.
    readonly property var _horneroDark: ({
        "primary_paletteKeyColor": "#a06a58",
        "secondary_paletteKeyColor": "#926f64",
        "tertiary_paletteKeyColor": "#8f733b",
        "neutral_paletteKeyColor": "#807471",
        "neutral_variant_paletteKeyColor": "#86736d",
        "background": "#130d0b",
        "onBackground": "#f9e0d9",
        "surface": "#130d0b",
        "surfaceDim": "#130d0b",
        "surfaceBright": "#372924",
        "surfaceContainerLowest": "#000000",
        "surfaceContainerLow": "#1a110f",
        "surfaceContainer": "#221714",
        "surfaceContainerHigh": "#291d19",
        "surfaceContainerHighest": "#30231e",
        "onSurface": "#f9e0d9",
        "surfaceVariant": "#30231e",
        "onSurfaceVariant": "#bca6a0",
        "inverseSurface": "#fff8f6",
        "inverseOnSurface": "#5d5350",
        "outline": "#84716c",
        "outlineVariant": "#55443f",
        "shadow": "#000000",
        "scrim": "#000000",
        "surfaceTint": "#f9b7a3",
        "primary": "#f9b7a3",
        "onPrimary": "#613426",
        "primaryContainer": "#764637",
        "onPrimaryContainer": "#ffdcd1",
        "inversePrimary": "#855242",
        "secondary": "#e7bdb1",
        "onSecondary": "#563930",
        "secondaryContainer": "#50352c",
        "onSecondaryContainer": "#dfb6aa",
        "tertiary": "#ffebcc",
        "onTertiary": "#6e551f",
        "tertiaryContainer": "#ffdb98",
        "onTertiaryContainer": "#644c18",
        "error": "#fa746f",
        "onError": "#490006",
        "errorContainer": "#871f21",
        "onErrorContainer": "#ff9993",
        "success": "#B5CCBA",
        "onSuccess": "#213528",
        "successContainer": "#374B3E",
        "onSuccessContainer": "#D1E9D6",
        "primaryFixed": "#f9b7a3",
        "primaryFixedDim": "#eaaa96",
        "onPrimaryFixed": "#482114",
        "onPrimaryFixedVariant": "#6b3d2e",
        "secondaryFixed": "#ffdbd0",
        "secondaryFixedDim": "#f6cbbe",
        "onSecondaryFixed": "#553830",
        "onSecondaryFixedVariant": "#74544a",
        "tertiaryFixed": "#ffdb98",
        "tertiaryFixedDim": "#f0cd8c",
        "onTertiaryFixed": "#503a05",
        "onTertiaryFixedVariant": "#6f5620",
        "term0": "#353434",
        "term1": "#ff4c8a",
        "term2": "#ffbbb7",
        "term3": "#ffdedf",
        "term4": "#b3a2d5",
        "term5": "#e98fb0",
        "term6": "#ffba93",
        "term7": "#eed1d2",
        "term8": "#b39e9e",
        "term9": "#ff80a3",
        "term10": "#ffd3d0",
        "term11": "#fff1f0",
        "term12": "#dcbc93",
        "term13": "#f9a8c2",
        "term14": "#ffd1c0",
        "term15": "#ffffff"
    })
    readonly property var _horneroLight: ({
        "primary_paletteKeyColor": "#a86651",
        "secondary_paletteKeyColor": "#926f64",
        "tertiary_paletteKeyColor": "#8f733b",
        "neutral_paletteKeyColor": "#807471",
        "neutral_variant_paletteKeyColor": "#86736d",
        "background": "#fff8f6",
        "onBackground": "#3e2f2b",
        "surface": "#fff8f6",
        "surfaceDim": "#edd5ce",
        "surfaceBright": "#fff8f6",
        "surfaceContainerLowest": "#ffffff",
        "surfaceContainerLow": "#fff1ed",
        "surfaceContainer": "#fee9e4",
        "surfaceContainerHigh": "#fae4dd",
        "surfaceContainerHighest": "#f6ddd6",
        "onSurface": "#3e2f2b",
        "surfaceVariant": "#f6ddd6",
        "onSurfaceVariant": "#6d5b56",
        "inverseSurface": "#130d0b",
        "inverseOnSurface": "#a79a96",
        "outline": "#8a7671",
        "outlineVariant": "#c3ada7",
        "shadow": "#000000",
        "scrim": "#000000",
        "surfaceTint": "#8c4f3b",
        "primary": "#8c4f3b",
        "onPrimary": "#fff7f5",
        "primaryContainer": "#fdae95",
        "onPrimaryContainer": "#622d1c",
        "inversePrimary": "#fdae95",
        "secondary": "#78584e",
        "onSecondary": "#fff7f5",
        "secondaryContainer": "#ffdbd0",
        "onSecondaryContainer": "#694a41",
        "tertiary": "#755b25",
        "onTertiary": "#fff8f1",
        "tertiaryContainer": "#ffdb98",
        "onTertiaryContainer": "#644c18",
        "error": "#a83836",
        "onError": "#fff7f6",
        "errorContainer": "#fa746f",
        "onErrorContainer": "#6e0a12",
        "success": "#406836",
        "onSuccess": "#ffffff",
        "successContainer": "#c2f0b9",
        "onSuccessContainer": "#072100",
        "primaryFixed": "#f9b7a3",
        "primaryFixedDim": "#eaaa96",
        "onPrimaryFixed": "#482114",
        "onPrimaryFixedVariant": "#6b3d2e",
        "secondaryFixed": "#ffdbd0",
        "secondaryFixedDim": "#f6cbbe",
        "onSecondaryFixed": "#553830",
        "onSecondaryFixedVariant": "#74544a",
        "tertiaryFixed": "#ffdb98",
        "tertiaryFixedDim": "#f0cd8c",
        "onTertiaryFixed": "#503a05",
        "onTertiaryFixedVariant": "#6f5620",
        "term0": "#3f3b3d",
        "term1": "#b3261e",
        "term2": "#2e7d32",
        "term3": "#8a5a00",
        "term4": "#2f6fed",
        "term5": "#7b1fa2",
        "term6": "#0d7d8c",
        "term7": "#f5f0f0",
        "term8": "#7a6f72",
        "term9": "#e4695e",
        "term10": "#4caf50",
        "term11": "#c99700",
        "term12": "#669df6",
        "term13": "#ba68c8",
        "term14": "#4dd0e1",
        "term15": "#ffffff"
    })
    // Native wallpaper analysis (issue #2, step (b)): luminance and dominant
    // colour come straight from the ImageAnalyser plugin — no CLI involved.
    readonly property alias wallLuminance: analyser.luminance
    readonly property alias wallDominantColour: analyser.dominantColour

    function getLuminance(c: color): real {
        if (c.r == 0 && c.g == 0 && c.b == 0)
            return 0;
        return Math.sqrt(0.299 * (c.r ** 2) + 0.587 * (c.g ** 2) + 0.114 * (c.b ** 2));
    }

    function alterColour(c: color, a: real, layer: int): color {
        const luminance = getLuminance(c);

        const offset = (!light || layer == 1 ? 1 : -layer / 2) * (light ? 0.2 : 0.3) * (1 - transparency.base) * (1 + wallLuminance * (light ? (layer == 1 ? 3 : 1) : 2.5));
        const scale = (luminance + offset) / luminance;
        const r = Math.max(0, Math.min(1, c.r * scale));
        const g = Math.max(0, Math.min(1, c.g * scale));
        const b = Math.max(0, Math.min(1, c.b * scale));

        return Qt.rgba(r, g, b, a);
    }

    function layer(c: color, layer: var): color {
        if (!transparency.enabled)
            return c;

        return layer === 0 ? Qt.alpha(c, transparency.base) : alterColour(c, transparency.layers, layer ?? 1);
    }

    function on(c: color): color {
        if (c.hslLightness < 0.5)
            return Qt.hsla(c.hslHue, c.hslSaturation, 0.9, 1);
        return Qt.hsla(c.hslHue, c.hslSaturation, 0.1, 1);
    }

    function load(data: string, isPreview: bool): void {
        const colours = isPreview ? preview : current;
        const scheme = JSON.parse(data);

        if (!isPreview) {
            root.scheme = scheme.name;
            flavour = scheme.flavour;
            currentLight = scheme.mode === "light";
            if (root.isBuiltInTheme(scheme.name))
                themeId = scheme.name;
            // Live scheme from disk supersedes any wallpaper-preview palette.
            showPreview = false;
        } else {
            previewLight = scheme.mode === "light";
        }

        for (const [name, colour] of Object.entries(scheme.colours)) {
            const propName = name.startsWith("term") ? name : `m3${name}`;
            if (colours.hasOwnProperty(propName))
                colours[propName] = `#${colour}`;
        }
    }

    // TODO(hornero-compat): dots-color-scheme is an external runtime CLI;
    // see docs/COMPAT.md (disposition A).
    function setMode(mode: string): void {
        Quickshell.execDetached(["dots-color-scheme", "mode", mode]);
    }

    function reloadFromDisk(): void {
        root._schemeFallbackActive = false;
        schemeFileView.reload();
    }

    // Runtime path contract row 4: canonical hornero/* scheme.json first,
    // legacy dots/* fallback (reads only). The fallback applies only after
    // the canonical read fails, so a migrated install never regresses.
    property bool _schemeFallbackActive: false

    FileView {
        id: schemeFileView

        path: `${Paths.cache}/smart-colors/scheme.json`
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            root._schemeFallbackActive = false;
            root.load(text(), false);
        }
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound && !root._schemeFallbackActive) {
                root._schemeFallbackActive = true;
                schemeFileViewFallback.reload();
            }
        }
    }

    FileView {
        id: schemeFileViewFallback

        path: `${Paths.cacheFallback}/smart-colors/scheme.json`
        onLoaded: {
            if (root._schemeFallbackActive)
                root.load(text(), false);
        }
        onLoadFailed: {
            root._schemeFallbackActive = false;
        }
    }

    IpcHandler {
        target: "colours"

        function reload(): void {
            root.reloadFromDisk();
        }

        function mode(): string {
            return root.currentLight ? "light" : "dark";
        }

        function flavour(): string {
            return root.flavour;
        }
    }

    ImageAnalyser {
        id: analyser

        source: Wallpapers.current
    }

    component Transparency: QtObject {
        readonly property bool enabled: Appearance.transparency.enabled
        readonly property real base: Appearance.transparency.base - (root.light ? 0.1 : 0)
        readonly property real layers: Appearance.transparency.layers
    }

    component M3TPalette: QtObject {
        readonly property color m3primary_paletteKeyColor: root.layer(root.palette.m3primary_paletteKeyColor)
        readonly property color m3secondary_paletteKeyColor: root.layer(root.palette.m3secondary_paletteKeyColor)
        readonly property color m3tertiary_paletteKeyColor: root.layer(root.palette.m3tertiary_paletteKeyColor)
        readonly property color m3neutral_paletteKeyColor: root.layer(root.palette.m3neutral_paletteKeyColor)
        readonly property color m3neutral_variant_paletteKeyColor: root.layer(root.palette.m3neutral_variant_paletteKeyColor)
        readonly property color m3background: root.layer(root.palette.m3background, 0)
        readonly property color m3onBackground: root.layer(root.palette.m3onBackground)
        readonly property color m3surface: root.layer(root.palette.m3surface, 0)
        readonly property color m3surfaceDim: root.layer(root.palette.m3surfaceDim, 0)
        readonly property color m3surfaceBright: root.layer(root.palette.m3surfaceBright, 0)
        readonly property color m3surfaceContainerLowest: root.layer(root.palette.m3surfaceContainerLowest)
        readonly property color m3surfaceContainerLow: root.layer(root.palette.m3surfaceContainerLow)
        readonly property color m3surfaceContainer: root.layer(root.palette.m3surfaceContainer)
        readonly property color m3surfaceContainerHigh: root.layer(root.palette.m3surfaceContainerHigh)
        readonly property color m3surfaceContainerHighest: root.layer(root.palette.m3surfaceContainerHighest)
        readonly property color m3onSurface: root.layer(root.palette.m3onSurface)
        readonly property color m3surfaceVariant: root.layer(root.palette.m3surfaceVariant, 0)
        readonly property color m3onSurfaceVariant: root.layer(root.palette.m3onSurfaceVariant)
        readonly property color m3inverseSurface: root.layer(root.palette.m3inverseSurface, 0)
        readonly property color m3inverseOnSurface: root.layer(root.palette.m3inverseOnSurface)
        readonly property color m3outline: root.layer(root.palette.m3outline)
        readonly property color m3outlineVariant: root.layer(root.palette.m3outlineVariant)
        readonly property color m3shadow: root.layer(root.palette.m3shadow)
        readonly property color m3scrim: root.layer(root.palette.m3scrim)
        readonly property color m3surfaceTint: root.layer(root.palette.m3surfaceTint)
        readonly property color m3primary: root.layer(root.palette.m3primary)
        readonly property color m3onPrimary: root.layer(root.palette.m3onPrimary)
        readonly property color m3primaryContainer: root.layer(root.palette.m3primaryContainer)
        readonly property color m3onPrimaryContainer: root.layer(root.palette.m3onPrimaryContainer)
        readonly property color m3inversePrimary: root.layer(root.palette.m3inversePrimary)
        readonly property color m3secondary: root.layer(root.palette.m3secondary)
        readonly property color m3onSecondary: root.layer(root.palette.m3onSecondary)
        readonly property color m3secondaryContainer: root.layer(root.palette.m3secondaryContainer)
        readonly property color m3onSecondaryContainer: root.layer(root.palette.m3onSecondaryContainer)
        readonly property color m3tertiary: root.layer(root.palette.m3tertiary)
        readonly property color m3onTertiary: root.layer(root.palette.m3onTertiary)
        readonly property color m3tertiaryContainer: root.layer(root.palette.m3tertiaryContainer)
        readonly property color m3onTertiaryContainer: root.layer(root.palette.m3onTertiaryContainer)
        readonly property color m3error: root.layer(root.palette.m3error)
        readonly property color m3onError: root.layer(root.palette.m3onError)
        readonly property color m3errorContainer: root.layer(root.palette.m3errorContainer)
        readonly property color m3onErrorContainer: root.layer(root.palette.m3onErrorContainer)
        readonly property color m3success: root.layer(root.palette.m3success)
        readonly property color m3onSuccess: root.layer(root.palette.m3onSuccess)
        readonly property color m3successContainer: root.layer(root.palette.m3successContainer)
        readonly property color m3onSuccessContainer: root.layer(root.palette.m3onSuccessContainer)
        readonly property color m3primaryFixed: root.layer(root.palette.m3primaryFixed)
        readonly property color m3primaryFixedDim: root.layer(root.palette.m3primaryFixedDim)
        readonly property color m3onPrimaryFixed: root.layer(root.palette.m3onPrimaryFixed)
        readonly property color m3onPrimaryFixedVariant: root.layer(root.palette.m3onPrimaryFixedVariant)
        readonly property color m3secondaryFixed: root.layer(root.palette.m3secondaryFixed)
        readonly property color m3secondaryFixedDim: root.layer(root.palette.m3secondaryFixedDim)
        readonly property color m3onSecondaryFixed: root.layer(root.palette.m3onSecondaryFixed)
        readonly property color m3onSecondaryFixedVariant: root.layer(root.palette.m3onSecondaryFixedVariant)
        readonly property color m3tertiaryFixed: root.layer(root.palette.m3tertiaryFixed)
        readonly property color m3tertiaryFixedDim: root.layer(root.palette.m3tertiaryFixedDim)
        readonly property color m3onTertiaryFixed: root.layer(root.palette.m3onTertiaryFixed)
        readonly property color m3onTertiaryFixedVariant: root.layer(root.palette.m3onTertiaryFixedVariant)
    }

    component M3Palette: QtObject {
        property color m3primary_paletteKeyColor: "#a06a58"
        property color m3secondary_paletteKeyColor: "#926f64"
        property color m3tertiary_paletteKeyColor: "#8f733b"
        property color m3neutral_paletteKeyColor: "#807471"
        property color m3neutral_variant_paletteKeyColor: "#86736d"
        property color m3background: "#130d0b"
        property color m3onBackground: "#f9e0d9"
        property color m3surface: "#130d0b"
        property color m3surfaceDim: "#130d0b"
        property color m3surfaceBright: "#372924"
        property color m3surfaceContainerLowest: "#000000"
        property color m3surfaceContainerLow: "#1a110f"
        property color m3surfaceContainer: "#221714"
        property color m3surfaceContainerHigh: "#291d19"
        property color m3surfaceContainerHighest: "#30231e"
        property color m3onSurface: "#f9e0d9"
        property color m3surfaceVariant: "#30231e"
        property color m3onSurfaceVariant: "#bca6a0"
        property color m3inverseSurface: "#fff8f6"
        property color m3inverseOnSurface: "#5d5350"
        property color m3outline: "#84716c"
        property color m3outlineVariant: "#55443f"
        property color m3shadow: "#000000"
        property color m3scrim: "#000000"
        property color m3surfaceTint: "#f9b7a3"
        property color m3primary: "#f9b7a3"
        property color m3onPrimary: "#613426"
        property color m3primaryContainer: "#764637"
        property color m3onPrimaryContainer: "#ffdcd1"
        property color m3inversePrimary: "#855242"
        property color m3secondary: "#e7bdb1"
        property color m3onSecondary: "#563930"
        property color m3secondaryContainer: "#50352c"
        property color m3onSecondaryContainer: "#dfb6aa"
        property color m3tertiary: "#ffebcc"
        property color m3onTertiary: "#6e551f"
        property color m3tertiaryContainer: "#ffdb98"
        property color m3onTertiaryContainer: "#644c18"
        property color m3error: "#fa746f"
        property color m3onError: "#490006"
        property color m3errorContainer: "#871f21"
        property color m3onErrorContainer: "#ff9993"
        property color m3success: "#B5CCBA"
        property color m3onSuccess: "#213528"
        property color m3successContainer: "#374B3E"
        property color m3onSuccessContainer: "#D1E9D6"
        property color m3primaryFixed: "#f9b7a3"
        property color m3primaryFixedDim: "#eaaa96"
        property color m3onPrimaryFixed: "#482114"
        property color m3onPrimaryFixedVariant: "#6b3d2e"
        property color m3secondaryFixed: "#ffdbd0"
        property color m3secondaryFixedDim: "#f6cbbe"
        property color m3onSecondaryFixed: "#553830"
        property color m3onSecondaryFixedVariant: "#74544a"
        property color m3tertiaryFixed: "#ffdb98"
        property color m3tertiaryFixedDim: "#f0cd8c"
        property color m3onTertiaryFixed: "#503a05"
        property color m3onTertiaryFixedVariant: "#6f5620"
        property color term0: "#353434"
        property color term1: "#ff4c8a"
        property color term2: "#ffbbb7"
        property color term3: "#ffdedf"
        property color term4: "#b3a2d5"
        property color term5: "#e98fb0"
        property color term6: "#ffba93"
        property color term7: "#eed1d2"
        property color term8: "#b39e9e"
        property color term9: "#ff80a3"
        property color term10: "#ffd3d0"
        property color term11: "#fff1f0"
        property color term12: "#dcbc93"
        property color term13: "#f9a8c2"
        property color term14: "#ffd1c0"
        property color term15: "#ffffff"
    }
}
