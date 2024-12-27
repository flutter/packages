// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.ZoomState;

/**
 * ProxyApi implementation for {@link ZoomState}. This class may handle instantiating native object
 * instances that are attached to a Dart instance or handle method calls on the associated native
 * class or an instance of that class.
 */
class ZoomStateProxyApi extends PigeonApiZoomState {
  ZoomStateProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public double minZoomRatio(ZoomState pigeon_instance) {
    return pigeon_instance.getMinZoomRatio();
  }

  @Override
  public double maxZoomRatio(ZoomState pigeon_instance) {
    return pigeon_instance.getMaxZoomRatio();
  }
}
