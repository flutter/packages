// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.Camera;
import androidx.camera.core.CameraInfo;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraHostApi;
import java.util.Objects;

public class CameraHostApiImpl implements CameraHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;

  public CameraHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
  }

  /**
   * Retrieves the {@link CameraInfo} instance that contains information about the {@link Camera}
   * instance with the specified identifier.
   */
  @Override
  @NonNull
  public Long getCameraInfo(@NonNull Long identifier) {
    Camera camera = (Camera) Objects.requireNonNull(instanceManager.getInstance(identifier));
    CameraInfo cameraInfo = camera.getCameraInfo();

    if (!instanceManager.containsInstance(cameraInfo)) {
      CameraInfoFlutterApiImpl cameraInfoFlutterApiImpl =
          new CameraInfoFlutterApiImpl(binaryMessenger, instanceManager);
      cameraInfoFlutterApiImpl.create(cameraInfo, reply -> {});
    }
    return instanceManager.getIdentifierForStrongReference(cameraInfo);
  }
}
