// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.DynamicRange;
import androidx.camera.video.VideoCapabilities;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

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
  public List<DynamicRangeType> getSupportedDynamicRanges(
      @NonNull VideoCapabilities pigeonInstance) {
    final Set<DynamicRange> supported = pigeonInstance.getSupportedDynamicRanges();
    final List<DynamicRangeType> result = new ArrayList<>();
    if (supported.contains(DynamicRange.SDR)) {
      result.add(DynamicRangeType.SDR);
    }
    if (supported.contains(DynamicRange.HLG_10_BIT)) {
      result.add(DynamicRangeType.HLG10);
    }
    return result;
  }
}
