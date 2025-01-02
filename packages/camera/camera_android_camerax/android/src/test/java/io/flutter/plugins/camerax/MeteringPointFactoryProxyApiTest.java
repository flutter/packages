// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import androidx.camera.core.MeteringPointFactory
import androidx.camera.core.MeteringPoint
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

public class MeteringPointFactoryProxyApiTest {
  @Test
  public void createPoint() {
    final PigeonApiMeteringPointFactory api = new TestProxyApiRegistrar().getPigeonApiMeteringPointFactory();

    final MeteringPointFactory instance = mock(MeteringPointFactory.class);
    final Double x = 1.0;
    final Double y = 1.0;
    final androidx.camera.core.MeteringPoint value = mock(MeteringPoint.class);
    when(instance.createPoint(x, y)).thenReturn(value);

    assertEquals(value, api.createPoint(instance, x, y));
  }

  @Test
  public void createPointWithSize() {
    final PigeonApiMeteringPointFactory api = new TestProxyApiRegistrar().getPigeonApiMeteringPointFactory();

    final MeteringPointFactory instance = mock(MeteringPointFactory.class);
    final Double x = 1.0;
    final Double y = 1.0;
    final Double size = 1.0;
    final androidx.camera.core.MeteringPoint value = mock(MeteringPoint.class);
    when(instance.createPointWithSize(x, y, size)).thenReturn(value);

    assertEquals(value, api.createPointWithSize(instance, x, y, size));
  }

}
