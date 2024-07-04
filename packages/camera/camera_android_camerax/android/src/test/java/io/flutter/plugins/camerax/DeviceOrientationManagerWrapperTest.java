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

import android.app.Activity;
import io.flutter.embedding.engine.systemchannels.PlatformChannel.DeviceOrientation;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.DeviceOrientationManager.DeviceOrientationChangeCallback;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.DeviceOrientationManagerFlutterApi.Reply;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.ArgumentMatchers;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class DeviceOrientationManagerWrapperTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock DeviceOrientationManager mockDeviceOrientationManager;
  @Mock public BinaryMessenger mockBinaryMessenger;
  @Mock public InstanceManager mockInstanceManager;

  @Test
  public void deviceOrientationManagerWrapper_handlesDeviceOrientationChangesAsExpected() {
    final DeviceOrientationManagerHostApiImpl hostApi =
        new DeviceOrientationManagerHostApiImpl(mockBinaryMessenger, mockInstanceManager);
    final CameraXProxy mockCameraXProxy = mock(CameraXProxy.class);
    final Activity mockActivity = mock(Activity.class);
    final Boolean isFrontFacing = true;
    final int sensorOrientation = 90;

    DeviceOrientationManagerFlutterApiImpl flutterApi =
        mock(DeviceOrientationManagerFlutterApiImpl.class);
    hostApi.deviceOrientationManagerFlutterApiImpl = flutterApi;

    hostApi.cameraXProxy = mockCameraXProxy;
    hostApi.setActivity(mockActivity);
    when(mockCameraXProxy.createDeviceOrientationManager(
            eq(mockActivity),
            eq(isFrontFacing),
            eq(sensorOrientation),
            any(DeviceOrientationChangeCallback.class)))
        .thenReturn(mockDeviceOrientationManager);

    final ArgumentCaptor<DeviceOrientationChangeCallback> deviceOrientationChangeCallbackCaptor =
        ArgumentCaptor.forClass(DeviceOrientationChangeCallback.class);

    hostApi.startListeningForDeviceOrientationChange(
        isFrontFacing, Long.valueOf(sensorOrientation));

    // Test callback method defined in Flutter API is called when device orientation changes.
    verify(mockCameraXProxy)
        .createDeviceOrientationManager(
            eq(mockActivity),
            eq(isFrontFacing),
            eq(sensorOrientation),
            deviceOrientationChangeCallbackCaptor.capture());
    DeviceOrientationChangeCallback deviceOrientationChangeCallback =
        deviceOrientationChangeCallbackCaptor.getValue();

    deviceOrientationChangeCallback.onChange(DeviceOrientation.PORTRAIT_DOWN);
    verify(flutterApi)
        .sendDeviceOrientationChangedEvent(
            eq(DeviceOrientation.PORTRAIT_DOWN.toString()), ArgumentMatchers.<Reply<Void>>any());

    // Test that the DeviceOrientationManager starts listening for device orientation changes.
    verify(mockDeviceOrientationManager).start();

    // Test that the DeviceOrientationManager can stop listening for device orientation changes.
    hostApi.stopListeningForDeviceOrientationChange();
    verify(mockDeviceOrientationManager).stop();
  }

  @Test
  public void getDefaultDisplayRotation_returnsExpectedRotation() {
    final DeviceOrientationManagerHostApiImpl hostApi =
        new DeviceOrientationManagerHostApiImpl(mockBinaryMessenger, mockInstanceManager);
    final int defaultRotation = 180;

    hostApi.deviceOrientationManager = mockDeviceOrientationManager;
    when(mockDeviceOrientationManager.getDefaultRotation()).thenReturn(defaultRotation);

    assertEquals(hostApi.getDefaultDisplayRotation(), Long.valueOf(defaultRotation));
  }

  @Test
  public void getUiOrientation_returnsExpectedOrientation() {
    final DeviceOrientationManagerHostApiImpl hostApi =
        new DeviceOrientationManagerHostApiImpl(mockBinaryMessenger, mockInstanceManager);
    final DeviceOrientation uiOrientation = DeviceOrientation.LANDSCAPE_LEFT;

    hostApi.deviceOrientationManager = mockDeviceOrientationManager;
    when(mockDeviceOrientationManager.getUIOrientation()).thenReturn(uiOrientation);

    assertEquals(hostApi.getUiOrientation(), uiOrientation.toString());
  }
}
