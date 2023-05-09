// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;

import androidx.camera.core.CameraState;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraStateErrorFlutterApi;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class CameraStateErrorTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public CameraState.StateError mockCameraStateError;
  @Mock public BinaryMessenger mockBinaryMessenger;
  @Mock public CameraStateErrorFlutterApi mockFlutterApi;

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
    final CameraStateErrorFlutterApiWrapper flutterApi =
        new CameraStateErrorFlutterApiWrapper(mockBinaryMessenger, instanceManager);
    flutterApi.setApi(mockFlutterApi);

    final Long code = 0L;

    flutterApi.create(mockCameraStateError, code, reply -> {});

    final long instanceIdentifier =
        Objects.requireNonNull(
            instanceManager.getIdentifierForStrongReference(mockCameraStateError));
    verify(mockFlutterApi).create(eq(instanceIdentifier), eq(code), any());
  }
}
