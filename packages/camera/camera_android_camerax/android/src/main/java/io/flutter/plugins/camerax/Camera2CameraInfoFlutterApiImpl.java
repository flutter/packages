// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.OptIn;
import androidx.camera.camera2.interop.Camera2CameraInfo;
import androidx.camera.camera2.interop.ExperimentalCamera2Interop;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.Camera2CameraInfoFlutterApi;

public class Camera2CameraInfoFlutterApiImpl extends Camera2CameraInfoFlutterApi {
  private final InstanceManager instanceManager;

  public Camera2CameraInfoFlutterApiImpl(
      @Nullable BinaryMessenger binaryMessenger, @Nullable InstanceManager instanceManager) {
    super(binaryMessenger);
    this.instanceManager = instanceManager;
  }

  @OptIn(markerClass = ExperimentalCamera2Interop.class)
  void create(@NonNull Camera2CameraInfo camera2CameraInfo, @Nullable Reply<Void> reply) {
    if (!instanceManager.containsInstance(camera2CameraInfo)) {
      create(instanceManager.addHostCreatedInstance(camera2CameraInfo), reply);
    }
  }
}
