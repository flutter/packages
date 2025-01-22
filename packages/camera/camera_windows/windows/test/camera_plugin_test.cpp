// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "camera_plugin.h"

#include <flutter/method_call.h>
#include <flutter/method_result_functions.h>
#include <flutter/standard_method_codec.h>
#include <flutter/texture_registrar.h>
#include <gmock/gmock.h>
#include <gtest/gtest.h>
#include <windows.h>

#include <functional>
#include <memory>
#include <string>

#include "mocks.h"

namespace camera_windows {
namespace test {

using flutter::EncodableMap;
using flutter::EncodableValue;
using ::testing::_;
using ::testing::DoAll;
using ::testing::EndsWith;
using ::testing::Eq;
using ::testing::Pointee;
using ::testing::Return;

void MockInitCamera(MockCamera* camera, bool success) {
  EXPECT_CALL(*camera,
              HasPendingResultByType(Eq(PendingResultType::kCreateCamera)))
      .Times(1)
      .WillOnce(Return(false));

  EXPECT_CALL(*camera,
              AddPendingIntResult(Eq(PendingResultType::kCreateCamera), _))
      .Times(1)
      .WillOnce([camera](PendingResultType type,
                         std::function<void(ErrorOr<int64_t> reply)> result) {
        camera->pending_int_result_ = result;
        return true;
      });

  EXPECT_CALL(*camera, HasDeviceId(Eq(camera->device_id_)))
      .WillRepeatedly(Return(true));

  EXPECT_CALL(*camera, InitCamera)
      .Times(1)
      .WillOnce([camera, success](flutter::TextureRegistrar* texture_registrar,
                                  flutter::BinaryMessenger* messenger,
                                  const PlatformMediaSettings& media_settings) {
        assert(camera->pending_int_result_);
        if (success) {
          camera->pending_int_result_(1);
          return true;
        } else {
          camera->pending_int_result_(
              FlutterError("camera_error", "InitCamera failed."));
          return false;
        }
      });
}

TEST(CameraPlugin, AvailableCamerasHandlerSuccessIfNoCameras) {
  std::unique_ptr<MockTextureRegistrar> texture_registrar_ =
      std::make_unique<MockTextureRegistrar>();
  std::unique_ptr<MockBinaryMessenger> messenger_ =
      std::make_unique<MockBinaryMessenger>();
  std::unique_ptr<MockCameraFactory> camera_factory_ =
      std::make_unique<MockCameraFactory>();

  MockCameraPlugin plugin(texture_registrar_.get(), messenger_.get(),
                          std::move(camera_factory_));

  EXPECT_CALL(plugin, EnumerateVideoCaptureDeviceSources)
      .Times(1)
      .WillOnce([](IMFActivate*** devices, UINT32* count) {
        *count = 0U;
        *devices = static_cast<IMFActivate**>(
            CoTaskMemAlloc(sizeof(IMFActivate*) * (*count)));
        return true;
      });

  ErrorOr<flutter::EncodableList> result = plugin.GetAvailableCameras();

  EXPECT_FALSE(result.has_error());
  EXPECT_EQ(result.value().size(), 0);
}

TEST(CameraPlugin, AvailableCamerasHandlerErrorIfFailsToEnumerateDevices) {
  std::unique_ptr<MockTextureRegistrar> texture_registrar_ =
      std::make_unique<MockTextureRegistrar>();
  std::unique_ptr<MockBinaryMessenger> messenger_ =
      std::make_unique<MockBinaryMessenger>();
  std::unique_ptr<MockCameraFactory> camera_factory_ =
      std::make_unique<MockCameraFactory>();

  MockCameraPlugin plugin(texture_registrar_.get(), messenger_.get(),
                          std::move(camera_factory_));

  EXPECT_CALL(plugin, EnumerateVideoCaptureDeviceSources)
      .Times(1)
      .WillOnce([](IMFActivate*** devices, UINT32* count) { return false; });

  ErrorOr<flutter::EncodableList> result = plugin.GetAvailableCameras();

  EXPECT_TRUE(result.has_error());
}

TEST(CameraPlugin, CreateHandlerCallsInitCamera) {
  std::unique_ptr<MockTextureRegistrar> texture_registrar_ =
      std::make_unique<MockTextureRegistrar>();
  std::unique_ptr<MockBinaryMessenger> messenger_ =
      std::make_unique<MockBinaryMessenger>();
  std::unique_ptr<MockCameraFactory> camera_factory_ =
      std::make_unique<MockCameraFactory>();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);

  MockInitCamera(camera.get(), true);

  // Move mocked camera to the factory to be passed
  // for plugin with CreateCamera function.
  camera_factory_->pending_camera_ = std::move(camera);

  EXPECT_CALL(*camera_factory_, CreateCamera(MOCK_DEVICE_ID));

  CameraPlugin plugin(texture_registrar_.get(), messenger_.get(),
                      std::move(camera_factory_));

  bool result_called = false;
  std::function<void(ErrorOr<int64_t>)> create_result =
      [&result_called](ErrorOr<int64_t> reply) {
        EXPECT_FALSE(result_called);  // Ensure only one reply call.
        result_called = true;
        EXPECT_FALSE(reply.has_error());
        EXPECT_EQ(reply.value(), 1);
      };

  plugin.Create(MOCK_CAMERA_NAME,
                PlatformMediaSettings(PlatformResolutionPreset::kMax, true),
                std::move(create_result));

  EXPECT_TRUE(result_called);
}

TEST(CameraPlugin, CreateHandlerErrorOnInvalidDeviceId) {
  std::unique_ptr<MockTextureRegistrar> texture_registrar_ =
      std::make_unique<MockTextureRegistrar>();
  std::unique_ptr<MockBinaryMessenger> messenger_ =
      std::make_unique<MockBinaryMessenger>();
  std::unique_ptr<MockCameraFactory> camera_factory_ =
      std::make_unique<MockCameraFactory>();

  CameraPlugin plugin(texture_registrar_.get(), messenger_.get(),
                      std::move(camera_factory_));

  bool result_called = false;
  std::function<void(ErrorOr<int64_t>)> create_result =
      [&result_called](ErrorOr<int64_t> reply) {
        EXPECT_FALSE(result_called);  // Ensure only one reply call.
        result_called = true;
        EXPECT_TRUE(reply.has_error());
      };

  plugin.Create(MOCK_INVALID_CAMERA_NAME,
                PlatformMediaSettings(PlatformResolutionPreset::kMax, true),
                std::move(create_result));

  EXPECT_TRUE(result_called);
}

TEST(CameraPlugin, CreateHandlerErrorOnExistingDeviceId) {
  std::unique_ptr<MockTextureRegistrar> texture_registrar_ =
      std::make_unique<MockTextureRegistrar>();
  std::unique_ptr<MockBinaryMessenger> messenger_ =
      std::make_unique<MockBinaryMessenger>();
  std::unique_ptr<MockCameraFactory> camera_factory_ =
      std::make_unique<MockCameraFactory>();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);

  MockInitCamera(camera.get(), true);

  // Move mocked camera to the factory to be passed
  // for plugin with CreateCamera function.
  camera_factory_->pending_camera_ = std::move(camera);

  EXPECT_CALL(*camera_factory_, CreateCamera(MOCK_DEVICE_ID));

  CameraPlugin plugin(texture_registrar_.get(), messenger_.get(),
                      std::move(camera_factory_));

  bool first_result_called = false;
  std::function<void(ErrorOr<int64_t>)> first_create_result =
      [&first_result_called](ErrorOr<int64_t> reply) {
        EXPECT_FALSE(first_result_called);  // Ensure only one reply call.
        first_result_called = true;
        EXPECT_FALSE(reply.has_error());
        EXPECT_EQ(reply.value(), 1);
      };

  PlatformMediaSettings media_settings(PlatformResolutionPreset::kMax, true);
  plugin.Create(MOCK_CAMERA_NAME, media_settings,
                std::move(first_create_result));

  EXPECT_TRUE(first_result_called);

  bool second_result_called = false;
  std::function<void(ErrorOr<int64_t>)> second_create_result =
      [&second_result_called](ErrorOr<int64_t> reply) {
        EXPECT_FALSE(second_result_called);  // Ensure only one reply call.
        second_result_called = true;
        EXPECT_TRUE(reply.has_error());
      };

  plugin.Create(MOCK_CAMERA_NAME, media_settings,
                std::move(second_create_result));

  EXPECT_TRUE(second_result_called);
}

TEST(CameraPlugin, CreateHandlerAllowsRetry) {
  std::unique_ptr<MockTextureRegistrar> texture_registrar_ =
      std::make_unique<MockTextureRegistrar>();
  std::unique_ptr<MockBinaryMessenger> messenger_ =
      std::make_unique<MockBinaryMessenger>();
  std::unique_ptr<MockCameraFactory> camera_factory_ =
      std::make_unique<MockCameraFactory>();

  // The camera will fail initialization once and then succeed.
  EXPECT_CALL(*camera_factory_, CreateCamera(MOCK_DEVICE_ID))
      .Times(2)
      .WillOnce([](const std::string& device_id) {
        std::unique_ptr<MockCamera> first_camera =
            std::make_unique<MockCamera>(MOCK_DEVICE_ID);

        MockInitCamera(first_camera.get(), false);

        return first_camera;
      })
      .WillOnce([](const std::string& device_id) {
        std::unique_ptr<MockCamera> second_camera =
            std::make_unique<MockCamera>(MOCK_DEVICE_ID);

        MockInitCamera(second_camera.get(), true);

        return second_camera;
      });

  CameraPlugin plugin(texture_registrar_.get(), messenger_.get(),
                      std::move(camera_factory_));

  bool first_result_called = false;
  std::function<void(ErrorOr<int64_t>)> first_create_result =
      [&first_result_called](ErrorOr<int64_t> reply) {
        EXPECT_FALSE(first_result_called);  // Ensure only one reply call.
        first_result_called = true;
        EXPECT_TRUE(reply.has_error());
      };

  PlatformMediaSettings media_settings(PlatformResolutionPreset::kMax, true);
  plugin.Create(MOCK_CAMERA_NAME, media_settings,
                std::move(first_create_result));

  EXPECT_TRUE(first_result_called);

  bool second_result_called = false;
  std::function<void(ErrorOr<int64_t>)> second_create_result =
      [&second_result_called](ErrorOr<int64_t> reply) {
        EXPECT_FALSE(second_result_called);  // Ensure only one reply call.
        second_result_called = true;
        EXPECT_FALSE(reply.has_error());
        EXPECT_EQ(reply.value(), 1);
      };

  plugin.Create(MOCK_CAMERA_NAME, media_settings,
                std::move(second_create_result));

  EXPECT_TRUE(second_result_called);
}

TEST(CameraPlugin, InitializeHandlerCallStartPreview) {
  int64_t mock_camera_id = 1234;

  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*camera, HasCameraId(Eq(mock_camera_id)))
      .Times(1)
      .WillOnce([cam = camera.get()](int64_t camera_id) {
        return cam->camera_id_ == camera_id;
      });

  EXPECT_CALL(*camera,
              HasPendingResultByType(Eq(PendingResultType::kInitialize)))
      .Times(1)
      .WillOnce(Return(false));

  EXPECT_CALL(*camera,
              AddPendingSizeResult(Eq(PendingResultType::kInitialize), _))
      .Times(1)
      .WillOnce([cam = camera.get()](
                    PendingResultType type,
                    std::function<void(ErrorOr<PlatformSize>)> result) {
        cam->pending_size_result_ = std::move(result);
        return true;
      });

  EXPECT_CALL(*camera, GetCaptureController)
      .Times(1)
      .WillOnce([cam = camera.get()]() {
        assert(cam->pending_size_result_);
        return cam->capture_controller_.get();
      });

  EXPECT_CALL(*capture_controller, StartPreview())
      .Times(1)
      .WillOnce([cam = camera.get()]() {
        assert(cam->pending_size_result_);
        return cam->pending_size_result_(PlatformSize(800, 600));
      });

  camera->camera_id_ = mock_camera_id;
  camera->capture_controller_ = std::move(capture_controller);

  MockCameraPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockCameraFactory>());

  // Add mocked camera to plugins camera list.
  plugin.AddCamera(std::move(camera));

  bool result_called = false;
  std::function<void(ErrorOr<PlatformSize>)> initialize_result =
      [&result_called](ErrorOr<PlatformSize> reply) {
        EXPECT_FALSE(result_called);  // Ensure only one reply call.
        result_called = true;
        EXPECT_FALSE(reply.has_error());
      };

  plugin.Initialize(mock_camera_id, std::move(initialize_result));

  EXPECT_TRUE(result_called);
}

TEST(CameraPlugin, InitializeHandlerErrorOnInvalidCameraId) {
  int64_t mock_camera_id = 1234;
  int64_t missing_camera_id = 5678;

  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*camera, HasCameraId)
      .Times(1)
      .WillOnce([cam = camera.get()](int64_t camera_id) {
        return cam->camera_id_ == camera_id;
      });

  EXPECT_CALL(*camera, HasPendingResultByType).Times(0);
  EXPECT_CALL(*camera, AddPendingSizeResult).Times(0);
  EXPECT_CALL(*camera, GetCaptureController).Times(0);
  EXPECT_CALL(*capture_controller, StartPreview).Times(0);

  camera->camera_id_ = mock_camera_id;

  MockCameraPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockCameraFactory>());

  // Add mocked camera to plugins camera list.
  plugin.AddCamera(std::move(camera));

  bool result_called = false;
  std::function<void(ErrorOr<PlatformSize>)> initialize_result =
      [&result_called](ErrorOr<PlatformSize> reply) {
        EXPECT_FALSE(result_called);  // Ensure only one reply call.
        result_called = true;
        EXPECT_TRUE(reply.has_error());
      };

  plugin.Initialize(missing_camera_id, std::move(initialize_result));

  EXPECT_TRUE(result_called);
}

TEST(CameraPlugin, TakePictureHandlerCallsTakePictureWithPath) {
  int64_t mock_camera_id = 1234;

  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*camera, HasCameraId(Eq(mock_camera_id)))
      .Times(1)
      .WillOnce([cam = camera.get()](int64_t camera_id) {
        return cam->camera_id_ == camera_id;
      });

  EXPECT_CALL(*camera,
              HasPendingResultByType(Eq(PendingResultType::kTakePicture)))
      .Times(1)
      .WillOnce(Return(false));

  EXPECT_CALL(*camera,
              AddPendingStringResult(Eq(PendingResultType::kTakePicture), _))
      .Times(1)
      .WillOnce([cam = camera.get()](
                    PendingResultType type,
                    std::function<void(ErrorOr<std::string>)> result) {
        cam->pending_string_result_ = std::move(result);
        return true;
      });

  EXPECT_CALL(*camera, GetCaptureController)
      .Times(1)
      .WillOnce([cam = camera.get()]() {
        assert(cam->pending_string_result_);
        return cam->capture_controller_.get();
      });

  EXPECT_CALL(*capture_controller, TakePicture(EndsWith(".jpeg")))
      .Times(1)
      .WillOnce([cam = camera.get()](const std::string& file_path) {
        assert(cam->pending_string_result_);
        return cam->pending_string_result_(file_path);
      });

  camera->camera_id_ = mock_camera_id;
  camera->capture_controller_ = std::move(capture_controller);

  MockCameraPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockCameraFactory>());

  // Add mocked camera to plugins camera list.
  plugin.AddCamera(std::move(camera));

  bool result_called = false;
  std::function<void(ErrorOr<std::string>)> take_picture_result =
      [&result_called](ErrorOr<std::string> reply) {
        EXPECT_FALSE(result_called);  // Ensure only one reply call.
        result_called = true;
        EXPECT_FALSE(reply.has_error());
      };

  plugin.TakePicture(mock_camera_id, std::move(take_picture_result));

  EXPECT_TRUE(result_called);
}

TEST(CameraPlugin, TakePictureHandlerErrorOnInvalidCameraId) {
  int64_t mock_camera_id = 1234;
  int64_t missing_camera_id = 5678;

  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*camera, HasCameraId)
      .Times(1)
      .WillOnce([cam = camera.get()](int64_t camera_id) {
        return cam->camera_id_ == camera_id;
      });

  EXPECT_CALL(*camera, HasPendingResultByType).Times(0);
  EXPECT_CALL(*camera, AddPendingStringResult).Times(0);
  EXPECT_CALL(*camera, GetCaptureController).Times(0);
  EXPECT_CALL(*capture_controller, TakePicture).Times(0);

  camera->camera_id_ = mock_camera_id;

  MockCameraPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockCameraFactory>());

  // Add mocked camera to plugins camera list.
  plugin.AddCamera(std::move(camera));

  bool result_called = false;
  std::function<void(ErrorOr<std::string>)> take_picture_result =
      [&result_called](ErrorOr<std::string> reply) {
        EXPECT_FALSE(result_called);  // Ensure only one reply call.
        result_called = true;
        EXPECT_TRUE(reply.has_error());
      };

  plugin.TakePicture(missing_camera_id, std::move(take_picture_result));

  EXPECT_TRUE(result_called);
}

TEST(CameraPlugin, StartVideoRecordingHandlerCallsStartRecordWithPath) {
  int64_t mock_camera_id = 1234;

  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*camera, HasCameraId(Eq(mock_camera_id)))
      .Times(1)
      .WillOnce([cam = camera.get()](int64_t camera_id) {
        return cam->camera_id_ == camera_id;
      });

  EXPECT_CALL(*camera,
              HasPendingResultByType(Eq(PendingResultType::kStartRecord)))
      .Times(1)
      .WillOnce(Return(false));

  EXPECT_CALL(*camera,
              AddPendingVoidResult(Eq(PendingResultType::kStartRecord), _))
      .Times(1)
      .WillOnce([cam = camera.get()](
                    PendingResultType type,
                    std::function<void(std::optional<FlutterError>)> result) {
        cam->pending_void_result_ = std::move(result);
        return true;
      });

  EXPECT_CALL(*camera, GetCaptureController)
      .Times(1)
      .WillOnce([cam = camera.get()]() {
        assert(cam->pending_void_result_);
        return cam->capture_controller_.get();
      });

  EXPECT_CALL(*capture_controller, StartRecord(EndsWith(".mp4")))
      .Times(1)
      .WillOnce([cam = camera.get()](const std::string& file_path) {
        assert(cam->pending_void_result_);
        return cam->pending_void_result_(std::nullopt);
      });

  camera->camera_id_ = mock_camera_id;
  camera->capture_controller_ = std::move(capture_controller);

  MockCameraPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockCameraFactory>());

  // Add mocked camera to plugins camera list.
  plugin.AddCamera(std::move(camera));

  bool result_called = false;
  std::function<void(std::optional<FlutterError>)> start_video_result =
      [&result_called](std::optional<FlutterError> reply) {
        EXPECT_FALSE(result_called);  // Ensure only one reply call.
        result_called = true;
        EXPECT_FALSE(reply);
      };

  plugin.StartVideoRecording(mock_camera_id, std::move(start_video_result));

  EXPECT_TRUE(result_called);
}

TEST(CameraPlugin, StartVideoRecordingHandlerErrorOnInvalidCameraId) {
  int64_t mock_camera_id = 1234;
  int64_t missing_camera_id = 5678;

  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*camera, HasCameraId)
      .Times(1)
      .WillOnce([cam = camera.get()](int64_t camera_id) {
        return cam->camera_id_ == camera_id;
      });

  EXPECT_CALL(*camera, HasPendingResultByType).Times(0);
  EXPECT_CALL(*camera, AddPendingVoidResult).Times(0);
  EXPECT_CALL(*camera, GetCaptureController).Times(0);
  EXPECT_CALL(*capture_controller, StartRecord(_)).Times(0);

  camera->camera_id_ = mock_camera_id;

  MockCameraPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockCameraFactory>());

  // Add mocked camera to plugins camera list.
  plugin.AddCamera(std::move(camera));

  bool result_called = false;
  std::function<void(std::optional<FlutterError>)> start_video_result =
      [&result_called](std::optional<FlutterError> reply) {
        EXPECT_FALSE(result_called);  // Ensure only one reply call.
        result_called = true;
        EXPECT_TRUE(reply);
      };

  plugin.StartVideoRecording(missing_camera_id, std::move(start_video_result));

  EXPECT_TRUE(result_called);
}

TEST(CameraPlugin, StopVideoRecordingHandlerCallsStopRecord) {
  int64_t mock_camera_id = 1234;
  std::string mock_video_path = "path/to/video.mpeg";

  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*camera, HasCameraId(Eq(mock_camera_id)))
      .Times(1)
      .WillOnce([cam = camera.get()](int64_t camera_id) {
        return cam->camera_id_ == camera_id;
      });

  EXPECT_CALL(*camera,
              HasPendingResultByType(Eq(PendingResultType::kStopRecord)))
      .Times(1)
      .WillOnce(Return(false));

  EXPECT_CALL(*camera,
              AddPendingStringResult(Eq(PendingResultType::kStopRecord), _))
      .Times(1)
      .WillOnce([cam = camera.get()](
                    PendingResultType type,
                    std::function<void(ErrorOr<std::string>)> result) {
        cam->pending_string_result_ = std::move(result);
        return true;
      });

  EXPECT_CALL(*camera, GetCaptureController)
      .Times(1)
      .WillOnce([cam = camera.get()]() {
        assert(cam->pending_string_result_);
        return cam->capture_controller_.get();
      });

  EXPECT_CALL(*capture_controller, StopRecord)
      .Times(1)
      .WillOnce([cam = camera.get(), mock_video_path]() {
        assert(cam->pending_string_result_);
        return cam->pending_string_result_(mock_video_path);
      });

  camera->camera_id_ = mock_camera_id;
  camera->capture_controller_ = std::move(capture_controller);

  MockCameraPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockCameraFactory>());

  // Add mocked camera to plugins camera list.
  plugin.AddCamera(std::move(camera));

  bool result_called = false;
  std::function<void(ErrorOr<std::string>)> stop_recording_result =
      [&result_called, mock_video_path](ErrorOr<std::string> reply) {
        EXPECT_FALSE(result_called);  // Ensure only one reply call.
        result_called = true;
        EXPECT_FALSE(reply.has_error());
        EXPECT_EQ(reply.value(), mock_video_path);
      };

  plugin.StopVideoRecording(mock_camera_id, std::move(stop_recording_result));

  EXPECT_TRUE(result_called);
}

TEST(CameraPlugin, StopVideoRecordingHandlerErrorOnInvalidCameraId) {
  int64_t mock_camera_id = 1234;
  int64_t missing_camera_id = 5678;

  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*camera, HasCameraId)
      .Times(1)
      .WillOnce([cam = camera.get()](int64_t camera_id) {
        return cam->camera_id_ == camera_id;
      });

  EXPECT_CALL(*camera, HasPendingResultByType).Times(0);
  EXPECT_CALL(*camera, AddPendingStringResult).Times(0);
  EXPECT_CALL(*camera, GetCaptureController).Times(0);
  EXPECT_CALL(*capture_controller, StopRecord).Times(0);

  camera->camera_id_ = mock_camera_id;

  MockCameraPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockCameraFactory>());

  // Add mocked camera to plugins camera list.
  plugin.AddCamera(std::move(camera));

  bool result_called = false;
  std::function<void(ErrorOr<std::string>)> stop_recording_result =
      [&result_called](ErrorOr<std::string> reply) {
        EXPECT_FALSE(result_called);  // Ensure only one reply call.
        result_called = true;
        EXPECT_TRUE(reply.has_error());
      };

  plugin.StopVideoRecording(missing_camera_id,
                            std::move(stop_recording_result));

  EXPECT_TRUE(result_called);
}

TEST(CameraPlugin, ResumePreviewHandlerCallsResumePreview) {
  int64_t mock_camera_id = 1234;

  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*camera, HasCameraId(Eq(mock_camera_id)))
      .Times(1)
      .WillOnce([cam = camera.get()](int64_t camera_id) {
        return cam->camera_id_ == camera_id;
      });

  EXPECT_CALL(*camera,
              HasPendingResultByType(Eq(PendingResultType::kResumePreview)))
      .Times(1)
      .WillOnce(Return(false));

  EXPECT_CALL(*camera,
              AddPendingVoidResult(Eq(PendingResultType::kResumePreview), _))
      .Times(1)
      .WillOnce([cam = camera.get()](
                    PendingResultType type,
                    std::function<void(std::optional<FlutterError>)> result) {
        cam->pending_void_result_ = std::move(result);
        return true;
      });

  EXPECT_CALL(*camera, GetCaptureController)
      .Times(1)
      .WillOnce([cam = camera.get()]() {
        assert(cam->pending_void_result_);
        return cam->capture_controller_.get();
      });

  EXPECT_CALL(*capture_controller, ResumePreview)
      .Times(1)
      .WillOnce([cam = camera.get()]() {
        assert(cam->pending_void_result_);
        return cam->pending_void_result_(std::nullopt);
      });

  camera->camera_id_ = mock_camera_id;
  camera->capture_controller_ = std::move(capture_controller);

  MockCameraPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockCameraFactory>());

  // Add mocked camera to plugins camera list.
  plugin.AddCamera(std::move(camera));

  bool result_called = false;
  std::function<void(std::optional<FlutterError>)> resume_preview_result =
      [&result_called](std::optional<FlutterError> reply) {
        EXPECT_FALSE(result_called);  // Ensure only one reply call.
        result_called = true;
        EXPECT_FALSE(reply);
      };

  plugin.ResumePreview(mock_camera_id, std::move(resume_preview_result));

  EXPECT_TRUE(result_called);
}

TEST(CameraPlugin, ResumePreviewHandlerErrorOnInvalidCameraId) {
  int64_t mock_camera_id = 1234;
  int64_t missing_camera_id = 5678;

  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*camera, HasCameraId)
      .Times(1)
      .WillOnce([cam = camera.get()](int64_t camera_id) {
        return cam->camera_id_ == camera_id;
      });

  EXPECT_CALL(*camera, HasPendingResultByType).Times(0);
  EXPECT_CALL(*camera, AddPendingVoidResult).Times(0);
  EXPECT_CALL(*camera, GetCaptureController).Times(0);
  EXPECT_CALL(*capture_controller, ResumePreview).Times(0);

  camera->camera_id_ = mock_camera_id;

  MockCameraPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockCameraFactory>());

  // Add mocked camera to plugins camera list.
  plugin.AddCamera(std::move(camera));

  bool result_called = false;
  std::function<void(std::optional<FlutterError>)> resume_preview_result =
      [&result_called](std::optional<FlutterError> reply) {
        EXPECT_FALSE(result_called);  // Ensure only one reply call.
        result_called = true;
        EXPECT_TRUE(reply);
      };

  plugin.ResumePreview(missing_camera_id, std::move(resume_preview_result));

  EXPECT_TRUE(result_called);
}

TEST(CameraPlugin, PausePreviewHandlerCallsPausePreview) {
  int64_t mock_camera_id = 1234;

  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*camera, HasCameraId(Eq(mock_camera_id)))
      .Times(1)
      .WillOnce([cam = camera.get()](int64_t camera_id) {
        return cam->camera_id_ == camera_id;
      });

  EXPECT_CALL(*camera,
              HasPendingResultByType(Eq(PendingResultType::kPausePreview)))
      .Times(1)
      .WillOnce(Return(false));

  EXPECT_CALL(*camera,
              AddPendingVoidResult(Eq(PendingResultType::kPausePreview), _))
      .Times(1)
      .WillOnce([cam = camera.get()](
                    PendingResultType type,
                    std::function<void(std::optional<FlutterError>)> result) {
        cam->pending_void_result_ = std::move(result);
        return true;
      });

  EXPECT_CALL(*camera, GetCaptureController)
      .Times(1)
      .WillOnce([cam = camera.get()]() {
        assert(cam->pending_void_result_);
        return cam->capture_controller_.get();
      });

  EXPECT_CALL(*capture_controller, PausePreview)
      .Times(1)
      .WillOnce([cam = camera.get()]() {
        assert(cam->pending_void_result_);
        return cam->pending_void_result_(std::nullopt);
      });

  camera->camera_id_ = mock_camera_id;
  camera->capture_controller_ = std::move(capture_controller);

  MockCameraPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockCameraFactory>());

  // Add mocked camera to plugins camera list.
  plugin.AddCamera(std::move(camera));

  bool result_called = false;
  std::function<void(std::optional<FlutterError>)> pause_preview_result =
      [&result_called](std::optional<FlutterError> reply) {
        EXPECT_FALSE(result_called);  // Ensure only one reply call.
        result_called = true;
        EXPECT_FALSE(reply);
      };

  plugin.PausePreview(mock_camera_id, std::move(pause_preview_result));

  EXPECT_TRUE(result_called);
}

TEST(CameraPlugin, PausePreviewHandlerErrorOnInvalidCameraId) {
  int64_t mock_camera_id = 1234;
  int64_t missing_camera_id = 5678;

  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*camera, HasCameraId)
      .Times(1)
      .WillOnce([cam = camera.get()](int64_t camera_id) {
        return cam->camera_id_ == camera_id;
      });

  EXPECT_CALL(*camera, HasPendingResultByType).Times(0);
  EXPECT_CALL(*camera, AddPendingVoidResult).Times(0);
  EXPECT_CALL(*camera, GetCaptureController).Times(0);
  EXPECT_CALL(*capture_controller, PausePreview).Times(0);

  camera->camera_id_ = mock_camera_id;

  MockCameraPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockCameraFactory>());

  // Add mocked camera to plugins camera list.
  plugin.AddCamera(std::move(camera));

  bool result_called = false;
  std::function<void(std::optional<FlutterError>)> pause_preview_result =
      [&result_called](std::optional<FlutterError> reply) {
        EXPECT_FALSE(result_called);  // Ensure only one reply call.
        result_called = true;
        EXPECT_TRUE(reply);
      };

  plugin.PausePreview(missing_camera_id, std::move(pause_preview_result));

  EXPECT_TRUE(result_called);
}

}  // namespace test
}  // namespace camera_windows
