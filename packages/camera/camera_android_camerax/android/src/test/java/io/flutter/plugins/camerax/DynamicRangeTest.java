// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;

import androidx.camera.core.DynamicRange;
import org.junit.Test;

public class DynamicRangeTest {
  @Test
  public void sdr_returnsStandardDynamicRange() {
    final PigeonApiDynamicRange api = new TestProxyApiRegistrar().getPigeonApiDynamicRange();

    assertEquals(DynamicRange.SDR, api.sdr());
  }
}
