// VisionCast-AI — Licence officielle Prestige Technologie Company,
// développée par Glody Dimputu Ngola.
//
// HelpPanel.qml — Help and support panel.
//                 Documentation, shortcuts, and about information.

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

            // ── Documentation Section ─────────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: docsContent.height + 32

                ColumnLayout {
                    id: docsContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "📚"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Documentation"
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
                        text: "Access user manuals, guides, and tutorials."
                        color: "#8B949E"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    // Quick links
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Repeater {
                            model: [
                                { icon: "📖", title: "User Manual", desc: "Complete guide to VisionCast-AI" },
                                { icon: "🎬", title: "Getting Started", desc: "Quick start tutorial" },
                                { icon: "⚙️", title: "Configuration Guide", desc: "Setup and configuration" },
                                { icon: "🤖", title: "AI Features", desc: "Face recognition and automation" }
                            ]

                            Rectangle {
                                Layout.fillWidth: true
                                height: 52
                                radius: 6
                                color: docLinkArea.containsMouse ? "#21262D" : "#161B22"
                                border.color: docLinkArea.containsMouse ? "#30363D" : "transparent"
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 100 } }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Text {
                                        text: modelData.icon
                                        font.pixelSize: 16
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Text {
                                            text: modelData.title
                                            color: "#E6EDF3"
                                            font.pixelSize: 13
                                            font.weight: Font.DemiBold
                                        }

                                        Text {
                                            text: modelData.desc
                                            color: "#8B949E"
                                            font.pixelSize: 11
                                        }
                                    }

                                    Text {
                                        text: "→"
                                        color: "#58A6FF"
                                        font.pixelSize: 14
                                        visible: docLinkArea.containsMouse
                                    }
                                }

                                MouseArea {
                                    id: docLinkArea
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: Qt.openUrlExternally("https://visioncast.prestige.tech/docs")
                                }
                            }
                        }
                    }
                }
            }

            // ── Keyboard Shortcuts Section ────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: shortcutsContent.height + 32

                ColumnLayout {
                    id: shortcutsContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "⌨️"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Keyboard Shortcuts"
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

                    // Essential shortcuts
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 8
                        columnSpacing: 24

                        // Row 1
                        ShortcutItem { shortcut: "F5"; description: "Start Engine" }
                        ShortcutItem { shortcut: "F7"; description: "Go Live" }

                        // Row 2
                        ShortcutItem { shortcut: "F6"; description: "Stop Engine" }
                        ShortcutItem { shortcut: "F8"; description: "Stop Broadcast" }

                        // Row 3
                        ShortcutItem { shortcut: "Space"; description: "Take / Cut" }
                        ShortcutItem { shortcut: "Enter"; description: "Transition" }

                        // Row 4
                        ShortcutItem { shortcut: "Ctrl+S"; description: "Save Project" }
                        ShortcutItem { shortcut: "Ctrl+O"; description: "Open Project" }
                    }

                    VCButton {
                        text: "View All Shortcuts"
                        variant: "default"
                        onClicked: console.log("Show all shortcuts")
                    }
                }
            }

            // ── Support Section ───────────────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: supportContent.height + 32

                ColumnLayout {
                    id: supportContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "💬"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Support"
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
                        text: "Get help and support for VisionCast-AI."
                        color: "#8B949E"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        VCButton {
                            text: "Contact Support"
                            variant: "primary"
                            onClicked: Qt.openUrlExternally("mailto:support@prestige.tech")
                        }

                        VCButton {
                            text: "Report Issue"
                            variant: "default"
                            onClicked: console.log("Report issue")
                        }
                    }
                }
            }

            // ── About Section ─────────────────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: aboutContent.height + 32

                ColumnLayout {
                    id: aboutContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "ℹ️"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "About VisionCast-AI"
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

                    // App info
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16

                        // Logo
                        Rectangle {
                            width: 64
                            height: 64
                            radius: 12
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#1F6FEB" }
                                GradientStop { position: 1.0; color: "#A855F7" }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "VC"
                                color: "#FFFFFF"
                                font.pixelSize: 22
                                font.weight: Font.Bold
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: "VisionCast-AI"
                                color: "#E6EDF3"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                            }

                            Text {
                                text: "Professional Broadcast Control Room"
                                color: "#8B949E"
                                font.pixelSize: 12
                            }

                            Text {
                                text: "Version 1.0.0"
                                color: "#484F58"
                                font.pixelSize: 11
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#30363D"
                    }

                    Text {
                        text: "Licence officielle Prestige Technologie Company\ndéveloppée par Glody Dimputu Ngola"
                        color: "#8B949E"
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                    }

                    VCButton {
                        text: "Check for Updates"
                        variant: "default"
                        onClicked: console.log("Check for updates")
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

    // ── ShortcutItem component ────────────────────────────────────────
    component ShortcutItem: RowLayout {
        property string shortcut: ""
        property string description: ""
        spacing: 8
        Layout.fillWidth: true

        Rectangle {
            width: 60
            height: 24
            radius: 4
            color: "#21262D"
            border.color: "#30363D"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: shortcut
                color: "#58A6FF"
                font.pixelSize: 10
                font.family: "JetBrains Mono, Cascadia Code, monospace"
                font.weight: Font.Medium
            }
        }

        Text {
            text: description
            color: "#E6EDF3"
            font.pixelSize: 12
            Layout.fillWidth: true
        }
    }
}
