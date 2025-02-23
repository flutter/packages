// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.MeteringPoint;
import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class MeteringPointTest {
  @Test
  public void getSize() {
    final PigeonApiMeteringPoint api = new TestProxyApiRegistrar().getPigeonApiMeteringPoint();

    final MeteringPoint instance = mock(MeteringPoint.class);
    final double value = 1.0;
    when(instance.getSize()).thenReturn((float) value);

    assertEquals(value, api.getSize(instance ), 0.1);
  }
}
