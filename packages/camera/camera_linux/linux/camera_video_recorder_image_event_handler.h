
#ifndef CAMERA_VIDEO_RECORDER_IMAGE_EVENT_HANDLER_H_
#define CAMERA_VIDEO_RECORDER_IMAGE_EVENT_HANDLER_H_

#include "flutter_linux/flutter_linux.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverloaded-virtual"
#pragma clang diagnostic ignored "-Wunused-variable"

#include <pylon/PylonIncludes.h>

#pragma clang diagnostic pop

#define CAMERA_VIDEO_RECORDER_PLAY_BACK_FRAME_RATE 60.0
#define CAMERA_VIDEO_RECORDER_QUALITY 100

class CameraVideoRecorderImageEventHandler : public Pylon::CImageEventHandler {
  Pylon::CVideoWriter m_videoWriter;

 public:
  std::string m_videoFilePath;

  CameraVideoRecorderImageEventHandler(std::string videoFilePath);

  ~CameraVideoRecorderImageEventHandler() override;

  void OnImageGrabbed(Pylon::CInstantCamera& camera,
                      const Pylon::CGrabResultPtr& ptr) override;

  void OnImageEventHandlerDeregistered(Pylon::CInstantCamera& camera) override;
};

#endif  // CAMERA_VIDEO_RECORDER_IMAGE_EVENT_HANDLER_H_