// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.camera.core.ZoomState;
import org.junit.Test;

public class ZoomStateTest {
  @Test
  public void minZoomRatio_returnsExpectedMinZoomRatio() {
    final PigeonApiZoomState api = new TestProxyApiRegistrar().getPigeonApiZoomState();

    final ZoomState instance = mock(ZoomState.class);
    final double value = 1.0;
    when(instance.getMinZoomRatio()).thenReturn((float) value);

    assertEquals(value, api.minZoomRatio(instance), 0.1);
  }

  @Test
  public void maxZoomRatio_returnsExpectedMaxZoomRatio() {
    final PigeonApiZoomState api = new TestProxyApiRegistrar().getPigeonApiZoomState();

    final ZoomState instance = mock(ZoomState.class);
    final double value = 1.0;
    when(instance.getMaxZoomRatio()).thenReturn((float) value);

    assertEquals(value, api.maxZoomRatio(instance), 0.1);
  }
}
