// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.DynamicRange;

/**
 * ProxyApi implementation for {@link DynamicRange}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
class DynamicRangeProxyApi extends PigeonApiDynamicRange {
  DynamicRangeProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public DynamicRange sdr() {
    return DynamicRange.SDR;
  }
}
