// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.camera.core.Camera;
import androidx.camera.core.CameraControl;
import androidx.camera.core.CameraInfo;
import org.junit.Test;

public class CameraTest {
  @Test
  public void cameraInfo_retrievesExpectedCameraInfoInstance() {
    final PigeonApiCamera api = new TestProxyApiRegistrar().getPigeonApiCamera();

    final Camera instance = mock(Camera.class);
    final androidx.camera.core.CameraInfo value = mock(CameraInfo.class);
    when(instance.getCameraInfo()).thenReturn(value);

    assertEquals(value, api.getCameraInfo(instance));
  }

  @Test
  public void getCameraControl_retrievesExpectedCameraControlInstance() {
    final PigeonApiCamera api = new TestProxyApiRegistrar().getPigeonApiCamera();

    final Camera instance = mock(Camera.class);
    final androidx.camera.core.CameraControl value = mock(CameraControl.class);
    when(instance.getCameraControl()).thenReturn(value);

    assertEquals(value, api.cameraControl(instance));
  }
}
