// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.ImageProxy.PlaneProxy;
import java.nio.ByteBuffer;
import java.util.List;

/* Utilities for working with {@code ImageProxy}s. */
public class ImageProxyUtils {

  /**
   * Converts list of {@link PlaneProxy}s in YUV_420_888 format (with VU planes in NV21 layout) to a
   * single NV21 {@code ByteBuffer}.
   */
  @NonNull
  public static ByteBuffer planesToNV21(@NonNull List<PlaneProxy> planes, int width, int height) {
    if (!areUVPlanesNV21(planes, width, height)) {
      throw new IllegalArgumentException(
          "Provided UV planes are not in NV21 layout and thus cannot be converted.");
    }

    int imageSize = width * height;
    int nv21Size = imageSize + 2 * (imageSize / 4);
    byte[] nv21Bytes = new byte[nv21Size];

    // Copy Y plane.
    ByteBuffer yBuffer = planes.get(0).getBuffer();
    yBuffer.rewind();
    yBuffer.get(nv21Bytes, 0, imageSize);

    // Copy interleaved VU plane (NV21 layout).
    ByteBuffer vBuffer = planes.get(2).getBuffer();
    ByteBuffer uBuffer = planes.get(1).getBuffer();

    vBuffer.rewind();
    uBuffer.rewind();
    vBuffer.get(nv21Bytes, imageSize, 1);
    uBuffer.get(nv21Bytes, imageSize + 1, 2 * imageSize / 4 - 1);

    return ByteBuffer.wrap(nv21Bytes);
  }

  public static boolean areUVPlanesNV21(@NonNull List<PlaneProxy> planes, int width, int height) {
    int imageSize = width * height;

    ByteBuffer uBuffer = planes.get(1).getBuffer();
    ByteBuffer vBuffer = planes.get(2).getBuffer();

    // Backup buffer properties.
    int vBufferPosition = vBuffer.position();
    int uBufferLimit = uBuffer.limit();

    // Advance the V buffer by 1 byte, since the U buffer will not contain the first V value.
    vBuffer.position(vBufferPosition + 1);
    // Chop off the last byte of the U buffer, since the V buffer will not contain the last U value.
    uBuffer.limit(uBufferLimit - 1);

    // Check that the buffers are equal and have the expected number of elements.
    boolean areNV21 =
        (vBuffer.remaining() == (2 * imageSize / 4 - 2)) && (vBuffer.compareTo(uBuffer) == 0);

    // Restore buffers to their initial state.
    vBuffer.position(vBufferPosition);
    uBuffer.limit(uBufferLimit);

    return areNV21;
  }
}
