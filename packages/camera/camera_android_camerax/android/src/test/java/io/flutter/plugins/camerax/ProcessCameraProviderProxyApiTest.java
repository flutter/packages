// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.core.UseCase
import androidx.camera.core.CameraSelector
import androidx.camera.core.CameraInfo
import androidx.camera.core.Camera
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

public class ProcessCameraProviderProxyApiTest {
  @Test
  public void getAvailableCameraInfos() {
    final PigeonApiProcessCameraProvider api = new TestProxyApiRegistrar().getPigeonApiProcessCameraProvider();

    final ProcessCameraProvider instance = mock(ProcessCameraProvider.class);
    final List<androidx.camera.core.CameraInfo> value = Arrays.asList(mock(CameraInfo.class));
    when(instance.getAvailableCameraInfos()).thenReturn(value);

    assertEquals(value, api.getAvailableCameraInfos(instance ));
  }

  @Test
  public void bindToLifecycle() {
    final PigeonApiProcessCameraProvider api = new TestProxyApiRegistrar().getPigeonApiProcessCameraProvider();

    final ProcessCameraProvider instance = mock(ProcessCameraProvider.class);
    final androidx.camera.core.CameraSelector cameraSelector = mock(CameraSelector.class);
    final List<androidx.camera.core.UseCase> useCases = Arrays.asList(mock(UseCase.class));
    final androidx.camera.core.Camera value = mock(Camera.class);
    when(instance.bindToLifecycle(cameraSelector, useCases)).thenReturn(value);

    assertEquals(value, api.bindToLifecycle(instance, cameraSelector, useCases));
  }

  @Test
  public void isBound() {
    final PigeonApiProcessCameraProvider api = new TestProxyApiRegistrar().getPigeonApiProcessCameraProvider();

    final ProcessCameraProvider instance = mock(ProcessCameraProvider.class);
    final androidx.camera.core.UseCase useCase = mock(UseCase.class);
    final Boolean value = true;
    when(instance.isBound(useCase)).thenReturn(value);

    assertEquals(value, api.isBound(instance, useCase));
  }

  @Test
  public void unbind() {
    final PigeonApiProcessCameraProvider api = new TestProxyApiRegistrar().getPigeonApiProcessCameraProvider();

    final ProcessCameraProvider instance = mock(ProcessCameraProvider.class);
    final List<androidx.camera.core.UseCase> useCases = Arrays.asList(mock(UseCase.class));
    api.unbind(instance, useCases);

    verify(instance).unbind(useCases);
  }

  @Test
  public void unbindAll() {
    final PigeonApiProcessCameraProvider api = new TestProxyApiRegistrar().getPigeonApiProcessCameraProvider();

    final ProcessCameraProvider instance = mock(ProcessCameraProvider.class);
    api.unbindAll(instance );

    verify(instance).unbindAll();
  }

}
