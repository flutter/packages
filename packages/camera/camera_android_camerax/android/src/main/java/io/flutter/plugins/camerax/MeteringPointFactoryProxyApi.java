// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.MeteringPointFactory;
import androidx.camera.core.MeteringPoint;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * ProxyApi implementation for {@link MeteringPointFactory}.
 * This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class MeteringPointFactoryProxyApi extends PigeonApiMeteringPointFactory {
  MeteringPointFactoryProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public androidx.camera.core.MeteringPoint createPoint(MeteringPointFactory, pigeon_instance@NonNull Double x, @NonNull Double y) {
    return pigeon_instance.createPoint(x, y);
  }

  @NonNull
  @Override
  public androidx.camera.core.MeteringPoint createPointWithSize(MeteringPointFactory, pigeon_instance@NonNull Double x, @NonNull Double y, @NonNull Double size) {
    return pigeon_instance.createPointWithSize(x, y, size);
  }

}
