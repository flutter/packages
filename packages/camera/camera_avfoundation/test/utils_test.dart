// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_avfoundation/src/messages.g.dart';
import 'package:camera_avfoundation/src/utils.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Utility methods', () {
    test('Should convert CameraLensDirection values correctly', () {
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

    test('serializeDeviceOrientation() should serialize correctly', () {
      expect(serializeDeviceOrientation(DeviceOrientation.portraitUp),
          PlatformDeviceOrientation.portraitUp);
      expect(serializeDeviceOrientation(DeviceOrientation.portraitDown),
          PlatformDeviceOrientation.portraitDown);
      expect(serializeDeviceOrientation(DeviceOrientation.landscapeRight),
          PlatformDeviceOrientation.landscapeRight);
      expect(serializeDeviceOrientation(DeviceOrientation.landscapeLeft),
          PlatformDeviceOrientation.landscapeLeft);
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
  });
}
