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

public class ImageProxyUtilsApiTest {

  @Test
  public void getNv21Buffer_returnsExpectedBytes() {
    final PigeonApiImageProxyUtils api = new TestProxyApiRegistrar().getPigeonApiImageProxyUtils();

    List<PlaneProxy> planes =
        Arrays.asList(mock(PlaneProxy.class), mock(PlaneProxy.class), mock(PlaneProxy.class));
    long width = 4;
    long height = 2;
    byte[] expectedBytes = new byte[] {1, 2, 3, 4, 5};
    ByteBuffer mockBuffer = ByteBuffer.wrap(expectedBytes);

    try (MockedStatic<ImageProxyUtils> mockedStatic = mockStatic(ImageProxyUtils.class)) {
      mockedStatic
          .when(
              () -> ImageProxyUtils.planesToNV21(anyList(), anyInt(), anyInt(), any(byte[].class)))
          .thenReturn(mockBuffer);

      ImageProxy imageProxy = mock(ImageProxy.class);
      PlaneProxy[] planesArray = planes.toArray(new PlaneProxy[0]);
      when(imageProxy.getPlanes()).thenReturn(planesArray);
      when(imageProxy.getWidth()).thenReturn((int) width);
      when(imageProxy.getHeight()).thenReturn((int) height);

      byte[] result = api.getNv21Buffer(imageProxy);

      assertArrayEquals(expectedBytes, result);
      mockedStatic.verify(
          () ->
              ImageProxyUtils.planesToNV21(
                  eq(Arrays.asList(planesArray)),
                  eq((int) width),
                  eq((int) height),
                  any(byte[].class)));
    }
  }
}
