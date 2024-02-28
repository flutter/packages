// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import static org.mockito.ArgumentMatchers.anyFloat;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.CaptureResult;
import android.hardware.camera2.TotalCaptureResult;
import io.flutter.plugins.camera.types.CameraCaptureProperties;
import io.flutter.plugins.camera.types.CaptureTimeoutsWrapper;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class CameraCaptureCallbackTest {

  private CameraCaptureCallback cameraCaptureCallback;
  private CameraCaptureProperties mockCaptureProps;

  @Before
  public void setUp() {
    CameraCaptureCallback.CameraCaptureStateListener mockCaptureStateListener =
        mock(CameraCaptureCallback.CameraCaptureStateListener.class);
    CaptureTimeoutsWrapper mockCaptureTimeouts = mock(CaptureTimeoutsWrapper.class);
    mockCaptureProps = mock(CameraCaptureProperties.class);
    cameraCaptureCallback =
        CameraCaptureCallback.create(
            mockCaptureStateListener, mockCaptureTimeouts, mockCaptureProps);
  }

  @Test
  public void onCaptureProgressed_doesNotUpdateCameraCaptureProperties() {
    CameraCaptureSession mockSession = mock(CameraCaptureSession.class);
    CaptureRequest mockRequest = mock(CaptureRequest.class);
    CaptureResult mockResult = mock(CaptureResult.class);

    cameraCaptureCallback.onCaptureProgressed(mockSession, mockRequest, mockResult);

    verify(mockCaptureProps, never()).setLastLensAperture(anyFloat());
    verify(mockCaptureProps, never()).setLastSensorExposureTime(anyLong());
    verify(mockCaptureProps, never()).setLastSensorSensitivity(anyInt());
  }

  @Test
  public void onCaptureCompleted_updatesCameraCaptureProperties() {
    CameraCaptureSession mockSession = mock(CameraCaptureSession.class);
    CaptureRequest mockRequest = mock(CaptureRequest.class);
    TotalCaptureResult mockResult = mock(TotalCaptureResult.class);
    when(mockResult.get(CaptureResult.LENS_APERTURE)).thenReturn(1.0f);
    when(mockResult.get(CaptureResult.SENSOR_EXPOSURE_TIME)).thenReturn(2L);
    when(mockResult.get(CaptureResult.SENSOR_SENSITIVITY)).thenReturn(3);

    cameraCaptureCallback.onCaptureCompleted(mockSession, mockRequest, mockResult);

    verify(mockCaptureProps, times(1)).setLastLensAperture(1.0f);
    verify(mockCaptureProps, times(1)).setLastSensorExposureTime(2L);
    verify(mockCaptureProps, times(1)).setLastSensorSensitivity(3);
  }

  @Test
  public void onCaptureCompleted_checksBothAutoFocusAndAutoExposure() {
    CameraCaptureSession mockSession = mock(CameraCaptureSession.class);
    CaptureRequest mockRequest = mock(CaptureRequest.class);
    TotalCaptureResult mockResult = mock(TotalCaptureResult.class);

    cameraCaptureCallback.onCaptureCompleted(mockSession, mockRequest, mockResult);

    // This is inherently somewhat fragile since it is testing internal implementation details,
    // but it is important to test that the code is actually using both of the expected states
    // since it's easy to typo one of these constants as the other. Ideally this would be tested
    // via the state machine output (CameraCaptureCallbackStatesTest.java), but testing the state
    // machine requires overriding the keys, so can't test that the right real keys are used in
    // production.
    verify(mockResult, times(1)).get(CaptureResult.CONTROL_AE_STATE);
    verify(mockResult, times(1)).get(CaptureResult.CONTROL_AF_STATE);
  }
}
