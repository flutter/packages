// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.camera.core.CameraInfo;
import androidx.camera.core.CameraSelector;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import org.junit.Test;

public class CameraSelectorTest {
  @Test
  public void pigeon_defaultConstructor_createsCameraSelectorInstanceWithLensFacing() {
    final PigeonApiCameraSelector api = new TestProxyApiRegistrar().getPigeonApiCameraSelector();
    final CameraSelector selector =
        api.pigeon_defaultConstructor(io.flutter.plugins.camerax.LensFacing.FRONT, null);

    assertEquals(selector.getLensFacing(), (Integer) CameraSelector.LENS_FACING_FRONT);
  }

  @Test
  public void pigeon_defaultConstructor_createsCameraSelectorInstanceWithCameraInfo() {
    final PigeonApiCameraSelector api = new TestProxyApiRegistrar().getPigeonApiCameraSelector();
    final androidx.camera.core.CameraInfo cameraInfo = mock(CameraInfo.class);
    final androidx.camera.core.CameraInfo cameraInfoToSelect = mock(CameraInfo.class);

    final CameraSelector selector = api.pigeon_defaultConstructor(null, cameraInfoToSelect);

    final List<androidx.camera.core.CameraInfo> cameraInfosList = new ArrayList<>();
    cameraInfosList.add(cameraInfo);
    cameraInfosList.add(cameraInfoToSelect);

    final List<androidx.camera.core.CameraInfo> filteredCameraInfosList =
        selector.filter(new ArrayList<>(cameraInfosList));
    assertEquals(1, filteredCameraInfosList.size());
    assertEquals(cameraInfoToSelect, filteredCameraInfosList.get(0));
  }

  @Test
  public void filter_callsFilterWithMethodParameters() {
    final PigeonApiCameraSelector api = new TestProxyApiRegistrar().getPigeonApiCameraSelector();

    final CameraSelector instance = mock(CameraSelector.class);

    final List<androidx.camera.core.CameraInfo> cameraInfos =
        Collections.singletonList(mock(CameraInfo.class));
    final List<androidx.camera.core.CameraInfo> value =
        Collections.singletonList(mock(CameraInfo.class));
    when(instance.filter(cameraInfos)).thenReturn(value);

    assertEquals(value, api.filter(instance, cameraInfos));
  }
}
