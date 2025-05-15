// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.reset;
import static org.mockito.Mockito.when;

import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraMetadata;
import androidx.camera.camera2.interop.Camera2CameraInfo;
import androidx.camera.core.CameraInfo;
import java.util.Map;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.stubbing.Answer;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
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

  @Config(minSdk = 28)
  @SuppressWarnings("unchecked")
  @Test
  public void getCameraCharacteristic_returnsCorrespondingValueOfKeyWhenKeyNotRecognized() {
    final PigeonApiCamera2CameraInfo api =
        new TestProxyApiRegistrar().getPigeonApiCamera2CameraInfo();

    final Camera2CameraInfo instance = mock(Camera2CameraInfo.class);
    final CameraCharacteristics.Key<String> key = CameraCharacteristics.INFO_VERSION;
    final String value = "version info";
    when(instance.getCameraCharacteristic(key)).thenReturn(value);

    assertEquals(value, api.getCameraCharacteristic(instance, key));
  }

  @Config(minSdk = 21)
  @SuppressWarnings("unchecked")
  @Test
  public void getCameraCharacteristic_returnsExpectedCameraHardwareLevelWhenRequested() {
    final PigeonApiCamera2CameraInfo api =
        new TestProxyApiRegistrar().getPigeonApiCamera2CameraInfo();

    final Camera2CameraInfo instance = mock(Camera2CameraInfo.class);
    final CameraCharacteristics.Key<Integer> key =
        CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL;

    // Test known values.
    Map<Integer, InfoSupportedHardwareLevel> cameraHardwareLevelsToPigeonConstants =
        Map.of(
            CameraMetadata.INFO_SUPPORTED_HARDWARE_LEVEL_3, InfoSupportedHardwareLevel.LEVEL3,
            CameraMetadata.INFO_SUPPORTED_HARDWARE_LEVEL_EXTERNAL,
                InfoSupportedHardwareLevel.EXTERNAL,
            CameraMetadata.INFO_SUPPORTED_HARDWARE_LEVEL_FULL, InfoSupportedHardwareLevel.FULL,
            CameraMetadata.INFO_SUPPORTED_HARDWARE_LEVEL_LEGACY, InfoSupportedHardwareLevel.LEGACY,
            CameraMetadata.INFO_SUPPORTED_HARDWARE_LEVEL_LIMITED,
                InfoSupportedHardwareLevel.LIMITED);

    for (int cameraHardwareLevel : cameraHardwareLevelsToPigeonConstants.keySet()) {
      when(instance.getCameraCharacteristic(key)).thenReturn(cameraHardwareLevel);
      assertEquals(
          cameraHardwareLevelsToPigeonConstants.get(cameraHardwareLevel),
          api.getCameraCharacteristic(instance, key));
      reset(instance);
    }

    // Test unknown value.
    int testUnknownValue = -1;
    when(instance.getCameraCharacteristic(key)).thenReturn(testUnknownValue);
    assertEquals(testUnknownValue, api.getCameraCharacteristic(instance, key));
  }
}
