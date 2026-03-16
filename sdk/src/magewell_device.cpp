/// @file magewell_device.cpp
/// @brief Magewell capture device implementation.
///
/// Updated for Magewell Capture SDK 3.3.1 compatibility.
/// Changes from 3.2.x:
/// - Uses MWCaptureInitInstance/MWCaptureExitInstance for SDK lifecycle
/// - Uses MWGetDevicePath + MWOpenChannelByPath instead of MWOpenChannelByIndex
/// - Uses MWGetChannelInfoByIndex for device enumeration
/// - Uses MWFOURCC_UYVY instead of deprecated FOURCC_UYV2

#include "visioncast_sdk/magewell_device.h"
#include "visioncast_sdk/sdk_error.h"
#include "visioncast_sdk/sdk_logger.h"

#ifdef HAS_MAGEWELL
#include "LibMWCapture/MWCapture.h"
#endif

#include <mutex>
#include <atomic>
#include <cstring>

static const char* TAG = "MagewellDevice";

#ifdef HAS_MAGEWELL
// Global SDK initialization counter for thread-safe reference counting.
// Multiple MagewellDevice/MagewellInput instances may coexist.
// These variables have external linkage and are shared with magewell_input.cpp.
std::atomic<int> s_sdkRefCount{0};
std::mutex s_sdkMutex;

/// Initialize the Magewell SDK if not already initialized.
static void initMagewellSDK() {
    std::lock_guard<std::mutex> lock(s_sdkMutex);
    if (s_sdkRefCount.fetch_add(1) == 0) {
        MWCaptureInitInstance();
        SDKLogger::info(TAG, "MWCaptureInitInstance() called");
    }
}

/// Exit the Magewell SDK if this is the last reference.
static void exitMagewellSDK() {
    std::lock_guard<std::mutex> lock(s_sdkMutex);
    if (s_sdkRefCount.fetch_sub(1) == 1) {
        MWCaptureExitInstance();
        SDKLogger::info(TAG, "MWCaptureExitInstance() called");
    }
}
#endif

struct MagewellDevice::Impl {
    bool isOpen = false;
    VideoMode currentMode;
    std::string name = "Magewell";
    std::mutex mutex;

#ifdef HAS_MAGEWELL
    HCHANNEL channel = nullptr;
    char devicePath[256] = {0};
#endif
};

MagewellDevice::MagewellDevice() : impl_(std::make_unique<Impl>()) {
#ifdef HAS_MAGEWELL
    initMagewellSDK();
#endif
}
MagewellDevice::~MagewellDevice() {
    close();
#ifdef HAS_MAGEWELL
    exitMagewellSDK();
#endif
}

bool MagewellDevice::open(const DeviceConfig& config) {
#ifdef HAS_MAGEWELL
    std::lock_guard<std::mutex> lock(impl_->mutex);
    SDKLogger::info(TAG, "Opening Magewell device index=" +
                         std::to_string(config.deviceIndex));
    MWRefreshDevice();
    int count = MWGetChannelCount();
    if (config.deviceIndex >= count) {
        SDKLogger::error(TAG, "Magewell device not found at index " +
                              std::to_string(config.deviceIndex));
        return false;
    }
    
    // SDK 3.3.1: Use MWGetDevicePath + MWOpenChannelByPath instead of MWOpenChannelByIndex
    char devicePath[256] = {0};
    MW_RESULT pathResult = MWGetDevicePath(config.deviceIndex, devicePath);
    if (pathResult != MW_SUCCEEDED) {
        SDKLogger::error(TAG, "MWGetDevicePath failed for index " +
                              std::to_string(config.deviceIndex));
        return false;
    }
    std::strncpy(impl_->devicePath, devicePath, sizeof(impl_->devicePath) - 1);
    
    impl_->channel = MWOpenChannelByPath(devicePath);
    if (!impl_->channel) {
        SDKLogger::error(TAG, "MWOpenChannelByPath failed for path: " +
                              std::string(devicePath));
        return false;
    }
    
    // SDK 3.3.1: Use MWGetChannelInfoByIndex for enumeration info
    MWCAP_CHANNEL_INFO info;
    if (MWGetChannelInfoByIndex(config.deviceIndex, &info) == MW_SUCCEEDED) {
        impl_->name = config.name.empty()
                      ? std::string(info.szProductName)
                      : config.name;
    } else {
        impl_->name = config.name.empty() ? "Magewell" : config.name;
    }
    impl_->isOpen = true;
    SDKLogger::info(TAG, "Device opened: " + impl_->name);
    return true;
#else
    SDKLogger::warn(TAG, "Magewell SDK not available — device will not open");
    return false;
#endif
}

void MagewellDevice::close() {
    std::lock_guard<std::mutex> lock(impl_->mutex);
    if (!impl_->isOpen) return;
    SDKLogger::info(TAG, "Closing Magewell device: " + impl_->name);
#ifdef HAS_MAGEWELL
    if (impl_->channel) {
        MWCloseChannel(impl_->channel);
        impl_->channel = nullptr;
    }
#endif
    impl_->isOpen = false;
    SDKLogger::info(TAG, "Device closed");
}

bool MagewellDevice::isOpen() const { return impl_->isOpen; }
std::string MagewellDevice::deviceName() const { return impl_->name; }
DeviceType MagewellDevice::deviceType() const { return DeviceType::CAPTURE; }

std::vector<VideoMode> MagewellDevice::supportedModes() const {
    return {
        {1920, 1080, 25.0,   PixelFormat::UYVY, false},
        {1920, 1080, 29.97,  PixelFormat::UYVY, false},
        {1920, 1080, 50.0,   PixelFormat::UYVY, false},
        {1920, 1080, 59.94,  PixelFormat::UYVY, false},
        {3840, 2160, 25.0,   PixelFormat::UYVY, false},
        {3840, 2160, 29.97,  PixelFormat::UYVY, false},
    };
}

bool MagewellDevice::startCapture(const VideoMode& /*mode*/) {
    SDKLogger::debug(TAG, "startCapture() — use MagewellInput for capture");
    return false;
}
bool MagewellDevice::stopCapture() { return false; }
VideoFrame MagewellDevice::captureFrame() { return VideoFrame{}; }
bool MagewellDevice::startPlayout(const VideoMode& /*mode*/) { return false; }
bool MagewellDevice::stopPlayout() { return false; }
bool MagewellDevice::sendFrame(const VideoFrame& /*frame*/) { return false; }
void MagewellDevice::setVideoMode(const VideoMode& mode) { impl_->currentMode = mode; }
VideoMode MagewellDevice::currentMode() const { return impl_->currentMode; }

std::vector<DeviceConfig> MagewellDevice::enumerateDevices() {
#ifdef HAS_MAGEWELL
    std::vector<DeviceConfig> devices;
    
    // Ensure SDK is initialized for enumeration
    initMagewellSDK();
    
    MWRefreshDevice();
    int count = MWGetChannelCount();
    for (int i = 0; i < count; ++i) {
        // SDK 3.3.1: Use MWGetDevicePath + MWOpenChannelByPath
        char devicePath[256] = {0};
        if (MWGetDevicePath(i, devicePath) != MW_SUCCEEDED) {
            continue;
        }
        
        HCHANNEL ch = MWOpenChannelByPath(devicePath);
        if (!ch) continue;
        
        // SDK 3.3.1: Use MWGetChannelInfoByIndex for device info
        MWCAP_CHANNEL_INFO info;
        DeviceConfig cfg;
        cfg.deviceIndex = i;
        if (MWGetChannelInfoByIndex(i, &info) == MW_SUCCEEDED)
            cfg.name = info.szProductName;
        else
            cfg.name = "Magewell";
        devices.push_back(cfg);
        MWCloseChannel(ch);
    }
    
    // Release SDK reference from enumeration
    exitMagewellSDK();
    
    SDKLogger::info(TAG, "enumerateDevices() found " +
                         std::to_string(devices.size()) + " Magewell device(s)");
    return devices;
#endif
    SDKLogger::debug(TAG, "enumerateDevices() — no Magewell SDK, returning empty list");
    return {};
}

