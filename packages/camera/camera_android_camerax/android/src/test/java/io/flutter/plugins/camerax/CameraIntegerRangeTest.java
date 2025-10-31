// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;

import android.util.Range;
import org.junit.Test;

public class CameraIntegerRangeTest {
  @SuppressWarnings("unchecked")
  @Test
  public void pigeon_defaultConstructor_createsInstanceWithConstructorValues() {
    final PigeonApiCameraIntegerRange api =
        new TestProxyApiRegistrar().getPigeonApiCameraIntegerRange();

    final long lower = 2;
    final long upper = 1;

    final Range<Integer> instance = (Range<Integer>) api.pigeon_defaultConstructor(lower, upper);
    assertEquals((int) instance.getLower(), (int) lower);
    assertEquals((int) instance.getUpper(), (int) upper);
  }

  @Test
  public void lower_returnsValueOfLowerFromInstance() {
    final PigeonApiCameraIntegerRange api =
        new TestProxyApiRegistrar().getPigeonApiCameraIntegerRange();

    final int lower = 3;
    final Range<Integer> instance = new Range<>(lower, 4);

    assertEquals(lower, api.lower(instance));
  }

  @Test
  public void upper_returnsValueOfUpperFromInstance() {
    final PigeonApiCameraIntegerRange api =
        new TestProxyApiRegistrar().getPigeonApiCameraIntegerRange();

    final int upper = 4;
    final Range<Integer> instance = new Range<>(0, upper);

    assertEquals(upper, api.upper(instance));
  }
}
