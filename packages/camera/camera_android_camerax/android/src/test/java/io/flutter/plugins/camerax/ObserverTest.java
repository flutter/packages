// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.camera.core.CameraState;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraStateType;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ObserverFlutterApi;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class ObserverTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public ObserverHostApiImpl.ObserverImpl<CameraState> mockObserver;

  @Mock public BinaryMessenger mockBinaryMessenger;
  @Mock public ObserverFlutterApi mockFlutterApi;
  @Mock public ObserverHostApiImpl.ObserverProxy mockProxy;

  InstanceManager instanceManager;

  @Before
  public void setUp() {
    instanceManager = InstanceManager.create(identifier -> {});
  }

  @After
  public void tearDown() {
    instanceManager.clear();
  }

  @Test
  @SuppressWarnings({"rawtypes", "unchecked"})
  public void create_createsObserverInstance() {
    final ObserverHostApiImpl hostApi =
        new ObserverHostApiImpl(mockBinaryMessenger, instanceManager, mockProxy);
    final long instanceIdentifier = 0;

    when(mockProxy.<CameraState>create(mockBinaryMessenger, instanceManager))
        .thenReturn(mockObserver);

    hostApi.create(instanceIdentifier);

    assertEquals(instanceManager.getInstance(instanceIdentifier), mockObserver);
  }

  @Test
  public void onChanged_makesCallToDartCallbackForCameraState() {
    final ObserverFlutterApiWrapper flutterApi =
        new ObserverFlutterApiWrapper(mockBinaryMessenger, instanceManager);
    final ObserverHostApiImpl.ObserverImpl<CameraState> instance =
        new ObserverHostApiImpl.ObserverImpl<CameraState>(mockBinaryMessenger, instanceManager);
    final CameraStateFlutterApiWrapper mockCameraStateFlutterApiWrapper =
        mock(CameraStateFlutterApiWrapper.class);
    final long instanceIdentifier = 0;
    final CameraState.StateError testCameraStateError =
        CameraState.StateError.create(CameraState.ERROR_CAMERA_IN_USE);
    final CameraState testCameraState =
        CameraState.create(CameraState.Type.CLOSED, testCameraStateError);
    Long mockCameraStateIdentifier = instanceManager.addHostCreatedInstance(testCameraState);

    flutterApi.setApi(mockFlutterApi);
    instance.setApi(flutterApi);
    flutterApi.cameraStateFlutterApiWrapper = mockCameraStateFlutterApiWrapper;

    instanceManager.addDartCreatedInstance(instance, instanceIdentifier);

    instance.onChanged(testCameraState);

    verify(mockFlutterApi)
        .onChanged(
            eq(instanceIdentifier), eq(Objects.requireNonNull(mockCameraStateIdentifier)), any());
    verify(mockCameraStateFlutterApiWrapper)
        .create(eq(testCameraState), eq(CameraStateType.CLOSED), eq(testCameraStateError), any());
  }
}
