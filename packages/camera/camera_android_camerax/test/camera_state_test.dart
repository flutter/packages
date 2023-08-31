// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camera_state.dart';
import 'package:camera_android_camerax/src/camera_state_error.dart';
import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'camera_state_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('CameraState', () {
    test(
        'FlutterAPI create makes call to create CameraState instance with expected identifier',
        () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final CameraStateFlutterApiImpl api = CameraStateFlutterApiImpl(
        instanceManager: instanceManager,
      );

      // Create CameraStateError for CameraState instance.
      const int code = 23;
      final CameraStateError cameraStateError = CameraStateError.detached(
        instanceManager: instanceManager,
        code: code,
      );
      final int cameraStateErrorIdentifier =
          instanceManager.addDartCreatedInstance(cameraStateError, onCopy: (_) {
        return CameraStateError.detached(code: code);
      });

      // Create CameraState.
      const int instanceIdentifier = 46;
      const CameraStateType cameraStateType = CameraStateType.closed;
      api.create(
        instanceIdentifier,
        CameraStateTypeData(value: cameraStateType),
        cameraStateErrorIdentifier,
      );

      // Test instance type.
      final Object? instance =
          instanceManager.getInstanceWithWeakReference(instanceIdentifier);
      expect(
        instanceManager.getInstanceWithWeakReference(instanceIdentifier),
        isA<CameraState>(),
      );

      // Test instance properties.
      final CameraState cameraState = instance! as CameraState;
      expect(cameraState.type, equals(cameraStateType));
      expect(cameraState.error, equals(cameraStateError));
    });
  });
}
