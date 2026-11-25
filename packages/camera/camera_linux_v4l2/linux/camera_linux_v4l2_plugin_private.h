// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_LINUX_V4L2_LINUX_CAMERA_LINUX_V4L2_PLUGIN_PRIVATE_H_
#define PACKAGES_CAMERA_CAMERA_LINUX_V4L2_LINUX_CAMERA_LINUX_V4L2_PLUGIN_PRIVATE_H_

#include <flutter_linux/flutter_linux.h>

#include <cstdint>
#include <memory>

#include "include/camera_linux_v4l2/camera_linux_v4l2_plugin.h"
#include "messages.g.h"
#include "v4l2_system.h"

// Creates a plugin instance wired to `registrar` using the POSIX V4L2 backend.
FlCameraLinuxV4l2Plugin* fl_camera_linux_v4l2_plugin_new(
    FlPluginRegistrar* registrar);

// Creates a plugin instance with injected dependencies for unit testing.
FlCameraLinuxV4l2Plugin* fl_camera_linux_v4l2_plugin_new_with_dependencies(
    FlBinaryMessenger* messenger, FlTextureRegistrar* texture_registrar,
    std::unique_ptr<camera_linux_v4l2::V4l2System> v4l2_system);

// Pigeon host API handlers exposed for direct unit testing.
FclCameraApiGetAvailableCamerasResponse* handle_get_available_cameras(
    gpointer user_data);

FclCameraApiCreateResponse* handle_create(
    const gchar* camera_name, FclPlatformResolutionPreset resolution_preset,
    gpointer user_data);

FclCameraApiInitializeResponse* handle_initialize(int64_t camera_id,
                                                  gpointer user_data);

FclCameraApiStartImageStreamResponse* handle_start_image_stream(
    int64_t camera_id, gpointer user_data);

FclCameraApiStopImageStreamResponse* handle_stop_image_stream(
    int64_t camera_id, gpointer user_data);

FclCameraApiDisposeResponse* handle_dispose(int64_t camera_id,
                                            gpointer user_data);

#endif  // PACKAGES_CAMERA_CAMERA_LINUX_V4L2_LINUX_CAMERA_LINUX_V4L2_PLUGIN_PRIVATE_H_
