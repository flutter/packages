// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import androidx.camera.core.Preview
import androidx.camera.core.resolutionselector.ResolutionSelector
import androidx.camera.core.ResolutionInfo
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

public class PreviewProxyApiTest {
  @Test
  public void pigeon_defaultConstructor() {
    final PigeonApiPreview api = new TestProxyApiRegistrar().getPigeonApiPreview();

    assertTrue(api.pigeon_defaultConstructor(0, mock(ResolutionSelector.class)) instanceof PreviewProxyApi.Preview);
  }

  @Test
  public void setSurfaceProvider() {
    final PigeonApiPreview api = new TestProxyApiRegistrar().getPigeonApiPreview();

    final Preview instance = mock(Preview.class);
    final SystemServicesManager systemServicesManager = mock(SystemServicesManager.class);
    final Long value = 0;
    when(instance.setSurfaceProvider(systemServicesManager)).thenReturn(value);

    assertEquals(value, api.setSurfaceProvider(instance, systemServicesManager));
  }

  @Test
  public void releaseSurfaceProvider() {
    final PigeonApiPreview api = new TestProxyApiRegistrar().getPigeonApiPreview();

    final Preview instance = mock(Preview.class);
    api.releaseSurfaceProvider(instance );

    verify(instance).releaseSurfaceProvider();
  }

  @Test
  public void getResolutionInfo() {
    final PigeonApiPreview api = new TestProxyApiRegistrar().getPigeonApiPreview();

    final Preview instance = mock(Preview.class);
    final androidx.camera.core.ResolutionInfo value = mock(ResolutionInfo.class);
    when(instance.getResolutionInfo()).thenReturn(value);

    assertEquals(value, api.getResolutionInfo(instance ));
  }

  @Test
  public void setTargetRotation() {
    final PigeonApiPreview api = new TestProxyApiRegistrar().getPigeonApiPreview();

    final Preview instance = mock(Preview.class);
    final Long rotation = 0;
    api.setTargetRotation(instance, rotation);

    verify(instance).setTargetRotation(rotation);
  }

}
