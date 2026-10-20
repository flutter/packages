// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_android_camerax/src/camerax_library.dart';
import 'package:camera_android_camerax/src/rotated_preview_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'android_camera_camerax_test.mocks.dart';

/// Minimal [RotatedPreview] that records the state tracked by
/// [RotatedPreviewStateMixin] every time it builds.
final class _TestRotatedPreview extends RotatedPreview {
  const _TestRotatedPreview({
    required super.initialDeviceOrientation,
    required super.initialDefaultDisplayRotation,
    required super.deviceOrientationStream,
    required super.deviceOrientationManager,
    required super.initialTransformationInfo,
    required super.transformationInfoStream,
    required this.onBuild,
  }) : super(
         previewTargetRotation: Surface.rotation0,
         sensorOrientationDegrees: 90,
         cameraIsFrontFacing: false,
         child: const SizedBox(),
       );

  final void Function(
    DeviceOrientation deviceOrientation,
    int defaultDisplayRotation,
    TransformationInfo? transformationInfo,
  )
  onBuild;

  @override
  State<StatefulWidget> createState() => _TestRotatedPreviewState();
}

final class _TestRotatedPreviewState extends State<_TestRotatedPreview>
    with RotatedPreviewStateMixin<_TestRotatedPreview> {
  @override
  Widget build(BuildContext context) {
    return buildWithDefaultDisplayRotation((int defaultDisplayRotation) {
      widget.onBuild(deviceOrientation, defaultDisplayRotation, transformationInfo);
      return widget.child;
    });
  }
}

void main() {
  late StreamController<DeviceOrientation> deviceOrientationStreamController;
  late StreamController<TransformationInfo> transformationInfoStreamController;
  late MockDeviceOrientationManager mockDeviceOrientationManager;

  late DeviceOrientation lastDeviceOrientation;
  late int lastDefaultDisplayRotation;
  TransformationInfo? lastTransformationInfo;

  setUp(() {
    deviceOrientationStreamController = StreamController<DeviceOrientation>.broadcast();
    transformationInfoStreamController = StreamController<TransformationInfo>.broadcast();
    mockDeviceOrientationManager = MockDeviceOrientationManager();
    lastTransformationInfo = null;
  });

  tearDown(() {
    deviceOrientationStreamController.close();
    transformationInfoStreamController.close();
  });

  Widget createTestRotatedPreview({TransformationInfo? initialTransformationInfo}) {
    return _TestRotatedPreview(
      initialDeviceOrientation: DeviceOrientation.portraitUp,
      initialDefaultDisplayRotation: Surface.rotation0,
      deviceOrientationStream: deviceOrientationStreamController.stream,
      deviceOrientationManager: mockDeviceOrientationManager,
      initialTransformationInfo: initialTransformationInfo,
      transformationInfoStream: transformationInfoStreamController.stream,
      onBuild:
          (
            DeviceOrientation deviceOrientation,
            int defaultDisplayRotation,
            TransformationInfo? transformationInfo,
          ) {
            lastDeviceOrientation = deviceOrientation;
            lastDefaultDisplayRotation = defaultDisplayRotation;
            lastTransformationInfo = transformationInfo;
          },
    );
  }

  testWidgets('starts from the initial values', (WidgetTester tester) async {
    final initialTransformationInfo = TransformationInfo.pigeon_detached(
      rotationDegrees: 90,
      hasCameraTransform: true,
      isMirroring: false,
    );

    await tester.pumpWidget(
      createTestRotatedPreview(initialTransformationInfo: initialTransformationInfo),
    );
    await tester.pump();

    expect(lastDeviceOrientation, DeviceOrientation.portraitUp);
    expect(lastDefaultDisplayRotation, Surface.rotation0);
    expect(lastTransformationInfo, initialTransformationInfo);
    verifyNever(mockDeviceOrientationManager.getDefaultDisplayRotation());
  });

  testWidgets(
    'updates the device orientation and default display rotation on device orientation changes',
    (WidgetTester tester) async {
      when(
        mockDeviceOrientationManager.getDefaultDisplayRotation(),
      ).thenAnswer((_) async => Surface.rotation90);

      await tester.pumpWidget(createTestRotatedPreview());
      await tester.pump();

      deviceOrientationStreamController.add(DeviceOrientation.landscapeLeft);
      await tester.pumpAndSettle();

      expect(lastDeviceOrientation, DeviceOrientation.landscapeLeft);
      expect(lastDefaultDisplayRotation, Surface.rotation90);
      verify(mockDeviceOrientationManager.getDefaultDisplayRotation()).called(1);
    },
  );

  testWidgets('updates the TransformationInfo when a new one is received', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestRotatedPreview());
    await tester.pump();
    expect(lastTransformationInfo, isNull);

    final transformationInfo = TransformationInfo.pigeon_detached(
      rotationDegrees: 0,
      hasCameraTransform: false,
      isMirroring: true,
    );
    transformationInfoStreamController.add(transformationInfo);
    await tester.pumpAndSettle();

    expect(lastTransformationInfo, transformationInfo);
    // The device orientation and default display rotation are unchanged.
    expect(lastDeviceOrientation, DeviceOrientation.portraitUp);
    expect(lastDefaultDisplayRotation, Surface.rotation0);
  });

  testWidgets('cancels its subscriptions when disposed', (WidgetTester tester) async {
    await tester.pumpWidget(createTestRotatedPreview());
    await tester.pump();
    expect(deviceOrientationStreamController.hasListener, isTrue);
    expect(transformationInfoStreamController.hasListener, isTrue);

    await tester.pumpWidget(const SizedBox());

    expect(deviceOrientationStreamController.hasListener, isFalse);
    expect(transformationInfoStreamController.hasListener, isFalse);
  });
}
