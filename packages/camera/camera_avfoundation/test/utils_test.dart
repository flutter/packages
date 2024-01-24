// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_avfoundation/src/utils.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Utility methods', () {
    test(
        'Should return CameraLensDirection when valid value is supplied when parsing camera lens direction',
        () {
      expect(
        parseCameraLensDirection('back'),
        CameraLensDirection.back,
      );
      expect(
        parseCameraLensDirection('front'),
        CameraLensDirection.front,
      );
      expect(
        parseCameraLensDirection('external'),
        CameraLensDirection.external,
      );
    });

    test(
        'Should throw ArgumentException when invalid value is supplied when parsing camera lens direction',
        () {
      expect(
        () => parseCameraLensDirection('test'),
        throwsA(isArgumentError),
      );
    });

    test(
        'Should return AppleCaptureDeviceType when valid value is supplied when parsing Apple capture device type',
        () {
      expect(
        parseAppleCaptureDeviceType('builtInWideAngleCamera'),
        AppleCaptureDeviceType.builtInWideAngleCamera,
      );
      expect(
        parseAppleCaptureDeviceType('builtInUltraWideCamera'),
        AppleCaptureDeviceType.builtInUltraWideCamera,
      );
      expect(
        parseAppleCaptureDeviceType('builtInTelephotoCamera'),
        AppleCaptureDeviceType.builtInTelephotoCamera,
      );
      expect(
        parseAppleCaptureDeviceType('builtInDualCamera'),
        AppleCaptureDeviceType.builtInDualCamera,
      );
      expect(
        parseAppleCaptureDeviceType('builtInDualWideCamera'),
        AppleCaptureDeviceType.builtInDualWideCamera,
      );
      expect(
        parseAppleCaptureDeviceType('builtInTripleCamera'),
        AppleCaptureDeviceType.builtInTripleCamera,
      );
      expect(
        parseAppleCaptureDeviceType('continuityCamera'),
        AppleCaptureDeviceType.continuityCamera,
      );
      expect(
        parseAppleCaptureDeviceType('external'),
        AppleCaptureDeviceType.external,
      );
      expect(
        parseAppleCaptureDeviceType('builtInLiDARDepthCamera'),
        AppleCaptureDeviceType.builtInLiDARDepthCamera,
      );
      expect(
        parseAppleCaptureDeviceType('builtInTrueDepthCamera'),
        AppleCaptureDeviceType.builtInTrueDepthCamera,
      );
    });

    test('serializeDeviceOrientation() should serialize correctly', () {
      expect(serializeDeviceOrientation(DeviceOrientation.portraitUp),
          'portraitUp');
      expect(serializeDeviceOrientation(DeviceOrientation.portraitDown),
          'portraitDown');
      expect(serializeDeviceOrientation(DeviceOrientation.landscapeRight),
          'landscapeRight');
      expect(serializeDeviceOrientation(DeviceOrientation.landscapeLeft),
          'landscapeLeft');
    });

    test('deserializeDeviceOrientation() should deserialize correctly', () {
      expect(deserializeDeviceOrientation('portraitUp'),
          DeviceOrientation.portraitUp);
      expect(deserializeDeviceOrientation('portraitDown'),
          DeviceOrientation.portraitDown);
      expect(deserializeDeviceOrientation('landscapeRight'),
          DeviceOrientation.landscapeRight);
      expect(deserializeDeviceOrientation('landscapeLeft'),
          DeviceOrientation.landscapeLeft);
    });
  });
}
