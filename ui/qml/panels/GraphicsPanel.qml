// VisionCast-AI — Licence officielle Prestige Technologie Company,
// développée par Glody Dimputu Ngola.
//
// GraphicsPanel.qml — Graphics and branding panel.
//                     Overlay templates, lower-thirds, and visual effects.

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

            // ── Overlay Templates Section ─────────────────────────────
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
                            text: "🖼️"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Overlay Templates"
                            color: "#E6EDF3"
                            font.pixelSize: 15
                            font.weight: Font.Bold
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            width: templateCountText.implicitWidth + 16
                            height: 24
                            radius: 12
                            color: "#1F6FEB"
                            opacity: 0.2
                            border.color: "#1F6FEB"
                            border.width: 1

                            Text {
                                id: templateCountText
                                anchors.centerIn: parent
                                text: "8 templates"
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
                        text: "Manage and customize your broadcast overlay templates."
                        color: "#8B949E"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        VCButton {
                            text: "Overlay Templates"
                            variant: "primary"
                            onClicked: bridge.openOverlayTemplates()
                        }

                        VCButton {
                            text: "Create New"
                            variant: "default"
                            onClicked: console.log("Create new template")
                        }
                    }
                }
            }

            // ── Lower-Third Editor Section ────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: lowerThirdContent.height + 32

                ColumnLayout {
                    id: lowerThirdContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "📝"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Lower-Third Editor"
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
                        text: "Design and edit lower-third graphics for talent identification."
                        color: "#8B949E"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    // Quick preview
                    Rectangle {
                        Layout.fillWidth: true
                        height: 80
                        radius: 8
                        color: "#161B22"
                        border.color: "#30363D"
                        border.width: 1

                        // Sample lower-third preview
                        Rectangle {
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 16
                            anchors.bottomMargin: 12
                            width: 200
                            height: 50
                            radius: 4
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#1F6FEB" }
                                GradientStop { position: 1.0; color: "#A855F7" }
                            }

                            Column {
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2

                                Text {
                                    text: "John Smith"
                                    color: "#FFFFFF"
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                }

                                Text {
                                    text: "CEO, Prestige Tech"
                                    color: "#FFFFFFCC"
                                    font.pixelSize: 11
                                }
                            }
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 8
                            text: "Preview"
                            color: "#484F58"
                            font.pixelSize: 10
                        }
                    }

                    VCButton {
                        text: "Open Lower-Third Editor"
                        variant: "default"
                        onClicked: bridge.openLowerThirdEditor()
                    }
                }
            }

            // ── Branding Section ──────────────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: brandingContent.height + 32

                ColumnLayout {
                    id: brandingContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "🏷️"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Branding"
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
                        text: "Configure your channel branding, logos, and watermarks."
                        color: "#8B949E"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        VCButton {
                            text: "Branding Settings"
                            variant: "default"
                            onClicked: bridge.openBrandingSettings()
                        }

                        VCButton {
                            text: "Upload Logo"
                            variant: "default"
                            onClicked: console.log("Upload logo")
                        }
                    }
                }
            }

            // ── Effects Pipeline Section ──────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: effectsContent.height + 32

                ColumnLayout {
                    id: effectsContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "✨"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Effects Pipeline"
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
                        text: "Configure video effects, LUTs, and color correction."
                        color: "#8B949E"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 12

                        VCButton {
                            text: "LUT Manager"
                            variant: "default"
                            onClicked: bridge.openLutManager()
                        }

                        VCButton {
                            text: "Effects Pipeline"
                            variant: "default"
                            onClicked: bridge.openEffectsPipeline()
                        }

                        VCButton {
                            text: "Theme Settings"
                            variant: "default"
                            onClicked: console.log("Theme settings")
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
