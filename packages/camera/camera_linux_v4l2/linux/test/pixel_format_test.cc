// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "pixel_format.h"

#include <gtest/gtest.h>
#include <linux/videodev2.h>

#include <cstdint>
#include <vector>

namespace camera_linux_v4l2 {
namespace test {
namespace {

TEST(PixelFormatTest, RankPrefersYuyvThenRgb24ThenBgr24) {
  EXPECT_EQ(PixelFormatRank(V4L2_PIX_FMT_YUYV), 0);
  EXPECT_EQ(PixelFormatRank(V4L2_PIX_FMT_RGB24), 1);
  EXPECT_EQ(PixelFormatRank(V4L2_PIX_FMT_BGR24), 2);
  EXPECT_EQ(PixelFormatRank(V4L2_PIX_FMT_MJPEG), -1);
  EXPECT_EQ(PixelFormatRank(V4L2_PIX_FMT_GREY), -1);
}

TEST(PixelFormatTest, BoundsRgbaBufferSizeByDimensionsAndArea) {
  size_t bytes = 0;
  EXPECT_TRUE(GetRgbaBufferSize(4096, 2160, &bytes));
  EXPECT_EQ(bytes, 4096u * 2160u * 4u);

  EXPECT_FALSE(GetRgbaBufferSize(4096, 2161, &bytes));
  EXPECT_FALSE(GetRgbaBufferSize(kMaxFrameDimension, 2048, &bytes));
  EXPECT_FALSE(GetRgbaBufferSize(kMaxFrameDimension + 1, 1, &bytes));
  EXPECT_FALSE(GetRgbaBufferSize(1, 1, nullptr));
}

TEST(PixelFormatTest, ConvertsYuyvToRgba) {
  // BT.601 limited range: Y=81, U=90, V=240 represents saturated red.
  const uint8_t src[4] = {81, 90, 235, 240};
  uint8_t dst[8] = {};

  ASSERT_TRUE(
      ConvertFrameToRgba(src, sizeof(src), V4L2_PIX_FMT_YUYV, 2, 1, 0, dst));
  EXPECT_NEAR(dst[0], 255, 3);
  EXPECT_NEAR(dst[1], 0, 3);
  EXPECT_NEAR(dst[2], 0, 3);
  EXPECT_EQ(dst[3], 255);

  EXPECT_EQ(dst[4], 255);
  EXPECT_GT(dst[4], dst[5]);
  EXPECT_GT(dst[4], dst[6]);
  EXPECT_EQ(dst[7], 255);
}

TEST(PixelFormatTest, ConvertsYuyvWithOddWidthAndStridePadding) {
  // Width 3, height 2, stride 12 (8 payload bytes + 4 padding bytes per row).
  const uint8_t row[12] = {
      16,  128, 235, 128,  // pixel 0 black, pixel 1 white
      235, 128, 0,   128,  // pixel 2 white, trailing dummy pixel
      0,   0,   0,   0,    // padding
  };
  std::vector<uint8_t> src;
  src.insert(src.end(), row, row + 12);
  src.insert(src.end(), row, row + 12);
  std::vector<uint8_t> dst(3 * 2 * 4, 0);

  ASSERT_TRUE(ConvertFrameToRgba(src.data(), src.size(), V4L2_PIX_FMT_YUYV, 3,
                                 2, 12, dst.data()));
  // Row 0 pixel 0: black, pixel 1: white, pixel 2: white.
  EXPECT_EQ(dst[0], 0);
  EXPECT_EQ(dst[1], 0);
  EXPECT_EQ(dst[2], 0);
  EXPECT_EQ(dst[3], 255);
  EXPECT_EQ(dst[4], 255);
  EXPECT_EQ(dst[8], 255);
  // Row 1 pixel 0: black.
  EXPECT_EQ(dst[12], 0);
  EXPECT_EQ(dst[15], 255);
}

TEST(PixelFormatTest, ConvertsRgb24AndBgr24WithStride) {
  const uint8_t src[14] = {
      10, 20, 30, 40, 50, 60, 0,  // row 0 + 1 pad byte
      70, 80, 90, 1,  2,  3,  0,  // row 1 + 1 pad byte
  };
  uint8_t rgba[16] = {};

  ASSERT_TRUE(
      ConvertFrameToRgba(src, sizeof(src), V4L2_PIX_FMT_RGB24, 2, 2, 7, rgba));
  EXPECT_EQ(rgba[0], 10);
  EXPECT_EQ(rgba[1], 20);
  EXPECT_EQ(rgba[2], 30);
  EXPECT_EQ(rgba[3], 255);
  EXPECT_EQ(rgba[8], 70);
  EXPECT_EQ(rgba[12], 1);

  ASSERT_TRUE(
      ConvertFrameToRgba(src, sizeof(src), V4L2_PIX_FMT_BGR24, 2, 2, 7, rgba));
  EXPECT_EQ(rgba[0], 30);
  EXPECT_EQ(rgba[1], 20);
  EXPECT_EQ(rgba[2], 10);
  EXPECT_EQ(rgba[3], 255);
  EXPECT_EQ(rgba[12], 3);
  EXPECT_EQ(rgba[14], 1);
}

TEST(PixelFormatTest, RejectsInvalidInputs) {
  uint8_t src[16] = {};
  uint8_t dst[64] = {};

  EXPECT_FALSE(
      ConvertFrameToRgba(nullptr, 16, V4L2_PIX_FMT_YUYV, 2, 2, 0, dst));
  EXPECT_FALSE(
      ConvertFrameToRgba(src, 16, V4L2_PIX_FMT_YUYV, 2, 2, 0, nullptr));
  EXPECT_FALSE(ConvertFrameToRgba(src, 16, V4L2_PIX_FMT_YUYV, 0, 2, 0, dst));
  EXPECT_FALSE(ConvertFrameToRgba(src, 16, V4L2_PIX_FMT_YUYV,
                                  kMaxFrameDimension + 1, 1, 0, dst));
  EXPECT_FALSE(
      ConvertFrameToRgba(src, 16, V4L2_PIX_FMT_YUYV, 4096, 2161, 0, dst));
  EXPECT_FALSE(ConvertFrameToRgba(src, 3, V4L2_PIX_FMT_YUYV, 2, 1, 0, dst));
  EXPECT_FALSE(ConvertFrameToRgba(src, 16, V4L2_PIX_FMT_MJPEG, 2, 2, 0, dst));
}

TEST(PixelFormatTest, ConvertsRgbaToBgra) {
  const uint8_t rgba[8] = {10, 20, 30, 255, 1, 2, 3, 128};
  uint8_t bgra[8] = {};
  ConvertRgbaToBgra(rgba, bgra, 2);

  EXPECT_EQ(bgra[0], 30);
  EXPECT_EQ(bgra[1], 20);
  EXPECT_EQ(bgra[2], 10);
  EXPECT_EQ(bgra[3], 255);
  EXPECT_EQ(bgra[4], 3);
  EXPECT_EQ(bgra[5], 2);
  EXPECT_EQ(bgra[6], 1);
  EXPECT_EQ(bgra[7], 128);
}

}  // namespace
}  // namespace test
}  // namespace camera_linux_v4l2
