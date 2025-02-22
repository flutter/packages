// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.util.Size;
import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class CameraSizeTest {
  @Test
  public void pigeon_defaultConstructor() {
    final PigeonApiCameraSize api = new TestProxyApiRegistrar().getPigeonApiCameraSize();

    final int width = 6;
    final int height = 7;
    final Size instance = api.pigeon_defaultConstructor(width, height);

    assertEquals(instance.getWidth(), width);
    assertEquals(instance.getHeight(), height);
  }

  @Test
  public void width() {
    final PigeonApiCameraSize api = new TestProxyApiRegistrar().getPigeonApiCameraSize();

    final Size instance = mock(Size.class);
    final int value = 0;
    when(instance.getWidth()).thenReturn(value);

    assertEquals(value, api.width(instance));
  }

  @Test
  public void height() {
    final PigeonApiCameraSize api = new TestProxyApiRegistrar().getPigeonApiCameraSize();

    final Size instance = mock(Size.class);
    final int value = 0;
    when(instance.getHeight()).thenReturn(value);

    assertEquals(value, api.height(instance));
  }

}
