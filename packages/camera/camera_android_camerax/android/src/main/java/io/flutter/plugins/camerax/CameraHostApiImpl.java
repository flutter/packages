// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.Camera;
import androidx.camera.core.CameraControl;
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
    Camera camera = getCameraInstance(identifier);
    CameraInfo cameraInfo = camera.getCameraInfo();

    CameraInfoFlutterApiImpl cameraInfoFlutterApiImpl =
        new CameraInfoFlutterApiImpl(binaryMessenger, instanceManager);
    cameraInfoFlutterApiImpl.create(cameraInfo, reply -> {});
    return instanceManager.getIdentifierForStrongReference(cameraInfo);
  }

  /**
   * Retrieves the {@link CameraControl} instance that provides access to asynchronous operations
   * like zoom and focus & metering on the {@link Camera} instance with the specified identifier.
   */
  @Override
  @NonNull
  public Long getCameraControl(@NonNull Long identifier) {
    Camera camera = getCameraInstance(identifier);
    CameraControl cameraControl = camera.getCameraControl();

    CameraControlFlutterApiImpl cameraControlFlutterApiImpl =
        new CameraControlFlutterApiImpl(binaryMessenger, instanceManager);
    cameraControlFlutterApiImpl.create(cameraControl, reply -> {});
    return instanceManager.getIdentifierForStrongReference(cameraControl);
  }

  /** Retrieives the {@link Camera} instance associated with the specified {@code identifier}. */
  private Camera getCameraInstance(@NonNull Long identifier) {
    return (Camera) Objects.requireNonNull(instanceManager.getInstance(identifier));
  }
}
