
#ifndef CAMERA_H_
#define CAMERA_H_

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

  Camera(Pylon::IPylonDevice* device, int64_t camera_id,
         FlPluginRegistrar* registrar,
         CameraLinuxPlatformResolutionPreset resolution_preset);

  Camera(Camera&&) = default;
  Camera& operator=(Camera&&) = default;

  ~Camera();

  void initialize(CameraLinuxPlatformImageFormatGroup image_format);
  int64_t getTextureId();

  // State
 public:
  CameraLinuxPlatformExposureMode exposure_mode;
  CameraLinuxPlatformFocusMode focus_mode;
  int width;
  int height;

  void emitState();

  Camera& setResolutionPreset(CameraLinuxPlatformResolutionPreset preset);

 private:
  CameraLinuxPlatformResolutionPreset resolution_preset;
  FlPluginRegistrar* registrar;
};

#endif  // CAMERA_H_
