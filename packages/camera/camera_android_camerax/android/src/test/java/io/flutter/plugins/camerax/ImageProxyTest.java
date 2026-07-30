// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.camera.core.ImageProxy;
import androidx.camera.core.ImageProxy.PlaneProxy;
import java.nio.ByteBuffer;
import java.util.List;
import org.junit.Test;

public class ImageProxyTest {
  @Test
  public void format_returnsExpectedFormat() {
    final PigeonApiImageProxy api = new TestProxyApiRegistrar().getPigeonApiImageProxy();

    final ImageProxy instance = mock(ImageProxy.class);
    final long value = 0;
    when(instance.getFormat()).thenReturn((int) value);

    assertEquals(value, api.format(instance));
  }

  @Test
  public void width_returnsExpectedWidth() {
    final PigeonApiImageProxy api = new TestProxyApiRegistrar().getPigeonApiImageProxy();

    final ImageProxy instance = mock(ImageProxy.class);
    final long value = 0;
    when(instance.getWidth()).thenReturn((int) value);

    assertEquals(value, api.width(instance));
  }

  @Test
  public void height_returnsExpectedHeight() {
    final PigeonApiImageProxy api = new TestProxyApiRegistrar().getPigeonApiImageProxy();

    final ImageProxy instance = mock(ImageProxy.class);
    final long value = 0;
    when(instance.getHeight()).thenReturn((int) value);

    assertEquals(value, api.height(instance));
  }

  @Test
  public void getPlanes_returnsExpectedPlanes() {
    final PigeonApiImageProxy api = new TestProxyApiRegistrar().getPigeonApiImageProxy();

    final ImageProxy instance = mock(ImageProxy.class);
    when(instance.getHeight()).thenReturn(4);

    final PlaneProxy mockPlane0 = mock(PlaneProxy.class);
    final PlaneProxy mockPlane1 = mock(PlaneProxy.class);

    when(mockPlane0.getRowStride()).thenReturn(10);
    when(mockPlane0.getPixelStride()).thenReturn(1);
    // Y plane buffer with some extra padding
    ByteBuffer buffer0 = ByteBuffer.allocate(100);
    when(mockPlane0.getBuffer()).thenReturn(buffer0);

    when(mockPlane1.getRowStride()).thenReturn(5);
    when(mockPlane1.getPixelStride()).thenReturn(2);
    // U/V plane buffer
    ByteBuffer buffer1 = ByteBuffer.allocate(50);
    when(mockPlane1.getBuffer()).thenReturn(buffer1);

    when(instance.getPlanes()).thenReturn(new PlaneProxy[] {mockPlane0, mockPlane1});

    List<PlaneProxy> planes = api.getPlanes(instance);
    assertEquals(2, planes.size());

    // Verify Y plane wrapping
    PlaneProxy plane0 = planes.get(0);
    assertEquals(10, plane0.getRowStride());
    assertEquals(1, plane0.getPixelStride());

    ByteBuffer wrappedBuffer0 = plane0.getBuffer();
    // expected size: planeHeight * rowStride = 4 * 10 = 40
    assertEquals(40, wrappedBuffer0.remaining());

    // Verify U/V plane wrapping
    PlaneProxy plane1 = planes.get(1);
    assertEquals(5, plane1.getRowStride());
    assertEquals(2, plane1.getPixelStride());

    ByteBuffer wrappedBuffer1 = plane1.getBuffer();
    // expected size: (planeHeight / 2) * rowStride = 2 * 5 = 10
    assertEquals(10, wrappedBuffer1.remaining());
  }

  @Test
  public void close_callsCloseOnInstance() {
    final PigeonApiImageProxy api = new TestProxyApiRegistrar().getPigeonApiImageProxy();

    final ImageProxy instance = mock(ImageProxy.class);
    api.close(instance);

    verify(instance).close();
  }
}
