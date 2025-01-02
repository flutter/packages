// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import androidx.camera.core.ImageProxy.PlaneProxy
import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import org.mockito.Mockito;
import org.mockito.Mockito.any;
import java.util.HashMap;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class PlaneProxyProxyApiTest {
  @Test
  public void buffer() {
    final PigeonApiPlaneProxy api = new TestProxyApiRegistrar().getPigeonApiPlaneProxy();

    final PlaneProxy instance = mock(PlaneProxy.class);
    final ByteArray value = {0xA1};
    when(instance.getBuffer()).thenReturn(value);

    assertEquals(value, api.buffer(instance));
  }

  @Test
  public void pixelStride() {
    final PigeonApiPlaneProxy api = new TestProxyApiRegistrar().getPigeonApiPlaneProxy();

    final PlaneProxy instance = mock(PlaneProxy.class);
    final Long value = 0;
    when(instance.getPixelStride()).thenReturn(value);

    assertEquals(value, api.pixelStride(instance));
  }

  @Test
  public void rowStride() {
    final PigeonApiPlaneProxy api = new TestProxyApiRegistrar().getPigeonApiPlaneProxy();

    final PlaneProxy instance = mock(PlaneProxy.class);
    final Long value = 0;
    when(instance.getRowStride()).thenReturn(value);

    assertEquals(value, api.rowStride(instance));
  }

}
