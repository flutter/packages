// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.CameraState;

import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class CameraStateTest {
  @Test
  public void type() {
    final PigeonApiCameraState api = new TestProxyApiRegistrar().getPigeonApiCameraState();

    final CameraState instance = mock(CameraState.class);
    final CameraState.Type value = CameraState.Type.CLOSED;
    when(instance.getType()).thenReturn(value);

    assertEquals(io.flutter.plugins.camerax.CameraStateType.CLOSED, api.type(instance));
  }

  @Test
  public void error() {
    final PigeonApiCameraState api = new TestProxyApiRegistrar().getPigeonApiCameraState();

    final CameraState instance = mock(CameraState.class);
    final androidx.camera.core.CameraState.StateError value = mock(CameraState.StateError.class);
    when(instance.getError()).thenReturn(value);

    assertEquals(value, api.error(instance));
  }
}
