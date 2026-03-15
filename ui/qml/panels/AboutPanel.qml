// VisionCast-AI — Licence officielle Prestige Technologie Company,
// développée par Glody Dimputu Ngola.
//
// AboutPanel.qml — About panel with version, credits, and system info.

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
            text: "ABOUT"
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

    // ── About Content ──────────────────────────────────────────────
    Flickable {
        anchors {
            top: hdr.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: 12
        }
        contentHeight: aboutColumn.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            width: 4
        }

        ColumnLayout {
            id: aboutColumn
            width: parent.width
            spacing: 16

            // ── Logo and Title ─────────────────────────────────────
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 100

                Column {
                    anchors.centerIn: parent
                    spacing: 12

                    // VisionCast logo
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 56; height: 56; radius: 12
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#1F6FEB" }
                            GradientStop { position: 1.0; color: "#A855F7" }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "VC"
                            color: "#FFFFFF"
                            font.pixelSize: 20
                            font.weight: Font.Bold
                        }
                    }

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 4

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "VisionCast-AI"
                            color: "#E6EDF3"
                            font.pixelSize: 16
                            font.weight: Font.Bold
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Professional Broadcast Control Room"
                            color: "#8B949E"
                            font.pixelSize: 11
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#30363D" }

            // ── Version Info ───────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 70
                radius: 8
                color: "#21262D"
                border.color: "#30363D"
                border.width: 1

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Version 1.0.0"
                        color: "#E6EDF3"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Build: 2024.03.15 • QML Edition"
                        color: "#8B949E"
                        font.pixelSize: 10
                    }

                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 8

                        Rectangle {
                            width: releaseLbl.implicitWidth + 12
                            height: 18
                            radius: 9
                            color: "#3FB95022"
                            border.color: "#3FB950"
                            border.width: 1

                            Text {
                                id: releaseLbl
                                anchors.centerIn: parent
                                text: "STABLE"
                                color: "#3FB950"
                                font.pixelSize: 9
                                font.weight: Font.Bold
                            }
                        }

                        Rectangle {
                            width: qt6Lbl.implicitWidth + 12
                            height: 18
                            radius: 9
                            color: "#1F6FEB22"
                            border.color: "#1F6FEB"
                            border.width: 1

                            Text {
                                id: qt6Lbl
                                anchors.centerIn: parent
                                text: "Qt 6 Compatible"
                                color: "#58A6FF"
                                font.pixelSize: 9
                                font.weight: Font.Bold
                            }
                        }
                    }
                }
            }

            // ── Credits ────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 90
                radius: 8
                color: "#21262D"
                border.color: "#30363D"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Text {
                        text: "CREDITS"
                        color: "#8B949E"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        font.letterSpacing: 1.0
                    }

                    Text {
                        text: "Developed by Glody Dimputu Ngola"
                        color: "#E6EDF3"
                        font.pixelSize: 12
                    }

                    Text {
                        text: "Licence officielle Prestige Technologie Company"
                        color: "#8B949E"
                        font.pixelSize: 10
                    }

                    Text {
                        text: "© 2024 All rights reserved"
                        color: "#484F58"
                        font.pixelSize: 9
                    }
                }
            }

            // ── Features ───────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: featuresList.height + 40
                radius: 8
                color: "#21262D"
                border.color: "#30363D"
                border.width: 1

                Column {
                    id: featuresList
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 12
                    spacing: 6

                    Text {
                        text: "FEATURES"
                        color: "#8B949E"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        font.letterSpacing: 1.0
                    }

                    FeatureItem { icon: "🎥"; text: "Real-time Video Engine" }
                    FeatureItem { icon: "🤖"; text: "AI Face Recognition" }
                    FeatureItem { icon: "🖼️"; text: "Auto-Overlay System" }
                    FeatureItem { icon: "📡"; text: "Multi-Platform Streaming" }
                    FeatureItem { icon: "✨"; text: "Professional Effects Pipeline" }
                    FeatureItem { icon: "📊"; text: "System Monitoring" }
                }
            }

            // ── Links ──────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                VCButton {
                    text: "Documentation"
                    variant: "default"
                    Layout.fillWidth: true
                    onClicked: Qt.openUrlExternally("https://visioncast.prestige.tech/docs")
                }

                VCButton {
                    text: "Support"
                    variant: "default"
                    Layout.fillWidth: true
                    onClicked: Qt.openUrlExternally("https://visioncast.prestige.tech/support")
                }
            }
        }
    }

    // ── FeatureItem component ──────────────────────────────────────
    component FeatureItem: Row {
        property string icon: ""
        property string text: ""
        spacing: 8

        Text {
            text: icon
            font.pixelSize: 12
        }

        Text {
            text: parent.text
            color: "#E6EDF3"
            font.pixelSize: 11
        }
    }
}
