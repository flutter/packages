// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import androidx.camera.core.CameraControl
import androidx.camera.core.FocusMeteringAction
import androidx.camera.core.FocusMeteringResult
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

public class CameraControlProxyApiTest {
  @Test
  public void enableTorch() {
    final PigeonApiCameraControl api = new TestProxyApiRegistrar().getPigeonApiCameraControl();

    final CameraControl instance = mock(CameraControl.class);
    final Boolean torch = true;
    api.enableTorch(instance, torch);

    verify(instance).enableTorch(torch);
  }

  @Test
  public void setZoomRatio() {
    final PigeonApiCameraControl api = new TestProxyApiRegistrar().getPigeonApiCameraControl();

    final CameraControl instance = mock(CameraControl.class);
    final Double ratio = 1.0;
    api.setZoomRatio(instance, ratio);

    verify(instance).setZoomRatio(ratio);
  }

  @Test
  public void startFocusAndMetering() {
    final PigeonApiCameraControl api = new TestProxyApiRegistrar().getPigeonApiCameraControl();

    final CameraControl instance = mock(CameraControl.class);
    final androidx.camera.core.FocusMeteringAction action = mock(FocusMeteringAction.class);
    final androidx.camera.core.FocusMeteringResult value = mock(FocusMeteringResult.class);
    when(instance.startFocusAndMetering(action)).thenReturn(value);

    assertEquals(value, api.startFocusAndMetering(instance, action));
  }

  @Test
  public void cancelFocusAndMetering() {
    final PigeonApiCameraControl api = new TestProxyApiRegistrar().getPigeonApiCameraControl();

    final CameraControl instance = mock(CameraControl.class);
    api.cancelFocusAndMetering(instance );

    verify(instance).cancelFocusAndMetering();
  }

  @Test
  public void setExposureCompensationIndex() {
    final PigeonApiCameraControl api = new TestProxyApiRegistrar().getPigeonApiCameraControl();

    final CameraControl instance = mock(CameraControl.class);
    final Long index = 0;
    final Long value = 0;
    when(instance.setExposureCompensationIndex(index)).thenReturn(value);

    assertEquals(value, api.setExposureCompensationIndex(instance, index));
  }

}
