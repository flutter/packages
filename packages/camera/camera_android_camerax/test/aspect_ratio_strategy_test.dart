// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/aspect_ratio_strategy.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'aspect_ratio_strategy_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[
  TestAspectRatioStrategyHostApi,
  TestInstanceManagerHostApi,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AspectRatioStrategy', () {
    tearDown(() {
      TestAspectRatioStrategyHostApi.setup(null);
      TestInstanceManagerHostApi.setup(null);
    });

    test(
        'detached create does not make call to create expected AspectRatioStrategy instance',
        () async {
      final MockTestAspectRatioStrategyHostApi mockApi =
          MockTestAspectRatioStrategyHostApi();
      TestAspectRatioStrategyHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      const int preferredAspectRatio = 1;

      const int fallbackRule = 1;

      AspectRatioStrategy.detached(
        preferredAspectRatio: preferredAspectRatio,
        fallbackRule: fallbackRule,
        instanceManager: instanceManager,
      );

      verifyNever(mockApi.create(
        argThat(isA<int>()),
        preferredAspectRatio,
        fallbackRule,
      ));
    });

    test(
        'HostApi create makes call to create expected AspectRatioStrategy instance',
        () {
      final MockTestAspectRatioStrategyHostApi mockApi =
          MockTestAspectRatioStrategyHostApi();
      TestAspectRatioStrategyHostApi.setup(mockApi);
      TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      const int preferredAspectRatio = 0;

      const int fallbackRule = 0;

      final AspectRatioStrategy instance = AspectRatioStrategy(
        preferredAspectRatio: preferredAspectRatio,
        fallbackRule: fallbackRule,
        instanceManager: instanceManager,
      );

      verify(mockApi.create(
        instanceManager.getIdentifier(instance),
        preferredAspectRatio,
        fallbackRule,
      ));
    });
  });
}
