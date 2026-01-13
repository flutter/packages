// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.camera.core.ImageProxy.PlaneProxy;
import org.junit.Test;

public class PlaneProxyTest {
  @Test
  public void pixelStride_returnsExpectedPixelStride() {
    final PigeonApiPlaneProxy api = new TestProxyApiRegistrar().getPigeonApiPlaneProxy();

    final PlaneProxy instance = mock(PlaneProxy.class);
    final long value = 0;
    when(instance.getPixelStride()).thenReturn((int) value);

    assertEquals(value, api.pixelStride(instance));
  }

  @Test
  public void rowStride_returnsExpectedRowStride() {
    final PigeonApiPlaneProxy api = new TestProxyApiRegistrar().getPigeonApiPlaneProxy();

    final PlaneProxy instance = mock(PlaneProxy.class);
    final long value = 0;
    when(instance.getRowStride()).thenReturn((int) value);

    assertEquals(value, api.rowStride(instance));
  }
}
