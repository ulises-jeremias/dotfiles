pragma ComponentBehavior: Bound

import qs.components
import qs.components.images
import qs.components.filedialog
import qs.services
import qs.config
import qs.utils
import QtQuick
import QtMultimedia
import Quickshell.Services.UPower

Item {
    id: root

    property string source: Wallpapers.current
    property var current
    property bool completed

    onSourceChanged: {
        if (!source) {
            current = null;
        } else {
            Qt.callLater(() => {
                if (!current && source) {
                    if (Images.isVideo(source))
                        current = videoComp.createObject(this, { path: source });
                    else
                        current = imgComp.createObject(this, { path: source });
                }
            });
        }
    }

    Component.onCompleted: {
        completed = true;
        if (!current && source) {
            Qt.callLater(() => {
                if (!current && source) {
                    if (Images.isVideo(source))
                        current = videoComp.createObject(this, { path: source });
                    else
                        current = imgComp.createObject(this, { path: source });
                }
            });
        }
    }

    // No wallpaper set: prompt the user
    Loader {
        anchors.fill: parent
        active: root.completed && !root.source

        sourceComponent: StyledRect {
            color: Colours.palette.m3surfaceContainer

            Row {
                anchors.centerIn: parent
                spacing: Appearance.spacing.large

                MaterialIcon {
                    text: "sentiment_stressed"
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.extraLarge * 5
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Appearance.spacing.small

                    StyledText {
                        text: qsTr("Wallpaper missing?")
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.extraLarge * 2
                        font.bold: true
                    }

                    StyledRect {
                        implicitWidth: selectWallText.implicitWidth + Appearance.padding.large * 2
                        implicitHeight: selectWallText.implicitHeight + Appearance.padding.small * 2

                        radius: Appearance.rounding.full
                        color: Colours.palette.m3primary

                        FileDialog {
                            id: dialog

                            title: qsTr("Select a wallpaper")
                            filterLabel: qsTr("Image & video files")
                            filters: Images.validWallpaperExtensions
                            onAccepted: path => Wallpapers.setWallpaper(path)
                        }

                        StateLayer {
                            radius: parent.radius
                            color: Colours.palette.m3onPrimary

                            function onClicked(): void {
                                dialog.open();
                            }
                        }

                        StyledText {
                            id: selectWallText

                            anchors.centerIn: parent

                            text: qsTr("Set it now!")
                            color: Colours.palette.m3onPrimary
                            font.pointSize: Appearance.font.size.large
                        }
                    }
                }
            }
        }
    }

    // ── Video wallpaper (mp4/mkv/webm/avi/mov) ──────────────────────────
    Component {
        id: videoComp

        Item {
            id: vidRoot

            property string path
            readonly property bool isReady: player.mediaStatus === MediaPlayer.LoadedMedia || player.mediaStatus === MediaPlayer.BufferedMedia || player.mediaStatus === MediaPlayer.BufferingMedia || player.playbackState === MediaPlayer.PlayingState || player.playbackState === MediaPlayer.PausedState
            anchors.fill: parent
            opacity: 0

            onIsReadyChanged: {
                if (isReady && opacity === 0)
                    fadeInVid.start();
            }

            MediaPlayer {
                id: player

                source: vidRoot.path ? `file://${vidRoot.path}` : ""
                videoOutput: videoOutput
                audioOutput: null
                loops: MediaPlayer.Infinite

                readonly property bool isCovered: {
                    try {
                        if (!Config.background.video.enabled)
                            return false;

                        if (Config.background.video.pauseOnGameMode && GameMode.enabled)
                            return true;

                        if (Config.background.video.batteryLimitEnabled && Config.background.video.batteryLimit > 0 && UPower.displayDevice && UPower.displayDevice.isPresent && UPower.displayDevice.isLaptopBattery) {
                            if (UPower.displayDevice.state === UPowerDeviceState.Discharging && (UPower.displayDevice.percentage * 100) <= Config.background.video.batteryLimit)
                                return true;
                        }

                        if (Config.background.video.pauseOnFullscreen && Hypr.activeToplevel && Hypr.activeToplevel.lastIpcObject && Hypr.activeToplevel.lastIpcObject.fullscreen) {
                            const winClass = (Hypr.activeToplevel.lastIpcObject.class || "").toLowerCase();
                            const browsers = ["firefox", "brave", "chromium", "chrome", "zen", "thorium", "vivaldi", "opera", "floorp", "waterfox", "librewolf", "edge"];
                            if (browsers.some(b => winClass.includes(b)))
                                return false;
                            return true;
                        }

                        return false;
                    } catch (e) {
                        return false;
                    }
                }

                onIsCoveredChanged: {
                    if (isCovered)
                        player.pause();
                    else if (root.current === vidRoot)
                        player.play();
                }

                onErrorOccurred: (error, errorString) => {
                    if (error !== MediaPlayer.NoError && vidRoot.path) {
                        const p = vidRoot.path;
                        vidRoot.path = "";
                        Qt.callLater(() => {
                            vidRoot.path = p;
                            if (!player.isCovered)
                                player.play();
                        });
                    }
                }

                Component.onCompleted: {
                    play();
                    if (isCovered) {
                        Qt.callLater(() => {
                            if (isCovered)
                                pause();
                        });
                    }
                }

                onPlaybackStateChanged: {
                    if (playbackState === MediaPlayer.PlayingState)
                        fadeInVid.start();
                }

                onMediaStatusChanged: {
                    if (mediaStatus === MediaPlayer.LoadedMedia || mediaStatus === MediaPlayer.BufferedMedia)
                        fadeInVid.start();
                }
            }

            VideoOutput {
                id: videoOutput

                anchors.fill: parent
                fillMode: VideoOutput.PreserveAspectCrop
            }

            NumberAnimation {
                id: fadeInVid

                target: vidRoot
                property: "opacity"
                duration: Appearance.anim.durations.extraLarge
                from: 0
                to: 1
            }

            Timer {
                running: root.current !== vidRoot && root.current?.isReady
                interval: fadeInVid.duration || 500
                onTriggered: {
                    player.stop();
                    player.source = "";
                    vidRoot.destroy();
                }
            }
        }
    }

    // ── Static image wallpaper ──────────────────────────────────────────
    Component {
        id: imgComp

        CachingImage {
            id: img

            property bool isReady: status === Image.Ready

            anchors.fill: parent
            opacity: 0

            onStatusChanged: {
                if (status === Image.Ready)
                    fadeInImg.start();
            }

            Anim on opacity {
                id: fadeInImg

                running: false
                from: 0
                to: 1
            }

            Timer {
                running: root.current !== img && root.current?.isReady
                interval: fadeInImg.duration || 500
                onTriggered: {
                    img.source = "";
                    img.destroy();
                }
            }
        }
    }
}
