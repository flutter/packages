// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.core.CameraInfo;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.ExperimentalLensFacing;
import java.util.List;

/**
 * ProxyApi implementation for {@link CameraSelector}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
class CameraSelectorProxyApi extends PigeonApiCameraSelector {
  CameraSelectorProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @ExperimentalLensFacing
  @NonNull
  @Override
  public CameraSelector pigeon_defaultConstructor(@Nullable LensFacing requireLensFacing) {
    final CameraSelector.Builder builder = new CameraSelector.Builder();
    if (requireLensFacing != null) {
      switch (requireLensFacing) {
        case FRONT:
          builder.requireLensFacing(CameraSelector.LENS_FACING_FRONT);
          break;
        case BACK:
          builder.requireLensFacing(CameraSelector.LENS_FACING_BACK);
          break;
        case EXTERNAL:
          builder.requireLensFacing(CameraSelector.LENS_FACING_EXTERNAL);
          break;
        case UNKNOWN:
          builder.requireLensFacing(CameraSelector.LENS_FACING_UNKNOWN);
          break;
      }
    }
    return builder.build();
  }

  @NonNull
  @Override
  public androidx.camera.core.CameraSelector defaultBackCamera() {
    return CameraSelector.DEFAULT_BACK_CAMERA;
  }

  @NonNull
  @Override
  public androidx.camera.core.CameraSelector defaultFrontCamera() {
    return CameraSelector.DEFAULT_FRONT_CAMERA;
  }

  // List<? extends CameraInfo> can be considered the same as List<CameraInfo>.
  @SuppressWarnings("unchecked")
  @NonNull
  @Override
  public List<CameraInfo> filter(
      @NonNull CameraSelector pigeon_instance, @NonNull List<? extends CameraInfo> cameraInfos) {
    return pigeon_instance.filter((List<CameraInfo>) cameraInfos);
  }
}
