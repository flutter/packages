// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceOrientationChangedEvent tests', () {
    test('Constructor should initialize all properties', () {
      const event = DeviceOrientationChangedEvent(DeviceOrientation.portraitUp);

      expect(event.orientation, DeviceOrientation.portraitUp);
    });

    test('equals should return true if objects are the same', () {
      const firstEvent = DeviceOrientationChangedEvent(DeviceOrientation.portraitUp);
      const secondEvent = DeviceOrientationChangedEvent(DeviceOrientation.portraitUp);

      expect(firstEvent == secondEvent, true);
    });

    test('equals should return false if orientation is different', () {
      const firstEvent = DeviceOrientationChangedEvent(DeviceOrientation.portraitUp);
      const secondEvent = DeviceOrientationChangedEvent(DeviceOrientation.landscapeLeft);

      expect(firstEvent == secondEvent, false);
    });

    test('hashCode should match hashCode of all properties', () {
      const event = DeviceOrientationChangedEvent(DeviceOrientation.portraitUp);
      final expectedHashCode = event.orientation.hashCode;

      expect(event.hashCode, expectedHashCode);
    });
  });
}
