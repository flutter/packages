// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camera_info.dart';
import 'package:camera_android_camerax/src/camera_state.dart';
import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/exposure_state.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/live_data.dart';
import 'package:camera_android_camerax/src/zoom_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'camera_info_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[
  TestCameraInfoHostApi,
  TestInstanceManagerHostApi
], customMocks: <MockSpec<Object>>[
  MockSpec<LiveData<CameraState>>(as: #MockLiveCameraState),
  MockSpec<LiveData<ZoomState>>(as: #MockLiveZoomState),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('CameraInfo', () {
    tearDown(() => TestCameraInfoHostApi.setup(null));

    test(
        'getSensorRotationDegrees makes call to retrieve expected sensor rotation',
        () async {
      final MockTestCameraInfoHostApi mockApi = MockTestCameraInfoHostApi();
      TestCameraInfoHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final CameraInfo cameraInfo = CameraInfo.detached(
        instanceManager: instanceManager,
      );
      instanceManager.addHostCreatedInstance(
        cameraInfo,
        0,
        onCopy: (_) => CameraInfo.detached(),
      );

      when(mockApi.getSensorRotationDegrees(
              instanceManager.getIdentifier(cameraInfo)))
          .thenReturn(90);
      expect(await cameraInfo.getSensorRotationDegrees(), equals(90));

      verify(mockApi.getSensorRotationDegrees(0));
    });

    test('getCameraState makes call to retrieve live camera state', () async {
      final MockTestCameraInfoHostApi mockApi = MockTestCameraInfoHostApi();
      TestCameraInfoHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final CameraInfo cameraInfo = CameraInfo.detached(
        instanceManager: instanceManager,
      );
      const int cameraIdentifier = 55;
      final MockLiveCameraState mockLiveCameraState = MockLiveCameraState();
      const int liveCameraStateIdentifier = 73;
      instanceManager.addHostCreatedInstance(
        cameraInfo,
        cameraIdentifier,
        onCopy: (_) => CameraInfo.detached(),
      );
      instanceManager.addHostCreatedInstance(
        mockLiveCameraState,
        liveCameraStateIdentifier,
        onCopy: (_) => MockLiveCameraState(),
      );

      when(mockApi.getCameraState(cameraIdentifier))
          .thenReturn(liveCameraStateIdentifier);

      expect(await cameraInfo.getCameraState(), equals(mockLiveCameraState));
      verify(mockApi.getCameraState(cameraIdentifier));
    });

    test('getExposureState makes call to retrieve expected ExposureState',
        () async {
      final MockTestCameraInfoHostApi mockApi = MockTestCameraInfoHostApi();
      TestCameraInfoHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final CameraInfo cameraInfo = CameraInfo.detached(
        instanceManager: instanceManager,
      );
      const int cameraInfoIdentifier = 4;
      final ExposureState exposureState = ExposureState.detached(
        exposureCompensationRange:
            ExposureCompensationRange(maxCompensation: 0, minCompensation: 1),
        exposureCompensationStep: 4,
        instanceManager: instanceManager,
      );
      const int exposureStateIdentifier = 45;

      instanceManager.addHostCreatedInstance(
        cameraInfo,
        cameraInfoIdentifier,
        onCopy: (_) => CameraInfo.detached(),
      );
      instanceManager.addHostCreatedInstance(
        exposureState,
        exposureStateIdentifier,
        onCopy: (_) => ExposureState.detached(
            exposureCompensationRange: ExposureCompensationRange(
                maxCompensation: 0, minCompensation: 1),
            exposureCompensationStep: 4),
      );

      when(mockApi.getExposureState(cameraInfoIdentifier))
          .thenReturn(exposureStateIdentifier);
      expect(await cameraInfo.getExposureState(), equals(exposureState));

      verify(mockApi.getExposureState(cameraInfoIdentifier));
    });

    test('getZoomState makes call to retrieve expected ZoomState', () async {
      final MockTestCameraInfoHostApi mockApi = MockTestCameraInfoHostApi();
      TestCameraInfoHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final CameraInfo cameraInfo = CameraInfo.detached(
        instanceManager: instanceManager,
      );
      const int cameraInfoIdentifier = 2;
      final MockLiveZoomState mockLiveZoomState = MockLiveZoomState();
      const int mockLiveZoomStateIdentifier = 55;

      instanceManager.addHostCreatedInstance(
        cameraInfo,
        cameraInfoIdentifier,
        onCopy: (_) => CameraInfo.detached(),
      );
      instanceManager.addHostCreatedInstance(
          mockLiveZoomState, mockLiveZoomStateIdentifier,
          onCopy: (_) => MockLiveZoomState());

      when(mockApi.getZoomState(cameraInfoIdentifier))
          .thenReturn(mockLiveZoomStateIdentifier);
      expect(await cameraInfo.getZoomState(), equals(mockLiveZoomState));

      verify(mockApi.getZoomState(cameraInfoIdentifier));
    });

    test('flutterApi create makes call to create expected instance type', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final CameraInfoFlutterApi flutterApi = CameraInfoFlutterApiImpl(
        instanceManager: instanceManager,
      );

      flutterApi.create(0);

      expect(
          instanceManager.getInstanceWithWeakReference(0), isA<CameraInfo>());
    });
  });
}
