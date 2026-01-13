// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.CameraState;

/**
 * ProxyApi implementation for {@link CameraState.StateError}. This class may handle instantiating
 * native object instances that are attached to a Dart instance or handle method calls on the
 * associated native class or an instance of that class.
 */
class CameraStateStateErrorProxyApi extends PigeonApiCameraStateStateError {
  CameraStateStateErrorProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public CameraStateErrorCode code(CameraState.StateError pigeonInstance) {
    switch (pigeonInstance.getCode()) {
      case CameraState.ERROR_CAMERA_DISABLED:
        return CameraStateErrorCode.CAMERA_DISABLED;
      case CameraState.ERROR_CAMERA_FATAL_ERROR:
        return CameraStateErrorCode.CAMERA_FATAL_ERROR;
      case CameraState.ERROR_CAMERA_IN_USE:
        return CameraStateErrorCode.CAMERA_IN_USE;
      case CameraState.ERROR_DO_NOT_DISTURB_MODE_ENABLED:
        return CameraStateErrorCode.DO_NOT_DISTURB_MODE_ENABLED;
      case CameraState.ERROR_MAX_CAMERAS_IN_USE:
        return CameraStateErrorCode.MAX_CAMERAS_IN_USE;
      case CameraState.ERROR_OTHER_RECOVERABLE_ERROR:
        return CameraStateErrorCode.OTHER_RECOVERABLE_ERROR;
      case CameraState.ERROR_STREAM_CONFIG:
        return CameraStateErrorCode.STREAM_CONFIG;
      default:
        return CameraStateErrorCode.UNKNOWN;
    }
  }
}
