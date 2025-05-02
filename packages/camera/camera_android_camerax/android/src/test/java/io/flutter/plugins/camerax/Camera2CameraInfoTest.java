// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import android.hardware.camera2.CameraCharacteristics;
import androidx.camera.camera2.interop.Camera2CameraInfo;
import androidx.camera.core.CameraInfo;
import org.junit.Test;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.stubbing.Answer;

public class Camera2CameraInfoTest {
  @Test
  public void from_createsInstanceFromCameraInfoInstance() {
    final PigeonApiCamera2CameraInfo api =
        new TestProxyApiRegistrar().getPigeonApiCamera2CameraInfo();

    final CameraInfo mockCameraInfo = mock(CameraInfo.class);
    final Camera2CameraInfo mockCamera2CameraInfo = mock(Camera2CameraInfo.class);

    try (MockedStatic<Camera2CameraInfo> mockedCamera2CameraInfo =
        Mockito.mockStatic(Camera2CameraInfo.class)) {
      mockedCamera2CameraInfo
          .when(() -> Camera2CameraInfo.from(mockCameraInfo))
          .thenAnswer((Answer<Camera2CameraInfo>) invocation -> mockCamera2CameraInfo);

      assertEquals(api.from(mockCameraInfo), mockCamera2CameraInfo);
    }
  }

  @Test
  public void getCameraId_returnsExpectedId() {
    final PigeonApiCamera2CameraInfo api =
        new TestProxyApiRegistrar().getPigeonApiCamera2CameraInfo();

    final Camera2CameraInfo instance = mock(Camera2CameraInfo.class);
    final String value = "myString";
    when(instance.getCameraId()).thenReturn(value);

    assertEquals(value, api.getCameraId(instance));
  }

  @SuppressWarnings("unchecked")
  @Test
  public void getCameraCharacteristic_returnsCorrespondingValueOfKey() {
    final PigeonApiCamera2CameraInfo api =
        new TestProxyApiRegistrar().getPigeonApiCamera2CameraInfo();

    final Camera2CameraInfo instance = mock(Camera2CameraInfo.class);
    final CameraCharacteristics.Key<Integer> key = mock(CameraCharacteristics.Key.class);
    final int value = -1;
    when(instance.getCameraCharacteristic(key)).thenReturn(value);

    assertEquals(value, api.getCameraCharacteristic(instance, key));
  }
}
