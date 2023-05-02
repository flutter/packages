// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.camera.core.ImageProxy;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.AnalyzerFlutterApi;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class AnalyzerTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();
  @Mock public AnalyzerHostApiImpl.AnalyzerImpl mockImageAnalysisAnalyzer;
  @Mock public BinaryMessenger mockBinaryMessenger;
  @Mock public AnalyzerFlutterApi mockFlutterApi;
  @Mock public AnalyzerHostApiImpl.AnalyzerProxy mockProxy;

  InstanceManager instanceManager;

  @Before
  public void setUp() {
    instanceManager = InstanceManager.create(identifier -> {});
  }

  @After
  public void tearDown() {
    instanceManager.stopFinalizationListener();
  }

  @Test
  public void hostApiCreate_makesCallToCreateAnalyzerInstanceWithExpectedIdentifier() {
    final AnalyzerHostApiImpl hostApi =
        new AnalyzerHostApiImpl(mockBinaryMessenger, instanceManager, mockProxy);
    final long instanceIdentifier = 90;

    when(mockProxy.create(mockBinaryMessenger, instanceManager))
        .thenReturn(mockImageAnalysisAnalyzer);

    hostApi.create(instanceIdentifier);

    assertEquals(instanceManager.getInstance(instanceIdentifier), mockImageAnalysisAnalyzer);
  }

  @Test
  public void flutterApiCreate_makesCallToDartCreate() {
    final AnalyzerFlutterApiImpl flutterApi =
        new AnalyzerFlutterApiImpl(mockBinaryMessenger, instanceManager);

    flutterApi.setApi(mockFlutterApi);

    flutterApi.create(mockImageAnalysisAnalyzer, reply -> {});
    final long instanceIdentifier =
        Objects.requireNonNull(
            instanceManager.getIdentifierForStrongReference(mockImageAnalysisAnalyzer));

    verify(mockFlutterApi).create(eq(instanceIdentifier), any());
  }

  @Test
  public void analyze_makesCallToDartAnalyze() {
    final AnalyzerFlutterApiImpl flutterApi =
        new AnalyzerFlutterApiImpl(mockBinaryMessenger, instanceManager);
    final ImageProxy mockImageProxy = mock(ImageProxy.class);
    final long mockImageProxyIdentifier = 97;
    final AnalyzerHostApiImpl.AnalyzerImpl instance =
        new AnalyzerHostApiImpl.AnalyzerImpl(mockBinaryMessenger, instanceManager);
    final ImageProxyFlutterApiImpl mockImageProxyApi =
        spy(new ImageProxyFlutterApiImpl(mockBinaryMessenger, instanceManager));
    final long instanceIdentifier = 20;
    final long format = 3;
    final long height = 2;
    final long width = 1;

    flutterApi.setApi(mockFlutterApi);
    instance.setApi(flutterApi);
    instance.imageProxyApi = mockImageProxyApi;

    instanceManager.addDartCreatedInstance(instance, instanceIdentifier);
    instanceManager.addDartCreatedInstance(mockImageProxy, mockImageProxyIdentifier);

    when(mockImageProxy.getFormat()).thenReturn(3);
    when(mockImageProxy.getHeight()).thenReturn(2);
    when(mockImageProxy.getWidth()).thenReturn(1);

    instance.analyze(mockImageProxy);

    verify(mockFlutterApi).analyze(eq(instanceIdentifier), eq(mockImageProxyIdentifier), any());
    verify(mockImageProxyApi).create(eq(mockImageProxy), eq(format), eq(height), eq(width), any());
  }
}
