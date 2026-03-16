// VisionCast-AI — Licence officielle Prestige Technologie Company,
// développée par Glody Dimputu Ngola.
//
// RightPanelContainer.qml — Main right-side panel container that displays
//                            the currently selected panel with smooth transitions.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../panels"

Rectangle {
    id: root
    color: "#0D1117"

    // ── Panel Manager reference ───────────────────────────────────────
    property var panelManager: null

    // ── Current active panel ──────────────────────────────────────────
    property string activePanel: panelManager ? panelManager.activePanel : "sources"

    // ── Cached panel info to avoid repeated lookups ───────────────────
    property var currentPanelInfo: {
        if (panelManager) {
            return panelManager.getPanelInfo(activePanel)
        }
        return { icon: "📄", title: "Panel", description: "" }
    }

    // ── Panel navigation header ───────────────────────────────────────
    Rectangle {
        id: panelHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 52
        color: "#161B22"
        z: 10

        // Top gradient accent
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#1F6FEB" }
                GradientStop { position: 0.5; color: "#A855F7" }
                GradientStop { position: 1.0; color: "#1F6FEB" }
            }
        }

        // Bottom border
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: "#30363D"
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            // Back button (when history exists)
            Rectangle {
                id: backBtn
                visible: panelManager && panelManager.canGoBack()
                width: 32
                height: 32
                radius: 6
                color: backBtnArea.containsMouse ? "#21262D" : "transparent"
                border.color: backBtnArea.containsMouse ? "#30363D" : "transparent"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: "←"
                    color: "#8B949E"
                    font.pixelSize: 16
                    font.weight: Font.Bold
                }

                MouseArea {
                    id: backBtnArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: panelManager.goBack()
                }
            }

            // Panel icon
            Text {
                id: panelIcon
                text: root.currentPanelInfo.icon
                font.pixelSize: 20
            }

            // Panel title
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: root.currentPanelInfo.title
                    color: "#E6EDF3"
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    font.family: "Segoe UI, Inter, Helvetica Neue, Arial"
                }

                Text {
                    text: root.currentPanelInfo.description
                    color: "#8B949E"
                    font.pixelSize: 11
                    font.family: "Segoe UI, Inter, Helvetica Neue, Arial"
                    visible: text.length > 0
                }
            }

            // Panel close/minimize button
            Rectangle {
                width: 32
                height: 32
                radius: 6
                color: closeBtnArea.containsMouse ? "#21262D" : "transparent"
                border.color: closeBtnArea.containsMouse ? "#30363D" : "transparent"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: "×"
                    color: closeBtnArea.containsMouse ? "#F85149" : "#8B949E"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                }

                MouseArea {
                    id: closeBtnArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        // Reset to default panel
                        if (panelManager) panelManager.navigateTo("sources")
                    }
                }
            }
        }
    }

    // ── Panel content area ────────────────────────────────────────────
    Item {
        id: panelContent
        anchors.top: panelHeader.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        // ── All panels (visibility controlled by activePanel) ─────────

        // Menu-linked panels
        ChannelPanel {
            anchors.fill: parent
            visible: activePanel === "channel"
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        BroadcastPanel {
            anchors.fill: parent
            visible: activePanel === "broadcast"
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        AIPanel {
            anchors.fill: parent
            visible: activePanel === "ai"
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        GraphicsPanel {
            anchors.fill: parent
            visible: activePanel === "graphics"
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        StreamingPanel {
            anchors.fill: parent
            visible: activePanel === "streaming"
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        ToolsPanel {
            anchors.fill: parent
            visible: activePanel === "tools"
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        ViewPanel {
            anchors.fill: parent
            visible: activePanel === "view"
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        HelpPanel {
            anchors.fill: parent
            visible: activePanel === "help"
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        // Original panels
        SourcePanel {
            anchors.fill: parent
            visible: activePanel === "sources"
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        DesignPanel {
            anchors.fill: parent
            visible: activePanel === "design"
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        TalentPanel {
            anchors.fill: parent
            visible: activePanel === "talent"
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        OverlayPanel {
            anchors.fill: parent
            visible: activePanel === "overlay"
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        RecognitionPanel {
            anchors.fill: parent
            visible: activePanel === "recognition"
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        MonitoringPanel {
            anchors.fill: parent
            visible: activePanel === "monitoring"
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        MultiStreamPanel {
            anchors.fill: parent
            visible: activePanel === "multistream"
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        OutputPanel {
            anchors.fill: parent
            visible: activePanel === "output"
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        EffectsPanel {
            anchors.fill: parent
            visible: activePanel === "effects"
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        SettingsPanel {
            anchors.fill: parent
            visible: activePanel === "settings"
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        AboutPanel {
            anchors.fill: parent
            visible: activePanel === "about"
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }
    }
}
