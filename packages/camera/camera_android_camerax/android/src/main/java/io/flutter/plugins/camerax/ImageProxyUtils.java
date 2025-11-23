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

    // Rewind buffers to start to ensure full read.
    yBuffer.rewind();
    uBuffer.rewind();
    vBuffer.rewind();

    // Allocate a byte array for the NV21 frame.
    // NV21 = Y plane + interleaved VU plane.
    // Y = width * height; VU = (width * height) / 2 (4:2:0 subsampling).
    // If the Y plane includes padding, ySize may be larger than width*height,
    // but only the valid Y bytes are copied, so output size remains correct.
    int ySize = yBuffer.remaining();
    byte[] nv21Bytes = new byte[ySize + (width * height / 2)];
    int position = 0;

    int yRowStride = yPlane.getRowStride();
    if (yRowStride == width) {
      // If no padding, copy entire Y plane at once.
      yBuffer.get(nv21Bytes, 0, ySize);
      position = ySize;
    } else {
      // Copy row by row if padding exists.
      byte[] row = new byte[width];
      for (int rowIndex = 0; rowIndex < height; rowIndex++) {
        yBuffer.get(row, 0, width);
        System.arraycopy(row, 0, nv21Bytes, position, width);
        position += width;
        // Adjust buffer position to start of next row.
        // After reading 'width' bytes, move ahead by (yRowStride - width)
        // to skip any padding bytes at the end of the current row.
        if (rowIndex < height - 1) {
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

    // Read full row from U and V planes into temporary buffers.
    for (int row = 0; row < height / 2; row++) {
      int uRemaining = Math.min(uBuffer.remaining(), uRowStride);
      int vRemaining = Math.min(vBuffer.remaining(), vRowStride);

      uBuffer.get(uRowBuffer, 0, uRemaining);
      vBuffer.get(vRowBuffer, 0, vRemaining);

      // Interleave V and U chroma data into the NV21 buffer.
      // In NV21, chroma bytes follow the Y plane in repeating VU pairs (VUVU...).
      for (int col = 0; col < width / 2; col++) {
        int vIndex = col * vPixelStride;
        int uIndex = col * uPixelStride;
        nv21Bytes[position++] = vRowBuffer[vIndex];
        nv21Bytes[position++] = uRowBuffer[uIndex];
      }
    }

    return ByteBuffer.wrap(nv21Bytes);
  }
}
