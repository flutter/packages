// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_LINUX_V4L2_LINUX_INCLUDE_CAMERA_LINUX_V4L2_CAMERA_LINUX_V4L2_PLUGIN_H_
#define PACKAGES_CAMERA_CAMERA_LINUX_V4L2_LINUX_INCLUDE_CAMERA_LINUX_V4L2_CAMERA_LINUX_V4L2_PLUGIN_H_

// A plugin to access cameras on Linux using V4L2.

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

G_DECLARE_FINAL_TYPE(FlCameraLinuxV4l2Plugin, fl_camera_linux_v4l2_plugin, FL,
                     CAMERA_LINUX_V4L2_PLUGIN, GObject)

FLUTTER_PLUGIN_EXPORT void camera_linux_v4l2_plugin_register_with_registrar(
    FlPluginRegistrar* registrar);

G_END_DECLS

#endif  // PACKAGES_CAMERA_CAMERA_LINUX_V4L2_LINUX_INCLUDE_CAMERA_LINUX_V4L2_CAMERA_LINUX_V4L2_PLUGIN_H_
