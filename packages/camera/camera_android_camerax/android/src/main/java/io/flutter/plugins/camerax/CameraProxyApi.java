// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.Camera;
import androidx.camera.core.CameraControl;
import androidx.camera.core.CameraInfo;

/**
 * ProxyApi implementation for {@link Camera}. This class may handle instantiating native object
 * instances that are attached to a Dart instance or handle method calls on the associated native
 * class or an instance of that class.
 */
class CameraProxyApi extends PigeonApiCamera {
  CameraProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public CameraControl cameraControl(Camera pigeonInstance) {
    return pigeonInstance.getCameraControl();
  }

  @NonNull
  @Override
  public CameraInfo getCameraInfo(Camera pigeonInstance) {
    return pigeonInstance.getCameraInfo();
  }
}
