// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.camera.core.CameraInfo;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.CameraState;
import androidx.camera.core.ExposureState;
import androidx.camera.core.ZoomState;
import androidx.lifecycle.LiveData;
import java.util.Arrays;
import java.util.List;
import org.junit.Test;

public class CameraInfoTest {
  @Test
  public void sensorRotationDegrees_makesCallToRetrieveSensorRotationDegrees() {
    final PigeonApiCameraInfo api = new TestProxyApiRegistrar().getPigeonApiCameraInfo();

    final CameraInfo instance = mock(CameraInfo.class);
    final long value = 0;
    when(instance.getSensorRotationDegrees()).thenReturn((int) value);

    assertEquals(value, api.sensorRotationDegrees(instance));
  }

  @Test
  public void lensFacing_makesCallToRetrieveLensFacing() {
    final PigeonApiCameraInfo api = new TestProxyApiRegistrar().getPigeonApiCameraInfo();

    final CameraInfo instance = mock(CameraInfo.class);
    List<Integer> testedLensFacingValues =
        Arrays.asList(
            CameraSelector.LENS_FACING_BACK,
            CameraSelector.LENS_FACING_FRONT,
            CameraSelector.LENS_FACING_EXTERNAL,
            CameraSelector.LENS_FACING_UNKNOWN);

    for (int testedLensFacingValue : testedLensFacingValues) {
      when(instance.getLensFacing()).thenReturn(testedLensFacingValue);

      LensFacing expected;
      switch (testedLensFacingValue) {
        case CameraSelector.LENS_FACING_BACK:
          expected = LensFacing.BACK;
          break;
        case CameraSelector.LENS_FACING_FRONT:
          expected = LensFacing.FRONT;
          break;
        case CameraSelector.LENS_FACING_EXTERNAL:
          expected = LensFacing.EXTERNAL;
          break;
        default:
          expected = LensFacing.UNKNOWN;
          break;
      }

      assertEquals(expected, api.lensFacing(instance));
    }
  }

  @SuppressWarnings("unchecked")
  @Test
  public void getCameraState_makesCallToRetrieveLiveCameraState() {
    final PigeonApiCameraInfo api = new TestProxyApiRegistrar().getPigeonApiCameraInfo();

    final CameraInfo instance = mock(CameraInfo.class);
    final LiveData<CameraState> value = mock(LiveData.class);
    when(instance.getCameraState()).thenReturn(value);

    assertEquals(value, api.getCameraState(instance).getLiveData());
  }

  @Test
  public void getExposureState_retrievesExpectedExposureState() {
    final PigeonApiCameraInfo api = new TestProxyApiRegistrar().getPigeonApiCameraInfo();

    final CameraInfo instance = mock(CameraInfo.class);
    final androidx.camera.core.ExposureState value = mock(ExposureState.class);
    when(instance.getExposureState()).thenReturn(value);

    assertEquals(value, api.exposureState(instance));
  }

  @SuppressWarnings("unchecked")
  @Test
  public void getZoomState_retrievesExpectedZoomState() {
    final PigeonApiCameraInfo api = new TestProxyApiRegistrar().getPigeonApiCameraInfo();

    final CameraInfo instance = mock(CameraInfo.class);
    final LiveData<ZoomState> value = mock(LiveData.class);
    when(instance.getZoomState()).thenReturn(value);

    assertEquals(value, api.getZoomState(instance).getLiveData());
  }
}
