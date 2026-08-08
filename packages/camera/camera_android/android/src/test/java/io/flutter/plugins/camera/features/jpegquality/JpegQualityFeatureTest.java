// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.jpegquality;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import android.hardware.camera2.CaptureRequest;
import io.flutter.plugins.camera.CameraProperties;
import org.junit.Test;

public class JpegQualityFeatureTest {
  @Test
  public void getDebugName_shouldReturnTheNameOfTheFeature() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    JpegQualityFeature jpegQualityFeature = new JpegQualityFeature(mockCameraProperties);

    assertEquals("JpegQualityFeature", jpegQualityFeature.getDebugName());
  }

  @Test
  public void getValue_shouldReturn100IfNotSet() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    JpegQualityFeature jpegQualityFeature = new JpegQualityFeature(mockCameraProperties);

    assertEquals(Integer.valueOf(100), jpegQualityFeature.getValue());
  }

  @Test
  public void getValue_shouldEchoTheSetValue() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    JpegQualityFeature jpegQualityFeature = new JpegQualityFeature(mockCameraProperties);

    jpegQualityFeature.setValue(50);
    assertEquals(Integer.valueOf(50), jpegQualityFeature.getValue());
  }

  @Test
  public void checkIsSupported_shouldReturnTrue() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    JpegQualityFeature jpegQualityFeature = new JpegQualityFeature(mockCameraProperties);

    assertTrue(jpegQualityFeature.checkIsSupported());
  }

  @Test
  public void updateBuilder_shouldSetJpegQualityOnBuilder() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    JpegQualityFeature jpegQualityFeature = new JpegQualityFeature(mockCameraProperties);

    jpegQualityFeature.setValue(75);
    jpegQualityFeature.updateBuilder(mockBuilder);

    verify(mockBuilder, times(1)).set(CaptureRequest.JPEG_QUALITY, (byte) 75);
  }

  @Test
  public void updateBuilder_shouldSetDefaultQualityWhenNotExplicitlySet() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    JpegQualityFeature jpegQualityFeature = new JpegQualityFeature(mockCameraProperties);

    jpegQualityFeature.updateBuilder(mockBuilder);

    verify(mockBuilder, times(1)).set(CaptureRequest.JPEG_QUALITY, (byte) 100);
  }
}
