// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.camera.core.MeteringPoint;
import androidx.camera.core.MeteringPointFactory;
import org.junit.Test;

public class MeteringPointFactoryTest {
  @Test
  public void createPoint_createsExpectedMeteringPointWithoutSizeSpecified() {
    final PigeonApiMeteringPointFactory api =
        new TestProxyApiRegistrar().getPigeonApiMeteringPointFactory();

    final MeteringPointFactory instance = mock(MeteringPointFactory.class);
    final double x = 1.0;
    final double y = 2.0;
    final androidx.camera.core.MeteringPoint value = mock(MeteringPoint.class);
    when(instance.createPoint((float) x, (float) y)).thenReturn(value);

    assertEquals(value, api.createPoint(instance, x, y));
  }

  @Test
  public void createPointWithSize_createsExpectedMeteringPointWithSizeSpecified() {
    final PigeonApiMeteringPointFactory api =
        new TestProxyApiRegistrar().getPigeonApiMeteringPointFactory();

    final MeteringPointFactory instance = mock(MeteringPointFactory.class);
    final double x = 1.0;
    final double y = 2.0;
    final double size = 3.0;
    final androidx.camera.core.MeteringPoint value = mock(MeteringPoint.class);
    when(instance.createPoint((float) x, (float) y, (float) size)).thenReturn(value);

    assertEquals(value, api.createPointWithSize(instance, x, y, size));
  }
}
