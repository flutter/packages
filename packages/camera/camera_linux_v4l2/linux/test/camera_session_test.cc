// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "camera_session.h"

#include <errno.h>
#include <gtest/gtest.h>
#include <linux/videodev2.h>

#include <chrono>
#include <condition_variable>
#include <cstdint>
#include <mutex>
#include <string>
#include <vector>

#include "fake_v4l2_system.h"
#include "pixel_format.h"

namespace camera_linux_v4l2 {
namespace test {
namespace {

TEST(CameraSessionTest, EnumeratesOnlyStreamingCaptureDevicesInOrder) {
  FakeV4l2System v4l2;
  v4l2.AddDevice("/dev/video0");  // valid YUYV capture

  FakeV4l2Device* metadata = v4l2.AddDevice("/dev/video1");
  // Capabilities include VIDEO_CAPTURE, but device_caps marks this node as
  // metadata-only (common on UVC webcams).
  metadata->capabilities =
      V4L2_CAP_VIDEO_CAPTURE | V4L2_CAP_META_CAPTURE | V4L2_CAP_DEVICE_CAPS;
  metadata->device_caps = V4L2_CAP_META_CAPTURE | V4L2_CAP_STREAMING;

  FakeV4l2Device* mjpeg_only = v4l2.AddDevice("/dev/video2");
  mjpeg_only->formats = {V4L2_PIX_FMT_MJPEG};

  FakeV4l2Device* non_v4l2 = v4l2.AddDevice("/dev/video3");
  non_v4l2->fail_querycap = true;

  FakeV4l2Device* endless = v4l2.AddDevice("/dev/video4");
  endless->endless_formats = true;

  FakeV4l2Device* bgr = v4l2.AddDevice("/dev/video10");
  bgr->formats = {V4L2_PIX_FMT_BGR24};

  EXPECT_EQ(EnumerateVideoDevices(&v4l2),
            (std::vector<std::string>{"/dev/video0", "/dev/video10"}));
  EXPECT_EQ(endless->enum_fmt_count, 64);
}

TEST(CameraSessionTest, StreamsSyntheticYuyvFrameAndStopsCleanly) {
  FakeV4l2System v4l2;
  FakeV4l2Device* dev = v4l2.AddDevice("/dev/video0");
  dev->negotiated_width = 4;
  dev->negotiated_height = 2;

  CameraSession session(&v4l2, "/dev/video0", 640, 480);

  std::mutex cb_mutex;
  std::condition_variable cb_cv;
  std::vector<uint8_t> received_rgba;
  uint32_t received_w = 0;
  uint32_t received_h = 0;
  bool got_frame = false;

  std::string err_code;
  std::string err_msg;
  ASSERT_TRUE(session.Start(
      [&](CameraPixelBuffer* rgba_buffer, uint32_t w, uint32_t h) {
        std::lock_guard<std::mutex> lock(cb_mutex);
        const size_t bytes = static_cast<size_t>(w) * h * 4;
        received_rgba.assign(rgba_buffer->data, rgba_buffer->data + bytes);
        received_w = w;
        received_h = h;
        got_frame = true;
        cb_cv.notify_all();
      },
      [](const std::string&) {}, &err_code, &err_msg))
      << err_msg;

  EXPECT_EQ(session.width(), 4u);
  EXPECT_EQ(session.height(), 2u);

  // Push a 4x2 YUYV frame alternating black (Y=16) and white (Y=235).
  std::vector<uint8_t> yuyv = {
      16,  128, 235, 128, 16,  128, 235, 128,  // row 0: B, W, B, W
      235, 128, 16,  128, 235, 128, 16,  128,  // row 1: W, B, W, B
  };
  dev->PushFrame(yuyv);

  {
    std::unique_lock<std::mutex> lock(cb_mutex);
    ASSERT_TRUE(cb_cv.wait_for(lock, std::chrono::seconds(2),
                               [&] { return got_frame; }));
  }

  EXPECT_EQ(received_w, 4u);
  EXPECT_EQ(received_h, 2u);
  ASSERT_EQ(received_rgba.size(), 32u);
  EXPECT_EQ(received_rgba[0], 0);     // row 0, col 0 black
  EXPECT_EQ(received_rgba[4], 255);   // row 0, col 1 white
  EXPECT_EQ(received_rgba[16], 255);  // row 1, col 0 white
  EXPECT_EQ(received_rgba[20], 0);    // row 1, col 1 black

  session.Stop();
  session.Stop();  // Idempotent.

  EXPECT_EQ(dev->open_count, 1);
  EXPECT_EQ(dev->close_count, 1);
  EXPECT_EQ(dev->mmap_count, 4);
  EXPECT_EQ(dev->munmap_count, 4);
}

TEST(CameraSessionTest, ReportsCameraAccessDeniedOnPermissionError) {
  FakeV4l2System v4l2;
  FakeV4l2Device* dev = v4l2.AddDevice("/dev/video0");
  dev->open_errno = EACCES;

  CameraSession session(&v4l2, "/dev/video0", 640, 480);
  std::string err_code;
  std::string err_msg;
  EXPECT_FALSE(session.Start(nullptr, nullptr, &err_code, &err_msg));
  EXPECT_EQ(err_code, "CameraAccessDenied");
  EXPECT_FALSE(err_msg.empty());
  EXPECT_EQ(dev->close_count, 0);
}

TEST(CameraSessionTest, CleansUpDescriptorsAndMmapsOnNegotiationErrors) {
  FakeV4l2System v4l2;

  FakeV4l2Device* bad_fmt = v4l2.AddDevice("/dev/video0");
  bad_fmt->fail_s_fmt = true;
  {
    CameraSession session(&v4l2, "/dev/video0", 640, 480);
    std::string err_code;
    std::string err_msg;
    EXPECT_FALSE(session.Start(nullptr, nullptr, &err_code, &err_msg));
    EXPECT_EQ(err_code, "camera_error");
    EXPECT_EQ(bad_fmt->open_count, 1);
    EXPECT_EQ(bad_fmt->close_count, 1);
  }

  FakeV4l2Device* bad_dim = v4l2.AddDevice("/dev/video1");
  bad_dim->negotiated_width = kMaxFrameDimension + 1;
  bad_dim->negotiated_height = 480;
  {
    CameraSession session(&v4l2, "/dev/video1", 640, 480);
    std::string err_code;
    std::string err_msg;
    EXPECT_FALSE(session.Start(nullptr, nullptr, &err_code, &err_msg));
    EXPECT_EQ(bad_dim->close_count, 1);
  }

  FakeV4l2Device* excessive_area = v4l2.AddDevice("/dev/video4");
  excessive_area->negotiated_width = 4096;
  excessive_area->negotiated_height = 2161;
  {
    CameraSession session(&v4l2, "/dev/video4", 640, 480);
    std::string err_code;
    std::string err_msg;
    EXPECT_FALSE(session.Start(nullptr, nullptr, &err_code, &err_msg));
    EXPECT_EQ(excessive_area->close_count, 1);
  }

  FakeV4l2Device* too_few_bufs = v4l2.AddDevice("/dev/video2");
  too_few_bufs->granted_buffers = 1;
  {
    CameraSession session(&v4l2, "/dev/video2", 640, 480);
    std::string err_code;
    std::string err_msg;
    EXPECT_FALSE(session.Start(nullptr, nullptr, &err_code, &err_msg));
    EXPECT_EQ(too_few_bufs->close_count, 1);
  }

  FakeV4l2Device* bad_mmap = v4l2.AddDevice("/dev/video3");
  bad_mmap->fail_mmap = true;
  {
    CameraSession session(&v4l2, "/dev/video3", 640, 480);
    std::string err_code;
    std::string err_msg;
    EXPECT_FALSE(session.Start(nullptr, nullptr, &err_code, &err_msg));
    EXPECT_EQ(bad_mmap->close_count, 1);
    EXPECT_EQ(bad_mmap->mmap_count, bad_mmap->munmap_count);
  }
}

TEST(CameraSessionTest, EmitsErrorCallbackWhenEveryFrameIsCorrupt) {
  FakeV4l2System v4l2;
  FakeV4l2Device* dev = v4l2.AddDevice("/dev/video0");
  dev->negotiated_width = 2;
  dev->negotiated_height = 1;
  dev->flag_frames_as_corrupt = true;

  CameraSession session(&v4l2, "/dev/video0", 640, 480);
  std::mutex mutex;
  std::condition_variable cv;
  int frames = 0;
  std::string reported_error;
  std::string err_code;
  std::string err_msg;

  ASSERT_TRUE(session.Start(
      [&](CameraPixelBuffer*, uint32_t, uint32_t) {
        std::lock_guard<std::mutex> lock(mutex);
        ++frames;
      },
      [&](const std::string& message) {
        std::lock_guard<std::mutex> lock(mutex);
        reported_error = message;
        cv.notify_all();
      },
      &err_code, &err_msg))
      << err_msg;

  for (int i = 0; i < 30; ++i) {
    dev->PushFrame({16, 128, 16, 128});
  }

  std::unique_lock<std::mutex> lock(mutex);
  ASSERT_TRUE(cv.wait_for(lock, std::chrono::seconds(5),
                          [&] { return !reported_error.empty(); }));
  EXPECT_NE(reported_error.find("corrupt"), std::string::npos);
  EXPECT_EQ(frames, 0);
}

TEST(CameraSessionTest, EmitsErrorCallbackOnDisconnect) {
  FakeV4l2System v4l2;
  FakeV4l2Device* dev = v4l2.AddDevice("/dev/video0");
  dev->negotiated_width = 2;
  dev->negotiated_height = 2;

  CameraSession session(&v4l2, "/dev/video0", 640, 480);
  std::mutex err_mutex;
  std::condition_variable err_cv;
  std::string reported_error;
  std::string err_code;
  std::string err_msg;

  ASSERT_TRUE(session.Start([](CameraPixelBuffer*, uint32_t, uint32_t) {},
                            [&](const std::string& message) {
                              std::lock_guard<std::mutex> lock(err_mutex);
                              reported_error = message;
                              err_cv.notify_all();
                            },
                            &err_code, &err_msg))
      << err_msg;

  dev->Disconnect();

  {
    std::unique_lock<std::mutex> lock(err_mutex);
    ASSERT_TRUE(err_cv.wait_for(lock, std::chrono::seconds(2),
                                [&] { return !reported_error.empty(); }));
  }
  EXPECT_NE(reported_error.find("/dev/video0"), std::string::npos);

  session.Stop();
  EXPECT_EQ(dev->close_count, 1);
  EXPECT_EQ(dev->munmap_count, 4);
}

}  // namespace
}  // namespace test
}  // namespace camera_linux_v4l2
