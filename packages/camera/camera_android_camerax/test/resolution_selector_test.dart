// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:camera_android_camerax/src/aspect_ratio_strategy.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/resolution_filter.dart';
import 'package:camera_android_camerax/src/resolution_selector.dart';
import 'package:camera_android_camerax/src/resolution_strategy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'resolution_selector_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[
  AspectRatioStrategy,
  ResolutionFilter,
  ResolutionStrategy,
  TestResolutionSelectorHostApi,
  TestInstanceManagerHostApi,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ResolutionSelector', () {
    tearDown(() {
      TestResolutionSelectorHostApi.setup(null);
      TestInstanceManagerHostApi.setup(null);
    });

    test(
        'detached constructor does not make call to create expected AspectRatioStrategy instance',
        () async {
      final MockTestResolutionSelectorHostApi mockApi =
          MockTestResolutionSelectorHostApi();
      TestResolutionSelectorHostApi.setup(mockApi);
      TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

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

      ResolutionSelector.detached(
        resolutionStrategy: MockResolutionStrategy(),
        resolutionFilter: MockResolutionFilter(),
        aspectRatioStrategy: MockAspectRatioStrategy(),
        instanceManager: instanceManager,
      );

      verifyNever(mockApi.create(argThat(isA<int>()), argThat(isA<int>()),
          argThat(isA<int>()), argThat(isA<int>())));
    });

    test('HostApi create creates expected ResolutionSelector instance', () {
      final MockTestResolutionSelectorHostApi mockApi =
          MockTestResolutionSelectorHostApi();
      TestResolutionSelectorHostApi.setup(mockApi);
      TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final ResolutionStrategy resolutionStrategy = ResolutionStrategy.detached(
        boundSize: const Size(50, 30),
        fallbackRule: ResolutionStrategy.fallbackRuleClosestLower,
        instanceManager: instanceManager,
      );
      const int resolutionStrategyIdentifier = 14;
      instanceManager.addHostCreatedInstance(
        resolutionStrategy,
        resolutionStrategyIdentifier,
        onCopy: (ResolutionStrategy original) => ResolutionStrategy.detached(
          boundSize: original.boundSize,
          fallbackRule: original.fallbackRule,
          instanceManager: instanceManager,
        ),
      );

      final ResolutionFilter resolutionFilter =
          ResolutionFilter.onePreferredSizeDetached(
              preferredResolution: const Size(30, 40));
      const int resolutionFilterIdentifier = 54;
      instanceManager.addHostCreatedInstance(
        resolutionFilter,
        resolutionFilterIdentifier,
        onCopy: (ResolutionFilter original) =>
            ResolutionFilter.onePreferredSizeDetached(
          preferredResolution: original.preferredResolution,
          instanceManager: instanceManager,
        ),
      );

      final AspectRatioStrategy aspectRatioStrategy =
          AspectRatioStrategy.detached(
        preferredAspectRatio: AspectRatio.ratio4To3,
        fallbackRule: AspectRatioStrategy.fallbackRuleAuto,
        instanceManager: instanceManager,
      );
      const int aspectRatioStrategyIdentifier = 15;
      instanceManager.addHostCreatedInstance(
        aspectRatioStrategy,
        aspectRatioStrategyIdentifier,
        onCopy: (AspectRatioStrategy original) => AspectRatioStrategy.detached(
          preferredAspectRatio: original.preferredAspectRatio,
          fallbackRule: original.fallbackRule,
          instanceManager: instanceManager,
        ),
      );

      final ResolutionSelector instance = ResolutionSelector(
        resolutionStrategy: resolutionStrategy,
        resolutionFilter: resolutionFilter,
        aspectRatioStrategy: aspectRatioStrategy,
        instanceManager: instanceManager,
      );

      verify(mockApi.create(
        instanceManager.getIdentifier(instance),
        resolutionStrategyIdentifier,
        resolutionFilterIdentifier,
        aspectRatioStrategyIdentifier,
      ));
    });
  });
}
