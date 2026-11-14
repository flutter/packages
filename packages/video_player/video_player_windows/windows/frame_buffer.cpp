// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "frame_buffer.h"

#include <utility>

namespace video_player_windows {
namespace {
struct FrameLease {
  FlutterDesktopPixelBuffer buffer = {};
  std::shared_ptr<const VideoFrame> frame;
};
}  // namespace

FrameBuffer::FrameBuffer()
    : texture_(flutter::PixelBufferTexture(
          [this](size_t, size_t) { return Acquire(); })) {}

void FrameBuffer::Publish(std::shared_ptr<const VideoFrame> frame) {
  std::lock_guard<std::mutex> lock(mutex_);
  latest_ = std::move(frame);
}

const FlutterDesktopPixelBuffer* FrameBuffer::Acquire() {
  std::lock_guard<std::mutex> lock(mutex_);
  if (!latest_) {
    return nullptr;
  }

  auto* lease = new FrameLease();
  lease->frame = latest_;
  lease->buffer.buffer = lease->frame->rgba.data();
  lease->buffer.width = lease->frame->width;
  lease->buffer.height = lease->frame->height;

  lease->buffer.release_context = lease;
  lease->buffer.release_callback = [](void* context) {
    delete static_cast<FrameLease*>(context);
  };

  return &lease->buffer;
}

}  // namespace video_player_windows
