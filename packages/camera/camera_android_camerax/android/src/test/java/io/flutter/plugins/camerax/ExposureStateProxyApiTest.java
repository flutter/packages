// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import androidx.camera.core.ExposureState
import android.util.Range<*>
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

public class ExposureStateProxyApiTest {
  @Test
  public void exposureCompensationRange() {
    final PigeonApiExposureState api = new TestProxyApiRegistrar().getPigeonApiExposureState();

    final ExposureState instance = mock(ExposureState.class);
    final android.util.Range<*> value = mock(CameraIntegerRange.class);
    when(instance.getExposureCompensationRange()).thenReturn(value);

    assertEquals(value, api.exposureCompensationRange(instance));
  }

  @Test
  public void exposureCompensationStep() {
    final PigeonApiExposureState api = new TestProxyApiRegistrar().getPigeonApiExposureState();

    final ExposureState instance = mock(ExposureState.class);
    final Double value = 1.0;
    when(instance.getExposureCompensationStep()).thenReturn(value);

    assertEquals(value, api.exposureCompensationStep(instance));
  }

}
