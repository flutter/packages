// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import androidx.camera.core.CameraInfo
import androidx.camera.core.ExposureState
import io.flutter.plugins.camerax.LiveDataProxyApi.LiveDataWrapper
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

public class CameraInfoProxyApiTest {
  @Test
  public void sensorRotationDegrees() {
    final PigeonApiCameraInfo api = new TestProxyApiRegistrar().getPigeonApiCameraInfo();

    final CameraInfo instance = mock(CameraInfo.class);
    final Long value = 0;
    when(instance.getSensorRotationDegrees()).thenReturn(value);

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

  @Test
  public void getCameraState() {
    final PigeonApiCameraInfo api = new TestProxyApiRegistrar().getPigeonApiCameraInfo();

    final CameraInfo instance = mock(CameraInfo.class);
    final io.flutter.plugins.camerax.LiveDataProxyApi.LiveDataWrapper value = mock(LiveData.class);
    when(instance.getCameraState()).thenReturn(value);

    assertEquals(value, api.getCameraState(instance ));
  }

  @Test
  public void getZoomState() {
    final PigeonApiCameraInfo api = new TestProxyApiRegistrar().getPigeonApiCameraInfo();

    final CameraInfo instance = mock(CameraInfo.class);
    final io.flutter.plugins.camerax.LiveDataProxyApi.LiveDataWrapper value = mock(LiveData.class);
    when(instance.getZoomState()).thenReturn(value);

    assertEquals(value, api.getZoomState(instance ));
  }

}
