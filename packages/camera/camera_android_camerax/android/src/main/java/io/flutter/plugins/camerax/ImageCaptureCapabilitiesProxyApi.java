// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.ImageCaptureCapabilities;
import java.util.ArrayList;
import java.util.List;

/**
 * ProxyApi implementation for {@link ImageCaptureCapabilities}. This class may handle instantiating
 * native object instances that are attached to a Dart instance or handle method calls on the
 * associated native class or an instance of that class.
 */
class ImageCaptureCapabilitiesProxyApi extends PigeonApiImageCaptureCapabilities {
  ImageCaptureCapabilitiesProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public List<Long> getSupportedOutputFormats(@NonNull ImageCaptureCapabilities pigeonInstance) {
    final List<Long> result = new ArrayList<>();
    for (Integer format : pigeonInstance.getSupportedOutputFormats()) {
      result.add(format.longValue());
    }
    return result;
  }
}
