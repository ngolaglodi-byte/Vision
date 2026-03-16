// VisionCast-AI — Licence officielle Prestige Technologie Company,
// développée par Glody Dimputu Ngola.
//
// StreamingPanel.qml — Multi-platform streaming configuration panel.
//                      YouTube, Facebook, Twitch, and RTMP setup.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Rectangle {
    id: root
    color: "#0D1117"

    property bool youtubeConnected: false
    property bool facebookConnected: false
    property bool twitchConnected: false

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

            // ── Platform Connections Section ──────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: platformContent.height + 32

                ColumnLayout {
                    id: platformContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "🌐"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Platform Connections"
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

                    // YouTube
                    Rectangle {
                        Layout.fillWidth: true
                        height: 56
                        radius: 8
                        color: "#161B22"
                        border.color: root.youtubeConnected ? "#3FB950" : "#30363D"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 6
                                color: "#FF0000"

                                Text {
                                    anchors.centerIn: parent
                                    text: "▶"
                                    color: "#FFFFFF"
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: "YouTube"
                                    color: "#E6EDF3"
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    text: root.youtubeConnected ? "Connected" : "Not connected"
                                    color: root.youtubeConnected ? "#3FB950" : "#8B949E"
                                    font.pixelSize: 11
                                }
                            }

                            VCButton {
                                text: root.youtubeConnected ? "Configure" : "Connect"
                                variant: root.youtubeConnected ? "default" : "primary"
                                onClicked: bridge.openYouTubeSetup()
                            }
                        }
                    }

                    // Facebook
                    Rectangle {
                        Layout.fillWidth: true
                        height: 56
                        radius: 8
                        color: "#161B22"
                        border.color: root.facebookConnected ? "#3FB950" : "#30363D"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 6
                                color: "#1877F2"

                                Text {
                                    anchors.centerIn: parent
                                    text: "f"
                                    color: "#FFFFFF"
                                    font.pixelSize: 18
                                    font.weight: Font.Bold
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: "Facebook"
                                    color: "#E6EDF3"
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    text: root.facebookConnected ? "Connected" : "Not connected"
                                    color: root.facebookConnected ? "#3FB950" : "#8B949E"
                                    font.pixelSize: 11
                                }
                            }

                            VCButton {
                                text: root.facebookConnected ? "Configure" : "Connect"
                                variant: root.facebookConnected ? "default" : "primary"
                                onClicked: bridge.openFacebookSetup()
                            }
                        }
                    }

                    // Twitch
                    Rectangle {
                        Layout.fillWidth: true
                        height: 56
                        radius: 8
                        color: "#161B22"
                        border.color: root.twitchConnected ? "#3FB950" : "#30363D"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 6
                                color: "#9146FF"

                                Text {
                                    anchors.centerIn: parent
                                    text: "📺"
                                    font.pixelSize: 14
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: "Twitch"
                                    color: "#E6EDF3"
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    text: root.twitchConnected ? "Connected" : "Not connected"
                                    color: root.twitchConnected ? "#3FB950" : "#8B949E"
                                    font.pixelSize: 11
                                }
                            }

                            VCButton {
                                text: root.twitchConnected ? "Configure" : "Connect"
                                variant: root.twitchConnected ? "default" : "primary"
                                onClicked: bridge.openTwitchSetup()
                            }
                        }
                    }
                }
            }

            // ── RTMP Profiles Section ─────────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: rtmpContent.height + 32

                ColumnLayout {
                    id: rtmpContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "📡"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "RTMP Profiles"
                            color: "#E6EDF3"
                            font.pixelSize: 15
                            font.weight: Font.Bold
                        }

                        Item { Layout.fillWidth: true }

                        VCButton {
                            text: "Add Profile"
                            variant: "default"
                            onClicked: console.log("Add RTMP profile")
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#30363D"
                    }

                    Text {
                        text: "Custom RTMP destinations for streaming to any server."
                        color: "#8B949E"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    VCButton {
                        text: "Manage RTMP Profiles"
                        variant: "default"
                        onClicked: bridge.openRtmpProfiles()
                    }
                }
            }

            // ── Multi-Stream Presets Section ──────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: multiStreamContent.height + 32

                ColumnLayout {
                    id: multiStreamContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "🔄"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Multi-Stream Presets"
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

                    Text {
                        text: "Stream simultaneously to multiple platforms with preset configurations."
                        color: "#8B949E"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    VCButton {
                        text: "Configure Multi-Stream Presets"
                        variant: "primary"
                        onClicked: bridge.openMultiStreamPresets()
                    }
                }
            }

            // ── Encoder Settings Section ──────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: encoderContent.height + 32

                ColumnLayout {
                    id: encoderContent
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
                            text: "Encoder Settings"
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

                        Text { text: "Bitrate"; color: "#8B949E"; font.pixelSize: 12 }
                        SpinBox {
                            from: 1000
                            to: 50000
                            stepSize: 500
                            value: 6000
                            editable: true
                        }

                        Text { text: "Keyframe Interval"; color: "#8B949E"; font.pixelSize: 12 }
                        SpinBox {
                            from: 1
                            to: 10
                            stepSize: 1
                            value: 2
                            editable: true
                        }

                        Text { text: "Audio Bitrate"; color: "#8B949E"; font.pixelSize: 12 }
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["128 kbps", "160 kbps", "192 kbps", "256 kbps", "320 kbps"]
                            currentIndex: 2
                        }
                    }

                    VCButton {
                        text: "Advanced Encoder Settings"
                        variant: "default"
                        onClicked: bridge.openEncoderSettings()
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
