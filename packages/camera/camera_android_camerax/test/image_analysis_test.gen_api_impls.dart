// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';

import 'image_analysis_test.mocks.dart';

// TODO(bparrishMines): Move desired test implementations to test file or
// remove .gen_api_impls from filename and follow todos below
// TODO(bparrishMines): Import generated pigeon files (the one in lib and test)
// TODO(bparrishMines): Run build runner

@GenerateMocks(<Type>[TestImageAnalysisHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImageAnalysis', () {
    setUp(() {});

    tearDown(() {
      TestImageAnalysisHostApi.setup(null);
      TestInstanceManagerHostApi.setup(null);
    });

    test('HostApi create', () {
      final MockTestImageAnalysisHostApi mockApi =
          MockTestImageAnalysisHostApi();
      TestImageAnalysisHostApi.setup(mockApi);
      TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final ResolutionInfo targetResolution = ResolutionInfo.detached(
        // TODO(bparrishMines): This should include the missing params.
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      const int targetResolutionIdentifier = 11;
      instanceManager.addHostCreatedInstance(
        targetResolution,
        targetResolutionIdentifier,
        onCopy: (_) => ResolutionInfo.detached(
          // TODO(bparrishMines): This should include the missing params.
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      final ImageAnalysis instance = ImageAnalysis(
        targetResolution: targetResolution,
        instanceManager: instanceManager,
      );

      verify(mockApi.create(
        instanceManager.getIdentifier(instance),
        targetResolutionIdentifier,
      ));
    });

    test('onStreamedFrameAvailableStreamController', () {
      final MockTestImageAnalysisHostApi mockApi =
          MockTestImageAnalysisHostApi();
      TestImageAnalysisHostApi.setup(mockApi);

      final StreamController onStreamedFrameAvailableStreamController =
          ImageAnalysis.onStreamedFrameAvailableStreamController;

      verify(mockApi.attachOnStreamedFrameAvailableStreamController(
        JavaObject.globalInstanceManager
            .getIdentifier(onStreamedFrameAvailableStreamController),
      ));
    });

    test('setAnalyzer', () async {
      final MockTestImageAnalysisHostApi mockApi =
          MockTestImageAnalysisHostApi();
      TestImageAnalysisHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final ImageAnalysis instance = ImageAnalysis.detached(
        targetResolution: ResolutionInfo.detached(
          // TODO(bparrishMines): This should include the missing params.
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (ImageAnalysis original) => ImageAnalysis.detached(
          targetResolution: original.targetResolution,
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      final ImageAnalysisAnalyzer analyzer = ImageAnalysisAnalyzer.detached(
        // TODO(bparrishMines): This should include the missing params.
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      const int analyzerIdentifier = 10;
      instanceManager.addHostCreatedInstance(
        analyzer,
        analyzerIdentifier,
        onCopy: (_) => ImageAnalysisAnalyzer.detached(
          // TODO(bparrishMines): This should include the missing params.
          binaryMessenger: null,
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
        targetResolution: ResolutionInfo.detached(
          // TODO(bparrishMines): This should include the missing params.
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (ImageAnalysis original) => ImageAnalysis.detached(
          targetResolution: original.targetResolution,
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      await instance.clearAnalyzer();

      verify(mockApi.clearAnalyzer(
        instanceIdentifier,
      ));
    });

    test('FlutterAPI create', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final ImageAnalysisFlutterApiImpl api = ImageAnalysisFlutterApiImpl(
        instanceManager: instanceManager,
      );

      const int instanceIdentifier = 0;

      api.create(
        instanceIdentifier,
        targetResolution: ResolutionInfo.detached(
          // TODO(bparrishMines): This should include the missing params.
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      expect(
        instanceManager.getInstanceWithWeakReference(instanceIdentifier),
        isA<ImageAnalysis>(),
      );
    });
  });
}
