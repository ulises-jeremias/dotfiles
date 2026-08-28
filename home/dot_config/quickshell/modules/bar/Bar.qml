pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import "popouts" as BarPopouts
import "components"
import "components/workspaces"
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property ShellScreen screen
    required property PersistentProperties visibilities
    required property BarPopouts.Wrapper popouts

    readonly property bool vertical: Config.bar.isVerticalFor(screen.name)
    readonly property bool floating: Config.bar.isFloatingFor(screen.name)
    readonly property int edgePadding: Appearance.padding.large
    readonly property int barPadding: Math.max(Appearance.padding.smaller, Config.border.thickness)
    // Fixed main-axis thickness of the bar content (excludes the float gap)
    readonly property int pillThickness: Config.bar.sizes.innerWidth + barPadding * 2
    // Inner padding of the pill when floating
    readonly property int pillPadding: floating ? Appearance.padding.normal : 0
    // Kept for ActiveWindow compat (main-axis end padding)
    readonly property int vPadding: edgePadding
    readonly property GridLayout container: layout
    readonly property Item visualItem: pill

    function closeTray(): void {
        if (!Config.bar.tray.compact)
            return;

        for (let i = 0; i < repeater.count; i++) {
            const item = repeater.itemAt(i);
            if (item?.enabled && item.id === "tray") {
                item.item.expanded = false;
            }
        }
    }

    function resetPopout(): void {
        popouts.hasCurrent = false;
        popouts.currentName = "";
        popouts.currentCenter = 0;
        closeTray();
    }

    function checkPopout(pos: real): void {
        try {
            if (!pill || !layout)
                return;
            // pos is a main-axis coordinate in window space; convert to layout space
            // (the pill may be offset when floating, and the layout has inner margins)
            const pt = layout.mapFromItem(pill, vertical ? pill.width / 2 : pos - pill.x, vertical ? pos - pill.y : pill.height / 2);
        const axisPos = vertical ? pt.y : pt.x;
        const ch = layout.childAt(pt.x, pt.y) as WrappedLoader;

        if (ch?.id !== "tray")
            closeTray();

        if (!ch) {
            popouts.hasCurrent = false;
            return;
        }

        const id = ch.id;
        const start = vertical ? ch.y : ch.x;
        const item = ch.item;
        const itemLength = vertical ? item.implicitHeight : item.implicitWidth;

        if (id === "statusIcons" && Config.bar.popouts.statusIcons) {
            if (!item || !item.items)
                return;
            const items = item.items;
            if (!items || typeof items.childAt !== "function")
                return;
            const mapped = vertical ? root.mapToItem(items, 0, pos) : root.mapToItem(items, pos, 0);
            if (!mapped)
                return;
            const icon = vertical ? items.childAt(items.width / 2, mapped.y) : items.childAt(mapped.x, items.height / 2);
            if (icon) {
                popouts.currentName = icon.name;
                const iconRef = icon;
                popouts.currentCenter = Qt.binding(() => {
                    try {
                        if (!iconRef || typeof iconRef.mapToItem !== "function")
                            return 0;
                        return vertical ? iconRef.mapToItem(null, 0, iconRef.implicitHeight / 2).y : iconRef.mapToItem(null, iconRef.implicitWidth / 2, 0).x;
                    } catch (e) {
                        return 0;
                    }
                });
                popouts.hasCurrent = true;
            }
        } else if (id === "tray" && Config.bar.popouts.tray) {
            if (!item || !item.expandIcon)
                return;
            const overExpandIcon = vertical ? item.expandIcon.contains(root.mapToItem(item.expandIcon, item.implicitWidth / 2, pos)) : item.expandIcon.contains(root.mapToItem(item.expandIcon, pos, item.implicitHeight / 2));
            if (!Config.bar.tray.compact || (item.expanded && !overExpandIcon)) {
                const layoutLength = vertical ? item.layout.implicitHeight : item.layout.implicitWidth;
                const count = item.items?.count ?? 0;
                const index = Math.floor(((axisPos - start - item.padding * 2 + item.spacing) / layoutLength) * count);
                const trayItem = item.items?.itemAt(index) ?? null;
                if (trayItem) {
                    popouts.currentName = `traymenu${index}`;
                    const trayRef = trayItem;
                    popouts.currentCenter = Qt.binding(() => {
                        try {
                            if (!trayRef || typeof trayRef.mapToItem !== "function")
                                return 0;
                            return vertical ? trayRef.mapToItem(null, 0, trayRef.implicitHeight / 2).y : trayRef.mapToItem(null, trayRef.implicitWidth / 2, 0).x;
                        } catch (e) {
                            return 0;
                        }
                    });
                    popouts.hasCurrent = true;
                } else {
                    popouts.hasCurrent = false;
                }
            } else {
                popouts.hasCurrent = false;
                item.expanded = true;
            }
        } else if (id === "activeWindow" && Config.bar.popouts.activeWindow) {
            if (!item)
                return;
            popouts.currentName = id.toLowerCase();
            const winRef = item;
            const len = itemLength;
            popouts.currentCenter = Qt.binding(() => {
                try {
                    if (!winRef || typeof winRef.mapToItem !== "function")
                        return 0;
                    return vertical ? winRef.mapToItem(null, 0, len / 2).y : winRef.mapToItem(null, len / 2, 0).x;
                } catch (e) {
                    return 0;
                }
            });
            popouts.hasCurrent = true;
        }
        } catch (e) {
            // During layout transitions the bar items may be temporarily undefined
            popouts.hasCurrent = false;
        }
    }

    function handleWheel(pos: real, angleDelta: point): void {
        const pt = layout.mapFromItem(pill, vertical ? pill.width / 2 : pos - pill.x, vertical ? pos - pill.y : pill.height / 2);
        const ch = layout.childAt(pt.x, pt.y) as WrappedLoader;
        if (ch?.id === "workspaces" && Config.bar.scrollActions.workspaces) {
            // Workspace scroll
            const mon = (Config.bar.workspaces.perMonitorWorkspaces ? Hypr.monitorFor(screen) : Hypr.focusedMonitor);
            const specialWs = mon?.lastIpcObject.specialWorkspace.name;
            if (specialWs?.length > 0)
                Hypr.dispatch(`togglespecialworkspace ${specialWs.slice(8)}`);
            else if (angleDelta.y < 0 || (Config.bar.workspaces.perMonitorWorkspaces ? mon.activeWorkspace?.id : Hypr.activeWsId) > 1)
                Hypr.dispatch(`workspace r${angleDelta.y > 0 ? "-" : "+"}1`);
        } else if (pos < (vertical ? parent.height : parent.width) / 2 && Config.bar.scrollActions.volume) {
            // Volume scroll on first half
            if (angleDelta.y > 0)
                Audio.incrementVolume();
            else if (angleDelta.y < 0)
                Audio.decrementVolume();
        } else if (Config.bar.scrollActions.brightness) {
            // Brightness scroll on second half
            const monitor = Brightness.getMonitorForScreen(screen);
            if (angleDelta.y > 0)
                monitor.setBrightness(monitor.brightness + Config.services.brightnessIncrement);
            else if (angleDelta.y < 0)
                monitor.setBrightness(monitor.brightness - Config.services.brightnessIncrement);
        }
    }

    Connections {
        target: Config.bar

        function onEntriesChanged(): void {
            root.resetPopout();
        }

        function onPositionChanged(): void {
            root.resetPopout();
        }

        function onStyleChanged(): void {
            root.resetPopout();
        }
    }

    // The pill: actual bar content container. Attached bars fill the whole edge
    // strip (content glued to the interior side so it slides out on hide instead
    // of squishing); floating bars are content-sized and centered on the cross
    // axis with a gap to the screen edge. Positioned with pure bindings (no
    // anchors) to avoid anchor conflicts during live config reloads.
    Item {
        id: pill

        width: root.vertical ? root.pillThickness : (root.floating ? layout.implicitWidth + root.pillPadding * 2 : parent.width)
        height: root.vertical ? (root.floating ? layout.implicitHeight + root.pillPadding * 2 : parent.height) : root.pillThickness

        // Floating gap: only when actually floating; attached bars glue to the edge
        readonly property real floatGap: root.floating ? Config.bar.floatingMargin : 0

        x: {
            if (root.vertical)
                return Config.bar.positionFor(root.screen.name) === "left" ? root.floatGap : parent.width - width - root.floatGap;
            return root.floating ? Math.round((parent.width - width) / 2) : 0;
        }
        y: {
            if (!root.vertical)
                return Config.bar.positionFor(root.screen.name) === "top" ? root.floatGap : parent.height - height - root.floatGap;
            return root.floating ? Math.round((parent.height - height) / 2) : 0;
        }

        // Own background when floating (attached bars are backed by the screen border frame)
        StyledRect {
            visible: root.floating || !Config.border.frameEnabled
            anchors.fill: parent
            color: Colours.layer(Colours.palette.m3surface, 1)
            radius: root.floating ? Appearance.rounding.full : 0
        }

        GridLayout {
            id: layout

            anchors.fill: parent
            anchors.margins: root.pillPadding

            flow: root.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
            rows: root.vertical ? -1 : 1
            columns: root.vertical ? 1 : -1
            rowSpacing: Appearance.spacing.normal
            columnSpacing: Appearance.spacing.normal

            Repeater {
                id: repeater

                model: Config.bar.entries

                DelegateChooser {
                    role: "id"

                    DelegateChoice {
                        roleValue: "spacer"
                        delegate: WrappedLoader {
                            Layout.fillHeight: enabled && root.vertical
                            Layout.fillWidth: enabled && !root.vertical
                        }
                    }
                    DelegateChoice {
                        roleValue: "logo"
                        delegate: WrappedLoader {
                            sourceComponent: OsIcon {}
                        }
                    }
                    DelegateChoice {
                        roleValue: "workspaces"
                        delegate: WrappedLoader {
                            sourceComponent: Workspaces {
                                screen: root.screen
                            }
                        }
                    }
                    DelegateChoice {
                        roleValue: "activeWindow"
                        delegate: WrappedLoader {
                            sourceComponent: ActiveWindow {
                                bar: root
                                monitor: Brightness.getMonitorForScreen(root.screen)
                            }
                        }
                    }
                    DelegateChoice {
                        roleValue: "tray"
                        delegate: WrappedLoader {
                            sourceComponent: Tray {
                                screen: root.screen
                            }
                        }
                    }
                    DelegateChoice {
                        roleValue: "clock"
                        delegate: WrappedLoader {
                            sourceComponent: Clock {
                                screen: root.screen
                            }
                        }
                    }
                    DelegateChoice {
                        roleValue: "statusIcons"
                        delegate: WrappedLoader {
                            sourceComponent: StatusIcons {
                                screen: root.screen
                            }
                        }
                    }
                    DelegateChoice {
                        roleValue: "audioSlider"
                        delegate: WrappedLoader {
                            sourceComponent: InlineSlider {
                                screen: root.screen
                                kind: "audio"
                            }
                        }
                    }
                    DelegateChoice {
                        roleValue: "brightnessSlider"
                        delegate: WrappedLoader {
                            sourceComponent: InlineSlider {
                                screen: root.screen
                                kind: "brightness"
                            }
                        }
                    }
                    DelegateChoice {
                        roleValue: "power"
                        delegate: WrappedLoader {
                            sourceComponent: Power {
                                visibilities: root.visibilities
                            }
                        }
                    }
                }
            }
        }
    }

    component WrappedLoader: Loader {
        required property bool enabled
        required property string id
        required property int index

        function findFirstEnabled(): Item {
            const count = repeater.count;
            for (let i = 0; i < count; i++) {
                const item = repeater.itemAt(i);
                if (item?.enabled)
                    return item;
            }
            return null;
        }

        function findLastEnabled(): Item {
            for (let i = repeater.count - 1; i >= 0; i--) {
                const item = repeater.itemAt(i);
                if (item?.enabled)
                    return item;
            }
            return null;
        }

        Layout.alignment: root.vertical ? Qt.AlignHCenter : Qt.AlignVCenter

        // Cursed ahh thing to add padding to first and last enabled components
        Layout.topMargin: root.vertical && findFirstEnabled() === this ? root.edgePadding : 0
        Layout.bottomMargin: root.vertical && findLastEnabled() === this ? root.edgePadding : 0
        Layout.leftMargin: !root.vertical && findFirstEnabled() === this ? root.edgePadding : 0
        Layout.rightMargin: !root.vertical && findLastEnabled() === this ? root.edgePadding : 0

        visible: enabled
        active: enabled
    }
}
