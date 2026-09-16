import qs.components
import qs.components.controls
import qs.services
import qs.config
import qs.modules.welcome
import qs.modules.welcome as WelcomeModule
import Quickshell
import QtQuick
import QtQuick.Layouts
import "pages"

FloatingWindow {
    id: win

    title: qsTr("Hornero Welcome")
    color: Colours.tPalette.m3surface

    implicitWidth: 1024
    implicitHeight: 640
    minimumSize.width: 960
    minimumSize.height: 600

    visible: true
    // FloatingWindow has no closing signal (that belongs to QML Window):
    // sync state when the surface hides, following the FileDialog /
    // WindowFactory onVisibleChanged pattern.
    onVisibleChanged: {
        if (!visible && Welcome.opened)
            Welcome.close();
    }

    Behavior on color {
        CAnim {}
    }

    // Nav entries in StackLayout order. Labels stay translatable; page
    // content lives in pages/*.qml and actions in Actions.qml.
    readonly property var navPages: [
        {
            id: "start",
            icon: "waving_hand",
            label: qsTr("Start")
        },
        {
            id: "navigate",
            icon: "explore",
            label: qsTr("Navigate")
        },
        {
            id: "shell",
            icon: "terminal",
            label: qsTr("Shell")
        },
        {
            id: "workspaces",
            icon: "dashboard",
            label: qsTr("Workspaces")
        },
        {
            id: "personalize",
            icon: "palette",
            label: qsTr("Personalize")
        },
        {
            id: "tools",
            icon: "handyman",
            label: qsTr("Tools")
        },
        {
            id: "system",
            icon: "settings",
            label: qsTr("System")
        },
        {
            id: "learn",
            icon: "school",
            label: qsTr("Learn")
        }
    ]

    function pageIndex(id: string): int {
        for (let i = 0; i < win.navPages.length; i++) {
            if (win.navPages[i].id === id)
                return i;
        }
        return 0;
    }

    Shortcut {
        sequences: ["Escape"]
        context: Qt.WindowShortcut
        onActivated: Welcome.close()
    }

    Component.onCompleted: {
        const s = win.screen;
        if (s && win.width > 0 && win.height > 0) {
            win.x = Math.max(0, Math.round((s.width - win.width) / 2));
            win.y = Math.max(0, Math.round((s.height - win.height) / 2));
        }
        navList.currentIndex = win.pageIndex(Welcome.currentPage);
        navList.forceActiveFocus();
    }

    Connections {
        target: Welcome
        function onCurrentPageChanged(): void {
            navList.currentIndex = win.pageIndex(Welcome.currentPage);
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Header ───────────────────────────────────────────────────
        StyledRect {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: Colours.layer(Colours.palette.m3surfaceContainer, 1)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Appearance.padding.large
                anchors.rightMargin: Appearance.padding.normal
                spacing: Appearance.spacing.normal

                Image {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    source: Qt.resolvedUrl(`${Quickshell.shellDir}/assets/logo.svg`)
                    fillMode: Image.PreserveAspectFit
                    Accessible.name: qsTr("Hornero logo")
                }

                StyledText {
                    text: qsTr("Hornero Welcome")
                    font.pointSize: Appearance.font.size.large
                    font.weight: 600
                }

                Item {
                    Layout.fillWidth: true
                }

                IconButton {
                    type: IconButton.Text
                    icon: "close"
                    onClicked: Welcome.close()
                }
            }
        }

        // ── Body ─────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Nav rail: arrow keys move, Enter follows automatically.
            ListView {
                id: navList

                Layout.fillHeight: true
                Layout.preferredWidth: 232
                Layout.topMargin: Appearance.padding.normal
                Layout.bottomMargin: Appearance.padding.normal
                Layout.leftMargin: Appearance.padding.normal

                keyNavigationWraps: true
                activeFocusOnTab: true
                spacing: Appearance.spacing.smaller
                highlightMoveDuration: Appearance.anim.durations.normal
                clip: true

                model: win.navPages

                onCurrentIndexChanged: {
                    const entry = win.navPages[currentIndex];
                    if (entry && entry.id !== Welcome.currentPage)
                        Welcome.open(entry.id);
                }

                highlight: StyledRect {
                    radius: Appearance.rounding.normal
                    color: navList.activeFocus ? Colours.palette.m3secondaryContainer : Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)
                    border.width: navList.activeFocus ? 2 : 0
                    border.color: Colours.palette.m3primary
                }

                delegate: StyledRect {
                    id: navItem

                    required property var modelData
                    required property int index

                    readonly property bool isCurrent: ListView.isCurrentItem

                    width: ListView.view.width
                    implicitHeight: 44
                    radius: Appearance.rounding.normal
                    color: isCurrent ? "transparent" : navMouse.containsMouse ? Colours.layer(Colours.palette.m3surfaceContainerHigh, 1) : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Appearance.padding.normal
                        anchors.rightMargin: Appearance.padding.normal
                        spacing: Appearance.spacing.normal

                        MaterialIcon {
                            text: navItem.modelData.icon
                            color: navItem.isCurrent ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: navItem.modelData.label
                            font.weight: navItem.isCurrent ? 600 : 400
                            color: navItem.isCurrent ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: navMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: navList.currentIndex = navItem.index
                    }
                }
            }

            StackLayout {
                id: pages

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: Appearance.padding.large
                currentIndex: win.pageIndex(Welcome.currentPage)

                StartPage {}
                NavigatePage {}
                ShellPage {}
                WorkspacesPage {}
                PersonalizePage {}
                ToolsPage {}
                SystemPage {}
                LearnPage {}
            }
        }

        // ── Footer ───────────────────────────────────────────────────
        StyledRect {
            Layout.fillWidth: true
            Layout.preferredHeight: WelcomeModule.State.writeFailed ? 88 : 64
            color: Colours.layer(Colours.palette.m3surfaceContainer, 1)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Appearance.padding.large
                anchors.rightMargin: Appearance.padding.large
                spacing: Appearance.spacing.normal

                StyledText {
                    text: qsTr("Show on login")
                }

                StyledSwitch {
                    id: loginSwitch

                    focusPolicy: Qt.TabFocus
                    checked: WelcomeModule.State.showOnLogin
                    onToggled: WelcomeModule.State.writeShowOnLogin(checked)
                }

                StyledRect {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    radius: Appearance.rounding.full
                    visible: loginSwitch.activeFocus
                    color: "transparent"
                    border.width: 2
                    border.color: Colours.palette.m3primary
                }

                StyledText {
                    visible: WelcomeModule.State.writeFailed
                    text: WelcomeModule.State.lastWriteError !== "" ? WelcomeModule.State.lastWriteError : qsTr("Preference kept for this session only")
                    color: Colours.palette.m3error
                    font.pointSize: Appearance.font.size.smaller
                    elide: Text.ElideRight
                }

                Item {
                    Layout.fillWidth: true
                }

                Item {
                    id: doneWrap

                    Layout.preferredWidth: doneButton.implicitWidth + 8
                    Layout.preferredHeight: doneButton.implicitHeight + 8
                    activeFocusOnTab: true

                    Keys.onReturnPressed: Welcome.close()
                    Keys.onSpacePressed: Welcome.close()

                    StyledRect {
                        anchors.fill: parent
                        radius: Appearance.rounding.full
                        color: "transparent"
                        border.width: doneWrap.activeFocus ? 2 : 0
                        border.color: Colours.palette.m3primary
                    }

                    TextButton {
                        id: doneButton

                        anchors.centerIn: parent
                        text: qsTr("Done")
                        onClicked: Welcome.close()
                    }
                }
            }
        }
    }
}
