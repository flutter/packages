// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camera.dart';
import 'package:camera_android_camerax/src/camera_info.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'camera_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[TestCameraHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('Camera', () {
    tearDown(() => TestCameraHostApi.setup(null));

    test('getCameraInfo makes call to retrieve CameraInfo', () async {
      final MockTestCameraHostApi mockApi = MockTestCameraHostApi();
      TestCameraHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final Camera camera = Camera.detached(
        instanceManager: instanceManager,
      );
      const int cameraIdentifier = 34;
      final CameraInfo cameraInfo = CameraInfo.detached(
        instanceManager: instanceManager,
      );
      const int cameraInfoIdentifier = 28;
      instanceManager.addHostCreatedInstance(
        camera,
        cameraIdentifier,
        onCopy: (_) => CameraInfo.detached(),
      );
      instanceManager.addHostCreatedInstance(
        cameraInfo,
        cameraInfoIdentifier,
        onCopy: (_) => CameraInfo.detached(),
      );

      when(mockApi.getCameraInfo(cameraIdentifier))
          .thenReturn(cameraInfoIdentifier);

      expect(await camera.getCameraInfo(), equals(cameraInfo));
      verify(mockApi.getCameraInfo(cameraIdentifier));
    });

    test('create makes call to add instance to instance manager', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final CameraFlutterApiImpl flutterApi = CameraFlutterApiImpl(
        instanceManager: instanceManager,
      );

      flutterApi.create(0);

      expect(instanceManager.getInstanceWithWeakReference(0), isA<Camera>());
    });
  });
}
