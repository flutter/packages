// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/analyzer.dart';
import 'package:camera_android_camerax/src/image_analysis.dart';
import 'package:camera_android_camerax/src/image_proxy.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/resolution_selector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'image_analysis_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[
  TestImageAnalysisHostApi,
  TestInstanceManagerHostApi,
  ResolutionSelector,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('ImageAnalysis', () {
    tearDown(() {
      TestImageAnalysisHostApi.setup(null);
    });

    test('create calls create on the Java side', () {
      final MockTestImageAnalysisHostApi mockApi =
          MockTestImageAnalysisHostApi();
      TestImageAnalysisHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final MockResolutionSelector mockResolutionSelector =
          MockResolutionSelector();
      const int mockResolutionSelectorId = 24;

      instanceManager.addHostCreatedInstance(
          mockResolutionSelector, mockResolutionSelectorId,
          onCopy: (ResolutionSelector original) {
        return MockResolutionSelector();
      });

      final ImageAnalysis instance = ImageAnalysis(
        resolutionSelector: mockResolutionSelector,
        instanceManager: instanceManager,
      );

      verify(mockApi.create(
          argThat(equals(instanceManager.getIdentifier(instance))),
          argThat(equals(mockResolutionSelectorId))));
    });

    test('setAnalyzer makes call to set analyzer on ImageAnalysis instance',
        () async {
      final MockTestImageAnalysisHostApi mockApi =
          MockTestImageAnalysisHostApi();
      TestImageAnalysisHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final ImageAnalysis instance = ImageAnalysis.detached(
        resolutionSelector: MockResolutionSelector(),
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (ImageAnalysis original) => ImageAnalysis.detached(
          resolutionSelector: original.resolutionSelector,
          instanceManager: instanceManager,
        ),
      );

      final Analyzer analyzer = Analyzer.detached(
        analyze: (ImageProxy imageProxy) async {},
        instanceManager: instanceManager,
      );
      const int analyzerIdentifier = 10;
      instanceManager.addHostCreatedInstance(
        analyzer,
        analyzerIdentifier,
        onCopy: (_) => Analyzer.detached(
          analyze: (ImageProxy imageProxy) async {},
          instanceManager: instanceManager,
        ),
      );

      await instance.setAnalyzer(
        analyzer,
      );

      verify(mockApi.setAnalyzer(
        instanceIdentifier,
        analyzerIdentifier,
      ));
    });

    test('clearAnalyzer makes call to clear analyzer on ImageAnalysis instance',
        () async {
      final MockTestImageAnalysisHostApi mockApi =
          MockTestImageAnalysisHostApi();
      TestImageAnalysisHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final ImageAnalysis instance = ImageAnalysis.detached(
        resolutionSelector: MockResolutionSelector(),
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (ImageAnalysis original) => ImageAnalysis.detached(
          resolutionSelector: original.resolutionSelector,
          instanceManager: instanceManager,
        ),
      );

      await instance.clearAnalyzer();

      verify(mockApi.clearAnalyzer(
        instanceIdentifier,
      ));
    });
  });
}
