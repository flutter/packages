// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camera_info.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/metering_point.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'metering_point_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(
    <Type>[TestInstanceManagerHostApi, TestMeteringPointHostApi, CameraInfo])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('MeteringPoint', () {
    tearDown(() => TestMeteringPointHostApi.setup(null));

    test('detached create does not call create on the Java side', () async {
      final MockTestMeteringPointHostApi mockApi =
          MockTestMeteringPointHostApi();
      TestMeteringPointHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      MeteringPoint.detached(
        x: 0,
        y: 0.3,
        size: 4,
        cameraInfo: MockCameraInfo(),
        instanceManager: instanceManager,
      );

      verifyNever(mockApi.create(argThat(isA<int>()), argThat(isA<int>()),
          argThat(isA<int>()), argThat(isA<int>()), argThat(isA<int>())));
    }, skip: 'Flaky test: https://github.com/flutter/flutter/issues/164132');

    test('create calls create on the Java side', () async {
      final MockTestMeteringPointHostApi mockApi =
          MockTestMeteringPointHostApi();
      TestMeteringPointHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      const double x = 0.5;
      const double y = 0.6;
      const double size = 3;
      final CameraInfo mockCameraInfo = MockCameraInfo();
      const int mockCameraInfoId = 4;

      instanceManager.addHostCreatedInstance(mockCameraInfo, mockCameraInfoId,
          onCopy: (CameraInfo original) => MockCameraInfo());

      MeteringPoint(
        x: x,
        y: y,
        size: size,
        cameraInfo: mockCameraInfo,
        instanceManager: instanceManager,
      );

      verify(mockApi.create(
        argThat(isA<int>()),
        x,
        y,
        size,
        mockCameraInfoId,
      ));
    });

    test('getDefaultPointSize returns expected size', () async {
      final MockTestMeteringPointHostApi mockApi =
          MockTestMeteringPointHostApi();
      TestMeteringPointHostApi.setup(mockApi);

      const double defaultPointSize = 6;
      when(mockApi.getDefaultPointSize()).thenAnswer((_) => defaultPointSize);

      expect(
          await MeteringPoint.getDefaultPointSize(), equals(defaultPointSize));
      verify(mockApi.getDefaultPointSize());
    });
  });
}
