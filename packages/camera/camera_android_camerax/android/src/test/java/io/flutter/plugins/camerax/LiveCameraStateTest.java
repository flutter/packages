// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.camera.core.CameraState;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.Observer;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.LiveCameraStateFlutterApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.SystemServicesFlutterApi;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.ArgumentMatchers;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class LiveCameraStateTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public LiveData<CameraState> liveCameraState;
  @Mock public BinaryMessenger mockBinaryMessenger;

  InstanceManager testInstanceManager;

  @Before
  public void setUp() {
    testInstanceManager = InstanceManager.open(identifier -> {});
  }

  @After
  public void tearDown() {
    testInstanceManager.close();
  }

  @Test
  public void addObserver_addsExpectedCameraStateObesrveToLiveCameraState() {
    final LiveCameraStateHostApiImpl liveCameraStateHostApiImpl =
        new LiveCameraStateHostApiImpl(mockBinaryMessenger, testInstanceManager);
    final LiveCameraStateFlutterApiImpl mockLiveCameraStateFlutterApiImpl =
        mock(LiveCameraStateFlutterApiImpl.class);
    final SystemServicesFlutterApiImpl mockSystemServicesFlutterApiImpl =
        mock(SystemServicesFlutterApiImpl.class);
    final Long liveCameraStateIdentifier = 94L;
    final LifecycleOwner mockLifecycleOwner = mock(LifecycleOwner.class);
    final CameraXProxy mockCameraXProxy = mock(CameraXProxy.class);
    @SuppressWarnings("unchecked")
    final ArgumentCaptor<Observer<CameraState>> cameraStateObserverCaptor =
        ArgumentCaptor.forClass(Observer.class);

    testInstanceManager.addDartCreatedInstance(liveCameraState, liveCameraStateIdentifier);
    liveCameraStateHostApiImpl.setLifecycleOwner(mockLifecycleOwner);
    liveCameraStateHostApiImpl.cameraXProxy = mockCameraXProxy;

    liveCameraStateHostApiImpl.addObserver(liveCameraStateIdentifier);

    verify(liveCameraState).observe(eq(mockLifecycleOwner), cameraStateObserverCaptor.capture());

    // Test camera state observer handles onChanged callback as expected:
    Observer<CameraState> cameraStateObserver = cameraStateObserverCaptor.getValue();

    // Test case where camera is closing.
    when(mockCameraXProxy.createLiveCameraStateFlutterApiImpl(
            mockBinaryMessenger, testInstanceManager))
        .thenReturn(mockLiveCameraStateFlutterApiImpl);
    cameraStateObserver.onChanged(CameraState.create(CameraState.Type.CLOSING));
    verify(mockLiveCameraStateFlutterApiImpl)
        .sendCameraClosingEvent(ArgumentMatchers.<LiveCameraStateFlutterApi.Reply<Void>>any());

    // Test case where there is a camera state error.
    when(mockCameraXProxy.createSystemServicesFlutterApiImpl(mockBinaryMessenger))
        .thenReturn(mockSystemServicesFlutterApiImpl);
    cameraStateObserver.onChanged(
        CameraState.create(
            CameraState.Type.OPEN, CameraState.StateError.create(CameraState.ERROR_CAMERA_IN_USE)));
    verify(mockSystemServicesFlutterApiImpl)
        .sendCameraError(anyString(), ArgumentMatchers.<SystemServicesFlutterApi.Reply<Void>>any());
  }

  @Test
  public void removeObservers_removesObserversFromLiveCameraState() {
    final LiveCameraStateHostApiImpl liveCameraStateHostApiImpl =
        new LiveCameraStateHostApiImpl(mockBinaryMessenger, testInstanceManager);
    final Long liveCameraStateIdentifier = 96L;
    final LifecycleOwner mockLifecycleOwner = mock(LifecycleOwner.class);

    testInstanceManager.addDartCreatedInstance(liveCameraState, liveCameraStateIdentifier);
    liveCameraStateHostApiImpl.setLifecycleOwner(mockLifecycleOwner);

    liveCameraStateHostApiImpl.removeObservers(liveCameraStateIdentifier);

    verify(liveCameraState).removeObservers(mockLifecycleOwner);
  }

  @Test
  public void flutterApiCreate_makesCallToCreateInstanceInDart() {
    final LiveCameraStateFlutterApiImpl spyLiveCameraStateFlutterApiImpl =
        spy(new LiveCameraStateFlutterApiImpl(mockBinaryMessenger, testInstanceManager));
    spyLiveCameraStateFlutterApiImpl.create(liveCameraState, reply -> {});

    final long liveCameraStateIdentifier =
        Objects.requireNonNull(
            testInstanceManager.getIdentifierForStrongReference(liveCameraState));
    verify(spyLiveCameraStateFlutterApiImpl).create(eq(liveCameraStateIdentifier), any());
  }

  @Test
  public void flutterApiSendCameraClosingEvent_makesCallToDartCallbackMethod() {
    final LiveCameraStateFlutterApiImpl spyLiveCameraStateFlutterApiImpl =
        spy(new LiveCameraStateFlutterApiImpl(mockBinaryMessenger, testInstanceManager));
    spyLiveCameraStateFlutterApiImpl.onCameraClosing(reply -> {});
    verify(spyLiveCameraStateFlutterApiImpl).onCameraClosing(any());
  }
}
