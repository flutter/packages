// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.fpsrange;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.hardware.camera2.CaptureRequest;
import android.util.Range;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.DeviceInfo;
import io.flutter.plugins.camera.types.CaptureMode;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class FpsRangeFeatureTest {
  @Before
  public void before() {
    DeviceInfo.BRAND = "Test Brand";
    DeviceInfo.MODEL = "Test Model";
  }

  @After
  public void after() {
    DeviceInfo.BRAND = null;
    DeviceInfo.MODEL = null;
  }

  @Test
  public void ctor_shouldInitializeFpsRangeWithHighestUpperValueFromRangeArray() {
    FpsRangeFeature fpsRangeFeature = createTestInstance(CaptureMode.video);
    assertEquals(13, (int) fpsRangeFeature.getValue().getUpper());
  }

  @Test
  public void getDebugName_shouldReturnTheNameOfTheFeature() {
    FpsRangeFeature fpsRangeFeature = createTestInstance(CaptureMode.video);
    assertEquals("FpsRangeFeature", fpsRangeFeature.getDebugName());
  }

  @Test
  public void getValue_shouldReturnHighestUpperRangeIfNotSet() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FpsRangeFeature fpsRangeFeature = createTestInstance(CaptureMode.video);

    assertEquals(60, (int) fpsRangeFeature.getValue().getUpper());
  }

  @Test
  public void getValue_shouldReturnNoHigherThan60fpsInPhotoMode() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FpsRangeFeature fpsRangeFeature = createTestInstance(CaptureMode.photo);

    assertEquals(30, (int) fpsRangeFeature.getValue().getUpper());
  }

  @Test
  public void getValue_shouldEchoTheSetValue() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FpsRangeFeature fpsRangeFeature = new FpsRangeFeature(mockCameraProperties);
    @SuppressWarnings("unchecked")
    Range<Integer> expectedValue = mock(Range.class);

    fpsRangeFeature.setValue(expectedValue);
    Range<Integer> actualValue = fpsRangeFeature.getValue();

    assertEquals(expectedValue, actualValue);
  }

  @Test
  public void checkIsSupported_shouldReturnTrue() {
    FpsRangeFeature fpsRangeFeature = createTestInstance(CaptureMode.video);
    assertTrue(fpsRangeFeature.checkIsSupported());
  }

  @Test
  @SuppressWarnings("unchecked")
  public void updateBuilder_shouldSetAeTargetFpsRange() {
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    FpsRangeFeature fpsRangeFeature = createTestInstance(CaptureMode.video);

    fpsRangeFeature.updateBuilder(mockBuilder);

    verify(mockBuilder).set(eq(CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE), any(Range.class));
  }

  private static FpsRangeFeature createTestInstance(CaptureMode captureMode) {
    @SuppressWarnings("unchecked")
    Range<Integer> rangeOne = mock(Range.class);
    @SuppressWarnings("unchecked")
    Range<Integer> rangeTwo = mock(Range.class);
    @SuppressWarnings("unchecked")
    Range<Integer> rangeThree = mock(Range.class);
    @SuppressWarnings("unchecked")
    Range<Integer> rangeFour = mock(Range.class);
    when(rangeOne.getUpper()).thenReturn(11);
    when(rangeTwo.getUpper()).thenReturn(12);
    when(rangeThree.getUpper()).thenReturn(13);
    when(rangeFour.getUpper()).thenReturn(60);

    // Use a wildcard, since `new Range<Integer>[] {rangeOne, rangeTwo, rangeThree}`
    // results in a 'Generic array creation' error.
    @SuppressWarnings("unchecked")
    Range<Integer>[] ranges =
        (Range<Integer>[]) new Range<?>[] {rangeOne, rangeTwo, rangeThree, rangeFour};

    CameraProperties cameraProperties = mock(CameraProperties.class);

    when(cameraProperties.getControlAutoExposureAvailableTargetFpsRanges()).thenReturn(ranges);

    return new FpsRangeFeature(cameraProperties, captureMode);
  }
}
