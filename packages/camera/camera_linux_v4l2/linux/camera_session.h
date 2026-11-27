// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_LINUX_V4L2_LINUX_CAMERA_SESSION_H_
#define PACKAGES_CAMERA_CAMERA_LINUX_V4L2_LINUX_CAMERA_SESSION_H_

#include <glib.h>

#include <atomic>
#include <cstdint>
#include <functional>
#include <string>
#include <vector>

#include "pixel_format.h"
#include "v4l2_system.h"

namespace camera_linux_v4l2 {

// Returns the video devices that support streaming video capture in a pixel
// format understood by PixelFormatRank().
std::vector<std::string> EnumerateVideoDevices(V4l2System* system);

// Owns one open V4L2 device, its memory-mapped capture buffers, and a
// background capture thread that converts incoming frames to RGBA8888.
class CameraSession {
 public:
  // Called on the capture thread with each converted frame. `rgba_buffer`
  // holds `width * height * 4` bytes; the callee may take the pixels by
  // swapping `rgba_buffer` with a buffer of its own.
  using FrameCallback = std::function<void(CameraPixelBuffer* rgba_buffer,
                                           uint32_t width, uint32_t height)>;
  // Called on the capture thread when capture fails and the thread exits.
  using ErrorCallback = std::function<void(const std::string& message)>;

  CameraSession(V4l2System* system, std::string device_path,
                uint32_t requested_width, uint32_t requested_height);
  ~CameraSession();

  CameraSession(const CameraSession&) = delete;
  CameraSession& operator=(const CameraSession&) = delete;

  // Opens the device, negotiates the pixel format and frame size, maps
  // capture buffers, and starts the capture thread. On failure sets
  // `error_code` and `error_message` and leaves no open resources.
  bool Start(FrameCallback on_frame, ErrorCallback on_error,
             std::string* error_code, std::string* error_message);

  // Stops and joins the capture thread, then releases the device. Safe to
  // call multiple times.
  void Stop();

  // The negotiated frame size. Valid after a successful Start().
  uint32_t width() const { return width_; }
  uint32_t height() const { return height_; }

 private:
  struct MappedBuffer {
    void* start = nullptr;
    size_t length = 0;
  };

  static gpointer ThreadEntry(gpointer data);
  void RunCaptureLoop();
  void ReportError(const std::string& message);
  bool OpenAndNegotiate(std::string* error_code, std::string* error_message);
  bool SetupMmapAndStream(std::string* error_message);
  void CleanupResources();

  V4l2System* system_;
  std::string device_path_;
  uint32_t requested_width_;
  uint32_t requested_height_;

  int fd_ = -1;
  // An eventfd that Stop() signals to wake the capture thread out of poll().
  int wakeup_fd_ = -1;
  uint32_t fourcc_ = 0;
  uint32_t width_ = 0;
  uint32_t height_ = 0;
  uint32_t bytes_per_line_ = 0;
  size_t rgba_bytes_ = 0;
  bool streaming_ = false;

  std::vector<MappedBuffer> buffers_;
  CameraPixelBuffer work_rgba_;

  FrameCallback on_frame_;
  ErrorCallback on_error_;
  std::atomic<bool> stop_{false};
  GThread* thread_ = nullptr;
};

}  // namespace camera_linux_v4l2

#endif  // PACKAGES_CAMERA_CAMERA_LINUX_V4L2_LINUX_CAMERA_SESSION_H_
