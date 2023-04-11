
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(bparrishMines): Remove GenApiImpls from filename or copy classes/methods to your own implementation

package io.flutter.plugins.camerax;

// TODO(bparrishMines): Import native classes
import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
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

public class ImageAnalysisTest {

  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public ImageAnalysis mockImageAnalysis;

  @Mock public BinaryMessenger mockBinaryMessenger;

  // TODO(bparrishMines): Fix name of generated pigeon file
  @Mock public GeneratedPigeonFilename.ImageAnalysisFlutterApi mockFlutterApi;

  @Mock public ImageAnalysisHostApiImpl.ImageAnalysisProxy mockProxy;

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

    final ResolutionInfo mockTargetResolution = mock(ResolutionInfo.class);
    final long targetResolutionIdentifier = 11;
    instanceManager.addDartCreatedInstance(mockTargetResolution, targetResolutionIdentifier);

    when(mockProxy.create(mockTargetResolution)).thenReturn(mockImageAnalysis);

    final ImageAnalysisHostApiImpl hostApi =
        new ImageAnalysisHostApiImpl(mockBinaryMessenger, instanceManager, mockProxy);

    final long instanceIdentifier = 0;
    hostApi.create(instanceIdentifier, targetResolutionIdentifier);

    assertEquals(instanceManager.getInstance(instanceIdentifier), mockImageAnalysis);
  }

  @Test
  public void getOnStreamedFrameAvailableStreamController() {
    final StreamController mockStreamController = mock(StreamController.class);
    final long onStreamedFrameAvailableStreamControllerIdentifier = 1;

    when(mockProxy.getOnStreamedFrameAvailableStreamController()).thenReturn(mockStreamController);

    final long instanceIdentifier = 0;
    instanceManager.addDartCreatedInstance(mockImageAnalysis, instanceIdentifier);

    final ImageAnalysisHostApiImpl hostApi =
        new ImageAnalysisHostApiImpl(mockBinaryMessenger, instanceManager, mockProxy);
    hostApi.attachOnStreamedFrameAvailableStreamController(
        onStreamedFrameAvailableStreamControllerIdentifier);

    assertEquals(
        instanceManager.getInstance(onStreamedFrameAvailableStreamControllerIdentifier),
        mockStreamController);
  }

  @Test
  public void setAnalyzer() {

    final ImageAnalysisAnalyzer mockAnalyzer = mock(ImageAnalysisAnalyzer.class);
    final long analyzerIdentifier = 10;
    instanceManager.addDartCreatedInstance(mockAnalyzer, analyzerIdentifier);

    final long instanceIdentifier = 0;
    instanceManager.addDartCreatedInstance(mockImageAnalysis, instanceIdentifier);

    final ImageAnalysisHostApiImpl hostApi =
        new ImageAnalysisHostApiImpl(mockBinaryMessenger, instanceManager);

    hostApi.setAnalyzer(instanceIdentifier, analyzerIdentifier);

    verify(mockImageAnalysis).setAnalyzer(mockAnalyzer);
  }

  @Test
  public void clearAnalyzer() {

    final long instanceIdentifier = 0;
    instanceManager.addDartCreatedInstance(mockImageAnalysis, instanceIdentifier);

    final ImageAnalysisHostApiImpl hostApi =
        new ImageAnalysisHostApiImpl(mockBinaryMessenger, instanceManager);

    hostApi.clearAnalyzer(instanceIdentifier);

    verify(mockImageAnalysis).clearAnalyzer();
  }

  @Test
  public void flutterApiCreate() {
    final ImageAnalysisFlutterApiImpl flutterApi =
        new ImageAnalysisFlutterApiImpl(mockBinaryMessenger, instanceManager);
    flutterApi.setApi(mockFlutterApi);

    final ResolutionInfo mockTargetResolution = mock(ResolutionInfo.class);

    flutterApi.create(mockImageAnalysis, mockTargetResolution, reply -> {});

    final long instanceIdentifier =
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(mockImageAnalysis));
    verify(mockFlutterApi)
        .create(
            eq(instanceIdentifier),
            eq(
                Objects.requireNonNull(
                    instanceManager.getIdentifierForStrongReference(mockTargetResolution))),
            any());
  }
}
