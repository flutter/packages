// Copyright 2013 The Flutter Authors. All rights reserved.
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

  final Map<ResolutionPreset, Size> presetExpectedSizes =
      <ResolutionPreset, Size>{
    ResolutionPreset.low: const Size(288, 352),
    ResolutionPreset.medium: const Size(480, 640),
    ResolutionPreset.high: const Size(720, 1280),
    ResolutionPreset.veryHigh: const Size(1080, 1920),
    ResolutionPreset.ultraHigh: const Size(2160, 3840),
    // Don't bother checking for max here since it could be anything.
  };

  /// Verify that [actual] has dimensions that are at least as large as
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
        final CameraController controller =
            CameraController(cameraDescription, preset.key);
        await controller.initialize();
        final bool presetExactlySupported =
            await testCaptureImageResolution(controller, preset.key);
        assert(!(!previousPresetExactlySupported && presetExactlySupported),
            'The camera took higher resolution pictures at a lower resolution.');
        previousPresetExactlySupported = presetExactlySupported;
        await controller.dispose();
      }
    }
  });

  // This tests that the capture is no bigger than the preset, since we have
  // automatic code to fall back to smaller sizes when we need to. Returns
  // whether the image is exactly the desired resolution.
  Future<bool> testCaptureVideoResolution(
      CameraController controller, ResolutionPreset preset) async {
    final Size expectedSize = presetExpectedSizes[preset]!;

    // Take Video
    await controller.startVideoRecording();
    sleep(const Duration(milliseconds: 300));
    final XFile file = await controller.stopVideoRecording();

    // Load video metadata
    final File videoFile = File(file.path);
    final VideoPlayerController videoController =
        VideoPlayerController.file(videoFile);
    await videoController.initialize();
    final Size video = videoController.value.size;

    // Verify image dimensions are as expected
    expect(video, isNotNull);
    return assertExpectedDimensions(
        expectedSize, Size(video.height, video.width));
  }

  testWidgets('Capture specific video resolutions',
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
        final CameraController controller =
            CameraController(cameraDescription, preset.key);
        await controller.initialize();
        await controller.prepareForVideoRecording();
        final bool presetExactlySupported =
            await testCaptureVideoResolution(controller, preset.key);
        assert(!(!previousPresetExactlySupported && presetExactlySupported),
            'The camera took higher resolution pictures at a lower resolution.');
        previousPresetExactlySupported = presetExactlySupported;
        await controller.dispose();
      }
    }
  });

  testWidgets('Pause and resume video recording', (WidgetTester tester) async {
    final List<CameraDescription> cameras =
        await CameraPlatform.instance.availableCameras();
    if (cameras.isEmpty) {
      return;
    }

    final CameraController controller = CameraController(
      cameras[0],
      ResolutionPreset.low,
      enableAudio: false,
    );

    await controller.initialize();
    await controller.prepareForVideoRecording();

    int startPause;
    int timePaused = 0;

    await controller.startVideoRecording();
    final int recordingStart = DateTime.now().millisecondsSinceEpoch;
    sleep(const Duration(milliseconds: 500));

    await controller.pauseVideoRecording();
    startPause = DateTime.now().millisecondsSinceEpoch;
    sleep(const Duration(milliseconds: 500));
    await controller.resumeVideoRecording();
    timePaused += DateTime.now().millisecondsSinceEpoch - startPause;

    sleep(const Duration(milliseconds: 500));

    await controller.pauseVideoRecording();
    startPause = DateTime.now().millisecondsSinceEpoch;
    sleep(const Duration(milliseconds: 500));
    await controller.resumeVideoRecording();
    timePaused += DateTime.now().millisecondsSinceEpoch - startPause;

    sleep(const Duration(milliseconds: 500));

    final XFile file = await controller.stopVideoRecording();
    final int recordingTime =
        DateTime.now().millisecondsSinceEpoch - recordingStart;

    final File videoFile = File(file.path);
    final VideoPlayerController videoController = VideoPlayerController.file(
      videoFile,
    );
    await videoController.initialize();
    final int duration = videoController.value.duration.inMilliseconds;
    await videoController.dispose();

    expect(duration, lessThan(recordingTime - timePaused));
  });

  testWidgets('Set description while recording', (WidgetTester tester) async {
    final List<CameraDescription> cameras =
        await CameraPlatform.instance.availableCameras();
    if (cameras.length < 2) {
      return;
    }

    final CameraController controller = CameraController(
      cameras[0],
      ResolutionPreset.low,
      enableAudio: false,
    );

    await controller.initialize();
    await controller.prepareForVideoRecording();

    await controller.startVideoRecording();
    await controller.setDescription(cameras[1]);

    expect(controller.description, cameras[1]);
  });

  testWidgets('Set description', (WidgetTester tester) async {
    final List<CameraDescription> cameras =
        await CameraPlatform.instance.availableCameras();
    if (cameras.length < 2) {
      return;
    }

    final CameraController controller = CameraController(
      cameras[0],
      ResolutionPreset.low,
      enableAudio: false,
    );

    await controller.initialize();
    await controller.setDescription(cameras[1]);

    expect(controller.description, cameras[1]);
  });

  /// Start streaming with specifying the ImageFormatGroup.
  Future<CameraImageData> startStreaming(List<CameraDescription> cameras,
      ImageFormatGroup? imageFormatGroup) async {
    final CameraController controller = CameraController(
      cameras.first,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: imageFormatGroup,
    );

    await controller.initialize();
    final Completer<CameraImageData> completer = Completer<CameraImageData>();

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

  testWidgets(
    'image streaming with imageFormatGroup',
    (WidgetTester tester) async {
      final List<CameraDescription> cameras =
          await CameraPlatform.instance.availableCameras();
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
    },
  );

  testWidgets('Recording with video streaming', (WidgetTester tester) async {
    final List<CameraDescription> cameras =
        await CameraPlatform.instance.availableCameras();
    if (cameras.isEmpty) {
      return;
    }

    final CameraController controller = CameraController(
      cameras[0],
      ResolutionPreset.low,
      enableAudio: false,
    );

    await controller.initialize();
    await controller.prepareForVideoRecording();
    final Completer<CameraImageData> completer = Completer<CameraImageData>();
    await controller.startVideoRecording(
        streamCallback: (CameraImageData image) {
      if (!completer.isCompleted) {
        completer.complete(image);
      }
    });
    sleep(const Duration(milliseconds: 500));
    await controller.stopVideoRecording();
    await controller.dispose();

    expect(await completer.future, isNotNull);
  });

  // Test fileFormat is respected when taking a picture.
  testWidgets('Capture specific image output formats',
      (WidgetTester tester) async {
    final List<CameraDescription> cameras =
        await CameraPlatform.instance.availableCameras();
    if (cameras.isEmpty) {
      return;
    }
    for (final CameraDescription cameraDescription in cameras) {
      for (final ImageFileFormat fileFormat in ImageFileFormat.values) {
        final CameraController controller =
            CameraController(cameraDescription, ResolutionPreset.low);
        await controller.initialize();
        await controller.setImageFileFormat(fileFormat);
        final XFile file = await controller.takePicture();
        await controller.dispose();
        expect(file.path.endsWith(fileFormat.name), true);
      }
    }
  });

  group('Camera settings', () {
    testWidgets('Control FPS', (WidgetTester tester) async {
      final List<CameraDescription> cameras =
          await CameraPlatform.instance.availableCameras();
      if (cameras.isEmpty) {
        return;
      }

      final List<int> lengths = <int>[];
      for (final int fps in <int>[10, 30]) {
        final CameraController controller = CameraController.withSettings(
          cameras.first,
          mediaSettings: MediaSettings(
            resolutionPreset: ResolutionPreset.medium,
            fps: fps,
          ),
        );
        await controller.initialize();
        await controller.prepareForVideoRecording();

        // Take Video
        await controller.startVideoRecording();
        sleep(const Duration(milliseconds: 500));
        final XFile file = await controller.stopVideoRecording();

        // Load video size
        final File videoFile = File(file.path);

        lengths.add(await videoFile.length());

        await controller.dispose();
      }

      for (int n = 0; n < lengths.length - 1; n++) {
        expect(lengths[n], lessThan(lengths[n + 1]),
            reason: 'incrementing fps should increment file size');
      }
    });

    testWidgets('Control video bitrate', (WidgetTester tester) async {
      final List<CameraDescription> cameras =
          await CameraPlatform.instance.availableCameras();
      if (cameras.isEmpty) {
        return;
      }

      const int kiloBits = 1024;
      final List<int> lengths = <int>[];
      for (final int videoBitrate in <int>[100 * kiloBits, 1000 * kiloBits]) {
        final CameraController controller = CameraController.withSettings(
          cameras.first,
          mediaSettings: MediaSettings(
            resolutionPreset: ResolutionPreset.medium,
            videoBitrate: videoBitrate,
          ),
        );
        await controller.initialize();
        await controller.prepareForVideoRecording();

        // Take Video
        await controller.startVideoRecording();
        sleep(const Duration(milliseconds: 500));
        final XFile file = await controller.stopVideoRecording();

        // Load video size
        final File videoFile = File(file.path);

        lengths.add(await videoFile.length());

        await controller.dispose();
      }

      for (int n = 0; n < lengths.length - 1; n++) {
        expect(lengths[n], lessThan(lengths[n + 1]),
            reason: 'incrementing video bitrate should increment file size');
      }
    });

    testWidgets('Control audio bitrate', (WidgetTester tester) async {
      final List<CameraDescription> cameras =
          await CameraPlatform.instance.availableCameras();
      if (cameras.isEmpty) {
        return;
      }

      final List<int> lengths = <int>[];

      const int kiloBits = 1024;
      for (final int audioBitrate in <int>[32 * kiloBits, 64 * kiloBits]) {
        final CameraController controller = CameraController.withSettings(
          cameras.first,
          mediaSettings: MediaSettings(
              resolutionPreset: ResolutionPreset.low,
              fps: 5,
              videoBitrate: 32000,
              audioBitrate: audioBitrate,
              enableAudio: true),
        );
        await controller.initialize();
        await controller.prepareForVideoRecording();

        // Take Video
        await controller.startVideoRecording();
        sleep(const Duration(milliseconds: 1000));
        final XFile file = await controller.stopVideoRecording();

        // Load video metadata
        final File videoFile = File(file.path);

        final int length = await videoFile.length();

        lengths.add(length);

        await controller.dispose();
      }

      for (int n = 0; n < lengths.length - 1; n++) {
        expect(lengths[n], lessThan(lengths[n + 1]),
            reason: 'incrementing audio bitrate should increment file size');
      }
    });
  });
}
