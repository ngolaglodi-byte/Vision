// VisionCast-AI — Licence officielle Prestige Technologie Company,
// développée par Glody Dimputu Ngola.
//
// PanelManager.qml — Centralized panel state manager for the right panel container.
//                    Manages active panel, panel stack, and navigation.

import QtQuick 2.15

QtObject {
    id: root

    // ── Panel identifiers ─────────────────────────────────────────────
    readonly property string panelChannel: "channel"
    readonly property string panelBroadcast: "broadcast"
    readonly property string panelAI: "ai"
    readonly property string panelGraphics: "graphics"
    readonly property string panelStreaming: "streaming"
    readonly property string panelTools: "tools"
    readonly property string panelView: "view"
    readonly property string panelHelp: "help"
    readonly property string panelSources: "sources"
    readonly property string panelDesign: "design"
    readonly property string panelTalent: "talent"
    readonly property string panelOverlay: "overlay"
    readonly property string panelRecognition: "recognition"
    readonly property string panelMonitoring: "monitoring"
    readonly property string panelMultiStream: "multistream"
    readonly property string panelOutput: "output"
    readonly property string panelEffects: "effects"
    readonly property string panelSettings: "settings"
    readonly property string panelAbout: "about"

    // ── Active panel state ────────────────────────────────────────────
    property string activePanel: panelSources
    property string previousPanel: ""

    // ── Panel history for back navigation ─────────────────────────────
    property var panelHistory: []

    // ── Navigation functions ──────────────────────────────────────────

    /// Navigate to a specific panel
    function navigateTo(panelId) {
        if (panelId !== activePanel) {
            previousPanel = activePanel
            // Limit history to 20 items - check before adding
            if (panelHistory.length >= 20) {
                panelHistory.shift()
            }
            panelHistory.push(activePanel)
            activePanel = panelId
        }
    }

    /// Go back to the previous panel
    function goBack() {
        if (panelHistory.length > 0) {
            previousPanel = activePanel
            activePanel = panelHistory.pop()
        }
    }

    /// Check if we can go back
    function canGoBack() {
        return panelHistory.length > 0
    }

    /// Reset panel navigation
    function reset() {
        previousPanel = ""
        panelHistory = []
        activePanel = panelSources
    }

    // ── Panel metadata ────────────────────────────────────────────────
    readonly property var panelInfo: ({
        "channel": { icon: "📺", title: "Channel", description: "Channel profiles and settings" },
        "broadcast": { icon: "🎬", title: "Broadcast", description: "Video engine and broadcast controls" },
        "ai": { icon: "🤖", title: "AI & Automation", description: "Face recognition and AI features" },
        "graphics": { icon: "🎨", title: "Graphics", description: "Overlays, templates and branding" },
        "streaming": { icon: "📡", title: "Streaming", description: "Platform setup and encoder settings" },
        "tools": { icon: "🔧", title: "Tools", description: "System monitor and diagnostics" },
        "view": { icon: "👁", title: "View", description: "Layout and display options" },
        "help": { icon: "❓", title: "Help", description: "Documentation and support" },
        "sources": { icon: "🎥", title: "Sources", description: "Video input sources" },
        "design": { icon: "🎨", title: "Design", description: "Themes and visual settings" },
        "talent": { icon: "👤", title: "Talent", description: "Talent profiles and management" },
        "overlay": { icon: "🖼️", title: "Overlay", description: "Overlay templates and editor" },
        "recognition": { icon: "🔍", title: "Recognition", description: "Face recognition controls" },
        "monitoring": { icon: "📊", title: "Monitoring", description: "System metrics and status" },
        "multistream": { icon: "📡", title: "Multi-Stream", description: "Multi-platform streaming" },
        "output": { icon: "🔌", title: "Output", description: "Output configuration" },
        "effects": { icon: "✨", title: "Effects", description: "Video effects and filters" },
        "settings": { icon: "⚙️", title: "Settings", description: "Application settings" },
        "about": { icon: "ℹ️", title: "About", description: "Application information" }
    })

    /// Get panel info for a panel ID
    function getPanelInfo(panelId) {
        return panelInfo[panelId] || { icon: "📄", title: panelId, description: "" }
    }
}
