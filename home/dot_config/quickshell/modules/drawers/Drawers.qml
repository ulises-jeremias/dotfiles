pragma ComponentBehavior: Bound

import qs.components
import qs.components.containers
import qs.services
import qs.config
import qs.utils
import qs.modules.bar
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Effects

Variants {
    model: Quickshell.screens

    Scope {
        id: scope

        required property ShellScreen modelData
        readonly property bool barDisabled: Strings.testRegexList(Config.bar.excludedScreens, modelData.name)

        Exclusions {
            screen: scope.modelData
            bar: bar
        }

        StyledWindow {
            id: win

            readonly property bool hasFullscreen: Hypr.monitorFor(screen)?.activeWorkspace?.toplevels.values.some(t => t.lastIpcObject.fullscreen === 2) ?? false
            readonly property int dragMaskPadding: {
                if (focusGrab.active || panels.popouts.isDetached)
                    return 0;

                const mon = Hypr.monitorFor(screen);
                if (mon?.lastIpcObject?.specialWorkspace?.name || mon?.activeWorkspace?.lastIpcObject?.windows > 0)
                    return 0;

                const thresholds = [];
                for (const panel of ["dashboard", "launcher", "session", "sidebar"])
                    if (Config[panel].enabled)
                        thresholds.push(Config[panel].dragThreshold);
                return Math.max(...thresholds);
            }

            onHasFullscreenChanged: {
                visibilities.launcher = false;
                visibilities.session = false;
                visibilities.dashboard = false;
                visibilities.layoutPicker = false;
            }

            screen: scope.modelData
            name: "drawers"
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: visibilities.launcher || visibilities.session || visibilities.layoutPicker ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            mask: Region {
                regions: win.hasFullscreen ? [] : inputRegions.instances
            }

            // DEBUG overlay disabled for production
            // Item {
            //     id: debugOverlay
            //     anchors.fill: parent
            //     visible: false
            //     z: 999
            //     Repeater {
            //         model: inputRegions.model
            //         Rectangle {
            //             required property var modelData
            //             readonly property bool isEdge: modelData !== null && typeof modelData === "object" && modelData.isEdge === true
            //             x: isEdge ? modelData.x : modelData.x + bar.marginLeft
            //             y: isEdge ? modelData.y : modelData.y + bar.marginTop
            //             width: isEdge ? modelData.width : (modelData.width > 0 && modelData.height > 0 ? modelData.width : 0)
            //             height: isEdge ? modelData.height : (modelData.width > 0 && modelData.height > 0 ? modelData.height : 0)
            //             color: isEdge ? "#3000ff00" : "#60ff0000"
            //             border.color: isEdge ? "#8000ff00" : "#ffff0000"
            //             border.width: 2
            //         }
            //     }
            // }

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            Variants {
                id: inputRegions

                model: {
                    if (win.hasFullscreen)
                        return [];
                    const trigger = Math.max(bar.frameInset, win.dragMaskPadding, 1);
                    const rects = [];
                    if (panels.popouts.isDetached) {
                        // Detached popouts grab all clicks so outside-clicks
                        // can close them (see Interactions.onPressed)
                        rects.push({
                            x: 0,
                            y: 0,
                            width: win.width,
                            height: win.height,
                            isEdge: true
                        });
                        return rects;
                    }
                    rects.push(
                        {
                            x: 0,
                            y: 0,
                            width: win.width,
                            height: trigger,
                            isEdge: true
                        },
                        {
                            x: 0,
                            y: win.height - trigger,
                            width: win.width,
                            height: trigger,
                            isEdge: true
                        },
                        {
                            x: 0,
                            y: trigger,
                            width: trigger,
                            height: Math.max(0, win.height - trigger * 2),
                            isEdge: true
                        },
                        {
                            x: win.width - trigger,
                            y: trigger,
                            width: trigger,
                            height: Math.max(0, win.height - trigger * 2),
                            isEdge: true
                        }
                    );

                    if (bar.visible && bar.visualWidth > 0 && bar.visualHeight > 0) {
                        rects.push({
                            x: bar.visualX,
                            y: bar.visualY,
                            width: bar.visualWidth,
                            height: bar.visualHeight,
                            isEdge: true
                        });
                    }

                    // Panels as live Items for reactive geometry during animations
                    for (const p of panels.children)
                        rects.push(p);
                    return rects;
                }

                Region {
                    required property var modelData

                    readonly property bool isEdge: modelData !== null && typeof modelData === "object" && modelData.isEdge === true
                    x: isEdge ? modelData.x : modelData.x + bar.marginLeft
                    y: isEdge ? modelData.y : modelData.y + bar.marginTop
                    width: isEdge ? modelData.width : (modelData.width > 0 && modelData.height > 0 ? modelData.width : 0)
                    height: isEdge ? modelData.height : (modelData.width > 0 && modelData.height > 0 ? modelData.height : 0)
                }
            }

            HyprlandFocusGrab {
                id: focusGrab

                active: (visibilities.launcher && Config.launcher.enabled) || (visibilities.session && Config.session.enabled) || (visibilities.sidebar && Config.sidebar.enabled) || (!Config.dashboard.showOnHover && visibilities.dashboard && Config.dashboard.enabled) || visibilities.layoutPicker || (panels.popouts.currentName.startsWith("traymenu") && panels.popouts.current?.depth > 1)
                windows: [win]
                onCleared: {
                    visibilities.launcher = false;
                    visibilities.session = false;
                    visibilities.sidebar = false;
                    visibilities.dashboard = false;
                    visibilities.layoutPicker = false;
                    panels.popouts.hasCurrent = false;
                    bar.closeTray();
                }
            }

            StyledRect {
                anchors.fill: parent
                opacity: (visibilities.session && Config.session.enabled) || visibilities.layoutPicker ? 0.5 : 0
                color: Colours.palette.m3scrim

                Behavior on opacity {
                    Anim {}
                }
            }

            Item {
                anchors.fill: parent
                opacity: Colours.transparency.enabled ? Colours.transparency.base : 1
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    blurMax: 15
                    shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.7)
                }

                Border {
                    bar: bar
                    visible: bar.frameVisible
                }

                Backgrounds {
                    panels: panels
                    bar: bar
                }
            }

            PersistentProperties {
                id: visibilities

                property bool bar
                property bool osd
                property bool session
                property bool launcher
                property bool dashboard
                property bool utilities
                property bool sidebar
                property bool layoutPicker

                Component.onCompleted: Visibilities.load(scope.modelData, this)
            }

            // DEBUG: red borders on every panel + bar. Toggle with:
            //   qs ipc call debug borders
            Item {
                id: debugBorders

                anchors.fill: parent
                visible: false
                z: 1000

                // Bar wrapper (edge strip) — orange
                Rectangle {
                    x: bar.x
                    y: bar.y
                    width: bar.width
                    height: bar.height
                    color: "transparent"
                    border.color: "#FF8800"
                    border.width: 2
                }

                // Bar pill (visual extent) — bright red
                Rectangle {
                    x: bar.visualX
                    y: bar.visualY
                    width: bar.visualWidth
                    height: bar.visualHeight
                    color: "transparent"
                    border.color: "#FF2020"
                    border.width: 3
                }

                // Every panel (launcher, dashboard, session, sidebar,
                // utilities, notifications, popouts, osd, toasts...) — red
                Repeater {
                    model: panels.children

                    Rectangle {
                        required property Item modelData

                        x: modelData.x + bar.marginLeft
                        y: modelData.y + bar.marginTop
                        width: modelData.width
                        height: modelData.height
                        color: "transparent"
                        border.color: "#FF2020"
                        border.width: 2
                    }
                }
            }

            IpcHandler {
                target: "debug"

                function borders(): string {
                    debugBorders.visible = !debugBorders.visible;
                    return debugBorders.visible ? "borders ON" : "borders OFF";
                }

                function dump(): string {
                    const panelsDump = [];
                    for (const p of panels.children)
                        panelsDump.push({
                            name: p.objectName || String(p).split("_")[0],
                            x: p.x, y: p.y, width: p.width, height: p.height,
                            visible: p.visible
                        });
                    return JSON.stringify({
                        win: {w: win.width, h: win.height},
                        bar: {
                            x: bar.x, y: bar.y, w: bar.width, h: bar.height,
                            implicitW: bar.implicitWidth, implicitH: bar.implicitHeight,
                            position: bar.position, vertical: bar.vertical,
                            floating: bar.floating, thickness: bar.thickness,
                            currentThickness: bar.currentThickness,
                            pill: {x: bar.visualX, y: bar.visualY, w: bar.visualWidth, h: bar.visualHeight},
                        contentLoader: {
                            w: bar.children[0]?.width ?? -1, h: bar.children[0]?.height ?? -1,
                            itemW: bar.children[0]?.item?.width ?? -1, itemH: bar.children[0]?.item?.height ?? -1
                        },
                        pillDirect: {
                            w: bar.visualItem?.width ?? -1,
                            h: bar.visualItem?.height ?? -1,
                            floatGap: bar.visualItem?.floatGap ?? -999,
                            styleAttached: bar.visualItem?.styleAttached ?? "undef",
                            effStyle: bar.visualItem?.effStyle ?? "undef"
                        },
                        layout: {
                            w: bar.children[0]?.item?.container?.width ?? -1,
                            h: bar.children[0]?.item?.container?.height ?? -1,
                            implW: bar.children[0]?.item?.container?.implicitWidth ?? -1,
                            implH: bar.children[0]?.item?.container?.implicitHeight ?? -1,
                            x: bar.children[0]?.item?.container?.x ?? -1,
                            y: bar.children[0]?.item?.container?.y ?? -1
                        },
                            disabled: bar.disabled,
                        config: {
                            position: Config.bar.position,
                            style: Config.bar.style,
                            perScreen: Config.bar.perScreen,
                            styleFor: Config.bar.styleFor("HDMI-A-1"),
                            floatingFor: Config.bar.isFloatingFor("HDMI-A-1")
                        },
                        barFloating: bar.floating,
                        barStyleAttached: bar.styleAttached,
                        barEffStyle: bar.effStyle
                        },
                        panelsMargins: {
                            left: bar.marginLeft, top: bar.marginTop,
                            right: bar.marginRight, bottom: bar.marginBottom
                        },
                        panels: panelsDump
                    });
                }
            }

            Interactions {
                enabled: !win.hasFullscreen
                screen: scope.modelData
                popouts: panels.popouts
                visibilities: visibilities
                panels: panels
                bar: bar

                Panels {
                    id: panels

                    screen: scope.modelData
                    visibilities: visibilities
                    bar: bar
                }

                BarWrapper {
                    id: bar

                    anchors.left: (!bar.vertical || bar.position === "left") ? parent.left : undefined
                    anchors.right: (!bar.vertical || bar.position === "right") ? parent.right : undefined
                    anchors.top: (bar.vertical || bar.position === "top") ? parent.top : undefined
                    anchors.bottom: (bar.vertical || bar.position === "bottom") ? parent.bottom : undefined

                    // Floating bars: gap between the bar and the screen edge
                    anchors.topMargin: (bar.position === "top" && bar.floating) ? Config.bar.floatingMargin : 0
                    anchors.bottomMargin: (bar.position === "bottom" && bar.floating) ? Config.bar.floatingMargin : 0
                    anchors.leftMargin: (bar.position === "left" && bar.floating) ? Config.bar.floatingMargin : 0
                    anchors.rightMargin: (bar.position === "right" && bar.floating) ? Config.bar.floatingMargin : 0

                    screen: scope.modelData
                    visibilities: visibilities
                    popouts: panels.popouts

                    disabled: scope.barDisabled || win.hasFullscreen
                    frameVisible: Config.border.frameEnabled && !win.hasFullscreen

                    Component.onCompleted: Visibilities.setBar(scope.modelData, this)
                }
            }
        }
    }
}
