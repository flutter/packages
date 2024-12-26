// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.CameraControl;
import androidx.camera.core.FocusMeteringAction;
import androidx.camera.core.FocusMeteringResult;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * ProxyApi implementation for {@link CameraControl}.
 * This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class CameraControlProxyApi extends PigeonApiCameraControl {
  CameraControlProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public Void enableTorch(CameraControl, pigeon_instance@NonNull Boolean torch) {
    pigeon_instance.enableTorch(torch);
  }

  @Override
  public Void setZoomRatio(CameraControl, pigeon_instance@NonNull Double ratio) {
    pigeon_instance.setZoomRatio(ratio);
  }

  @NonNull
  @Override
  public androidx.camera.core.FocusMeteringResult startFocusAndMetering(CameraControl, pigeon_instance@NonNull androidx.camera.core.FocusMeteringAction action) {
    return pigeon_instance.startFocusAndMetering(action);
  }

  @Override
  public Void cancelFocusAndMetering(CameraControl pigeon_instance) {
    pigeon_instance.cancelFocusAndMetering();
  }

  @NonNull
  @Override
  public Long setExposureCompensationIndex(CameraControl, pigeon_instance@NonNull Long index) {
    return pigeon_instance.setExposureCompensationIndex(index);
  }

}
