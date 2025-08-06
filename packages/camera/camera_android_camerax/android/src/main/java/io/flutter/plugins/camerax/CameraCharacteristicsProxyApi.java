// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.hardware.camera2.CameraCharacteristics;
import androidx.annotation.NonNull;

/**
 * ProxyApi implementation for {@link CameraCharacteristics}. This class may handle instantiating
 * native object instances that are attached to a Dart instance or handle method calls on the
 * associated native class or an instance of that class.
 */
class CameraCharacteristicsProxyApi extends PigeonApiCameraCharacteristics {
  CameraCharacteristicsProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public CameraCharacteristics.Key<?> infoSupportedHardwareLevel() {
    return CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL;
  }

  @NonNull
  @Override
  public CameraCharacteristics.Key<?> sensorOrientation() {
    return CameraCharacteristics.SENSOR_ORIENTATION;
  }
}
