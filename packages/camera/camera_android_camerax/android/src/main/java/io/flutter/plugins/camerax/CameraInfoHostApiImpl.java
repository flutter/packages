// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.CameraInfo;
import androidx.camera.core.CameraState;
import androidx.camera.core.ExposureState;
import androidx.camera.core.ZoomState;
import androidx.lifecycle.LiveData;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraInfoHostApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.LiveDataSupportedType;
import java.util.Objects;

public class CameraInfoHostApiImpl implements CameraInfoHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;

  @VisibleForTesting public @NonNull LiveDataFlutterApiWrapper liveDataFlutterApiWrapper;

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
  public Long getCameraState(@NonNull Long identifier) {
    CameraInfo cameraInfo =
        (CameraInfo) Objects.requireNonNull(instanceManager.getInstance(identifier));
    LiveData<CameraState> liveCameraState = cameraInfo.getCameraState();
    liveDataFlutterApiWrapper.create(
        liveCameraState, LiveDataSupportedType.CAMERA_STATE, reply -> {});
    return instanceManager.getIdentifierForStrongReference(liveCameraState);
  }

  /**
   * Retrieves the {@link ExposureState} of the {@link CameraInfo} with the specified identifier.
   */
  @Override
  @NonNull
  public Long getExposureState(@NonNull Long identifier) {
    CameraInfo cameraInfo =
        (CameraInfo) Objects.requireNonNull(instanceManager.getInstance(identifier));
    ExposureState exposureState = cameraInfo.getExposureState();

    ExposureStateFlutterApiImpl exposureStateFlutterApiImpl =
        new ExposureStateFlutterApiImpl(binaryMessenger, instanceManager);
    exposureStateFlutterApiImpl.create(exposureState, result -> {});

    return instanceManager.getIdentifierForStrongReference(exposureState);
  }

  /**
   * Retrieves the {@link LiveData} of the {@link ZoomState} of the {@link CameraInfo} with the
   * specified identifier.
   */
  @NonNull
  @Override
  public Long getZoomState(@NonNull Long identifier) {
    CameraInfo cameraInfo =
        (CameraInfo) Objects.requireNonNull(instanceManager.getInstance(identifier));
    LiveData<ZoomState> zoomState = cameraInfo.getZoomState();

    LiveDataFlutterApiWrapper liveDataFlutterApiWrapper =
        new LiveDataFlutterApiWrapper(binaryMessenger, instanceManager);
    liveDataFlutterApiWrapper.create(zoomState, LiveDataSupportedType.ZOOM_STATE, reply -> {});

    return instanceManager.getIdentifierForStrongReference(zoomState);
  }
}
