#include "camera.h"

#include <opencv2/opencv.hpp>
#include <thread>

#include "capture_pipeline.h"

Camera::Camera(Pylon::IPylonDevice* device, int64_t camera_id,
               FlPluginRegistrar* registrar,
               CameraLinuxPlatformResolutionPreset resolution_preset)
    : camera_id(camera_id),
      cameraLinuxCameraEventApi(camera_linux_camera_event_api_new(
          fl_plugin_registrar_get_messenger(registrar),
          std::to_string(camera_id).c_str())),
      exposure_mode(CameraLinuxPlatformExposureMode::
                        CAMERA_LINUX_PLATFORM_EXPOSURE_MODE_AUTO),
      focus_mode(CameraLinuxPlatformFocusMode::
                     CAMERA_LINUX_PLATFORM_FOCUS_MODE_LOCKED),
      width(3840),
      height(2160),
      imageFormatGroup(CameraLinuxPlatformImageFormatGroup::
                           CAMERA_LINUX_PLATFORM_IMAGE_FORMAT_GROUP_RGB8),
      resolution_preset(resolution_preset),
      registrar(registrar) {
  camera = std::make_unique<Pylon::CInstantCamera>(device);
  setResolutionPreset(resolution_preset);
  if (registrar) g_object_ref(registrar);
}

Camera::~Camera() {
  if (capturePipeline && camera) camera->StopGrabbing();
  if (camera) {
    if (camera->IsGrabbing()) camera->StopGrabbing();
    if (camera->IsOpen()) camera->Close();
  }
  if (cameraLinuxCameraEventApi) g_object_unref(cameraLinuxCameraEventApi);
  if (registrar) g_object_unref(registrar);
}

void Camera::initialize(CameraLinuxPlatformImageFormatGroup imageFormat) {
  imageFormatGroup = imageFormat;
  capturePipeline = std::make_unique<CapturePipeline>(*this, registrar);
  if (camera->IsOpen()) {
    camera->Close();
  }

  camera->Open();
  GenApi::INodeMap& nodemap = camera->GetNodeMap();
  Pylon::CEnumParameter(nodemap, "DeviceLinkThroughputLimitMode")
      .TrySetValue("Off");
  Pylon::CBooleanParameter(nodemap, "AcquisitionFrameRateEnable")
      .TrySetValue(true);
  Pylon::CFloatParameter(nodemap, "AcquisitionFrameRate").TrySetValue(60.0);
  Pylon::CFloatParameter(nodemap, "ResultingFrameRate").TrySetValue(60.0);
  setImageFormatGroup(imageFormat);
  Pylon::CIntegerParameter(nodemap, "Width").TrySetValue(width);
  Pylon::CIntegerParameter(nodemap, "Height").TrySetValue(height);
  Pylon::CIntegerParameter(nodemap, "OffsetX").TrySetValue(0);
  Pylon::CIntegerParameter(nodemap, "OffsetY").TrySetValue(0);
  Pylon::CStringParameter(nodemap, "ExposureAuto").TrySetValue("Off");
  Pylon::CBooleanParameter(nodemap, "ReverseY").TrySetValue(true);
  Pylon::CBooleanParameter(nodemap, "AutoFunctionROIUseBrightness")
      .TrySetValue(false);
  Pylon::CBooleanParameter(nodemap, "AutoFunctionROIUseWhiteBalance")
      .TrySetValue(false);
  Pylon::CEnumParameter(nodemap, "BslDefectPixelCorrectionMode")
      .TrySetValue("On");

  capturePipeline->StartGrabbing();
  emitState();
}

void Camera::setImageFormatGroup(
    CameraLinuxPlatformImageFormatGroup imageFormatGroup) {
  CAMERA_CONFIG_LOCK({
    GenApi::INodeMap& nodemap = camera->GetNodeMap();
    switch (imageFormatGroup) {
      case CameraLinuxPlatformImageFormatGroup::
          CAMERA_LINUX_PLATFORM_IMAGE_FORMAT_GROUP_MONO8:
        Pylon::CEnumParameter(nodemap, "PixelFormat").SetValue("Mono8");
        break;
      case CameraLinuxPlatformImageFormatGroup::
          CAMERA_LINUX_PLATFORM_IMAGE_FORMAT_GROUP_RGB8:
      default:
        Pylon::CEnumParameter(nodemap, "PixelFormat").SetValue("RGB8");
        break;
    }
  });
}

int64_t Camera::getTextureId() {
  if (!capturePipeline) return -1;
  return capturePipeline->get_texture_id();
}

void Camera::takePicture(std::string filePath) {
  CAMERA_CONFIG_LOCK(
      Pylon::CGrabResultPtr grabResult;

      if (camera->IsGrabbing()) { camera->StopGrabbing(); }

      if (!camera->GrabOne(Pylon::INFINITE, grabResult,
                           Pylon::TimeoutHandling_Return)) {
        std::cerr << "Failed to grab image within timeout." << std::endl;
        return;
      }

      if (!grabResult.IsValid() || !grabResult->GrabSucceeded()) {
        std::cerr << "Failed to grab image." << std::endl;
        return;
      };
      Pylon::CPylonImage image; image.AttachGrabResultBuffer(grabResult);
      bool isMono = image.GetPixelType() == Pylon::PixelType_Mono8 ||
                    image.GetPixelType() == Pylon::PixelType_Mono12 ||
                    image.GetPixelType() == Pylon::PixelType_Mono16;

      cv::Mat mat(grabResult->GetHeight(), grabResult->GetWidth(),
                  isMono ? CV_8UC1 : CV_8UC3, (uint8_t*)image.GetBuffer());
      cv::Mat bgr;
      cv::cvtColor(mat, bgr, isMono ? cv::COLOR_GRAY2BGR : cv::COLOR_RGB2BGR);
      cv::imwrite(filePath, bgr);

  );
}

void camera_linux_camera_event_api_initialized_callback(GObject* object,
                                                        GAsyncResult* result,
                                                        gpointer user_data) {}

void Camera::emitState() {
  if (!cameraLinuxCameraEventApi) return;
  CameraLinuxPlatformSize* size = camera_linux_platform_size_new(width, height);
  CameraLinuxPlatformCameraState* cameraState =
      camera_linux_platform_camera_state_new(size, exposure_mode, focus_mode,
                                             false, false);
  camera_linux_camera_event_api_initialized(
      cameraLinuxCameraEventApi, cameraState, nullptr,
      camera_linux_camera_event_api_initialized_callback, nullptr);
  g_object_unref(cameraState);
  g_object_unref(size);
}

void Camera::emitTextureId(int64_t textureId) const {
  if (!cameraLinuxCameraEventApi) return;

  camera_linux_camera_event_api_texture_id(
      cameraLinuxCameraEventApi, textureId, nullptr,
      camera_linux_camera_event_api_initialized_callback, nullptr);
}

// void Camera::startGrabbing() {
//   GenApi::INodeMap& nodemap = camera->GetNodeMap();
//   Pylon::CEnumParameter(nodemap, "TriggerSelector").SetValue("FrameStart");
//   Pylon::CEnumParameter(nodemap, "TriggerMode").SetValue("On");
//   Pylon::CEnumParameter(nodemap, "TriggerSource").SetValue("Software");

//   // Manual grab loop with exposure bracketing
//   cameraTextureImageEventHandler->OnImageEventHandlerRegistered(*camera);

//   camera->StartGrabbing(Pylon::GrabStrategy_OneByOne,
//                         Pylon::EGrabLoop::GrabLoop_ProvidedByUser);

//   std::thread([this]() {
//     double shortExposure = 1000.0;  // µs - initial value
//     // double longExposure = 128000.0;  // µs
//     // const double gain = 0.6;
//     // const double targetBrightness = 120.0;  // target average
//     // brightness

//     // const double overblownTargetRatio = 0.01;  // 3%
//     // const double overblownThreshold = 240.0;

//     auto& nodemap = camera->GetNodeMap();
//     // const double minExposure =
//     //     Pylon::CFloatParameter(nodemap, "ExposureTime").GetMin();
//     // const double maxExposure =
//     //     Pylon::CFloatParameter(nodemap, "ExposureTime").GetMax();

//     while (camera->IsGrabbing()) {
//       // --- Short exposure ---
//       Pylon::CFloatParameter(nodemap, "ExposureTime")
//           .TrySetValue(shortExposure);
//       camera->WaitForFrameTriggerReady(5000,
//                                        Pylon::TimeoutHandling_ThrowException);
//       camera->ExecuteSoftwareTrigger();

//       Pylon::CGrabResultPtr shortResult;
//       camera->RetrieveResult(5000, shortResult,
//                              Pylon::TimeoutHandling_ThrowException);

//       // if (shortResult && shortResult->GrabSucceeded()) {
//       //   cameraTextureImageEventHandler->OnImageGrabbed(*camera,
//       //   shortResult);

//       //   // === Adjust short exposure for overblown % ===
//       //   const int width = shortResult->GetWidth();
//       //   const int height = shortResult->GetHeight();
//       //   const uint8_t* buffer =
//       //       static_cast<const uint8_t*>(shortResult->GetBuffer());

//       //   const int cx = width / 2;
//       //   const int cy = height / 2;
//       //   const int radius = std::min(width, height) / 4;

//       //   size_t overblown = 0;
//       //   size_t total = 0;

//       //   for (int y = 0; y < height; ++y) {
//       //     for (int x = 0; x < width; ++x) {
//       //       int dx = x - cx;
//       //       int dy = y - cy;
//       //       if (dx * dx + dy * dy <= radius * radius) {
//       //         int index = (y * width + x) * 3;
//       //         uint8_t r = buffer[index];
//       //         uint8_t g = buffer[index + 1];
//       //         uint8_t b = buffer[index + 2];
//       //         double luminance = 0.299 * r + 0.587 * g + 0.114 * b;

//       //         if (luminance >= overblownThreshold) {
//       //           overblown++;
//       //         }
//       //         total++;
//       //       }
//       //     }
//       //   }

//       //   if (total > 0) {
//       //     double ratio = static_cast<double>(overblown) / total;
//       //     double error = overblownTargetRatio - ratio;

//       //     // Adjust short exposure proportionally
//       //     double proposed =
//       //         shortExposure * (1.0 + gain * error /
//       //         overblownTargetRatio);
//       //     shortExposure =
//       //         std::max(minExposure, std::min(maxExposure, proposed));
//       //   }
//       // }

//       // // --- Long exposure ---
//       // Pylon::CFloatParameter(nodemap,
//       // "ExposureTime").TrySetValue(longExposure);
//       // camera->WaitForFrameTriggerReady(5000,
//       // Pylon::TimeoutHandling_ThrowException);
//       // camera->ExecuteSoftwareTrigger();

//       // Pylon::CGrabResultPtr longResult;
//       // camera->RetrieveResult(5000, longResult,
//       //                        Pylon::TimeoutHandling_ThrowException);
//       // if (longResult && longResult->GrabSucceeded()) {
//       //   cameraTextureImageEventHandler->OnImageGrabbed(*camera,
//       //   longResult);

//       //   // === Adjust long exposure brightness as before ===
//       //   const int width = longResult->GetWidth();
//       //   const int height = longResult->GetHeight();
//       //   const uint8_t* buffer =
//       //       static_cast<const uint8_t*>(longResult->GetBuffer());

//       //   const int cx = width / 2;
//       //   const int cy = height / 2;
//       //   const int radius = std::min(width, height) / 4;

//       //   uint64_t sum = 0;
//       //   size_t count = 0;

//       //   for (int y = 0; y < height; ++y) {
//       //     for (int x = 0; x < width; ++x) {
//       //       int dx = x - cx;
//       //       int dy = y - cy;
//       //       if (dx * dx + dy * dy <= radius * radius) {
//       //         int index = (y * width + x) * 3;
//       //         uint8_t r = buffer[index];
//       //         uint8_t g = buffer[index + 1];
//       //         uint8_t b = buffer[index + 2];
//       //         double luminance = 0.299 * r + 0.587 * g + 0.114 * b;

//       //         if (luminance > 10 && luminance < 240) {
//       //           sum += luminance;
//       //           count++;
//       //         }
//       //       }
//       //     }
//       //   }

//       //   if (count > 0) {
//       //     double avgBrightness = static_cast<double>(sum) / count;
//       //     double error = targetBrightness - avgBrightness;
//       //     double proposed =
//       //         longExposure * (1.0 + gain * error / targetBrightness);
//       //     longExposure = std::max(minExposure, std::min(maxExposure,
//       //     proposed));
//       //   }
//       // }
//     }
//   }).detach();
// }

Camera& Camera::setResolutionPreset(
    CameraLinuxPlatformResolutionPreset preset) {
  switch (preset) {
    case CameraLinuxPlatformResolutionPreset::
        CAMERA_LINUX_PLATFORM_RESOLUTION_PRESET_LOW:
      width = 352;
      height = 288;
      break;
    case CameraLinuxPlatformResolutionPreset::
        CAMERA_LINUX_PLATFORM_RESOLUTION_PRESET_MEDIUM:
      width = 640;
      height = 480;
      break;
    case CameraLinuxPlatformResolutionPreset::
        CAMERA_LINUX_PLATFORM_RESOLUTION_PRESET_HIGH:
      width = 1280;
      height = 720;
      break;
    case CameraLinuxPlatformResolutionPreset::
        CAMERA_LINUX_PLATFORM_RESOLUTION_PRESET_VERY_HIGH:
      width = 1920;
      height = 1080;
      break;
    case CameraLinuxPlatformResolutionPreset::
        CAMERA_LINUX_PLATFORM_RESOLUTION_PRESET_ULTRA_HIGH:
    case CameraLinuxPlatformResolutionPreset::
        CAMERA_LINUX_PLATFORM_RESOLUTION_PRESET_MAX:
      width = 3840;
      height = 2160;
      break;
    default:
      width = 1920;
      height = 1080;
      break;
  }
  resolution_preset = preset;
  return *this;
}

void Camera::setExposureMode(CameraLinuxPlatformExposureMode mode) {
  CAMERA_CONFIG_LOCK({
    GenApi::INodeMap& nodemap = camera->GetNodeMap();
    switch (mode) {
      case CameraLinuxPlatformExposureMode::
          CAMERA_LINUX_PLATFORM_EXPOSURE_MODE_AUTO:
        Pylon::CEnumParameter(nodemap, "ExposureAuto")
            .TrySetValue("Continuous");
        break;
      case CameraLinuxPlatformExposureMode::
          CAMERA_LINUX_PLATFORM_EXPOSURE_MODE_LOCKED:
        Pylon::CEnumParameter(nodemap, "ExposureAuto").TrySetValue("Off");
        break;
      default:
        Pylon::CEnumParameter(nodemap, "ExposureAuto")
            .TrySetValue("Continuous");
        break;
    }
    exposure_mode = mode;
    emitState();
  });
}

void Camera::setFocusMode(CameraLinuxPlatformFocusMode mode) {
  CAMERA_CONFIG_LOCK({
    GenApi::INodeMap& nodemap = camera->GetNodeMap();
    switch (mode) {
      case CameraLinuxPlatformFocusMode::CAMERA_LINUX_PLATFORM_FOCUS_MODE_AUTO:
        Pylon::CEnumParameter(nodemap, "FocusAuto")
            .TrySetValue("FocusAuto_Continuous");
        break;
      case CameraLinuxPlatformFocusMode::
          CAMERA_LINUX_PLATFORM_FOCUS_MODE_LOCKED:
        Pylon::CEnumParameter(nodemap, "FocusAuto")
            .TrySetValue("FocusAuto_Off");
        break;
      default:
        Pylon::CEnumParameter(nodemap, "FocusAuto")
            .TrySetValue("FocusAuto_Continuous");
        break;
    }
    focus_mode = mode;
    emitState();
  });
}

void Camera::startVideoRecording(std::string filePath) {
  if (!camera || !Pylon::CVideoWriter::IsSupported() ||
      cameraVideoRecorderImageEventHandler) {
    std::cerr << "Video recording is not supported or camera is not "
                 "initialized. or already recording."
              << std::endl;
    return;
  }
  CAMERA_CONFIG_LOCK({
    cameraVideoRecorderImageEventHandler =
        std::make_unique<CameraVideoRecorderImageEventHandler>(filePath);
    camera->RegisterImageEventHandler(
        cameraVideoRecorderImageEventHandler.get(),
        Pylon::RegistrationMode_Append, Pylon::Cleanup_None);
  });
}

void Camera::stopVideoRecording(std::string& filePath) {
  if (!camera || !cameraVideoRecorderImageEventHandler) {
    return;
  }
  CAMERA_CONFIG_LOCK({
    filePath = cameraVideoRecorderImageEventHandler->m_videoFilePath;
    camera->DeregisterImageEventHandler(
        cameraVideoRecorderImageEventHandler.get());
    cameraVideoRecorderImageEventHandler.reset();
  });
}