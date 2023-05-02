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

import androidx.camera.core.CameraInfo;
import androidx.camera.core.ExposureState;
import androidx.camera.core.ZoomState;
import androidx.lifecycle.LiveData;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class CameraInfoTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public CameraInfo mockCameraInfo;
  @Mock public BinaryMessenger mockBinaryMessenger;

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
  public void getSensorRotationDegrees_retrievesExpectedSensorRotation() {
    final CameraInfoHostApiImpl cameraInfoHostApi =
        new CameraInfoHostApiImpl(mockBinaryMessenger, testInstanceManager);

    testInstanceManager.addDartCreatedInstance(mockCameraInfo, 1);

    when(mockCameraInfo.getSensorRotationDegrees()).thenReturn(90);

    assertEquals((long) cameraInfoHostApi.getSensorRotationDegrees(1L), 90L);
    verify(mockCameraInfo).getSensorRotationDegrees();
  }

  @Test
  public void getExposureState_retrievesExpectedExposureState() {
    final CameraInfoHostApiImpl cameraInfoHostApiImpl =
        new CameraInfoHostApiImpl(mockBinaryMessenger, testInstanceManager);
    final ExposureState mockExposureState = mock(ExposureState.class);
    final Long mockCameraInfoIdentifier = 27L;
    final Long mockExposureStateIdentifier = 47L;

    testInstanceManager.addDartCreatedInstance(mockCameraInfo, mockCameraInfoIdentifier);
    testInstanceManager.addDartCreatedInstance(mockExposureState, mockExposureStateIdentifier);

    when(mockCameraInfo.getExposureState()).thenReturn(mockExposureState);

    assertEquals(
        cameraInfoHostApiImpl.getExposureState(mockCameraInfoIdentifier),
        mockExposureStateIdentifier);
    verify(mockCameraInfo).getExposureState();
  }

  @Test
  @SuppressWarnings("unchecked")
  public void getZoomState_retrievesExpectedZoomState() {
    final CameraInfoHostApiImpl cameraInfoHostApiImpl =
        new CameraInfoHostApiImpl(mockBinaryMessenger, testInstanceManager);
    final LiveData<ZoomState> mockLiveZoomState = (LiveData<ZoomState>) mock(LiveData.class);
    final ZoomState mockZoomState = mock(ZoomState.class);
    final Long mockCameraInfoIdentifier = 20L;
    final Long mockZoomStateIdentifier = 74L;

    testInstanceManager.addDartCreatedInstance(mockCameraInfo, mockCameraInfoIdentifier);
    testInstanceManager.addDartCreatedInstance(mockZoomState, mockZoomStateIdentifier);

    when(mockCameraInfo.getZoomState()).thenReturn(mockLiveZoomState);
    when(mockLiveZoomState.getValue()).thenReturn(mockZoomState);

    assertEquals(
        cameraInfoHostApiImpl.getZoomState(mockCameraInfoIdentifier), mockZoomStateIdentifier);
    verify(mockCameraInfo).getZoomState();
  }

  @Test
  public void flutterApiCreate_makesCallToCreateInstanceOnDartSide() {
    final CameraInfoFlutterApiImpl spyFlutterApi =
        spy(new CameraInfoFlutterApiImpl(mockBinaryMessenger, testInstanceManager));

    spyFlutterApi.create(mockCameraInfo, reply -> {});

    final long identifier =
        Objects.requireNonNull(testInstanceManager.getIdentifierForStrongReference(mockCameraInfo));
    verify(spyFlutterApi).create(eq(identifier), any());
  }
}
