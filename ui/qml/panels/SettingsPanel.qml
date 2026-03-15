// VisionCast-AI — Licence officielle Prestige Technologie Company,
// développée par Glody Dimputu Ngola.
//
// SettingsPanel.qml — Application settings panel.
//                      Theme, colors, broadcast defaults, and preferences.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Rectangle {
    id: root
    color: "#161B22"

    // ── Header ─────────────────────────────────────────────────────
    Rectangle {
        id: hdr
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 44
        color: "#1C2128"

        Text {
            text: "SETTINGS"
            color: "#8B949E"
            font.pixelSize: 11
            font.weight: Font.DemiBold
            font.letterSpacing: 1.0
            font.family: "Segoe UI, Inter, Helvetica Neue, Arial"
            anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: "#30363D"
        }
    }

    // ── Settings Content ───────────────────────────────────────────
    Flickable {
        anchors {
            top: hdr.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: 12
        }
        contentHeight: settingsColumn.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            width: 4
        }

        ColumnLayout {
            id: settingsColumn
            width: parent.width
            spacing: 16

            // ── Appearance Section ─────────────────────────────────
            SettingsSection {
                title: "APPEARANCE"
                icon: "🎨"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    // Theme selection
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            text: "Theme"
                            color: "#8B949E"
                            font.pixelSize: 12
                            Layout.preferredWidth: 100
                        }

                        ComboBox {
                            id: themeCombo
                            Layout.fillWidth: true
                            model: ["Dark", "Light", "Ocean", "Prestige"]
                            currentIndex: 0
                            onCurrentIndexChanged: bridge.setTheme(themeCombo.model[currentIndex])
                        }
                    }

                    // Accent color
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            text: "Accent Color"
                            color: "#8B949E"
                            font.pixelSize: 12
                            Layout.preferredWidth: 100
                        }

                        Row {
                            spacing: 6

                            Repeater {
                                model: ["#1F6FEB", "#A855F7", "#3FB950", "#FFD33D", "#F85149"]
                                delegate: Rectangle {
                                    width: 24; height: 24; radius: 12
                                    color: modelData
                                    border.color: root._selectedAccent === modelData ? "#E6EDF3" : "transparent"
                                    border.width: 2

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            root._selectedAccent = modelData
                                            bridge.setAccentColor(modelData)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── Broadcast Defaults ─────────────────────────────────
            SettingsSection {
                title: "BROADCAST DEFAULTS"
                icon: "📡"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    // Default resolution
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            text: "Resolution"
                            color: "#8B949E"
                            font.pixelSize: 12
                            Layout.preferredWidth: 100
                        }

                        ComboBox {
                            id: resolutionCombo
                            Layout.fillWidth: true
                            model: ["1920x1080 (1080p)", "1280x720 (720p)", "3840x2160 (4K)", "2560x1440 (1440p)"]
                            currentIndex: 0
                            onCurrentIndexChanged: bridge.setDefaultResolution(resolutionCombo.model[currentIndex])
                        }
                    }

                    // Default framerate
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            text: "Frame Rate"
                            color: "#8B949E"
                            font.pixelSize: 12
                            Layout.preferredWidth: 100
                        }

                        ComboBox {
                            id: fpsCombo
                            Layout.fillWidth: true
                            model: ["30 fps", "60 fps", "25 fps (PAL)", "29.97 fps (NTSC)", "59.94 fps"]
                            currentIndex: 0
                            onCurrentIndexChanged: bridge.setDefaultFrameRate(fpsCombo.model[currentIndex])
                        }
                    }

                    // Video bitrate
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            text: "Bitrate"
                            color: "#8B949E"
                            font.pixelSize: 12
                            Layout.preferredWidth: 100
                        }

                        ComboBox {
                            id: bitrateCombo
                            Layout.fillWidth: true
                            model: ["6000 kbps", "8000 kbps", "10000 kbps", "15000 kbps", "20000 kbps"]
                            currentIndex: 1
                            onCurrentIndexChanged: bridge.setDefaultBitrate(bitrateCombo.model[currentIndex])
                        }
                    }
                }
            }

            // ── AI Settings ────────────────────────────────────────
            SettingsSection {
                title: "AI & RECOGNITION"
                icon: "🤖"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    // Auto-overlay toggle
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            text: "Auto-Overlay"
                            color: "#8B949E"
                            font.pixelSize: 12
                            Layout.fillWidth: true
                        }

                        VCToggleSwitch {
                            id: autoOverlayToggle
                            checked: true
                            onCheckedChanged: bridge.setAutoOverlayEnabled(checked)
                        }
                    }

                    // Recognition confidence threshold
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            text: "Min Confidence"
                            color: "#8B949E"
                            font.pixelSize: 12
                            Layout.preferredWidth: 100
                        }

                        Slider {
                            id: confidenceSlider
                            Layout.fillWidth: true
                            from: 0.5
                            to: 0.99
                            value: 0.85
                            onValueChanged: bridge.setMinConfidence(value)
                        }

                        Text {
                            text: Math.round(confidenceSlider.value * 100) + "%"
                            color: "#58A6FF"
                            font.pixelSize: 10
                            font.family: "JetBrains Mono, Cascadia Code, monospace"
                            Layout.preferredWidth: 35
                        }
                    }
                }
            }

            // ── Performance ────────────────────────────────────────
            SettingsSection {
                title: "PERFORMANCE"
                icon: "⚡"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    // Hardware acceleration
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            text: "Hardware Accel"
                            color: "#8B949E"
                            font.pixelSize: 12
                            Layout.fillWidth: true
                        }

                        VCToggleSwitch {
                            id: hwAccelToggle
                            checked: true
                            onCheckedChanged: bridge.setHardwareAcceleration(checked)
                        }
                    }

                    // Preview quality
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            text: "Preview Quality"
                            color: "#8B949E"
                            font.pixelSize: 12
                            Layout.preferredWidth: 100
                        }

                        ComboBox {
                            id: previewQualityCombo
                            Layout.fillWidth: true
                            model: ["Low (Fast)", "Medium", "High (Full)", "Auto"]
                            currentIndex: 3
                            onCurrentIndexChanged: bridge.setPreviewQuality(previewQualityCombo.model[currentIndex])
                        }
                    }
                }
            }

            // ── Save / Reset ───────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                VCButton {
                    text: "Save Settings"
                    variant: "primary"
                    Layout.fillWidth: true
                    onClicked: bridge.saveSettings()
                }

                VCButton {
                    text: "Reset to Defaults"
                    variant: "default"
                    Layout.preferredWidth: 120
                    onClicked: bridge.resetSettings()
                }
            }
        }
    }

    // ── Internal state ─────────────────────────────────────────────
    property string _selectedAccent: "#1F6FEB"

    // ── SettingsSection component ──────────────────────────────────
    component SettingsSection: Rectangle {
        id: section
        property string title: ""
        property string icon: ""

        Layout.fillWidth: true
        implicitHeight: sectionHeader.height + sectionContent.height
        radius: 8
        color: "#21262D"
        border.color: "#30363D"
        border.width: 1

        // Section header
        Rectangle {
            id: sectionHeader
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 36
            color: "#1C2128"
            radius: 8

            // Bottom corners should be square
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 8
                color: parent.color
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Text {
                    text: section.icon
                    font.pixelSize: 12
                }

                Text {
                    text: section.title
                    color: "#8B949E"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    font.letterSpacing: 1.0
                    Layout.fillWidth: true
                }
            }
        }

        // Section content
        Item {
            id: sectionContent
            anchors.top: sectionHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 100
        }
    }
}
