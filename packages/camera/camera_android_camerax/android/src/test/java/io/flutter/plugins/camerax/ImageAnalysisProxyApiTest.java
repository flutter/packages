// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import androidx.camera.core.ImageAnalysis
import androidx.camera.core.resolutionselector.ResolutionSelector
import androidx.camera.core.ImageAnalysis.Analyzer
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

public class ImageAnalysisProxyApiTest {
  @Test
  public void pigeon_defaultConstructor() {
    final PigeonApiImageAnalysis api = new TestProxyApiRegistrar().getPigeonApiImageAnalysis();

    assertTrue(api.pigeon_defaultConstructor(0, mock(ResolutionSelector.class)) instanceof ImageAnalysisProxyApi.ImageAnalysis);
  }

  @Test
  public void setAnalyzer() {
    final PigeonApiImageAnalysis api = new TestProxyApiRegistrar().getPigeonApiImageAnalysis();

    final ImageAnalysis instance = mock(ImageAnalysis.class);
    final androidx.camera.core.ImageAnalysis.Analyzer analyzer = mock(Analyzer.class);
    api.setAnalyzer(instance, analyzer);

    verify(instance).setAnalyzer(analyzer);
  }

  @Test
  public void clearAnalyzer() {
    final PigeonApiImageAnalysis api = new TestProxyApiRegistrar().getPigeonApiImageAnalysis();

    final ImageAnalysis instance = mock(ImageAnalysis.class);
    api.clearAnalyzer(instance );

    verify(instance).clearAnalyzer();
  }

  @Test
  public void setTargetRotation() {
    final PigeonApiImageAnalysis api = new TestProxyApiRegistrar().getPigeonApiImageAnalysis();

    final ImageAnalysis instance = mock(ImageAnalysis.class);
    final Long rotation = 0;
    api.setTargetRotation(instance, rotation);

    verify(instance).setTargetRotation(rotation);
  }

}
