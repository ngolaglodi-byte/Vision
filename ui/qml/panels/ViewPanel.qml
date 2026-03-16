// VisionCast-AI — Licence officielle Prestige Technologie Company,
// développée par Glody Dimputu Ngola.
//
// ViewPanel.qml — View and layout configuration panel.
//                 Panel visibility, layout presets, and display options.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Rectangle {
    id: root
    color: "#0D1117"

    property bool showMonitoring: true
    property bool showBottomBar: true
    property string currentTheme: "Dark"

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

            // ── Panel Visibility Section ──────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: visibilityContent.height + 32

                ColumnLayout {
                    id: visibilityContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "👁"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Panel Visibility"
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

                    // Panel toggles
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        // Monitoring panel
                        Rectangle {
                            Layout.fillWidth: true
                            height: 48
                            radius: 6
                            color: "#161B22"
                            border.color: "#30363D"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 12

                                Text {
                                    text: "📊"
                                    font.pixelSize: 16
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: "Monitoring Panel"
                                        color: "#E6EDF3"
                                        font.pixelSize: 13
                                    }

                                    Text {
                                        text: "System metrics and status bar"
                                        color: "#8B949E"
                                        font.pixelSize: 11
                                    }
                                }

                                Switch {
                                    checked: root.showMonitoring
                                    onCheckedChanged: root.showMonitoring = checked
                                }
                            }
                        }

                        // Bottom bar
                        Rectangle {
                            Layout.fillWidth: true
                            height: 48
                            radius: 6
                            color: "#161B22"
                            border.color: "#30363D"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 12

                                Text {
                                    text: "📐"
                                    font.pixelSize: 16
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: "Bottom Bar"
                                        color: "#E6EDF3"
                                        font.pixelSize: 13
                                    }

                                    Text {
                                        text: "Multi-stream and output controls"
                                        color: "#8B949E"
                                        font.pixelSize: 11
                                    }
                                }

                                Switch {
                                    checked: root.showBottomBar
                                    onCheckedChanged: root.showBottomBar = checked
                                }
                            }
                        }
                    }
                }
            }

            // ── Theme Section ─────────────────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: themeContent.height + 32

                ColumnLayout {
                    id: themeContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "🎨"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Theme"
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

                    // Theme selection
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 12
                        columnSpacing: 12

                        Repeater {
                            model: [
                                { name: "Dark", color: "#0D1117", accent: "#1F6FEB" },
                                { name: "Light", color: "#F6F8FA", accent: "#0969DA" },
                                { name: "Ocean", color: "#0F172A", accent: "#38BDF8" },
                                { name: "Prestige", color: "#1A1A2E", accent: "#A855F7" }
                            ]

                            Rectangle {
                                Layout.fillWidth: true
                                height: 64
                                radius: 8
                                color: modelData.color
                                border.color: root.currentTheme === modelData.name ? modelData.accent : "#30363D"
                                border.width: root.currentTheme === modelData.name ? 2 : 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    // Accent color preview
                                    Rectangle {
                                        width: 24
                                        height: 24
                                        radius: 12
                                        color: modelData.accent
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Text {
                                            text: modelData.name
                                            color: modelData.name === "Light" ? "#24292F" : "#E6EDF3"
                                            font.pixelSize: 13
                                            font.weight: Font.DemiBold
                                        }

                                        Text {
                                            text: root.currentTheme === modelData.name ? "Active" : "Click to apply"
                                            color: modelData.name === "Light" ? "#57606A" : "#8B949E"
                                            font.pixelSize: 11
                                        }
                                    }

                                    // Check mark for active theme
                                    Rectangle {
                                        visible: root.currentTheme === modelData.name
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: modelData.accent

                                        Text {
                                            anchors.centerIn: parent
                                            text: "✓"
                                            color: "#FFFFFF"
                                            font.pixelSize: 12
                                            font.weight: Font.Bold
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        // Only call setTheme if the theme actually changes
                                        if (root.currentTheme !== modelData.name) {
                                            root.currentTheme = modelData.name
                                            bridge.setTheme(modelData.name)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── Layout Presets Section ────────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: layoutContent.height + 32

                ColumnLayout {
                    id: layoutContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "📐"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Layout Presets"
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
                        text: "Choose a predefined layout or create your own."
                        color: "#8B949E"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 12

                        Repeater {
                            model: ["Default", "Compact", "Wide Preview", "Production"]

                            VCButton {
                                text: modelData
                                variant: modelData === "Default" ? "primary" : "default"
                                onClicked: console.log("Apply layout:", modelData)
                            }
                        }
                    }
                }
            }

            // ── Display Options Section ───────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: displayContent.height + 32

                ColumnLayout {
                    id: displayContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "🖥️"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Display Options"
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

                        Text { text: "Preview Quality"; color: "#8B949E"; font.pixelSize: 12 }
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["High", "Medium", "Low", "Auto"]
                            currentIndex: 0
                        }

                        Text { text: "UI Scale"; color: "#8B949E"; font.pixelSize: 12 }
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["100%", "125%", "150%", "175%", "200%"]
                            currentIndex: 0
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
