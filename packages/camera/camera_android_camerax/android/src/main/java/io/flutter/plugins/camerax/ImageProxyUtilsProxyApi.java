// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.ImageProxy.PlaneProxy;
import java.nio.ByteBuffer;
import java.util.List;

/**
 * ProxyApi implementation for {@link ImageProxyUtils}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
public class ImageProxyUtilsProxyApi extends PigeonApiImageProxyUtils {
  ImageProxyUtilsProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  // List<? extends PlaneProxy> can be considered the same as List<PlaneProxy>.
  @SuppressWarnings("unchecked")
  @NonNull
  @Override
  public byte[] getNv21Buffer(
      long imageWidth, long imageHeight, @NonNull List<? extends PlaneProxy> planes) {
    final ByteBuffer nv21Buffer =
        ImageProxyUtils.planesToNV21(
            (List<PlaneProxy>) planes, (int) imageWidth, (int) imageHeight);

    byte[] bytes = new byte[nv21Buffer.remaining()];
    nv21Buffer.get(bytes, 0, bytes.length);

    return bytes;
  }
}
