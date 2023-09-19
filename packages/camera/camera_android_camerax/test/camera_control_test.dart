// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camera_control.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'camera_control_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[TestCameraControlHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('CameraControl', () {
    tearDown(() => TestCameraHostApi.setup(null));

    test('enableTorch makes call on Java side to enable torch', () async {
      final MockTestCameraControlHostApi mockApi =
          MockTestCameraControlHostApi();
      TestCameraControlHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final CameraControl cameraControl = CameraControl.detached(
        instanceManager: instanceManager,
      );
      const int cameraControlIdentifier = 22;

      instanceManager.addHostCreatedInstance(
        cameraControl,
        cameraControlIdentifier,
        onCopy: (_) => CameraControl.detached(instanceManager: instanceManager),
      );

      const bool enableTorch = true;
      await cameraControl.enableTorch(enableTorch);

      verify(mockApi.enableTorch(cameraControlIdentifier, enableTorch));
    });

    test('setZoomRatio makes call on Java side to set zoom ratio', () async {
      final MockTestCameraControlHostApi mockApi =
          MockTestCameraControlHostApi();
      TestCameraControlHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final CameraControl cameraControl = CameraControl.detached(
        instanceManager: instanceManager,
      );
      const int cameraControlIdentifier = 45;

      instanceManager.addHostCreatedInstance(
        cameraControl,
        cameraControlIdentifier,
        onCopy: (_) => CameraControl.detached(instanceManager: instanceManager),
      );

      const double zoom = 0.2;
      await cameraControl.setZoomRatio(zoom);

      verify(mockApi.setZoomRatio(cameraControlIdentifier, zoom));
    });

    test('flutterApiCreate makes call to add instance to instance manager', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final CameraControlFlutterApiImpl flutterApi =
          CameraControlFlutterApiImpl(
        instanceManager: instanceManager,
      );
      const int cameraControlIdentifier = 67;

      flutterApi.create(cameraControlIdentifier);

      expect(
          instanceManager.getInstanceWithWeakReference(cameraControlIdentifier),
          isA<CameraControl>());
    });
  });
}
