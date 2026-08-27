pragma ComponentBehavior: Bound

import qs.components
import qs.components.containers
import qs.services
import qs.config
import qs.utils
import qs.modules.bar
import Quickshell
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
            //             x: modelData.x
            //             y: modelData.y
            //             width: modelData.width
            //             height: modelData.height
            //             color: "#60ff0000"
            //             border.color: "#ffff0000"
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
                    const trigger = Math.max(bar.frameInset, win.dragMaskPadding, 1);
                    const rects = [
                        {
                            x: 0,
                            y: 0,
                            width: win.width,
                            height: trigger
                        },
                        {
                            x: 0,
                            y: win.height - trigger,
                            width: win.width,
                            height: trigger
                        },
                        {
                            x: 0,
                            y: trigger,
                            width: trigger,
                            height: Math.max(0, win.height - trigger * 2)
                        },
                        {
                            x: win.width - trigger,
                            y: trigger,
                            width: trigger,
                            height: Math.max(0, win.height - trigger * 2)
                        }
                    ];

                    if (bar.visible && bar.visualWidth > 0 && bar.visualHeight > 0) {
                        rects.push({
                            x: bar.visualX,
                            y: bar.visualY,
                            width: bar.visualWidth,
                            height: bar.visualHeight
                        });
                    }

                    for (const panel of panels.children) {
                        if (panel.width > 0 && panel.height > 0) {
                            rects.push({
                                x: panel.x + bar.marginLeft,
                                y: panel.y + bar.marginTop,
                                width: panel.width,
                                height: panel.height
                            });
                        }
                    }
                    return rects;
                }

                Region {
                    required property var modelData

                    x: modelData.x
                    y: modelData.y
                    width: modelData.width
                    height: modelData.height
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

                    anchors.left: (!Config.bar.isVertical() || Config.bar.position === "left") ? parent.left : undefined
                    anchors.right: (!Config.bar.isVertical() || Config.bar.position === "right") ? parent.right : undefined
                    anchors.top: (Config.bar.isVertical() || Config.bar.position === "top") ? parent.top : undefined
                    anchors.bottom: (Config.bar.isVertical() || Config.bar.position === "bottom") ? parent.bottom : undefined

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
