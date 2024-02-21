// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camera_control.dart';
import 'package:camera_android_camerax/src/focus_metering_action.dart';
import 'package:camera_android_camerax/src/focus_metering_result.dart';
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

    test(
        'startFocusAndMetering makes call on Java side to start focus and metering and returns expected result',
        () async {
      final MockTestCameraControlHostApi mockApi =
          MockTestCameraControlHostApi();
      TestCameraControlHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final CameraControl cameraControl = CameraControl.detached(
        instanceManager: instanceManager,
      );
      const int cameraControlIdentifier = 75;
      final FocusMeteringAction action =
          FocusMeteringAction.detached(instanceManager: instanceManager);
      const int actionId = 5;
      final FocusMeteringResult result =
          FocusMeteringResult.detached(instanceManager: instanceManager);
      const int resultId = 2;

      instanceManager.addHostCreatedInstance(
        cameraControl,
        cameraControlIdentifier,
        onCopy: (_) => CameraControl.detached(instanceManager: instanceManager),
      );
      instanceManager.addHostCreatedInstance(
        action,
        actionId,
        onCopy: (_) =>
            FocusMeteringAction.detached(instanceManager: instanceManager),
      );
      instanceManager.addHostCreatedInstance(
        result,
        resultId,
        onCopy: (_) =>
            FocusMeteringResult.detached(instanceManager: instanceManager),
      );

      when(mockApi.startFocusAndMetering(cameraControlIdentifier, actionId))
          .thenAnswer((_) => Future<int>.value(resultId));

      expect(await cameraControl.startFocusAndMetering(action), equals(result));
      verify(mockApi.startFocusAndMetering(cameraControlIdentifier, actionId));
    });

    test(
        'cancelFocusAndMetering makes call on Java side to cancel focus and metering',
        () async {
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

      await cameraControl.cancelFocusAndMetering();

      verify(mockApi.cancelFocusAndMetering(cameraControlIdentifier));
    });

    test(
        'setExposureCompensationIndex makes call on Java side to set index and returns expected target exposure value',
        () async {
      final MockTestCameraControlHostApi mockApi =
          MockTestCameraControlHostApi();
      TestCameraControlHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final CameraControl cameraControl = CameraControl.detached(
        instanceManager: instanceManager,
      );
      const int cameraControlIdentifier = 40;

      instanceManager.addHostCreatedInstance(
        cameraControl,
        cameraControlIdentifier,
        onCopy: (_) => CameraControl.detached(instanceManager: instanceManager),
      );

      const int index = 3;
      const int fakeTargetExposureValue = 2;
      when(mockApi.setExposureCompensationIndex(cameraControlIdentifier, index))
          .thenAnswer((_) => Future<int>.value(fakeTargetExposureValue));

      expect(await cameraControl.setExposureCompensationIndex(index),
          equals(fakeTargetExposureValue));
      verify(
          mockApi.setExposureCompensationIndex(cameraControlIdentifier, index));
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
