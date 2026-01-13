// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.util.Range;
import androidx.annotation.NonNull;

/**
 * ProxyApi implementation for {@link android.util.Range<Integer>}. This class may handle
 * instantiating native object instances that are attached to a Dart instance or handle method calls
 * on the associated native class or an instance of that class.
 */
class CameraIntegerRangeProxyApi extends PigeonApiCameraIntegerRange {
  CameraIntegerRangeProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public Range<Integer> pigeon_defaultConstructor(long lower, long upper) {
    return new Range<>((int) lower, (int) upper);
  }

  @Override
  public long lower(Range<?> pigeonInstance) {
    return (Integer) pigeonInstance.getLower();
  }

  @Override
  public long upper(Range<?> pigeonInstance) {
    return (Integer) pigeonInstance.getUpper();
  }
}
