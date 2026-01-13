// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import android.util.Range;
import android.util.Rational;
import androidx.camera.core.ExposureState;
import org.junit.Test;

public class ExposureStateTest {
  @SuppressWarnings("unchecked")
  @Test
  public void exposureCompensationRange_returnsExpectedRange() {
    final PigeonApiExposureState api = new TestProxyApiRegistrar().getPigeonApiExposureState();

    final ExposureState instance = mock(ExposureState.class);
    final android.util.Range<Integer> value = mock(Range.class);
    when(instance.getExposureCompensationRange()).thenReturn(value);

    assertEquals(value, api.exposureCompensationRange(instance));
  }

  @Test
  public void exposureCompensationStep_returnsExpectedStep() {
    final PigeonApiExposureState api = new TestProxyApiRegistrar().getPigeonApiExposureState();

    final ExposureState instance = mock(ExposureState.class);
    final double value = (double) 3 / 5;
    when(instance.getExposureCompensationStep()).thenReturn(new Rational(3, 5));

    assertEquals(value, api.exposureCompensationStep(instance), 0.1);
  }
}
