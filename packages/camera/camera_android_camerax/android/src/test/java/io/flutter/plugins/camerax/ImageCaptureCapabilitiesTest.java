// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.camera.core.ImageCapture;
import androidx.camera.core.ImageCaptureCapabilities;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import org.junit.Test;

public class ImageCaptureCapabilitiesTest {
  @Test
  public void getSupportedOutputFormats_returnsTheCameraXValues() {
    final PigeonApiImageCaptureCapabilities api =
        new TestProxyApiRegistrar().getPigeonApiImageCaptureCapabilities();
    final ImageCaptureCapabilities instance = mock(ImageCaptureCapabilities.class);
    when(instance.getSupportedOutputFormats())
        .thenReturn(
            new HashSet<>(Collections.singletonList(ImageCapture.OUTPUT_FORMAT_JPEG_ULTRA_HDR)));

    final List<Long> result = api.getSupportedOutputFormats(instance);

    assertEquals(
        Collections.singletonList((long) ImageCapture.OUTPUT_FORMAT_JPEG_ULTRA_HDR), result);
  }
}
