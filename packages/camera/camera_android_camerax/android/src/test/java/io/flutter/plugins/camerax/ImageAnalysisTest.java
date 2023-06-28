// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.content.Context;
import android.util.Size;
import androidx.camera.core.ImageAnalysis;
import androidx.test.core.app.ApplicationProvider;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ResolutionInfo;
import java.util.concurrent.Executor;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class ImageAnalysisTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();
  @Mock public ImageAnalysis mockImageAnalysis;
  @Mock public BinaryMessenger mockBinaryMessenger;

  InstanceManager instanceManager;
  private Context context;

  @Before
  public void setUp() {
    instanceManager = InstanceManager.create(identifier -> {});
    context = ApplicationProvider.getApplicationContext();
  }

  @After
  public void tearDown() {
    instanceManager.stopFinalizationListener();
  }

  @Test
  public void hostApiCreate_createsExpectedImageAnalysisInstanceWithExpectedIdentifier() {
    final ImageAnalysisHostApiImpl hostApi =
        new ImageAnalysisHostApiImpl(mockBinaryMessenger, instanceManager);
    final CameraXProxy mockCameraXProxy = mock(CameraXProxy.class);
    final ImageAnalysis.Builder mockImageAnalysisBuilder = mock(ImageAnalysis.Builder.class);
    final int targetResolutionWidth = 10;
    final int targetResolutionHeight = 50;
    final ResolutionInfo resolutionInfo =
        new ResolutionInfo.Builder()
            .setWidth(Long.valueOf(targetResolutionWidth))
            .setHeight(Long.valueOf(targetResolutionHeight))
            .build();
    final long instanceIdentifier = 0;

    hostApi.cameraXProxy = mockCameraXProxy;

    final ArgumentCaptor<Size> sizeCaptor = ArgumentCaptor.forClass(Size.class);

    when(mockCameraXProxy.createImageAnalysisBuilder()).thenReturn(mockImageAnalysisBuilder);
    when(mockImageAnalysisBuilder.build()).thenReturn(mockImageAnalysis);

    hostApi.create(instanceIdentifier, resolutionInfo);

    verify(mockImageAnalysisBuilder).setTargetResolution(sizeCaptor.capture());
    assertEquals(sizeCaptor.getValue().getWidth(), targetResolutionWidth);
    assertEquals(sizeCaptor.getValue().getHeight(), targetResolutionHeight);
    assertEquals(instanceManager.getInstance(instanceIdentifier), mockImageAnalysis);
  }

  @Test
  public void setAnalyzer_makesCallToSetAnalyzerOnExpectedImageAnalysisInstance() {
    final ImageAnalysisHostApiImpl hostApi =
        new ImageAnalysisHostApiImpl(mockBinaryMessenger, instanceManager);
    hostApi.setContext(context);

    final ImageAnalysis.Analyzer mockAnalyzer = mock(ImageAnalysis.Analyzer.class);
    final long analyzerIdentifier = 10;
    final long instanceIdentifier = 94;

    instanceManager.addDartCreatedInstance(mockAnalyzer, analyzerIdentifier);
    instanceManager.addDartCreatedInstance(mockImageAnalysis, instanceIdentifier);

    hostApi.setAnalyzer(instanceIdentifier, analyzerIdentifier);

    verify(mockImageAnalysis).setAnalyzer(any(Executor.class), eq(mockAnalyzer));
  }

  @Test
  public void clearAnalyzer_makesCallToClearAnalyzerOnExpectedImageAnalysisInstance() {
    final ImageAnalysisHostApiImpl hostApi =
        new ImageAnalysisHostApiImpl(mockBinaryMessenger, instanceManager);
    final long instanceIdentifier = 22;

    instanceManager.addDartCreatedInstance(mockImageAnalysis, instanceIdentifier);

    hostApi.clearAnalyzer(instanceIdentifier);

    verify(mockImageAnalysis).clearAnalyzer();
  }
}
