// VisionCast-AI — Licence officielle Prestige Technologie Company,
// développée par Glody Dimputu Ngola.
//
// EffectsPanel.qml — Professional video effects pipeline panel.
//                     LUT, color grading, vignette, sharpen, and more.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Rectangle {
    id: root
    color: "#161B22"

    // ── Header ─────────────────────────────────────────────────────
    Rectangle {
        id: hdr
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 44
        color: "#1C2128"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 8

            Text {
                text: "EFFECTS PIPELINE"
                color: "#8B949E"
                font.pixelSize: 11
                font.weight: Font.DemiBold
                font.letterSpacing: 1.0
                font.family: "Segoe UI, Inter, Helvetica Neue, Arial"
            }

            Item { Layout.fillWidth: true }

            // Master toggle
            VCToggleSwitch {
                id: masterToggle
                checked: true
            }

            Text {
                text: masterToggle.checked ? "ON" : "OFF"
                color: masterToggle.checked ? "#3FB950" : "#484F58"
                font.pixelSize: 10
                font.weight: Font.Bold
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: "#30363D"
        }
    }

    // ── Effects List ───────────────────────────────────────────────
    Flickable {
        anchors {
            top: hdr.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: 8
        }
        contentHeight: effectsColumn.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            width: 4
        }

        ColumnLayout {
            id: effectsColumn
            width: parent.width
            spacing: 8

            // ── LUT / Color Grading ────────────────────────────────
            EffectCard {
                title: "LUT / Color Grading"
                icon: "🎨"
                enabled: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Preset:"
                            color: "#8B949E"
                            font.pixelSize: 11
                        }

                        ComboBox {
                            id: lutCombo
                            Layout.fillWidth: true
                            model: ["None", "Cinema Warm", "Cinema Cool", "Film Noir", "Vintage", "HDR Vivid", "Broadcast Standard"]
                            currentIndex: 0
                            onCurrentIndexChanged: bridge.setLutPreset(lutCombo.model[currentIndex])
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Intensity:"
                            color: "#8B949E"
                            font.pixelSize: 11
                            Layout.preferredWidth: 60
                        }

                        Slider {
                            id: lutIntensity
                            Layout.fillWidth: true
                            from: 0.0
                            to: 1.0
                            value: 0.8
                            onValueChanged: bridge.setLutIntensity(value)
                        }

                        Text {
                            text: Math.round(lutIntensity.value * 100) + "%"
                            color: "#58A6FF"
                            font.pixelSize: 10
                            font.family: "JetBrains Mono, Cascadia Code, monospace"
                            Layout.preferredWidth: 35
                        }
                    }
                }
            }

            // ── Sharpen ────────────────────────────────────────────
            EffectCard {
                title: "Sharpen"
                icon: "🔍"
                enabled: false

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Amount:"
                            color: "#8B949E"
                            font.pixelSize: 11
                            Layout.preferredWidth: 60
                        }

                        Slider {
                            id: sharpenAmount
                            Layout.fillWidth: true
                            from: 0.0
                            to: 2.0
                            value: 0.5
                            onValueChanged: bridge.setSharpenAmount(value)
                        }

                        Text {
                            text: sharpenAmount.value.toFixed(1)
                            color: "#58A6FF"
                            font.pixelSize: 10
                            font.family: "JetBrains Mono, Cascadia Code, monospace"
                            Layout.preferredWidth: 35
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Radius:"
                            color: "#8B949E"
                            font.pixelSize: 11
                            Layout.preferredWidth: 60
                        }

                        Slider {
                            id: sharpenRadius
                            Layout.fillWidth: true
                            from: 0.5
                            to: 3.0
                            value: 1.0
                            onValueChanged: bridge.setSharpenRadius(value)
                        }

                        Text {
                            text: sharpenRadius.value.toFixed(1) + "px"
                            color: "#58A6FF"
                            font.pixelSize: 10
                            font.family: "JetBrains Mono, Cascadia Code, monospace"
                            Layout.preferredWidth: 35
                        }
                    }
                }
            }

            // ── Vignette ───────────────────────────────────────────
            EffectCard {
                title: "Vignette"
                icon: "⚫"
                enabled: false

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Intensity:"
                            color: "#8B949E"
                            font.pixelSize: 11
                            Layout.preferredWidth: 60
                        }

                        Slider {
                            id: vignetteIntensity
                            Layout.fillWidth: true
                            from: 0.0
                            to: 1.0
                            value: 0.3
                            onValueChanged: bridge.setVignetteIntensity(value)
                        }

                        Text {
                            text: Math.round(vignetteIntensity.value * 100) + "%"
                            color: "#58A6FF"
                            font.pixelSize: 10
                            font.family: "JetBrains Mono, Cascadia Code, monospace"
                            Layout.preferredWidth: 35
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Softness:"
                            color: "#8B949E"
                            font.pixelSize: 11
                            Layout.preferredWidth: 60
                        }

                        Slider {
                            id: vignetteSoftness
                            Layout.fillWidth: true
                            from: 0.0
                            to: 1.0
                            value: 0.5
                            onValueChanged: bridge.setVignetteSoftness(value)
                        }

                        Text {
                            text: Math.round(vignetteSoftness.value * 100) + "%"
                            color: "#58A6FF"
                            font.pixelSize: 10
                            font.family: "JetBrains Mono, Cascadia Code, monospace"
                            Layout.preferredWidth: 35
                        }
                    }
                }
            }

            // ── Noise Reduction ────────────────────────────────────
            EffectCard {
                title: "Noise Reduction"
                icon: "🔇"
                enabled: false

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Strength:"
                            color: "#8B949E"
                            font.pixelSize: 11
                            Layout.preferredWidth: 60
                        }

                        Slider {
                            id: noiseStrength
                            Layout.fillWidth: true
                            from: 0.0
                            to: 1.0
                            value: 0.3
                            onValueChanged: bridge.setNoiseReductionStrength(value)
                        }

                        Text {
                            text: Math.round(noiseStrength.value * 100) + "%"
                            color: "#58A6FF"
                            font.pixelSize: 10
                            font.family: "JetBrains Mono, Cascadia Code, monospace"
                            Layout.preferredWidth: 35
                        }
                    }
                }
            }

            // ── Apply / Reset Buttons ──────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                VCButton {
                    text: "Apply All"
                    variant: "primary"
                    Layout.fillWidth: true
                    onClicked: bridge.applyAllEffects()
                }

                VCButton {
                    text: "Reset"
                    variant: "default"
                    Layout.preferredWidth: 80
                    onClicked: {
                        lutCombo.currentIndex = 0
                        lutIntensity.value = 0.8
                        sharpenAmount.value = 0.5
                        sharpenRadius.value = 1.0
                        vignetteIntensity.value = 0.3
                        vignetteSoftness.value = 0.5
                        noiseStrength.value = 0.3
                        bridge.resetAllEffects()
                    }
                }
            }
        }
    }

    // ── EffectCard component ───────────────────────────────────────
    component EffectCard: Rectangle {
        id: effectCard
        property string title: ""
        property string icon: ""
        property bool enabled: false

        Layout.fillWidth: true
        height: effectCard.enabled ? contentArea.height + 48 : 48
        radius: 8
        color: effectCard.enabled ? "#21262D" : "#161B22"
        border.color: effectCard.enabled ? "#1F6FEB55" : "#30363D"
        border.width: 1

        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: 150 } }

        // Header
        Rectangle {
            id: effectHeader
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 42
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Text {
                    text: effectCard.icon
                    font.pixelSize: 14
                }

                Text {
                    text: effectCard.title
                    color: effectCard.enabled ? "#E6EDF3" : "#8B949E"
                    font.pixelSize: 12
                    font.weight: effectCard.enabled ? Font.DemiBold : Font.Normal
                    Layout.fillWidth: true
                }

                VCToggleSwitch {
                    checked: effectCard.enabled
                    onCheckedChanged: effectCard.enabled = checked
                }
            }
        }

        // Content area
        Item {
            id: contentArea
            anchors.top: effectHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 80
            visible: effectCard.enabled
            clip: true
        }
    }
}
