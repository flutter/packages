// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.Preview;
import androidx.camera.core.resolutionselector.ResolutionSelector;
import androidx.camera.core.ResolutionInfo;
import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import org.junit.runner.RunWith;
import org.mockito.Mockito;
import org.robolectric.RobolectricTestRunner;

import static org.mockito.Mockito.any;
import java.util.HashMap;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.view.Surface;

import io.flutter.view.TextureRegistry;

@RunWith(RobolectricTestRunner.class)
public class PreviewProxyApiTest {
  @Test
  public void pigeon_defaultConstructor() {
      final PigeonApiPreview api = new TestProxyApiRegistrar().getPigeonApiPreview();

      final ResolutionSelector mockResolutionSelector = new ResolutionSelector.Builder().build();
      final long targetResolution = Surface.ROTATION_0;
      final Preview instance =
              api.pigeon_defaultConstructor(mockResolutionSelector, targetResolution);

      assertEquals(instance.getResolutionSelector(), mockResolutionSelector);
      assertEquals(instance.getTargetRotation(), Surface.ROTATION_0);
  }

  @Test
  public void resolutionSelector() {
    final PigeonApiPreview api = new TestProxyApiRegistrar().getPigeonApiPreview();

    final Preview instance = mock(Preview.class);
    final androidx.camera.core.resolutionselector.ResolutionSelector value = mock(ResolutionSelector.class);
    when(instance.getResolutionSelector()).thenReturn(value);

    assertEquals(value, api.resolutionSelector(instance));
  }

  @Test
  public void setSurfaceProvider() {
    final TextureRegistry mockTextureRegistry = mock(TextureRegistry.class);
    final TextureRegistry.SurfaceProducer mockSurfaceProducer = mock(TextureRegistry.SurfaceProducer.class);
    final long textureId = 0;
    when(mockSurfaceProducer.id()).thenReturn(textureId);
    when(mockTextureRegistry.createSurfaceProducer()).thenReturn(mockSurfaceProducer);
    final PigeonApiPreview api = new TestProxyApiRegistrar() {
      @NonNull
      @Override
      TextureRegistry getTextureRegistry() {
        return mockTextureRegistry;
      }
    }.getPigeonApiPreview();

    final Preview instance = mock(Preview.class);
    final SystemServicesManager systemServicesManager = mock(SystemServicesManager.class);

    assertEquals(textureId, api.setSurfaceProvider(instance, systemServicesManager));
    verify(instance).setSurfaceProvider(any(Preview.SurfaceProvider.class));
  }

  @Test
  public void releaseSurfaceProvider_makesCallToReleaseFlutterSurfaceTexture() {
    final TextureRegistry mockTextureRegistry = mock(TextureRegistry.class);
    final TextureRegistry.SurfaceProducer mockSurfaceProducer = mock(TextureRegistry.SurfaceProducer.class);
    when(mockSurfaceProducer.id()).thenReturn(0L);
    when(mockTextureRegistry.createSurfaceProducer()).thenReturn(mockSurfaceProducer);
    final PigeonApiPreview api = new TestProxyApiRegistrar() {
      @NonNull
      @Override
      TextureRegistry getTextureRegistry() {
        return mockTextureRegistry;
      }
    }.getPigeonApiPreview();

    final Preview instance = mock(Preview.class);
    final SystemServicesManager systemServicesManager = mock(SystemServicesManager.class);
    api.setSurfaceProvider(instance, systemServicesManager);
    api.releaseSurfaceProvider(instance);

    verify(mockSurfaceProducer).release();
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
    final long rotation = 0;
    api.setTargetRotation(instance, rotation);

    verify(instance).setTargetRotation((int) rotation);
  }
}
