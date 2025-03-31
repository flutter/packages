// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "camera.h"

namespace camera_windows {

// Camera error codes
constexpr char kCameraAccessDenied[] = "CameraAccessDenied";
constexpr char kCameraError[] = "camera_error";
constexpr char kPluginDisposed[] = "plugin_disposed";

std::string GetErrorCode(CameraResult result) {
  assert(result != CameraResult::kSuccess);

  switch (result) {
    case CameraResult::kAccessDenied:
      return kCameraAccessDenied;

    case CameraResult::kSuccess:
    case CameraResult::kError:
    default:
      return kCameraError;
  }
}

CameraImpl::CameraImpl(const std::string& device_id)
    : device_id_(device_id), Camera(device_id) {}

CameraImpl::~CameraImpl() {
  // Sends camera closing event.
  OnCameraClosing();

  capture_controller_ = nullptr;
  SendErrorForPendingResults(kPluginDisposed,
                             "Plugin disposed before request was handled");
}

bool CameraImpl::InitCamera(flutter::TextureRegistrar* texture_registrar,
                            flutter::BinaryMessenger* messenger,
                            const PlatformMediaSettings& media_settings) {
  auto capture_controller_factory =
      std::make_unique<CaptureControllerFactoryImpl>();
  return InitCamera(std::move(capture_controller_factory), texture_registrar,
                    messenger, media_settings);
}

bool CameraImpl::InitCamera(
    std::unique_ptr<CaptureControllerFactory> capture_controller_factory,
    flutter::TextureRegistrar* texture_registrar,
    flutter::BinaryMessenger* messenger,
    const PlatformMediaSettings& media_settings) {
  assert(!device_id_.empty());
  messenger_ = messenger;
  capture_controller_ =
      capture_controller_factory->CreateCaptureController(this);
  return capture_controller_->InitCaptureDevice(texture_registrar, device_id_,
                                                media_settings);
}

bool CameraImpl::AddPendingVoidResult(
    PendingResultType type,
    std::function<void(std::optional<FlutterError> reply)> result) {
  assert(result);
  return AddPendingResult(type, result);
}

bool CameraImpl::AddPendingIntResult(
    PendingResultType type,
    std::function<void(ErrorOr<int64_t> reply)> result) {
  assert(result);
  return AddPendingResult(type, result);
}

bool CameraImpl::AddPendingStringResult(
    PendingResultType type,
    std::function<void(ErrorOr<std::string> reply)> result) {
  assert(result);
  return AddPendingResult(type, result);
}

bool CameraImpl::AddPendingSizeResult(
    PendingResultType type,
    std::function<void(ErrorOr<PlatformSize> reply)> result) {
  assert(result);
  return AddPendingResult(type, result);
}

bool CameraImpl::AddPendingResult(PendingResultType type,
                                  CameraImpl::AsyncResult result) {
  auto it = pending_results_.find(type);
  if (it != pending_results_.end()) {
    std::visit(
        [](auto&& r) {
          r(FlutterError("Duplicate request", "Method handler already called"));
        },
        result);
    return false;
  }

  pending_results_.insert(std::make_pair(type, std::move(result)));
  return true;
}

std::function<void(std::optional<FlutterError> reply)>
CameraImpl::GetPendingVoidResultByType(PendingResultType type) {
  std::optional<AsyncResult> result = GetPendingResultByType(type);
  if (!result) {
    return nullptr;
  }
  return std::get<std::function<void(std::optional<FlutterError>)>>(
      result.value());
}

std::function<void(ErrorOr<int64_t> reply)>
CameraImpl::GetPendingIntResultByType(PendingResultType type) {
  std::optional<AsyncResult> result = GetPendingResultByType(type);
  if (!result) {
    return nullptr;
  }
  return std::get<std::function<void(ErrorOr<int64_t>)>>(result.value());
}

std::function<void(ErrorOr<std::string> reply)>
CameraImpl::GetPendingStringResultByType(PendingResultType type) {
  std::optional<AsyncResult> result = GetPendingResultByType(type);
  if (!result) {
    return nullptr;
  }
  return std::get<std::function<void(ErrorOr<std::string>)>>(result.value());
}

std::function<void(ErrorOr<PlatformSize> reply)>
CameraImpl::GetPendingSizeResultByType(PendingResultType type) {
  std::optional<AsyncResult> result = GetPendingResultByType(type);
  if (!result) {
    return nullptr;
  }
  return std::get<std::function<void(ErrorOr<PlatformSize>)>>(result.value());
}

std::optional<CameraImpl::AsyncResult> CameraImpl::GetPendingResultByType(
    PendingResultType type) {
  auto it = pending_results_.find(type);
  if (it == pending_results_.end()) {
    return std::nullopt;
  }
  CameraImpl::AsyncResult result = std::move(it->second);
  pending_results_.erase(it);
  return result;
}

bool CameraImpl::HasPendingResultByType(PendingResultType type) const {
  auto it = pending_results_.find(type);
  return it != pending_results_.end();
}

void CameraImpl::SendErrorForPendingResults(const std::string& error_code,
                                            const std::string& description) {
  for (const auto& pending_result : pending_results_) {
    std::visit(
        [&error_code, &description](auto&& result) {
          result(FlutterError(error_code, description));
        },
        pending_result.second);
  }
  pending_results_.clear();
}

CameraEventApi* CameraImpl::GetEventApi() {
  assert(messenger_);
  assert(camera_id_);

  if (!event_api_) {
    std::string suffix = std::to_string(camera_id_);
    event_api_ = std::make_unique<CameraEventApi>(messenger_, suffix);
  }

  return event_api_.get();
}

void CameraImpl::OnCreateCaptureEngineSucceeded(int64_t texture_id) {
  // Use texture id as camera id
  camera_id_ = texture_id;
  auto pending_result =
      GetPendingIntResultByType(PendingResultType::kCreateCamera);
  if (pending_result) {
    pending_result(texture_id);
  }
}

void CameraImpl::OnCreateCaptureEngineFailed(CameraResult result,
                                             const std::string& error) {
  auto pending_result =
      GetPendingIntResultByType(PendingResultType::kCreateCamera);
  if (pending_result) {
    std::string error_code = GetErrorCode(result);
    pending_result(FlutterError(error_code, error));
  }
}

void CameraImpl::OnStartPreviewSucceeded(int32_t width, int32_t height) {
  auto pending_result =
      GetPendingSizeResultByType(PendingResultType::kInitialize);
  if (pending_result) {
    pending_result(
        PlatformSize(static_cast<double>(width), static_cast<double>(height)));
  }
};

void CameraImpl::OnStartPreviewFailed(CameraResult result,
                                      const std::string& error) {
  auto pending_result =
      GetPendingSizeResultByType(PendingResultType::kInitialize);
  if (pending_result) {
    std::string error_code = GetErrorCode(result);
    pending_result(FlutterError(error_code, error));
  }
};

void CameraImpl::OnResumePreviewSucceeded() {
  auto pending_result =
      GetPendingVoidResultByType(PendingResultType::kResumePreview);
  if (pending_result) {
    pending_result(std::nullopt);
  }
}

void CameraImpl::OnResumePreviewFailed(CameraResult result,
                                       const std::string& error) {
  auto pending_result =
      GetPendingVoidResultByType(PendingResultType::kResumePreview);
  if (pending_result) {
    std::string error_code = GetErrorCode(result);
    pending_result(FlutterError(error_code, error));
  }
}

void CameraImpl::OnPausePreviewSucceeded() {
  auto pending_result =
      GetPendingVoidResultByType(PendingResultType::kPausePreview);
  if (pending_result) {
    pending_result(std::nullopt);
  }
}

void CameraImpl::OnPausePreviewFailed(CameraResult result,
                                      const std::string& error) {
  auto pending_result =
      GetPendingVoidResultByType(PendingResultType::kPausePreview);
  if (pending_result) {
    std::string error_code = GetErrorCode(result);
    pending_result(FlutterError(error_code, error));
  }
}

void CameraImpl::OnStartRecordSucceeded() {
  auto pending_result =
      GetPendingVoidResultByType(PendingResultType::kStartRecord);
  if (pending_result) {
    pending_result(std::nullopt);
  }
};

void CameraImpl::OnStartRecordFailed(CameraResult result,
                                     const std::string& error) {
  auto pending_result =
      GetPendingVoidResultByType(PendingResultType::kStartRecord);
  if (pending_result) {
    std::string error_code = GetErrorCode(result);
    pending_result(FlutterError(error_code, error));
  }
};

void CameraImpl::OnStopRecordSucceeded(const std::string& file_path) {
  auto pending_result =
      GetPendingStringResultByType(PendingResultType::kStopRecord);
  if (pending_result) {
    pending_result(file_path);
  }
};

void CameraImpl::OnStopRecordFailed(CameraResult result,
                                    const std::string& error) {
  auto pending_result =
      GetPendingStringResultByType(PendingResultType::kStopRecord);
  if (pending_result) {
    std::string error_code = GetErrorCode(result);
    pending_result(FlutterError(error_code, error));
  }
};

void CameraImpl::OnTakePictureSucceeded(const std::string& file_path) {
  auto pending_result =
      GetPendingStringResultByType(PendingResultType::kTakePicture);
  if (pending_result) {
    pending_result(file_path);
  }
};

void CameraImpl::OnTakePictureFailed(CameraResult result,
                                     const std::string& error) {
  auto pending_take_picture_result =
      GetPendingStringResultByType(PendingResultType::kTakePicture);
  if (pending_take_picture_result) {
    std::string error_code = GetErrorCode(result);
    pending_take_picture_result(FlutterError(error_code, error));
  }
};

void CameraImpl::OnCaptureError(CameraResult result, const std::string& error) {
  if (messenger_ && camera_id_ >= 0) {
    GetEventApi()->Error(
        error,
        // TODO(stuartmorgan): Replace with an event channel, since that's how
        // these calls are used. Given that use case, ignore responses.
        []() {}, [](const FlutterError& error) {});
  }

  std::string error_code = GetErrorCode(result);
  SendErrorForPendingResults(error_code, error);
}

void CameraImpl::OnCameraClosing() {
  if (messenger_ && camera_id_ >= 0) {
    // TODO(stuartmorgan): Replace with an event channel, since that's how
    // these calls are used. Given that use case, ignore responses.
    GetEventApi()->CameraClosing([]() {}, [](const FlutterError& error) {});
  }
}

}  // namespace camera_windows
