// VisionCast-AI — Licence officielle Prestige Technologie Company,
// développée par Glody Dimputu Ngola.
//
// BroadcastPanel.qml — Broadcast engine control panel.
//                      Video engine settings, routing, and live controls.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Rectangle {
    id: root
    color: "#0D1117"

    property bool engineRunning: false
    property bool isLive: false

    // ── Scrollable content ─────────────────────────────────────────────
    Flickable {
        id: contentFlickable
        anchors.fill: parent
        contentHeight: contentColumn.height + 32
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            width: 6
        }

        ColumnLayout {
            id: contentColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 16
            spacing: 20

            // ── Engine Status Section ─────────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: statusContent.height + 32

                ColumnLayout {
                    id: statusContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "🎬"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Engine Status"
                            color: "#E6EDF3"
                            font.pixelSize: 15
                            font.weight: Font.Bold
                        }

                        Item { Layout.fillWidth: true }

                        // Engine status indicator
                        Rectangle {
                            width: engineStatusText.implicitWidth + 20
                            height: 28
                            radius: 14
                            color: root.engineRunning ? "#238636" : "#21262D"
                            opacity: root.engineRunning ? 0.3 : 1.0
                            border.color: root.engineRunning ? "#3FB950" : "#30363D"
                            border.width: 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6

                                Rectangle {
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: root.engineRunning ? "#3FB950" : "#484F58"
                                }

                                Text {
                                    id: engineStatusText
                                    text: root.engineRunning ? "Running" : "Stopped"
                                    color: root.engineRunning ? "#3FB950" : "#8B949E"
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#30363D"
                    }

                    // Engine controls
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        VCButton {
                            text: root.engineRunning ? "Stop Engine" : "Start Engine"
                            variant: root.engineRunning ? "danger" : "primary"
                            onClicked: {
                                if (root.engineRunning) {
                                    bridge.stopEngine()
                                } else {
                                    bridge.startEngine()
                                }
                                root.engineRunning = !root.engineRunning
                            }
                        }

                        VCButton {
                            text: "Restart"
                            variant: "default"
                            enabled: root.engineRunning
                            onClicked: {
                                bridge.stopEngine()
                                bridge.startEngine()
                            }
                        }
                    }
                }
            }

            // ── Live Controls Section ─────────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: liveContent.height + 32

                ColumnLayout {
                    id: liveContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "🔴"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Live Controls"
                            color: "#E6EDF3"
                            font.pixelSize: 15
                            font.weight: Font.Bold
                        }

                        Item { Layout.fillWidth: true }

                        // Live status indicator
                        Rectangle {
                            visible: root.isLive
                            width: liveText.implicitWidth + 20
                            height: 28
                            radius: 14
                            color: "#F85149"
                            opacity: 0.3
                            border.color: "#F85149"
                            border.width: 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6

                                Rectangle {
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: "#F85149"

                                    SequentialAnimation on opacity {
                                        loops: Animation.Infinite
                                        running: root.isLive
                                        NumberAnimation { to: 0.3; duration: 500 }
                                        NumberAnimation { to: 1.0; duration: 500 }
                                    }
                                }

                                Text {
                                    id: liveText
                                    text: "LIVE"
                                    color: "#F85149"
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#30363D"
                    }

                    // Live controls
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        VCButton {
                            text: root.isLive ? "Stop Broadcast" : "Go Live"
                            variant: root.isLive ? "danger" : "primary"
                            enabled: root.engineRunning
                            onClicked: {
                                if (root.isLive) {
                                    bridge.stopBroadcast()
                                } else {
                                    bridge.goLive()
                                }
                                root.isLive = !root.isLive
                            }
                        }
                    }

                    // Broadcast stats
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 3
                        rowSpacing: 8
                        columnSpacing: 16
                        visible: root.isLive

                        Text { text: "Duration"; color: "#8B949E"; font.pixelSize: 11 }
                        Text { text: "Viewers"; color: "#8B949E"; font.pixelSize: 11 }
                        Text { text: "Bitrate"; color: "#8B949E"; font.pixelSize: 11 }

                        Text { text: "00:00:00"; color: "#E6EDF3"; font.pixelSize: 14; font.weight: Font.DemiBold }
                        Text { text: "0"; color: "#E6EDF3"; font.pixelSize: 14; font.weight: Font.DemiBold }
                        Text { text: "6000 kbps"; color: "#E6EDF3"; font.pixelSize: 14; font.weight: Font.DemiBold }
                    }
                }
            }

            // ── Video Engine Settings Section ─────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: videoContent.height + 32

                ColumnLayout {
                    id: videoContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "⚙️"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Video Engine Settings"
                            color: "#E6EDF3"
                            font.pixelSize: 15
                            font.weight: Font.Bold
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#30363D"
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 12
                        columnSpacing: 16

                        Text { text: "Resolution"; color: "#8B949E"; font.pixelSize: 12 }
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["1920x1080 (Full HD)", "1280x720 (HD)", "3840x2160 (4K)", "2560x1440 (2K)"]
                            currentIndex: 0
                        }

                        Text { text: "Frame Rate"; color: "#8B949E"; font.pixelSize: 12 }
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["60 fps", "30 fps", "25 fps", "24 fps"]
                            currentIndex: 0
                        }

                        Text { text: "Encoder"; color: "#8B949E"; font.pixelSize: 12 }
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["x264 (CPU)", "NVENC (NVIDIA)", "QuickSync (Intel)", "AMF (AMD)"]
                            currentIndex: 0
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        VCButton {
                            text: "Video Engine Settings"
                            variant: "default"
                            onClicked: bridge.openVideoEngineSettings()
                        }

                        VCButton {
                            text: "Audio Routing"
                            variant: "default"
                            onClicked: bridge.openAudioRoutingSettings()
                        }
                    }
                }
            }

            // ── Input/Output Section ──────────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: ioContent.height + 32

                ColumnLayout {
                    id: ioContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "🔌"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Input/Output Configuration"
                            color: "#E6EDF3"
                            font.pixelSize: 15
                            font.weight: Font.Bold
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#30363D"
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 12

                        VCButton {
                            text: "DeckLink / SDI"
                            variant: "default"
                            onClicked: bridge.openDeckLinkSettings()
                        }

                        VCButton {
                            text: "NDI"
                            variant: "default"
                            onClicked: bridge.openNdiSettings()
                        }

                        VCButton {
                            text: "SRT / RTMP Inputs"
                            variant: "default"
                            onClicked: bridge.openSrtRtmpInputSettings()
                        }

                        VCButton {
                            text: "Output Routing"
                            variant: "default"
                            onClicked: bridge.openOutputRoutingSettings()
                        }
                    }
                }
            }

            // Spacer
            Item {
                Layout.fillWidth: true
                height: 16
            }
        }
    }
}
