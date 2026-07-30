// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertArrayEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.when;

import androidx.camera.core.ImageProxy;
import androidx.camera.core.ImageProxy.PlaneProxy;
import java.nio.ByteBuffer;
import java.util.Arrays;
import java.util.List;
import org.junit.Test;
import org.mockito.MockedStatic;
import org.mockito.stubbing.Answer;

public class ImageProxyUtilsApiTest {

  @Test
  public void getNv21Buffer_returnsExpectedBytes() {
    final PigeonApiImageProxyUtils api = new TestProxyApiRegistrar().getPigeonApiImageProxyUtils();

    List<PlaneProxy> planes =
        Arrays.asList(mock(PlaneProxy.class), mock(PlaneProxy.class), mock(PlaneProxy.class));
    int width = 4;
    int height = 2;
    // Matches the size allocated by getNv21Buffer: width * height * 3 / 2.
    final byte[] nv21Data = new byte[] {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12};

    try (MockedStatic<ImageProxyUtils> mockedStatic = mockStatic(ImageProxyUtils.class)) {
      // Simulate planesToNV21 filling the caller-owned outBuffer in-place.
      mockedStatic
          .when(
              () -> ImageProxyUtils.planesToNV21(anyList(), anyInt(), anyInt(), any(byte[].class)))
          .thenAnswer(
              (Answer<ByteBuffer>)
                  invocation -> {
                    byte[] outBuffer = invocation.getArgument(3);
                    System.arraycopy(nv21Data, 0, outBuffer, 0, outBuffer.length);
                    return ByteBuffer.wrap(outBuffer);
                  });

      ImageProxy imageProxy = mock(ImageProxy.class);
      PlaneProxy[] planesArray = planes.toArray(new PlaneProxy[0]);
      when(imageProxy.getPlanes()).thenReturn(planesArray);
      when(imageProxy.getWidth()).thenReturn(width);
      when(imageProxy.getHeight()).thenReturn(height);

      byte[] result = api.getNv21Buffer(imageProxy);

      assertArrayEquals(nv21Data, result);
      mockedStatic.verify(
          () ->
              ImageProxyUtils.planesToNV21(
                  eq(Arrays.asList(planesArray)),
                  eq(width),
                  eq(height),
                  any(byte[].class)));
    }
  }
}
