// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.ImageProxy;
import java.util.Arrays;

/**
 * ProxyApi implementation for {@link ImageProxyUtils}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
public class ImageProxyUtilsProxyApi extends PigeonApiImageProxyUtils {

  ImageProxyUtilsProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public byte[] getNv21Buffer(@NonNull ImageProxy imageProxy) {
    final int width = imageProxy.getWidth();
    final int height = imageProxy.getHeight();
    final int expectedYSize = width * height;
    final byte[] bytes = new byte[expectedYSize + (expectedYSize / 2)];

    ImageProxyUtils.planesToNV21(Arrays.asList(imageProxy.getPlanes()), width, height, bytes);

    return bytes;
  }
}
