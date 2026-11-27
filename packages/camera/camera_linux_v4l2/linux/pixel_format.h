// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_LINUX_V4L2_LINUX_PIXEL_FORMAT_H_
#define PACKAGES_CAMERA_CAMERA_LINUX_V4L2_LINUX_PIXEL_FORMAT_H_

#include <cstddef>
#include <cstdint>

namespace camera_linux_v4l2 {

// Limits accepted frame dimensions and total area. The area limit keeps each
// RGBA/BGRA frame buffer below 34 MiB while retaining DCI 4K support.
constexpr uint32_t kMaxFrameDimension = 8192;
constexpr uint64_t kMaxFramePixelCount = 4096ULL * 2160;

// Plain buffer owning heap-allocated pixel bytes via g_malloc/g_free so it can
// be stored safely inside GObject structs and swapped in O(1).
struct CameraPixelBuffer {
  uint8_t* data = nullptr;
  size_t capacity = 0;
};

// Ensures `buffer` can hold at least `required_bytes`. Returns false on
// allocation failure.
bool CameraPixelBufferEnsure(CameraPixelBuffer* buffer, size_t required_bytes);

// Frees `buffer->data` and resets fields to zero.
void CameraPixelBufferFree(CameraPixelBuffer* buffer);

// Swaps `a` and `b` in O(1).
void CameraPixelBufferSwap(CameraPixelBuffer* a, CameraPixelBuffer* b);

// Returns the required byte count for a tightly packed RGBA frame, or false
// if the dimensions or output pointer are invalid.
bool GetRgbaBufferSize(uint32_t width, uint32_t height, size_t* bytes);

// Returns preference rank for a V4L2 fourcc (lower is preferred), or -1 if
// unsupported.
int PixelFormatRank(uint32_t fourcc);

// Converts a V4L2 frame to tightly packed RGBA8888 (`width * height * 4`
// bytes in `dst`). Returns false if arguments, dimensions, format, or input
// byte length are invalid.
bool ConvertFrameToRgba(const uint8_t* src, size_t src_len, uint32_t fourcc,
                        uint32_t width, uint32_t height,
                        uint32_t bytes_per_line, uint8_t* dst);

// Converts `pixel_count` tightly packed RGBA pixels to BGRA (`4 * pixel_count`
// bytes in `bgra`).
void ConvertRgbaToBgra(const uint8_t* rgba, uint8_t* bgra, size_t pixel_count);

}  // namespace camera_linux_v4l2

#endif  // PACKAGES_CAMERA_CAMERA_LINUX_V4L2_LINUX_PIXEL_FORMAT_H_
