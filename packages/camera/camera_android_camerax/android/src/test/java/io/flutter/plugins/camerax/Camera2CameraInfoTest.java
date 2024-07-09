// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraMetadata;
import androidx.camera.camera2.interop.Camera2CameraInfo;
import androidx.camera.core.CameraInfo;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.mockito.stubbing.Answer;

public class Camera2CameraInfoTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public Camera2CameraInfo mockCamera2CameraInfo;

  InstanceManager testInstanceManager;

  @Before
  public void setUp() {
    testInstanceManager = InstanceManager.create(identifier -> {});
  }

  @After
  public void tearDown() {
    testInstanceManager.stopFinalizationListener();
  }

  @Test
  public void createFrom_createsInstanceFromCameraInfoInstance() {
    final Camera2CameraInfoHostApiImpl hostApi =
        new Camera2CameraInfoHostApiImpl(mock(BinaryMessenger.class), testInstanceManager);
    final long camera2CameraInfoIdentifier = 60;
    final CameraInfo mockCameraInfo = mock(CameraInfo.class);
    final long cameraInfoIdentifier = 92;

    testInstanceManager.addDartCreatedInstance(mockCameraInfo, cameraInfoIdentifier);
    testInstanceManager.addDartCreatedInstance(mockCamera2CameraInfo, camera2CameraInfoIdentifier);

    try (MockedStatic<Camera2CameraInfo> mockedCamera2CameraInfo =
        Mockito.mockStatic(Camera2CameraInfo.class)) {
      mockedCamera2CameraInfo
          .when(() -> Camera2CameraInfo.from(mockCameraInfo))
          .thenAnswer((Answer<Camera2CameraInfo>) invocation -> mockCamera2CameraInfo);

      hostApi.createFrom(cameraInfoIdentifier);
      assertEquals(
          testInstanceManager.getInstance(camera2CameraInfoIdentifier), mockCamera2CameraInfo);
    }
  }

  @Test
  public void getSupportedHardwareLevel_returnsExpectedLevel() {
    final Camera2CameraInfoHostApiImpl hostApi =
        new Camera2CameraInfoHostApiImpl(mock(BinaryMessenger.class), testInstanceManager);
    final long camera2CameraInfoIdentifier = 3;
    final int expectedHardwareLevel = CameraMetadata.INFO_SUPPORTED_HARDWARE_LEVEL_FULL;

    testInstanceManager.addDartCreatedInstance(mockCamera2CameraInfo, camera2CameraInfoIdentifier);
    when(mockCamera2CameraInfo.getCameraCharacteristic(
            CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL))
        .thenReturn(expectedHardwareLevel);

    assertEquals(
        expectedHardwareLevel,
        hostApi.getSupportedHardwareLevel(camera2CameraInfoIdentifier).intValue());
  }

  @Test
  public void getCameraId_returnsExpectedId() {
    final Camera2CameraInfoHostApiImpl hostApi =
        new Camera2CameraInfoHostApiImpl(mock(BinaryMessenger.class), testInstanceManager);
    final long camera2CameraInfoIdentifier = 13;
    final String expectedCameraId = "testCameraId";

    testInstanceManager.addDartCreatedInstance(mockCamera2CameraInfo, camera2CameraInfoIdentifier);
    when(mockCamera2CameraInfo.getCameraId()).thenReturn(expectedCameraId);

    assertEquals(expectedCameraId, hostApi.getCameraId(camera2CameraInfoIdentifier));
  }

  @Test
  public void flutterApiCreate_makesCallToCreateInstanceOnDartSide() {
    final Camera2CameraInfoFlutterApiImpl spyFlutterApi =
        spy(new Camera2CameraInfoFlutterApiImpl(mock(BinaryMessenger.class), testInstanceManager));

    spyFlutterApi.create(mockCamera2CameraInfo, reply -> {});

    final long identifier =
        Objects.requireNonNull(
            testInstanceManager.getIdentifierForStrongReference(mockCamera2CameraInfo));
    verify(spyFlutterApi).create(eq(identifier), any());
  }
}
