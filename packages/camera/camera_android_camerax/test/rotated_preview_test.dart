// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_android_camerax/src/camerax_library.dart';
import 'package:camera_android_camerax/src/rotated_preview.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'android_camera_camerax_test.mocks.dart';

// How RotatedPreview rotates and mirrors the preview, including when the
// device orientation or TransformationInfo changes, is tested end to end in
// preview_rotation_test.dart. These tests only cover what those do not.
void main() {
  late StreamController<DeviceOrientation> deviceOrientationStreamController;
  late StreamController<TransformationInfo> transformationInfoStreamController;
  late MockDeviceOrientationManager mockDeviceOrientationManager;

  setUp(() {
    deviceOrientationStreamController = StreamController<DeviceOrientation>.broadcast();
    transformationInfoStreamController = StreamController<TransformationInfo>.broadcast();
    mockDeviceOrientationManager = MockDeviceOrientationManager();
  });

  tearDown(() {
    deviceOrientationStreamController.close();
    transformationInfoStreamController.close();
  });

  /// Creates a [RotatedPreview] of a back camera with a sensor orientation of
  /// 90 degrees whose surface is backed by an `ImageReader` with CameraX
  /// mirroring turned off, with a target
  /// rotation of 0 degrees, created in portrait with a display rotation of 0
  /// degrees.
  Widget createRotatedPreview({TransformationInfo? initialTransformationInfo}) {
    return RotatedPreview(
      handlesCropAndRotation: false,
      previewMirroringDisabled: true,
      initialDeviceOrientation: DeviceOrientation.portraitUp,
      initialDefaultDisplayRotation: Surface.rotation0,
      deviceOrientationStream: deviceOrientationStreamController.stream,
      deviceOrientationManager: mockDeviceOrientationManager,
      initialTransformationInfo: initialTransformationInfo,
      transformationInfoStream: transformationInfoStreamController.stream,
      previewTargetRotation: Surface.rotation0,
      sensorOrientationDegrees: 90,
      cameraIsFrontFacing: false,
      child: const SizedBox(),
    );
  }

  int quarterTurns(WidgetTester tester) =>
      tester.widget<RotatedBox>(find.byType(RotatedBox)).quarterTurns % 4;

  testWidgets('starts from the initial values', (WidgetTester tester) async {
    // The surface does not have the camera transform, so the preview is
    // rotated by TransformationInfo.rotationDegrees: 180 - (0 - 0) = 180
    // degrees (instead of the sensor-based 90 degrees).
    await tester.pumpWidget(
      createRotatedPreview(
        initialTransformationInfo: TransformationInfo.pigeon_detached(
          rotationDegrees: 180,
          hasCameraTransform: false,
          isMirroring: false,
        ),
      ),
    );
    await tester.pump();

    expect(quarterTurns(tester), 2);
    verifyNever(mockDeviceOrientationManager.getDefaultDisplayRotation());
  });

  testWidgets('cancels its subscriptions when disposed', (WidgetTester tester) async {
    await tester.pumpWidget(createRotatedPreview());
    await tester.pump();
    expect(deviceOrientationStreamController.hasListener, isTrue);
    expect(transformationInfoStreamController.hasListener, isTrue);

    await tester.pumpWidget(const SizedBox());

    expect(deviceOrientationStreamController.hasListener, isFalse);
    expect(transformationInfoStreamController.hasListener, isFalse);
  });
}
