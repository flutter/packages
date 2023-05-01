// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.CameraInfo;
import androidx.camera.core.CameraState;
import androidx.lifecycle.LiveData;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraInfoHostApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.LiveDataSupportedType;
import java.util.Objects;

public class CameraInfoHostApiImpl implements CameraInfoHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;

  @VisibleForTesting public LiveDataFlutterApiWrapper liveDataFlutterApiWrapper;

  public CameraInfoHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.liveDataFlutterApiWrapper =
        new LiveDataFlutterApiWrapper(binaryMessenger, instanceManager);
  }

  /**
   * Retrieves the sensor rotation degrees of the {@link androidx.camera.core.Camera} that is
   * represented by the {@link CameraInfo} with the specified identifier.
   */
  @Override
  @NonNull
  public Long getSensorRotationDegrees(@NonNull Long identifier) {
    CameraInfo cameraInfo =
        (CameraInfo) Objects.requireNonNull(instanceManager.getInstance(identifier));
    return Long.valueOf(cameraInfo.getSensorRotationDegrees());
  }

  /**
   * Retrieves the {@link LiveData} of the {@link CameraState} that is tied to the {@link
   * androidx.camera.core.Camera} that is represented by the {@link CameraInfo} with the specified
   * identifier.
   */
  @Override
  @NonNull
  public Long getLiveCameraState(@NonNull Long identifier) {
    CameraInfo cameraInfo =
        (CameraInfo) Objects.requireNonNull(instanceManager.getInstance(identifier));
    LiveData<CameraState> liveCameraState = cameraInfo.getCameraState();
    liveDataFlutterApiWrapper.create(
        liveCameraState, LiveDataSupportedType.CAMERA_STATE, reply -> {});
    return instanceManager.getIdentifierForStrongReference(liveCameraState);
  }
}
