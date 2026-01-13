// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:camera_android_camerax/camera_android_camerax.dart';
import 'package:camera_android_camerax_example/camera_controller.dart';
import 'package:camera_android_camerax_example/camera_image.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:video_player/video_player.dart';

// Skip due to video_player error.
// See https://github.com/flutter/flutter/issues/157181
const bool skipFor157181 = true;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    CameraPlatform.instance = AndroidCameraCameraX();
  });

  final presetExpectedSizes = <ResolutionPreset, Size>{
    ResolutionPreset.low: const Size(240, 320),
    ResolutionPreset.medium: const Size(480, 720),
    ResolutionPreset.high: const Size(720, 1280),
    ResolutionPreset.veryHigh: const Size(1080, 1920),
    ResolutionPreset.ultraHigh: const Size(2160, 3840),
    // Don't bother checking for max here since it could be anything.
  };

  /// Verify that [actual] has dimensions that are at most as large as
  /// [expectedSize]. Allows for a mismatch in portrait vs landscape. Returns
  /// whether the dimensions exactly match.
  bool assertExpectedDimensions(Size expectedSize, Size actual) {
    expect(actual.shortestSide, lessThanOrEqualTo(expectedSize.shortestSide));
    expect(actual.longestSide, lessThanOrEqualTo(expectedSize.longestSide));
    return actual.shortestSide == expectedSize.shortestSide &&
        actual.longestSide == expectedSize.longestSide;
  }

  testWidgets('availableCameras only supports valid back or front cameras', (
    WidgetTester tester,
  ) async {
    final List<CameraDescription> availableCameras = await CameraPlatform
        .instance
        .availableCameras();

    for (final cameraDescription in availableCameras) {
      expect(
        cameraDescription.lensDirection,
        isNot(CameraLensDirection.external),
      );
      expect(cameraDescription.sensorOrientation, anyOf(0, 90, 180, 270));
    }
  });

  testWidgets('Preview takes expected resolution from preset', (
    WidgetTester tester,
  ) async {
    final List<CameraDescription> cameras = await CameraPlatform.instance
        .availableCameras();
    if (cameras.isEmpty) {
      return;
    }
    for (final cameraDescription in cameras) {
      var previousPresetExactlySupported = true;
      for (final MapEntry<ResolutionPreset, Size> preset
          in presetExpectedSizes.entries) {
        final controller = CameraController(
          cameraDescription,
          mediaSettings: MediaSettings(resolutionPreset: preset.key),
        );

        await controller.initialize();

        while (controller.value.previewSize == null) {
          // Wait for preview size to update.
        }

        final bool presetExactlySupported = assertExpectedDimensions(
          preset.value,
          controller.value.previewSize!,
        );
        // Ensures that if a lower resolution was used for previous (lower)
        // resolution preset, then the current (higher) preset also is adjusted,
        // as it demands a hgher resolution.
        expect(
          previousPresetExactlySupported || !presetExactlySupported,
          isTrue,
          reason: 'The preview has a lower resolution than that specified.',
        );
        previousPresetExactlySupported = presetExactlySupported;
        await controller.dispose();
      }
    }
  });

  testWidgets('Images from streaming have expected resolution from preset', (
    WidgetTester tester,
  ) async {
    final List<CameraDescription> cameras = await CameraPlatform.instance
        .availableCameras();
    if (cameras.isEmpty) {
      return;
    }
    for (final cameraDescription in cameras) {
      var previousPresetExactlySupported = true;
      for (final MapEntry<ResolutionPreset, Size> preset
          in presetExpectedSizes.entries) {
        final controller = CameraController(
          cameraDescription,
          mediaSettings: MediaSettings(resolutionPreset: preset.key),
        );
        final imageCompleter = Completer<CameraImage>();
        await controller.initialize();
        await controller.startImageStream((CameraImage image) {
          imageCompleter.complete(image);
          controller.stopImageStream();
        });

        final CameraImage image = await imageCompleter.future;
        final bool presetExactlySupported = assertExpectedDimensions(
          preset.value,
          Size(image.height.toDouble(), image.width.toDouble()),
        );
        // Ensures that if a lower resolution was used for previous (lower)
        // resolution preset, then the current (higher) preset also is adjusted,
        // as it demands a hgher resolution.
        expect(
          previousPresetExactlySupported || !presetExactlySupported,
          isTrue,
          reason: 'The preview has a lower resolution than that specified.',
        );
        previousPresetExactlySupported = presetExactlySupported;

        await controller.dispose();
      }
    }
  });

  testWidgets('Video capture records valid video', (WidgetTester tester) async {
    final List<CameraDescription> cameras = await availableCameras();
    if (cameras.isEmpty) {
      return;
    }

    final controller = CameraController(
      cameras[0],
      mediaSettings: const MediaSettings(
        resolutionPreset: ResolutionPreset.low,
      ),
    );
    await controller.initialize();
    await controller.prepareForVideoRecording();

    await controller.startVideoRecording();
    final int recordingStart = DateTime.now().millisecondsSinceEpoch;

    sleep(const Duration(seconds: 2));

    final XFile file = await controller.stopVideoRecording();
    final int postStopTime =
        DateTime.now().millisecondsSinceEpoch - recordingStart;

    final videoFile = File(file.path);
    final videoController = VideoPlayerController.file(videoFile);
    await videoController.initialize();
    final int duration = videoController.value.duration.inMilliseconds;
    await videoController.dispose();

    expect(duration, lessThan(postStopTime));
  }, skip: skipFor157181);

  testWidgets('Pause and resume video recording', (WidgetTester tester) async {
    final List<CameraDescription> cameras = await availableCameras();
    if (cameras.isEmpty) {
      return;
    }

    final controller = CameraController(
      cameras[0],
      mediaSettings: const MediaSettings(
        resolutionPreset: ResolutionPreset.low,
      ),
    );
    await controller.initialize();
    await controller.prepareForVideoRecording();

    int startPause;
    var timePaused = 0;
    const pauseIterations = 2;

    await controller.startVideoRecording();
    final int recordingStart = DateTime.now().millisecondsSinceEpoch;
    sleep(const Duration(milliseconds: 500));

    for (var i = 0; i < pauseIterations; i++) {
      await controller.pauseVideoRecording();
      startPause = DateTime.now().millisecondsSinceEpoch;
      sleep(const Duration(milliseconds: 500));
      await controller.resumeVideoRecording();
      timePaused += DateTime.now().millisecondsSinceEpoch - startPause;

      sleep(const Duration(milliseconds: 500));
    }

    final XFile file = await controller.stopVideoRecording();
    final int recordingTime =
        DateTime.now().millisecondsSinceEpoch - recordingStart;

    final videoFile = File(file.path);
    final videoController = VideoPlayerController.file(videoFile);
    await videoController.initialize();
    final int duration = videoController.value.duration.inMilliseconds;
    await videoController.dispose();

    expect(duration, lessThan(recordingTime - timePaused));
  }, skip: skipFor157181);

  testWidgets('Set description while recording captures full video', (
    WidgetTester tester,
  ) async {
    final List<CameraDescription> cameras = await availableCameras();
    if (cameras.length < 2) {
      return;
    }

    final controller = CameraController(
      cameras[0],
      mediaSettings: const MediaSettings(
        resolutionPreset: ResolutionPreset.medium,
        enableAudio: true,
      ),
    );
    await controller.initialize();
    await controller.prepareForVideoRecording();

    await controller.startVideoRecording();

    await controller.setDescription(cameras[1]);

    await tester.pumpAndSettle(const Duration(seconds: 4));

    await controller.setDescription(cameras[0]);

    await tester.pumpAndSettle(const Duration(seconds: 1));

    final XFile file = await controller.stopVideoRecording();

    final videoFile = File(file.path);
    final videoController = VideoPlayerController.file(videoFile);
    await videoController.initialize();
    final int duration = videoController.value.duration.inMilliseconds;
    await videoController.dispose();

    expect(
      duration,
      greaterThanOrEqualTo(const Duration(seconds: 4).inMilliseconds),
    );
    await controller.dispose();
  });
}
