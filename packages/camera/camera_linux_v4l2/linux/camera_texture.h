// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_LINUX_V4L2_LINUX_CAMERA_TEXTURE_H_
#define PACKAGES_CAMERA_CAMERA_LINUX_V4L2_LINUX_CAMERA_TEXTURE_H_

#include <flutter_linux/flutter_linux.h>

#include <cstdint>

#include "pixel_format.h"

G_BEGIN_DECLS

G_DECLARE_FINAL_TYPE(FlCameraTexture, fl_camera_texture, FL, CAMERA_TEXTURE,
                     FlPixelBufferTexture)

// Creates a triple-buffered FlPixelBufferTexture for camera preview frames.
FlCameraTexture* fl_camera_texture_new();

// Publishes a new RGBA frame by swapping `rgba_buffer` with the internal
// staging buffer in O(1). `rgba_buffer` must hold at least
// `width * height * 4` bytes. Returns FALSE on invalid arguments.
gboolean fl_camera_texture_update_frame(
    FlCameraTexture* texture, camera_linux_v4l2::CameraPixelBuffer* rgba_buffer,
    uint32_t width, uint32_t height);

G_END_DECLS

#endif  // PACKAGES_CAMERA_CAMERA_LINUX_V4L2_LINUX_CAMERA_TEXTURE_H_
