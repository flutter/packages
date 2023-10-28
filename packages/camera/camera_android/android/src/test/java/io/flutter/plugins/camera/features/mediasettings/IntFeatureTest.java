// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.mediasettings;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.*;

import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.features.intfeature.IntFeature;
import org.junit.Test;

public class IntFeatureTest {
  @Test
  public void getDebugName_shouldReturnTheNameOfTheFeature() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    IntFeature intFeature = new IntFeature(mockCameraProperties, 10);

    assertEquals("IntFeature", intFeature.getDebugName());
  }

  @Test
  public void getValue_shouldEchoTheSetValue() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    IntFeature intFeature = new IntFeature(mockCameraProperties, 10);
    Integer expectedValue = 10;

    intFeature.setValue(expectedValue);
    Integer actualValue = intFeature.getValue();

    assertEquals(expectedValue, actualValue);
  }
}
