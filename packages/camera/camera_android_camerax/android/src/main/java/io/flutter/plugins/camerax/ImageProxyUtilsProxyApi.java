// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.core.ImageProxy;
import java.nio.ByteBuffer;
import java.util.Arrays;

/**
 * ProxyApi implementation for {@link ImageProxyUtils}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
public class ImageProxyUtilsProxyApi extends PigeonApiImageProxyUtils {

  // Pre-allocated NV21 output buffer, reused across frames to avoid per-frame heap allocations.
  // Reallocated only when the image resolution changes.
  @Nullable private byte[] nv21Buffer;

  ImageProxyUtilsProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public byte[] getNv21Buffer(@NonNull ImageProxy imageProxy) {
    final int width = imageProxy.getWidth();
    final int height = imageProxy.getHeight();
    final int expectedYSize = width * height;
    final int totalSize = expectedYSize + (expectedYSize / 2);

    // Reallocate only when the resolution changes (rare).
    if (nv21Buffer == null || nv21Buffer.length != totalSize) {
      nv21Buffer = new byte[totalSize];
    }

    final ByteBuffer nv21ByteBuffer =
        ImageProxyUtils.planesToNV21(
            Arrays.asList(imageProxy.getPlanes()), width, height, nv21Buffer);

    byte[] bytes = new byte[nv21ByteBuffer.remaining()];
    nv21ByteBuffer.get(bytes, 0, bytes.length);

    return bytes;
  }
}
