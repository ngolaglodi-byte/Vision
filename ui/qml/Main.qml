// VisionCast-AI — Licence officielle Prestige Technologie Company,
// développée par Glody Dimputu Ngola.
//
// Main.qml — Root ApplicationWindow for the QML Broadcast Control Room.
//            Modernized layout with right-side panel system.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "panels"
import "components"

ApplicationWindow {
    id: root
    visible:    true
    width:      1920
    height:     1080
    minimumWidth:  1280
    minimumHeight: 720
    title: "VisionCast-AI — Broadcast Control Room"
    color: "#0D1117"

    // ── Theme Constants ───────────────────────────────────────────────
    readonly property int menuBarHeight: 44
    readonly property int bottomBarHeight: 180
    readonly property int quickAccessBarWidth: 52
    readonly property int rightPanelWidth: 420

    // ── Panel Manager instance ────────────────────────────────────────
    PanelManager {
        id: panelManager
    }

    // == Menu bar modernisée (QtQuick Controls 2 compatible) ==
    // == Professional broadcast-level menu system ==
    menuBar: Rectangle {
        height: root.menuBarHeight
        color: "#161B22"

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
            spacing: 0

            // VisionCast Logo
            Row {
                spacing: 8
                Layout.rightMargin: 24

                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    anchors.verticalCenter: parent.verticalCenter
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#1F6FEB" }
                        GradientStop { position: 1.0; color: "#A855F7" }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "VC"
                        color: "#FFFFFF"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                    }
                }

                Text {
                    text: "VisionCast"
                    color: "#E6EDF3"
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // ==== CHANNEL ====
            MenuButton {
                text: "Channel"
                onClicked: panelManager.navigateTo("channel")
                active: panelManager.activePanel === "channel"
            }

            // ==== BROADCAST ====
            MenuButton {
                text: "Broadcast"
                onClicked: panelManager.navigateTo("broadcast")
                active: panelManager.activePanel === "broadcast"
            }

            // ==== AI ====
            MenuButton {
                text: "AI"
                onClicked: panelManager.navigateTo("ai")
                active: panelManager.activePanel === "ai"
            }

            // ==== GRAPHICS ====
            MenuButton {
                text: "Graphics"
                onClicked: panelManager.navigateTo("graphics")
                active: panelManager.activePanel === "graphics"
            }

            // ==== STREAMING ====
            MenuButton {
                text: "Streaming"
                onClicked: panelManager.navigateTo("streaming")
                active: panelManager.activePanel === "streaming"
            }

            // ==== TOOLS ====
            MenuButton {
                text: "Tools"
                onClicked: panelManager.navigateTo("tools")
                active: panelManager.activePanel === "tools"
            }

            // ==== VIEW ====
            MenuButton {
                text: "View"
                onClicked: panelManager.navigateTo("view")
                active: panelManager.activePanel === "view"
            }

            // ==== HELP ====
            MenuButton {
                text: "Help"
                onClicked: panelManager.navigateTo("help")
                active: panelManager.activePanel === "help"
            }

            Item { Layout.fillWidth: true }

            // Live indicator
            Rectangle {
                id: liveIndicator
                visible: false
                width: liveText.implicitWidth + 20
                height: 28
                radius: 14
                color: "#F85149"
                opacity: 0.9

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: "#FFFFFF"

                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            running: liveIndicator.visible
                            NumberAnimation { to: 0.3; duration: 500 }
                            NumberAnimation { to: 1.0; duration: 500 }
                        }
                    }

                    Text {
                        id: liveText
                        text: "LIVE"
                        color: "#FFFFFF"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }
                }
            }
        }
    }

    // ---- Notification toast ----
    property string _toastMsg:   ""
    property string _toastLevel: "info"

    Connections {
        target: bridge
        function onNotification(message, level) {
            root._toastMsg   = message
            root._toastLevel = level
            toastTimer.restart()
        }
    }

    // == Interface principale ==
    Rectangle {
        anchors.fill: parent
        color: "#0D1117"

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // ── Center: Program/Preview Area ──────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                // Program/Preview views
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        // Program View (Main output)
                        ProgramView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredHeight: parent.height * 0.55
                        }

                        // Separator
                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: "#30363D"
                        }

                        // Preview View
                        PreviewView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredHeight: parent.height * 0.45
                        }
                    }
                }

                // Bottom bar separator
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#30363D"
                }

                // ── Bottom Bar: Monitoring & Controls ─────────────────
                Rectangle {
                    id: bottomBar
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.bottomBarHeight
                    color: "#161B22"

                    RowLayout {
                        anchors.fill: parent
                        spacing: 0

                        // Monitoring Panel
                        MonitoringPanel {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }

                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.fillHeight: true
                            color: "#30363D"
                        }

                        // Multi-Stream Panel
                        MultiStreamPanel {
                            Layout.preferredWidth: 400
                            Layout.minimumWidth: 320
                            Layout.fillHeight: true
                        }

                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.fillHeight: true
                            color: "#30363D"
                        }

                        // Output Panel
                        OutputPanel {
                            Layout.preferredWidth: 280
                            Layout.fillHeight: true
                        }
                    }
                }
            }

            // Vertical separator
            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                color: "#30363D"
            }

            // ── Right Panel Container ─────────────────────────────────
            RightPanelContainer {
                id: rightPanelContainer
                Layout.preferredWidth: root.rightPanelWidth
                Layout.minimumWidth: 360
                Layout.maximumWidth: 520
                Layout.fillHeight: true
                panelManager: panelManager
            }
        }

        // ── Quick Panel Access Bar ────────────────────────────────────
        Rectangle {
            id: quickAccessBar
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: bottomBar.top
            width: root.quickAccessBarWidth
            color: "#161B22"
            z: 5

            // Left border
            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 1
                color: "#30363D"
            }

            Column {
                anchors.fill: parent
                anchors.topMargin: 12
                spacing: 8

                // Panel quick access buttons
                Repeater {
                    model: [
                        { id: "sources", icon: "🎥", tip: "Sources" },
                        { id: "design", icon: "🎨", tip: "Design" },
                        { id: "talent", icon: "👤", tip: "Talent" },
                        { id: "overlay", icon: "🖼️", tip: "Overlay" },
                        { id: "recognition", icon: "🔍", tip: "Recognition" },
                        { id: "monitoring", icon: "📊", tip: "Monitoring" },
                        { id: "multistream", icon: "📡", tip: "Multi-Stream" },
                        { id: "output", icon: "🔌", tip: "Output" },
                        { id: "effects", icon: "✨", tip: "Effects" },
                        { id: "settings", icon: "⚙️", tip: "Settings" },
                        { id: "about", icon: "ℹ️", tip: "About" }
                    ]

                    Rectangle {
                        width: 40
                        height: 40
                        anchors.horizontalCenter: parent.horizontalCenter
                        radius: 8
                        color: panelManager.activePanel === modelData.id ?
                               "#1F6FEB33" :
                               (quickAccessArea.containsMouse ? "#21262D" : "transparent")
                        border.color: panelManager.activePanel === modelData.id ? "#1F6FEB" : "transparent"
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon
                            font.pixelSize: 16
                        }

                        MouseArea {
                            id: quickAccessArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: panelManager.navigateTo(modelData.id)

                            ToolTip.visible: containsMouse
                            ToolTip.text: modelData.tip
                            ToolTip.delay: 500
                        }
                    }
                }
            }
        }
    } // end main Rectangle

    // == TOAST notification ==
    Rectangle {
        id: toast
        visible:  opacity > 0
        opacity:  toastTimer.running ? 1.0 : 0.0
        anchors.bottom: bottomBar.top
        anchors.bottomMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        width:    toastText.implicitWidth + 32
        height:   36
        radius:   8
        color:    root._toastLevel === "error"   ? "#F85149"
                : root._toastLevel === "success"  ? "#3FB950"
                : root._toastLevel === "warning"  ? "#D29922"
                : root._toastLevel === "live"     ? "#F85149"
                : "#21262D"
        border.color: Qt.lighter(color, 1.3)
        border.width: 1
        z: 100
        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Text {
            id:    toastText
            text:  root._toastMsg
            color: "#FFFFFF"
            font.pixelSize: 12
            font.family:    "Segoe UI, Inter, Helvetica Neue, Arial"
            anchors.centerIn: parent
        }
    }
    Timer { id: toastTimer; interval: 3000 }

    // == DIALOGS ==
    Dialog {
        id:       aboutDialog
        title:    "About VisionCast-AI"
        modal:    true
        anchors.centerIn: parent
        width:    480
        height:   320
        background: Rectangle {
            color:  "#161B22"
            radius: 10
            border.color: "#30363D"
            border.width: 1
        }
        header: Rectangle {
            height: 48
            color:  "#1C2128"
            radius: 10
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left:   parent.left
                anchors.right:  parent.right
                height: 1
                color:  "#30363D"
            }
            Text {
                text:  "About VisionCast-AI"
                color: "#E6EDF3"
                font.pixelSize: 14
                font.weight:    Font.Bold
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        contentItem: Column {
            anchors.centerIn: parent
            spacing: 12

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 64; height: 64; radius: 12
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#1F6FEB" }
                    GradientStop { position: 1.0; color: "#A855F7" }
                }
                Text { anchors.centerIn: parent; text: "VC"; color: "#FFFFFF"; font.pixelSize: 24; font.weight: Font.Bold }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:  "VisionCast-AI"
                color: "#E6EDF3"
                font.pixelSize: 18
                font.weight:    Font.Bold
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:  "Broadcast Control Room — QML Edition"
                color: "#8B949E"
                font.pixelSize: 12
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:  "Version 1.0.0"
                color: "#484F58"
                font.pixelSize: 11
            }

            Rectangle { width: 300; height: 1; color: "#30363D"; anchors.horizontalCenter: parent.horizontalCenter }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:  "Licence officielle Prestige Technologie Company\ndéveloppée par Glody Dimputu Ngola"
                color: "#8B949E"
                font.pixelSize: 11
                horizontalAlignment: Text.AlignHCenter
            }
        }
        footer: Rectangle {
            height: 52
            color: "transparent"
            VCButton {
                text: "Close"
                width: 80; height: 32
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                onClicked: aboutDialog.close()
            }
        }
    }

    // == Settings dialog placeholder ==
    Dialog {
        id: settingsDialog
        title: "Settings"
        modal: true
        anchors.centerIn: parent
        width: 480
        height: 400
        standardButtons: Dialog.Ok | Dialog.Cancel
        visible: false

        property string selectedTheme: "Dark"
        property string selectedAccent: "#1F6FEB"

        contentItem: Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            Text {
                text: "Application Settings"
                font.pixelSize: 16
                font.weight: Font.Bold
                color: "#E6EDF3"
            }

            Rectangle { width: parent.width; height: 1; color: "#30363D" }

            // Theme selection
            Row {
                spacing: 16
                Text {
                    text: "Theme:"
                    color: "#8B949E"
                    font.pixelSize: 13
                    anchors.verticalCenter: parent.verticalCenter
                    width: 100
                }
                ComboBox {
                    id: themeSettingsCombo
                    model: ["Dark", "Light", "Ocean", "Prestige"]
                    currentIndex: Math.max(0, model.indexOf(settingsDialog.selectedTheme))
                    onCurrentIndexChanged: settingsDialog.selectedTheme = themeSettingsCombo.model[currentIndex]
                }
            }

            // Accent color
            Row {
                spacing: 16
                Text {
                    text: "Accent Color:"
                    color: "#8B949E"
                    font.pixelSize: 13
                    anchors.verticalCenter: parent.verticalCenter
                    width: 100
                }
                Repeater {
                    model: ["#1F6FEB", "#A855F7", "#3FB950", "#FFD33D", "#F85149"]
                    delegate: Rectangle {
                        width: 28; height: 28; radius: 14
                        color: modelData
                        border.color: settingsDialog.selectedAccent === modelData ? "#E6EDF3" : "transparent"
                        border.width: 2
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: settingsDialog.selectedAccent = modelData
                        }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#30363D" }

            Text {
                text: "Changes will be applied on OK"
                color: "#8B949E"
                font.pixelSize: 11
                font.italic: true
            }
        }

        onAccepted: {
            bridge.setTheme(settingsDialog.selectedTheme)
            bridge.setAccentColor(settingsDialog.selectedAccent)
        }
    }

    // == Shortcuts dialog ==
    Dialog {
        id: shortcutsDialog
        title: "Keyboard Shortcuts"
        modal: true
        anchors.centerIn: parent
        width: 520
        height: 480

        background: Rectangle {
            color: "#161B22"
            radius: 10
            border.color: "#30363D"
            border.width: 1
        }

        header: Rectangle {
            height: 48
            color: "#1C2128"
            radius: 10
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: "#30363D"
            }
            Text {
                text: "Keyboard Shortcuts"
                color: "#E6EDF3"
                font.pixelSize: 14
                font.weight: Font.Bold
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        contentItem: Flickable {
            anchors.fill: parent
            anchors.margins: 16
            contentHeight: shortcutsColumn.height
            clip: true

            Column {
                id: shortcutsColumn
                width: parent.width
                spacing: 12

                // Broadcast controls
                Text {
                    text: "BROADCAST CONTROLS"
                    color: "#8B949E"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    font.letterSpacing: 1.0
                }

                ShortcutRow { shortcut: "F5"; description: "Start Engine" }
                ShortcutRow { shortcut: "F6"; description: "Stop Engine" }
                ShortcutRow { shortcut: "F7"; description: "Go Live" }
                ShortcutRow { shortcut: "F8"; description: "Stop Broadcast" }

                Rectangle { width: parent.width; height: 1; color: "#30363D" }

                // Sources
                Text {
                    text: "SOURCES"
                    color: "#8B949E"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    font.letterSpacing: 1.0
                }

                ShortcutRow { shortcut: "1-9"; description: "Select Source 1-9" }
                ShortcutRow { shortcut: "Space"; description: "Take / Cut" }
                ShortcutRow { shortcut: "Enter"; description: "Transition" }

                Rectangle { width: parent.width; height: 1; color: "#30363D" }

                // Overlays
                Text {
                    text: "OVERLAYS"
                    color: "#8B949E"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    font.letterSpacing: 1.0
                }

                ShortcutRow { shortcut: "Ctrl+1-5"; description: "Toggle Overlay 1-5" }
                ShortcutRow { shortcut: "Ctrl+0"; description: "Clear All Overlays" }

                Rectangle { width: parent.width; height: 1; color: "#30363D" }

                // General
                Text {
                    text: "GENERAL"
                    color: "#8B949E"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    font.letterSpacing: 1.0
                }

                ShortcutRow { shortcut: "Ctrl+S"; description: "Save Project" }
                ShortcutRow { shortcut: "Ctrl+O"; description: "Open Project" }
                ShortcutRow { shortcut: "Ctrl+E"; description: "Export Settings" }
                ShortcutRow { shortcut: "Ctrl+,"; description: "Settings" }
                ShortcutRow { shortcut: "F1"; description: "Help" }
                ShortcutRow { shortcut: "Ctrl+Q"; description: "Quit" }
            }
        }

        footer: Rectangle {
            height: 52
            color: "transparent"
            VCButton {
                text: "Close"
                width: 80; height: 32
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                onClicked: shortcutsDialog.close()
            }
        }
    }

    // == ShortcutRow component ==
    component ShortcutRow: Row {
        property string shortcut: ""
        property string description: ""
        spacing: 12
        width: parent ? parent.width : 400

        Rectangle {
            width: 80
            height: 24
            radius: 4
            color: "#21262D"
            border.color: "#30363D"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: shortcut
                color: "#58A6FF"
                font.pixelSize: 11
                font.family: "JetBrains Mono, Cascadia Code, monospace"
                font.weight: Font.Medium
            }
        }

        Text {
            text: description
            color: "#E6EDF3"
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // == MenuButton component for menu bar ==
    component MenuButton: Rectangle {
        property string text: ""
        property bool active: false
        signal clicked()

        width: menuBtnText.implicitWidth + 24
        height: 32
        radius: 6
        color: active ? "#1F6FEB33" : (menuBtnArea.containsMouse ? "#21262D" : "transparent")
        border.color: active ? "#1F6FEB" : "transparent"
        border.width: 1

        Behavior on color { ColorAnimation { duration: 100 } }

        Text {
            id: menuBtnText
            anchors.centerIn: parent
            text: parent.text
            color: active ? "#58A6FF" : (menuBtnArea.containsMouse ? "#E6EDF3" : "#8B949E")
            font.pixelSize: 12
            font.weight: active ? Font.DemiBold : Font.Normal
            font.family: "Segoe UI, Inter, Helvetica Neue, Arial"

            Behavior on color { ColorAnimation { duration: 100 } }
        }

        MouseArea {
            id: menuBtnArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: parent.clicked()
        }
    }
}