// VisionCast-AI — Licence officielle Prestige Technologie Company,
// développée par Glody Dimputu Ngola.
//
// Main.qml — Root ApplicationWindow for the QML Broadcast Control Room.

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

    // == Menu bar modernisée (QtQuick Controls 2 compatible) ==
    // == Professional broadcast-level menu system ==
    menuBar: Rectangle {
        height: 40
        color: "#161B22"
        border.color: "#30363D"
        border.width: 1

        Row {
            anchors.fill: parent
            anchors.leftMargin: 16
            spacing: 24

            // ==== CHANNEL ====
            VCSectionHeader {
                title: "Channel"
                onClicked: channelMenu.open()
            }
            Menu {
                id: channelMenu
                MenuItem { text: "New Channel Profile"; onTriggered: bridge.newChannelProfile() }
                MenuItem { text: "Load Channel Profile..."; onTriggered: bridge.loadChannelProfile() }
                MenuItem { text: "Save Channel Profile"; onTriggered: bridge.saveChannelProfile() }
                MenuSeparator {}
                MenuItem { text: "Export Settings..."; onTriggered: bridge.exportProject() }
                MenuSeparator {}
                MenuItem { text: "Exit"; onTriggered: Qt.quit() }
            }

            // ==== BROADCAST SETTINGS ====
            VCSectionHeader {
                title: "Broadcast"
                onClicked: broadcastSettingsMenu.open()
            }
            Menu {
                id: broadcastSettingsMenu
                MenuItem { text: "Video Engine"; onTriggered: bridge.openVideoEngineSettings() }
                MenuItem { text: "Audio Routing"; onTriggered: bridge.openAudioRoutingSettings() }
                MenuSeparator {}
                MenuItem { text: "DeckLink / SDI"; onTriggered: bridge.openDeckLinkSettings() }
                MenuItem { text: "NDI"; onTriggered: bridge.openNdiSettings() }
                MenuItem { text: "SRT / RTMP Inputs"; onTriggered: bridge.openSrtRtmpInputSettings() }
                MenuSeparator {}
                MenuItem { text: "Output Routing"; onTriggered: bridge.openOutputRoutingSettings() }
                MenuSeparator {}
                MenuItem { text: "Start Engine"; onTriggered: bridge.startEngine() }
                MenuItem { text: "Stop Engine"; onTriggered: bridge.stopEngine() }
                MenuSeparator {}
                MenuItem { text: "Go Live"; onTriggered: bridge.goLive() }
                MenuItem { text: "Stop Broadcast"; onTriggered: bridge.stopBroadcast() }
            }

            // ==== AI & AUTOMATION ====
            VCSectionHeader {
                title: "AI"
                onClicked: aiMenu.open()
            }
            Menu {
                id: aiMenu
                MenuItem { text: "Face Recognition"; onTriggered: bridge.openFaceRecognitionSettings() }
                MenuItem { text: "Talent Database"; onTriggered: bridge.openTalentDatabase() }
                MenuSeparator {}
                MenuItem { text: "Auto-Overlay Rules"; onTriggered: bridge.openAutoOverlayRules() }
                MenuItem { text: "AI Diagnostics"; onTriggered: bridge.openAiDiagnostics() }
            }

            // ==== GRAPHICS & DESIGN ====
            VCSectionHeader {
                title: "Graphics"
                onClicked: graphicsMenu.open()
            }
            Menu {
                id: graphicsMenu
                MenuItem { text: "Overlay Templates"; onTriggered: bridge.openOverlayTemplates() }
                MenuItem { text: "Lower-Third Editor"; onTriggered: bridge.openLowerThirdEditor() }
                MenuItem { text: "Branding"; onTriggered: bridge.openBrandingSettings() }
                MenuSeparator {}
                MenuItem { text: "LUT Manager"; onTriggered: bridge.openLutManager() }
                MenuItem { text: "Effects Pipeline"; onTriggered: bridge.openEffectsPipeline() }
                MenuSeparator {}
                MenuItem { text: "Theme Settings..."; onTriggered: settingsDialog.open() }
            }

            // ==== STREAMING ====
            VCSectionHeader {
                title: "Streaming"
                onClicked: streamingMenu.open()
            }
            Menu {
                id: streamingMenu
                MenuItem { text: "YouTube Setup"; onTriggered: bridge.openYouTubeSetup() }
                MenuItem { text: "Facebook Setup"; onTriggered: bridge.openFacebookSetup() }
                MenuItem { text: "Twitch Setup"; onTriggered: bridge.openTwitchSetup() }
                MenuSeparator {}
                MenuItem { text: "RTMP Profiles"; onTriggered: bridge.openRtmpProfiles() }
                MenuItem { text: "Multi-Stream Presets"; onTriggered: bridge.openMultiStreamPresets() }
                MenuSeparator {}
                MenuItem { text: "Encoder Settings"; onTriggered: bridge.openEncoderSettings() }
            }

            // ==== TOOLS ====
            VCSectionHeader {
                title: "Tools"
                onClicked: toolsMenu.open()
            }
            Menu {
                id: toolsMenu
                MenuItem { text: "System Monitor"; onTriggered: bridge.openSystemMonitor() }
                MenuItem { text: "Network Diagnostics"; onTriggered: bridge.openNetworkDiagnostics() }
                MenuSeparator {}
                MenuItem { text: "Log Viewer"; onTriggered: bridge.openLogViewer() }
                MenuItem { text: "Backup / Restore"; onTriggered: bridge.openBackupRestore() }
            }

            // ==== VIEW ====
            VCSectionHeader {
                title: "View"
                onClicked: viewMenu.open()
            }
            Menu {
                id: viewMenu
                MenuItem {
                    text: "Show Monitoring"
                    checkable: true
                    checked: true
                    onToggled: bottomBar.visible = checked
                }
                MenuItem {
                    text: "Show Left Panel"
                    checkable: true
                    checked: true
                    onToggled: leftAccordionMenu.visible = checked
                }
                MenuSeparator {}
                MenuItem {
                    text: "Dark/Light Theme"
                    checkable: true
                    checked: true
                    onToggled: bridge.setTheme(checked ? "Dark" : "Light")
                }
            }

            // ==== HELP ====
            VCSectionHeader {
                title: "Help"
                onClicked: helpMenu.open()
            }
            Menu {
                id: helpMenu
                MenuItem { text: "User Manual"; onTriggered: Qt.openUrlExternally("https://visioncast.prestige.tech/docs") }
                MenuItem { text: "Shortcuts"; onTriggered: shortcutsDialog.open() }
                MenuSeparator {}
                MenuItem { text: "About VisionCast-AI"; onTriggered: aboutDialog.open() }
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
        color: Qt.rgba(0.05,0.07,0.09,1)

        // TOP BAR (déjà moderne)
        Rectangle {
            id:     topBar
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 48
            color:  "#161B22"
            z:      10
            // Note: Top bar can contain sticky logo/status if needed for scrolling layouts.
        }

        // MAIN
        RowLayout {
            anchors {
                top:    topBar.bottom
                bottom: bottomBar.top
                left:   parent.left
                right:  parent.right
            }
            spacing: 0

            // Left column — Premium Accordion Menu (160px)
            Rectangle {
                id: leftAccordionMenu
                Layout.preferredWidth: 160
                Layout.minimumWidth: 160
                Layout.maximumWidth: 160
                Layout.fillHeight: true
                color: "#161B22"

                // Prestige gradient header
                Rectangle {
                    id: accordionHeader
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 44
                    z: 2

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#1A2332" }
                        GradientStop { position: 1.0; color: "#1F6FEB22" }
                    }

                    // Bottom border
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        color: "#30363D"
                    }

                    // Logo / Brand
                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        Rectangle {
                            width: 24; height: 24; radius: 6
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#1F6FEB" }
                                GradientStop { position: 1.0; color: "#A855F7" }
                            }
                            Text {
                                anchors.centerIn: parent
                                text: "VC"
                                color: "#FFFFFF"
                                font.pixelSize: 9
                                font.weight: Font.Bold
                            }
                        }

                        Text {
                            text: "PANELS"
                            color: "#8B949E"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1.2
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // Scrollable accordion sections
                Flickable {
                    id: accordionFlickable
                    anchors.top: accordionHeader.bottom
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    contentHeight: accordionColumn.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        width: 4
                    }

                    Column {
                        id: accordionColumn
                        width: parent.width
                        spacing: 0

                        // 🎥 Sources
                        AccordionSection {
                            sectionIcon: "🎥"
                            sectionTitle: "Sources"
                            expandedHeight: 350
                            panelComponent: Component { SourcePanel { } }
                        }

                        // 🎨 Design
                        AccordionSection {
                            sectionIcon: "🎨"
                            sectionTitle: "Design"
                            expandedHeight: 320
                            panelComponent: Component { DesignPanel { } }
                        }

                        // 👤 Talent
                        AccordionSection {
                            sectionIcon: "👤"
                            sectionTitle: "Talent"
                            expandedHeight: 400
                            panelComponent: Component { TalentPanel { } }
                        }

                        // 🖼️ Overlay
                        AccordionSection {
                            sectionIcon: "🖼️"
                            sectionTitle: "Overlay"
                            expandedHeight: 400
                            panelComponent: Component { OverlayPanel { } }
                        }

                        // 🔍 Recognition
                        AccordionSection {
                            sectionIcon: "🔍"
                            sectionTitle: "Recognition"
                            expandedHeight: 280
                            panelComponent: Component { RecognitionPanel { } }
                        }

                        // 📊 Monitoring
                        AccordionSection {
                            sectionIcon: "📊"
                            sectionTitle: "Monitoring"
                            expandedHeight: 220
                            panelComponent: Component { MonitoringPanel { } }
                        }

                        // 📡 Multi-Streaming
                        AccordionSection {
                            sectionIcon: "📡"
                            sectionTitle: "Multi-Stream"
                            expandedHeight: 380
                            panelComponent: Component { MultiStreamPanel { } }
                        }

                        // 🔌 Output
                        AccordionSection {
                            sectionIcon: "🔌"
                            sectionTitle: "Output"
                            expandedHeight: 250
                            panelComponent: Component { OutputPanel { } }
                        }

                        // ✨ Effects
                        AccordionSection {
                            sectionIcon: "✨"
                            sectionTitle: "Effects"
                            expandedHeight: 350
                            panelComponent: Component { EffectsPanel { } }
                        }

                        // ⚙️ Settings
                        AccordionSection {
                            sectionIcon: "⚙️"
                            sectionTitle: "Settings"
                            expandedHeight: 380
                            panelComponent: Component { SettingsPanel { } }
                        }

                        // ℹ️ About
                        AccordionSection {
                            sectionIcon: "ℹ️"
                            sectionTitle: "About"
                            expandedHeight: 280
                            panelComponent: Component { AboutPanel { } }
                        }
                    }
                }

                // Right border separator
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 1
                    color: "#30363D"
                }
            }
            Rectangle { Layout.preferredWidth: 1; Layout.fillHeight: true; color: "#30363D" }

            // Center: Program/Preview
            ColumnLayout {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                spacing: 0

                ProgramView {
                    Layout.fillWidth:  true
                    Layout.fillHeight: true
                    Layout.preferredHeight: parent.height * 0.55
                    Layout.margins: 8
                }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#30363D" }
                PreviewView {
                    Layout.fillWidth:  true
                    Layout.fillHeight: true
                    Layout.preferredHeight: parent.height * 0.45
                    Layout.margins: 8
                }
            }
            Rectangle { Layout.preferredWidth: 1; Layout.fillHeight: true; color: "#30363D" }

            // Right: Tabbed panel
            Rectangle {
                Layout.preferredWidth: 360
                Layout.minimumWidth:   260
                Layout.fillHeight:     true
                color: "#161B22"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // Tab bar/code inchangé
                    Rectangle {
                        Layout.fillWidth: true
                        height: 42
                        color:  "#1C2128"
                        // ... [inchangé]
                    }

                    // Tab contents inchangé
                    Item {
                        id:               rightPanel
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        property int currentTab: 0

                        TalentPanel {
                            anchors.fill: parent
                            visible:      rightPanel.currentTab === 0

                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            opacity: visible ? 1.0 : 0.0
                        }
                        OverlayPanel {
                            anchors.fill: parent
                            visible:      rightPanel.currentTab === 1

                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            opacity: visible ? 1.0 : 0.0
                        }
                        RecognitionPanel {
                            anchors.fill: parent
                            visible:      rightPanel.currentTab === 2

                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            opacity: visible ? 1.0 : 0.0
                        }
                    }
                }
            }
        }

        // BOTTOM BAR
        Rectangle {
            id:     bottomBar
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: 200
            color:  "#161B22"
            z:      5

            Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#30363D" }

            RowLayout {
                anchors { fill: parent }
                spacing: 0

                MonitoringPanel { Layout.fillWidth:  true; Layout.fillHeight: true }
                Rectangle { Layout.preferredWidth: 1; Layout.fillHeight: true; color: "#30363D" }
                MultiStreamPanel { Layout.preferredWidth: 480; Layout.minimumWidth: 340; Layout.fillHeight: true }
                Rectangle { Layout.preferredWidth: 1; Layout.fillHeight: true; color: "#30363D" }
                OutputPanel { Layout.preferredWidth: 300; Layout.fillHeight: true }
            }
        }
    } // end Rectangle

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
}