// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camera2_camera_control.dart';
import 'package:camera_android_camerax/src/camera_control.dart';
import 'package:camera_android_camerax/src/capture_request_options.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'camera2_camera_control_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[
  CameraControl,
  CaptureRequestOptions,
  TestCamera2CameraControlHostApi,
  TestInstanceManagerHostApi
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('Camera2CameraControl', () {
    tearDown(() {
      TestCamera2CameraControlHostApi.setup(null);
      TestInstanceManagerHostApi.setup(null);
    });

    test('detached create does not call create on the Java side', () {
      final MockTestCamera2CameraControlHostApi mockApi =
          MockTestCamera2CameraControlHostApi();
      TestCamera2CameraControlHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      Camera2CameraControl.detached(
        cameraControl: MockCameraControl(),
        instanceManager: instanceManager,
      );

      verifyNever(mockApi.create(argThat(isA<int>()), argThat(isA<int>())));
    });

    test('create calls create on the Java side', () {
      final MockTestCamera2CameraControlHostApi mockApi =
          MockTestCamera2CameraControlHostApi();
      TestCamera2CameraControlHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final CameraControl mockCameraControl = MockCameraControl();
      const int cameraControlIdentifier = 9;
      instanceManager.addHostCreatedInstance(
        mockCameraControl,
        cameraControlIdentifier,
        onCopy: (_) => CameraControl.detached(
          instanceManager: instanceManager,
        ),
      );

      final Camera2CameraControl instance = Camera2CameraControl(
        cameraControl: mockCameraControl,
        instanceManager: instanceManager,
      );

      verify(mockApi.create(
        instanceManager.getIdentifier(instance),
        cameraControlIdentifier,
      ));
    });

    test(
        'addCaptureRequestOptions makes call on Java side to add capture request options',
        () async {
      final MockTestCamera2CameraControlHostApi mockApi =
          MockTestCamera2CameraControlHostApi();
      TestCamera2CameraControlHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final Camera2CameraControl instance = Camera2CameraControl.detached(
        cameraControl: MockCameraControl(),
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 30;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (Camera2CameraControl original) =>
            Camera2CameraControl.detached(
          cameraControl: original.cameraControl,
          instanceManager: instanceManager,
        ),
      );

      final CaptureRequestOptions mockCaptureRequestOptions =
          MockCaptureRequestOptions();
      const int mockCaptureRequestOptionsIdentifier = 8;
      instanceManager.addHostCreatedInstance(
        mockCaptureRequestOptions,
        mockCaptureRequestOptionsIdentifier,
        onCopy: (_) => MockCaptureRequestOptions(),
      );

      await instance.addCaptureRequestOptions(
        mockCaptureRequestOptions,
      );

      verify(mockApi.addCaptureRequestOptions(
        instanceIdentifier,
        mockCaptureRequestOptionsIdentifier,
      ));
    });
  });
}
