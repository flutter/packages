// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import androidx.camera.core.ImageAnalysis.Analyzer
import androidx.camera.core.ImageProxy
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

public class AnalyzerProxyApiTest {
  @Test
  public void pigeon_defaultConstructor() {
    final PigeonApiAnalyzer api = new TestProxyApiRegistrar().getPigeonApiAnalyzer();

    assertTrue(api.pigeon_defaultConstructor() instanceof AnalyzerProxyApi.AnalyzerImpl);
  }

  @Test
  public void analyze() {
    final AnalyzerProxyApi mockApi = mock(AnalyzerProxyApi.class);
    when(mockApi.pigeonRegistrar).thenReturn(new TestProxyApiRegistrar());

    final AnalyzerImpl instance = new AnalyzerImpl(mockApi);
    final androidx.camera.core.ImageProxy image = mock(ImageProxy.class);
    instance.analyze(image);

    verify(mockApi).analyze(eq(instance), eq(image), any());
  }

}
