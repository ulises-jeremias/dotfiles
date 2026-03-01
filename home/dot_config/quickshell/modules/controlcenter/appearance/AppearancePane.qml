pragma ComponentBehavior: Bound

import ".."
import "../components"
import "./sections"
import "../../launcher/services"
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.components.images
import qs.services
import qs.config
import qs.utils
import Caelestia.Models
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Session session

    property real animDurationsScale: Config.appearance.anim.durations.scale ?? 1
    property string fontFamilyMaterial: Config.appearance.font.family.material ?? "Material Symbols Rounded"
    property string fontFamilyMono: Config.appearance.font.family.mono ?? "CaskaydiaCove NF"
    property string fontFamilySans: Config.appearance.font.family.sans ?? "Rubik"
    property real fontSizeScale: Config.appearance.font.size.scale ?? 1
    property real paddingScale: Config.appearance.padding.scale ?? 1
    property real roundingScale: Config.appearance.rounding.scale ?? 1
    property real spacingScale: Config.appearance.spacing.scale ?? 1
    property bool transparencyEnabled: Config.appearance.transparency.enabled ?? false
    property real transparencyBase: Config.appearance.transparency.base ?? 0.85
    property real transparencyLayers: Config.appearance.transparency.layers ?? 0.4
    property real borderRounding: Config.border.rounding ?? 1
    property real borderThickness: Config.border.thickness ?? 1

    property bool desktopClockEnabled: Config.background.desktopClock.enabled ?? false
    property real desktopClockScale: Config.background.desktopClock.scale ?? 1
    property string desktopClockPosition: Config.background.desktopClock.position ?? "bottom-right"
    property bool desktopClockShadowEnabled: Config.background.desktopClock.shadow.enabled ?? true
    property real desktopClockShadowOpacity: Config.background.desktopClock.shadow.opacity ?? 0.7
    property real desktopClockShadowBlur: Config.background.desktopClock.shadow.blur ?? 0.4
    property bool desktopClockBackgroundEnabled: Config.background.desktopClock.background.enabled ?? false
    property real desktopClockBackgroundOpacity: Config.background.desktopClock.background.opacity ?? 0.7
    property bool desktopClockBackgroundBlur: Config.background.desktopClock.background.blur ?? false
    property bool desktopClockInvertColors: Config.background.desktopClock.invertColors ?? false
    property bool backgroundEnabled: Config.background.enabled ?? true
    property bool wallpaperEnabled: Config.background.wallpaperEnabled ?? true
    property bool visualiserEnabled: Config.background.visualiser.enabled ?? false
    property bool visualiserAutoHide: Config.background.visualiser.autoHide ?? true
    property real visualiserRounding: Config.background.visualiser.rounding ?? 1
    property real visualiserSpacing: Config.background.visualiser.spacing ?? 1
    property string pendingAppearanceId: Appearances.currentId
    property string pendingSchemeKey: Schemes.currentScheme
    property string pendingVariant: Schemes.currentVariant
    property string pendingMode: Colours.currentLight ? "light" : "dark"
    property string pendingWallpaperPath: Wallpapers.actualCurrent
    property bool previewActive: false
    property string previewSource: ""
    property string previewTitle: ""
    property string previewSubtitle: ""
    property string previewVariant: ""
    property string previewMode: ""
    property string previewWallpaperPath: ""
    property string previewSchemeType: ""
    property string previewGenWallpaper: ""
    property string previewGenMode: "dark"
    property string previewGenSchemeType: "tonal-spot"
    property bool previewPaletteQueued: false
    property var previewPalette: ({})
    property var previewPaletteCache: ({})
    property string previewRequestKey: ""
    property string previewRunningKey: ""
    property int previewQuality: 8
    readonly property string m3ScriptPath: `${Quickshell.env("HOME")}/.local/lib/dots/generate-m3-colors.py`

    anchors.fill: parent

    function normalizeVariantKey(value: string): string {
        return (value ?? "").toLowerCase().replace(/[^a-z0-9]/g, "");
    }

    function normalizeSchemeType(value: string): string {
        const v = (value ?? "").toLowerCase().replace(/[_\s]/g, "-");
        switch (v) {
        case "tonalspot":
        case "tonal-spot":
            return "tonal-spot";
        case "fruitsalad":
        case "fruit-salad":
        case "rainbow":
            return "expressive";
        case "vibrant":
        case "expressive":
        case "fidelity":
        case "content":
        case "neutral":
        case "monochrome":
            return v;
        default:
            return "tonal-spot";
        }
    }

    function currentSchemeEntry(): var {
        for (const scheme of Schemes.list) {
            if (`${scheme.name} ${scheme.flavour}` === Schemes.currentScheme)
                return scheme;
        }
        return null;
    }

    function findSchemeByVariant(variant: string, preferredName: string): var {
        const target = normalizeVariantKey(variant);
        if (!target)
            return null;

        if (preferredName) {
            for (const scheme of Schemes.list) {
                if (scheme.name === preferredName && normalizeVariantKey(scheme.flavour) === target)
                    return scheme;
            }
        }

        for (const scheme of Schemes.list) {
            if (normalizeVariantKey(scheme.flavour) === target)
                return scheme;
        }

        return null;
    }

    function normalizePreviewPalette(colours: var): var {
        const out = {};
        for (const [name, value] of Object.entries(colours ?? {})) {
            const key = name.startsWith("term") ? name : `m3${name}`;
            out[key] = `#${String(value).replace(/^#/, "")}`;
        }
        return out;
    }

    function buildPreviewKey(wallpaperPath: string, mode: string, schemeType: string): string {
        return `${wallpaperPath}::${mode === "light" ? "light" : "dark"}::${normalizeSchemeType(schemeType)}`;
    }

    function applyPreviewFromCache(key: string): bool {
        if (!key)
            return false;
        if (!Object.prototype.hasOwnProperty.call(previewPaletteCache, key))
            return false;

        const entry = previewPaletteCache[key];
        if (!entry || !entry.palette)
            return false;

        previewPalette = entry.palette;
        previewMode = entry.mode === "light" ? "light" : "dark";
        previewRequestKey = key;
        return true;
    }

    function scheduleGeneratedPreview(wallpaperPath: string, mode: string, schemeType: string): void {
        if (!wallpaperPath)
            return;

        const normalizedMode = mode === "light" ? "light" : "dark";
        const normalizedSchemeType = normalizeSchemeType(schemeType);
        const key = buildPreviewKey(wallpaperPath, normalizedMode, normalizedSchemeType);

        if (applyPreviewFromCache(key))
            return;

        previewRequestKey = key;
        previewGenWallpaper = wallpaperPath;
        previewGenMode = normalizedMode;
        previewGenSchemeType = normalizedSchemeType;
        previewPaletteQueued = true;
        previewPaletteDebounce.restart();
    }

    function startSchemePreview(modelData: var): void {
        if (!modelData)
            return;

        previewActive = true;
        previewSource = "scheme";
        previewTitle = `${modelData.name ?? ""} ${modelData.flavour ?? ""}`.trim();
        previewSubtitle = qsTr("Color scheme");
        previewVariant = modelData.flavour ?? "";
        previewSchemeType = normalizeSchemeType(modelData.flavour ?? "");
        scheduleGeneratedPreview(previewWallpaperPath || pendingWallpaperPath, pendingMode, previewSchemeType);
    }

    function startVariantPreview(variant: string): void {
        const current = currentSchemeEntry();
        const scheme = findSchemeByVariant(variant, current?.name ?? "");
        if (!scheme)
            return;

        previewActive = true;
        previewSource = "variant";
        previewTitle = scheme.flavour ?? variant;
        previewSubtitle = qsTr("Color variant");
        previewVariant = scheme.flavour ?? variant;
        previewSchemeType = normalizeSchemeType(scheme.flavour ?? variant);
        scheduleGeneratedPreview(previewWallpaperPath || pendingWallpaperPath, pendingMode, previewSchemeType);
    }

    function startModePreview(mode: string): void {
        const current = currentSchemeEntry();
        if (!current)
            return;

        previewActive = true;
        previewSource = "mode";
        previewTitle = mode === "light" ? qsTr("Light mode") : qsTr("Dark mode");
        previewSubtitle = qsTr("Theme mode");
        previewMode = mode;
        previewSchemeType = normalizeSchemeType(previewVariant || current.flavour || pendingVariant);
        scheduleGeneratedPreview(previewWallpaperPath || pendingWallpaperPath, mode, previewSchemeType);
    }

    function startWallpaperPreview(path: string, label: string): void {
        if (!path)
            return;

        previewActive = true;
        previewSource = "wallpaper";
        previewTitle = label || path.split("/").pop();
        previewSubtitle = qsTr("Wallpaper");
        previewWallpaperPath = path;
        previewSchemeType = normalizeSchemeType(previewVariant || pendingVariant);
        scheduleGeneratedPreview(path, previewMode || pendingMode, previewSchemeType);
    }

    function startAppearancePreview(modelData: var): void {
        if (!modelData)
            return;

        previewActive = true;
        previewSource = "appearance";
        previewTitle = modelData.name ?? modelData.id ?? qsTr("Appearance");
        previewSubtitle = modelData.style ?? modelData.description ?? qsTr("Appearance preset");
        previewVariant = modelData.schemeType ?? "";
        previewMode = (modelData.darkMode ?? true) ? "dark" : "light";
        previewWallpaperPath = modelData.wallpaper ?? "";
        previewSchemeType = normalizeSchemeType(modelData.schemeType ?? "");

        scheduleGeneratedPreview(previewWallpaperPath || pendingWallpaperPath, previewMode, previewSchemeType);
    }

    function clearPreviewFor(source: string): void {
        if (previewSource === source)
            clearPreview();
    }

    function clearPreview(): void {
        previewActive = false;
        previewSource = "";
        previewTitle = "";
        previewSubtitle = "";
        previewVariant = "";
        previewMode = "";
        previewWallpaperPath = "";
        previewSchemeType = "";
        previewPalette = {};
        previewRequestKey = "";
        previewRunningKey = "";
    }

    function commitSelection(): void {
        clearPreview();
    }

    function stageAppearanceApply(appearanceId: string): void {
        pendingAppearanceId = appearanceId;
        session.queueAction("appearance.apply", ["dots-appearance", "apply", appearanceId]);
    }

    function stageAppearanceApplyWithWallpaper(appearanceId: string, wallpaperPath: string): void {
        pendingAppearanceId = appearanceId;
        pendingWallpaperPath = wallpaperPath;
        session.queueAction("appearance.apply", ["dots-appearance", "apply", appearanceId, "--wallpaper", wallpaperPath]);
    }

    function stageSchemeApply(name: string, flavour: string): void {
        pendingSchemeKey = `${name} ${flavour}`;
        session.queueAction("appearance.scheme", ["dots-color-scheme", "set", "-n", name, "-f", flavour]);
    }

    function stageVariantApply(variant: string): void {
        pendingVariant = variant;
        session.queueAction("appearance.variant", ["dots-color-scheme", "variant", variant]);
    }

    function stageModeApply(mode: string): void {
        pendingMode = mode;
        session.queueAction("appearance.mode", ["dots-color-scheme", "mode", mode]);
    }

    function stageWallpaperApply(path: string): void {
        pendingWallpaperPath = path;
        session.queueAction("appearance.wallpaper", ["dots-hyprpaper-set", path]);
    }

    function resetPendingSelections(): void {
        pendingAppearanceId = Appearances.currentId;
        pendingSchemeKey = Schemes.currentScheme;
        pendingVariant = Schemes.currentVariant;
        pendingMode = Colours.currentLight ? "light" : "dark";
        pendingWallpaperPath = Wallpapers.actualCurrent;
        if (!previewActive) {
            previewWallpaperPath = pendingWallpaperPath;
            previewVariant = pendingVariant;
            previewMode = pendingMode;
            previewSchemeType = normalizeSchemeType(pendingVariant);
        }
    }

    function saveConfig() {
        Config.appearance.anim.durations.scale = root.animDurationsScale;

        Config.appearance.font.family.material = root.fontFamilyMaterial;
        Config.appearance.font.family.mono = root.fontFamilyMono;
        Config.appearance.font.family.sans = root.fontFamilySans;
        Config.appearance.font.size.scale = root.fontSizeScale;

        Config.appearance.padding.scale = root.paddingScale;
        Config.appearance.rounding.scale = root.roundingScale;
        Config.appearance.spacing.scale = root.spacingScale;

        Config.appearance.transparency.enabled = root.transparencyEnabled;
        Config.appearance.transparency.base = root.transparencyBase;
        Config.appearance.transparency.layers = root.transparencyLayers;

        Config.background.desktopClock.enabled = root.desktopClockEnabled;
        Config.background.enabled = root.backgroundEnabled;
        Config.background.desktopClock.scale = root.desktopClockScale;
        Config.background.desktopClock.position = root.desktopClockPosition;
        Config.background.desktopClock.shadow.enabled = root.desktopClockShadowEnabled;
        Config.background.desktopClock.shadow.opacity = root.desktopClockShadowOpacity;
        Config.background.desktopClock.shadow.blur = root.desktopClockShadowBlur;
        Config.background.desktopClock.background.enabled = root.desktopClockBackgroundEnabled;
        Config.background.desktopClock.background.opacity = root.desktopClockBackgroundOpacity;
        Config.background.desktopClock.background.blur = root.desktopClockBackgroundBlur;
        Config.background.desktopClock.invertColors = root.desktopClockInvertColors;

        Config.background.wallpaperEnabled = root.wallpaperEnabled;

        Config.background.visualiser.enabled = root.visualiserEnabled;
        Config.background.visualiser.autoHide = root.visualiserAutoHide;
        Config.background.visualiser.rounding = root.visualiserRounding;
        Config.background.visualiser.spacing = root.visualiserSpacing;

        Config.border.rounding = root.borderRounding;
        Config.border.thickness = root.borderThickness;

        Config.save();
    }

    Component {
        id: appearanceRightContentComponent

        Item {
            id: rightAppearanceFlickable

            ColumnLayout {
                id: contentLayout

                anchors.fill: parent
                spacing: 0

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: Appearance.spacing.normal
                    text: qsTr("Preview")
                    font.pointSize: Appearance.font.size.extraLarge
                    font.weight: 600
                }

                AppearancePreviewPane {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 320
                    Layout.bottomMargin: Appearance.spacing.normal

                    active: root.previewActive
                    source: root.previewSource
                    titleText: root.previewTitle
                    subtitleText: root.previewSubtitle
                    variantText: root.previewVariant
                    modeText: root.previewMode
                    wallpaperPath: root.previewWallpaperPath || root.pendingWallpaperPath
                    rootPane: root
                }

                Loader {
                    id: wallpaperLoader

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.bottomMargin: -Appearance.padding.large * 2

                    active: {
                        const isActive = root.session.activeIndex === 3;
                        const isAdjacent = Math.abs(root.session.activeIndex - 3) === 1;
                        const splitLayout = root.children[0];
                        const loader = splitLayout && splitLayout.rightLoader ? splitLayout.rightLoader : null;
                        const shouldActivate = loader && loader.item !== null && (isActive || isAdjacent);
                        return shouldActivate;
                    }

                    onStatusChanged: {
                        if (status === Loader.Error) {
                            console.error("[AppearancePane] Wallpaper loader error!");
                        }
                    }

                    sourceComponent: WallpaperGrid {
                        session: root.session
                        previewController: root
                    }
                }
            }
        }
    }

    Timer {
        id: previewPaletteDebounce
        interval: 60
        onTriggered: {
            if (!previewPaletteQueued || !previewGenWallpaper)
                return;
            if (!previewPaletteProc.running) {
                previewPaletteQueued = false;
                previewRunningKey = previewRequestKey;
                previewPaletteProc.running = true;
            }
        }
    }

    Process {
        id: previewPaletteProc
        command: [
            "python3",
            root.m3ScriptPath,
            "--image",
            root.previewGenWallpaper,
            "--mode",
            root.previewGenMode,
            "--scheme-type",
            root.previewGenSchemeType,
            "--quality",
            String(root.previewQuality)
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(text);
                    const palette = normalizePreviewPalette(parsed.colours ?? {});
                    root.previewPalette = palette;
                    root.previewMode = parsed.mode === "light" ? "light" : "dark";
                    if (root.previewRunningKey) {
                        root.previewPaletteCache[root.previewRunningKey] = {
                            palette,
                            mode: root.previewMode
                        };
                    }
                } catch (e) {
                    // Keep previous preview if parse fails.
                }
            }
        }
        onRunningChanged: {
            if (!running && previewPaletteQueued) {
                previewPaletteQueued = false;
                running = true;
            }
        }
    }

    SplitPaneLayout {
        anchors.fill: parent

        leftContent: Component {

            StyledFlickable {
                id: sidebarFlickable
                readonly property var rootPane: root
                flickableDirection: Flickable.VerticalFlick
                contentHeight: sidebarLayout.height

                StyledScrollBar.vertical: StyledScrollBar {
                    flickable: sidebarFlickable
                }

                ColumnLayout {
                    id: sidebarLayout
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: Appearance.spacing.small

                    readonly property var rootPane: sidebarFlickable.rootPane

                    readonly property bool allSectionsExpanded: appearancesSection.expanded && themeModeSection.expanded && colorVariantSection.expanded && colorSchemeSection.expanded && animationsSection.expanded && fontsSection.expanded && scalesSection.expanded && transparencySection.expanded && borderSection.expanded && backgroundSection.expanded

                    RowLayout {
                        spacing: Appearance.spacing.smaller

                        StyledText {
                            text: qsTr("Appearance")
                            font.pointSize: Appearance.font.size.large
                            font.weight: 500
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        IconButton {
                            icon: sidebarLayout.allSectionsExpanded ? "unfold_less" : "unfold_more"
                            type: IconButton.Text
                            label.animate: true
                            onClicked: {
                                const shouldExpand = !sidebarLayout.allSectionsExpanded;
                                appearancesSection.expanded = shouldExpand;
                                themeModeSection.expanded = shouldExpand;
                                colorVariantSection.expanded = shouldExpand;
                                colorSchemeSection.expanded = shouldExpand;
                                animationsSection.expanded = shouldExpand;
                                fontsSection.expanded = shouldExpand;
                                scalesSection.expanded = shouldExpand;
                                transparencySection.expanded = shouldExpand;
                                borderSection.expanded = shouldExpand;
                                backgroundSection.expanded = shouldExpand;
                            }
                        }
                    }

                    AppearancesSection {
                        id: appearancesSection
                        session: root.session
                        previewController: root
                    }

                    ThemeModeSection {
                        id: themeModeSection
                        session: root.session
                        previewController: root
                    }

                    ColorVariantSection {
                        id: colorVariantSection
                        session: root.session
                        previewController: root
                    }

                    ColorSchemeSection {
                        id: colorSchemeSection
                        session: root.session
                        previewController: root
                    }

                    AnimationsSection {
                        id: animationsSection
                        rootPane: sidebarFlickable.rootPane
                    }

                    FontsSection {
                        id: fontsSection
                        rootPane: sidebarFlickable.rootPane
                    }

                    ScalesSection {
                        id: scalesSection
                        rootPane: sidebarFlickable.rootPane
                    }

                    TransparencySection {
                        id: transparencySection
                        rootPane: sidebarFlickable.rootPane
                    }

                    BorderSection {
                        id: borderSection
                        rootPane: sidebarFlickable.rootPane
                    }

                    BackgroundSection {
                        id: backgroundSection
                        rootPane: sidebarFlickable.rootPane
                    }
                }
            }
        }

        rightContent: appearanceRightContentComponent
    }

    Connections {
        target: root.session

        function onActiveIndexChanged(): void {
            if (root.session.activeIndex !== 3)
                root.clearPreview();
        }

        function onPendingActionsChanged(): void {
            if (!root.session.hasPendingActions)
                root.resetPendingSelections();
        }
    }

    Component.onDestruction: clearPreview()
    Component.onCompleted: resetPendingSelections()
}
