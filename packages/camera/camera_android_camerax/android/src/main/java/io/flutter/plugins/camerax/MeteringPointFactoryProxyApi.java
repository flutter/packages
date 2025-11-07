// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.MeteringPoint;
import androidx.camera.core.MeteringPointFactory;

/**
 * ProxyApi implementation for {@link MeteringPointFactory}. This class may handle instantiating
 * native object instances that are attached to a Dart instance or handle method calls on the
 * associated native class or an instance of that class.
 */
class MeteringPointFactoryProxyApi extends PigeonApiMeteringPointFactory {
  MeteringPointFactoryProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public MeteringPoint createPoint(MeteringPointFactory pigeonInstance, double x, double y) {
    return pigeonInstance.createPoint((float) x, (float) y);
  }

  @NonNull
  @Override
  public MeteringPoint createPointWithSize(
      MeteringPointFactory pigeonInstance, double x, double y, double size) {
    return pigeonInstance.createPoint((float) x, (float) y, (float) size);
  }
}
