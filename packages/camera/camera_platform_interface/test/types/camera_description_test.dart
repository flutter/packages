// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CameraLensDirection tests', () {
    test('CameraLensDirection should contain 3 options', () {
      const List<CameraLensDirection> values = CameraLensDirection.values;

      expect(values.length, 3);
    });

    test('CameraLensDirection enum should have items in correct index', () {
      const List<CameraLensDirection> values = CameraLensDirection.values;

      expect(values[0], CameraLensDirection.front);
      expect(values[1], CameraLensDirection.back);
      expect(values[2], CameraLensDirection.external);
    });
  });

  group('AVCaptureDeviceType tests', () {
    test('AVCaptureDeviceType should contain 8 options', () {
      const List<AVCaptureDeviceType> values = AVCaptureDeviceType.values;

      expect(values.length, 9);
    });

    test('CameraLensDirection enum should have items in correct index', () {
      const List<AVCaptureDeviceType> values = AVCaptureDeviceType.values;

      expect(values[0], AVCaptureDeviceType.wideAngleCamera);
      expect(values[1], AVCaptureDeviceType.telephotoCamera);
      expect(values[2], AVCaptureDeviceType.ultraWideCamera);
      expect(values[3], AVCaptureDeviceType.dualCamera);
      expect(values[4], AVCaptureDeviceType.dualWideCamera);
      expect(values[5], AVCaptureDeviceType.tripleCamera);
      expect(values[6], AVCaptureDeviceType.trueDepthCamera);
      expect(values[7], AVCaptureDeviceType.liDARDepthCamera);
      expect(values[8], AVCaptureDeviceType.unknown);
    });

    test('CameraLensDirection enum should have items with correct name', () {
      expect(AVCaptureDeviceType.wideAngleCamera.name,
          'AVCaptureDeviceTypeBuiltInWideAngleCamera');
      expect(AVCaptureDeviceType.telephotoCamera.name,
          'AVCaptureDeviceTypeBuiltInTelephotoCamera');
      expect(AVCaptureDeviceType.ultraWideCamera.name,
          'AVCaptureDeviceTypeBuiltInUltraWideCamera');
      expect(AVCaptureDeviceType.dualCamera.name,
          'AVCaptureDeviceTypeBuiltInDualCamera');
      expect(AVCaptureDeviceType.dualWideCamera.name,
          'AVCaptureDeviceTypeBuiltInDualWideCamera');
      expect(AVCaptureDeviceType.tripleCamera.name,
          'AVCaptureDeviceTypeBuiltInTripleCamera');
      expect(AVCaptureDeviceType.trueDepthCamera.name,
          'AVCaptureDeviceTypeBuiltInTrueDepthCamera');
      expect(AVCaptureDeviceType.liDARDepthCamera.name,
          'AVCaptureDeviceTypeBuiltInLiDARDepthCamera');
      expect(AVCaptureDeviceType.unknown.name, null);
    });
  });

  group('CameraDescription tests', () {
    test('Constructor should initialize all properties', () {
      const CameraDescription description = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
        cameraType: AVCaptureDeviceType.dualCamera,
      );

      expect(description.name, 'Test');
      expect(description.lensDirection, CameraLensDirection.front);
      expect(description.sensorOrientation, 90);
      expect(description.cameraType, AVCaptureDeviceType.dualCamera);
    });

    test('equals should return true if objects are the same', () {
      const CameraDescription firstDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
        cameraType: AVCaptureDeviceType.dualCamera,
      );
      const CameraDescription secondDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
        cameraType: AVCaptureDeviceType.dualCamera,
      );

      expect(firstDescription == secondDescription, true);
    });

    test('equals should return false if name is different', () {
      const CameraDescription firstDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
      );
      const CameraDescription secondDescription = CameraDescription(
        name: 'Testing',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
      );

      expect(firstDescription == secondDescription, false);
    });

    test('equals should return false if lens direction is different', () {
      const CameraDescription firstDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
      );
      const CameraDescription secondDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
      );

      expect(firstDescription == secondDescription, false);
    });

    test('equals should return true if sensor orientation is different', () {
      const CameraDescription firstDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 0,
      );
      const CameraDescription secondDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
      );

      expect(firstDescription == secondDescription, true);
    });

    test('equals should return false if camera type is different', () {
      const CameraDescription firstDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
        cameraType: AVCaptureDeviceType.dualCamera,
      );
      const CameraDescription secondDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
      );

      expect(firstDescription == secondDescription, false);
    });

    test('hashCode should match hashCode of all equality-tested properties',
        () {
      const CameraDescription description = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 0,
      );
      final int expectedHashCode = Object.hash(
        description.name,
        description.lensDirection,
        description.cameraType,
      );

      expect(description.hashCode, expectedHashCode);
    });
  });
}
