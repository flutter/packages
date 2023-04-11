
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(bparrishMines): Remove GenApiImpls from filename or copy classes/methods to your own implementation

package io.flutter.plugins.camerax;

// TODO(bparrishMines): Import native classes
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
    instanceManager = InstanceManager.open(identifier -> {});
  }

  @After
  public void tearDown() {
    instanceManager.close();
  }

  @Test
  public void flutterApiCreate() {
    final CameraStateErrorFlutterApiWrapper flutterApi =
        new CameraStateErrorFlutterApiWrapper(mockBinaryMessenger, instanceManager);
    flutterApi.setApi(mockFlutterApi);

    final Long code = 0L;

    final String description = "testString";

    flutterApi.create(mockCameraStateError, code, description, reply -> {});

    final long instanceIdentifier =
        Objects.requireNonNull(
            instanceManager.getIdentifierForStrongReference(mockCameraStateError));
    verify(mockFlutterApi).create(eq(instanceIdentifier), eq(code), eq(description), any());
  }
}
