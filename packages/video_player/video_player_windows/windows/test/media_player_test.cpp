// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "media_player.h"

#include <gtest/gtest.h>

#include <limits>
#include <memory>

#include "frame_buffer.h"

namespace video_player_windows {

TEST(MediaPlayer, PreservesUnicodeSources) {
  EXPECT_EQ(Utf16FromUtf8("C:/\xd9\x81\xdb\x8c\xd9\x84\xd9\x85/test.mp4"),
            L"C:/\u0641\u06cc\u0644\u0645/test.mp4");
  EXPECT_TRUE(Utf16FromUtf8("\xff").empty());
}

TEST(MediaPlayer, ConvertsFiniteTimesWithoutOverflow) {
  EXPECT_EQ(SecondsToMilliseconds(1.125), 1125);
  EXPECT_EQ(SecondsToMilliseconds(-1), 0);
  EXPECT_EQ(SecondsToMilliseconds(std::numeric_limits<double>::quiet_NaN()), 0);
  EXPECT_EQ(SecondsToMilliseconds(std::numeric_limits<double>::infinity()), 0);
  EXPECT_EQ(SecondsToMilliseconds(1e20), std::numeric_limits<int64_t>::max());
}

TEST(FrameBuffer, KeepsAcquiredFrameAliveAcrossReplacementAndDisposal) {
  auto frames = std::make_unique<FrameBuffer>();
  auto first = std::make_shared<VideoFrame>();
  first->width = 1;
  first->height = 1;
  first->rgba = {10, 20, 30, 255};
  std::weak_ptr<VideoFrame> first_reference = first;
  frames->Publish(first);
  first.reset();

  const auto* acquired =
      std::get<flutter::PixelBufferTexture>(*frames->texture())
          .CopyPixelBuffer(1, 1);
  ASSERT_NE(acquired, nullptr);

  auto second = std::make_shared<VideoFrame>();
  second->width = 1;
  second->height = 1;
  second->rgba = {40, 50, 60, 255};
  frames->Publish(second);
  frames.reset();

  EXPECT_FALSE(first_reference.expired());
  EXPECT_EQ(acquired->buffer[0], 10);
  EXPECT_EQ(acquired->width, 1u);

  acquired->release_callback(acquired->release_context);
  EXPECT_TRUE(first_reference.expired());
}

TEST(FrameBuffer, ReturnsNoFrameUntilPublished) {
  FrameBuffer frames;
  EXPECT_EQ(std::get<flutter::PixelBufferTexture>(*frames.texture())
                .CopyPixelBuffer(1, 1),
            nullptr);
}

}  // namespace video_player_windows
