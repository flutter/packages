// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android/src/messages.g.dart';
import 'package:camera_android/src/utils.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Utility methods', () {
    test(
        'Should return CameraLensDirection when valid value is supplied when parsing camera lens direction',
        () {
      expect(
        cameraLensDirectionFromPlatform(PlatformCameraLensDirection.back),
        CameraLensDirection.back,
      );
      expect(
        cameraLensDirectionFromPlatform(PlatformCameraLensDirection.front),
        CameraLensDirection.front,
      );
      expect(
        cameraLensDirectionFromPlatform(PlatformCameraLensDirection.external),
        CameraLensDirection.external,
      );
    });

    test('deviceOrientationFromPlatform() should convert correctly', () {
      expect(
          deviceOrientationFromPlatform(PlatformDeviceOrientation.portraitUp),
          DeviceOrientation.portraitUp);
      expect(
          deviceOrientationFromPlatform(PlatformDeviceOrientation.portraitDown),
          DeviceOrientation.portraitDown);
      expect(
          deviceOrientationFromPlatform(
              PlatformDeviceOrientation.landscapeRight),
          DeviceOrientation.landscapeRight);
      expect(
          deviceOrientationFromPlatform(
              PlatformDeviceOrientation.landscapeLeft),
          DeviceOrientation.landscapeLeft);
    });

    test('exposureModeFromPlatform() should convert correctly', () {
      expect(exposureModeFromPlatform(PlatformExposureMode.auto),
          ExposureMode.auto);
      expect(exposureModeFromPlatform(PlatformExposureMode.locked),
          ExposureMode.locked);
    });

    test('focusModeFromPlatform() should convert correctly', () {
      expect(focusModeFromPlatform(PlatformFocusMode.auto), FocusMode.auto);
      expect(focusModeFromPlatform(PlatformFocusMode.locked), FocusMode.locked);
    });
  });
}
