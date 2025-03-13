// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "camera.h"

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

#include "messages.g.h"
#include "mocks.h"

namespace camera_windows {
using ::testing::_;
using ::testing::Eq;
using ::testing::NiceMock;
using ::testing::Pointee;
using ::testing::Return;

namespace test {

TEST(Camera, InitCameraCreatesCaptureController) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockCaptureControllerFactory> capture_controller_factory =
      std::make_unique<MockCaptureControllerFactory>();

  EXPECT_CALL(*capture_controller_factory, CreateCaptureController)
      .Times(1)
      .WillOnce([]() {
        std::unique_ptr<NiceMock<MockCaptureController>> capture_controller =
            std::make_unique<NiceMock<MockCaptureController>>();

        EXPECT_CALL(*capture_controller, InitCaptureDevice)
            .Times(1)
            .WillOnce(Return(true));

        return capture_controller;
      });

  EXPECT_TRUE(camera->GetCaptureController() == nullptr);

  PlatformMediaSettings media_settings(PlatformResolutionPreset::kMax, false);

  // Init camera with mock capture controller factory
  bool result = camera->InitCamera(
      std::move(capture_controller_factory),
      std::make_unique<MockTextureRegistrar>().get(),
      std::make_unique<MockBinaryMessenger>().get(), media_settings);
  EXPECT_TRUE(result);
  EXPECT_TRUE(camera->GetCaptureController() != nullptr);
}

TEST(Camera, InitCameraReportsFailure) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockCaptureControllerFactory> capture_controller_factory =
      std::make_unique<MockCaptureControllerFactory>();

  EXPECT_CALL(*capture_controller_factory, CreateCaptureController)
      .Times(1)
      .WillOnce([]() {
        std::unique_ptr<NiceMock<MockCaptureController>> capture_controller =
            std::make_unique<NiceMock<MockCaptureController>>();

        EXPECT_CALL(*capture_controller, InitCaptureDevice)
            .Times(1)
            .WillOnce(Return(false));

        return capture_controller;
      });

  EXPECT_TRUE(camera->GetCaptureController() == nullptr);

  PlatformMediaSettings media_settings(PlatformResolutionPreset::kMax, false);

  // Init camera with mock capture controller factory
  bool result = camera->InitCamera(
      std::move(capture_controller_factory),
      std::make_unique<MockTextureRegistrar>().get(),
      std::make_unique<MockBinaryMessenger>().get(), media_settings);
  EXPECT_FALSE(result);
  EXPECT_TRUE(camera->GetCaptureController() != nullptr);
}

TEST(Camera, AddPendingVoidResultReturnsErrorForDuplicates) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  bool first_result_called = false;
  std::function<void(std::optional<FlutterError>)> first_pending_result =
      [&first_result_called](std::optional<FlutterError> reply) {
        first_result_called = true;
      };
  bool second_result_called = false;
  std::function<void(std::optional<FlutterError>)> second_pending_result =
      [&second_result_called](std::optional<FlutterError> reply) {
        second_result_called = true;
        EXPECT_TRUE(reply);
      };

  camera->AddPendingVoidResult(PendingResultType::kStartRecord,
                               std::move(first_pending_result));
  camera->AddPendingVoidResult(PendingResultType::kStartRecord,
                               std::move(second_pending_result));

  EXPECT_FALSE(first_result_called);
  EXPECT_TRUE(second_result_called);
}

TEST(Camera, AddPendingIntResultReturnsErrorForDuplicates) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  bool first_result_called = false;
  std::function<void(ErrorOr<int64_t>)> first_pending_result =
      [&first_result_called](ErrorOr<int64_t> reply) {
        first_result_called = true;
      };
  bool second_result_called = false;
  std::function<void(ErrorOr<int64_t>)> second_pending_result =
      [&second_result_called](ErrorOr<int64_t> reply) {
        second_result_called = true;
        EXPECT_TRUE(reply.has_error());
      };

  camera->AddPendingIntResult(PendingResultType::kCreateCamera,
                              std::move(first_pending_result));
  camera->AddPendingIntResult(PendingResultType::kCreateCamera,
                              std::move(second_pending_result));

  EXPECT_FALSE(first_result_called);
  EXPECT_TRUE(second_result_called);
}

TEST(Camera, AddPendingStringResultReturnsErrorForDuplicates) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  bool first_result_called = false;
  std::function<void(ErrorOr<std::string>)> first_pending_result =
      [&first_result_called](ErrorOr<std::string> reply) {
        first_result_called = true;
      };
  bool second_result_called = false;
  std::function<void(ErrorOr<std::string>)> second_pending_result =
      [&second_result_called](ErrorOr<std::string> reply) {
        second_result_called = true;
        EXPECT_TRUE(reply.has_error());
      };

  camera->AddPendingStringResult(PendingResultType::kStopRecord,
                                 std::move(first_pending_result));
  camera->AddPendingStringResult(PendingResultType::kStopRecord,
                                 std::move(second_pending_result));

  EXPECT_FALSE(first_result_called);
  EXPECT_TRUE(second_result_called);
}

TEST(Camera, AddPendingSizeResultReturnsErrorForDuplicates) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  bool first_result_called = false;
  std::function<void(ErrorOr<PlatformSize>)> first_pending_result =
      [&first_result_called](ErrorOr<PlatformSize> reply) {
        first_result_called = true;
      };
  bool second_result_called = false;
  std::function<void(ErrorOr<PlatformSize>)> second_pending_result =
      [&second_result_called](ErrorOr<PlatformSize> reply) {
        second_result_called = true;
        EXPECT_TRUE(reply.has_error());
      };

  camera->AddPendingSizeResult(PendingResultType::kInitialize,
                               std::move(first_pending_result));
  camera->AddPendingSizeResult(PendingResultType::kInitialize,
                               std::move(second_pending_result));

  EXPECT_FALSE(first_result_called);
  EXPECT_TRUE(second_result_called);
}

TEST(Camera, OnCreateCaptureEngineSucceededReturnsCameraId) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);

  const int64_t texture_id = 12345;

  bool result_called = false;
  camera->AddPendingIntResult(
      PendingResultType::kCreateCamera,
      [&result_called, texture_id](ErrorOr<int64_t> reply) {
        result_called = true;
        EXPECT_FALSE(reply.has_error());
        EXPECT_EQ(reply.value(), texture_id);
      });

  camera->OnCreateCaptureEngineSucceeded(texture_id);

  EXPECT_TRUE(result_called);
}

TEST(Camera, CreateCaptureEngineReportsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);

  const std::string error_text = "error_text";

  bool result_called = false;
  camera->AddPendingIntResult(
      PendingResultType::kCreateCamera,
      [&result_called, error_text](ErrorOr<int64_t> reply) {
        result_called = true;
        EXPECT_TRUE(reply.has_error());
        EXPECT_EQ(reply.error().code(), "camera_error");
        EXPECT_EQ(reply.error().message(), error_text);
      });

  camera->OnCreateCaptureEngineFailed(CameraResult::kError, error_text);

  EXPECT_TRUE(result_called);
}

TEST(Camera, CreateCaptureEngineReportsAccessDenied) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);

  const std::string error_text = "error_text";

  bool result_called = false;
  camera->AddPendingIntResult(
      PendingResultType::kCreateCamera,
      [&result_called, error_text](ErrorOr<int64_t> reply) {
        result_called = true;
        EXPECT_TRUE(reply.has_error());
        EXPECT_EQ(reply.error().code(), "CameraAccessDenied");
        EXPECT_EQ(reply.error().message(), error_text);
      });

  camera->OnCreateCaptureEngineFailed(CameraResult::kAccessDenied, error_text);

  EXPECT_TRUE(result_called);
}

TEST(Camera, OnStartPreviewSucceededReturnsFrameSize) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);

  const int32_t width = 123;
  const int32_t height = 456;

  bool result_called = false;
  camera->AddPendingSizeResult(
      PendingResultType::kInitialize,
      [&result_called, width, height](ErrorOr<PlatformSize> reply) {
        result_called = true;
        EXPECT_FALSE(reply.has_error());
        EXPECT_EQ(reply.value().width(), width);
        EXPECT_EQ(reply.value().height(), height);
      });

  camera->OnStartPreviewSucceeded(width, height);

  EXPECT_TRUE(result_called);
}

TEST(Camera, StartPreviewReportsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);

  const std::string error_text = "error_text";

  bool result_called = false;
  camera->AddPendingSizeResult(
      PendingResultType::kInitialize,
      [&result_called, error_text](ErrorOr<PlatformSize> reply) {
        result_called = true;
        EXPECT_TRUE(reply.has_error());
        EXPECT_EQ(reply.error().code(), "camera_error");
        EXPECT_EQ(reply.error().message(), error_text);
      });

  camera->OnStartPreviewFailed(CameraResult::kError, error_text);

  EXPECT_TRUE(result_called);
}

TEST(Camera, StartPreviewReportsAccessDenied) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);

  const std::string error_text = "error_text";

  bool result_called = false;
  camera->AddPendingSizeResult(
      PendingResultType::kInitialize,
      [&result_called, error_text](ErrorOr<PlatformSize> reply) {
        result_called = true;
        EXPECT_TRUE(reply.has_error());
        EXPECT_EQ(reply.error().code(), "CameraAccessDenied");
        EXPECT_EQ(reply.error().message(), error_text);
      });

  camera->OnStartPreviewFailed(CameraResult::kAccessDenied, error_text);

  EXPECT_TRUE(result_called);
}

TEST(Camera, OnPausePreviewSucceededReturnsSuccess) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);

  bool result_called = false;
  camera->AddPendingVoidResult(
      PendingResultType::kPausePreview,
      [&result_called](std::optional<FlutterError> reply) {
        result_called = true;
        EXPECT_FALSE(reply);
      });

  camera->OnPausePreviewSucceeded();

  EXPECT_TRUE(result_called);
}

TEST(Camera, PausePreviewReportsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);

  const std::string error_text = "error_text";

  bool result_called = false;
  camera->AddPendingVoidResult(
      PendingResultType::kPausePreview,
      [&result_called, error_text](std::optional<FlutterError> reply) {
        result_called = true;
        EXPECT_TRUE(reply);
        EXPECT_EQ(reply.value().code(), "camera_error");
        EXPECT_EQ(reply.value().message(), error_text);
      });

  camera->OnPausePreviewFailed(CameraResult::kError, error_text);

  EXPECT_TRUE(result_called);
}

TEST(Camera, PausePreviewReportsAccessDenied) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);

  const std::string error_text = "error_text";

  bool result_called = false;
  camera->AddPendingVoidResult(
      PendingResultType::kPausePreview,
      [&result_called, error_text](std::optional<FlutterError> reply) {
        result_called = true;
        EXPECT_TRUE(reply);
        EXPECT_EQ(reply.value().code(), "CameraAccessDenied");
        EXPECT_EQ(reply.value().message(), error_text);
      });

  camera->OnPausePreviewFailed(CameraResult::kAccessDenied, error_text);

  EXPECT_TRUE(result_called);
}

TEST(Camera, OnResumePreviewSucceededReturnsSuccess) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);

  bool result_called = false;
  camera->AddPendingVoidResult(
      PendingResultType::kResumePreview,
      [&result_called](std::optional<FlutterError> reply) {
        result_called = true;
        EXPECT_FALSE(reply);
      });

  camera->OnResumePreviewSucceeded();

  EXPECT_TRUE(result_called);
}

TEST(Camera, ResumePreviewReportsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);

  const std::string error_text = "error_text";

  bool result_called = false;
  camera->AddPendingVoidResult(
      PendingResultType::kResumePreview,
      [&result_called, error_text](std::optional<FlutterError> reply) {
        result_called = true;
        EXPECT_TRUE(reply);
        EXPECT_EQ(reply.value().code(), "camera_error");
        EXPECT_EQ(reply.value().message(), error_text);
      });

  camera->OnResumePreviewFailed(CameraResult::kError, error_text);

  EXPECT_TRUE(result_called);
}

TEST(Camera, OnResumePreviewPermissionFailureReturnsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);

  const std::string error_text = "error_text";

  bool result_called = false;
  camera->AddPendingVoidResult(
      PendingResultType::kResumePreview,
      [&result_called, error_text](std::optional<FlutterError> reply) {
        result_called = true;
        EXPECT_TRUE(reply);
        EXPECT_EQ(reply.value().code(), "CameraAccessDenied");
        EXPECT_EQ(reply.value().message(), error_text);
      });

  camera->OnResumePreviewFailed(CameraResult::kAccessDenied, error_text);

  EXPECT_TRUE(result_called);
}

TEST(Camera, OnStartRecordSucceededReturnsSuccess) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);

  bool result_called = false;
  camera->AddPendingVoidResult(
      PendingResultType::kStartRecord,
      [&result_called](std::optional<FlutterError> reply) {
        result_called = true;
        EXPECT_FALSE(reply);
      });

  camera->OnStartRecordSucceeded();

  EXPECT_TRUE(result_called);
}

TEST(Camera, StartRecordReportsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);

  const std::string error_text = "error_text";

  bool result_called = false;
  camera->AddPendingVoidResult(
      PendingResultType::kStartRecord,
      [&result_called, error_text](std::optional<FlutterError> reply) {
        result_called = true;
        EXPECT_TRUE(reply);
        EXPECT_EQ(reply.value().code(), "camera_error");
        EXPECT_EQ(reply.value().message(), error_text);
      });

  camera->OnStartRecordFailed(CameraResult::kError, error_text);

  EXPECT_TRUE(result_called);
}

TEST(Camera, StartRecordReportsAccessDenied) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);

  const std::string error_text = "error_text";

  bool result_called = false;
  camera->AddPendingVoidResult(
      PendingResultType::kStartRecord,
      [&result_called, error_text](std::optional<FlutterError> reply) {
        result_called = true;
        EXPECT_TRUE(reply);
        EXPECT_EQ(reply.value().code(), "CameraAccessDenied");
        EXPECT_EQ(reply.value().message(), error_text);
      });

  camera->OnStartRecordFailed(CameraResult::kAccessDenied, error_text);

  EXPECT_TRUE(result_called);
}

TEST(Camera, OnStopRecordSucceededReturnsSuccess) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);

  const std::string file_path = "C:\temp\filename.mp4";

  bool result_called = false;
  camera->AddPendingStringResult(
      PendingResultType::kStopRecord,
      [&result_called, file_path](ErrorOr<std::string> reply) {
        result_called = true;
        EXPECT_FALSE(reply.has_error());
        EXPECT_EQ(reply.value(), file_path);
      });

  camera->OnStopRecordSucceeded(file_path);

  EXPECT_TRUE(result_called);
}

TEST(Camera, StopRecordReportsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);

  const std::string error_text = "error_text";

  bool result_called = false;
  camera->AddPendingStringResult(
      PendingResultType::kStopRecord,
      [&result_called, error_text](ErrorOr<std::string> reply) {
        result_called = true;
        EXPECT_TRUE(reply.has_error());
        EXPECT_EQ(reply.error().code(), "camera_error");
        EXPECT_EQ(reply.error().message(), error_text);
      });

  camera->OnStopRecordFailed(CameraResult::kError, error_text);

  EXPECT_TRUE(result_called);
}

TEST(Camera, StopRecordReportsAccessDenied) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);

  const std::string error_text = "error_text";

  bool result_called = false;
  camera->AddPendingStringResult(
      PendingResultType::kStopRecord,
      [&result_called, error_text](ErrorOr<std::string> reply) {
        result_called = true;
        EXPECT_TRUE(reply.has_error());
        EXPECT_EQ(reply.error().code(), "CameraAccessDenied");
        EXPECT_EQ(reply.error().message(), error_text);
      });

  camera->OnStopRecordFailed(CameraResult::kAccessDenied, error_text);

  EXPECT_TRUE(result_called);
}

TEST(Camera, OnTakePictureSucceededReturnsSuccess) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);

  const std::string file_path = "C:\\temp\\filename.jpeg";

  bool result_called = false;
  camera->AddPendingStringResult(
      PendingResultType::kTakePicture,
      [&result_called, file_path](ErrorOr<std::string> reply) {
        result_called = true;
        EXPECT_FALSE(reply.has_error());
        EXPECT_EQ(reply.value(), file_path);
      });

  camera->OnTakePictureSucceeded(file_path);

  EXPECT_TRUE(result_called);
}

TEST(Camera, TakePictureReportsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);

  const std::string error_text = "error_text";

  bool result_called = false;
  camera->AddPendingStringResult(
      PendingResultType::kTakePicture,
      [&result_called, error_text](ErrorOr<std::string> reply) {
        result_called = true;
        EXPECT_TRUE(reply.has_error());
        EXPECT_EQ(reply.error().code(), "camera_error");
        EXPECT_EQ(reply.error().message(), error_text);
      });

  camera->OnTakePictureFailed(CameraResult::kError, error_text);

  EXPECT_TRUE(result_called);
}

TEST(Camera, TakePictureReportsAccessDenied) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);

  const std::string error_text = "error_text";

  bool result_called = false;
  camera->AddPendingStringResult(
      PendingResultType::kTakePicture,
      [&result_called, error_text](ErrorOr<std::string> reply) {
        result_called = true;
        EXPECT_TRUE(reply.has_error());
        EXPECT_EQ(reply.error().code(), "CameraAccessDenied");
        EXPECT_EQ(reply.error().message(), error_text);
      });

  camera->OnTakePictureFailed(CameraResult::kAccessDenied, error_text);

  EXPECT_TRUE(result_called);
}

}  // namespace test
}  // namespace camera_windows
