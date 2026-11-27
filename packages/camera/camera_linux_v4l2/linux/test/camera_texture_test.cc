// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "camera_texture.h"

#include <gtest/gtest.h>

#include <cstdint>

#include "pixel_format.h"

namespace camera_linux_v4l2 {
namespace test {
namespace {

TEST(CameraTextureTest, ReturnsPlaceholderPixelBeforeFirstFrame) {
  g_autoptr(FlCameraTexture) texture = fl_camera_texture_new();
  FlPixelBufferTextureClass* klass = FL_PIXEL_BUFFER_TEXTURE_GET_CLASS(texture);

  const uint8_t* buffer = nullptr;
  uint32_t width = 0;
  uint32_t height = 0;
  g_autoptr(GError) error = nullptr;

  ASSERT_TRUE(klass->copy_pixels(FL_PIXEL_BUFFER_TEXTURE(texture), &buffer,
                                 &width, &height, &error));
  EXPECT_EQ(error, nullptr);
  ASSERT_NE(buffer, nullptr);
  EXPECT_EQ(width, 1u);
  EXPECT_EQ(height, 1u);
  EXPECT_EQ(buffer[0], 0);
  EXPECT_EQ(buffer[1], 0);
  EXPECT_EQ(buffer[2], 0);
  EXPECT_EQ(buffer[3], 255);
}

TEST(CameraTextureTest, RejectsInvalidFrameUpdates) {
  g_autoptr(FlCameraTexture) texture = fl_camera_texture_new();
  CameraPixelBuffer empty;
  EXPECT_FALSE(fl_camera_texture_update_frame(texture, nullptr, 2, 2));
  EXPECT_FALSE(fl_camera_texture_update_frame(texture, &empty, 2, 2));

  CameraPixelBuffer small;
  ASSERT_TRUE(CameraPixelBufferEnsure(&small, 4));
  EXPECT_FALSE(fl_camera_texture_update_frame(texture, &small, 0, 2));
  EXPECT_FALSE(fl_camera_texture_update_frame(texture, &small,
                                              kMaxFrameDimension + 1, 1));
  EXPECT_FALSE(fl_camera_texture_update_frame(texture, &small, 2, 2));
  CameraPixelBufferFree(&small);
}

TEST(CameraTextureTest, SwapsBuffersWithoutMutatingFrontBuffer) {
  g_autoptr(FlCameraTexture) texture = fl_camera_texture_new();
  FlPixelBufferTextureClass* klass = FL_PIXEL_BUFFER_TEXTURE_GET_CLASS(texture);

  CameraPixelBuffer work;
  ASSERT_TRUE(CameraPixelBufferEnsure(&work, 2 * 2 * 4));
  for (size_t i = 0; i < 16; ++i) {
    work.data[i] = static_cast<uint8_t>(10 + i);
  }
  ASSERT_TRUE(fl_camera_texture_update_frame(texture, &work, 2, 2));

  const uint8_t* front1 = nullptr;
  uint32_t w = 0;
  uint32_t h = 0;
  g_autoptr(GError) error = nullptr;
  ASSERT_TRUE(klass->copy_pixels(FL_PIXEL_BUFFER_TEXTURE(texture), &front1, &w,
                                 &h, &error));
  EXPECT_EQ(w, 2u);
  EXPECT_EQ(h, 2u);
  EXPECT_EQ(front1[0], 10);
  EXPECT_EQ(front1[15], 25);

  // Publish a second frame into staging and verify front1 stays intact until
  // the next copy_pixels call.
  ASSERT_TRUE(CameraPixelBufferEnsure(&work, 2 * 2 * 4));
  for (size_t i = 0; i < 16; ++i) {
    work.data[i] = static_cast<uint8_t>(200 + i);
  }
  ASSERT_TRUE(fl_camera_texture_update_frame(texture, &work, 2, 2));
  EXPECT_EQ(front1[0], 10);

  const uint8_t* front2 = nullptr;
  ASSERT_TRUE(klass->copy_pixels(FL_PIXEL_BUFFER_TEXTURE(texture), &front2, &w,
                                 &h, &error));
  EXPECT_EQ(front2[0], 200);
  EXPECT_EQ(front2[15], 215);

  CameraPixelBufferFree(&work);
}

}  // namespace
}  // namespace test
}  // namespace camera_linux_v4l2
