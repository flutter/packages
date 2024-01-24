
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(bparrishMines): Remove GenApiImpls from filename or copy classes/methods to your own implementation

package io.flutter.plugins.camerax;

// TODO(bparrishMines): Import native classes
import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.Camera2CameraControlFlutterApi;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class Camera2CameraControlTest {

  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public Camera2CameraControl mockCamera2CameraControl;

  @Mock public BinaryMessenger mockBinaryMessenger;

  @Mock public Camera2CameraControlFlutterApi mockFlutterApi;

  @Mock public Camera2CameraControlHostApiImpl.Camera2CameraControlProxy mockProxy;

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
  public void hostApiCreate() {

    final CameraControl mockCameraControl = mock(CameraControl.class);
    final long cameraControlIdentifier = 9;
    instanceManager.addDartCreatedInstance(mockCameraControl, cameraControlIdentifier);

    when(mockProxy.create(mockCameraControl)).thenReturn(mockCamera2CameraControl);

    final Camera2CameraControlHostApiImpl hostApi =
        new Camera2CameraControlHostApiImpl(mockBinaryMessenger, instanceManager, mockProxy);

    final long instanceIdentifier = 0;
    hostApi.create(instanceIdentifier, cameraControlIdentifier);

    assertEquals(instanceManager.getInstance(instanceIdentifier), mockCamera2CameraControl);
  }

  @Test
  public void addCaptureRequestOptions() {

    final CaptureRequestOptions mockCaptureRequestOptions = mock(CaptureRequestOptions.class);
    final long captureRequestOptionsIdentifier = 8;
    instanceManager.addDartCreatedInstance(
        mockCaptureRequestOptions, captureRequestOptionsIdentifier);

    final long instanceIdentifier = 0;
    instanceManager.addDartCreatedInstance(mockCamera2CameraControl, instanceIdentifier);

    final Camera2CameraControlHostApiImpl hostApi =
        new Camera2CameraControlHostApiImpl(mockBinaryMessenger, instanceManager);

    hostApi.addCaptureRequestOptions(instanceIdentifier, captureRequestOptionsIdentifier);

    verify(mockCamera2CameraControl).addCaptureRequestOptions(mockCaptureRequestOptions);
  }

  @Test
  public void flutterApiCreate() {
    final Camera2CameraControlFlutterApiImpl flutterApi =
        new Camera2CameraControlFlutterApiImpl(mockBinaryMessenger, instanceManager);
    flutterApi.setApi(mockFlutterApi);

    final CameraControl mockCameraControl = mock(CameraControl.class);

    flutterApi.create(mockCamera2CameraControl, mockCameraControl, reply -> {});

    final long instanceIdentifier =
        Objects.requireNonNull(
            instanceManager.getIdentifierForStrongReference(mockCamera2CameraControl));
    verify(mockFlutterApi)
        .create(
            eq(instanceIdentifier),
            eq(
                Objects.requireNonNull(
                    instanceManager.getIdentifierForStrongReference(mockCameraControl))),
            any());
  }
}
