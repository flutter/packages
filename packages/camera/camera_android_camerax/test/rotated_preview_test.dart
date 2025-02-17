// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_android_camerax/src/rotated_preview.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  double getRotationDegreesFromDeviceOrientation(
      DeviceOrientation deviceOrientation) {
    return switch (deviceOrientation) {
      DeviceOrientation.portraitUp => 0,
      DeviceOrientation.landscapeRight => 90,
      DeviceOrientation.portraitDown => 180,
      DeviceOrientation.landscapeLeft => 270,
    };
  }

  double calculateExpectedPreviewRotation(double sensorOrientationDegrees,
      double deviceOrientationDegrees, int facingSign) {
    return ((sensorOrientationDegrees -
                deviceOrientationDegrees * facingSign +
                360) %
            360) -
        deviceOrientationDegrees;
  }

  void findAndTestRotatedPreviewHasExpectedRotation(
      {required WidgetTester tester,
      required DeviceOrientation deviceOrientation,
      required double sensorOrientationDegrees,
      required int facingSign}) {
    final double deviceOrientationDegrees =
        getRotationDegreesFromDeviceOrientation(deviceOrientation);
    final double expectedRotation = calculateExpectedPreviewRotation(
        sensorOrientationDegrees, deviceOrientationDegrees, facingSign);
    final int expectedQuarterTurns = expectedRotation ~/ 90;

    final RotatedBox rotatedBox =
        tester.widget<RotatedBox>(find.byType(RotatedBox));
    expect(rotatedBox.quarterTurns, expectedQuarterTurns,
        reason:
            'When the device orientation $deviceOrientation, the preview should be rotated by $expectedQuarterTurns quarter turns but instead was rotated ${rotatedBox.quarterTurns} quarter turns.');
  }

  Future<void> testRotatedPreviewRespondsAsExpectedToDeviceOrientationChanges(
      WidgetTester tester,
      RotatedPreview rotatedPreview,
      StreamController<DeviceOrientation>
          deviceOrientationStreamController) async {
    for (final DeviceOrientation deviceOrientation
        in DeviceOrientation.values) {
      deviceOrientationStreamController.add(deviceOrientation);
      await tester.pumpAndSettle();
      findAndTestRotatedPreviewHasExpectedRotation(
          tester: tester,
          deviceOrientation: deviceOrientation,
          sensorOrientationDegrees: rotatedPreview.sensorOrientationDegrees,
          facingSign: rotatedPreview.facingSign);
    }
  }

  test('RotatedPreview.frontFacingCamera sets facingSign to 1', () {
    final RotatedPreview rotatedPreview = RotatedPreview.frontFacingCamera(
        DeviceOrientation.portraitDown, const Stream<DeviceOrientation>.empty(),
        sensorOrientationDegrees: 90, child: Container());
    expect(rotatedPreview.facingSign, 1);
  });

  test('RotatedPreview.backFacingCamera sets facingSign to -1', () {
    final RotatedPreview rotatedPreview = RotatedPreview.backFacingCamera(
        DeviceOrientation.portraitDown, const Stream<DeviceOrientation>.empty(),
        sensorOrientationDegrees: 90, child: Container());
    expect(rotatedPreview.facingSign, -1);
  });

  testWidgets(
      'RotatedPreview.frontFacingCamera correctly rotates preview in initial device orientation',
      (WidgetTester tester) async {
    const DeviceOrientation initialDeviceOrientation =
        DeviceOrientation.landscapeLeft;
    final RotatedPreview rotatedPreview = RotatedPreview.frontFacingCamera(
        initialDeviceOrientation, const Stream<DeviceOrientation>.empty(),
        sensorOrientationDegrees: 90, child: Container());
    await tester.pumpWidget(rotatedPreview);

    findAndTestRotatedPreviewHasExpectedRotation(
        tester: tester,
        deviceOrientation: initialDeviceOrientation,
        sensorOrientationDegrees: rotatedPreview.sensorOrientationDegrees,
        facingSign: rotatedPreview.facingSign);
  });

  testWidgets(
      'RotatedPreview.frontFacingCamera correctly rotates preview as device orientation changes',
      (WidgetTester tester) async {
    final StreamController<DeviceOrientation>
        deviceOrientationStreamController =
        StreamController<DeviceOrientation>();
    final Stream<DeviceOrientation> deviceOrientationStream =
        deviceOrientationStreamController.stream;
    final RotatedPreview rotatedPreview = RotatedPreview.frontFacingCamera(
        DeviceOrientation.portraitUp, deviceOrientationStream,
        sensorOrientationDegrees: 90, child: Container());

    await tester.pumpWidget(rotatedPreview);
    await testRotatedPreviewRespondsAsExpectedToDeviceOrientationChanges(
        tester, rotatedPreview, deviceOrientationStreamController);
    await deviceOrientationStreamController.close();
  });

  testWidgets(
      'RotatedPreview.backFacingCamera correctly rotates preview in initial device orientation',
      (WidgetTester tester) async {
    const DeviceOrientation initialDeviceOrientation =
        DeviceOrientation.landscapeRight;
    final RotatedPreview rotatedPreview = RotatedPreview.backFacingCamera(
        initialDeviceOrientation, const Stream<DeviceOrientation>.empty(),
        sensorOrientationDegrees: 270, child: Container());
    await tester.pumpWidget(rotatedPreview);

    findAndTestRotatedPreviewHasExpectedRotation(
        tester: tester,
        deviceOrientation: initialDeviceOrientation,
        sensorOrientationDegrees: rotatedPreview.sensorOrientationDegrees,
        facingSign: rotatedPreview.facingSign);
  });

  testWidgets(
      'RotatedPreview.backFacingCamera correctly rotates preview as device orientation changes',
      (WidgetTester tester) async {
    final StreamController<DeviceOrientation>
        deviceOrientationStreamController =
        StreamController<DeviceOrientation>();
    final Stream<DeviceOrientation> deviceOrientationStream =
        deviceOrientationStreamController.stream;
    final RotatedPreview rotatedPreview = RotatedPreview.backFacingCamera(
        DeviceOrientation.portraitUp, deviceOrientationStream,
        sensorOrientationDegrees: 90, child: Container());

    await tester.pumpWidget(rotatedPreview);
    await testRotatedPreviewRespondsAsExpectedToDeviceOrientationChanges(
        tester, rotatedPreview, deviceOrientationStreamController);
    await deviceOrientationStreamController.close();
  });
}
