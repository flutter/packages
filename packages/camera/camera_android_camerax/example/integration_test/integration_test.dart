// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:camera_android_camerax/camera_android_camerax.dart';
import 'package:camera_android_camerax_example/camera_controller.dart';
import 'package:camera_android_camerax_example/camera_image.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    CameraPlatform.instance = AndroidCameraCameraX();
  });

  final Map<ResolutionPreset, Size> presetExpectedSizes =
      <ResolutionPreset, Size>{
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

  // This tests that the capture is no bigger than the preset, since we have
  // automatic code to fall back to smaller sizes when we need to. Returns
  // whether the image is exactly the desired resolution.
  Future<bool> testCaptureImageResolution(
      CameraController controller, ResolutionPreset preset) async {
    final Size expectedSize = presetExpectedSizes[preset]!;

    // Take Picture
    final XFile file = await controller.takePicture();

    // Load picture
    final File fileImage = File(file.path);
    final Image image = await decodeImageFromList(fileImage.readAsBytesSync());

    // Verify image dimensions are as expected
    expect(image, isNotNull);
    return assertExpectedDimensions(
        expectedSize, Size(image.height.toDouble(), image.width.toDouble()));
  }

  testWidgets('availableCameras only supports valid back or front cameras',
      (WidgetTester tester) async {
    final List<CameraDescription> availableCameras =
        await CameraPlatform.instance.availableCameras();

    for (final CameraDescription cameraDescription in availableCameras) {
      expect(
          cameraDescription.lensDirection, isNot(CameraLensDirection.external));
      expect(cameraDescription.sensorOrientation, anyOf(0, 90, 180, 270));
    }
  });

  testWidgets('Capture specific image resolutions',
      (WidgetTester tester) async {
    final List<CameraDescription> cameras =
        await CameraPlatform.instance.availableCameras();
    if (cameras.isEmpty) {
      return;
    }
    for (final CameraDescription cameraDescription in cameras) {
      bool previousPresetExactlySupported = true;
      for (final MapEntry<ResolutionPreset, Size> preset
          in presetExpectedSizes.entries) {
        final CameraController controller = CameraController(
          cameraDescription,
          mediaSettings: MediaSettings(resolutionPreset: preset.key),
        );
        await controller.initialize();
        final bool presetExactlySupported =
            await testCaptureImageResolution(controller, preset.key);
        // Ensures that if a lower resolution was used for previous (lower)
        // resolution preset, then the current (higher) preset also is adjusted,
        // as it demands a hgher resolution.
        expect(
            previousPresetExactlySupported || !presetExactlySupported, isTrue,
            reason:
                'The camera took higher resolution pictures at a lower resolution.');
        previousPresetExactlySupported = presetExactlySupported;
        await controller.dispose();
      }
    }
  });

  testWidgets('Preview takes expected resolution from preset',
      (WidgetTester tester) async {
    final List<CameraDescription> cameras =
        await CameraPlatform.instance.availableCameras();
    if (cameras.isEmpty) {
      return;
    }
    for (final CameraDescription cameraDescription in cameras) {
      bool previousPresetExactlySupported = true;
      for (final MapEntry<ResolutionPreset, Size> preset
          in presetExpectedSizes.entries) {
        final CameraController controller = CameraController(
          cameraDescription,
          mediaSettings: MediaSettings(resolutionPreset: preset.key),
        );

        await controller.initialize();

        while (controller.value.previewSize == null) {
          // Wait for preview size to update.
        }

        final bool presetExactlySupported = assertExpectedDimensions(
            preset.value, controller.value.previewSize!);
        // Ensures that if a lower resolution was used for previous (lower)
        // resolution preset, then the current (higher) preset also is adjusted,
        // as it demands a hgher resolution.
        expect(
            previousPresetExactlySupported || !presetExactlySupported, isTrue,
            reason: 'The preview has a lower resolution than that specified.');
        previousPresetExactlySupported = presetExactlySupported;
        await controller.dispose();
      }
    }
  });

  testWidgets('Images from streaming have expected resolution from preset',
      (WidgetTester tester) async {
    final List<CameraDescription> cameras =
        await CameraPlatform.instance.availableCameras();
    if (cameras.isEmpty) {
      return;
    }
    for (final CameraDescription cameraDescription in cameras) {
      bool previousPresetExactlySupported = true;
      for (final MapEntry<ResolutionPreset, Size> preset
          in presetExpectedSizes.entries) {
        final CameraController controller = CameraController(
          cameraDescription,
          mediaSettings: MediaSettings(resolutionPreset: preset.key),
        );
        final Completer<CameraImage> imageCompleter = Completer<CameraImage>();
        await controller.initialize();
        await controller.startImageStream((CameraImage image) {
          imageCompleter.complete(image);
          controller.stopImageStream();
        });

        final CameraImage image = await imageCompleter.future;
        final bool presetExactlySupported = assertExpectedDimensions(
            preset.value,
            Size(image.height.toDouble(), image.width.toDouble()));
        // Ensures that if a lower resolution was used for previous (lower)
        // resolution preset, then the current (higher) preset also is adjusted,
        // as it demands a hgher resolution.
        expect(
            previousPresetExactlySupported || !presetExactlySupported, isTrue,
            reason: 'The preview has a lower resolution than that specified.');
        previousPresetExactlySupported = presetExactlySupported;

        await controller.dispose();
      }
    }
  });
}
