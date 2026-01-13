// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.core.CameraState;
import androidx.camera.core.CameraState.StateError;

/**
 * ProxyApi implementation for {@link CameraState}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
class CameraStateProxyApi extends PigeonApiCameraState {
  CameraStateProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public CameraStateType type(CameraState pigeonInstance) {
    switch (pigeonInstance.getType()) {
      case PENDING_OPEN:
        return CameraStateType.PENDING_OPEN;
      case OPENING:
        return CameraStateType.OPENING;
      case OPEN:
        return CameraStateType.OPEN;
      case CLOSING:
        return CameraStateType.CLOSING;
      case CLOSED:
        return CameraStateType.CLOSED;
    }
    return CameraStateType.UNKNOWN;
  }

  @Nullable
  @Override
  public StateError error(CameraState pigeonInstance) {
    return pigeonInstance.getError();
  }
}
