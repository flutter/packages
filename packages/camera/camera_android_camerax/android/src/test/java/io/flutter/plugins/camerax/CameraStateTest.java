// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
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
    instanceManager = InstanceManager.open(identifier -> {});
  }

  @After
  public void tearDown() {
    instanceManager.close();
  }

  @Test
  public void flutterApiCreate_makesCallToDartToCreateInstance() {
    final CameraStateFlutterApiWrapper flutterApi =
        new CameraStateFlutterApiWrapper(mockBinaryMessenger, instanceManager);
    flutterApi.setApi(mockFlutterApi);

    final CameraState.Type type = CameraState.Type.OPEN;
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

    assertEquals(cameraStateTypeDataCaptor.getValue().getValue(), CameraStateType.OPEN);
  }
}

// TODO(camsim99): Test static method I added.
