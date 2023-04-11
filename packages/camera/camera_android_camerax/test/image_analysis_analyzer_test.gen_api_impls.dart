// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';

import 'image_analysis_analyzer_test.mocks.dart';

// TODO(bparrishMines): Move desired test implementations to test file or
// remove .gen_api_impls from filename and follow todos below
// TODO(bparrishMines): Import generated pigeon files (the one in lib and test)
// TODO(bparrishMines): Run build runner

@GenerateMocks(
    <Type>[TestImageAnalysisAnalyzerHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImageAnalysisAnalyzer', () {
    setUp(() {});

    tearDown(() {
      TestImageAnalysisAnalyzerHostApi.setup(null);
      TestInstanceManagerHostApi.setup(null);
    });

    test('HostApi create', () {
      final MockTestImageAnalysisAnalyzerHostApi mockApi =
          MockTestImageAnalysisAnalyzerHostApi();
      TestImageAnalysisAnalyzerHostApi.setup(mockApi);
      TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final ImageAnalysisAnalyzer instance = ImageAnalysisAnalyzer(
        instanceManager: instanceManager,
      );

      verify(mockApi.create(
        instanceManager.getIdentifier(instance),
      ));
    });

    test('FlutterAPI create', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final ImageAnalysisAnalyzerFlutterApiImpl api =
          ImageAnalysisAnalyzerFlutterApiImpl(
        instanceManager: instanceManager,
      );

      const int instanceIdentifier = 0;

      api.create(
        instanceIdentifier,
      );

      expect(
        instanceManager.getInstanceWithWeakReference(instanceIdentifier),
        isA<ImageAnalysisAnalyzer>(),
      );
    });

    test('analyze', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      const int instanceIdentifier = 0;
      late final List<Object?> callbackParameters;
      final ImageAnalysisAnalyzer instance = ImageAnalysisAnalyzer.detached(
        analyze: (
          ImageAnalysisAnalyzer instance,
        ) {
          callbackParameters = <Object?>[
            instance,
          ];
        },
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (ImageAnalysisAnalyzer original) =>
            ImageAnalysisAnalyzer.detached(
          analyze: original.analyze,
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      final ImageAnalysisAnalyzerFlutterApiImpl flutterApi =
          ImageAnalysisAnalyzerFlutterApiImpl(
        instanceManager: instanceManager,
      );

      flutterApi.analyze(
        instanceIdentifier,
      );

      expect(callbackParameters, <Object?>[
        instance,
      ]);
    });
  });
}
