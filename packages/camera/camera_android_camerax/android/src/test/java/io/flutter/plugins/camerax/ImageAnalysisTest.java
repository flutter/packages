// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.view.Surface;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageAnalysis.Analyzer;
import androidx.camera.core.resolutionselector.ResolutionSelector;
import androidx.core.content.ContextCompat;
import java.util.concurrent.Executor;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.stubbing.Answer;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class ImageAnalysisTest {
  @Test
  public void pigeon_defaultConstructor_createsExpectedImageAnalysisInstance() {
    final PigeonApiImageAnalysis api = new TestProxyApiRegistrar().getPigeonApiImageAnalysis();

    final ResolutionSelector mockResolutionSelector = new ResolutionSelector.Builder().build();
    final long targetResolution = Surface.ROTATION_0;
    final long outputImageFormat = ImageAnalysis.OUTPUT_IMAGE_FORMAT_NV21;
    final ImageAnalysis imageAnalysis =
        api.pigeon_defaultConstructor(mockResolutionSelector, targetResolution, outputImageFormat);

    assertEquals(imageAnalysis.getResolutionSelector(), mockResolutionSelector);
    assertEquals(imageAnalysis.getTargetRotation(), Surface.ROTATION_0);
    assertEquals(imageAnalysis.getOutputImageFormat(), ImageAnalysis.OUTPUT_IMAGE_FORMAT_NV21);
  }

  @Test
  public void resolutionSelector_returnsExpectedResolutionSelector() {
    final PigeonApiImageAnalysis api = new TestProxyApiRegistrar().getPigeonApiImageAnalysis();

    final ImageAnalysis instance = mock(ImageAnalysis.class);
    final androidx.camera.core.resolutionselector.ResolutionSelector value =
        mock(ResolutionSelector.class);
    when(instance.getResolutionSelector()).thenReturn(value);

    assertEquals(value, api.resolutionSelector(instance));
  }

  @Test
  public void setAnalyzer_makesCallToSetAnalyzerOnExpectedImageAnalysisInstance() {
    final PigeonApiImageAnalysis api = new TestProxyApiRegistrar().getPigeonApiImageAnalysis();

    final ImageAnalysis instance = mock(ImageAnalysis.class);
    final androidx.camera.core.ImageAnalysis.Analyzer analyzer = mock(Analyzer.class);

    try (MockedStatic<ContextCompat> mockedContextCompat =
        Mockito.mockStatic(ContextCompat.class)) {
      mockedContextCompat
          .when(() -> ContextCompat.getMainExecutor(any()))
          .thenAnswer((Answer<Executor>) invocation -> mock(Executor.class));

      api.setAnalyzer(instance, analyzer);

      verify(instance).setAnalyzer(any(), eq(analyzer));
    }
  }

  @Test
  public void clearAnalyzer_makesCallToClearAnalyzerOnExpectedImageAnalysisInstance() {
    final PigeonApiImageAnalysis api = new TestProxyApiRegistrar().getPigeonApiImageAnalysis();

    final ImageAnalysis instance = mock(ImageAnalysis.class);
    api.clearAnalyzer(instance);

    verify(instance).clearAnalyzer();
  }

  @Test
  public void setTargetRotation_makesCallToSetTargetRotation() {
    final PigeonApiImageAnalysis api = new TestProxyApiRegistrar().getPigeonApiImageAnalysis();

    final ImageAnalysis instance = mock(ImageAnalysis.class);
    final long rotation = Surface.ROTATION_180;
    api.setTargetRotation(instance, rotation);

    verify(instance).setTargetRotation(Surface.ROTATION_180);
  }
}
