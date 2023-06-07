// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.CameraInfo;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraInfoFlutterApi;

public class CameraInfoFlutterApiImpl extends CameraInfoFlutterApi {
  private final @NonNull InstanceManager instanceManager;

  public CameraInfoFlutterApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    super(binaryMessenger);
    this.instanceManager = instanceManager;
  }

  /**
   * Creates a {@link CameraInfo} instance in Dart. {@code reply} is not used so it can be empty.
   */
  void create(CameraInfo cameraInfo, Reply<Void> reply) {
    if (!instanceManager.containsInstance(cameraInfo)) {
      create(instanceManager.addHostCreatedInstance(cameraInfo), reply);
    }
  }
}
