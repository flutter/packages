// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.camera.core.MeteringPoint;
import org.junit.Test;

public class MeteringPointTest {
  @Test
  public void getSize_returnsExpectedSize() {
    final PigeonApiMeteringPoint api = new TestProxyApiRegistrar().getPigeonApiMeteringPoint();

    final MeteringPoint instance = mock(MeteringPoint.class);
    final double value = 1.0;
    when(instance.getSize()).thenReturn((float) value);

    assertEquals(value, api.getSize(instance), 0.1);
  }
}
