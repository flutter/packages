// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/resolution_strategy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'resolution_strategy_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[
  TestResolutionStrategyHostApi,
  TestInstanceManagerHostApi,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ResolutionStrategy', () {
    tearDown(() {
      TestResolutionStrategyHostApi.setup(null);
      TestInstanceManagerHostApi.setup(null);
    });

    test(
        'ResolutionStrategy constructor detects valid boundSize and fallbackRule combinations',
        () {
      final MockTestResolutionStrategyHostApi mockApi =
          MockTestResolutionStrategyHostApi();
      TestResolutionStrategyHostApi.setup(mockApi);
      TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      // Expect error if boundSize is null, but fallbackRule is not.
      Size? boundSize;
      int? fallbackRule = 5;
      expect(
          ResolutionStrategy(
            boundSize: boundSize,
            fallbackRule: fallbackRule,
            instanceManager: instanceManager,
          ),
          throwsArgumentError);

      // Expect no error if boundSize is non-null, but fallbackRule is not.
      boundSize = const Size(3, 5);
      fallbackRule = null;
      expect(
          ResolutionStrategy(
            boundSize: boundSize,
            fallbackRule: fallbackRule,
            instanceManager: instanceManager,
          ),
          returnsNormally);

      // Expect no error if boundSize and fallbackRule are both null.
      boundSize = null;
      fallbackRule = null;
      expect(
          ResolutionStrategy(
            boundSize: boundSize,
            fallbackRule: fallbackRule,
            instanceManager: instanceManager,
          ),
          returnsNormally);
    });

    test('HostApi create creates expected ResolutionStrategy', () {
      final MockTestResolutionStrategyHostApi mockApi =
          MockTestResolutionStrategyHostApi();
      TestResolutionStrategyHostApi.setup(mockApi);
      TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      const Size boundSize = Size(50, 30);
      const int fallbackRule = 0;

      final ResolutionStrategy instance = ResolutionStrategy(
        boundSize: boundSize,
        fallbackRule: fallbackRule,
        instanceManager: instanceManager,
      );

      verify(mockApi.create(
        instanceManager.getIdentifier(instance),
        argThat(isA<ResolutionInfo>()
            .having((ResolutionInfo size) => size.width, 'width', 50)
            .having((ResolutionInfo size) => size.height, 'height', 30)),
        fallbackRule,
      ));
    });
  });
}
