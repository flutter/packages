// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import androidx.camera.camera2.interop.Camera2CameraInfo
import androidx.camera.core.CameraInfo
import android.hardware.camera2.CameraCharacteristics.Key<*>
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

public class Camera2CameraInfoProxyApiTest {
  @Test
  public void from() {
    final PigeonApiCamera2CameraInfo api = new TestProxyApiRegistrar().getPigeonApiCamera2CameraInfo();

    assertTrue(api.from(mock(CameraInfo.class)) instanceof Camera2CameraInfoProxyApi.Camera2CameraInfo);
  }

  @Test
  public void getCameraId() {
    final PigeonApiCamera2CameraInfo api = new TestProxyApiRegistrar().getPigeonApiCamera2CameraInfo();

    final Camera2CameraInfo instance = mock(Camera2CameraInfo.class);
    final String value = "myString";
    when(instance.getCameraId()).thenReturn(value);

    assertEquals(value, api.getCameraId(instance ));
  }

  @Test
  public void getCameraCharacteristic() {
    final PigeonApiCamera2CameraInfo api = new TestProxyApiRegistrar().getPigeonApiCamera2CameraInfo();

    final Camera2CameraInfo instance = mock(Camera2CameraInfo.class);
    final android.hardware.camera2.CameraCharacteristics.Key<*> key = mock(CameraCharacteristicsKey.class);
    final Any value = -1;
    when(instance.getCameraCharacteristic(key)).thenReturn(value);

    assertEquals(value, api.getCameraCharacteristic(instance, key));
  }

}
