// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';

import 'quality_selector_test.mocks.dart';

// TODO(bparrishMines): Move desired test implementations to test file or
// remove .gen_api_impls from filename and follow todos below
// TODO(bparrishMines): Import generated pigeon files (the one in lib and test)
// TODO(bparrishMines): Run build runner

@GenerateMocks(<Type>[TestQualitySelectorHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QualitySelector', () {
    tearDown(() {
      TestQualitySelectorHostApi.setup(null);
      TestInstanceManagerHostApi.setup(null);
    });

    test('HostApi createFrom', () {
      final MockTestQualitySelectorHostApi mockApi =
          MockTestQualitySelectorHostApi();
      TestQualitySelectorHostApi.setup(mockApi);
      TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      const Quality quality = Quality.someEnumValue;

      final FallbackStrategy fallbackStrategy = FallbackStrategy.detached(
        // TODO(bparrishMines): This should include the missing params.
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      const int fallbackStrategyIdentifier = 9;
      instanceManager.addHostCreatedInstance(
        fallbackStrategy,
        fallbackStrategyIdentifier,
        onCopy: (_) => FallbackStrategy.detached(
          // TODO(bparrishMines): This should include the missing params.
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      final QualitySelector instance = QualitySelector(
        quality: quality,
        fallbackStrategy: fallbackStrategy,
        instanceManager: instanceManager,
      );

      verify(mockApi.createfrom(
        instanceManager.getIdentifier(instance),
        quality,
        fallbackStrategyIdentifier,
      ));
    });

    test('HostApi createFromOrderedList', () {
      final MockTestQualitySelectorHostApi mockApi =
          MockTestQualitySelectorHostApi();
      TestQualitySelectorHostApi.setup(mockApi);
      TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      const List qualityList = <dynamic>[];

      final FallbackStrategy fallbackStrategy = FallbackStrategy.detached(
        // TODO(bparrishMines): This should include the missing params.
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      const int fallbackStrategyIdentifier = 11;
      instanceManager.addHostCreatedInstance(
        fallbackStrategy,
        fallbackStrategyIdentifier,
        onCopy: (_) => FallbackStrategy.detached(
          // TODO(bparrishMines): This should include the missing params.
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      final QualitySelector instance = QualitySelector(
        qualityList: qualityList,
        fallbackStrategy: fallbackStrategy,
        instanceManager: instanceManager,
      );

      verify(mockApi.createfromOrderedList(
        instanceManager.getIdentifier(instance),
        qualityList,
        fallbackStrategyIdentifier,
      ));
    });

    test('getResolution', () async {
      final MockTestQualitySelectorHostApi mockApi =
          MockTestQualitySelectorHostApi();
      TestQualitySelectorHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final QualitySelector instance = QualitySelector.detached(
        <dynamic>[],
        FallbackStrategy.detached(
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
        onCopy: (QualitySelector original) => QualitySelector.detached(
          original.qualityList,
          original.fallbackStrategy,
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      final InvalidType cameraInfo = InvalidType.detached(
        // TODO(bparrishMines): This should include the missing params.
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      const int cameraInfoIdentifier = 6;
      instanceManager.addHostCreatedInstance(
        cameraInfo,
        cameraInfoIdentifier,
        onCopy: (_) => InvalidType.detached(
          // TODO(bparrishMines): This should include the missing params.
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      const Quality quality = Quality.someEnumValue;

      final Size result = Size.detached(
        // TODO(bparrishMines): This should include the missing params.
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      const int resultIdentifier = 1;
      instanceManager.addHostCreatedInstance(
        result,
        resultIdentifier,
        onCopy: (Size original) {
          return Size.detached(
            // TODO(bparrishMines): This should include the missing params.
            binaryMessenger: null,
            instanceManager: instanceManager,
          );
        },
      );
      when(mockApi.getResolution(
        instanceIdentifier,
        cameraInfoIdentifier,
        quality,
      )).thenAnswer((_) {
        return Future<int>.value(resultIdentifier);
      });

      expect(
          await instance.getResolution(
            cameraInfo,
            quality,
          ),
          result);

      verify(mockApi.getResolution(
        instanceIdentifier,
        cameraInfoIdentifier,
        quality,
      ));
    });

    test('FlutterAPI create', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final QualitySelectorFlutterApiImpl api = QualitySelectorFlutterApiImpl(
        instanceManager: instanceManager,
      );

      const int instanceIdentifier = 0;

      api.create(
        instanceIdentifier,
        <dynamic>[],
        FallbackStrategy.detached(
          // TODO(bparrishMines): This should include the missing params.
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      expect(
        instanceManager.getInstanceWithWeakReference(instanceIdentifier),
        isA<QualitySelector>(),
      );
    });
  });
}
