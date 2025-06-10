#include "camera_video_recorder_image_event_handler.h"

CameraVideoRecorderImageEventHandler::CameraVideoRecorderImageEventHandler(
    std::string videoFilePath)
    : m_videoFilePath(std::move(videoFilePath)) {}

void CameraVideoRecorderImageEventHandler::OnImageGrabbed(
    Pylon::CInstantCamera& camera, const Pylon::CGrabResultPtr& ptr) {
  if (!ptr->GrabSucceeded()) {
    std::cerr << "Error: Grab failed or texture not ready." << std::endl;
    return;
  }

  static bool isFirstFrame = true;
  if (isFirstFrame) {
    m_videoWriter.SetParameter(ptr->GetWidth(), ptr->GetHeight(),
                               ptr->GetPixelType(),
                               CAMERA_VIDEO_RECORDER_PLAY_BACK_FRAME_RATE,
                               CAMERA_VIDEO_RECORDER_QUALITY);
    m_videoWriter.Open(m_videoFilePath.c_str());
    isFirstFrame = false;
  }

  Pylon::CPylonImage image;
  image.AttachGrabResultBuffer(ptr);
  m_videoWriter.Add(image);
}

void CameraVideoRecorderImageEventHandler::OnImageEventHandlerDeregistered(
    Pylon::CInstantCamera& camera) {
  if (m_videoWriter.IsOpen()) {
    m_videoWriter.Close();
  }
}

CameraVideoRecorderImageEventHandler::~CameraVideoRecorderImageEventHandler() {
  if (m_videoWriter.IsOpen()) {
    m_videoWriter.Close();
  }
}
