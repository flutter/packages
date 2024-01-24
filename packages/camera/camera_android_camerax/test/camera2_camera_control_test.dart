// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';

import 'camera2_camera_control_test.mocks.dart';
import 'test_camerax_library.g.dart';

// TODO(bparrishMines): Move desired test implementations to test file or
// remove .gen_api_impls from filename and follow todos below
// TODO(bparrishMines): Import generated pigeon files (the one in lib and test)
// TODO(bparrishMines): Run build runner

@GenerateMocks(
    <Type>[TestCamera2CameraControlHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Camera2CameraControl', () {
    tearDown(() {
      TestCamera2CameraControlHostApi.setup(null);
      TestInstanceManagerHostApi.setup(null);
    });

    test('HostApi create', () {
      final MockTestCamera2CameraControlHostApi mockApi =
          MockTestCamera2CameraControlHostApi();
      TestCamera2CameraControlHostApi.setup(mockApi);
      TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final CameraControl cameraControl = CameraControl.detached(
        // TODO(bparrishMines): This should include the missing params.
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      const int cameraControlIdentifier = 9;
      instanceManager.addHostCreatedInstance(
        cameraControl,
        cameraControlIdentifier,
        onCopy: (_) => CameraControl.detached(
          // TODO(bparrishMines): This should include the missing params.
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      final Camera2CameraControl instance = Camera2CameraControl(
        cameraControl: cameraControl,
        instanceManager: instanceManager,
      );

      verify(mockApi.create(
        instanceManager.getIdentifier(instance),
        cameraControlIdentifier,
      ));
    });

    test('addCaptureRequestOptions', () async {
      final MockTestCamera2CameraControlHostApi mockApi =
          MockTestCamera2CameraControlHostApi();
      TestCamera2CameraControlHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final Camera2CameraControl instance = Camera2CameraControl.detached(
        cameraControl: CameraControl.detached(
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
        onCopy: (Camera2CameraControl original) =>
            Camera2CameraControl.detached(
          cameraControl: original.cameraControl,
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      final CaptureRequestOptions captureRequestOptions =
          CaptureRequestOptions.detached(
        // TODO(bparrishMines): This should include the missing params.
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      const int captureRequestOptionsIdentifier = 8;
      instanceManager.addHostCreatedInstance(
        captureRequestOptions,
        captureRequestOptionsIdentifier,
        onCopy: (_) => CaptureRequestOptions.detached(
          // TODO(bparrishMines): This should include the missing params.
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      await instance.addCaptureRequestOptions(
        captureRequestOptions,
      );

      verify(mockApi.addCaptureRequestOptions(
        instanceIdentifier,
        captureRequestOptionsIdentifier,
      ));
    });
  });
}
