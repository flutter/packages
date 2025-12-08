// Copyright 2013 The Flutter Authors
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

  group('CameraDescription tests', () {
    test('Constructor should initialize all properties', () {
      const description = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
        lensType: CameraLensType.ultraWide,
      );

      expect(description.name, 'Test');
      expect(description.lensDirection, CameraLensDirection.front);
      expect(description.sensorOrientation, 90);
      expect(description.lensType, CameraLensType.ultraWide);
    });

    test('equals should return true if objects are the same', () {
      const firstDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
        lensType: CameraLensType.ultraWide,
      );
      const secondDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
        lensType: CameraLensType.ultraWide,
      );

      expect(firstDescription == secondDescription, true);
    });

    test('equals should return false if name is different', () {
      const firstDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
        lensType: CameraLensType.ultraWide,
      );
      const secondDescription = CameraDescription(
        name: 'Testing',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
        lensType: CameraLensType.ultraWide,
      );

      expect(firstDescription == secondDescription, false);
    });

    test('equals should return false if lens direction is different', () {
      const firstDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
        lensType: CameraLensType.ultraWide,
      );
      const secondDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
        lensType: CameraLensType.ultraWide,
      );

      expect(firstDescription == secondDescription, false);
    });

    test('equals should return true if sensor orientation is different', () {
      const firstDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 0,
        lensType: CameraLensType.ultraWide,
      );
      const secondDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
        lensType: CameraLensType.ultraWide,
      );

      expect(firstDescription == secondDescription, true);
    });

    test(
      'hashCode should match hashCode of all equality-tested properties',
      () {
        const description = CameraDescription(
          name: 'Test',
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 0,
          lensType: CameraLensType.ultraWide,
        );
        final int expectedHashCode = Object.hash(
          description.name,
          description.lensDirection,
          description.lensType,
        );

        expect(description.hashCode, expectedHashCode);
      },
    );

    test('toString should return correct string representation', () {
      const description = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
        lensType: CameraLensType.ultraWide,
      );

      expect(
        description.toString(),
        'CameraDescription(Test, CameraLensDirection.front, 90, CameraLensType.ultraWide)',
      );
    });
  });
}
