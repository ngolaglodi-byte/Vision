// VisionCast-AI — Licence officielle Prestige Technologie Company,
// développée par Glody Dimputu Ngola.
//
// ToolsPanel.qml — System tools and diagnostics panel.
//                  System monitor, network diagnostics, logs, and backup.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Rectangle {
    id: root
    color: "#0D1117"

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

            // ── System Monitor Section ────────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: monitorContent.height + 32

                ColumnLayout {
                    id: monitorContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "📊"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "System Monitor"
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

                    // System stats
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 4
                        rowSpacing: 12
                        columnSpacing: 24

                        // CPU
                        ColumnLayout {
                            spacing: 4

                            Text {
                                text: "CPU"
                                color: "#8B949E"
                                font.pixelSize: 11
                            }

                            Text {
                                text: "45%"
                                color: "#3FB950"
                                font.pixelSize: 20
                                font.weight: Font.Bold
                            }

                            Rectangle {
                                Layout.preferredWidth: 60
                                height: 4
                                radius: 2
                                color: "#21262D"

                                Rectangle {
                                    width: parent.width * 0.45
                                    height: parent.height
                                    radius: 2
                                    color: "#3FB950"
                                }
                            }
                        }

                        // Memory
                        ColumnLayout {
                            spacing: 4

                            Text {
                                text: "Memory"
                                color: "#8B949E"
                                font.pixelSize: 11
                            }

                            Text {
                                text: "62%"
                                color: "#58A6FF"
                                font.pixelSize: 20
                                font.weight: Font.Bold
                            }

                            Rectangle {
                                Layout.preferredWidth: 60
                                height: 4
                                radius: 2
                                color: "#21262D"

                                Rectangle {
                                    width: parent.width * 0.62
                                    height: parent.height
                                    radius: 2
                                    color: "#58A6FF"
                                }
                            }
                        }

                        // GPU
                        ColumnLayout {
                            spacing: 4

                            Text {
                                text: "GPU"
                                color: "#8B949E"
                                font.pixelSize: 11
                            }

                            Text {
                                text: "28%"
                                color: "#A855F7"
                                font.pixelSize: 20
                                font.weight: Font.Bold
                            }

                            Rectangle {
                                Layout.preferredWidth: 60
                                height: 4
                                radius: 2
                                color: "#21262D"

                                Rectangle {
                                    width: parent.width * 0.28
                                    height: parent.height
                                    radius: 2
                                    color: "#A855F7"
                                }
                            }
                        }

                        // Disk
                        ColumnLayout {
                            spacing: 4

                            Text {
                                text: "Disk"
                                color: "#8B949E"
                                font.pixelSize: 11
                            }

                            Text {
                                text: "15%"
                                color: "#FFD33D"
                                font.pixelSize: 20
                                font.weight: Font.Bold
                            }

                            Rectangle {
                                Layout.preferredWidth: 60
                                height: 4
                                radius: 2
                                color: "#21262D"

                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    radius: 2
                                    color: "#FFD33D"
                                }
                            }
                        }
                    }

                    VCButton {
                        text: "Open System Monitor"
                        variant: "default"
                        onClicked: bridge.openSystemMonitor()
                    }
                }
            }

            // ── Network Diagnostics Section ───────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: networkContent.height + 32

                ColumnLayout {
                    id: networkContent
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
                            text: "Network Diagnostics"
                            color: "#E6EDF3"
                            font.pixelSize: 15
                            font.weight: Font.Bold
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            width: statusLabel.implicitWidth + 16
                            height: 24
                            radius: 12
                            color: "#238636"
                            opacity: 0.2
                            border.color: "#3FB950"
                            border.width: 1

                            Text {
                                id: statusLabel
                                anchors.centerIn: parent
                                text: "Connected"
                                color: "#3FB950"
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }
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
                        rowSpacing: 8
                        columnSpacing: 24

                        Text { text: "Upload Speed"; color: "#8B949E"; font.pixelSize: 12 }
                        Text { text: "12.5 Mbps"; color: "#E6EDF3"; font.pixelSize: 12; font.weight: Font.DemiBold }

                        Text { text: "Download Speed"; color: "#8B949E"; font.pixelSize: 12 }
                        Text { text: "48.2 Mbps"; color: "#E6EDF3"; font.pixelSize: 12; font.weight: Font.DemiBold }

                        Text { text: "Latency"; color: "#8B949E"; font.pixelSize: 12 }
                        Text { text: "24 ms"; color: "#E6EDF3"; font.pixelSize: 12; font.weight: Font.DemiBold }

                        Text { text: "Packet Loss"; color: "#8B949E"; font.pixelSize: 12 }
                        Text { text: "0%"; color: "#3FB950"; font.pixelSize: 12; font.weight: Font.DemiBold }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        VCButton {
                            text: "Network Diagnostics"
                            variant: "default"
                            onClicked: bridge.openNetworkDiagnostics()
                        }

                        VCButton {
                            text: "Run Speed Test"
                            variant: "default"
                            onClicked: console.log("Run speed test")
                        }
                    }
                }
            }

            // ── Log Viewer Section ────────────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: logContent.height + 32

                ColumnLayout {
                    id: logContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "📜"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Log Viewer"
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
                        text: "View and export application logs for troubleshooting."
                        color: "#8B949E"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    // Recent log preview
                    Rectangle {
                        Layout.fillWidth: true
                        height: 80
                        radius: 6
                        color: "#161B22"
                        border.color: "#30363D"
                        border.width: 1

                        Flickable {
                            anchors.fill: parent
                            anchors.margins: 8
                            clip: true

                            Column {
                                spacing: 2

                                Text {
                                    text: "[INFO] Engine started successfully"
                                    color: "#3FB950"
                                    font.pixelSize: 10
                                    font.family: "JetBrains Mono, Cascadia Code, monospace"
                                }

                                Text {
                                    text: "[INFO] Face recognition module loaded"
                                    color: "#58A6FF"
                                    font.pixelSize: 10
                                    font.family: "JetBrains Mono, Cascadia Code, monospace"
                                }

                                Text {
                                    text: "[WARN] GPU acceleration not available"
                                    color: "#FFD33D"
                                    font.pixelSize: 10
                                    font.family: "JetBrains Mono, Cascadia Code, monospace"
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        VCButton {
                            text: "Open Log Viewer"
                            variant: "default"
                            onClicked: bridge.openLogViewer()
                        }

                        VCButton {
                            text: "Export Logs"
                            variant: "default"
                            onClicked: console.log("Export logs")
                        }
                    }
                }
            }

            // ── Backup & Restore Section ──────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: backupContent.height + 32

                ColumnLayout {
                    id: backupContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "💾"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Backup & Restore"
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
                        text: "Backup your settings, profiles, and configurations."
                        color: "#8B949E"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        VCButton {
                            text: "Create Backup"
                            variant: "primary"
                            onClicked: bridge.openBackupRestore()
                        }

                        VCButton {
                            text: "Restore Backup"
                            variant: "default"
                            onClicked: console.log("Restore backup")
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
