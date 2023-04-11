
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(bparrishMines): Remove GenApiImpls from filename or copy classes/methods to your own implementation

package io.flutter.plugins.camerax;

// TODO(bparrishMines): Import native classes
import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import io.flutter.plugin.common.BinaryMessenger;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class ImageAnalysisAnalyzerTest {

  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public ImageAnalysisAnalyzerHostApiImpl.ImageAnalysisAnalyzerImpl mockImageAnalysisAnalyzer;

  @Mock public BinaryMessenger mockBinaryMessenger;

  // TODO(bparrishMines): Fix name of generated pigeon file
  @Mock public GeneratedPigeonFilename.ImageAnalysisAnalyzerFlutterApi mockFlutterApi;

  @Mock public ImageAnalysisAnalyzerHostApiImpl.ImageAnalysisAnalyzerProxy mockProxy;

  InstanceManager instanceManager;

  @Before
  public void setUp() {
    instanceManager = InstanceManager.open(identifier -> {});
  }

  @After
  public void tearDown() {
    instanceManager.close();
  }

  @Test
  public void hostApiCreate() {

    when(mockProxy.create(mockBinaryMessenger, instanceManager))
        .thenReturn(mockImageAnalysisAnalyzer);
    final ImageAnalysisAnalyzerHostApiImpl hostApi =
        new ImageAnalysisAnalyzerHostApiImpl(mockBinaryMessenger, instanceManager, mockProxy);

    final long instanceIdentifier = 0;
    hostApi.create(instanceIdentifier);

    assertEquals(instanceManager.getInstance(instanceIdentifier), mockImageAnalysisAnalyzer);
  }

  @Test
  public void flutterApiCreate() {
    final ImageAnalysisAnalyzerFlutterApiImpl flutterApi =
        new ImageAnalysisAnalyzerFlutterApiImpl(mockBinaryMessenger, instanceManager);
    flutterApi.setApi(mockFlutterApi);

    flutterApi.create(mockImageAnalysisAnalyzer, reply -> {});

    final long instanceIdentifier =
        Objects.requireNonNull(
            instanceManager.getIdentifierForStrongReference(mockImageAnalysisAnalyzer));
    verify(mockFlutterApi).create(eq(instanceIdentifier), any());
  }

  @Test
  public void analyze() {
    final ImageAnalysisAnalyzerFlutterApiImpl flutterApi =
        new ImageAnalysisAnalyzerFlutterApiImpl(mockBinaryMessenger, instanceManager);
    flutterApi.setApi(mockFlutterApi);

    final ImageAnalysisAnalyzerHostApiImpl.ImageAnalysisAnalyzerImpl instance =
        new ImageAnalysisAnalyzerHostApiImpl.ImageAnalysisAnalyzerImpl(
            mockBinaryMessenger, instanceManager);
    instance.setApi(flutterApi);

    final long instanceIdentifier = 0;
    instanceManager.addDartCreatedInstance(instance, instanceIdentifier);

    instance.analyze();

    verify(mockFlutterApi).analyze(eq(instanceIdentifier), any());
  }
}
