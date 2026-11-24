// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.core.DynamicRange;
import androidx.camera.video.Quality;
import androidx.camera.video.VideoCapabilities;
import java.util.ArrayList;
import java.util.List;

/**
 * ProxyApi implementation for {@link VideoCapabilities}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
class VideoCapabilitiesProxyApi extends PigeonApiVideoCapabilities {
  VideoCapabilitiesProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public List<VideoQuality> getSupportedQualities(
      @NonNull VideoCapabilities pigeonInstance, @NonNull DynamicRange dynamicRange) {
    final List<VideoQuality> qualities = new ArrayList<>();
    for (final Quality quality : pigeonInstance.getSupportedQualities(dynamicRange)) {
      final VideoQuality videoQuality = getVideoQuality(quality);
      // Skips qualities VideoQuality does not model, such as QHD.
      if (videoQuality != null) {
        qualities.add(videoQuality);
      }
    }
    return qualities;
  }

  @Nullable
  VideoQuality getVideoQuality(@NonNull Quality quality) {
    if (quality == Quality.SD) {
      return VideoQuality.SD;
    } else if (quality == Quality.HD) {
      return VideoQuality.HD;
    } else if (quality == Quality.FHD) {
      return VideoQuality.FHD;
    } else if (quality == Quality.UHD) {
      return VideoQuality.UHD;
    } else if (quality == Quality.LOWEST) {
      return VideoQuality.LOWEST;
    } else if (quality == Quality.HIGHEST) {
      return VideoQuality.HIGHEST;
    }

    return null;
  }
}
