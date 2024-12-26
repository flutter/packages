// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.video.FallbackStrategy;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * ProxyApi implementation for {@link FallbackStrategy}.
 * This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class FallbackStrategyProxyApi extends PigeonApiFallbackStrategy {
  FallbackStrategyProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public FallbackStrategy higherQualityOrLowerThan(@NonNull VideoQuality quality) {
    return FallbackStrategy(quality);
  }

  @NonNull
  @Override
  public FallbackStrategy higherQualityThan(@NonNull VideoQuality quality) {
    return FallbackStrategy(quality);
  }

  @NonNull
  @Override
  public FallbackStrategy lowerQualityOrHigherThan(@NonNull VideoQuality quality) {
    return FallbackStrategy(quality);
  }

  @NonNull
  @Override
  public FallbackStrategy lowerQualityThan(@NonNull VideoQuality quality) {
    return FallbackStrategy(quality);
  }

}
