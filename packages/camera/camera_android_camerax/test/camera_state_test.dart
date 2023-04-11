// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:camera_android_camerax/src/camera_state_error.dart';
import 'package:camera_android_camerax/src/camera_state.dart';
import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';

import 'camera_state_test.mocks.dart';
import 'test_camerax_library.g.dart';

// TODO(bparrishMines): Move desired test implementations to test file or
// remove .gen_api_impls from filename and follow todos below
// TODO(bparrishMines): Import generated pigeon files (the one in lib and test)
// TODO(bparrishMines): Run build runner

@GenerateMocks(<Type>[TestCameraStateHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CameraState', () {
    tearDown(() {
      TestCameraStateHostApi.setup(null);
      TestInstanceManagerHostApi.setup(null);
    });

    test('FlutterAPI create', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final CameraStateFlutterApiImpl api = CameraStateFlutterApiImpl(
        instanceManager: instanceManager,
      );

      const int code = 23;
      const String description = "test description";
      final int cameraStateIdentifier = instanceManager.addDartCreatedInstance(
          CameraStateError.detached(
            // TODO(bparrishMines): This should include the missing params.
            binaryMessenger: null,
            instanceManager: instanceManager,
            code: code,
            description: description,
          ), onCopy: (_) {
        return CameraStateError.detached(code: code, description: description);
      });

      const int instanceIdentifier = 46;

      api.create(
        instanceIdentifier,
        CameraStateTypeData(value: CameraStateType.closed),
        cameraStateIdentifier,
      );

      expect(
        instanceManager.getInstanceWithWeakReference(instanceIdentifier),
        isA<CameraState>(),
      );
    });
  });
}
