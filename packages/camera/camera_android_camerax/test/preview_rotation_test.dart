// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/camera_android_camerax.dart';
import 'package:camera_android_camerax/src/device_orientation_manager.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// Constants to map clockwise degree rotations to quarter turns:
const int _90DegreesClockwise = 1;
const int _270DegreesClockwise = 3;

void main() {
  String getExpectedRotationTestFailureReason(
          int expectedQuarterTurns, int actualQuarterTurns) =>
      'Expected the preview to be rotated by $expectedQuarterTurns quarter turns (which is ${expectedQuarterTurns * 90} degrees clockwise) but instead was rotated $actualQuarterTurns quarter turns.';

  testWidgets(
      'when handlesCropAndRotation is true, the preview is an unrotated Texture',
      (WidgetTester tester) async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 537;

    // Tell camera that createCamera has been called and thus, preview has been
    // bound to the lifecycle of the camera.
    camera.previewInitiallyBound = true;

    // Tell camera that surface producer handles crop and rotation for surfaces
    // that back the camera preivew.
    camera.handlesCropAndRotation = true;

    await tester.pumpWidget(camera.buildPreview(cameraId));

    // Verify Texture was built.
    final Texture texture = tester.widget<Texture>(find.byType(Texture));
    expect(texture.textureId, cameraId);

    // Verify RotatedBox was not built and thus, the Texture is not rotated.
    expect(() => tester.widget<RotatedBox>(find.byType(RotatedBox)),
        throwsStateError);
  });

  group('when handlesCropAndRotation is false,', () {
    // Test that preview rotation responds to initial device orientation:
    group('sensor orientation degrees is 270, camera is front facing,', () {
      late AndroidCameraCameraX camera;
      late int cameraId;

      setUp(() {
        camera = AndroidCameraCameraX();
        cameraId = 27;

        // Tell camera that createCamera has been called and thus, preview has been
        // bound to the lifecycle of the camera.
        camera.previewInitiallyBound = true;

        // Tell camera that surface producer handles crop and rotation for surfaces
        // that back the camera preivew.
        camera.handlesCropAndRotation = false;

        // Set up camera information needed to calculate preview rotation:
        camera.sensorOrientationDegrees = 270;
        camera.cameraIsFrontFacing = true;
      });

      testWidgets(
          'initial device orientation fixed to DeviceOrientation.portraitUp, then the preview Texture is rotated 270 degrees clockwise',
          (WidgetTester tester) async {
        // Set camera initial device orientation to portrait up.
        const DeviceOrientation testInitialDeviceOrientation =
            DeviceOrientation.portraitUp;
        camera.initialDeviceOrientation = testInitialDeviceOrientation;

        await tester.pumpWidget(camera.buildPreview(cameraId));

        // Verify Texture is rotated by ((270 - 0 * 1 + 360) % 360) - 0 = 270 degrees.
        const int expectedQuarterTurns = _270DegreesClockwise;
        final RotatedBox rotatedBox =
            tester.widget<RotatedBox>(find.byType(RotatedBox));
        expect(rotatedBox.child, isA<Texture>());
        expect((rotatedBox.child! as Texture).textureId, cameraId);
        expect(rotatedBox.quarterTurns, expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns, rotatedBox.quarterTurns));
      });

      testWidgets(
          'initial device orientation fixed to DeviceOrientation.landscapeLeft, then the preview Texture is rotated 90 degrees clockwise',
          (WidgetTester tester) async {
        // Set camera initial device orientation to landscape left.
        const DeviceOrientation testInitialDeviceOrientation =
            DeviceOrientation.landscapeLeft;
        camera.initialDeviceOrientation = testInitialDeviceOrientation;

        await tester.pumpWidget(camera.buildPreview(cameraId));

        // Verify Texture is rotated by ((270 - 270 * 1 + 360) % 360) - 270 = -270 degrees clockwise = 270 degrees counterclockwise = 90 degrees.
        const int expectedQuarterTurns = _90DegreesClockwise;
        final RotatedBox rotatedBox =
            tester.widget<RotatedBox>(find.byType(RotatedBox));
        final int clockwiseQuarterTurns = rotatedBox.quarterTurns + 4;
        expect(rotatedBox.child, isA<Texture>());
        expect((rotatedBox.child! as Texture).textureId, cameraId);
        expect(clockwiseQuarterTurns, expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns, rotatedBox.quarterTurns));
      });

      testWidgets(
          'initial device orientation fixed to DeviceOrientation.portraitDown, then the preview Texture is rotated 270 degrees clockwise',
          (WidgetTester tester) async {
        // Set camera initial device orientation to portrait down.
        const DeviceOrientation testInitialDeviceOrientation =
            DeviceOrientation.portraitDown;
        camera.initialDeviceOrientation = testInitialDeviceOrientation;

        await tester.pumpWidget(camera.buildPreview(cameraId));

        // Verify Texture is rotated by ((270 - 180 * 1 + 360) % 360) - 180 = -90 degrees clockwise = 90 degrees counterclockwise = 270 degrees.
        const int expectedQuarterTurns = _270DegreesClockwise;
        final RotatedBox rotatedBox =
            tester.widget<RotatedBox>(find.byType(RotatedBox));
        final int clockwiseQuarterTurns = rotatedBox.quarterTurns + 4;
        expect(rotatedBox.child, isA<Texture>());
        expect((rotatedBox.child! as Texture).textureId, cameraId);
        expect(clockwiseQuarterTurns, expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns, rotatedBox.quarterTurns));
      });

      testWidgets(
          'initial device orientation fixed to DeviceOrientation.landscapeLeft, then the preview Texture is rotated 90 degrees clockwise',
          (WidgetTester tester) async {
        // Set camera initial device orientation to landscape left.
        const DeviceOrientation testInitialDeviceOrientation =
            DeviceOrientation.landscapeLeft;
        camera.initialDeviceOrientation = testInitialDeviceOrientation;

        await tester.pumpWidget(camera.buildPreview(cameraId));

        // Verify Texture is rotated by ((270 - 270 * 1 + 360) % 360) - 270 = -270 degrees clockwise = 270 degrees counterclockwise = 90 degrees.
        const int expectedQuarterTurns = _90DegreesClockwise;
        final RotatedBox rotatedBox =
            tester.widget<RotatedBox>(find.byType(RotatedBox));
        final int clockwiseQuarterTurns = rotatedBox.quarterTurns + 4;
        expect(rotatedBox.child, isA<Texture>());
        expect((rotatedBox.child! as Texture).textureId, cameraId);
        expect(clockwiseQuarterTurns, expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns, rotatedBox.quarterTurns));
      });
    });

    testWidgets(
        'sensor orientation degrees is 90, camera is front facing, then the preview Texture rotates correctly as the device orientation rotates',
        (WidgetTester tester) async {
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const int cameraId = 3372;

      // Tell camera that createCamera has been called and thus, preview has been
      // bound to the lifecycle of the camera.
      camera.previewInitiallyBound = true;

      // Tell camera that surface producer handles crop and rotation for surfaces
      // that back the camera preivew.
      camera.handlesCropAndRotation = false;

      // Set up camera information needed to calculate preview rotation:
      camera.initialDeviceOrientation = DeviceOrientation.portraitDown;
      camera.sensorOrientationDegrees = 90;
      camera.cameraIsFrontFacing = true;

      // Calculated according to:
      // ((90 - currentDeviceOrientation * 1 + 360) % 360) - currentDeviceOrientation.
      final Map<DeviceOrientation, int> expectedRotationPerDeviceOrientation =
          <DeviceOrientation, int>{
        DeviceOrientation.portraitUp: _90DegreesClockwise,
        DeviceOrientation.landscapeRight: _270DegreesClockwise,
        DeviceOrientation.portraitDown: _90DegreesClockwise,
        DeviceOrientation.landscapeLeft: _270DegreesClockwise,
      };

      await tester.pumpWidget(camera.buildPreview(cameraId));

      for (final DeviceOrientation currentDeviceOrientation
          in expectedRotationPerDeviceOrientation.keys) {
        final DeviceOrientationChangedEvent testEvent =
            DeviceOrientationChangedEvent(currentDeviceOrientation);
        DeviceOrientationManager.deviceOrientationChangedStreamController
            .add(testEvent);

        await tester.pumpAndSettle();

        // Verify Texture is rotated by expected clockwise degrees.
        final int expectedQuarterTurns =
            expectedRotationPerDeviceOrientation[currentDeviceOrientation]!;
        final RotatedBox rotatedBox =
            tester.widget<RotatedBox>(find.byType(RotatedBox));
        final int clockwiseQuarterTurns = rotatedBox.quarterTurns < 0
            ? rotatedBox.quarterTurns + 4
            : rotatedBox.quarterTurns;
        expect(rotatedBox.child, isA<Texture>());
        expect((rotatedBox.child! as Texture).textureId, cameraId);
        expect(clockwiseQuarterTurns, expectedQuarterTurns,
            reason:
                'When the device orientation is $currentDeviceOrientation, expected the preview to be rotated by $expectedQuarterTurns quarter turns (which is ${expectedQuarterTurns * 90} degrees clockwise) but instead was rotated ${rotatedBox.quarterTurns} quarter turns.');
      }

      await DeviceOrientationManager.deviceOrientationChangedStreamController
          .close();
    });

    // Test the preview rotation responds to the two most common sensor orientations for Android phone cameras; see
    // https://developer.android.com/media/camera/camera2/camera-preview#camera_orientation.
    group(
        'initial device orientation is DeviceOrientation.landscapeLeft, camera is back facing,',
        () {
      late AndroidCameraCameraX camera;
      late int cameraId;

      setUp(() {
        camera = AndroidCameraCameraX();
        cameraId = 347;

        // Tell camera that createCamera has been called and thus, preview has been
        // bound to the lifecycle of the camera.
        camera.previewInitiallyBound = true;

        // Tell camera that surface producer handles crop and rotation for surfaces
        // that back the camera preivew.
        camera.handlesCropAndRotation = false;

        // Set up camera information needed to calculate preview rotation:
        camera.initialDeviceOrientation = DeviceOrientation.landscapeLeft;
        camera.cameraIsFrontFacing = false;
      });

      testWidgets(
          'sensor orientation degrees is 90, then the preview Texture is rotated 90 degrees clockwise',
          (WidgetTester tester) async {
        camera.sensorOrientationDegrees = 90;

        await tester.pumpWidget(camera.buildPreview(cameraId));

        // Verify Texture is rotated by ((90 - 270 * -1 + 360) % 360) - 270 = -270 degrees clockwise = 270 degrees counterclockwise = 90 degrees clockwise.
        const int expectedQuarterTurns = _90DegreesClockwise;
        final RotatedBox rotatedBox =
            tester.widget<RotatedBox>(find.byType(RotatedBox));
        final int clockwiseQuarterTurns = rotatedBox.quarterTurns + 4;
        expect(rotatedBox.child, isA<Texture>());
        expect((rotatedBox.child! as Texture).textureId, cameraId);
        expect(clockwiseQuarterTurns, expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns, rotatedBox.quarterTurns));
      });

      testWidgets(
          'sensor orientation degrees is 270, then the preview Texture is rotated 270 degrees clockwise',
          (WidgetTester tester) async {
        camera.sensorOrientationDegrees = 270;

        await tester.pumpWidget(camera.buildPreview(cameraId));

        // Verify Texture is rotated by ((270 - 270 * -1 + 360) % 360) - 270 = -90 degrees clockwise = 90 degrees counterclockwise = 270 degrees clockwise.
        const int expectedQuarterTurns = _270DegreesClockwise;
        final RotatedBox rotatedBox =
            tester.widget<RotatedBox>(find.byType(RotatedBox));
        final int clockwiseQuarterTurns = rotatedBox.quarterTurns + 4;
        expect(rotatedBox.child, isA<Texture>());
        expect((rotatedBox.child! as Texture).textureId, cameraId);
        expect(clockwiseQuarterTurns, expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns, rotatedBox.quarterTurns));
      });
    });

    group(
        'initial device orientation is DeviceOrientation.landscapeRight, sensor orientation degrees is 90,',
        () {
      late AndroidCameraCameraX camera;
      late int cameraId;

      setUp(() {
        camera = AndroidCameraCameraX();
        cameraId = 317;

        // Tell camera that createCamera has been called and thus, preview has been
        // bound to the lifecycle of the camera.
        camera.previewInitiallyBound = true;

        // Tell camera that surface producer handles crop and rotation for surfaces
        // that back the camera preivew.
        camera.handlesCropAndRotation = false;

        // Set up camera information needed to calculate preview rotation:
        camera.initialDeviceOrientation = DeviceOrientation.landscapeRight;
        camera.sensorOrientationDegrees = 90;
      });

      testWidgets(
          'camera is front facing, then the preview Texture is rotated 270 degrees clockwise',
          (WidgetTester tester) async {
        camera.cameraIsFrontFacing = true;

        await tester.pumpWidget(camera.buildPreview(cameraId));

        // Verify Texture is rotated by ((90 - 90 * 1 + 360) % 360) - 90 = -90 degrees clockwise = 90 degrees counterclockwise = 270 degrees clockwise.
        const int expectedQuarterTurns = _270DegreesClockwise;
        final RotatedBox rotatedBox =
            tester.widget<RotatedBox>(find.byType(RotatedBox));
        final int clockwiseQuarterTurns = rotatedBox.quarterTurns + 4;
        expect(rotatedBox.child, isA<Texture>());
        expect((rotatedBox.child! as Texture).textureId, cameraId);
        expect(clockwiseQuarterTurns, expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns, rotatedBox.quarterTurns));
      });

      testWidgets(
          'camera is back facing, then the preview Texture is rotated 90 degrees clockwise',
          (WidgetTester tester) async {
        camera.cameraIsFrontFacing = false;

        await tester.pumpWidget(camera.buildPreview(cameraId));

        // Verify Texture is rotated by ((90 - 90 * -1 + 360) % 360) - 90 = 90 degrees clockwise.
        const int expectedQuarterTurns = _90DegreesClockwise;
        final RotatedBox rotatedBox =
            tester.widget<RotatedBox>(find.byType(RotatedBox));
        expect(rotatedBox.child, isA<Texture>());
        expect((rotatedBox.child! as Texture).textureId, cameraId);
        expect(rotatedBox.quarterTurns, expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns, rotatedBox.quarterTurns));
      });
    });
  });
}
