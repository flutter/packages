// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import androidx.camera.core.CameraState;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraStateFlutterApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraStateType;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraStateTypeData;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class CameraStateTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public CameraState mockCameraState;
  @Mock public BinaryMessenger mockBinaryMessenger;
  @Mock public CameraStateFlutterApi mockFlutterApi;

  InstanceManager instanceManager;

  @Before
  public void setUp() {
    instanceManager = InstanceManager.create(identifier -> {});
  }

  @After
  public void tearDown() {
    instanceManager.stopFinalizationListener();
  }

  @Test
  public void flutterApiCreate_makesCallToDartToCreateInstance() {
    final CameraStateFlutterApiWrapper flutterApi =
        new CameraStateFlutterApiWrapper(mockBinaryMessenger, instanceManager);
    flutterApi.setApi(mockFlutterApi);

    final CameraStateType type = CameraStateType.OPEN;
    final CameraState.StateError mockError = mock(CameraState.StateError.class);

    flutterApi.create(mockCameraState, type, mockError, reply -> {});

    final long instanceIdentifier =
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(mockCameraState));
    final ArgumentCaptor<CameraStateTypeData> cameraStateTypeDataCaptor =
        ArgumentCaptor.forClass(CameraStateTypeData.class);

    verify(mockFlutterApi)
        .create(
            eq(instanceIdentifier),
            cameraStateTypeDataCaptor.capture(),
            eq(Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(mockError))),
            any());

    assertEquals(cameraStateTypeDataCaptor.getValue().getValue(), type);
  }

  @Test
  public void getCameraStateType_returnsExpectedType() {
    for (CameraState.Type type : CameraState.Type.values()) {
      switch (type) {
        case CLOSED:
          assertEquals(
              CameraStateFlutterApiWrapper.getCameraStateType(type), CameraStateType.CLOSED);
          break;
        case CLOSING:
          assertEquals(
              CameraStateFlutterApiWrapper.getCameraStateType(type), CameraStateType.CLOSING);
          break;
        case OPEN:
          assertEquals(CameraStateFlutterApiWrapper.getCameraStateType(type), CameraStateType.OPEN);
          break;
        case OPENING:
          assertEquals(
              CameraStateFlutterApiWrapper.getCameraStateType(type), CameraStateType.OPENING);
          break;
        case PENDING_OPEN:
          assertEquals(
              CameraStateFlutterApiWrapper.getCameraStateType(type), CameraStateType.PENDING_OPEN);
          break;
        default:
          fail("The CameraState.Type " + type.toString() + " is unhandled by this test.");
      }
    }
  }
}
