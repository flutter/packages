
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(bparrishMines): Remove GenApiImpls from filename or copy classes/methods to your own implementation

package io.flutter.plugins.camerax;

// TODO(bparrishMines): Import native classes
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
  public void flutterApiCreate() {
    final CameraStateFlutterApiWrapper flutterApi =
        new CameraStateFlutterApiWrapper(mockBinaryMessenger, instanceManager);
    flutterApi.setApi(mockFlutterApi);

    final CameraState.Type type = CameraState.Type.CLOSED;

    final CameraState.StateError mockError = mock(CameraState.StateError.class);

    flutterApi.create(mockCameraState, type, mockError, reply -> {});

    final long instanceIdentifier =
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(mockCameraState));
    verify(mockFlutterApi)
        .create(
            eq(instanceIdentifier),
            any(CameraStateTypeData.class),
            eq(Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(mockError))),
            any());
  }
}
