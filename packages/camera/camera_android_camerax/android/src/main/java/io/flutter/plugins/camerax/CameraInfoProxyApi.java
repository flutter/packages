// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.CameraInfo;
import androidx.camera.core.ExposureState;

/**
 * ProxyApi implementation for {@link CameraInfo}. This class may handle instantiating native object
 * instances that are attached to a Dart instance or handle method calls on the associated native
 * class or an instance of that class.
 */
class CameraInfoProxyApi extends PigeonApiCameraInfo {
  CameraInfoProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public long sensorRotationDegrees(CameraInfo pigeonInstance) {
    return pigeonInstance.getSensorRotationDegrees();
  }

  @NonNull
  @Override
  public ExposureState exposureState(CameraInfo pigeonInstance) {
    return pigeonInstance.getExposureState();
  }

  @NonNull
  @Override
  public LiveDataProxyApi.LiveDataWrapper getCameraState(CameraInfo pigeonInstance) {
    return new LiveDataProxyApi.LiveDataWrapper(
        pigeonInstance.getCameraState(), LiveDataSupportedType.CAMERA_STATE);
  }

  @NonNull
  @Override
  public LiveDataProxyApi.LiveDataWrapper getZoomState(CameraInfo pigeonInstance) {
    return new LiveDataProxyApi.LiveDataWrapper(
        pigeonInstance.getZoomState(), LiveDataSupportedType.ZOOM_STATE);
  }
}
