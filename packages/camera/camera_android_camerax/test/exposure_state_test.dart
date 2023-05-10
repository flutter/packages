// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/exposure_state.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'exposure_state_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('ExposureState', () {
    tearDown(() => TestCameraInfoHostApi.setup(null));

    test('flutterApi create makes call to create expected ExposureState', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final ExposureStateFlutterApiImpl flutterApi =
          ExposureStateFlutterApiImpl(
        instanceManager: instanceManager,
      );
      const int exposureStateIdentifier = 68;
      final ExposureCompensationRange exposureCompensationRange =
          ExposureCompensationRange(minCompensation: 5, maxCompensation: 7);
      const double exposureCompensationStep = 0.3;

      flutterApi.create(exposureStateIdentifier, exposureCompensationRange,
          exposureCompensationStep);

      final ExposureState instance =
          instanceManager.getInstanceWithWeakReference(exposureStateIdentifier)!
              as ExposureState;
      expect(instance.exposureCompensationRange,
          equals(exposureCompensationRange));
      expect(
          instance.exposureCompensationStep, equals(exposureCompensationStep));
    });
  });
}
