// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.camera.core.ImageProxy.PlaneProxy;
import java.nio.BufferUnderflowException;
import java.nio.ByteBuffer;
import java.util.Arrays;
import java.util.List;
import org.junit.Test;
import org.mockito.Mockito;

public class ImageProxyUtilsTest {

  @Test
  public void planesToNV21_throwsExceptionForNonNV21Layout() {
    int width = 4;
    int height = 2;
    byte[] y = new byte[] {0, 1, 2, 3, 4, 5, 6, 7};

    // U and V planes are not in NV21 layout because the 2 ending
    // bytes of the U plane does not overlap with the two
    // starting bytes of the V plane.
    byte[] u = new byte[] {20, 20, 20, 20};
    byte[] v = new byte[] {30, 30, 30, 30};

    PlaneProxy yPlane = mockPlaneProxyWithData(y);
    PlaneProxy uPlane = mockPlaneProxyWithData(u);
    PlaneProxy vPlane = mockPlaneProxyWithData(v);

    List<PlaneProxy> planes = Arrays.asList(yPlane, uPlane, vPlane);

    assertThrows(
        BufferUnderflowException.class, () -> ImageProxyUtils.planesToNV21(planes, width, height));
  }

  @Test
  public void planesToNV21_returnsExpectedBufferWhenPlanesAreNV21Compatible() {
    int width = 4;
    int height = 2;

    // Y plane.
    byte[] y = new byte[] {0, 1, 2, 3, 4, 5, 6, 7};
    PlaneProxy yPlane = mockPlaneProxyWithData(y);
    when(yPlane.getPixelStride()).thenReturn(1);
    when(yPlane.getRowStride()).thenReturn(width);

    // U and V planes in NV21 format. Both have 2 bytes that are overlapping (5, 7).
    ByteBuffer vBuffer = ByteBuffer.wrap(new byte[] {9, 5, 7});
    ByteBuffer uBuffer = ByteBuffer.wrap(new byte[] {5, 7, 33});

    PlaneProxy uPlane = Mockito.mock(PlaneProxy.class);
    PlaneProxy vPlane = Mockito.mock(PlaneProxy.class);

    Mockito.when(uPlane.getBuffer()).thenReturn(uBuffer);
    Mockito.when(vPlane.getBuffer()).thenReturn(vBuffer);

    // Set pixelStride and rowStride for UV planes to trigger NV21 shortcut
    Mockito.when(uPlane.getPixelStride()).thenReturn(2);
    Mockito.when(uPlane.getRowStride()).thenReturn(width);
    Mockito.when(vPlane.getPixelStride()).thenReturn(2);
    Mockito.when(vPlane.getRowStride()).thenReturn(width);

    List<PlaneProxy> planes = Arrays.asList(yPlane, uPlane, vPlane);

    ByteBuffer nv21Buffer = ImageProxyUtils.planesToNV21(planes, width, height);
    byte[] nv21 = new byte[nv21Buffer.remaining()];
    nv21Buffer.get(nv21);

    // The planesToNV21 method copies:
    // 1. All of the Y plane bytes.
    // 2. The first byte of the V plane.
    // 3. The first three (2 * 8 / 4 - 1) bytes of the U plane.
    byte[] expected =
        new byte[] {
          0,
          1,
          2,
          3,
          4,
          5,
          6,
          7, // Y
          9,
          5,
          7,
          33 // V0, U0, U1, U2
        };

    assertArrayEquals(expected, nv21);
  }

  @Test
  public void areUVPlanesNV21_handlesVBufferAtLimitGracefully() {
    int width = 1280;
    int height = 720;

    // --- Mock Y plane ---
    byte[] yData = new byte[width * height];
    PlaneProxy yPlane = mock(PlaneProxy.class);
    ByteBuffer yBuffer = ByteBuffer.wrap(yData);
    when(yPlane.getBuffer()).thenReturn(yBuffer);
    when(yPlane.getPixelStride()).thenReturn(1);
    when(yPlane.getRowStride()).thenReturn(width);

    // --- Mock U plane ---
    ByteBuffer uBuffer = ByteBuffer.allocate(width * height / 4);
    PlaneProxy uPlane = mock(PlaneProxy.class);
    when(uPlane.getBuffer()).thenReturn(uBuffer);
    when(uPlane.getPixelStride()).thenReturn(1);
    when(uPlane.getRowStride()).thenReturn(width / 2);

    // --- Mock V plane ---
    ByteBuffer vBuffer = ByteBuffer.allocate(width * height / 4);
    vBuffer.position(vBuffer.limit()); // position == limit
    PlaneProxy vPlane = mock(PlaneProxy.class);
    when(vPlane.getBuffer()).thenReturn(vBuffer);
    when(vPlane.getPixelStride()).thenReturn(1);
    when(vPlane.getRowStride()).thenReturn(width / 2);

    List<PlaneProxy> planes = Arrays.asList(yPlane, uPlane, vPlane);

    ByteBuffer nv21Buffer = ImageProxyUtils.planesToNV21(planes, width, height);
    byte[] nv21 = new byte[nv21Buffer.remaining()];
    nv21Buffer.get(nv21);

    assertEquals(width * height + (width * height / 2), nv21.length);
  }

  // Creates a mock PlaneProxy with a buffer (of zeroes) of the given size.
  private PlaneProxy mockPlaneProxy(int bufferSize) {
    PlaneProxy plane = mock(PlaneProxy.class);
    ByteBuffer buffer = ByteBuffer.allocate(bufferSize);
    when(plane.getBuffer()).thenReturn(buffer);
    return plane;
  }

  // Creates a mock PlaneProxy with specific data.
  private PlaneProxy mockPlaneProxyWithData(byte[] data) {
    PlaneProxy plane = Mockito.mock(PlaneProxy.class);
    ByteBuffer buffer = ByteBuffer.wrap(Arrays.copyOf(data, data.length));
    when(plane.getBuffer()).thenReturn(buffer);

    // Set pixelStride and rowStride to safe defaults for tests
    // For Y plane: pixelStride = 1, rowStride = width (approximate)
    when(plane.getPixelStride()).thenReturn(1);
    when(plane.getRowStride()).thenReturn(data.length); // rowStride ≥ width

    return plane;
  }
}
