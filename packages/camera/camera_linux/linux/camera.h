
#ifndef CAMERA_H_
#define CAMERA_H_

#include <functional>

#include "camera_video_recorder_image_event_handler.h"
#include "flutter_linux/flutter_linux.h"
#include "messages.g.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverloaded-virtual"
#pragma clang diagnostic ignored "-Wunused-variable"

#include <pylon/PylonIncludes.h>

#pragma clang diagnostic pop

class Camera {
  // Camera
 public:
  int64_t camera_id;
  std::unique_ptr<Pylon::CInstantCamera> camera;
  std::unique_ptr<class CameraTextureImageEventHandler>
      cameraTextureImageEventHandler;
  CameraLinuxCameraEventApi* cameraLinuxCameraEventApi;
  std::unique_ptr<CameraVideoRecorderImageEventHandler>
      cameraVideoRecorderImageEventHandler;

  Camera(Pylon::IPylonDevice* device, int64_t camera_id,
         FlPluginRegistrar* registrar,
         CameraLinuxPlatformResolutionPreset resolution_preset);

  Camera(Camera&&) = default;
  Camera& operator=(Camera&&) = default;

  ~Camera();

  void initialize(CameraLinuxPlatformImageFormatGroup imageFormat);

  int64_t getTextureId();

  void takePicture(std::string filePath);
  void startVideoRecording(std::string filePath);
  void stopVideoRecording(std::string& filePath);

  void setImageFormatGroup(
      CameraLinuxPlatformImageFormatGroup imageFormatGroup);
  void setExposureMode(CameraLinuxPlatformExposureMode mode);
  void setFocusMode(CameraLinuxPlatformFocusMode mode);

  // State
 public:
  CameraLinuxPlatformExposureMode exposure_mode;
  CameraLinuxPlatformFocusMode focus_mode;
  int width;
  int height;
  CameraLinuxPlatformImageFormatGroup imageFormatGroup;

  void emitState();
  void emitTextureId(int64_t textureId) const;

  Camera& setResolutionPreset(CameraLinuxPlatformResolutionPreset preset);

 private:
  CameraLinuxPlatformResolutionPreset resolution_preset;
  FlPluginRegistrar* registrar;
};

#define CAMERA_CONFIG_LOCK(code)                                              \
  do {                                                                        \
    bool wasGrabbing = camera->IsGrabbing();                                  \
    if (!camera) {                                                            \
      std::cerr << "Camera is not initialized." << std::endl;                 \
      return;                                                                 \
    }                                                                         \
    if (wasGrabbing) {                                                        \
      camera->StopGrabbing();                                                 \
      camera->DeregisterImageEventHandler(                                    \
          cameraTextureImageEventHandler.get());                              \
      cameraTextureImageEventHandler.reset();                                 \
    }                                                                         \
    {code};                                                                   \
    if (wasGrabbing) {                                                        \
      cameraTextureImageEventHandler =                                        \
          std::make_unique<CameraTextureImageEventHandler>(*this, registrar); \
      camera->RegisterImageEventHandler(cameraTextureImageEventHandler.get(), \
                                        Pylon::RegistrationMode_Append,       \
                                        Pylon::Cleanup_None);                 \
      camera->StartGrabbing(                                                  \
          Pylon::GrabStrategy_LatestImages,                                   \
          Pylon::EGrabLoop::GrabLoop_ProvidedByInstantCamera);                \
    }                                                                         \
  } while (0)

#endif  // CAMERA_H_
