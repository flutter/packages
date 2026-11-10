// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:camera_avfoundation/camera_avfoundation.dart';
import 'package:camera_example/camera_controller.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

void main() {
  late Directory testDir;

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    CameraPlatform.instance = AVFoundationCamera();
    final Directory extDir = await getTemporaryDirectory();
    testDir = await Directory('${extDir.path}/test').create(recursive: true);
  });

  tearDownAll(() async {
    await testDir.delete(recursive: true);
  });

  // Presets in increasing order of requested resolution. `max` is excluded
  // since its resolution could be anything.
  const presets = <ResolutionPreset>[
    ResolutionPreset.low,
    ResolutionPreset.medium,
    ResolutionPreset.high,
    ResolutionPreset.veryHigh,
    ResolutionPreset.ultraHigh,
  ];

  /// Captures with each of [presets] using [capture], and verifies that the
  /// captured size never decreases as the requested preset increases.
  ///
  /// Exact sizes aren't checked because a preset that the device doesn't
  /// support falls back to a device-specific resolution, which varies across
  /// hardware. Allows for a mismatch in portrait vs landscape.
  Future<void> expectNonDecreasingCaptureSizes(
    CameraDescription cameraDescription,
    Future<Size> Function(CameraController controller) capture,
  ) async {
    ResolutionPreset? previousPreset;
    Size? previousSize;
    for (final preset in presets) {
      final controller = CameraController(cameraDescription, preset);
      await controller.initialize();
      final Size size = await capture(controller);
      await controller.dispose();

      expect(size.isEmpty, isFalse, reason: '${cameraDescription.name} $preset captured $size');
      if (previousSize != null) {
        final reason =
            '${cameraDescription.name}: $preset captured $size, which is smaller '
            'than $previousSize captured by $previousPreset';
        expect(size.shortestSide, greaterThanOrEqualTo(previousSize.shortestSide), reason: reason);
        expect(size.longestSide, greaterThanOrEqualTo(previousSize.longestSide), reason: reason);
      }
      previousPreset = preset;
      previousSize = size;
    }
  }

  Future<Size> captureImageSize(CameraController controller) async {
    final XFile file = await controller.takePicture();
    final Image image = await decodeImageFromList(
      File.fromUri(Uri.parse(file.uri)).readAsBytesSync(),
    );
    return Size(image.width.toDouble(), image.height.toDouble());
  }

  testWidgets('Capture specific image resolutions', (WidgetTester tester) async {
    final List<CameraDescription> cameras = await CameraPlatform.instance.availableCameras();
    if (cameras.isEmpty) {
      return;
    }
    for (final cameraDescription in cameras) {
      await expectNonDecreasingCaptureSizes(cameraDescription, captureImageSize);
    }
  });

  Future<Size> captureVideoSize(CameraController controller) async {
    await controller.prepareForVideoRecording();
    await controller.startVideoRecording();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final XFile file = await controller.stopVideoRecording();

    final videoController = VideoPlayerController.file(File.fromUri(Uri.parse(file.uri)));
    await videoController.initialize();
    final Size size = videoController.value.size;
    await videoController.dispose();
    return size;
  }

  testWidgets('Capture specific video resolutions', (WidgetTester tester) async {
    final List<CameraDescription> cameras = await CameraPlatform.instance.availableCameras();
    if (cameras.isEmpty) {
      return;
    }
    for (final cameraDescription in cameras) {
      await expectNonDecreasingCaptureSizes(cameraDescription, captureVideoSize);
    }
  });

  testWidgets('Pause and resume video recording', (WidgetTester tester) async {
    final List<CameraDescription> cameras = await CameraPlatform.instance.availableCameras();
    if (cameras.isEmpty) {
      return;
    }

    final controller = CameraController(cameras[0], ResolutionPreset.low, enableAudio: false);

    await controller.initialize();
    await controller.prepareForVideoRecording();

    int startPause;
    var timePaused = 0;

    await controller.startVideoRecording();
    final int recordingStart = DateTime.now().millisecondsSinceEpoch;
    await Future<void>.delayed(const Duration(milliseconds: 500));

    await controller.pauseVideoRecording();
    startPause = DateTime.now().millisecondsSinceEpoch;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await controller.resumeVideoRecording();
    timePaused += DateTime.now().millisecondsSinceEpoch - startPause;

    await Future<void>.delayed(const Duration(milliseconds: 500));

    await controller.pauseVideoRecording();
    startPause = DateTime.now().millisecondsSinceEpoch;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await controller.resumeVideoRecording();
    timePaused += DateTime.now().millisecondsSinceEpoch - startPause;

    await Future<void>.delayed(const Duration(milliseconds: 500));

    final XFile file = await controller.stopVideoRecording();
    final int recordingTime = DateTime.now().millisecondsSinceEpoch - recordingStart;

    final videoFile = File.fromUri(Uri.parse(file.uri));
    final videoController = VideoPlayerController.file(videoFile);
    await videoController.initialize();
    final int duration = videoController.value.duration.inMilliseconds;
    await videoController.dispose();

    expect(duration, lessThan(recordingTime - timePaused));
  });

  testWidgets('Set description while recording', (WidgetTester tester) async {
    final List<CameraDescription> cameras = await CameraPlatform.instance.availableCameras();
    if (cameras.length < 2) {
      return;
    }

    final controller = CameraController(cameras[0], ResolutionPreset.low, enableAudio: false);

    await controller.initialize();
    await controller.prepareForVideoRecording();

    await controller.startVideoRecording();
    await controller.setDescription(cameras[1]);

    expect(controller.description, cameras[1]);
  });

  testWidgets('Set description', (WidgetTester tester) async {
    final List<CameraDescription> cameras = await CameraPlatform.instance.availableCameras();
    if (cameras.length < 2) {
      return;
    }

    final controller = CameraController(cameras[0], ResolutionPreset.low, enableAudio: false);

    await controller.initialize();
    await controller.setDescription(cameras[1]);

    expect(controller.description, cameras[1]);
  });

  /// Start streaming with specifying the ImageFormatGroup.
  Future<CameraImageData> startStreaming(
    List<CameraDescription> cameras,
    ImageFormatGroup? imageFormatGroup,
  ) async {
    final controller = CameraController(
      cameras.first,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: imageFormatGroup,
    );

    await controller.initialize();
    final completer = Completer<CameraImageData>();

    await controller.startImageStream((CameraImageData image) {
      if (!completer.isCompleted) {
        Future<void>(() async {
          await controller.stopImageStream();
          await controller.dispose();
        }).then((Object? value) {
          completer.complete(image);
        });
      }
    });
    return completer.future;
  }

  testWidgets('image streaming with imageFormatGroup', (WidgetTester tester) async {
    final List<CameraDescription> cameras = await CameraPlatform.instance.availableCameras();
    if (cameras.isEmpty) {
      return;
    }

    CameraImageData image = await startStreaming(cameras, null);
    expect(image, isNotNull);
    expect(image.format.group, ImageFormatGroup.bgra8888);
    expect(image.planes.length, 1);

    image = await startStreaming(cameras, ImageFormatGroup.yuv420);
    expect(image, isNotNull);
    expect(image.format.group, ImageFormatGroup.yuv420);
    expect(image.planes.length, 2);

    image = await startStreaming(cameras, ImageFormatGroup.bgra8888);
    expect(image, isNotNull);
    expect(image.format.group, ImageFormatGroup.bgra8888);
    expect(image.planes.length, 1);
  });

  testWidgets('Recording with video streaming', (WidgetTester tester) async {
    final List<CameraDescription> cameras = await CameraPlatform.instance.availableCameras();
    if (cameras.isEmpty) {
      return;
    }

    final controller = CameraController(cameras[0], ResolutionPreset.low, enableAudio: false);

    await controller.initialize();
    await controller.prepareForVideoRecording();
    final completer = Completer<CameraImageData>();
    await controller.startVideoRecording(
      streamCallback: (CameraImageData image) {
        if (!completer.isCompleted) {
          completer.complete(image);
        }
      },
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await controller.stopVideoRecording();
    await controller.dispose();

    expect(await completer.future, isNotNull);
  });

  // Test fileFormat is respected when taking a picture.
  testWidgets('Capture specific image output formats', (WidgetTester tester) async {
    final List<CameraDescription> cameras = await CameraPlatform.instance.availableCameras();
    if (cameras.isEmpty) {
      return;
    }
    for (final cameraDescription in cameras) {
      for (final ImageFileFormat fileFormat in ImageFileFormat.values) {
        final controller = CameraController(cameraDescription, ResolutionPreset.low);
        await controller.initialize();
        await controller.setImageFileFormat(fileFormat);
        final XFile file = await controller.takePicture();
        await controller.dispose();
        final String expectedExtension = switch (fileFormat) {
          ImageFileFormat.jpeg => 'jpg',
          ImageFileFormat.heif => 'heif',
        };
        expect(Uri.parse(file.uri).toFilePath().endsWith(expectedExtension), true);
      }
    }
  });
}
