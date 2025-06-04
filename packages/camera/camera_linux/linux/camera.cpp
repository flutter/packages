#include "camera.h"

#include "camera_texture_image_event_handler.h"

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
      width(1920),
      height(1080),
      resolution_preset(resolution_preset),
      registrar(registrar) {
  camera = std::make_unique<Pylon::CInstantCamera>(device);
  setResolutionPreset(resolution_preset);
  if (registrar) g_object_ref(registrar);
}

Camera::~Camera() {
  if (camera) camera->Close();
  if (cameraLinuxCameraEventApi) g_object_unref(cameraLinuxCameraEventApi);
  if (registrar) g_object_unref(registrar);
}

void Camera::initialize(CameraLinuxPlatformImageFormatGroup image_format) {
  cameraTextureImageEventHandler =
      std::make_unique<CameraTextureImageEventHandler>(*this, registrar);
  camera->Open();
  GenApi::INodeMap& nodemap = camera->GetNodeMap();
  Pylon::CEnumParameter(nodemap, "DeviceLinkThroughputLimitMode")
      .TrySetValue("Off");
  Pylon::CBooleanParameter(nodemap, "AcquisitionFrameRateEnable")
      .TrySetValue(true);
  Pylon::CFloatParameter(nodemap, "AcquisitionFrameRate").TrySetValue(60.0);
  Pylon::CFloatParameter(nodemap, "ResultingFrameRate").TrySetValue(60.0);
  Pylon::CEnumParameter(nodemap, "PixelFormat").TrySetValue("RGB8");
  Pylon::CEnumParameter(nodemap, "TriggerMode").SetValue("Off");
  Pylon::CIntegerParameter(nodemap, "Width").TrySetValue(width);
  Pylon::CIntegerParameter(nodemap, "Height").TrySetValue(height);
  Pylon::CIntegerParameter(nodemap, "OffsetX").TrySetValue(0);
  Pylon::CIntegerParameter(nodemap, "OffsetY").TrySetValue(0);

  camera->RegisterImageEventHandler(cameraTextureImageEventHandler.get(),
                                    Pylon::RegistrationMode_Append,
                                    Pylon::Cleanup_Delete);
  camera->StartGrabbing(Pylon::GrabStrategy_LatestImages,
                        Pylon::EGrabLoop::GrabLoop_ProvidedByInstantCamera);

  emitState();
}

int64_t Camera::getTextureId() {
  if (!cameraTextureImageEventHandler) return -1;
  return cameraTextureImageEventHandler->get_texture_id();
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
