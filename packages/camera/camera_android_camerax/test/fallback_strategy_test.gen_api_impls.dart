// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';

import 'fallback_strategy_test.mocks.dart';

// TODO(bparrishMines): Move desired test implementations to test file or
// remove .gen_api_impls from filename and follow todos below
// TODO(bparrishMines): Import generated pigeon files (the one in lib and test)
// TODO(bparrishMines): Run build runner

@GenerateMocks(<Type>[TestFallbackStrategyHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FallbackStrategy', () {
    tearDown(() {
      TestFallbackStrategyHostApi.setup(null);
      TestInstanceManagerHostApi.setup(null);
    });

    test('HostApi create', () {
      final MockTestFallbackStrategyHostApi mockApi =
          MockTestFallbackStrategyHostApi();
      TestFallbackStrategyHostApi.setup(mockApi);
      TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      const Quality quality = Quality.someEnumValue;

      const VideoResolutionFallbackRule fallbackRule =
          VideoResolutionFallbackRule.someEnumValue;

      final FallbackStrategy instance = FallbackStrategy(
        quality: quality,
        fallbackRule: fallbackRule,
        instanceManager: instanceManager,
      );

      verify(mockApi.create(
        instanceManager.getIdentifier(instance),
        quality,
        fallbackRule,
      ));
    });

    test('FlutterAPI create', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final FallbackStrategyFlutterApiImpl api = FallbackStrategyFlutterApiImpl(
        instanceManager: instanceManager,
      );

      const int instanceIdentifier = 0;

      api.create(
        instanceIdentifier,
        Quality.someEnumValue,
        VideoResolutionFallbackRule.someEnumValue,
      );

      expect(
        instanceManager.getInstanceWithWeakReference(instanceIdentifier),
        isA<FallbackStrategy>(),
      );
    });
  });
}
