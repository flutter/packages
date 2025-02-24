// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import org.junit.Test;

public class DeviceOrientationManagerApiTest {
  @Test
  public void startListeningForDeviceOrientationChange() {
    final PigeonApiDeviceOrientationManager api =
        new TestProxyApiRegistrar().getPigeonApiDeviceOrientationManager();

    final DeviceOrientationManager instance = mock(DeviceOrientationManager.class);
    api.startListeningForDeviceOrientationChange(instance, false, 0L);

    verify(instance).start();
  }

  @Test
  public void stopListeningForDeviceOrientationChange() {
    final PigeonApiDeviceOrientationManager api =
        new TestProxyApiRegistrar().getPigeonApiDeviceOrientationManager();

    final DeviceOrientationManager instance = mock(DeviceOrientationManager.class);
    api.stopListeningForDeviceOrientationChange(instance);

    verify(instance).stop();
  }

  @Test
  public void getDefaultDisplayRotation() {
    final PigeonApiDeviceOrientationManager api =
        new TestProxyApiRegistrar().getPigeonApiDeviceOrientationManager();

    final DeviceOrientationManager instance = mock(DeviceOrientationManager.class);
    final Long value = 0L;
    when(instance.getDefaultRotation()).thenReturn(value.intValue());

    assertEquals(value, (Long) api.getDefaultDisplayRotation(instance));
  }

  @Test
  public void getUiOrientation() {
    final PigeonApiDeviceOrientationManager api =
        new TestProxyApiRegistrar().getPigeonApiDeviceOrientationManager();

    final DeviceOrientationManager instance = mock(DeviceOrientationManager.class);
    final PlatformChannel.DeviceOrientation orientation =
        PlatformChannel.DeviceOrientation.LANDSCAPE_RIGHT;
    when(instance.getUIOrientation()).thenReturn(orientation);

    assertEquals(orientation.toString(), api.getUiOrientation(instance));
  }

  @Test
  public void onDeviceOrientationChanged() {
    final DeviceOrientationManagerProxyApi mockApi = mock(DeviceOrientationManagerProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final PlatformChannel.DeviceOrientation orientation =
        PlatformChannel.DeviceOrientation.PORTRAIT_UP;
    final DeviceOrientationManager instance =
        new DeviceOrientationManager(mockApi) {
          @NonNull
          @Override
          PlatformChannel.DeviceOrientation getUIOrientation() {
            return orientation;
          }
        };
    instance.handleUIOrientationChange();

    verify(mockApi).onDeviceOrientationChanged(eq(instance), eq(orientation.toString()), any());
  }
}
