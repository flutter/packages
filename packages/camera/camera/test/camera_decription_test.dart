// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('camera_description', () {
    test('Can be created with appleCaptureDeviceType', () {
      const CameraDescription cameraDescription = CameraDescription(
        name: 'cam',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
        appleCaptureDeviceType: AppleCaptureDeviceType.builtInWideAngleCamera,
      );

      expect(cameraDescription, isA<CameraDescription>());
      expect(cameraDescription.name, 'cam');
      expect(cameraDescription.lensDirection, CameraLensDirection.back);
      expect(cameraDescription.sensorOrientation, 90);
      expect(cameraDescription.appleCaptureDeviceType,
          AppleCaptureDeviceType.builtInWideAngleCamera);
    });

    test('Can be created without appleCaptureDeviceType', () {
      const CameraDescription cameraDescription = CameraDescription(
        name: 'cam',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
      );

      expect(cameraDescription, isA<CameraDescription>());
      expect(cameraDescription.name, 'cam');
      expect(cameraDescription.lensDirection, CameraLensDirection.back);
      expect(cameraDescription.sensorOrientation, 90);
      expect(cameraDescription.appleCaptureDeviceType, null);
    });
  });
}
