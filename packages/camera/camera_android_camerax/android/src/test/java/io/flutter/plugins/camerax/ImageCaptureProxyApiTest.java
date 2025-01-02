// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import androidx.camera.core.ImageCapture
import androidx.camera.core.resolutionselector.ResolutionSelector
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

public class ImageCaptureProxyApiTest {
  @Test
  public void pigeon_defaultConstructor() {
    final PigeonApiImageCapture api = new TestProxyApiRegistrar().getPigeonApiImageCapture();

    assertTrue(api.pigeon_defaultConstructor(0, io.flutter.plugins.camerax.CameraXFlashMode.AUTO, mock(ResolutionSelector.class)) instanceof ImageCaptureProxyApi.ImageCapture);
  }

  @Test
  public void setFlashMode() {
    final PigeonApiImageCapture api = new TestProxyApiRegistrar().getPigeonApiImageCapture();

    final ImageCapture instance = mock(ImageCapture.class);
    final CameraXFlashMode flashMode = io.flutter.plugins.camerax.CameraXFlashMode.AUTO;
    api.setFlashMode(instance, flashMode);

    verify(instance).setFlashMode(flashMode);
  }

  @Test
  public void takePicture() {
    final PigeonApiImageCapture api = new TestProxyApiRegistrar().getPigeonApiImageCapture();

    final ImageCapture instance = mock(ImageCapture.class);
    final String value = "myString";
    when(instance.takePicture()).thenReturn(value);

    assertEquals(value, api.takePicture(instance ));
  }

  @Test
  public void setTargetRotation() {
    final PigeonApiImageCapture api = new TestProxyApiRegistrar().getPigeonApiImageCapture();

    final ImageCapture instance = mock(ImageCapture.class);
    final Long rotation = 0;
    api.setTargetRotation(instance, rotation);

    verify(instance).setTargetRotation(rotation);
  }

}
