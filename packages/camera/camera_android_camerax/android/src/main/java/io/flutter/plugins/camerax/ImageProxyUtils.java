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
   *
   * <p>The result is written into {@code outBuffer}, which must have a capacity of at least {@code
   * width * height * 3 / 2} bytes. Passing a pre-allocated, reusable buffer avoids per-frame heap
   * allocations and reduces GC pressure in high-throughput camera pipelines.
   *
   * @param planes the YUV_420_888 planes (Y at index 0, U at 1, V at 2).
   * @param width image width in pixels.
   * @param height image height in pixels.
   * @param outBuffer caller-owned buffer that receives the NV21 data; must be large enough.
   * @return a {@link ByteBuffer} wrapping {@code outBuffer} with position 0 and limit set to the
   *     number of bytes written ({@code width * height * 3 / 2}).
   */
  @NonNull
  public static ByteBuffer planesToNV21(
      @NonNull List<PlaneProxy> planes, int width, int height, @NonNull byte[] outBuffer) {
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

    // Rewind buffers to start to ensure full read.
    yBuffer.rewind();
    uBuffer.rewind();
    vBuffer.rewind();

    int expectedYSize = width * height;
    int position = 0;

    int yRowStride = yPlane.getRowStride();
    if (yRowStride == width) {
      // If no padding, copy entire Y plane at once.
      yBuffer.get(outBuffer, 0, expectedYSize);
      position = expectedYSize;
    } else {
      // Copy row by row, reading directly into outBuffer to avoid a temporary array.
      for (int rowIndex = 0; rowIndex < height; rowIndex++) {
        yBuffer.get(outBuffer, position, width);
        position += width;
        // Skip padding bytes to advance to the start of the next row.
        // On the last row this seeks past the limit, which is harmless because
        // yBuffer is not read again after the loop.
        yBuffer.position(yBuffer.position() - width + yRowStride);
      }
    }

    int uRowStride = uPlane.getRowStride();
    int vRowStride = vPlane.getRowStride();
    int uPixelStride = uPlane.getPixelStride();
    int vPixelStride = vPlane.getPixelStride();

    byte[] uRowBuffer = new byte[uRowStride];
    byte[] vRowBuffer = new byte[vRowStride];

    // Read full row from U and V planes into temporary buffers.
    for (int row = 0; row < height / 2; row++) {
      int uRemaining = Math.min(uBuffer.remaining(), uRowStride);
      int vRemaining = Math.min(vBuffer.remaining(), vRowStride);

      uBuffer.get(uRowBuffer, 0, uRemaining);
      vBuffer.get(vRowBuffer, 0, vRemaining);

      // Interleave V and U chroma data into the NV21 buffer.
      // In NV21, chroma bytes follow the Y plane in repeating VU pairs (VUVU...).
      for (int col = 0; col < width / 2; col++) {
        outBuffer[position++] = vRowBuffer[col * vPixelStride];
        outBuffer[position++] = uRowBuffer[col * uPixelStride];
      }
    }

    return ByteBuffer.wrap(outBuffer, 0, expectedYSize + (expectedYSize / 2));
  }

  /**
   * Converts list of {@link PlaneProxy}s in YUV_420_888 format (with VU planes in NV21 layout) to a
   * single NV21 {@code ByteBuffer}.
   *
   * <p>Allocates a new output buffer sized {@code width * height * 3 / 2} bytes on every call. For
   * hot paths such as per-frame camera callbacks, prefer {@link #planesToNV21(List, int, int,
   * byte[])} with a pre-allocated, reusable buffer to reduce GC pressure.
   *
   * @param planes the YUV_420_888 planes (Y at index 0, U at 1, V at 2).
   * @param width image width in pixels.
   * @param height image height in pixels.
   * @return a {@link ByteBuffer} containing the NV21 data with a capacity of {@code width * height
   *     * 3 / 2} bytes.
   */
  @NonNull
  public static ByteBuffer planesToNV21(@NonNull List<PlaneProxy> planes, int width, int height) {
    int expectedYSize = width * height;
    byte[] outBuffer = new byte[expectedYSize + (expectedYSize / 2)];
    return planesToNV21(planes, width, height, outBuffer);
  }
}
