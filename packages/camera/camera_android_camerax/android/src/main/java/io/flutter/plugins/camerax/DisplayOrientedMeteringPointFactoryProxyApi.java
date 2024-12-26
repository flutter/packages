// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.DisplayOrientedMeteringPointFactory;
import androidx.camera.core.CameraInfo;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * ProxyApi implementation for {@link DisplayOrientedMeteringPointFactory}.
 * This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class DisplayOrientedMeteringPointFactoryProxyApi extends PigeonApiDisplayOrientedMeteringPointFactory {
  DisplayOrientedMeteringPointFactoryProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public DisplayOrientedMeteringPointFactory pigeon_defaultConstructor(@NonNull androidx.camera.core.CameraInfo cameraInfo, @NonNull Double width, @NonNull Double height) {
    return DisplayOrientedMeteringPointFactory(cameraInfo, width, height);
  }

}
