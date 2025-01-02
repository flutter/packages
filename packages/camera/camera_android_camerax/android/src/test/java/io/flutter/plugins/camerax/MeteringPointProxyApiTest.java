// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

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

public class MeteringPointProxyApiTest {
  @Test
  public void getSize() {
    final PigeonApiMeteringPoint api = new TestProxyApiRegistrar().getPigeonApiMeteringPoint();

    final MeteringPoint instance = mock(MeteringPoint.class);
    final Double value = 1.0;
    when(instance.getSize()).thenReturn(value);

    assertEquals(value, api.getSize(instance ));
  }

}
