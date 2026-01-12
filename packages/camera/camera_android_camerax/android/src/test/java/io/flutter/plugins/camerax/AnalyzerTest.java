// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.camera.core.ImageProxy;
import org.junit.Test;

public class AnalyzerTest {
  @Test
  public void pigeon_defaultConstructor_makesCallToCreateAnalyzerInstance() {
    final PigeonApiAnalyzer api = new TestProxyApiRegistrar().getPigeonApiAnalyzer();

    assertTrue(api.pigeon_defaultConstructor() instanceof AnalyzerProxyApi.AnalyzerImpl);
  }

  @Test
  public void analyze_makesCallToDartAnalyze() {
    final AnalyzerProxyApi mockApi = mock(AnalyzerProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final AnalyzerProxyApi.AnalyzerImpl instance = new AnalyzerProxyApi.AnalyzerImpl(mockApi);
    final androidx.camera.core.ImageProxy image = mock(ImageProxy.class);
    instance.analyze(image);

    verify(mockApi).analyze(eq(instance), eq(image), any());
  }
}
