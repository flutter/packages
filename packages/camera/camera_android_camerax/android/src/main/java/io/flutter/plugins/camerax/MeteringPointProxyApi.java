// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.MeteringPoint;

/**
 * ProxyApi implementation for {@link MeteringPoint}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
class MeteringPointProxyApi extends PigeonApiMeteringPoint {
  MeteringPointProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public double getSize(MeteringPoint pigeon_instance) {
    return pigeon_instance.getSize();
  }
}
