// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.video.FallbackStrategy;
import androidx.camera.video.Quality;

/**
 * ProxyApi implementation for {@link FallbackStrategy}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
class FallbackStrategyProxyApi extends PigeonApiFallbackStrategy {
  FallbackStrategyProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public FallbackStrategy higherQualityOrLowerThan(@NonNull VideoQuality quality) {
    return FallbackStrategy.higherQualityOrLowerThan(getNativeQuality(quality));
  }

  @NonNull
  @Override
  public FallbackStrategy higherQualityThan(@NonNull VideoQuality quality) {
    return FallbackStrategy.higherQualityThan(getNativeQuality(quality));
  }

  @NonNull
  @Override
  public FallbackStrategy lowerQualityOrHigherThan(@NonNull VideoQuality quality) {
    return FallbackStrategy.lowerQualityOrHigherThan(getNativeQuality(quality));
  }

  @NonNull
  @Override
  public FallbackStrategy lowerQualityThan(@NonNull VideoQuality quality) {
    return FallbackStrategy.lowerQualityThan(getNativeQuality(quality));
  }

  Quality getNativeQuality(VideoQuality quality) {
    switch (quality) {
      case SD:
        return Quality.SD;
      case HD:
        return Quality.HD;
      case FHD:
        return Quality.FHD;
      case UHD:
        return Quality.UHD;
      case LOWEST:
        return Quality.LOWEST;
      case HIGHEST:
        return Quality.HIGHEST;
    }

    throw new IllegalArgumentException(
        "VideoQuality " + quality + " is unhandled by FallbackStrategyProxyApi.");
  }
}
