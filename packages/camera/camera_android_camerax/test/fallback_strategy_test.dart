// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/fallback_strategy.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'fallback_strategy_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[TestFallbackStrategyHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FallbackStrategy', () {
    tearDown(() {
      TestFallbackStrategyHostApi.setup(null);
      TestInstanceManagerHostApi.setup(null);
    });

    test('detached constructor does not call create on the Java side',
        () async {
      final MockTestFallbackStrategyHostApi mockApi =
          MockTestFallbackStrategyHostApi();
      TestFallbackStrategyHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      FallbackStrategy.detached(
        quality: VideoQuality.UHD,
        fallbackRule: VideoResolutionFallbackRule.higherQualityThan,
        instanceManager: instanceManager,
      );

      verifyNever(mockApi.create(
        argThat(isA<int>()),
        argThat(isA<VideoQuality>()),
        argThat(isA<VideoResolutionFallbackRule>()),
      ));
    });

    test('constructor calls create on the Java side', () {
      final MockTestFallbackStrategyHostApi mockApi =
          MockTestFallbackStrategyHostApi();
      TestFallbackStrategyHostApi.setup(mockApi);
      TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      const VideoQuality quality = VideoQuality.HD;

      const VideoResolutionFallbackRule fallbackRule =
          VideoResolutionFallbackRule.lowerQualityThan;

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
  });
}
