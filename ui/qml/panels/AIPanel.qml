// VisionCast-AI — Licence officielle Prestige Technologie Company,
// développée par Glody Dimputu Ngola.
//
// AIPanel.qml — AI and automation features panel.
//               Face recognition, talent database, and auto-overlay rules.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Rectangle {
    id: root
    color: "#0D1117"

    property bool faceRecognitionEnabled: true
    property bool autoOverlayEnabled: true

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

            // ── Face Recognition Section ──────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: faceContent.height + 32

                ColumnLayout {
                    id: faceContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "🔍"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Face Recognition"
                            color: "#E6EDF3"
                            font.pixelSize: 15
                            font.weight: Font.Bold
                        }

                        Item { Layout.fillWidth: true }

                        // Toggle switch
                        Switch {
                            id: faceToggle
                            checked: root.faceRecognitionEnabled
                            onCheckedChanged: root.faceRecognitionEnabled = checked
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#30363D"
                    }

                    Text {
                        text: "Automatically identify talents in the video feed using AI-powered face recognition."
                        color: "#8B949E"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    // Recognition stats
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 3
                        rowSpacing: 8
                        columnSpacing: 16
                        visible: root.faceRecognitionEnabled

                        Text { text: "Faces Detected"; color: "#8B949E"; font.pixelSize: 11 }
                        Text { text: "Identified"; color: "#8B949E"; font.pixelSize: 11 }
                        Text { text: "Confidence"; color: "#8B949E"; font.pixelSize: 11 }

                        Text { text: "2"; color: "#E6EDF3"; font.pixelSize: 14; font.weight: Font.DemiBold }
                        Text { text: "1"; color: "#3FB950"; font.pixelSize: 14; font.weight: Font.DemiBold }
                        Text { text: "94%"; color: "#58A6FF"; font.pixelSize: 14; font.weight: Font.DemiBold }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        VCButton {
                            text: "Configure Recognition"
                            variant: "default"
                            onClicked: bridge.openFaceRecognitionSettings()
                        }

                        VCButton {
                            text: "AI Diagnostics"
                            variant: "default"
                            onClicked: bridge.openAiDiagnostics()
                        }
                    }
                }
            }

            // ── Talent Database Section ───────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: talentContent.height + 32

                ColumnLayout {
                    id: talentContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "👤"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Talent Database"
                            color: "#E6EDF3"
                            font.pixelSize: 15
                            font.weight: Font.Bold
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            width: countText.implicitWidth + 16
                            height: 24
                            radius: 12
                            color: "#1F6FEB"
                            opacity: 0.2
                            border.color: "#1F6FEB"
                            border.width: 1

                            Text {
                                id: countText
                                anchors.centerIn: parent
                                text: "12 talents"
                                color: "#58A6FF"
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

                    Text {
                        text: "Manage your talent profiles for automatic recognition and overlay display."
                        color: "#8B949E"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        VCButton {
                            text: "Open Talent Database"
                            variant: "primary"
                            onClicked: bridge.openTalentDatabase()
                        }

                        VCButton {
                            text: "Import Talents"
                            variant: "default"
                            onClicked: console.log("Import talents")
                        }
                    }
                }
            }

            // ── Auto-Overlay Rules Section ────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: overlayContent.height + 32

                ColumnLayout {
                    id: overlayContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "🎯"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Auto-Overlay Rules"
                            color: "#E6EDF3"
                            font.pixelSize: 15
                            font.weight: Font.Bold
                        }

                        Item { Layout.fillWidth: true }

                        Switch {
                            id: autoOverlayToggle
                            checked: root.autoOverlayEnabled
                            onCheckedChanged: root.autoOverlayEnabled = checked
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#30363D"
                    }

                    Text {
                        text: "Automatically display lower-thirds when recognized talents appear on screen."
                        color: "#8B949E"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    // Rule settings
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 12
                        columnSpacing: 16
                        visible: root.autoOverlayEnabled

                        Text { text: "Display Delay"; color: "#8B949E"; font.pixelSize: 12 }
                        SpinBox {
                            from: 0
                            to: 5000
                            stepSize: 100
                            value: 500
                            editable: true
                        }

                        Text { text: "Display Duration"; color: "#8B949E"; font.pixelSize: 12 }
                        SpinBox {
                            from: 1000
                            to: 30000
                            stepSize: 1000
                            value: 5000
                            editable: true
                        }

                        Text { text: "Min. Confidence"; color: "#8B949E"; font.pixelSize: 12 }
                        SpinBox {
                            from: 50
                            to: 100
                            stepSize: 5
                            value: 80
                            editable: true
                        }
                    }

                    VCButton {
                        text: "Configure Auto-Overlay Rules"
                        variant: "default"
                        onClicked: bridge.openAutoOverlayRules()
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
