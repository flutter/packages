// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import android.util.Size
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

public class CameraSizeProxyApiTest {
  @Test
  public void pigeon_defaultConstructor() {
    final PigeonApiCameraSize api = new TestProxyApiRegistrar().getPigeonApiCameraSize();

    assertTrue(api.pigeon_defaultConstructor() instanceof CameraSizeProxyApi.CameraSize);
  }

  @Test
  public void width() {
    final PigeonApiCameraSize api = new TestProxyApiRegistrar().getPigeonApiCameraSize();

    final CameraSize instance = mock(CameraSize.class);
    final Long value = 0;
    when(instance.getWidth()).thenReturn(value);

    assertEquals(value, api.width(instance));
  }

  @Test
  public void height() {
    final PigeonApiCameraSize api = new TestProxyApiRegistrar().getPigeonApiCameraSize();

    final CameraSize instance = mock(CameraSize.class);
    final Long value = 0;
    when(instance.getHeight()).thenReturn(value);

    assertEquals(value, api.height(instance));
  }

}
