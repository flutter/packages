// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.CameraControl;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraControlFlutterApi;

public class CameraControlFlutterApiImpl extends CameraControlFlutterApi {
  private final @NonNull InstanceManager instanceManager;

  public CameraControlFlutterApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    super(binaryMessenger);
    this.instanceManager = instanceManager;
  }

  /**
   * Creates a {@link CameraControl} instance in Dart. {@code reply} is not used so it can be empty.
   */
  void create(CameraControl cameraControl, Reply<Void> reply) {
    if (!instanceManager.containsInstance(cameraControl)) {
      create(instanceManager.addHostCreatedInstance(cameraControl), reply);
    }
  }
}
