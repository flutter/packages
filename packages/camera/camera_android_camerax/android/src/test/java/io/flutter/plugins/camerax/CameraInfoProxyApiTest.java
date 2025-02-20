// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.CameraInfo;
import androidx.camera.core.CameraState;
import androidx.camera.core.ExposureState;
import androidx.camera.core.ZoomState;
import androidx.lifecycle.LiveData;

import io.flutter.plugins.camerax.LiveDataProxyApi.LiveDataWrapper;
import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import org.mockito.Mockito;
import static org.mockito.Mockito.any;
import java.util.HashMap;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class CameraInfoProxyApiTest {
  @Test
  public void sensorRotationDegrees() {
    final PigeonApiCameraInfo api = new TestProxyApiRegistrar().getPigeonApiCameraInfo();

    final CameraInfo instance = mock(CameraInfo.class);
    final long value = 0;
    when(instance.getSensorRotationDegrees()).thenReturn((int) value);

    assertEquals(value, api.sensorRotationDegrees(instance));
  }

  @Test
  public void exposureState() {
    final PigeonApiCameraInfo api = new TestProxyApiRegistrar().getPigeonApiCameraInfo();

    final CameraInfo instance = mock(CameraInfo.class);
    final androidx.camera.core.ExposureState value = mock(ExposureState.class);
    when(instance.getExposureState()).thenReturn(value);

    assertEquals(value, api.exposureState(instance));
  }

  @SuppressWarnings("unchecked")
  @Test
  public void getCameraState() {
    final PigeonApiCameraInfo api = new TestProxyApiRegistrar().getPigeonApiCameraInfo();

    final CameraInfo instance = mock(CameraInfo.class);
    final LiveData<CameraState> value = mock(LiveData.class);
    when(instance.getCameraState()).thenReturn(value);

    assertEquals(value, api.getCameraState(instance).getLiveData());
  }

    @SuppressWarnings("unchecked")
  @Test
  public void getZoomState() {
    final PigeonApiCameraInfo api = new TestProxyApiRegistrar().getPigeonApiCameraInfo();

    final CameraInfo instance = mock(CameraInfo.class);
      final LiveData<ZoomState> value = mock(LiveData.class);
    when(instance.getZoomState()).thenReturn(value);

    assertEquals(value, api.getZoomState(instance ).getLiveData());
  }

}
