// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camera2_camera_info.dart';
import 'package:camera_android_camerax/src/camera_info.dart';
import 'package:camera_android_camerax/src/camera_metadata.dart';
import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'camera2_camera_info_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[
  TestCamera2CameraInfoHostApi,
  TestInstanceManagerHostApi,
  CameraInfo
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('Camera2CameraInfo', () {
    tearDown(() => TestCamera2CameraInfoHostApi.setup(null));

    test('from returns expected Camera2CameraInfo instance', () async {
      final MockTestCamera2CameraInfoHostApi mockApi =
          MockTestCamera2CameraInfoHostApi();
      TestCamera2CameraInfoHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final Camera2CameraInfo camera2CameraInfo = Camera2CameraInfo.detached(
        instanceManager: instanceManager,
      );
      final CameraInfo mockCameraInfo = MockCameraInfo();
      const int camera2CameraInfoId = 33;
      const int mockCameraInfoId = 44;

      instanceManager.addHostCreatedInstance(
        camera2CameraInfo,
        camera2CameraInfoId,
        onCopy: (_) => Camera2CameraInfo.detached(),
      );
      instanceManager.addHostCreatedInstance(
        mockCameraInfo,
        mockCameraInfoId,
        onCopy: (_) => CameraInfo.detached(),
      );

      when(mockApi.createFrom(mockCameraInfoId))
          .thenAnswer((_) => camera2CameraInfoId);
      expect(
          await Camera2CameraInfo.from(mockCameraInfo,
              instanceManager: instanceManager),
          equals(camera2CameraInfo));
      verify(mockApi.createFrom(mockCameraInfoId));
    });

    test('detached constructor does not create Camera2CameraInfo on Java side',
        () async {
      final MockTestCamera2CameraInfoHostApi mockApi =
          MockTestCamera2CameraInfoHostApi();
      TestCamera2CameraInfoHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      Camera2CameraInfo.detached(
        instanceManager: instanceManager,
      );

      verifyNever(mockApi.createFrom(argThat(isA<int>())));
    });

    test(
        'getSupportedHardwareLevel makes call to retrieve supported hardware level',
        () async {
      final MockTestCamera2CameraInfoHostApi mockApi =
          MockTestCamera2CameraInfoHostApi();
      TestCamera2CameraInfoHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final Camera2CameraInfo camera2CameraInfo = Camera2CameraInfo.detached(
        instanceManager: instanceManager,
      );
      const int camera2CameraInfoId = 9;

      instanceManager.addHostCreatedInstance(
        camera2CameraInfo,
        camera2CameraInfoId,
        onCopy: (_) => Camera2CameraInfo.detached(),
      );

      const int expectedSupportedHardwareLevel =
          CameraMetadata.infoSupportedHardwareLevelExternal;
      when(mockApi.getSupportedHardwareLevel(camera2CameraInfoId))
          .thenReturn(expectedSupportedHardwareLevel);
      expect(await camera2CameraInfo.getSupportedHardwareLevel(),
          equals(expectedSupportedHardwareLevel));

      verify(mockApi.getSupportedHardwareLevel(camera2CameraInfoId));
    });

    test('getCameraId makes call to retrieve camera ID', () async {
      final MockTestCamera2CameraInfoHostApi mockApi =
          MockTestCamera2CameraInfoHostApi();
      TestCamera2CameraInfoHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final Camera2CameraInfo camera2CameraInfo = Camera2CameraInfo.detached(
        instanceManager: instanceManager,
      );
      const int camera2CameraInfoId = 19;

      instanceManager.addHostCreatedInstance(
        camera2CameraInfo,
        camera2CameraInfoId,
        onCopy: (_) => Camera2CameraInfo.detached(),
      );

      const String expectedCameraId = 'testCameraId';
      when(mockApi.getCameraId(camera2CameraInfoId))
          .thenReturn(expectedCameraId);
      expect(await camera2CameraInfo.getCameraId(), equals(expectedCameraId));

      verify(mockApi.getCameraId(camera2CameraInfoId));
    });

    test('flutterApi create makes call to create expected instance type', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final Camera2CameraInfoFlutterApi flutterApi =
          Camera2CameraInfoFlutterApiImpl(
        instanceManager: instanceManager,
      );

      flutterApi.create(0);

      expect(instanceManager.getInstanceWithWeakReference(0),
          isA<Camera2CameraInfo>());
    });
  });
}
