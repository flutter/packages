// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camera_state_error.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'camera_state_error_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('CameraStateError', () {
    test(
        'FlutterAPI create makes call to create CameraStateError instance with expected identifier',
        () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final CameraStateErrorFlutterApiImpl api = CameraStateErrorFlutterApiImpl(
        instanceManager: instanceManager,
      );

      const int instanceIdentifier = 0;
      const int code = 23;

      api.create(
        instanceIdentifier,
        code,
      );

      // Test instance type.
      final Object? instance =
          instanceManager.getInstanceWithWeakReference(instanceIdentifier);
      expect(
        instance,
        isA<CameraStateError>(),
      );

      // Test instance properties.
      final CameraStateError cameraStateError = instance! as CameraStateError;
      expect(cameraStateError.code, equals(code));
    });
  });
}
