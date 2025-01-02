// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax


import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import org.mockito.Mockito;
import org.mockito.Mockito.any;
import java.util.HashMap;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class DeviceOrientationManagerProxyApiTest {
  @Test
  public void pigeon_defaultConstructor() {
    final PigeonApiDeviceOrientationManager api = new TestProxyApiRegistrar().getPigeonApiDeviceOrientationManager();

    assertTrue(api.pigeon_defaultConstructor() instanceof DeviceOrientationManagerProxyApi.DeviceOrientationManager);
  }

  @Test
  public void startListeningForDeviceOrientationChange() {
    final PigeonApiDeviceOrientationManager api = new TestProxyApiRegistrar().getPigeonApiDeviceOrientationManager();

    final DeviceOrientationManager instance = mock(DeviceOrientationManager.class);
    final Boolean isFrontFacing = true;
    final Long sensorOrientation = 0;
    api.startListeningForDeviceOrientationChange(instance, isFrontFacing, sensorOrientation);

    verify(instance).startListeningForDeviceOrientationChange(isFrontFacing, sensorOrientation);
  }

  @Test
  public void stopListeningForDeviceOrientationChange() {
    final PigeonApiDeviceOrientationManager api = new TestProxyApiRegistrar().getPigeonApiDeviceOrientationManager();

    final DeviceOrientationManager instance = mock(DeviceOrientationManager.class);
    api.stopListeningForDeviceOrientationChange(instance );

    verify(instance).stopListeningForDeviceOrientationChange();
  }

  @Test
  public void getDefaultDisplayRotation() {
    final PigeonApiDeviceOrientationManager api = new TestProxyApiRegistrar().getPigeonApiDeviceOrientationManager();

    final DeviceOrientationManager instance = mock(DeviceOrientationManager.class);
    final Long value = 0;
    when(instance.getDefaultDisplayRotation()).thenReturn(value);

    assertEquals(value, api.getDefaultDisplayRotation(instance ));
  }

  @Test
  public void getUiOrientation() {
    final PigeonApiDeviceOrientationManager api = new TestProxyApiRegistrar().getPigeonApiDeviceOrientationManager();

    final DeviceOrientationManager instance = mock(DeviceOrientationManager.class);
    final String value = "myString";
    when(instance.getUiOrientation()).thenReturn(value);

    assertEquals(value, api.getUiOrientation(instance ));
  }

  @Test
  public void onDeviceOrientationChanged() {
    final DeviceOrientationManagerProxyApi mockApi = mock(DeviceOrientationManagerProxyApi.class);
    when(mockApi.pigeonRegistrar).thenReturn(new TestProxyApiRegistrar());

    final DeviceOrientationManagerImpl instance = new DeviceOrientationManagerImpl(mockApi);
    final String orientation = "myString";
    instance.onDeviceOrientationChanged(orientation);

    verify(mockApi).onDeviceOrientationChanged(eq(instance), eq(orientation), any());
  }

}
