// VisionCast-AI — TalentPanel (Premium VisionCast Edition)
// Design premium sans modifier la logique interne.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#0D1117"
    radius: 10
    border.color: "#30363D"
    border.width: 1
    anchors.fill: parent

    // Gradient Prestige subtil
    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#0D1117" }
                GradientStop { position: 1.0; color: "#111827" }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // ---- Header ----
        Text {
            text: "Talent Details"
            color: "#E6EDF3"
            font.pixelSize: 16
            font.weight: Font.Bold
        }

        Rectangle { height: 1; color: "#30363D"; Layout.fillWidth: true }

        // ---- Name ----
        ColumnLayout {
            spacing: 4
            Layout.fillWidth: true

            Text {
                text: "Name"
                color: "#8B949E"
                font.pixelSize: 12
            }

            TextField {
                id: nameField
                text: root.talentName
                placeholderText: "Enter name"
                color: "#E6EDF3"
                Layout.fillWidth: true
                background: Rectangle {
                    radius: 6
                    color: "#161B22"
                    border.color: "#30363D"
                }
                onTextChanged: root.talentName = text
            }
        }

        // ---- Role ----
        ColumnLayout {
            spacing: 4
            Layout.fillWidth: true

            Text {
                text: "Role"
                color: "#8B949E"
                font.pixelSize: 12
            }

            TextField {
                id: roleField
                text: root.talentRole
                placeholderText: "Enter role"
                color: "#E6EDF3"
                Layout.fillWidth: true
                background: Rectangle {
                    radius: 6
                    color: "#161B22"
                    border.color: "#30363D"
                }
                onTextChanged: root.talentRole = text
            }
        }

        // ---- Organisation ----
        ColumnLayout {
            spacing: 4
            Layout.fillWidth: true

            Text {
                text: "Organisation"
                color: "#8B949E"
                font.pixelSize: 12
            }

            TextField {
                id: orgField
                text: root.talentOrg
                placeholderText: "Enter organisation"
                color: "#E6EDF3"
                Layout.fillWidth: true
                background: Rectangle {
                    radius: 6
                    color: "#161B22"
                    border.color: "#30363D"
                }
                onTextChanged: root.talentOrg = text
            }
        }

        // ---- Photo URL ----
        ColumnLayout {
            spacing: 4
            Layout.fillWidth: true

            Text {
                text: "Photo URL"
                color: "#8B949E"
                font.pixelSize: 12
            }

            TextField {
                id: photoField
                text: root.talentPhoto
                placeholderText: "https://..."
                color: "#E6EDF3"
                Layout.fillWidth: true
                background: Rectangle {
                    radius: 6
                    color: "#161B22"
                    border.color: "#30363D"
                }
                onTextChanged: root.talentPhoto = text
            }
        }

        Rectangle { height: 1; color: "#30363D"; Layout.fillWidth: true }

        // ---- Buttons ----
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Update button
            Rectangle {
                Layout.fillWidth: true
                height: 36
                radius: 6
                color: "#1F6FEB"
                border.color: "#388BFD"

                Text {
                    anchors.centerIn: parent
                    text: "Update"
                    color: "white"
                    font.pixelSize: 13
                    font.weight: Font.Bold
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.updateTalent()
                }
            }

            // Remove button
            Rectangle {
                width: 100
                height: 36
                radius: 6
                color: "#F85149"
                border.color: "#FF6A67"

                Text {
                    anchors.centerIn: parent
                    text: "Remove"
                    color: "white"
                    font.pixelSize: 13
                    font.weight: Font.Bold
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.removeTalent()
                }
            }
        }
    }

    // ---- Animations ----
    Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
}
