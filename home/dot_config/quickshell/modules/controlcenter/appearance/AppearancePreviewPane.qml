pragma ComponentBehavior: Bound

import qs.components
import qs.components.images
import qs.services
import qs.config
import qs.utils
import Quickshell
import QtQuick
import QtQuick.Layouts

StyledRect {
    id: root

    required property bool active
    required property string source
    required property string titleText
    required property string subtitleText
    required property string variantText
    required property string modeText
    required property string wallpaperPath
    required property var rootPane

    property string gtkThemeText: ""
    property string iconThemeText: ""
    property string gtkPreferText: ""
    property string wallpaperLabel: ""
    property string themeIdText: ""
    property var tags: []
    property int wallpaperCount: 0

    readonly property bool isThemePreview: source === "theme"
    readonly property bool hasRecipe: {
        return !!modeText || !!variantText || !!gtkThemeText || !!iconThemeText || !!gtkPreferText || !!wallpaperLabel || (tags && tags.length > 0);
    }
    readonly property bool showVisualSamples: active && (!!gtkThemeText || !!iconThemeText)

    function previewColor(role: string, fallback: color): color {
        const p = root.rootPane.previewPalette;
        if (p && Object.prototype.hasOwnProperty.call(p, role))
            return p[role];
        return fallback;
    }

    function modeLabel(mode: string): string {
        return mode === "light" ? qsTr("Light") : qsTr("Dark");
    }

    function gtkColorSchemeLabel(value: string): string {
        switch ((value || "").toLowerCase()) {
        case "follow":
            return qsTr("Follow theme mode");
        case "default":
        case "auto":
            return qsTr("Auto (apps decide)");
        case "prefer-light":
        case "light":
            return qsTr("Prefer light");
        case "prefer-dark":
        case "dark":
            return qsTr("Prefer dark");
        default:
            return value || "—";
        }
    }

    function gtkColorSchemeIcon(value: string): string {
        switch ((value || "").toLowerCase()) {
        case "follow":
            return "sync";
        case "default":
        case "auto":
            return "contrast";
        case "prefer-light":
        case "light":
            return "light_mode";
        default:
            return "dark_mode";
        }
    }

    function basename(path: string): string {
        if (!path)
            return "";
        const parts = path.split("/");
        return parts[parts.length - 1] || path;
    }

    function gtkThumbnailCandidates(theme: string): var {
        if (!theme || theme === "auto")
            return [];
        const home = Paths.home;
        const data = Quickshell.env("XDG_DATA_HOME") || `${home}/.local/share`;
        return [
            `/usr/share/themes/${theme}/gtk-3.0/thumbnail.png`,
            `/usr/share/themes/${theme}/cinnamon/thumbnail.png`,
            `/usr/share/themes/${theme}/metacity-1/thumbnail.png`,
            `${data}/themes/${theme}/gtk-3.0/thumbnail.png`,
            `${data}/themes/${theme}/cinnamon/thumbnail.png`,
            `${home}/.themes/${theme}/gtk-3.0/thumbnail.png`
        ];
    }

    function iconSampleCandidates(theme: string, name: string): var {
        if (!theme || !name)
            return [];
        const home = Paths.home;
        const data = Quickshell.env("XDG_DATA_HOME") || `${home}/.local/share`;
        const roots = [`/usr/share/icons/${theme}`, `${data}/icons/${theme}`, `${home}/.icons/${theme}`];
        // Prefer common layouts first (Numix/Papirus size/cat, Adwaita scalable, Breeze cat/size).
        const rels = [
            `48/apps/${name}.svg`, `48/places/${name}.svg`, `48/categories/${name}.svg`,
            `48x48/apps/${name}.svg`, `48x48/places/${name}.svg`,
            `scalable/apps/${name}.svg`, `scalable/places/${name}.svg`, `scalable/categories/${name}.svg`,
            `32/apps/${name}.svg`, `32/places/${name}.svg`,
            `apps/64/${name}.svg`, `places/64/${name}.svg`, `categories/64/${name}.svg`,
            `apps/48/${name}.svg`, `places/48/${name}.svg`,
            `48/apps/${name}.png`, `48/places/${name}.png`, `scalable/places/${name}.png`
        ];
        const out = [];
        for (let r = 0; r < roots.length; r++) {
            for (let i = 0; i < rels.length; i++)
                out.push(`${roots[r]}/${rels[i]}`);
        }
        return out;
    }

    radius: Appearance.rounding.normal
    color: previewColor("m3surfaceContainer", Colours.tPalette.m3surfaceContainer)

    Item {
        anchors.fill: parent
        anchors.margins: Appearance.padding.normal

        RowLayout {
            anchors.fill: parent
            spacing: Appearance.spacing.normal

            // Wallpaper / visual hero
            StyledClippingRect {
                Layout.preferredWidth: root.isThemePreview ? 180 : 220
                Layout.fillHeight: true
                radius: Appearance.rounding.normal
                color: previewColor("m3surfaceContainerHigh", Colours.tPalette.m3surfaceContainerHigh)

                Image {
                    anchors.fill: parent
                    source: root.wallpaperPath ? `file://${root.wallpaperPath}` : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                }

                // Mode badge over wallpaper
                StyledRect {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.margins: Appearance.padding.small
                    visible: root.active && !!root.modeText
                    radius: Appearance.rounding.full
                    color: Qt.alpha(previewColor("m3surface", Colours.palette.m3surface), 0.88)
                    implicitWidth: modeBadge.implicitWidth + Appearance.padding.small * 2
                    implicitHeight: modeBadge.implicitHeight + Appearance.padding.smaller

                    Row {
                        id: modeBadge
                        anchors.centerIn: parent
                        spacing: 4

                        MaterialIcon {
                            text: root.modeText === "light" ? "light_mode" : "dark_mode"
                            font.pointSize: Appearance.font.size.small
                            color: previewColor("m3primary", Colours.palette.m3primary)
                        }

                        StyledText {
                            text: root.modeLabel(root.modeText)
                            font.pointSize: Appearance.font.size.smaller
                            color: previewColor("m3onSurface", Colours.palette.m3onSurface)
                        }
                    }
                }

                MaterialIcon {
                    anchors.centerIn: parent
                    visible: !root.active
                    text: "visibility"
                    font.pointSize: Appearance.font.size.extraLarge
                    color: previewColor("m3outline", Colours.palette.m3outline)
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Appearance.spacing.small

                StyledText {
                    Layout.fillWidth: true
                    text: root.titleText || qsTr("Select an option")
                    font.pointSize: Appearance.font.size.normal
                    font.weight: 600
                    color: previewColor("m3onSurface", Colours.palette.m3onSurface)
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: {
                        if (root.rootPane.previewPaletteQueued || (!!root.rootPane.previewRunningKey && Object.keys(root.rootPane.previewPalette ?? {}).length === 0))
                            return qsTr("Generating palette preview…");
                        return root.subtitleText || qsTr("Preview updates here — click to apply");
                    }
                    color: previewColor("m3outline", Colours.palette.m3outline)
                    font.pointSize: Appearance.font.size.small
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    wrapMode: Text.WordWrap
                }

                // Palette swatches
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.small

                    Repeater {
                        model: [
                            {
                                role: "m3primary",
                                fallback: Colours.palette.m3primary
                            },
                            {
                                role: "m3secondary",
                                fallback: Colours.palette.m3secondary
                            },
                            {
                                role: "m3tertiary",
                                fallback: Colours.palette.m3tertiary
                            },
                            {
                                role: "m3surface",
                                fallback: Colours.palette.m3surface
                            },
                            {
                                role: "m3error",
                                fallback: Colours.palette.m3error
                            }
                        ]

                        delegate: StyledRect {
                            required property var modelData
                            radius: Appearance.rounding.full
                            color: root.previewColor(modelData.role, modelData.fallback)
                            implicitHeight: 22
                            implicitWidth: 22
                            border.width: 1
                            border.color: Qt.alpha(previewColor("m3outline", Colours.palette.m3outline), 0.25)
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    StyledText {
                        visible: root.isThemePreview && !!root.themeIdText
                        text: root.themeIdText
                        font.family: root.rootPane.fontFamilyMono
                        font.pointSize: Appearance.font.size.smaller
                        color: previewColor("m3outline", Colours.palette.m3outline)
                    }
                }

                // Recipe details (what Apply will set)
                StyledRect {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.active && root.hasRecipe
                    radius: Appearance.rounding.normal
                    color: Qt.alpha(previewColor("m3surfaceContainerHigh", Colours.tPalette.m3surfaceContainerHigh), 0.65)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Appearance.padding.normal
                        spacing: Appearance.spacing.small / 2

                        StyledText {
                            text: root.isThemePreview ? qsTr("This theme applies") : qsTr("Preview details")
                            font.pointSize: Appearance.font.size.small
                            font.weight: 600
                            color: previewColor("m3onSurface", Colours.palette.m3onSurface)
                        }

                        Flow {
                            Layout.fillWidth: true
                            visible: !root.isThemePreview
                            spacing: Appearance.spacing.smaller

                            PreviewChip {
                                visible: !!root.modeText
                                icon: root.modeText === "light" ? "light_mode" : "dark_mode"
                                label: qsTr("Mode")
                                value: root.modeLabel(root.modeText)
                            }

                            PreviewChip {
                                visible: !!root.variantText
                                icon: "palette"
                                label: qsTr("Scheme")
                                value: root.variantText
                            }

                            PreviewChip {
                                visible: !!root.gtkThemeText
                                icon: "desktop_windows"
                                label: qsTr("GTK")
                                value: root.gtkThemeText
                            }

                            PreviewChip {
                                visible: !!root.iconThemeText
                                icon: "imagesmode"
                                label: qsTr("Icons")
                                value: root.iconThemeText
                            }

                            PreviewChip {
                                visible: !!root.wallpaperLabel || !!root.wallpaperPath
                                icon: "wallpaper"
                                label: qsTr("Wallpaper")
                                value: root.wallpaperLabel || root.basename(root.wallpaperPath)
                            }
                        }

                        // Exact recipe for theme packs
                        ColumnLayout {
                            Layout.fillWidth: true
                            visible: root.isThemePreview
                            spacing: 2

                            RecipeRow {
                                icon: root.modeText === "light" ? "light_mode" : "dark_mode"
                                label: qsTr("Theme mode")
                                value: root.modeLabel(root.modeText)
                            }

                            RecipeRow {
                                icon: "palette"
                                label: qsTr("M3 scheme type")
                                value: root.variantText || "—"
                            }

                            RecipeRow {
                                icon: "desktop_windows"
                                label: qsTr("GTK theme")
                                value: root.gtkThemeText || "—"
                            }

                            RecipeRow {
                                icon: root.gtkColorSchemeIcon(root.gtkPreferText)
                                label: qsTr("GTK color scheme")
                                value: root.gtkColorSchemeLabel(root.gtkPreferText)
                            }

                            RecipeRow {
                                icon: "imagesmode"
                                label: qsTr("Icon theme")
                                value: root.iconThemeText || "—"
                            }

                            RecipeRow {
                                icon: "wallpaper"
                                label: qsTr("Default wallpaper")
                                value: root.wallpaperLabel || root.basename(root.wallpaperPath) || "—"
                            }

                            RecipeRow {
                                visible: root.wallpaperCount > 0
                                icon: "photo_library"
                                label: qsTr("Wallpapers in pack")
                                value: String(root.wallpaperCount)
                            }
                        }

                        // Visual samples: GTK thumbnail + icon strip
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.topMargin: Appearance.spacing.small / 2
                            visible: root.showVisualSamples
                            spacing: Appearance.spacing.normal

                            ColumnLayout {
                                spacing: 4
                                visible: !!root.gtkThemeText

                                StyledText {
                                    text: qsTr("GTK")
                                    font.pointSize: Appearance.font.size.smaller
                                    color: previewColor("m3outline", Colours.palette.m3outline)
                                }

                                FallbackImage {
                                    implicitWidth: 88
                                    implicitHeight: 56
                                    candidates: root.gtkThumbnailCandidates(root.gtkThemeText)
                                    placeholderIcon: "desktop_windows"
                                    placeholderText: root.gtkThemeText === "auto" ? qsTr("auto") : qsTr("No thumb")
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                visible: !!root.iconThemeText

                                StyledText {
                                    text: qsTr("Icons")
                                    font.pointSize: Appearance.font.size.smaller
                                    color: previewColor("m3outline", Colours.palette.m3outline)
                                }

                                Row {
                                    spacing: Appearance.spacing.small

                                    Repeater {
                                        model: ["folder", "user-home", "firefox", "terminal", "system-file-manager", "applications-system"]

                                        delegate: FallbackImage {
                                            required property string modelData
                                            implicitWidth: 28
                                            implicitHeight: 28
                                            candidates: root.iconSampleCandidates(root.iconThemeText, modelData)
                                            placeholderIcon: ""
                                            hideWhenMissing: true
                                        }
                                    }
                                }
                            }
                        }

                        Flow {
                            Layout.fillWidth: true
                            visible: root.tags && root.tags.length > 0
                            spacing: Appearance.spacing.smaller

                            Repeater {
                                model: root.tags ?? []

                                delegate: StyledRect {
                                    required property var modelData
                                    radius: Appearance.rounding.full
                                    color: Qt.alpha(previewColor("m3secondaryContainer", Colours.palette.m3secondaryContainer), 0.55)
                                    implicitWidth: tagLabel.implicitWidth + Appearance.padding.small * 2
                                    implicitHeight: tagLabel.implicitHeight + Appearance.padding.smaller

                                    StyledText {
                                        id: tagLabel
                                        anchors.centerIn: parent
                                        text: modelData
                                        font.pointSize: Appearance.font.size.smaller
                                        color: previewColor("m3onSecondaryContainer", Colours.palette.m3onSecondaryContainer)
                                    }
                                }
                            }
                        }
                    }
                }

                // Shell chrome preview (non-theme sources keep the typography sandbox)
                StyledRect {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.active && !root.isThemePreview
                    radius: Appearance.rounding.normal * root.rootPane.roundingScale
                    color: root.rootPane.transparencyEnabled ? Qt.alpha(previewColor("m3surfaceContainer", Colours.palette.m3surfaceContainer), root.rootPane.transparencyBase) : previewColor("m3surfaceContainer", Colours.palette.m3surfaceContainer)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Math.max(8, Appearance.padding.normal * root.rootPane.paddingScale)
                        spacing: Math.max(4, Appearance.spacing.small * root.rootPane.spacingScale)

                        StyledText {
                            text: qsTr("Typography Preview")
                            font.family: root.rootPane.fontFamilySans
                            font.pointSize: Appearance.font.size.normal * root.rootPane.fontSizeScale
                            font.weight: 600
                            color: previewColor("m3onSurface", Colours.palette.m3onSurface)
                        }

                        StyledText {
                            text: qsTr("Monospace: 1234 ABCD")
                            font.family: root.rootPane.fontFamilyMono
                            font.pointSize: Appearance.font.size.small * root.rootPane.fontSizeScale
                            color: previewColor("m3onSurfaceVariant", Colours.palette.m3onSurfaceVariant)
                        }

                        StyledText {
                            visible: !!root.variantText
                            text: qsTr("Variant: %1").arg(root.variantText)
                            font.pointSize: Appearance.font.size.small
                            color: previewColor("m3onSurfaceVariant", Colours.palette.m3onSurfaceVariant)
                        }

                        StyledText {
                            visible: !!root.modeText
                            text: qsTr("Mode: %1").arg(root.modeLabel(root.modeText))
                            font.pointSize: Appearance.font.size.small
                            color: previewColor("m3onSurfaceVariant", Colours.palette.m3onSurfaceVariant)
                        }
                    }
                }

                // Idle hint
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: !root.active

                    StyledText {
                        anchors.centerIn: parent
                        text: qsTr("Hover or select a theme, wallpaper, mode, or scheme")
                        color: previewColor("m3outline", Colours.palette.m3outline)
                        font.pointSize: Appearance.font.size.small
                    }
                }
            }
        }
    }

    component PreviewChip: StyledRect {
        id: chip

        property string icon
        property string label
        property string value

        radius: Appearance.rounding.full
        color: Qt.alpha(previewColor("m3primaryContainer", Colours.palette.m3primaryContainer), 0.7)
        implicitWidth: chipRow.implicitWidth + Appearance.padding.small * 2
        implicitHeight: chipRow.implicitHeight + Appearance.padding.smaller

        Row {
            id: chipRow
            anchors.centerIn: parent
            spacing: 4

            MaterialIcon {
                text: chip.icon
                font.pointSize: Appearance.font.size.small
                color: previewColor("m3onPrimaryContainer", Colours.palette.m3onPrimaryContainer)
            }

            StyledText {
                text: `${chip.label}: ${chip.value}`
                font.pointSize: Appearance.font.size.smaller
                color: previewColor("m3onPrimaryContainer", Colours.palette.m3onPrimaryContainer)
            }
        }
    }

    component RecipeRow: RowLayout {
        id: row

        property string icon
        property string label
        property string value

        Layout.fillWidth: true
        spacing: Appearance.spacing.small

        MaterialIcon {
            text: row.icon
            font.pointSize: Appearance.font.size.small
            color: previewColor("m3primary", Colours.palette.m3primary)
        }

        StyledText {
            text: row.label
            font.pointSize: Appearance.font.size.small
            color: previewColor("m3outline", Colours.palette.m3outline)
            Layout.preferredWidth: 120
        }

        StyledText {
            Layout.fillWidth: true
            text: row.value
            font.pointSize: Appearance.font.size.small
            font.weight: 500
            color: previewColor("m3onSurface", Colours.palette.m3onSurface)
            elide: Text.ElideMiddle
        }
    }

    // Tries candidate file paths until one loads; optional placeholder when none do.
    component FallbackImage: StyledRect {
        id: thumb

        property var candidates: []
        property string placeholderIcon: "image"
        property string placeholderText: ""
        property bool hideWhenMissing: false

        property int candidateIndex: 0
        property bool loaded: false
        property bool exhausted: false

        radius: Appearance.rounding.small
        color: Qt.alpha(previewColor("m3surface", Colours.palette.m3surface), 0.55)
        visible: !(hideWhenMissing && exhausted && !loaded)
        clip: true

        onCandidatesChanged: {
            candidateIndex = 0;
            loaded = false;
            exhausted = !candidates || candidates.length === 0;
            img.source = (!exhausted && candidates[0]) ? `file://${candidates[0]}` : "";
        }

        Image {
            id: img
            anchors.fill: parent
            anchors.margins: loaded ? 0 : Appearance.padding.smaller
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            visible: thumb.loaded
            sourceSize.width: thumb.implicitWidth * 2
            sourceSize.height: thumb.implicitHeight * 2

            onStatusChanged: {
                if (status === Image.Ready) {
                    thumb.loaded = true;
                    thumb.exhausted = false;
                    return;
                }
                if (status === Image.Error || status === Image.Null) {
                    const next = thumb.candidateIndex + 1;
                    if (thumb.candidates && next < thumb.candidates.length) {
                        thumb.candidateIndex = next;
                        img.source = `file://${thumb.candidates[next]}`;
                    } else {
                        thumb.loaded = false;
                        thumb.exhausted = true;
                        img.source = "";
                    }
                }
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 2
            visible: !thumb.loaded && !thumb.hideWhenMissing

            MaterialIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !!thumb.placeholderIcon
                text: thumb.placeholderIcon
                font.pointSize: Appearance.font.size.normal
                color: previewColor("m3outline", Colours.palette.m3outline)
            }

            StyledText {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !!thumb.placeholderText
                text: thumb.placeholderText
                font.pointSize: Appearance.font.size.smaller
                color: previewColor("m3outline", Colours.palette.m3outline)
            }
        }

        Component.onCompleted: {
            if (candidates && candidates.length > 0)
                img.source = `file://${candidates[0]}`;
            else
                exhausted = true;
        }
    }
}
