#pragma once

/// @file magewell_device.h
/// @brief Magewell capture device wrapper.
///
/// Requires the Magewell SDK to be installed in sdk/magewell/.
///
/// Updated for Magewell Capture SDK 3.3.1 compatibility:
/// - Uses MWCaptureInitInstance/MWCaptureExitInstance for SDK lifecycle
/// - Uses MWGetDevicePath + MWOpenChannelByPath instead of MWOpenChannelByIndex
/// - Uses MWGetChannelInfoByIndex for device enumeration
/// - Uses MWFOURCC_UYVY instead of deprecated FOURCC_UYV2

#include "visioncast_sdk/video_device.h"

#include <memory>

/// Magewell capture device implementation.
class MagewellDevice : public IVideoDevice {
public:
    MagewellDevice();
    ~MagewellDevice() override;

    bool open(const DeviceConfig& config) override;
    void close() override;
    bool isOpen() const override;

    std::string deviceName() const override;
    DeviceType deviceType() const override;
    std::vector<VideoMode> supportedModes() const override;

    bool startCapture(const VideoMode& mode) override;
    bool stopCapture() override;
    VideoFrame captureFrame() override;

    bool startPlayout(const VideoMode& mode) override;
    bool stopPlayout() override;
    bool sendFrame(const VideoFrame& frame) override;

    void setVideoMode(const VideoMode& mode) override;
    VideoMode currentMode() const override;

    /// Enumerate all Magewell devices on the system.
    static std::vector<DeviceConfig> enumerateDevices();

private:
    struct Impl;
    std::unique_ptr<Impl> impl_;
};
