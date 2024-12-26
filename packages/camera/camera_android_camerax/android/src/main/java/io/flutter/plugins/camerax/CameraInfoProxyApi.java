// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.CameraInfo;
import androidx.camera.core.ExposureState;
import androidx.lifecycle.LiveData;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * ProxyApi implementation for {@link CameraInfo}.
 * This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class CameraInfoProxyApi extends PigeonApiCameraInfo {
  CameraInfoProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public long sensorRotationDegrees(CameraInfo pigeon_instance) {
    return pigeon_instance.getSensorRotationDegrees();
  }

  @NonNull
  @Override
  public ExposureState exposureState(CameraInfo pigeon_instance) {
    return pigeon_instance.getExposureState();
  }

  @NonNull
  @Override
  public LiveDataProxyApi.LiveDataWrapper getCameraState(CameraInfo pigeon_instance) {
    return new LiveDataProxyApi.LiveDataWrapper(pigeon_instance.getCameraState(), LiveDataSupportedType.CAMERA_STATE);
  }

  @NonNull
  @Override
  public LiveDataProxyApi.LiveDataWrapper getZoomState(CameraInfo pigeon_instance) {
    return new LiveDataProxyApi.LiveDataWrapper(pigeon_instance.getZoomState(), LiveDataSupportedType.ZOOM_STATE);
  }
}
