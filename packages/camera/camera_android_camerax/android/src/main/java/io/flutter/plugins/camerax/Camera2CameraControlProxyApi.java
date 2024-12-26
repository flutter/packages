// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.camera2.interop.Camera2CameraControl;
import androidx.camera.core.CameraControl;
import androidx.camera.camera2.interop.CaptureRequestOptions;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * ProxyApi implementation for {@link Camera2CameraControl}.
 * This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class Camera2CameraControlProxyApi extends PigeonApiCamera2CameraControl {
  Camera2CameraControlProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public Camera2CameraControl from(@NonNull androidx.camera.core.CameraControl cameraControl) {
    return Camera2CameraControl(cameraControl);
  }

  @Override
  public Void addCaptureRequestOptions(Camera2CameraControl, pigeon_instance@NonNull androidx.camera.camera2.interop.CaptureRequestOptions bundle) {
    pigeon_instance.addCaptureRequestOptions(bundle);
  }

}
