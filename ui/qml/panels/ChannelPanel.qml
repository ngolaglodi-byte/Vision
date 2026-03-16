// VisionCast-AI — Licence officielle Prestige Technologie Company,
// développée par Glody Dimputu Ngola.
//
// ChannelPanel.qml — Channel profile management panel.
//                    Load, save, and manage broadcast channel configurations.

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

            // ── Channel Profile Section ───────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: profileContent.height + 32

                ColumnLayout {
                    id: profileContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "📺"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Channel Profile"
                            color: "#E6EDF3"
                            font.pixelSize: 15
                            font.weight: Font.Bold
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            width: statusText.implicitWidth + 16
                            height: 24
                            radius: 12
                            color: "#238636"
                            opacity: 0.2
                            border.color: "#3FB950"
                            border.width: 1

                            Text {
                                id: statusText
                                anchors.centerIn: parent
                                text: "Active"
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
                        rowSpacing: 12
                        columnSpacing: 16

                        Text {
                            text: "Profile Name"
                            color: "#8B949E"
                            font.pixelSize: 12
                        }

                        TextField {
                            id: profileNameField
                            Layout.fillWidth: true
                            placeholderText: "Enter profile name"
                            placeholderTextColor: "#484F58"
                            color: "#E6EDF3"
                            font.pixelSize: 12
                            background: Rectangle {
                                radius: 6
                                color: profileNameField.activeFocus ? "#1C2128" : "#161B22"
                                border.color: profileNameField.activeFocus ? "#1F6FEB" : "#30363D"
                                border.width: 1
                            }
                        }

                        Text {
                            text: "Channel Name"
                            color: "#8B949E"
                            font.pixelSize: 12
                        }

                        TextField {
                            id: channelNameField
                            Layout.fillWidth: true
                            placeholderText: "Your channel name"
                            placeholderTextColor: "#484F58"
                            color: "#E6EDF3"
                            font.pixelSize: 12
                            background: Rectangle {
                                radius: 6
                                color: channelNameField.activeFocus ? "#1C2128" : "#161B22"
                                border.color: channelNameField.activeFocus ? "#1F6FEB" : "#30363D"
                                border.width: 1
                            }
                        }

                        Text {
                            text: "Description"
                            color: "#8B949E"
                            font.pixelSize: 12
                        }

                        TextArea {
                            id: descriptionField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 60
                            placeholderText: "Channel description"
                            placeholderTextColor: "#484F58"
                            color: "#E6EDF3"
                            font.pixelSize: 12
                            wrapMode: TextArea.Wrap
                            background: Rectangle {
                                radius: 6
                                color: descriptionField.activeFocus ? "#1C2128" : "#161B22"
                                border.color: descriptionField.activeFocus ? "#1F6FEB" : "#30363D"
                                border.width: 1
                            }
                        }
                    }
                }
            }

            // ── Profile Actions Section ───────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: actionsContent.height + 32

                ColumnLayout {
                    id: actionsContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "📁"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Profile Actions"
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

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        VCButton {
                            text: "New Profile"
                            variant: "default"
                            onClicked: bridge.newChannelProfile()
                        }

                        VCButton {
                            text: "Load Profile"
                            variant: "default"
                            onClicked: bridge.loadChannelProfile()
                        }

                        VCButton {
                            text: "Save Profile"
                            variant: "primary"
                            onClicked: bridge.saveChannelProfile()
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        VCButton {
                            text: "Export Settings"
                            variant: "default"
                            onClicked: bridge.exportProject()
                        }

                        VCButton {
                            text: "Import Settings"
                            variant: "default"
                            onClicked: bridge.importProject()
                        }
                    }
                }
            }

            // ── Recent Profiles Section ───────────────────────────────
            VCCard {
                Layout.fillWidth: true
                Layout.preferredHeight: recentContent.height + 32

                ColumnLayout {
                    id: recentContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "🕐"
                            font.pixelSize: 18
                        }

                        Text {
                            text: "Recent Profiles"
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

                    // Recent profiles list (placeholder)
                    Repeater {
                        model: ["Default Profile", "Live Event Config", "Studio Setup"]

                        Rectangle {
                            Layout.fillWidth: true
                            height: 44
                            radius: 6
                            color: recentItemArea.containsMouse ? "#21262D" : "#161B22"
                            border.color: recentItemArea.containsMouse ? "#30363D" : "transparent"
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 100 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 10

                                Text {
                                    text: "📄"
                                    font.pixelSize: 14
                                }

                                Text {
                                    text: modelData
                                    color: "#E6EDF3"
                                    font.pixelSize: 13
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: "→"
                                    color: "#8B949E"
                                    font.pixelSize: 14
                                    visible: recentItemArea.containsMouse
                                }
                            }

                            MouseArea {
                                id: recentItemArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: console.log("Load profile:", modelData)
                            }
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
