// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "pixel_format.h"

#include <glib.h>
#include <linux/videodev2.h>

#include <algorithm>
#include <cstring>
#include <limits>

namespace camera_linux_v4l2 {
namespace {

inline uint8_t ClampUint8(int value) {
  return static_cast<uint8_t>(value < 0 ? 0 : (value > 255 ? 255 : value));
}

// ITU-R BT.601 limited range (Y 16..235, Cb/Cr 16..240), standard for UVC.
inline void YuvToRgba(int y, int u, int v, uint8_t* rgba) {
  const int c = 298 * (y - 16) + 128;
  const int d = u - 128;
  const int e = v - 128;
  rgba[0] = ClampUint8((c + 409 * e) >> 8);
  rgba[1] = ClampUint8((c - 100 * d - 208 * e) >> 8);
  rgba[2] = ClampUint8((c + 516 * d) >> 8);
  rgba[3] = 255;
}

bool ConvertYuyvToRgba(const uint8_t* src, size_t src_len, size_t width,
                       size_t height, uint32_t bytes_per_line, uint8_t* dst) {
  const size_t min_stride = ((width + 1) / 2) * 4;
  const size_t stride = std::max<size_t>(bytes_per_line, min_stride);
  const uint64_t required =
      static_cast<uint64_t>(stride) * (height - 1) + min_stride;
  if (static_cast<uint64_t>(src_len) < required) {
    return false;
  }

  for (size_t row = 0; row < height; ++row) {
    const uint8_t* s = src + row * stride;
    uint8_t* d = dst + row * width * 4;
    for (size_t x = 0; x < width; x += 2) {
      const int u = s[1];
      const int v = s[3];
      YuvToRgba(s[0], u, v, d);
      if (x + 1 < width) {
        YuvToRgba(s[2], u, v, d + 4);
      }
      s += 4;
      d += 8;
    }
  }
  return true;
}

bool ConvertRgbOrBgrToRgba(const uint8_t* src, size_t src_len, size_t width,
                           size_t height, uint32_t bytes_per_line, bool is_bgr,
                           uint8_t* dst) {
  const size_t min_stride = width * 3;
  const size_t stride = std::max<size_t>(bytes_per_line, min_stride);
  const uint64_t required =
      static_cast<uint64_t>(stride) * (height - 1) + min_stride;
  if (static_cast<uint64_t>(src_len) < required) {
    return false;
  }

  const size_t r_idx = is_bgr ? 2 : 0;
  const size_t b_idx = is_bgr ? 0 : 2;
  for (size_t row = 0; row < height; ++row) {
    const uint8_t* s = src + row * stride;
    uint8_t* d = dst + row * width * 4;
    for (size_t x = 0; x < width; ++x) {
      d[0] = s[r_idx];
      d[1] = s[1];
      d[2] = s[b_idx];
      d[3] = 255;
      s += 3;
      d += 4;
    }
  }
  return true;
}

}  // namespace

bool CameraPixelBufferEnsure(CameraPixelBuffer* buffer, size_t required_bytes) {
  if (buffer == nullptr) {
    return false;
  }
  if (required_bytes == 0) {
    return true;
  }
  if (buffer->capacity < required_bytes) {
    uint8_t* resized =
        static_cast<uint8_t*>(g_try_realloc(buffer->data, required_bytes));
    if (resized == nullptr) {
      return false;
    }
    buffer->data = resized;
    buffer->capacity = required_bytes;
  }
  return true;
}

void CameraPixelBufferFree(CameraPixelBuffer* buffer) {
  if (buffer == nullptr) {
    return;
  }
  g_clear_pointer(&buffer->data, g_free);
  buffer->capacity = 0;
}

void CameraPixelBufferSwap(CameraPixelBuffer* a, CameraPixelBuffer* b) {
  std::swap(a->data, b->data);
  std::swap(a->capacity, b->capacity);
}

bool GetRgbaBufferSize(uint32_t width, uint32_t height, size_t* bytes) {
  if (bytes == nullptr || width == 0 || height == 0 ||
      width > kMaxFrameDimension || height > kMaxFrameDimension) {
    return false;
  }
  const uint64_t pixel_count = static_cast<uint64_t>(width) * height;
  const uint64_t byte_count = pixel_count * 4;
  if (pixel_count > kMaxFramePixelCount ||
      byte_count > std::numeric_limits<size_t>::max()) {
    return false;
  }
  *bytes = static_cast<size_t>(byte_count);
  return true;
}

int PixelFormatRank(uint32_t fourcc) {
  switch (fourcc) {
    case V4L2_PIX_FMT_YUYV:
      return 0;
    case V4L2_PIX_FMT_RGB24:
      return 1;
    case V4L2_PIX_FMT_BGR24:
      return 2;
    default:
      return -1;
  }
}

bool ConvertFrameToRgba(const uint8_t* src, size_t src_len, uint32_t fourcc,
                        uint32_t width, uint32_t height,
                        uint32_t bytes_per_line, uint8_t* dst) {
  size_t unused_rgba_bytes = 0;
  if (src == nullptr || dst == nullptr ||
      !GetRgbaBufferSize(width, height, &unused_rgba_bytes)) {
    return false;
  }

  const size_t w = width;
  const size_t h = height;
  switch (fourcc) {
    case V4L2_PIX_FMT_YUYV:
      return ConvertYuyvToRgba(src, src_len, w, h, bytes_per_line, dst);
    case V4L2_PIX_FMT_RGB24:
      return ConvertRgbOrBgrToRgba(src, src_len, w, h, bytes_per_line, false,
                                   dst);
    case V4L2_PIX_FMT_BGR24:
      return ConvertRgbOrBgrToRgba(src, src_len, w, h, bytes_per_line, true,
                                   dst);
    default:
      return false;
  }
}

void ConvertRgbaToBgra(const uint8_t* rgba, uint8_t* bgra, size_t pixel_count) {
  if (pixel_count == 0 || rgba == nullptr || bgra == nullptr) {
    return;
  }
  for (size_t i = 0; i < pixel_count; ++i) {
    const size_t offset = i * 4;
    bgra[offset + 0] = rgba[offset + 2];
    bgra[offset + 1] = rgba[offset + 1];
    bgra[offset + 2] = rgba[offset + 0];
    bgra[offset + 3] = rgba[offset + 3];
  }
}

}  // namespace camera_linux_v4l2
