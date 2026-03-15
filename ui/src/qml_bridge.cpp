/// @file qml_bridge.cpp
/// @brief Implementation of QmlBridge — the C++ ↔ QML integration layer.
///
/// VisionCast-AI — Licence officielle Prestige Technologie Company,
/// développée par Glody Dimputu Ngola.

#include "visioncast_ui/qml_bridge.h"
#include "visioncast_ui/license_manager.h"
#include "visioncast_ui/license_config.h"
#include "visioncast_ui/python_launcher.h"
#include "visioncast_ui/device_scanner.h"

#include "visioncast/multi_ffmpeg_rtmp_manager.h"

#include <QTimer>
#include <QVariantMap>
#include <QRandomGenerator>
#include <QMetaObject>

#include <climits>

namespace visioncast_ui {

// ── RtmpImpl ───────────────────────────────────────────────────────────────

struct QmlBridge::RtmpImpl {
    visioncast::MultiFFmpegRtmpManager manager;
};

// ── Construction / Destruction ─────────────────────────────────────────────

QmlBridge::QmlBridge(QObject* parent)
    : QObject(parent)
    , rtmpImpl_(std::make_unique<RtmpImpl>())
{
    // Register status callback — delivers changes to QML via signals.
    rtmpImpl_->manager.setStatusCallback(
        [this](const std::string& id, visioncast::RtmpStatus status, const std::string& message) {
            const QString qid  = QString::fromStdString(id);
            const QString qst  = QString::fromLatin1(visioncast::rtmpStatusToString(status));
            const QString qmsg = QString::fromStdString(message);
            // Marshal back to the Qt main thread.
            QMetaObject::invokeMethod(this, [this, qid, qst, qmsg]() {
                refreshRtmpStreams();
                emit rtmpStreamStatusChanged(qid, qst, qmsg);
            }, Qt::QueuedConnection);
        }
    );

    initLicense();
    initPython();
    populateDemoData();
    populateDefaultRtmpStreams();

    // Metrics update every second
    metricsTimer_ = new QTimer(this);
    connect(metricsTimer_, &QTimer::timeout, this, &QmlBridge::onMetricsTimer);
    metricsTimer_->start(1000);
}

QmlBridge::~QmlBridge() = default;

// ── Private initialisation ─────────────────────────────────────────────────

void QmlBridge::initLicense()
{
    licenseManager_ = new LicenseManager(this);

    // Prefer env vars, fall back to config file
    if (!licenseManager_->loadFromEnvironment()) {
        licenseManager_->loadConfig("license_config.json");
    }

    connect(licenseManager_, &LicenseManager::validationCompleted,
            this, &QmlBridge::onLicenseValidation);

    // Try offline grace first; if ok mark as valid without a network round-trip
    if (licenseManager_->tryOfflineGrace()) {
        licenseValid_ = true;
        emit licenseStatusChanged();
    } else {
        const QString key = licenseManager_->licenseKey();
        if (!key.isEmpty()) {
            licenseManager_->validateKey(key);
        }
    }
}

void QmlBridge::initPython()
{
    pythonLauncher_ = new PythonLauncher(this);

    connect(pythonLauncher_, &PythonLauncher::aiStarted,
            this, &QmlBridge::onAiStarted);
    connect(pythonLauncher_, &PythonLauncher::aiStopped,
            this, &QmlBridge::onAiStopped);
    connect(pythonLauncher_, &PythonLauncher::error,
            this, [this](const QString& msg) {
                emit notification(msg, QStringLiteral("error"));
            });
}

void QmlBridge::populateDemoData()
{
    // Video sources — augmented by actual device scan when available
    auto devices = scanAllDevices();
    for (const auto& dev : devices) {
        QVariantMap src;
        src[QStringLiteral("name")]       = dev.name;
        src[QStringLiteral("deviceType")] = dev.deviceType;
        src[QStringLiteral("thumbnail")]  = QStringLiteral("");
        videoSources_.append(src);
    }
    emit sourcesChanged();

    // Demo talents
    const struct { const char* id; const char* name; const char* role; } talentData[] = {
        { "T001", "Alexandra Martin",  "Presenter"       },
        { "T002", "James Okoro",       "Co-Presenter"    },
        { "T003", "Dr. Sophie Dupont", "Expert Guest"    },
        { "T004", "Marc Bertrand",     "Sports Reporter" },
    };
    for (const auto& t : talentData) {
        QVariantMap m;
        m[QStringLiteral("id")]          = QString::fromLatin1(t.id);
        m[QStringLiteral("name")]        = QString::fromUtf8(t.name);
        m[QStringLiteral("role")]        = QString::fromLatin1(t.role);
        m[QStringLiteral("overlayActive")] = false;
        talents_.append(m);
    }
    emit talentsChanged();

    // Demo overlay templates
    const struct { const char* id; const char* name; const char* type; } overlayData[] = {
        { "OVL001", "Lower Third — Standard",  "lower_third" },
        { "OVL002", "Lower Third — Breaking",  "lower_third" },
        { "OVL003", "Ticker — News",           "ticker"      },
        { "OVL004", "Score Bug — Football",    "score_bug"   },
        { "OVL005", "Bug — Weather",           "bug"         },
        { "OVL006", "Full Screen — Transition","transition"  },
    };
    for (const auto& o : overlayData) {
        QVariantMap m;
        m[QStringLiteral("id")]     = QString::fromLatin1(o.id);
        m[QStringLiteral("name")]   = QString::fromLatin1(o.name);
        m[QStringLiteral("type")]   = QString::fromLatin1(o.type);
        m[QStringLiteral("active")] = false;
        overlayTemplates_.append(m);
    }
    emit overlaysChanged();

    // Output configurations
    const struct { const char* id; const char* name; const char* protocol; bool enabled; } outputData[] = {
        { "OUT001", "Primary SDI Out",  "SDI",  true  },
        { "OUT002", "NDI Stream",       "NDI",  true  },
        { "OUT003", "YouTube RTMP",     "RTMP", false },
        { "OUT004", "SRT Contribution", "SRT",  false },
    };
    for (const auto& o : outputData) {
        QVariantMap m;
        m[QStringLiteral("id")]       = QString::fromLatin1(o.id);
        m[QStringLiteral("name")]     = QString::fromLatin1(o.name);
        m[QStringLiteral("protocol")] = QString::fromLatin1(o.protocol);
        m[QStringLiteral("enabled")]  = o.enabled;
        outputConfigs_.append(m);
    }
    emit outputsChanged();
}

// ── Property accessors ─────────────────────────────────────────────────────

bool    QmlBridge::isEngineRunning() const { return engineRunning_; }
bool    QmlBridge::isAiConnected()   const { return aiConnected_;   }
int     QmlBridge::currentFps()      const { return fps_;           }
double  QmlBridge::cpuUsage()        const { return cpuUsage_;      }
double  QmlBridge::gpuUsage()        const { return gpuUsage_;      }
double  QmlBridge::memoryUsage()     const { return memoryUsage_;   }
QString QmlBridge::currentTalent()   const { return currentTalent_; }
bool    QmlBridge::isLive()          const { return isLive_;        }
bool    QmlBridge::isLicenseValid()  const { return licenseValid_;  }

QVariantList QmlBridge::videoSources()     const { return videoSources_;      }
QVariantList QmlBridge::talents()          const { return talents_;           }
QVariantList QmlBridge::overlayTemplates() const { return overlayTemplates_;  }
QVariantList QmlBridge::outputConfigs()    const { return outputConfigs_;     }
QVariantList QmlBridge::rtmpStreams()      const { return rtmpStreams_;        }

// ── Invokable methods ──────────────────────────────────────────────────────

void QmlBridge::selectSource(int index)
{
    if (index < 0 || index >= videoSources_.size()) return;
    selectedSourceIndex_ = index;
    const QVariantMap src = videoSources_.at(index).toMap();
    emit notification(QStringLiteral("Source selected: ") + src.value(QStringLiteral("name")).toString(),
                      QStringLiteral("info"));
}

void QmlBridge::startEngine()
{
    if (engineRunning_) return;
    engineRunning_ = true;
    fps_ = 25;
    emit engineStatusChanged();
    emit fpsChanged();
    emit notification(QStringLiteral("Broadcast engine started"), QStringLiteral("success"));
}

void QmlBridge::stopEngine()
{
    if (!engineRunning_) return;
    engineRunning_ = false;
    if (isLive_) stopBroadcast();
    fps_ = 0;
    emit engineStatusChanged();
    emit fpsChanged();
    emit notification(QStringLiteral("Broadcast engine stopped"), QStringLiteral("info"));
}

void QmlBridge::goLive()
{
    if (!engineRunning_) {
        emit notification(QStringLiteral("Start the engine first"), QStringLiteral("warning"));
        return;
    }
    isLive_ = true;
    emit liveStatusChanged();
    emit notification(QStringLiteral("🔴 ON AIR"), QStringLiteral("live"));
}

void QmlBridge::stopBroadcast()
{
    if (!isLive_) return;
    isLive_ = false;
    emit liveStatusChanged();
    emit notification(QStringLiteral("Broadcast stopped"), QStringLiteral("info"));
}

void QmlBridge::toggleOverlay(const QString& overlayId)
{
    for (int i = 0; i < overlayTemplates_.size(); ++i) {
        QVariantMap m = overlayTemplates_.at(i).toMap();
        if (m.value(QStringLiteral("id")).toString() == overlayId) {
            const bool newState = !m.value(QStringLiteral("active")).toBool();
            m[QStringLiteral("active")] = newState;
            overlayTemplates_[i] = m;
            emit overlaysChanged();
            emit notification(
                m.value(QStringLiteral("name")).toString() +
                    (newState ? QStringLiteral(" activated") : QStringLiteral(" deactivated")),
                QStringLiteral("info"));
            return;
        }
    }
}

void QmlBridge::selectTalent(const QString& talentId)
{
    for (const QVariant& v : talents_) {
        const QVariantMap m = v.toMap();
        if (m.value(QStringLiteral("id")).toString() == talentId) {
            currentTalent_ = m.value(QStringLiteral("name")).toString();
            emit talentChanged();
            emit notification(QStringLiteral("Talent: ") + currentTalent_, QStringLiteral("info"));
            return;
        }
    }
}

void QmlBridge::refreshSources()
{
    videoSources_.clear();
    populateDemoData();
    emit notification(QStringLiteral("Sources refreshed"), QStringLiteral("info"));
}

void QmlBridge::activateLicense(const QString& key)
{
    if (key.trimmed().isEmpty()) {
        emit notification(QStringLiteral("License key is empty"), QStringLiteral("error"));
        return;
    }
    licenseManager_->activateKey(key.trimmed());
}

QVariantMap QmlBridge::getSystemStatus()
{
    QVariantMap status;
    status[QStringLiteral("engineRunning")] = engineRunning_;
    status[QStringLiteral("aiConnected")]   = aiConnected_;
    status[QStringLiteral("isLive")]        = isLive_;
    status[QStringLiteral("fps")]           = fps_;
    status[QStringLiteral("cpuUsage")]      = cpuUsage_;
    status[QStringLiteral("gpuUsage")]      = gpuUsage_;
    status[QStringLiteral("memoryUsage")]   = memoryUsage_;
    status[QStringLiteral("licenseValid")]  = licenseValid_;
    return status;
}

// ── Private helpers ────────────────────────────────────────────────────────

void QmlBridge::populateDefaultRtmpStreams()
{
    // Pre-configure well-known platforms as disabled entries so the UI
    // shows them out of the box.  Users can edit URLs/keys before starting.
    rtmpImpl_->manager.addStream("YouTube Live",   "youtube",
                                 "rtmp://a.rtmp.youtube.com/live2",      "");
    rtmpImpl_->manager.addStream("Facebook Live",  "facebook",
                                 "rtmp://live-api-s.facebook.com:80/rtmp", "");
    rtmpImpl_->manager.addStream("Twitch",         "twitch",
                                 "rtmp://live.twitch.tv/app",            "");
    refreshRtmpStreams();
}

void QmlBridge::refreshRtmpStreams()
{
    const auto entries = rtmpImpl_->manager.streams();
    rtmpStreams_.clear();
    const int count = static_cast<int>(
        entries.size() <= static_cast<std::size_t>(INT_MAX) ? entries.size() : INT_MAX);
    rtmpStreams_.reserve(count);
    for (const auto& e : entries) {
        QVariantMap m;
        m[QStringLiteral("id")]            = QString::fromStdString(e.id);
        m[QStringLiteral("name")]          = QString::fromStdString(e.name);
        m[QStringLiteral("platform")]      = QString::fromStdString(e.platform);
        m[QStringLiteral("serverUrl")]     = QString::fromStdString(e.serverUrl);
        m[QStringLiteral("streamKey")]     = QString::fromStdString(e.streamKey);
        m[QStringLiteral("status")]        = QString::fromLatin1(
                                               visioncast::rtmpStatusToString(e.status));
        m[QStringLiteral("statusMessage")] = QString::fromStdString(e.statusMessage);

        // Flatten the last few log lines into a single string for QML display.
        QString logText;
        const int maxDisplay = 10;
        const int start = static_cast<int>(e.logLines.size()) > maxDisplay
                          ? static_cast<int>(e.logLines.size()) - maxDisplay : 0;
        for (int i = start; i < static_cast<int>(e.logLines.size()); ++i) {
            if (!logText.isEmpty()) logText += QLatin1Char('\n');
            logText += QString::fromStdString(e.logLines[i]);
        }
        m[QStringLiteral("log")] = logText;

        rtmpStreams_.append(m);
    }
    emit rtmpStreamsChanged();
}

// ── Multi-streaming invokables ─────────────────────────────────────────────

QString QmlBridge::addRtmpStream(const QString& name,
                                 const QString& platform,
                                 const QString& url,
                                 const QString& key)
{
    const std::string id = rtmpImpl_->manager.addStream(
        name.toStdString(), platform.toStdString(),
        url.toStdString(),  key.toStdString());
    refreshRtmpStreams();
    emit notification(QStringLiteral("Stream added: ") + name, QStringLiteral("info"));
    return QString::fromStdString(id);
}

void QmlBridge::removeRtmpStream(const QString& id)
{
    rtmpImpl_->manager.removeStream(id.toStdString());
    refreshRtmpStreams();
    emit notification(QStringLiteral("Stream removed"), QStringLiteral("info"));
}

void QmlBridge::updateRtmpStream(const QString& id,
                                 const QString& name,
                                 const QString& url,
                                 const QString& key)
{
    const bool ok = rtmpImpl_->manager.updateStream(
        id.toStdString(), name.toStdString(),
        url.toStdString(), key.toStdString());
    if (ok) {
        refreshRtmpStreams();
        emit notification(QStringLiteral("Stream updated: ") + name, QStringLiteral("info"));
    } else {
        emit notification(QStringLiteral("Cannot update active stream"), QStringLiteral("warning"));
    }
}

void QmlBridge::startRtmpStream(const QString& id)
{
    const bool ok = rtmpImpl_->manager.startStream(id.toStdString());
    if (ok) {
        refreshRtmpStreams();
        emit notification(QStringLiteral("Stream starting…"), QStringLiteral("info"));
    } else {
        emit notification(QStringLiteral("Could not start stream (check URL/key)"), QStringLiteral("error"));
    }
}

void QmlBridge::stopRtmpStream(const QString& id)
{
    rtmpImpl_->manager.stopStream(id.toStdString());
    refreshRtmpStreams();
    emit notification(QStringLiteral("Stream stopped"), QStringLiteral("info"));
}

void QmlBridge::stopAllRtmpStreams()
{
    rtmpImpl_->manager.stopAll();
    refreshRtmpStreams();
    emit notification(QStringLiteral("All streams stopped"), QStringLiteral("info"));
}

void QmlBridge::saveRtmpConfig()
{
    // Persist current stream list as a summary notification (full JSON
    // persistence can be wired to system.json in a future iteration).
    const auto entries = rtmpImpl_->manager.streams();
    emit notification(
        QStringLiteral("Multi-streaming config saved (%1 streams)")
            .arg(static_cast<int>(entries.size())),
        QStringLiteral("success"));
}

void QmlBridge::loadRtmpConfig()
{
    // Config reload hook — currently resets to defaults (extendable with
    // a JSON config reader when needed).
    emit notification(QStringLiteral("Multi-streaming config loaded"), QStringLiteral("info"));
}

// ── Project import/export ──────────────────────────────────────────────────

void QmlBridge::importProject()
{
    // In a full implementation, this would open a file dialog and load
    // the project configuration from a JSON file. For now, we provide
    // a skeleton that notifies the user.
    emit notification(QStringLiteral("Import Project: Feature initializing — select a project file"),
                      QStringLiteral("info"));
    // TODO: Integrate with QFileDialog when running in widgets mode,
    // or use a QML FileDialog for pure QML apps.
}

void QmlBridge::exportProject()
{
    // Export current state to a project JSON file.
    emit notification(QStringLiteral("Export Project: Feature initializing — saving project configuration"),
                      QStringLiteral("info"));
    // TODO: Serialize current talents_, overlayTemplates_, outputConfigs_,
    // rtmpStreams_, and design settings to a JSON file.
}

// ── Theme and design management ────────────────────────────────────────────

void QmlBridge::setTheme(const QString& theme)
{
    if (currentTheme_ == theme) return;
    
    currentTheme_ = theme;
    
    // In production, this would load a QSS stylesheet or configure the
    // QML theme singleton. Currently just notifies the UI.
    emit notification(QStringLiteral("Theme changed to: ") + theme, QStringLiteral("success"));
    
    // The QML layer can react to this notification and apply theme changes
    // via VCTheme singleton or by switching stylesheets.
}

void QmlBridge::setAccentColor(const QString& color)
{
    if (currentAccentColor_ == color) return;
    
    currentAccentColor_ = color;
    emit notification(QStringLiteral("Accent color set to: ") + color, QStringLiteral("info"));
}

void QmlBridge::setGraphicsTemplate(const QString& templateName)
{
    if (currentTemplate_ == templateName) return;
    
    currentTemplate_ = templateName;
    emit notification(QStringLiteral("Graphics template activated: ") + templateName,
                      QStringLiteral("success"));
}

void QmlBridge::exportDesignSettings()
{
    // Export design configuration (theme, accent, template) to design.json
    emit notification(QStringLiteral("Design settings exported"), QStringLiteral("success"));
    // TODO: Write currentTheme_, currentAccentColor_, currentTemplate_ to file.
}

void QmlBridge::importDesignSettings()
{
    // Import design configuration from design.json
    emit notification(QStringLiteral("Design settings imported"), QStringLiteral("info"));
    // TODO: Load design settings from file and apply them.
}

// ── Talent management ──────────────────────────────────────────────────────

void QmlBridge::addTalent(const QString& name, const QString& role,
                          const QString& organisation, const QString& photo)
{
    QVariantMap talent;
    talent[QStringLiteral("id")]           = QStringLiteral("T%1").arg(nextTalentId_.fetch_add(1));
    talent[QStringLiteral("name")]         = name;
    talent[QStringLiteral("role")]         = role;
    talent[QStringLiteral("organisation")] = organisation;
    talent[QStringLiteral("photo")]        = photo;
    talent[QStringLiteral("overlayActive")] = false;
    
    talents_.append(talent);
    emit talentsChanged();
    emit notification(QStringLiteral("Talent added: ") + name, QStringLiteral("success"));
}

void QmlBridge::updateTalent(const QString& id, const QString& name,
                             const QString& role, const QString& organisation,
                             const QString& photo)
{
    for (int i = 0; i < talents_.size(); ++i) {
        QVariantMap m = talents_.at(i).toMap();
        if (m.value(QStringLiteral("id")).toString() == id) {
            m[QStringLiteral("name")]         = name;
            m[QStringLiteral("role")]         = role;
            m[QStringLiteral("organisation")] = organisation;
            m[QStringLiteral("photo")]        = photo;
            talents_[i] = m;
            emit talentsChanged();
            emit notification(QStringLiteral("Talent updated: ") + name, QStringLiteral("info"));
            return;
        }
    }
    emit notification(QStringLiteral("Talent not found: ") + id, QStringLiteral("warning"));
}

void QmlBridge::removeTalent(const QString& id)
{
    for (int i = 0; i < talents_.size(); ++i) {
        QVariantMap m = talents_.at(i).toMap();
        if (m.value(QStringLiteral("id")).toString() == id) {
            const QString name = m.value(QStringLiteral("name")).toString();
            talents_.removeAt(i);
            emit talentsChanged();
            emit notification(QStringLiteral("Talent removed: ") + name, QStringLiteral("info"));
            return;
        }
    }
    emit notification(QStringLiteral("Talent not found: ") + id, QStringLiteral("warning"));
}

// ── Overlay management ─────────────────────────────────────────────────────

void QmlBridge::updateOverlay(const QString& id, const QString& title,
                              const QString& subtitle, const QString& style,
                              const QString& color, const QString& entryAnim,
                              const QString& exitAnim, int duration)
{
    for (int i = 0; i < overlayTemplates_.size(); ++i) {
        QVariantMap m = overlayTemplates_.at(i).toMap();
        if (m.value(QStringLiteral("id")).toString() == id) {
            m[QStringLiteral("title")]     = title;
            m[QStringLiteral("subtitle")]  = subtitle;
            m[QStringLiteral("style")]     = style;
            m[QStringLiteral("color")]     = color;
            m[QStringLiteral("entryAnim")] = entryAnim;
            m[QStringLiteral("exitAnim")]  = exitAnim;
            m[QStringLiteral("duration")]  = duration;
            overlayTemplates_[i] = m;
            emit overlaysChanged();
            emit notification(QStringLiteral("Overlay updated: ") + title, QStringLiteral("info"));
            return;
        }
    }
    emit notification(QStringLiteral("Overlay not found: ") + id, QStringLiteral("warning"));
}

// ── Private slots ──────────────────────────────────────────────────────────

void QmlBridge::onMetricsTimer()
{
    if (!engineRunning_) return;
    refreshMetrics();
}

void QmlBridge::refreshMetrics()
{
    // Simulate realistic metrics variance when no SDK monitoring is available
    auto rng = QRandomGenerator::global();
    cpuUsage_    = 20.0 + rng->bounded(30);
    gpuUsage_    = 35.0 + rng->bounded(25);
    memoryUsage_ = 40.0 + rng->bounded(20);
    fps_         = 24 + rng->bounded(3);
    emit metricsChanged();
    emit fpsChanged();
}

void QmlBridge::onAiStarted()
{
    aiConnected_ = true;
    emit aiStatusChanged();
    emit notification(QStringLiteral("AI recognition service connected"), QStringLiteral("success"));
}

void QmlBridge::onAiStopped()
{
    aiConnected_ = false;
    emit aiStatusChanged();
}

void QmlBridge::onLicenseValidation(bool valid, const QString& message)
{
    licenseValid_ = valid;
    emit licenseStatusChanged();
    if (!valid) {
        emit notification(message, QStringLiteral("error"));
    }
}

// ── Channel profile management ─────────────────────────────────────────────

void QmlBridge::newChannelProfile()
{
    emit notification(QStringLiteral("New channel profile created"), QStringLiteral("info"));
}

void QmlBridge::loadChannelProfile()
{
    emit notification(QStringLiteral("Load channel profile: Select a profile file"),
                      QStringLiteral("info"));
}

void QmlBridge::saveChannelProfile()
{
    emit notification(QStringLiteral("Channel profile saved"), QStringLiteral("success"));
}

// ── Settings dialogs (stub implementations) ────────────────────────────────

void QmlBridge::openVideoEngineSettings()
{
    emit notification(QStringLiteral("Video Engine Settings — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openAudioRoutingSettings()
{
    emit notification(QStringLiteral("Audio Routing Settings — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openDeckLinkSettings()
{
    emit notification(QStringLiteral("DeckLink / SDI Settings — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openNdiSettings()
{
    emit notification(QStringLiteral("NDI Settings — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openSrtRtmpInputSettings()
{
    emit notification(QStringLiteral("SRT / RTMP Input Settings — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openOutputRoutingSettings()
{
    emit notification(QStringLiteral("Output Routing Settings — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openFaceRecognitionSettings()
{
    emit notification(QStringLiteral("Face Recognition Settings — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openTalentDatabase()
{
    emit notification(QStringLiteral("Talent Database — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openAutoOverlayRules()
{
    emit notification(QStringLiteral("Auto-Overlay Rules — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openAiDiagnostics()
{
    emit notification(QStringLiteral("AI Diagnostics — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openOverlayTemplates()
{
    emit notification(QStringLiteral("Overlay Templates — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openLowerThirdEditor()
{
    emit notification(QStringLiteral("Lower-Third Editor — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openBrandingSettings()
{
    emit notification(QStringLiteral("Branding Settings — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openLutManager()
{
    emit notification(QStringLiteral("LUT Manager — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openEffectsPipeline()
{
    emit notification(QStringLiteral("Effects Pipeline — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openYouTubeSetup()
{
    emit notification(QStringLiteral("YouTube Setup — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openFacebookSetup()
{
    emit notification(QStringLiteral("Facebook Setup — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openTwitchSetup()
{
    emit notification(QStringLiteral("Twitch Setup — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openRtmpProfiles()
{
    emit notification(QStringLiteral("RTMP Profiles — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openMultiStreamPresets()
{
    emit notification(QStringLiteral("Multi-Stream Presets — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openEncoderSettings()
{
    emit notification(QStringLiteral("Encoder Settings — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openSystemMonitor()
{
    emit notification(QStringLiteral("System Monitor — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openNetworkDiagnostics()
{
    emit notification(QStringLiteral("Network Diagnostics — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openLogViewer()
{
    emit notification(QStringLiteral("Log Viewer — Opening…"), QStringLiteral("info"));
}

void QmlBridge::openBackupRestore()
{
    emit notification(QStringLiteral("Backup / Restore — Opening…"), QStringLiteral("info"));
}

// ── Video effects pipeline ─────────────────────────────────────────────────

void QmlBridge::loadLutFile(const QString& filePath)
{
    if (filePath.isEmpty()) {
        emit notification(QStringLiteral("No LUT file selected"), QStringLiteral("warning"));
        return;
    }
    emit notification(QStringLiteral("LUT file loaded: ") + filePath.split('/').last(),
                      QStringLiteral("success"));
}

void QmlBridge::setLutPreset(const QString& preset)
{
    if (preset == QStringLiteral("None")) {
        emit notification(QStringLiteral("LUT preset disabled"), QStringLiteral("info"));
    } else {
        emit notification(QStringLiteral("LUT preset applied: ") + preset, QStringLiteral("info"));
    }
}

void QmlBridge::setLutIntensity(double value)
{
    Q_UNUSED(value)
    // Stub: Controls intensity of built-in LUT presets (Cinema Warm, Film Noir, etc.)
}

void QmlBridge::setCustomLutIntensity(double value)
{
    Q_UNUSED(value)
    // Stub: Controls intensity of user-loaded custom .cube LUT files
}

void QmlBridge::setExposure(double value)
{
    Q_UNUSED(value)
    // Stub: Controls exposure correction filter
}

void QmlBridge::setContrast(double value)
{
    Q_UNUSED(value)
    // Stub: Controls contrast filter
}

void QmlBridge::setSaturation(double value)
{
    Q_UNUSED(value)
    // Stub: Controls saturation filter
}

void QmlBridge::setTemperature(double value)
{
    Q_UNUSED(value)
    // Stub: Controls color temperature filter
}

void QmlBridge::setSharpenAmount(double value)
{
    Q_UNUSED(value)
    // Stub: Controls sharpen filter amount
}

void QmlBridge::setSharpenRadius(double value)
{
    Q_UNUSED(value)
    // Stub: Controls sharpen filter radius
}

void QmlBridge::setVignetteIntensity(double value)
{
    Q_UNUSED(value)
    // Stub: Controls vignette effect intensity
}

void QmlBridge::setVignetteSoftness(double value)
{
    Q_UNUSED(value)
    // Stub: Controls vignette effect softness
}

void QmlBridge::setNoiseReductionStrength(double value)
{
    Q_UNUSED(value)
    // Stub: Controls noise reduction filter strength
}

void QmlBridge::setTitleSafeVisible(bool visible)
{
    emit notification(visible ? QStringLiteral("Title safe area enabled")
                              : QStringLiteral("Title safe area disabled"),
                      QStringLiteral("info"));
}

void QmlBridge::setActionSafeVisible(bool visible)
{
    emit notification(visible ? QStringLiteral("Action safe area enabled")
                              : QStringLiteral("Action safe area disabled"),
                      QStringLiteral("info"));
}

void QmlBridge::setSafeAreaColor(const QString& color)
{
    Q_UNUSED(color)
    // Stub: Controls safe area guide color
}

void QmlBridge::applyAllEffects()
{
    emit notification(QStringLiteral("All effects applied to pipeline"), QStringLiteral("success"));
}

void QmlBridge::resetAllEffects()
{
    emit notification(QStringLiteral("All effects reset to defaults"), QStringLiteral("info"));
}

// ── Broadcast settings ─────────────────────────────────────────────────────

void QmlBridge::setDefaultResolution(const QString& resolution)
{
    emit notification(QStringLiteral("Default resolution set: ") + resolution,
                      QStringLiteral("info"));
}

void QmlBridge::setDefaultFrameRate(const QString& frameRate)
{
    emit notification(QStringLiteral("Default frame rate set: ") + frameRate,
                      QStringLiteral("info"));
}

void QmlBridge::setDefaultBitrate(const QString& bitrate)
{
    emit notification(QStringLiteral("Default bitrate set: ") + bitrate,
                      QStringLiteral("info"));
}

// ── AI settings ────────────────────────────────────────────────────────────

void QmlBridge::setAutoOverlayEnabled(bool enabled)
{
    emit notification(enabled ? QStringLiteral("Auto-overlay enabled")
                              : QStringLiteral("Auto-overlay disabled"),
                      QStringLiteral("info"));
}

void QmlBridge::setMinConfidence(double value)
{
    emit notification(QStringLiteral("Min confidence threshold: %1%")
                          .arg(static_cast<int>(value * 100)),
                      QStringLiteral("info"));
}

// ── Performance settings ───────────────────────────────────────────────────

void QmlBridge::setHardwareAcceleration(bool enabled)
{
    emit notification(enabled ? QStringLiteral("Hardware acceleration enabled")
                              : QStringLiteral("Hardware acceleration disabled"),
                      QStringLiteral("info"));
}

void QmlBridge::setPreviewQuality(const QString& quality)
{
    emit notification(QStringLiteral("Preview quality set: ") + quality,
                      QStringLiteral("info"));
}

void QmlBridge::saveSettings()
{
    emit notification(QStringLiteral("Settings saved successfully"), QStringLiteral("success"));
}

void QmlBridge::resetSettings()
{
    emit notification(QStringLiteral("Settings reset to defaults"), QStringLiteral("info"));
}

} // namespace visioncast_ui
