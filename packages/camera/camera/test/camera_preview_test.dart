// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeController extends ValueNotifier<CameraValue>
    implements CameraController {
  FakeController() : super(const CameraValue.uninitialized(fakeDescription));

  static const CameraDescription fakeDescription = CameraDescription(
      name: '', lensDirection: CameraLensDirection.back, sensorOrientation: 0);

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  @override
  Widget buildPreview() {
    return const Texture(textureId: CameraController.kUninitializedCameraId);
  }

  @override
  int get cameraId => CameraController.kUninitializedCameraId;

  @override
  void debugCheckIsDisposed() {}

  @override
  bool get enableAudio => false;

  @override
  Future<double> getExposureOffsetStepSize() async => 1.0;

  @override
  Future<double> getMaxExposureOffset() async => 1.0;

  @override
  Future<double> getMaxZoomLevel() async => 1.0;

  @override
  Future<double> getMinExposureOffset() async => 1.0;

  @override
  Future<double> getMinZoomLevel() async => 1.0;

  @override
  ImageFormatGroup? get imageFormatGroup => null;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> lockCaptureOrientation([DeviceOrientation? orientation]) async {}

  @override
  Future<void> pauseVideoRecording() async {}

  @override
  Future<void> prepareForVideoRecording() async {}

  @override
  ResolutionPreset get resolutionPreset => ResolutionPreset.low;

  @override
  MediaSettings get mediaSettings => const MediaSettings(
        resolutionPreset: ResolutionPreset.low,
        fps: 15,
        videoBitrate: 200000,
        audioBitrate: 32000,
        enableAudio: true,
      );

  @override
  Future<void> resumeVideoRecording() async {}

  @override
  Future<void> setExposureMode(ExposureMode mode) async {}

  @override
  Future<double> setExposureOffset(double offset) async => offset;

  @override
  Future<void> setExposurePoint(Offset? point) async {}

  @override
  Future<void> setFlashMode(FlashMode mode) async {}

  @override
  Future<void> setFocusMode(FocusMode mode) async {}

  @override
  Future<void> setFocusPoint(Offset? point) async {}

  @override
  Future<void> setZoomLevel(double zoom) async {}

  @override
  Future<void> startImageStream(onLatestImageAvailable onAvailable) async {}

  @override
  Future<void> startVideoRecording(
      {onLatestImageAvailable? onAvailable}) async {}

  @override
  Future<void> stopImageStream() async {}

  @override
  Future<XFile> stopVideoRecording() async => XFile('');

  @override
  Future<XFile> takePicture() async => XFile('');

  @override
  Future<void> unlockCaptureOrientation() async {}

  @override
  Future<void> pausePreview() async {}

  @override
  Future<void> resumePreview() async {}

  @override
  Future<void> setDescription(CameraDescription description) async {}

  @override
  CameraDescription get description => value.description;

  @override
  bool supportsImageStreaming() => true;
}

void main() {
  group('RotatedBox (Android only)', () {
    testWidgets(
        'when recording in DeviceOrientaiton.portraitUp, rotatedBox should not be rotated',
        (
      WidgetTester tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final FakeController controller = FakeController();
      addTearDown(controller.dispose);

      controller.value = controller.value.copyWith(
          isInitialized: true,
          isRecordingVideo: true,
          deviceOrientation: DeviceOrientation.portraitDown,
          lockedCaptureOrientation:
              const Optional<DeviceOrientation>.fromNullable(
                  DeviceOrientation.landscapeRight),
          recordingOrientation: const Optional<DeviceOrientation>.fromNullable(
              DeviceOrientation.portraitUp),
          previewSize: const Size(480, 640) // preview size irrelevant to test
          );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CameraPreview(controller),
        ),
      );
      expect(find.byType(RotatedBox), findsOneWidget);

      final RotatedBox rotatedBox =
          tester.widget<RotatedBox>(find.byType(RotatedBox));
      expect(rotatedBox.quarterTurns, 0);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'when recording in DeviceOrientaiton.landscapeRight, rotatedBox should be rotated by one clockwise quarter turn',
        (
      WidgetTester tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final FakeController controller = FakeController();
      addTearDown(controller.dispose);

      controller.value = controller.value.copyWith(
          isInitialized: true,
          isRecordingVideo: true,
          deviceOrientation: DeviceOrientation.portraitUp,
          lockedCaptureOrientation:
              const Optional<DeviceOrientation>.fromNullable(
                  DeviceOrientation.landscapeLeft),
          recordingOrientation: const Optional<DeviceOrientation>.fromNullable(
              DeviceOrientation.landscapeRight),
          previewSize: const Size(480, 640) // preview size irrelevant to test
          );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CameraPreview(controller),
        ),
      );
      expect(find.byType(RotatedBox), findsOneWidget);

      final RotatedBox rotatedBox =
          tester.widget<RotatedBox>(find.byType(RotatedBox));
      expect(rotatedBox.quarterTurns, 1);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'when recording in DeviceOrientaiton.portraitDown, rotatedBox should be rotated by two clockwise quarter turns',
        (
      WidgetTester tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final FakeController controller = FakeController();
      addTearDown(controller.dispose);

      controller.value = controller.value.copyWith(
          isInitialized: true,
          isRecordingVideo: true,
          deviceOrientation: DeviceOrientation.portraitUp,
          lockedCaptureOrientation:
              const Optional<DeviceOrientation>.fromNullable(
                  DeviceOrientation.landscapeRight),
          recordingOrientation: const Optional<DeviceOrientation>.fromNullable(
              DeviceOrientation.portraitDown),
          previewSize: const Size(480, 640) // preview size irrelevant to test
          );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CameraPreview(controller),
        ),
      );
      expect(find.byType(RotatedBox), findsOneWidget);

      final RotatedBox rotatedBox =
          tester.widget<RotatedBox>(find.byType(RotatedBox));
      expect(rotatedBox.quarterTurns, 2);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'when recording in DeviceOrientaiton.landscapeLeft, rotatedBox should be rotated by three clockwise quarter turns',
        (
      WidgetTester tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final FakeController controller = FakeController();
      addTearDown(controller.dispose);

      controller.value = controller.value.copyWith(
          isInitialized: true,
          isRecordingVideo: true,
          deviceOrientation: DeviceOrientation.portraitUp,
          lockedCaptureOrientation:
              const Optional<DeviceOrientation>.fromNullable(
                  DeviceOrientation.landscapeRight),
          recordingOrientation: const Optional<DeviceOrientation>.fromNullable(
              DeviceOrientation.landscapeLeft),
          previewSize: const Size(480, 640) // preview size irrelevant to test
          );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CameraPreview(controller),
        ),
      );
      expect(find.byType(RotatedBox), findsOneWidget);

      final RotatedBox rotatedBox =
          tester.widget<RotatedBox>(find.byType(RotatedBox));
      expect(rotatedBox.quarterTurns, 3);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'when orientation locked in DeviceOrientaiton.portaitUp, rotatedBox should not be rotated',
        (
      WidgetTester tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final FakeController controller = FakeController();
      addTearDown(controller.dispose);

      controller.value = controller.value.copyWith(
          isInitialized: true,
          deviceOrientation: DeviceOrientation.portraitDown,
          lockedCaptureOrientation:
              const Optional<DeviceOrientation>.fromNullable(
                  DeviceOrientation.portraitUp),
          recordingOrientation: const Optional<DeviceOrientation>.fromNullable(
              DeviceOrientation.landscapeLeft),
          previewSize: const Size(480, 640) // preview size irrelevant to test
          );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CameraPreview(controller),
        ),
      );
      expect(find.byType(RotatedBox), findsOneWidget);

      final RotatedBox rotatedBox =
          tester.widget<RotatedBox>(find.byType(RotatedBox));
      expect(rotatedBox.quarterTurns, 0);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'when orientation locked in DeviceOrientaiton.landscapeRight, rotatedBox should be rotated by one clockwise quarter turn',
        (
      WidgetTester tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final FakeController controller = FakeController();
      addTearDown(controller.dispose);

      controller.value = controller.value.copyWith(
          isInitialized: true,
          deviceOrientation: DeviceOrientation.portraitDown,
          lockedCaptureOrientation:
              const Optional<DeviceOrientation>.fromNullable(
                  DeviceOrientation.landscapeRight),
          recordingOrientation: const Optional<DeviceOrientation>.fromNullable(
              DeviceOrientation.landscapeLeft),
          previewSize: const Size(480, 640) // preview size irrelevant to test
          );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CameraPreview(controller),
        ),
      );
      expect(find.byType(RotatedBox), findsOneWidget);

      final RotatedBox rotatedBox =
          tester.widget<RotatedBox>(find.byType(RotatedBox));
      expect(rotatedBox.quarterTurns, 1);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'when orientation locked in DeviceOrientaiton.portraitDown, rotatedBox should be rotated by two clockwise quarter turns',
        (
      WidgetTester tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final FakeController controller = FakeController();
      addTearDown(controller.dispose);

      controller.value = controller.value.copyWith(
          isInitialized: true,
          deviceOrientation: DeviceOrientation.portraitUp,
          lockedCaptureOrientation:
              const Optional<DeviceOrientation>.fromNullable(
                  DeviceOrientation.portraitDown),
          recordingOrientation: const Optional<DeviceOrientation>.fromNullable(
              DeviceOrientation.landscapeLeft),
          previewSize: const Size(480, 640) // preview size irrelevant to test
          );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CameraPreview(controller),
        ),
      );
      expect(find.byType(RotatedBox), findsOneWidget);

      final RotatedBox rotatedBox =
          tester.widget<RotatedBox>(find.byType(RotatedBox));
      expect(rotatedBox.quarterTurns, 2);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'when orientation locked in DeviceOrientaiton.landscapeRight, rotatedBox should be rotated by three clockwise quarter turns',
        (
      WidgetTester tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final FakeController controller = FakeController();
      addTearDown(controller.dispose);

      controller.value = controller.value.copyWith(
          isInitialized: true,
          deviceOrientation: DeviceOrientation.portraitUp,
          lockedCaptureOrientation:
              const Optional<DeviceOrientation>.fromNullable(
                  DeviceOrientation.landscapeRight),
          recordingOrientation: const Optional<DeviceOrientation>.fromNullable(
              DeviceOrientation.landscapeLeft),
          previewSize: const Size(480, 640) // preview size irrelevant to test
          );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CameraPreview(controller),
        ),
      );
      expect(find.byType(RotatedBox), findsOneWidget);

      final RotatedBox rotatedBox =
          tester.widget<RotatedBox>(find.byType(RotatedBox));
      expect(rotatedBox.quarterTurns, 1);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'when orientation not locked, not recording, and device orientation is portrait up, rotatedBox should not be rotated',
        (
      WidgetTester tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final FakeController controller = FakeController();
      addTearDown(controller.dispose);

      controller.value = controller.value.copyWith(
          isInitialized: true,
          deviceOrientation: DeviceOrientation.portraitUp,
          recordingOrientation: const Optional<DeviceOrientation>.fromNullable(
              DeviceOrientation.landscapeLeft),
          previewSize: const Size(480, 640) // preview size irrelevant to test
          );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CameraPreview(controller),
        ),
      );
      expect(find.byType(RotatedBox), findsOneWidget);

      final RotatedBox rotatedBox =
          tester.widget<RotatedBox>(find.byType(RotatedBox));
      expect(rotatedBox.quarterTurns, 0);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'when orientation not locked, not recording, and device orientation is landscape right, rotatedBox should be rotated by one clockwise quarter turn',
        (
      WidgetTester tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final FakeController controller = FakeController();
      addTearDown(controller.dispose);

      controller.value = controller.value.copyWith(
          isInitialized: true,
          deviceOrientation: DeviceOrientation.landscapeRight,
          recordingOrientation: const Optional<DeviceOrientation>.fromNullable(
              DeviceOrientation.landscapeLeft),
          previewSize: const Size(480, 640) // preview size irrelevant to test
          );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CameraPreview(controller),
        ),
      );
      expect(find.byType(RotatedBox), findsOneWidget);

      final RotatedBox rotatedBox =
          tester.widget<RotatedBox>(find.byType(RotatedBox));
      expect(rotatedBox.quarterTurns, 1);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'when orientation not locked, not recording, and device orientation is portrait down, rotatedBox should be rotated by two clockwise quarter turns',
        (
      WidgetTester tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final FakeController controller = FakeController();
      addTearDown(controller.dispose);

      controller.value = controller.value.copyWith(
          isInitialized: true,
          deviceOrientation: DeviceOrientation.portraitDown,
          recordingOrientation: const Optional<DeviceOrientation>.fromNullable(
              DeviceOrientation.landscapeLeft),
          previewSize: const Size(480, 640) // preview size irrelevant to test
          );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CameraPreview(controller),
        ),
      );
      expect(find.byType(RotatedBox), findsOneWidget);

      final RotatedBox rotatedBox =
          tester.widget<RotatedBox>(find.byType(RotatedBox));
      expect(rotatedBox.quarterTurns, 2);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'when orientation not locked, not recording, and device orientation is landscape left, rotatedBox should be rotated by three clockwise quarter turns',
        (
      WidgetTester tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final FakeController controller = FakeController();
      addTearDown(controller.dispose);

      controller.value = controller.value.copyWith(
          isInitialized: true,
          deviceOrientation: DeviceOrientation.landscapeLeft,
          recordingOrientation: const Optional<DeviceOrientation>.fromNullable(
              DeviceOrientation.portraitDown),
          previewSize: const Size(480, 640) // preview size irrelevant to test
          );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CameraPreview(controller),
        ),
      );
      expect(find.byType(RotatedBox), findsOneWidget);

      final RotatedBox rotatedBox =
          tester.widget<RotatedBox>(find.byType(RotatedBox));
      expect(rotatedBox.quarterTurns, 3);

      debugDefaultTargetPlatformOverride = null;
    });
  }, skip: kIsWeb);

  testWidgets('when not on Android there should not be a rotated box',
      (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final FakeController controller = FakeController();
    addTearDown(controller.dispose);
    controller.value = controller.value.copyWith(
        isInitialized: true,
        previewSize: const Size(480, 640) // preview size irrelevant to test
        );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: CameraPreview(controller),
      ),
    );
    expect(find.byType(RotatedBox), findsNothing);
    expect(find.byType(Texture), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });
}
