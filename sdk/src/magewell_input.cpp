/// @file magewell_input.cpp
/// @brief Magewell capture-only implementation.
///
/// Updated for Magewell Capture SDK 3.3.1 compatibility.
/// Changes from 3.2.x:
/// - Uses MWCaptureInitInstance/MWCaptureExitInstance for SDK lifecycle
/// - Uses MWGetDevicePath + MWOpenChannelByPath instead of MWOpenChannelByIndex
/// - Uses MWGetChannelInfoByIndex for device enumeration
/// - Uses MWFOURCC_UYVY instead of deprecated FOURCC_UYV2

#include "visioncast_sdk/magewell_input.h"
#include "visioncast_sdk/sdk_error.h"
#include "visioncast_sdk/sdk_logger.h"

#ifdef HAS_MAGEWELL
#include "LibMWCapture/MWCapture.h"
#ifdef _WIN32
#include <windows.h>
#else
// Non-Windows platforms need alternate event handling
#include <unistd.h>
#include <fcntl.h>
#include <sys/eventfd.h>
#include <sys/select.h>
#endif
#endif

#include <mutex>
#include <vector>
#include <atomic>
#include <cstring>

static const char* TAG = "MagewellInput";

#ifdef HAS_MAGEWELL
// Global SDK initialization counter for thread-safe reference counting.
// Multiple MagewellDevice/MagewellInput instances may coexist.
// Note: These are shared with magewell_device.cpp when both are linked.
extern std::atomic<int> s_sdkRefCount;
extern std::mutex s_sdkMutex;

/// Initialize the Magewell SDK if not already initialized.
static void initMagewellInputSDK() {
    std::lock_guard<std::mutex> lock(s_sdkMutex);
    if (s_sdkRefCount.fetch_add(1) == 0) {
        MWCaptureInitInstance();
        SDKLogger::info(TAG, "MWCaptureInitInstance() called");
    }
}

/// Exit the Magewell SDK if this is the last reference.
static void exitMagewellInputSDK() {
    std::lock_guard<std::mutex> lock(s_sdkMutex);
    if (s_sdkRefCount.fetch_sub(1) == 1) {
        MWCaptureExitInstance();
        SDKLogger::info(TAG, "MWCaptureExitInstance() called");
    }
}
#endif

struct MagewellInput::Impl {
    bool isOpen = false;
    bool capturing = false;
    VideoMode currentMode;
    std::string name = "Magewell Input";
    std::mutex mutex;

    // Frame buffer owned by us; size = stride * height.
    std::vector<uint8_t> frameBuf;

#ifdef HAS_MAGEWELL
    HCHANNEL channel    = nullptr;
    char devicePath[256] = {0};
#ifdef _WIN32
    HANDLE   notifyEvent = nullptr;
#else
    // Linux/macOS: use file descriptor for event notification
    int      notifyFd    = -1;
#endif
#endif
};

MagewellInput::MagewellInput() : impl_(std::make_unique<Impl>()) {
#ifdef HAS_MAGEWELL
    initMagewellInputSDK();
#endif
}
MagewellInput::~MagewellInput() {
    close();
#ifdef HAS_MAGEWELL
    exitMagewellInputSDK();
#endif
}

bool MagewellInput::open(const DeviceConfig& config) {
#ifdef HAS_MAGEWELL
    std::lock_guard<std::mutex> lock(impl_->mutex);
    SDKLogger::info(TAG, "Opening Magewell capture device index=" +
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
    
    // SDK 3.3.1: Use MWGetChannelInfoByIndex for device info
    MWCAP_CHANNEL_INFO info;
    if (MWGetChannelInfoByIndex(config.deviceIndex, &info) == MW_SUCCEEDED) {
        impl_->name = config.name.empty()
                      ? std::string(info.szProductName)
                      : config.name;
    } else {
        impl_->name = config.name.empty() ? "Magewell Input" : config.name;
    }
    impl_->isOpen = true;
    SDKLogger::info(TAG, "Capture device opened: " + impl_->name);
    return true;
#else
    SDKLogger::warn(TAG, "Magewell SDK not available — device will not open");
    return false;
#endif
}

void MagewellInput::close() {
    std::lock_guard<std::mutex> lock(impl_->mutex);
    if (!impl_->isOpen) return;
    SDKLogger::info(TAG, "Closing Magewell capture device: " + impl_->name);
    if (impl_->capturing) {
#ifdef HAS_MAGEWELL
        MWStopVideoCapture(impl_->channel);
#ifdef _WIN32
        if (impl_->notifyEvent) {
            CloseHandle(impl_->notifyEvent);
            impl_->notifyEvent = nullptr;
        }
#else
        if (impl_->notifyFd >= 0) {
            ::close(impl_->notifyFd);
            impl_->notifyFd = -1;
        }
#endif
#endif
        impl_->capturing = false;
    }
#ifdef HAS_MAGEWELL
    if (impl_->channel) {
        MWCloseChannel(impl_->channel);
        impl_->channel = nullptr;
    }
#endif
    impl_->isOpen = false;
    SDKLogger::info(TAG, "Capture device closed");
}

bool MagewellInput::isOpen() const { return impl_->isOpen; }
std::string MagewellInput::deviceName() const { return impl_->name; }
DeviceType MagewellInput::deviceType() const { return DeviceType::CAPTURE; }

std::vector<VideoMode> MagewellInput::supportedModes() const {
    return {
        {1920, 1080, 25.0,   PixelFormat::UYVY, false},
        {1920, 1080, 29.97,  PixelFormat::UYVY, false},
        {1920, 1080, 50.0,   PixelFormat::UYVY, false},
        {1920, 1080, 59.94,  PixelFormat::UYVY, false},
        {3840, 2160, 25.0,   PixelFormat::UYVY, false},
        {3840, 2160, 29.97,  PixelFormat::UYVY, false},
    };
}

bool MagewellInput::startCapture(const VideoMode& mode) {
#ifdef HAS_MAGEWELL
    std::lock_guard<std::mutex> lock(impl_->mutex);
    if (!impl_->isOpen) {
        SDKLogger::error(TAG, "startCapture() called on closed device");
        return false;
    }
    SDKLogger::info(TAG, "Starting Magewell capture " +
                         std::to_string(mode.width) + "x" +
                         std::to_string(mode.height) + "@" +
                         std::to_string(mode.frameRate));

#ifdef _WIN32
    impl_->notifyEvent = CreateEvent(nullptr, FALSE, FALSE, nullptr);
    MW_RESULT res = MWStartVideoCapture(impl_->channel, impl_->notifyEvent);
    if (res != MW_SUCCEEDED) {
        SDKLogger::error(TAG, "MWStartVideoCapture failed");
        CloseHandle(impl_->notifyEvent);
        impl_->notifyEvent = nullptr;
        return false;
    }
#else
    // Linux/macOS: Use eventfd or similar mechanism
    impl_->notifyFd = eventfd(0, EFD_NONBLOCK);
    MWCAP_PTR notifyPtr = (impl_->notifyFd >= 0) 
                          ? reinterpret_cast<MWCAP_PTR>(impl_->notifyFd) 
                          : 0;
    MW_RESULT res = MWStartVideoCapture(impl_->channel, notifyPtr);
    if (res != MW_SUCCEEDED) {
        SDKLogger::error(TAG, "MWStartVideoCapture failed");
        if (impl_->notifyFd >= 0) {
            ::close(impl_->notifyFd);
            impl_->notifyFd = -1;
        }
        return false;
    }
#endif
    const int stride = mode.width * 2; // UYVY: 2 bytes per pixel
    impl_->frameBuf.resize(static_cast<size_t>(stride) * mode.height);
    impl_->currentMode = mode;
    impl_->capturing = true;
    SDKLogger::info(TAG, "Magewell capture started");
    return true;
#else
    (void)mode; // Suppress unused parameter warning
    return false;
#endif
}

bool MagewellInput::stopCapture() {
    std::lock_guard<std::mutex> lock(impl_->mutex);
    if (!impl_->capturing) return true;
    SDKLogger::info(TAG, "Stopping Magewell capture");
#ifdef HAS_MAGEWELL
    MWStopVideoCapture(impl_->channel);
#ifdef _WIN32
    if (impl_->notifyEvent) {
        CloseHandle(impl_->notifyEvent);
        impl_->notifyEvent = nullptr;
    }
#else
    if (impl_->notifyFd >= 0) {
        ::close(impl_->notifyFd);
        impl_->notifyFd = -1;
    }
#endif
#endif
    impl_->capturing = false;
    return true;
}

VideoFrame MagewellInput::captureFrame() {
#ifdef HAS_MAGEWELL
    if (!impl_->capturing || impl_->frameBuf.empty()) return VideoFrame{};

    const int width  = impl_->currentMode.width;
    const int height = impl_->currentMode.height;
    const int stride = width * 2; // UYVY

    // Wait for a new frame notification (up to 200 ms)
#ifdef _WIN32
    if (impl_->notifyEvent)
        WaitForSingleObject(impl_->notifyEvent, 200);
#else
    // Linux/macOS: wait using select or poll on notifyFd
    if (impl_->notifyFd >= 0) {
        fd_set readfds;
        FD_ZERO(&readfds);
        FD_SET(impl_->notifyFd, &readfds);
        struct timeval tv = {0, 200000}; // 200ms
        select(impl_->notifyFd + 1, &readfds, nullptr, nullptr, &tv);
        // Clear the event
        uint64_t val;
        (void)read(impl_->notifyFd, &val, sizeof(val));
    }
#endif

    // SDK 3.3.1: Use MWFOURCC_UYVY instead of deprecated FOURCC_UYV2
    MW_RESULT res = MWCaptureVideoFrameToVirtualAddress(
        impl_->channel,
        -1 /*use current frame*/,
        impl_->frameBuf.data(),
        static_cast<DWORD>(impl_->frameBuf.size()),
        static_cast<DWORD>(stride),
        FALSE /*bottom-up*/,
        nullptr /*reserved*/,
        MWFOURCC_UYVY,
        width,
        height);

    if (res != MW_SUCCEEDED) {
        SDKLogger::debug(TAG, "captureFrame() — MWCaptureVideoFrameToVirtualAddress failed");
        return VideoFrame{};
    }

    VideoFrame frame;
    frame.data   = impl_->frameBuf.data();
    frame.width  = width;
    frame.height = height;
    frame.stride = stride;
    frame.format = PixelFormat::UYVY;
    return frame;
#endif
    SDKLogger::debug(TAG, "captureFrame() — no Magewell SDK, returning empty frame");
    return VideoFrame{};
}

// Playout no-ops
bool MagewellInput::startPlayout(const VideoMode& /*mode*/) { return false; }
bool MagewellInput::stopPlayout() { return false; }
bool MagewellInput::sendFrame(const VideoFrame& /*frame*/) { return false; }

void MagewellInput::setVideoMode(const VideoMode& mode) { impl_->currentMode = mode; }
VideoMode MagewellInput::currentMode() const { return impl_->currentMode; }

// MagewellInput-specific
bool MagewellInput::hasSignal() const {
#ifdef HAS_MAGEWELL
    if (!impl_->channel) return false;
    MWCAP_VIDEO_SIGNAL_STATUS status;
    if (MWGetVideoSignalStatus(impl_->channel, &status) == MW_SUCCEEDED)
        return status.state == MWCAP_VIDEO_SIGNAL_LOCKED;
#endif
    return false;
}

VideoMode MagewellInput::detectedMode() const {
#ifdef HAS_MAGEWELL
    if (!impl_->channel) return VideoMode{};
    MWCAP_VIDEO_SIGNAL_STATUS status;
    if (MWGetVideoSignalStatus(impl_->channel, &status) != MW_SUCCEEDED)
        return VideoMode{};
    if (status.state != MWCAP_VIDEO_SIGNAL_LOCKED)
        return VideoMode{};
    // Derive frame rate from field rate (status.dwFrameDuration is in 100ns units)
    double fps = 0.0;
    if (status.dwFrameDuration > 0)
        fps = 1e7 / static_cast<double>(status.dwFrameDuration);
    return VideoMode{
        status.cx,
        status.cy,
        fps,
        PixelFormat::UYVY,
        status.bInterlaced != 0
    };
#endif
    return VideoMode{};
}

std::vector<DeviceConfig> MagewellInput::enumerateDevices() {
#ifdef HAS_MAGEWELL
    std::vector<DeviceConfig> devices;
    
    // Ensure SDK is initialized for enumeration
    initMagewellInputSDK();
    
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
    exitMagewellInputSDK();
    
    SDKLogger::info(TAG, "enumerateDevices() found " +
                         std::to_string(devices.size()) + " Magewell device(s)");
    return devices;
#endif
    SDKLogger::debug(TAG, "enumerateDevices() — no Magewell SDK, returning empty list");
    return {};
}

