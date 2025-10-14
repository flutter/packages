// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertThrows;

import androidx.camera.core.ImageProxy.PlaneProxy;
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
        IllegalArgumentException.class, () -> ImageProxyUtils.planesToNV21(planes, width, height));
  }

  @Test
  public void planesToNV21_returnsExpectedBufferWhenPlanesAreNV21Compatible() {
    int width = 4;
    int height = 2;
    int imageSize = width * height; // 8

    // Y plane.
    byte[] y = new byte[] {0, 1, 2, 3, 4, 5, 6, 7};
    PlaneProxy yPlane = mockPlaneProxyWithData(y);

    // U and V planes in NV21 format. Both have 2 bytes that are overlapping (5, 7).
    ByteBuffer vBuffer = ByteBuffer.wrap(new byte[] {9, 5, 7});
    ByteBuffer uBuffer = ByteBuffer.wrap(new byte[] {5, 7, 33});

    PlaneProxy uPlane = Mockito.mock(PlaneProxy.class);
    PlaneProxy vPlane = Mockito.mock(PlaneProxy.class);

    Mockito.when(uPlane.getBuffer()).thenReturn(uBuffer);
    Mockito.when(vPlane.getBuffer()).thenReturn(vBuffer);

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

  // Creates a mock PlaneProxy with a buffer (of zeroes) of the given size.
  private PlaneProxy mockPlaneProxy(int bufferSize) {
    PlaneProxy plane = Mockito.mock(PlaneProxy.class);
    ByteBuffer buffer = ByteBuffer.allocate(bufferSize);
    Mockito.when(plane.getBuffer()).thenReturn(buffer);
    return plane;
  }

  // Creates a mock PlaneProxy with specific data.
  private PlaneProxy mockPlaneProxyWithData(byte[] data) {
    PlaneProxy plane = Mockito.mock(PlaneProxy.class);
    ByteBuffer buffer = ByteBuffer.wrap(Arrays.copyOf(data, data.length));
    Mockito.when(plane.getBuffer()).thenReturn(buffer);
    return plane;
  }
}
