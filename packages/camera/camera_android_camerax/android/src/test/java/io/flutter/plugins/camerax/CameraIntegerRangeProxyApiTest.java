// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

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

public class CameraIntegerRangeProxyApiTest {
  @Test
  public void pigeon_defaultConstructor() {
    final PigeonApiCameraIntegerRange api = new TestProxyApiRegistrar().getPigeonApiCameraIntegerRange();

    assertTrue(api.pigeon_defaultConstructor() instanceof CameraIntegerRangeProxyApi.CameraIntegerRange);
  }

  @Test
  public void lower() {
    final PigeonApiCameraIntegerRange api = new TestProxyApiRegistrar().getPigeonApiCameraIntegerRange();

    final CameraIntegerRange instance = mock(CameraIntegerRange.class);
    final Long value = 0;
    when(instance.getLower()).thenReturn(value);

    assertEquals(value, api.lower(instance));
  }

  @Test
  public void upper() {
    final PigeonApiCameraIntegerRange api = new TestProxyApiRegistrar().getPigeonApiCameraIntegerRange();

    final CameraIntegerRange instance = mock(CameraIntegerRange.class);
    final Long value = 0;
    when(instance.getUpper()).thenReturn(value);

    assertEquals(value, api.upper(instance));
  }

}
