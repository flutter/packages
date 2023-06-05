// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/analyzer.dart';
import 'package:camera_android_camerax/src/image_proxy.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'analyzer_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[TestAnalyzerHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('Analyzer', () {
    setUp(() {});

    tearDown(() {
      TestAnalyzerHostApi.setup(null);
    });

    test('HostApi create', () {
      final MockTestAnalyzerHostApi mockApi = MockTestAnalyzerHostApi();
      TestAnalyzerHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final Analyzer instance = Analyzer(
        analyze: (ImageProxy imageProxy) async {},
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

      final AnalyzerFlutterApiImpl api = AnalyzerFlutterApiImpl(
        instanceManager: instanceManager,
      );

      const int instanceIdentifier = 0;

      api.create(
        instanceIdentifier,
      );

      expect(
        instanceManager.getInstanceWithWeakReference(instanceIdentifier),
        isA<Analyzer>(),
      );
    });

    test('analyze', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      const int instanceIdentifier = 0;
      const int imageProxyIdentifier = 44;
      late final Object callbackParameter;
      final Analyzer instance = Analyzer.detached(
        analyze: (
          ImageProxy imageProxy,
        ) async {
          callbackParameter = imageProxy;
        },
        instanceManager: instanceManager,
      );
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (Analyzer original) => Analyzer.detached(
          analyze: original.analyze,
          instanceManager: instanceManager,
        ),
      );
      final ImageProxy imageProxy = ImageProxy.detached(
          instanceManager: instanceManager, format: 3, height: 4, width: 5);
      instanceManager.addHostCreatedInstance(imageProxy, imageProxyIdentifier,
          onCopy: (ImageProxy original) => ImageProxy.detached(
              instanceManager: instanceManager,
              format: original.format,
              height: original.height,
              width: original.width));

      final AnalyzerFlutterApiImpl flutterApi = AnalyzerFlutterApiImpl(
        instanceManager: instanceManager,
      );

      flutterApi.analyze(
        instanceIdentifier,
        imageProxyIdentifier,
      );

      expect(
        callbackParameter,
        imageProxy,
      );
    });
  });
}
