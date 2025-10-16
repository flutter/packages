// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.util.Size;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.core.CameraInfo;
import androidx.camera.video.FallbackStrategy;
import androidx.camera.video.Quality;
import androidx.camera.video.QualitySelector;
import java.util.ArrayList;
import java.util.List;

/**
 * ProxyApi implementation for {@link QualitySelector}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
class QualitySelectorProxyApi extends PigeonApiQualitySelector {
  QualitySelectorProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public QualitySelector from(
      @NonNull VideoQuality quality, @Nullable FallbackStrategy fallbackStrategy) {
    if (fallbackStrategy == null) {
      return QualitySelector.from(getNativeQuality(quality));
    }

    return QualitySelector.from(getNativeQuality(quality), fallbackStrategy);
  }

  @NonNull
  @Override
  public QualitySelector fromOrderedList(
      @NonNull List<? extends VideoQuality> qualities,
      @Nullable FallbackStrategy fallbackStrategy) {
    final List<Quality> nativeQualities = new ArrayList<>();
    for (final VideoQuality quality : qualities) {
      nativeQualities.add(getNativeQuality(quality));
    }

    if (fallbackStrategy == null) {
      return QualitySelector.fromOrderedList(nativeQualities);
    }

    return QualitySelector.fromOrderedList(nativeQualities, fallbackStrategy);
  }

  @Nullable
  @Override
  public Size getResolution(@NonNull CameraInfo cameraInfo, @NonNull VideoQuality quality) {
    return QualitySelector.getResolution(cameraInfo, getNativeQuality(quality));
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
        "VideoQuality " + quality + " is unhandled by QualitySelectorProxyApi.");
  }
}
