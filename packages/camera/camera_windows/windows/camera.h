// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAMERA_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAMERA_H_

#include <functional>
#include <optional>
#include <variant>

#include "capture_controller.h"
#include "messages.g.h"

namespace camera_windows {

// A set of result types that are stored
// for processing asynchronous commands.
enum class PendingResultType {
  kCreateCamera,
  kInitialize,
  kTakePicture,
  kStartRecord,
  kStopRecord,
  kPausePreview,
  kResumePreview,
};

// Interface implemented by cameras.
//
// Access is provided to an associated |CaptureController|, which can be used
// to capture video or photo from the camera.
class Camera : public CaptureControllerListener {
 public:
  explicit Camera([[maybe_unused]] const std::string& device_id) {}
  virtual ~Camera() = default;

  // Disallow copy and move.
  Camera(const Camera&) = delete;
  Camera& operator=(const Camera&) = delete;

  // Tests if this camera has the specified device ID.
  virtual bool HasDeviceId(std::string& device_id) const = 0;

  // Tests if this camera has the specified camera ID.
  virtual bool HasCameraId(int64_t camera_id) const = 0;

  // Adds a pending result for a void return.
  //
  // Returns an error result if the result has already been added.
  virtual bool AddPendingVoidResult(
      PendingResultType type,
      std::function<void(std::optional<FlutterError> reply)> result) = 0;

  // Adds a pending result for a string return.
  //
  // Returns an error result if the result has already been added.
  virtual bool AddPendingIntResult(
      PendingResultType type,
      std::function<void(ErrorOr<int64_t> reply)> result) = 0;

  // Adds a pending result for a string return.
  //
  // Returns an error result if the result has already been added.
  virtual bool AddPendingStringResult(
      PendingResultType type,
      std::function<void(ErrorOr<std::string> reply)> result) = 0;

  // Adds a pending result for a size return.
  //
  // Returns an error result if the result has already been added.
  virtual bool AddPendingSizeResult(
      PendingResultType type,
      std::function<void(ErrorOr<PlatformSize> reply)> result) = 0;

  // Checks if a pending result of the specified type already exists.
  virtual bool HasPendingResultByType(PendingResultType type) const = 0;

  // Returns a |CaptureController| that allows capturing video or still photos
  // from this camera.
  virtual camera_windows::CaptureController* GetCaptureController() = 0;

  // Initializes this camera and its associated capture controller.
  //
  // Returns false if initialization fails.
  virtual bool InitCamera(flutter::TextureRegistrar* texture_registrar,
                          flutter::BinaryMessenger* messenger,
                          const PlatformMediaSettings& media_settings) = 0;
};

// Concrete implementation of the |Camera| interface.
//
// This implementation is responsible for initializing the capture controller,
// listening for camera events, processing pending results, and notifying
// application code of processed events via the method channel.
class CameraImpl : public Camera {
 public:
  explicit CameraImpl(const std::string& device_id);
  virtual ~CameraImpl();

  // Disallow copy and move.
  CameraImpl(const CameraImpl&) = delete;
  CameraImpl& operator=(const CameraImpl&) = delete;

  // CaptureControllerListener
  void OnCreateCaptureEngineSucceeded(int64_t texture_id) override;
  void OnCreateCaptureEngineFailed(CameraResult result,
                                   const std::string& error) override;
  void OnStartPreviewSucceeded(int32_t width, int32_t height) override;
  void OnStartPreviewFailed(CameraResult result,
                            const std::string& error) override;
  void OnPausePreviewSucceeded() override;
  void OnPausePreviewFailed(CameraResult result,
                            const std::string& error) override;
  void OnResumePreviewSucceeded() override;
  void OnResumePreviewFailed(CameraResult result,
                             const std::string& error) override;
  void OnStartRecordSucceeded() override;
  void OnStartRecordFailed(CameraResult result,
                           const std::string& error) override;
  void OnStopRecordSucceeded(const std::string& file_path) override;
  void OnStopRecordFailed(CameraResult result,
                          const std::string& error) override;
  void OnTakePictureSucceeded(const std::string& file_path) override;
  void OnTakePictureFailed(CameraResult result,
                           const std::string& error) override;
  void OnCaptureError(CameraResult result, const std::string& error) override;

  // Camera
  bool HasDeviceId(std::string& device_id) const override {
    return device_id_ == device_id;
  }
  bool HasCameraId(int64_t camera_id) const override {
    return camera_id_ == camera_id;
  }
  bool AddPendingVoidResult(
      PendingResultType type,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  bool AddPendingIntResult(
      PendingResultType type,
      std::function<void(ErrorOr<int64_t> reply)> result) override;
  bool AddPendingStringResult(
      PendingResultType type,
      std::function<void(ErrorOr<std::string> reply)> result) override;
  bool AddPendingSizeResult(
      PendingResultType type,
      std::function<void(ErrorOr<PlatformSize> reply)> result) override;
  bool HasPendingResultByType(PendingResultType type) const override;
  camera_windows::CaptureController* GetCaptureController() override {
    return capture_controller_.get();
  }
  bool InitCamera(flutter::TextureRegistrar* texture_registrar,
                  flutter::BinaryMessenger* messenger,
                  const PlatformMediaSettings& media_settings) override;

  // Initializes the camera and its associated capture controller.
  //
  // This is a convenience method called by |InitCamera| but also used in
  // tests.
  //
  // Returns false if initialization fails.
  bool InitCamera(
      std::unique_ptr<CaptureControllerFactory> capture_controller_factory,
      flutter::TextureRegistrar* texture_registrar,
      flutter::BinaryMessenger* messenger,
      const PlatformMediaSettings& media_settings);

 private:
  // A generic type for any pending asyncronous result.
  using AsyncResult =
      std::variant<std::function<void(std::optional<FlutterError> reply)>,
                   std::function<void(ErrorOr<int64_t> reply)>,
                   std::function<void(ErrorOr<std::string> reply)>,
                   std::function<void(ErrorOr<PlatformSize> reply)>>;

  // Loops through all pending results and calls their error handler with given
  // error ID and description. Pending results are cleared in the process.
  //
  // error_code: A string error code describing the error.
  // description: A user-readable error message (optional).
  void SendErrorForPendingResults(const std::string& error_code,
                                  const std::string& description);

  // Called when camera is disposed.
  // Sends camera closing message to the cameras method channel.
  void OnCameraClosing();

  // Returns the FlutterApi instance used to communicate camera events.
  CameraEventApi* GetEventApi();

  // Finds pending void result by type.
  //
  // Returns an empty function if type is not present.
  std::function<void(std::optional<FlutterError> reply)>
  GetPendingVoidResultByType(PendingResultType type);

  // Finds pending int result by type.
  //
  // Returns an empty function if type is not present.
  std::function<void(ErrorOr<int64_t> reply)> GetPendingIntResultByType(
      PendingResultType type);

  // Finds pending string result by type.
  //
  // Returns an empty function if type is not present.
  std::function<void(ErrorOr<std::string> reply)> GetPendingStringResultByType(
      PendingResultType type);

  // Finds pending size result by type.
  //
  // Returns an empty function if type is not present.
  std::function<void(ErrorOr<PlatformSize> reply)> GetPendingSizeResultByType(
      PendingResultType type);

  // Finds pending result by type.
  //
  // Returns a nullopt if type is not present.
  //
  // This should not be used directly in most code, it's just a helper for the
  // typed versions above.
  std::optional<AsyncResult> GetPendingResultByType(PendingResultType type);

  // Adds pending result by type.
  //
  // This should not be used directly in most code, it's just a helper for the
  // typed versions in the public interface.
  bool AddPendingResult(PendingResultType type, AsyncResult result);

  std::map<PendingResultType, AsyncResult> pending_results_;
  std::unique_ptr<CaptureController> capture_controller_;
  std::unique_ptr<CameraEventApi> event_api_;
  flutter::BinaryMessenger* messenger_ = nullptr;
  int64_t camera_id_ = -1;
  std::string device_id_;
};

// Factory class for creating |Camera| instances from a specified device ID.
class CameraFactory {
 public:
  CameraFactory() {}
  virtual ~CameraFactory() = default;

  // Disallow copy and move.
  CameraFactory(const CameraFactory&) = delete;
  CameraFactory& operator=(const CameraFactory&) = delete;

  // Creates camera for given device id.
  virtual std::unique_ptr<Camera> CreateCamera(
      const std::string& device_id) = 0;
};

// Concrete implementation of |CameraFactory|.
class CameraFactoryImpl : public CameraFactory {
 public:
  CameraFactoryImpl() {}
  virtual ~CameraFactoryImpl() = default;

  // Disallow copy and move.
  CameraFactoryImpl(const CameraFactoryImpl&) = delete;
  CameraFactoryImpl& operator=(const CameraFactoryImpl&) = delete;

  std::unique_ptr<Camera> CreateCamera(const std::string& device_id) override {
    return std::make_unique<CameraImpl>(device_id);
  }
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAMERA_H_
