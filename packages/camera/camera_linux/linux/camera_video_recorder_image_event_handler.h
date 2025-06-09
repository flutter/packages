
#ifndef CAMERA_VIDEO_RECORDER_IMAGE_EVENT_HANDLER_H_
#define CAMERA_VIDEO_RECORDER_IMAGE_EVENT_HANDLER_H_

#include <GL/gl.h>

#include "camera.h"
#include "flutter_linux/flutter_linux.h"
#include "messages.g.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverloaded-virtual"
#pragma clang diagnostic ignored "-Wunused-variable"

#include <pylon/PylonIncludes.h>

#pragma clang diagnostic pop

class CameraVideoRecorderImageEventHandler : public Pylon::CImageEventHandler {
  const Camera& camera;

 public:
  CameraVideoRecorderImageEventHandler(const Camera& camera);

  ~CameraVideoRecorderImageEventHandler() override;

  void OnImageEventHandlerRegistered(Pylon::CInstantCamera& camera) override;

  void OnImageGrabbed(Pylon::CInstantCamera& camera,
                      const Pylon::CGrabResultPtr& ptr) override;

  void OnImageEventHandlerDeregistered(Pylon::CInstantCamera& camera) override;
};

#endif  // CAMERA_VIDEO_RECORDER_IMAGE_EVENT_HANDLER_H_