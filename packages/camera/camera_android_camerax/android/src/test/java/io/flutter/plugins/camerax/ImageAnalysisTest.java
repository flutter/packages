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

import android.hardware.camera2.CaptureRequest;
import android.util.Range;
import android.view.Surface;
import androidx.camera.camera2.interop.Camera2Interop;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageAnalysis.Analyzer;
import androidx.camera.core.resolutionselector.ResolutionSelector;
import androidx.core.content.ContextCompat;
import java.util.concurrent.Executor;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.MockedConstruction;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.stubbing.Answer;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class ImageAnalysisTest {
  // Due to Java's Type Erasure, we cannot get a class literal (e.g., Extender<T>.class) for a
  // parameterized type. We must use the raw type (Extender.class) which forces the 'unchecked' and
  // 'rawtypes' warnings. The runtime logic handles the type safely.
  @SuppressWarnings({"unchecked", "rawtypes"})
  @Test
  public void pigeon_defaultConstructor_createsExpectedImageAnalysisInstance() {
    final PigeonApiImageAnalysis api = new TestProxyApiRegistrar().getPigeonApiImageAnalysis();

    final ResolutionSelector mockResolutionSelector = new ResolutionSelector.Builder().build();
    final long targetResolution = Surface.ROTATION_0;
    final Range<Integer> targetFpsRange = new Range<>(30, 30);
    final long outputImageFormat = ImageAnalysis.OUTPUT_IMAGE_FORMAT_NV21;

    try (MockedConstruction<Camera2Interop.Extender> mockCamera2InteropExtender =
        Mockito.mockConstruction(
            Camera2Interop.Extender.class,
            (mock, context) -> {
              when(mock.setCaptureRequestOption(
                      CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE, targetFpsRange))
                  .thenReturn(mock);
            })) {
      final ImageAnalysis imageAnalysis =
          api.pigeon_defaultConstructor(
              mockResolutionSelector, targetResolution, targetFpsRange, outputImageFormat);

      assertEquals(mockResolutionSelector, imageAnalysis.getResolutionSelector());
      assertEquals(Surface.ROTATION_0, imageAnalysis.getTargetRotation());
      assertEquals(1, mockCamera2InteropExtender.constructed().size());
      assertEquals(ImageAnalysis.OUTPUT_IMAGE_FORMAT_NV21, imageAnalysis.getOutputImageFormat());
    }
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
