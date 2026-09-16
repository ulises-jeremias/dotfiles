pragma Singleton

import Hornero
import QtQuick
import Quickshell

// Native wallpaper color analysis (issue #2, migration step (b)).
//
// Thin wrapper around the native `ImageAnalyser` plugin
// (`dominantColour`/`luminance`). Covers instant wallpaper tone analysis
// without shelling out. Full Material-3 palette generation still needs the
// `dots-m3-colors` compat adapter (materialyoucolor lives outside this
// repo); those call sites keep a TODO(hornero-compat) marker.
// See docs/NATIVE-APPEARANCE.md.
Singleton {
    id: root

    // Wallpaper path to analyse. Binds straight through to the plugin, so
    // setting it re-runs the native analysis asynchronously.
    property string source: ""

    readonly property color dominantColour: analyser.dominantColour
    readonly property real luminance: analyser.luminance

    // True once the plugin produced a non-default analysis result.
    readonly property bool ready: analyser.luminance > 0 || (analyser.dominantColour.r + analyser.dominantColour.g + analyser.dominantColour.b) > 0

    // Wallpaper brightness hint using the same luminance scale as
    // Colours.getLuminance (0 = black … ~1 = white).
    readonly property bool isLight: analyser.luminance >= 0.5

    function analyze(path: string): void {
        if (!path)
            return;
        source = path;
    }

    ImageAnalyser {
        id: analyser

        source: root.source
    }
}
