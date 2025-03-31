// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAMERA_PLUGIN_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAMERA_PLUGIN_H_

#include <flutter/flutter_view.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <functional>

#include "camera.h"
#include "capture_controller.h"
#include "capture_controller_listener.h"
#include "messages.g.h"

namespace camera_windows {
using flutter::MethodResult;

namespace test {
namespace {
// Forward declaration of test class.
class MockCameraPlugin;
}  // namespace
}  // namespace test

class CameraPlugin : public flutter::Plugin,
                     public CameraApi,
                     public VideoCaptureDeviceEnumerator {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  CameraPlugin(flutter::TextureRegistrar* texture_registrar,
               flutter::BinaryMessenger* messenger);

  // Creates a plugin instance with the given CameraFactory instance.
  // Exists for unit testing with mock implementations.
  CameraPlugin(flutter::TextureRegistrar* texture_registrar,
               flutter::BinaryMessenger* messenger,
               std::unique_ptr<CameraFactory> camera_factory);

  virtual ~CameraPlugin();

  // Disallow copy and move.
  CameraPlugin(const CameraPlugin&) = delete;
  CameraPlugin& operator=(const CameraPlugin&) = delete;

  // CameraApi:
  ErrorOr<flutter::EncodableList> GetAvailableCameras() override;
  void Create(const std::string& camera_name,
              const PlatformMediaSettings& settings,
              std::function<void(ErrorOr<int64_t> reply)> result) override;
  void Initialize(
      int64_t camera_id,
      std::function<void(ErrorOr<PlatformSize> reply)> result) override;
  void PausePreview(
      int64_t camera_id,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void ResumePreview(
      int64_t camera_id,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void StartVideoRecording(
      int64_t camera_id,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void StopVideoRecording(
      int64_t camera_id,
      std::function<void(ErrorOr<std::string> reply)> result) override;
  void TakePicture(
      int64_t camera_id,
      std::function<void(ErrorOr<std::string> reply)> result) override;
  std::optional<FlutterError> Dispose(int64_t camera_id) override;

 private:
  // Loops through cameras and returns camera
  // with matching device_id or nullptr.
  Camera* GetCameraByDeviceId(std::string& device_id);

  // Loops through cameras and returns camera
  // with matching camera_id or nullptr.
  Camera* GetCameraByCameraId(int64_t camera_id);

  // Disposes camera by camera id.
  void DisposeCameraByCameraId(int64_t camera_id);

  // Enumerates video capture devices.
  bool EnumerateVideoCaptureDeviceSources(IMFActivate*** devices,
                                          UINT32* count) override;

  std::unique_ptr<CameraFactory> camera_factory_;
  flutter::TextureRegistrar* texture_registrar_;
  flutter::BinaryMessenger* messenger_;
  std::vector<std::unique_ptr<Camera>> cameras_;

  friend class camera_windows::test::MockCameraPlugin;
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAMERA_PLUGIN_H_
