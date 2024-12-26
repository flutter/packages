// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.video.QualitySelector;
import androidx.camera.video.FallbackStrategy;
import androidx.camera.core.CameraInfo;
import android.util.Size;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * ProxyApi implementation for {@link QualitySelector}.
 * This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class QualitySelectorProxyApi extends PigeonApiQualitySelector {
  QualitySelectorProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public QualitySelector from(@NonNull VideoQuality quality, @Nullable androidx.camera.video.FallbackStrategy? fallbackStrategy) {
    return QualitySelector(quality, fallbackStrategy);
  }

  @NonNull
  @Override
  public QualitySelector fromOrderedList(@NonNull List<VideoQuality> qualities, @Nullable androidx.camera.video.FallbackStrategy? fallbackStrategy) {
    return QualitySelector(qualities, fallbackStrategy);
  }

  @Nullable
  @Override
  public android.util.Size? getResolution(@NonNull androidx.camera.core.CameraInfo cameraInfo, @NonNull VideoQuality quality) {
    return QualitySelector.getResolution(cameraInfo, quality);
  }

}
