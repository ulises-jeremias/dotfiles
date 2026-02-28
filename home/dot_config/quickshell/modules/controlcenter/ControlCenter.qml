pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.config
import qs.modules.launcher.services
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property ShellScreen screen
    readonly property int rounding: floating ? 0 : Appearance.rounding.normal

    property alias floating: session.floating
    property alias active: session.active
    property alias navExpanded: session.navExpanded

    readonly property Session session: Session {
        id: session

        root: root
    }

    readonly property bool hasPendingChanges: Config.hasPendingChanges || session.hasPendingActions

    function close(): void {
    }

    function applyChanges(): void {
        session.applyPendingActions();
        Schemes.reload();
        Appearances.reload();
        Wallpapers.stopPreview();
        Colours.showPreview = false;
    }

    function saveChanges(): void {
        session.applyPendingActions();
        Config.writeNow();
        Schemes.reload();
        Appearances.reload();
        Wallpapers.stopPreview();
        Colours.showPreview = false;
    }

    function revertChanges(): void {
        session.clearPendingActions();
        Config.revertChanges();
        Schemes.reload();
        Appearances.reload();
        Wallpapers.stopPreview();
        Colours.showPreview = false;
    }

    implicitWidth: implicitHeight * Config.controlCenter.sizes.ratio
    implicitHeight: screen.height * Config.controlCenter.sizes.heightMult

    Component.onCompleted: Config.beginEditSession()
    Component.onDestruction: Config.endEditSession()

    GridLayout {
        anchors.fill: parent

        rowSpacing: 0
        columnSpacing: 0
        rows: root.floating ? 2 : 1
        columns: 2

        Loader {
            Layout.fillWidth: true
            Layout.columnSpan: 2

            active: root.floating
            visible: active

            sourceComponent: WindowTitle {
                screen: root.screen
                session: root.session
            }
        }

        StyledRect {
            Layout.fillHeight: true

            topLeftRadius: root.rounding
            bottomLeftRadius: root.rounding
            implicitWidth: navRail.implicitWidth
            color: Colours.tPalette.m3surfaceContainer

            CustomMouseArea {
                anchors.fill: parent

                function onWheel(event: WheelEvent): void {
                    // Prevent tab switching during initial opening animation to avoid blank pages
                    if (!panes.initialOpeningComplete) {
                        return;
                    }

                    if (event.angleDelta.y < 0)
                        root.session.activeIndex = Math.min(root.session.activeIndex + 1, root.session.panes.length - 1);
                    else if (event.angleDelta.y > 0)
                        root.session.activeIndex = Math.max(root.session.activeIndex - 1, 0);
                }
            }

            NavRail {
                id: navRail

                screen: root.screen
                session: root.session
                initialOpeningComplete: root.initialOpeningComplete
            }
        }

        Panes {
            id: panes

            Layout.fillWidth: true
            Layout.fillHeight: true

            topRightRadius: root.rounding
            bottomRightRadius: root.rounding
            session: root.session
        }
    }

    StyledRect {
        id: actionBar
        z: 20

        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: Appearance.padding.large
        anchors.bottomMargin: Appearance.padding.large

        color: Colours.tPalette.m3surfaceContainerHigh
        radius: Appearance.rounding.full
        visible: true
        opacity: root.hasPendingChanges ? 1 : 0.9

        implicitHeight: actionsRow.implicitHeight + Appearance.padding.small * 2
        implicitWidth: actionsRow.implicitWidth + Appearance.padding.small * 2

        RowLayout {
            id: actionsRow
            anchors.centerIn: parent
            spacing: Appearance.spacing.small

            TextButton {
                type: TextButton.Tonal
                text: qsTr("Apply")
                enabled: root.hasPendingChanges
                onClicked: root.applyChanges()
            }

            TextButton {
                type: TextButton.Filled
                text: qsTr("Save")
                enabled: root.hasPendingChanges
                onClicked: root.saveChanges()
            }

            TextButton {
                type: TextButton.Text
                text: qsTr("Revert")
                enabled: root.hasPendingChanges
                onClicked: root.revertChanges()
            }
        }
    }

    readonly property bool initialOpeningComplete: panes.initialOpeningComplete
}
