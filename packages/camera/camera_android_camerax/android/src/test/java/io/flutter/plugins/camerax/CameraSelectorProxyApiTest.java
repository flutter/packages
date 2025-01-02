// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import androidx.camera.core.CameraSelector
import androidx.camera.core.CameraInfo
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

public class CameraSelectorProxyApiTest {
  @Test
  public void pigeon_defaultConstructor() {
    final PigeonApiCameraSelector api = new TestProxyApiRegistrar().getPigeonApiCameraSelector();

    assertTrue(api.pigeon_defaultConstructor(io.flutter.plugins.camerax.LensFacing.FRONT) instanceof CameraSelectorProxyApi.CameraSelector);
  }

  @Test
  public void filter() {
    final PigeonApiCameraSelector api = new TestProxyApiRegistrar().getPigeonApiCameraSelector();

    final CameraSelector instance = mock(CameraSelector.class);
    final List<androidx.camera.core.CameraInfo> cameraInfos = Arrays.asList(mock(CameraInfo.class));
    final List<androidx.camera.core.CameraInfo> value = Arrays.asList(mock(CameraInfo.class));
    when(instance.filter(cameraInfos)).thenReturn(value);

    assertEquals(value, api.filter(instance, cameraInfos));
  }

}
