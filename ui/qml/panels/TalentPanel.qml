// VisionCast-AI — TalentPanel (Premium VisionCast Edition)
// Design premium avec import photo local (FileDialog) — Qt 6 compatible.
//
// VisionCast-AI — Licence officielle Prestige Technologie Company,
// développée par Glody Dimputu Ngola.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

Rectangle {
    id: root
    color: "#0D1117"
    radius: 8
    border.color: "#30363D"
    border.width: 1
    anchors.fill: parent

    // ── Talent data properties ─────────────────────────────────────
    property string talentId: ""
    property string talentName: ""
    property string talentRole: ""
    property string talentOrg: ""
    property string talentPhoto: ""

    // ── Signals ────────────────────────────────────────────────────
    signal updateTalent()
    signal removeTalent()
    signal addTalent()

    // ── Premium gradient background (Qt 6 compatible) ──────────────
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#0D1117" }
            GradientStop { position: 1.0; color: "#111827" }
        }
        opacity: 0.95
    }

    // ── FileDialog for local photo import ──────────────────────────
    FileDialog {
        id: photoFileDialog
        title: "Select Talent Photo"
        nameFilters: ["Image files (*.jpg *.jpeg *.png *.bmp *.gif)", "All files (*)"]
        selectMultiple: false
        onAccepted: {
            // Convert file URL to local path for display and storage
            var filePath = photoFileDialog.fileUrl.toString()
            // Remove file:// prefix for local path
            if (filePath.startsWith("file:///")) {
                // Windows: file:///C:/... -> C:/...
                filePath = filePath.substring(8)
            } else if (filePath.startsWith("file://")) {
                // Unix: file:///home/... -> /home/...
                filePath = filePath.substring(7)
            }
            root.talentPhoto = filePath
            photoPreview.source = photoFileDialog.fileUrl
        }
    }

    // ── Scrollable content ─────────────────────────────────────────
    Flickable {
        id: contentFlickable
        anchors.fill: parent
        anchors.margins: 12
        contentHeight: contentColumn.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            width: 4
        }

        ColumnLayout {
            id: contentColumn
            width: contentFlickable.width - 8
            spacing: 12

            // ── Header ─────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "👤"
                    font.pixelSize: 18
                }

                Text {
                    text: "Talent Details"
                    color: "#E6EDF3"
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                }
            }

            Rectangle {
                height: 1
                color: "#30363D"
                Layout.fillWidth: true
            }

            // ── Name field ─────────────────────────────────────────
            ColumnLayout {
                spacing: 4
                Layout.fillWidth: true

                Text {
                    text: "Name"
                    color: "#8B949E"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }

                TextField {
                    id: nameField
                    text: root.talentName
                    placeholderText: "Enter talent name"
                    placeholderTextColor: "#484F58"
                    color: "#E6EDF3"
                    font.pixelSize: 12
                    Layout.fillWidth: true
                    leftPadding: 10
                    rightPadding: 10
                    topPadding: 8
                    bottomPadding: 8
                    background: Rectangle {
                        radius: 6
                        color: nameField.activeFocus ? "#1C2128" : "#161B22"
                        border.color: nameField.activeFocus ? "#1F6FEB" : "#30363D"
                        border.width: 1
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                    }
                    onTextChanged: root.talentName = text
                }
            }

            // ── Role field ─────────────────────────────────────────
            ColumnLayout {
                spacing: 4
                Layout.fillWidth: true

                Text {
                    text: "Role"
                    color: "#8B949E"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }

                TextField {
                    id: roleField
                    text: root.talentRole
                    placeholderText: "Enter role (e.g., Presenter)"
                    placeholderTextColor: "#484F58"
                    color: "#E6EDF3"
                    font.pixelSize: 12
                    Layout.fillWidth: true
                    leftPadding: 10
                    rightPadding: 10
                    topPadding: 8
                    bottomPadding: 8
                    background: Rectangle {
                        radius: 6
                        color: roleField.activeFocus ? "#1C2128" : "#161B22"
                        border.color: roleField.activeFocus ? "#1F6FEB" : "#30363D"
                        border.width: 1
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                    }
                    onTextChanged: root.talentRole = text
                }
            }

            // ── Organisation field ─────────────────────────────────
            ColumnLayout {
                spacing: 4
                Layout.fillWidth: true

                Text {
                    text: "Organisation"
                    color: "#8B949E"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }

                TextField {
                    id: orgField
                    text: root.talentOrg
                    placeholderText: "Enter organisation"
                    placeholderTextColor: "#484F58"
                    color: "#E6EDF3"
                    font.pixelSize: 12
                    Layout.fillWidth: true
                    leftPadding: 10
                    rightPadding: 10
                    topPadding: 8
                    bottomPadding: 8
                    background: Rectangle {
                        radius: 6
                        color: orgField.activeFocus ? "#1C2128" : "#161B22"
                        border.color: orgField.activeFocus ? "#1F6FEB" : "#30363D"
                        border.width: 1
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                    }
                    onTextChanged: root.talentOrg = text
                }
            }

            Rectangle {
                height: 1
                color: "#30363D"
                Layout.fillWidth: true
            }

            // ── Photo section ──────────────────────────────────────
            ColumnLayout {
                spacing: 8
                Layout.fillWidth: true

                Text {
                    text: "Photo (Local Import)"
                    color: "#8B949E"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }

                // Photo preview container
                Rectangle {
                    id: photoPreviewContainer
                    Layout.fillWidth: true
                    height: 80
                    radius: 6
                    color: "#161B22"
                    border.color: "#30363D"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10

                        // Photo thumbnail preview
                        Rectangle {
                            id: thumbnailFrame
                            width: 64
                            height: 64
                            radius: 6
                            color: "#0D1117"
                            border.color: photoPreview.status === Image.Ready ? "#1F6FEB" : "#30363D"
                            border.width: 1
                            clip: true

                            Image {
                                id: photoPreview
                                anchors.fill: parent
                                anchors.margins: 2
                                source: root.talentPhoto ? (root.talentPhoto.startsWith("file://") ? root.talentPhoto : "file://" + root.talentPhoto) : ""
                                fillMode: Image.PreserveAspectCrop
                                visible: status === Image.Ready
                                asynchronous: true

                                // Rounded corners effect using clip
                                layer.enabled: true
                            }

                            // Placeholder when no photo
                            Text {
                                anchors.centerIn: parent
                                text: "📷"
                                font.pixelSize: 24
                                color: "#484F58"
                                visible: photoPreview.status !== Image.Ready
                            }
                        }

                        // Photo path and import button
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 4

                            Text {
                                text: root.talentPhoto ? root.talentPhoto.split("/").pop() : "No photo selected"
                                color: root.talentPhoto ? "#E6EDF3" : "#484F58"
                                font.pixelSize: 11
                                elide: Text.ElideMiddle
                                Layout.fillWidth: true
                            }

                            // Import button
                            Rectangle {
                                Layout.fillWidth: true
                                height: 28
                                radius: 4
                                color: importBtnArea.containsMouse ? "#238636" : "#238636CC"
                                border.color: "#3FB950"
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 100 } }

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6

                                    Text {
                                        text: "📁"
                                        font.pixelSize: 12
                                    }

                                    Text {
                                        text: "Import Photo"
                                        color: "white"
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                    }
                                }

                                MouseArea {
                                    id: importBtnArea
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: photoFileDialog.open()
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                height: 1
                color: "#30363D"
                Layout.fillWidth: true
            }

            // ── Action buttons ─────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // Add/Update button
                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    radius: 6
                    color: updateBtnArea.containsMouse ? "#2563EB" : "#1F6FEB"
                    border.color: "#388BFD"
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 100 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: root.talentId ? "✓" : "+"
                            font.pixelSize: 12
                            color: "white"
                        }

                        Text {
                            text: root.talentId ? "Update" : "Add Talent"
                            color: "white"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }
                    }

                    MouseArea {
                        id: updateBtnArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            if (root.talentId) {
                                bridge.updateTalent(root.talentId, root.talentName,
                                                    root.talentRole, root.talentOrg,
                                                    root.talentPhoto)
                            } else {
                                bridge.addTalent(root.talentName, root.talentRole,
                                                 root.talentOrg, root.talentPhoto)
                            }
                            root.updateTalent()
                        }
                    }
                }

                // Remove button (only visible when editing)
                Rectangle {
                    width: 80
                    height: 32
                    radius: 6
                    color: removeBtnArea.containsMouse ? "#DA3633" : "#F85149"
                    border.color: "#FF6A67"
                    border.width: 1
                    visible: root.talentId !== ""

                    Behavior on color { ColorAnimation { duration: 100 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: "🗑"
                            font.pixelSize: 10
                        }

                        Text {
                            text: "Remove"
                            color: "white"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }
                    }

                    MouseArea {
                        id: removeBtnArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            bridge.removeTalent(root.talentId)
                            root.removeTalent()
                            root.clearForm()
                        }
                    }
                }
            }

            // ── Clear form button ──────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 28
                radius: 4
                color: clearBtnArea.containsMouse ? "#30363D" : "#21262D"
                border.color: "#30363D"
                border.width: 1
                visible: root.talentName !== "" || root.talentRole !== "" || root.talentOrg !== "" || root.talentPhoto !== ""

                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: "Clear Form"
                    color: "#8B949E"
                    font.pixelSize: 11
                }

                MouseArea {
                    id: clearBtnArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: root.clearForm()
                }
            }
        }
    }

    // ── Helper function to clear the form ──────────────────────────
    function clearForm() {
        root.talentId = ""
        root.talentName = ""
        root.talentRole = ""
        root.talentOrg = ""
        root.talentPhoto = ""
        photoPreview.source = ""
    }

    // ── Animations ─────────────────────────────────────────────────
    Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
}
