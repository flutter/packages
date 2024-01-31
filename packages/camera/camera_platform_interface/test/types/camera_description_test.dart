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

  group('AppleCaptureDeviceType tests', () {
    test('AppleCaptureDeviceType should contain 10 options', () {
      const List<AppleCaptureDeviceType> values = AppleCaptureDeviceType.values;

      expect(values.length, 10);
    });

    test('AppleCaptureDeviceType enum should have items in correct index', () {
      const List<AppleCaptureDeviceType> values = AppleCaptureDeviceType.values;

      expect(values[0], AppleCaptureDeviceType.builtInWideAngleCamera);
      expect(values[1], AppleCaptureDeviceType.builtInUltraWideCamera);
      expect(values[2], AppleCaptureDeviceType.builtInTelephotoCamera);
      expect(values[3], AppleCaptureDeviceType.builtInDualCamera);
      expect(values[4], AppleCaptureDeviceType.builtInDualWideCamera);
      expect(values[5], AppleCaptureDeviceType.builtInTripleCamera);
      expect(values[6], AppleCaptureDeviceType.continuityCamera);
      expect(values[7], AppleCaptureDeviceType.external);
      expect(values[8], AppleCaptureDeviceType.builtInLiDARDepthCamera);
      expect(values[9], AppleCaptureDeviceType.builtInTrueDepthCamera);
    });
  });

  group('CameraDescription tests', () {
    test('Constructor should initialize all properties', () {
      const CameraDescription description = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
        appleCaptureDeviceType: AppleCaptureDeviceType.builtInWideAngleCamera,
      );

      expect(description.name, 'Test');
      expect(description.lensDirection, CameraLensDirection.front);
      expect(description.sensorOrientation, 90);
      expect(description.appleCaptureDeviceType,
          AppleCaptureDeviceType.builtInWideAngleCamera);
    });

    test('equals should return true if objects are the same', () {
      const CameraDescription firstDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
        appleCaptureDeviceType: AppleCaptureDeviceType.builtInWideAngleCamera,
      );
      const CameraDescription secondDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
        appleCaptureDeviceType: AppleCaptureDeviceType.builtInWideAngleCamera,
      );

      expect(firstDescription == secondDescription, true);
    });

    test('equals should return false if name is different', () {
      const CameraDescription firstDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
        appleCaptureDeviceType: AppleCaptureDeviceType.builtInWideAngleCamera,
      );
      const CameraDescription secondDescription = CameraDescription(
        name: 'Testing',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
        appleCaptureDeviceType: AppleCaptureDeviceType.builtInWideAngleCamera,
      );

      expect(firstDescription == secondDescription, false);
    });

    test('equals should return false if lens direction is different', () {
      const CameraDescription firstDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
        appleCaptureDeviceType: AppleCaptureDeviceType.builtInWideAngleCamera,
      );
      const CameraDescription secondDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
        appleCaptureDeviceType: AppleCaptureDeviceType.builtInWideAngleCamera,
      );

      expect(firstDescription == secondDescription, false);
    });

    test('equals should return true if sensor orientation is different', () {
      const CameraDescription firstDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 0,
        appleCaptureDeviceType: AppleCaptureDeviceType.builtInWideAngleCamera,
      );
      const CameraDescription secondDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
        appleCaptureDeviceType: AppleCaptureDeviceType.builtInWideAngleCamera,
      );

      expect(firstDescription == secondDescription, true);
    });

    test('equals should return false if apple capture device type is different',
        () {
      const CameraDescription firstDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 0,
        appleCaptureDeviceType: AppleCaptureDeviceType.builtInWideAngleCamera,
      );
      const CameraDescription secondDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 0,
        appleCaptureDeviceType: AppleCaptureDeviceType.builtInUltraWideCamera,
      );

      expect(firstDescription == secondDescription, false);
    });

    test('equals should return false if one apple capture device type is null',
        () {
      const CameraDescription firstDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 0,
        appleCaptureDeviceType: AppleCaptureDeviceType.builtInWideAngleCamera,
      );
      const CameraDescription secondDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 0,
      );

      expect(firstDescription == secondDescription, false);
    });

    test('equals should return true if apple capture device type is null', () {
      const CameraDescription firstDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 0,
      );
      const CameraDescription secondDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 0,
      );

      expect(firstDescription == secondDescription, true);
    });

    test('hashCode should match hashCode of all equality-tested properties',
        () {
      const CameraDescription description = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 0,
        appleCaptureDeviceType: AppleCaptureDeviceType.builtInWideAngleCamera,
      );
      final int expectedHashCode = Object.hash(description.name,
          description.lensDirection, description.appleCaptureDeviceType);

      expect(description.hashCode, expectedHashCode);
    });
  });
}
