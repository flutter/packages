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
    if (planes.size() < 3) {
      throw new IllegalArgumentException(
          "The plane list must contain at least 3 planes (Y, U, V).");
    }

    PlaneProxy yPlane = planes.get(0);
    PlaneProxy uPlane = planes.get(1);
    PlaneProxy vPlane = planes.get(2);

    ByteBuffer yBuffer = yPlane.getBuffer();
    ByteBuffer uBuffer = uPlane.getBuffer();
    ByteBuffer vBuffer = vPlane.getBuffer();

    // Rewind buffers to start to ensure full read
    yBuffer.rewind();
    uBuffer.rewind();
    vBuffer.rewind();

    int ySize = yBuffer.remaining();
    byte[] nv21Buffer = new byte[ySize + (width * height / 2)];
    int position = 0;

    int yRowStride = yPlane.getRowStride();
    if (yRowStride == width) {
      // If no padding, copy entire Y plane at once
      yBuffer.get(nv21Buffer, 0, ySize);
      position = ySize;
    } else {
      // Copy row by row if padding exists
      for (int row = 0; row < height; row++) {
        yBuffer.get(nv21Buffer, position, width);
        position += width;
        if (row < height - 1) {
          yBuffer.position(yBuffer.position() - width + yRowStride);
        }
      }
    }

    int uRowStride = uPlane.getRowStride();
    int vRowStride = vPlane.getRowStride();
    int uPixelStride = uPlane.getPixelStride();
    int vPixelStride = vPlane.getPixelStride();

    byte[] uRowBuffer = new byte[uRowStride];
    byte[] vRowBuffer = new byte[vRowStride];

    for (int row = 0; row < height / 2; row++) {
      // Read full row from U and V planes into temporary buffers
      uBuffer.get(uRowBuffer, 0, Math.min(uBuffer.remaining(), uRowStride));
      vBuffer.get(vRowBuffer, 0, Math.min(vBuffer.remaining(), vRowStride));

      for (int col = 0; col < width / 2; col++) {
        int vPixelIndex = col * vPixelStride;
        int uPixelIndex = col * uPixelStride;

        nv21Buffer[position++] = vRowBuffer[vPixelIndex]; // V (Cr)
        nv21Buffer[position++] = uRowBuffer[uPixelIndex]; // U (Cb)
      }
    }

    return ByteBuffer.wrap(nv21Buffer);
  }
}
