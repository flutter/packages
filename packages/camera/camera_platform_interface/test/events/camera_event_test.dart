// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CameraInitializedEvent tests', () {
    test('Constructor should initialize all properties', () {
      const event = CameraInitializedEvent(
        1,
        1024,
        640,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        true,
      );

      expect(event.cameraId, 1);
      expect(event.previewWidth, 1024);
      expect(event.previewHeight, 640);
      expect(event.exposureMode, ExposureMode.auto);
      expect(event.focusMode, FocusMode.auto);
      expect(event.exposurePointSupported, true);
      expect(event.focusPointSupported, true);
    });

    test('equals should return true if objects are the same', () {
      const firstEvent = CameraInitializedEvent(
        1,
        1024,
        640,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        true,
      );
      const secondEvent = CameraInitializedEvent(
        1,
        1024,
        640,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        true,
      );

      expect(firstEvent == secondEvent, true);
    });

    test('equals should return false if cameraId is different', () {
      const firstEvent = CameraInitializedEvent(
        1,
        1024,
        640,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        true,
      );
      const secondEvent = CameraInitializedEvent(
        2,
        1024,
        640,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        true,
      );

      expect(firstEvent == secondEvent, false);
    });

    test('equals should return false if previewWidth is different', () {
      const firstEvent = CameraInitializedEvent(
        1,
        1024,
        640,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        true,
      );
      const secondEvent = CameraInitializedEvent(
        1,
        2048,
        640,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        true,
      );

      expect(firstEvent == secondEvent, false);
    });

    test('equals should return false if previewHeight is different', () {
      const firstEvent = CameraInitializedEvent(
        1,
        1024,
        640,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        true,
      );
      const secondEvent = CameraInitializedEvent(
        1,
        1024,
        980,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        true,
      );

      expect(firstEvent == secondEvent, false);
    });

    test('equals should return false if exposureMode is different', () {
      const firstEvent = CameraInitializedEvent(
        1,
        1024,
        640,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        true,
      );
      const secondEvent = CameraInitializedEvent(
        1,
        1024,
        640,
        ExposureMode.locked,
        true,
        FocusMode.auto,
        true,
      );

      expect(firstEvent == secondEvent, false);
    });

    test('equals should return false if exposurePointSupported is different', () {
      const firstEvent = CameraInitializedEvent(
        1,
        1024,
        640,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        true,
      );
      const secondEvent = CameraInitializedEvent(
        1,
        1024,
        640,
        ExposureMode.auto,
        false,
        FocusMode.auto,
        true,
      );

      expect(firstEvent == secondEvent, false);
    });

    test('equals should return false if focusMode is different', () {
      const firstEvent = CameraInitializedEvent(
        1,
        1024,
        640,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        true,
      );
      const secondEvent = CameraInitializedEvent(
        1,
        1024,
        640,
        ExposureMode.auto,
        true,
        FocusMode.locked,
        true,
      );

      expect(firstEvent == secondEvent, false);
    });

    test('equals should return false if focusPointSupported is different', () {
      const firstEvent = CameraInitializedEvent(
        1,
        1024,
        640,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        true,
      );
      const secondEvent = CameraInitializedEvent(
        1,
        1024,
        640,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        false,
      );

      expect(firstEvent == secondEvent, false);
    });

    test('hashCode should match hashCode of all properties', () {
      const event = CameraInitializedEvent(
        1,
        1024,
        640,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        true,
      );
      final int expectedHashCode = Object.hash(
        event.cameraId.hashCode,
        event.previewWidth,
        event.previewHeight,
        event.exposureMode,
        event.exposurePointSupported,
        event.focusMode,
        event.focusPointSupported,
      );

      expect(event.hashCode, expectedHashCode);
    });
  });

  group('CameraResolutionChangesEvent tests', () {
    test('Constructor should initialize all properties', () {
      const event = CameraResolutionChangedEvent(1, 1024, 640);

      expect(event.cameraId, 1);
      expect(event.captureWidth, 1024);
      expect(event.captureHeight, 640);
    });

    test('equals should return true if objects are the same', () {
      const firstEvent = CameraResolutionChangedEvent(1, 1024, 640);
      const secondEvent = CameraResolutionChangedEvent(1, 1024, 640);

      expect(firstEvent == secondEvent, true);
    });

    test('equals should return false if cameraId is different', () {
      const firstEvent = CameraResolutionChangedEvent(1, 1024, 640);
      const secondEvent = CameraResolutionChangedEvent(2, 1024, 640);

      expect(firstEvent == secondEvent, false);
    });

    test('equals should return false if captureWidth is different', () {
      const firstEvent = CameraResolutionChangedEvent(1, 1024, 640);
      const secondEvent = CameraResolutionChangedEvent(1, 2048, 640);

      expect(firstEvent == secondEvent, false);
    });

    test('equals should return false if captureHeight is different', () {
      const firstEvent = CameraResolutionChangedEvent(1, 1024, 640);
      const secondEvent = CameraResolutionChangedEvent(1, 1024, 980);

      expect(firstEvent == secondEvent, false);
    });

    test('hashCode should match hashCode of all properties', () {
      const event = CameraResolutionChangedEvent(1, 1024, 640);
      final int expectedHashCode = Object.hash(
        event.cameraId.hashCode,
        event.captureWidth,
        event.captureHeight,
      );

      expect(event.hashCode, expectedHashCode);
    });
  });

  group('CameraClosingEvent tests', () {
    test('Constructor should initialize all properties', () {
      const event = CameraClosingEvent(1);

      expect(event.cameraId, 1);
    });

    test('equals should return true if objects are the same', () {
      const firstEvent = CameraClosingEvent(1);
      const secondEvent = CameraClosingEvent(1);

      expect(firstEvent == secondEvent, true);
    });

    test('equals should return false if cameraId is different', () {
      const firstEvent = CameraClosingEvent(1);
      const secondEvent = CameraClosingEvent(2);

      expect(firstEvent == secondEvent, false);
    });

    test('hashCode should match hashCode of all properties', () {
      const event = CameraClosingEvent(1);
      final expectedHashCode = event.cameraId.hashCode;

      expect(event.hashCode, expectedHashCode);
    });
  });

  group('CameraErrorEvent tests', () {
    test('Constructor should initialize all properties', () {
      const event = CameraErrorEvent(1, 'Error');

      expect(event.cameraId, 1);
      expect(event.description, 'Error');
    });

    test('equals should return true if objects are the same', () {
      const firstEvent = CameraErrorEvent(1, 'Error');
      const secondEvent = CameraErrorEvent(1, 'Error');

      expect(firstEvent == secondEvent, true);
    });

    test('equals should return false if cameraId is different', () {
      const firstEvent = CameraErrorEvent(1, 'Error');
      const secondEvent = CameraErrorEvent(2, 'Error');

      expect(firstEvent == secondEvent, false);
    });

    test('equals should return false if description is different', () {
      const firstEvent = CameraErrorEvent(1, 'Error');
      const secondEvent = CameraErrorEvent(1, 'Ooops');

      expect(firstEvent == secondEvent, false);
    });

    test('hashCode should match hashCode of all properties', () {
      const event = CameraErrorEvent(1, 'Error');
      final int expectedHashCode = Object.hash(event.cameraId.hashCode, event.description);

      expect(event.hashCode, expectedHashCode);
    });
  });
}
