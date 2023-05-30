// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/analyzer.dart';
import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/image_analysis.dart';
import 'package:camera_android_camerax/src/image_proxy.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'image_analysis_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[TestImageAnalysisHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('ImageAnalysis', () {
    setUp(() {});

    tearDown(() {
      TestImageAnalysisHostApi.setup(null);
    });

    test('HostApi create', () {
      final MockTestImageAnalysisHostApi mockApi =
          MockTestImageAnalysisHostApi();
      TestImageAnalysisHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      const int targetResolutionWidth = 65;
      const int targetResolutionHeight = 99;
      final ResolutionInfo targetResolution =
          ResolutionInfo(width: 65, height: 99);
      final ImageAnalysis instance = ImageAnalysis(
        targetResolution: targetResolution,
        instanceManager: instanceManager,
      );

      final VerificationResult createVerification = verify(mockApi.create(
          argThat(equals(instanceManager.getIdentifier(instance))),
          captureAny));
      final ResolutionInfo capturedResolutionInfo =
          createVerification.captured.single as ResolutionInfo;
      expect(capturedResolutionInfo.width, equals(targetResolutionWidth));
      expect(capturedResolutionInfo.height, equals(targetResolutionHeight));
    });

    test('setAnalyzer', () async {
      final MockTestImageAnalysisHostApi mockApi =
          MockTestImageAnalysisHostApi();
      TestImageAnalysisHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final ImageAnalysis instance = ImageAnalysis.detached(
        targetResolution: ResolutionInfo(width: 75, height: 98),
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (ImageAnalysis original) => ImageAnalysis.detached(
          targetResolution: original.targetResolution,
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

    test('clearAnalyzer', () async {
      final MockTestImageAnalysisHostApi mockApi =
          MockTestImageAnalysisHostApi();
      TestImageAnalysisHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final ImageAnalysis instance = ImageAnalysis.detached(
        targetResolution: ResolutionInfo(width: 75, height: 98),
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (ImageAnalysis original) => ImageAnalysis.detached(
          targetResolution: original.targetResolution,
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
