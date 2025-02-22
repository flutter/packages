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

public class CameraStateStateErrorTest {
  @Test
  public void code() {
    final PigeonApiCameraStateStateError api = new TestProxyApiRegistrar().getPigeonApiCameraStateStateError();

    final CameraState.StateError instance = mock(CameraState.StateError.class);
    final int value = CameraState.ERROR_CAMERA_DISABLED;
    when(instance.getCode()).thenReturn(value);

    assertEquals(io.flutter.plugins.camerax.CameraStateErrorCode.CAMERA_DISABLED, api.code(instance));
  }
}
