#pragma once

/// @file qml_bridge.h
/// @brief C++ ↔ QML bridge that exposes VisionCast backend services to the
///        QML UI engine via Q_PROPERTY, Q_INVOKABLE, and signals.
///
/// VisionCast-AI — Licence officielle Prestige Technologie Company,
/// développée par Glody Dimputu Ngola.

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QTimer>
#include <atomic>
#include <memory>

namespace visioncast_ui {

class LicenseManager;
class PythonLauncher;

/// Bridge between the QML frontend and the C++ backend.
///
/// An instance of this class is registered as a QML context property
/// (name: "bridge") in main_qml.cpp.  All C++ backend logic stays in
/// existing classes; QmlBridge merely wires them together and converts
/// data to/from QVariant types that QML understands.
class QmlBridge : public QObject {
    Q_OBJECT

    // ── Runtime state ──────────────────────────────────────────────
    Q_PROPERTY(bool   engineRunning  READ isEngineRunning  NOTIFY engineStatusChanged)
    Q_PROPERTY(bool   aiConnected    READ isAiConnected    NOTIFY aiStatusChanged)
    Q_PROPERTY(int    fps            READ currentFps       NOTIFY fpsChanged)
    Q_PROPERTY(double cpuUsage       READ cpuUsage         NOTIFY metricsChanged)
    Q_PROPERTY(double gpuUsage       READ gpuUsage         NOTIFY metricsChanged)
    Q_PROPERTY(double memoryUsage    READ memoryUsage      NOTIFY metricsChanged)
    Q_PROPERTY(QString currentTalent READ currentTalent    NOTIFY talentChanged)
    Q_PROPERTY(bool   isLive         READ isLive           NOTIFY liveStatusChanged)
    Q_PROPERTY(bool   licenseValid   READ isLicenseValid   NOTIFY licenseStatusChanged)

    // ── Data lists ─────────────────────────────────────────────────
    Q_PROPERTY(QVariantList videoSources      READ videoSources      NOTIFY sourcesChanged)
    Q_PROPERTY(QVariantList talents           READ talents           NOTIFY talentsChanged)
    Q_PROPERTY(QVariantList overlayTemplates  READ overlayTemplates  NOTIFY overlaysChanged)
    Q_PROPERTY(QVariantList outputConfigs     READ outputConfigs     NOTIFY outputsChanged)
    Q_PROPERTY(QVariantList rtmpStreams        READ rtmpStreams        NOTIFY rtmpStreamsChanged)

public:
    explicit QmlBridge(QObject* parent = nullptr);
    ~QmlBridge() override;

    // ── Property accessors ─────────────────────────────────────────
    bool    isEngineRunning() const;
    bool    isAiConnected()   const;
    int     currentFps()      const;
    double  cpuUsage()        const;
    double  gpuUsage()        const;
    double  memoryUsage()     const;
    QString currentTalent()   const;
    bool    isLive()          const;
    bool    isLicenseValid()  const;

    QVariantList videoSources()     const;
    QVariantList talents()          const;
    QVariantList overlayTemplates() const;
    QVariantList outputConfigs()    const;
    QVariantList rtmpStreams()      const;

    // ── Invokable methods (callable from QML) ──────────────────────

    /// Select a video source by index in the videoSources list.
    Q_INVOKABLE void selectSource(int index);

    /// Start the broadcast engine (begin processing video).
    Q_INVOKABLE void startEngine();

    /// Stop the broadcast engine.
    Q_INVOKABLE void stopEngine();

    /// Toggle the LIVE broadcast output on.
    Q_INVOKABLE void goLive();

    /// Stop the LIVE broadcast output.
    Q_INVOKABLE void stopBroadcast();

    /// Enable or disable an overlay by its unique ID.
    Q_INVOKABLE void toggleOverlay(const QString& overlayId);

    /// Set the active talent by ID.
    Q_INVOKABLE void selectTalent(const QString& talentId);

    /// Re-scan hardware devices and refresh videoSources.
    Q_INVOKABLE void refreshSources();

    /// Activate a license key.
    Q_INVOKABLE void activateLicense(const QString& key);

    /// Return a snapshot of the current system status as a map.
    Q_INVOKABLE QVariantMap getSystemStatus();

    // ── Multi-streaming invokables ─────────────────────────────────

    /// Add a new RTMP stream. Returns the generated stream ID.
    Q_INVOKABLE QString addRtmpStream(const QString& name,
                                      const QString& platform,
                                      const QString& url,
                                      const QString& key);

    /// Remove an RTMP stream by ID (stops it first if active).
    Q_INVOKABLE void removeRtmpStream(const QString& id);

    /// Update RTMP stream configuration (only when Idle or Error).
    Q_INVOKABLE void updateRtmpStream(const QString& id,
                                      const QString& name,
                                      const QString& url,
                                      const QString& key);

    /// Start an RTMP stream asynchronously.
    Q_INVOKABLE void startRtmpStream(const QString& id);

    /// Stop an RTMP stream.
    Q_INVOKABLE void stopRtmpStream(const QString& id);

    /// Stop all active RTMP streams.
    Q_INVOKABLE void stopAllRtmpStreams();

    /// Persist current RTMP stream list to the session config.
    Q_INVOKABLE void saveRtmpConfig();

    /// Reload RTMP stream list from the session config.
    Q_INVOKABLE void loadRtmpConfig();

    // ── Project import/export ──────────────────────────────────────

    /// Import a project configuration from file.
    Q_INVOKABLE void importProject();

    /// Export the current project configuration to file.
    Q_INVOKABLE void exportProject();

    // ── Theme and design management ────────────────────────────────

    /// Set the application theme (Dark, Light, Ocean, Prestige).
    Q_INVOKABLE void setTheme(const QString& theme);

    /// Set the accent color for UI elements.
    Q_INVOKABLE void setAccentColor(const QString& color);

    /// Set the graphics template (Default, Barred, Minimal, etc.).
    Q_INVOKABLE void setGraphicsTemplate(const QString& templateName);

    /// Export design settings to file.
    Q_INVOKABLE void exportDesignSettings();

    /// Import design settings from file.
    Q_INVOKABLE void importDesignSettings();

    // ── Talent management ──────────────────────────────────────────

    /// Add a new talent to the database.
    Q_INVOKABLE void addTalent(const QString& name, const QString& role,
                               const QString& organisation, const QString& photo);

    /// Update an existing talent.
    Q_INVOKABLE void updateTalent(const QString& id, const QString& name,
                                  const QString& role, const QString& organisation,
                                  const QString& photo);

    /// Remove a talent from the database.
    Q_INVOKABLE void removeTalent(const QString& id);

    // ── Overlay management ─────────────────────────────────────────

    /// Update overlay properties.
    Q_INVOKABLE void updateOverlay(const QString& id, const QString& title,
                                   const QString& subtitle, const QString& style,
                                   const QString& color, const QString& entryAnim,
                                   const QString& exitAnim, int duration);

    // ── Channel profile management ─────────────────────────────────

    /// Create a new channel profile.
    Q_INVOKABLE void newChannelProfile();

    /// Load a channel profile from file.
    Q_INVOKABLE void loadChannelProfile();

    /// Save the current channel profile.
    Q_INVOKABLE void saveChannelProfile();

    // ── Settings dialogs (stub implementations) ────────────────────

    Q_INVOKABLE void openVideoEngineSettings();
    Q_INVOKABLE void openAudioRoutingSettings();
    Q_INVOKABLE void openDeckLinkSettings();
    Q_INVOKABLE void openNdiSettings();
    Q_INVOKABLE void openSrtRtmpInputSettings();
    Q_INVOKABLE void openOutputRoutingSettings();
    Q_INVOKABLE void openFaceRecognitionSettings();
    Q_INVOKABLE void openTalentDatabase();
    Q_INVOKABLE void openAutoOverlayRules();
    Q_INVOKABLE void openAiDiagnostics();
    Q_INVOKABLE void openOverlayTemplates();
    Q_INVOKABLE void openLowerThirdEditor();
    Q_INVOKABLE void openBrandingSettings();
    Q_INVOKABLE void openLutManager();
    Q_INVOKABLE void openEffectsPipeline();
    Q_INVOKABLE void openYouTubeSetup();
    Q_INVOKABLE void openFacebookSetup();
    Q_INVOKABLE void openTwitchSetup();
    Q_INVOKABLE void openRtmpProfiles();
    Q_INVOKABLE void openMultiStreamPresets();
    Q_INVOKABLE void openEncoderSettings();
    Q_INVOKABLE void openSystemMonitor();
    Q_INVOKABLE void openNetworkDiagnostics();
    Q_INVOKABLE void openLogViewer();
    Q_INVOKABLE void openBackupRestore();

    // ── Video effects pipeline ─────────────────────────────────────

    /// Load a custom LUT file (.cube).
    Q_INVOKABLE void loadLutFile(const QString& filePath);

    /// Set the LUT preset (None, Cinema Warm, etc.).
    Q_INVOKABLE void setLutPreset(const QString& preset);

    /// Set the LUT preset intensity (0.0–1.0).
    Q_INVOKABLE void setLutIntensity(double value);

    /// Set the custom LUT intensity (0.0–1.0).
    Q_INVOKABLE void setCustomLutIntensity(double value);

    /// Set exposure value (-2.0 to +2.0 EV).
    Q_INVOKABLE void setExposure(double value);

    /// Set contrast value (-100 to +100).
    Q_INVOKABLE void setContrast(double value);

    /// Set saturation value (-100 to +100).
    Q_INVOKABLE void setSaturation(double value);

    /// Set color temperature value (-100 to +100).
    Q_INVOKABLE void setTemperature(double value);

    /// Set sharpen amount (0.0–2.0).
    Q_INVOKABLE void setSharpenAmount(double value);

    /// Set sharpen radius (0.5–3.0 px).
    Q_INVOKABLE void setSharpenRadius(double value);

    /// Set vignette intensity (0.0–1.0).
    Q_INVOKABLE void setVignetteIntensity(double value);

    /// Set vignette softness (0.0–1.0).
    Q_INVOKABLE void setVignetteSoftness(double value);

    /// Set noise reduction strength (0.0–1.0).
    Q_INVOKABLE void setNoiseReductionStrength(double value);

    /// Show/hide title safe area overlay.
    Q_INVOKABLE void setTitleSafeVisible(bool visible);

    /// Show/hide action safe area overlay.
    Q_INVOKABLE void setActionSafeVisible(bool visible);

    /// Set safe area guide color.
    Q_INVOKABLE void setSafeAreaColor(const QString& color);

    /// Apply all current effects to the video pipeline.
    Q_INVOKABLE void applyAllEffects();

    /// Reset all effects to default values.
    Q_INVOKABLE void resetAllEffects();

    // ── Broadcast settings ─────────────────────────────────────────

    /// Set default output resolution.
    Q_INVOKABLE void setDefaultResolution(const QString& resolution);

    /// Set default frame rate.
    Q_INVOKABLE void setDefaultFrameRate(const QString& frameRate);

    /// Set default video bitrate.
    Q_INVOKABLE void setDefaultBitrate(const QString& bitrate);

    // ── AI settings ────────────────────────────────────────────────

    /// Enable/disable automatic overlay triggering.
    Q_INVOKABLE void setAutoOverlayEnabled(bool enabled);

    /// Set minimum confidence threshold for face recognition.
    Q_INVOKABLE void setMinConfidence(double value);

    // ── Performance settings ───────────────────────────────────────

    /// Enable/disable hardware acceleration.
    Q_INVOKABLE void setHardwareAcceleration(bool enabled);

    /// Set preview quality mode.
    Q_INVOKABLE void setPreviewQuality(const QString& quality);

    /// Save all application settings.
    Q_INVOKABLE void saveSettings();

    /// Reset all settings to defaults.
    Q_INVOKABLE void resetSettings();

signals:
    void engineStatusChanged();
    void aiStatusChanged();
    void fpsChanged();
    void metricsChanged();
    void talentChanged();
    void liveStatusChanged();
    void licenseStatusChanged();
    void sourcesChanged();
    void talentsChanged();
    void overlaysChanged();
    void outputsChanged();
    void rtmpStreamsChanged();

    /// Emitted whenever a single RTMP stream changes status.
    void rtmpStreamStatusChanged(const QString& id,
                                 const QString& status,
                                 const QString& message);

    /// Generic notification for the QML UI (e.g. toast messages).
    void notification(const QString& message, const QString& level);

private slots:
    void onMetricsTimer();
    void onAiStarted();
    void onAiStopped();
    void onLicenseValidation(bool valid, const QString& message);

private:
    void initLicense();
    void initPython();
    void populateDemoData();
    void populateDefaultRtmpStreams();
    void refreshMetrics();
    void refreshRtmpStreams();

    LicenseManager* licenseManager_  = nullptr;
    PythonLauncher* pythonLauncher_   = nullptr;

    bool    engineRunning_ = false;
    bool    aiConnected_   = false;
    bool    isLive_        = false;
    bool    licenseValid_  = false;
    int     fps_           = 0;
    double  cpuUsage_      = 0.0;
    double  gpuUsage_      = 0.0;
    double  memoryUsage_   = 0.0;
    QString currentTalent_;
    QString currentTheme_       = QStringLiteral("Dark");
    QString currentAccentColor_ = QStringLiteral("#1F6FEB");
    QString currentTemplate_    = QStringLiteral("Default");
    int     selectedSourceIndex_ = -1;
    std::atomic<int> nextTalentId_{100};

    QVariantList videoSources_;
    QVariantList talents_;
    QVariantList overlayTemplates_;
    QVariantList outputConfigs_;
    QVariantList rtmpStreams_;

    QTimer* metricsTimer_ = nullptr;

    struct RtmpImpl;
    std::unique_ptr<RtmpImpl> rtmpImpl_;
};

} // namespace visioncast_ui

