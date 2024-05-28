// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/focus_metering_result.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/metering_point.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'focus_metering_result_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[
  MeteringPoint,
  TestFocusMeteringResultHostApi,
  TestInstanceManagerHostApi
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('FocusMeteringResult', () {
    tearDown(() => TestCameraHostApi.setup(null));

    test('isFocusSuccessful returns expected result', () async {
      final MockTestFocusMeteringResultHostApi mockApi =
          MockTestFocusMeteringResultHostApi();
      TestFocusMeteringResultHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final FocusMeteringResult focusMeteringResult =
          FocusMeteringResult.detached(
        instanceManager: instanceManager,
      );
      const int focusMeteringResultIdentifier = 5;

      instanceManager.addHostCreatedInstance(
        focusMeteringResult,
        focusMeteringResultIdentifier,
        onCopy: (_) =>
            FocusMeteringResult.detached(instanceManager: instanceManager),
      );

      when(mockApi.isFocusSuccessful(focusMeteringResultIdentifier))
          .thenAnswer((_) => false);

      expect(await focusMeteringResult.isFocusSuccessful(), isFalse);
      verify(mockApi.isFocusSuccessful(focusMeteringResultIdentifier));
    });

    test('flutterApiCreate makes call to add instance to instance manager', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final FocusMeteringResultFlutterApiImpl flutterApi =
          FocusMeteringResultFlutterApiImpl(
        instanceManager: instanceManager,
      );
      const int focusMeteringResultIdentifier = 37;

      flutterApi.create(focusMeteringResultIdentifier);

      expect(
          instanceManager
              .getInstanceWithWeakReference(focusMeteringResultIdentifier),
          isA<FocusMeteringResult>());
    });
  });
}
