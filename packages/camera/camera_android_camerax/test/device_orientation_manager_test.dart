// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/device_orientation_manager.dart';
import 'package:camera_android_camerax/src/surface.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart'
    show DeviceOrientationChangedEvent;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'device_orientation_manager_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(
    <Type>[TestInstanceManagerHostApi, TestDeviceOrientationManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('DeviceOrientationManager', () {
    tearDown(() => TestProcessCameraProviderHostApi.setup(null));

    test(
        'startListeningForDeviceOrientationChange makes request to start listening for new device orientations',
        () async {
      final MockTestDeviceOrientationManagerHostApi mockApi =
          MockTestDeviceOrientationManagerHostApi();
      TestDeviceOrientationManagerHostApi.setup(mockApi);

      DeviceOrientationManager.startListeningForDeviceOrientationChange(
          true, 90);
      verify(mockApi.startListeningForDeviceOrientationChange(true, 90));
    });

    test(
        'stopListeningForDeviceOrientationChange makes request to stop listening for new device orientations',
        () async {
      final MockTestDeviceOrientationManagerHostApi mockApi =
          MockTestDeviceOrientationManagerHostApi();
      TestDeviceOrientationManagerHostApi.setup(mockApi);

      DeviceOrientationManager.stopListeningForDeviceOrientationChange();
      verify(mockApi.stopListeningForDeviceOrientationChange());
    });

    test('getDefaultDisplayRotation retrieves expected rotation', () async {
      final MockTestDeviceOrientationManagerHostApi mockApi =
          MockTestDeviceOrientationManagerHostApi();
      TestDeviceOrientationManagerHostApi.setup(mockApi);
      const int expectedRotation = Surface.rotation180;

      when(mockApi.getDefaultDisplayRotation()).thenReturn(expectedRotation);

      expect(await DeviceOrientationManager.getDefaultDisplayRotation(),
          equals(expectedRotation));
      verify(mockApi.getDefaultDisplayRotation());
    });

    test('getUiOrientation returns expected orientation', () async {
      final MockTestDeviceOrientationManagerHostApi mockApi =
          MockTestDeviceOrientationManagerHostApi();
      TestDeviceOrientationManagerHostApi.setup(mockApi);
      const DeviceOrientation expectedOrientation =
          DeviceOrientation.landscapeRight;

      when(mockApi.getUiOrientation()).thenReturn('LANDSCAPE_RIGHT');

      expect(await DeviceOrientationManager.getUiOrientation(),
          equals(expectedOrientation));
      verify(mockApi.getUiOrientation());
    });

    test('onDeviceOrientationChanged adds new orientation to stream', () {
      DeviceOrientationManager.deviceOrientationChangedStreamController.stream
          .listen((DeviceOrientationChangedEvent event) {
        expect(event.orientation, equals(DeviceOrientation.landscapeLeft));
      });
      DeviceOrientationManagerFlutterApiImpl()
          .onDeviceOrientationChanged('LANDSCAPE_LEFT');
    });

    test(
        'onDeviceOrientationChanged throws error if new orientation is invalid',
        () {
      expect(
          () => DeviceOrientationManagerFlutterApiImpl()
              .onDeviceOrientationChanged('FAKE_ORIENTATION'),
          throwsA(isA<ArgumentError>().having(
              (ArgumentError e) => e.message,
              'message',
              '"FAKE_ORIENTATION" is not a valid DeviceOrientation value')));
    });
  });
}
