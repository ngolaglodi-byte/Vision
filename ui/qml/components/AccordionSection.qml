// VisionCast-AI — Licence officielle Prestige Technologie Company,
// développée par Glody Dimputu Ngola.
//
// AccordionSection.qml — Premium accordion section with slide-down animation
//                        and VisionCast Prestige gradient styling.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Column {
    id: root

    // ── Public API ─────────────────────────────────────────────────
    property string sectionIcon: ""
    property string sectionTitle: ""
    property Component panelComponent: null
    property bool expanded: false

    // Animation parameters
    property int animationDuration: 220
    property int expandedHeight: 400

    width: parent ? parent.width : 160

    // ── Header (clickable) ─────────────────────────────────────────
    Rectangle {
        id: header
        width: parent.width
        height: 42
        radius: 0

        // Prestige gradient effect
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: root.expanded ? "#1A2332" : "#161B22" }
            GradientStop { position: 1.0; color: root.expanded ? "#1E293B" : "#161B22" }
        }

        // Left accent line (electric blue when expanded)
        Rectangle {
            id: accentLine
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 3
            color: root.expanded ? "#1F6FEB" : "transparent"
            opacity: root.expanded ? 1.0 : 0.0

            Behavior on color   { ColorAnimation { duration: root.animationDuration } }
            Behavior on opacity { NumberAnimation { duration: root.animationDuration } }
        }

        // Bottom border line
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: "#30363D"
        }

        // Icon + Title row
        Row {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 8
            spacing: 10

            // Section icon
            Text {
                id: iconText
                text: root.sectionIcon
                font.pixelSize: 16
                color: root.expanded ? "#58A6FF" : "#8B949E"
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color { ColorAnimation { duration: root.animationDuration } }
            }

            // Section title
            Text {
                id: titleText
                text: root.sectionTitle
                font.pixelSize: 12
                font.weight: root.expanded ? Font.DemiBold : Font.Normal
                font.family: "Segoe UI, Inter, Helvetica Neue, Arial"
                color: root.expanded ? "#E6EDF3" : "#A0AEC0"
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color { ColorAnimation { duration: root.animationDuration } }
            }

        }

        // Chevron indicator (positioned absolutely on the right)
        Text {
            id: chevron
            text: root.expanded ? "▼" : "▶"
            font.pixelSize: 10
            color: root.expanded ? "#58A6FF" : "#6B7280"
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color { ColorAnimation { duration: root.animationDuration } }
        }

        // Hover effect
        Rectangle {
            id: hoverOverlay
            anchors.fill: parent
            color: "#FFFFFF"
            opacity: 0.0

            Behavior on opacity { NumberAnimation { duration: 100 } }
        }

        // Click area
        MouseArea {
            id: headerMouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            onEntered: hoverOverlay.opacity = 0.03
            onExited: hoverOverlay.opacity = 0.0
            onClicked: root.expanded = !root.expanded
        }
    }

    // ── Animated content wrapper ───────────────────────────────────
    Item {
        id: contentWrapper
        width: parent.width
        height: root.expanded ? root.expandedHeight : 0
        clip: true
        visible: height > 0

        Behavior on height {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutCubic
            }
        }

        // Content background with Prestige styling
        Rectangle {
            anchors.fill: parent
            color: "#0D1117"

            // Subtle gradient overlay
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: "#0D1117" }
                    GradientStop { position: 1.0; color: "#111827" }
                }
                opacity: 0.5
            }

            // Left accent border
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 1
                color: "#1F6FEB"
                opacity: 0.3
            }

            // Bottom border
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: "#30363D"
            }

            // Panel loader
            Loader {
                id: panelLoader
                anchors.fill: parent
                sourceComponent: root.expanded ? root.panelComponent : null
                active: root.expanded

                // Fade-in animation for loaded content
                opacity: root.expanded ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
