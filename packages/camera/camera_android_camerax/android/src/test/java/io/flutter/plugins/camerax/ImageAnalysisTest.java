// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.resolutionselector.ResolutionSelector;
import androidx.camera.core.ImageAnalysis.Analyzer;
import androidx.core.content.ContextCompat;

import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import org.junit.runner.RunWith;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.stubbing.Answer;
import org.robolectric.RobolectricTestRunner;

import static org.mockito.Mockito.any;

import java.util.concurrent.Executor;

import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.view.Surface;

@RunWith(RobolectricTestRunner.class)
public class ImageAnalysisTest {
  @Test
  public void pigeon_defaultConstructor() {
    final PigeonApiImageAnalysis api = new TestProxyApiRegistrar().getPigeonApiImageAnalysis();

    final ResolutionSelector mockResolutionSelector = new ResolutionSelector.Builder().build();
    final long targetResolution = Surface.ROTATION_0;
    final ImageAnalysis imageAnalysis = api.pigeon_defaultConstructor(mockResolutionSelector, targetResolution);

    assertEquals(imageAnalysis.getResolutionSelector(), mockResolutionSelector);
    assertEquals(imageAnalysis.getTargetRotation(), Surface.ROTATION_0);
  }

  @Test
  public void resolutionSelector() {
    final PigeonApiImageAnalysis api = new TestProxyApiRegistrar().getPigeonApiImageAnalysis();

    final ImageAnalysis instance = mock(ImageAnalysis.class);
    final androidx.camera.core.resolutionselector.ResolutionSelector value = mock(ResolutionSelector.class);
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
    api.clearAnalyzer(instance );

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
