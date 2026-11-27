// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_VIDEO_PLAYER_WINDOWS_FRAME_BUFFER_H_
#define PACKAGES_VIDEO_PLAYER_WINDOWS_FRAME_BUFFER_H_

#include <flutter/texture_registrar.h>

#include <cstddef>
#include <cstdint>
#include <memory>
#include <mutex>
#include <vector>

namespace video_player_windows {

struct VideoFrame {
  size_t width = 0;
  size_t height = 0;
  std::vector<uint8_t> rgba;
};

// Must outlive texture registration. Acquired frames remain valid until Flutter
// invokes their release callbacks, even if a newer frame replaces them.
class FrameBuffer {
 public:
  FrameBuffer();
  void Publish(std::shared_ptr<const VideoFrame> frame);
  flutter::TextureVariant* texture() { return &texture_; }

 private:
  const FlutterDesktopPixelBuffer* Acquire();
  std::mutex mutex_;
  std::shared_ptr<const VideoFrame> latest_;
  flutter::TextureVariant texture_;
};

}  // namespace video_player_windows

#endif
