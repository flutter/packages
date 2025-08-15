// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';
import 'dart:math';
import 'dart:ui';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/camera_web.dart';
import 'package:camera_web/src/camera.dart';
import 'package:camera_web/src/types/types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:web/web.dart';

import 'helpers/helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const Size videoSize = Size(320, 240);

  /// Draw some seconds of random video frames on canvas in realtime.
  Future<void> simulateCamera(HTMLCanvasElement canvasElement) async {
    const int fps = 15;
    const int seconds = 3;
    const int frameDuration = 1000 ~/ fps;
    final Random random = Random(0);

    for (int n = 0; n < fps * seconds; n++) {
      await Future<void>.delayed(const Duration(milliseconds: frameDuration));
      final int w = videoSize.width ~/ 20;
      final int h = videoSize.height ~/ 20;
      for (int y = 0; y < videoSize.height; y += h) {
        for (int x = 0; x < videoSize.width; x += w) {
          final int r = random.nextInt(255);
          final int g = random.nextInt(255);
          final int b = random.nextInt(255);
          canvasElement.context2D.fillStyle = 'rgba($r, $g, $b, 1)'.toJS;
          canvasElement.context2D.fillRect(x, y, w, h);
        }
      }
    }
  }

  testWidgets('Camera allows to control video bitrate',
      (WidgetTester tester) async {
    //const String supportedVideoType = 'video/webm';
    const String supportedVideoType = 'video/webm;codecs="vp9,opus"';
    bool isVideoTypeSupported(String type) => type == supportedVideoType;

    Future<int> recordVideo(int videoBitrate) async {
      final MockWindow mockWindow = MockWindow();
      final MockNavigator mockNavigator = MockNavigator();
      final MockMediaDevices mockMediaDevices = MockMediaDevices();

      final Window window = createJSInteropWrapper(mockWindow) as Window;
      final Navigator navigator =
          createJSInteropWrapper(mockNavigator) as Navigator;
      final MediaDevices mediaDevices =
          createJSInteropWrapper(mockMediaDevices) as MediaDevices;

      mockWindow.navigator = navigator;
      mockNavigator.mediaDevices = mediaDevices;

      final HTMLCanvasElement canvasElement = HTMLCanvasElement()
        ..width = videoSize.width.toInt()
        ..height = videoSize.height.toInt()
        ..context2D.clearRect(0, 0, videoSize.width, videoSize.height);

      final HTMLVideoElement videoElement = HTMLVideoElement();

      final MockCameraService cameraService = MockCameraService();

      CameraPlatform.instance = CameraPlugin(
        cameraService: cameraService,
      )..window = window;

      final CameraOptions options = CameraOptions(
        audio: const AudioConstraints(),
        video: VideoConstraints(
          width: VideoSizeConstraint(
            ideal: videoSize.width.toInt(),
          ),
          height: VideoSizeConstraint(
            ideal: videoSize.height.toInt(),
          ),
        ),
      );

      final int cameraId = videoBitrate;

      when(
        cameraService.getMediaStreamForOptions(
          options,
          cameraId: cameraId,
        ),
      ).thenAnswer((_) async => canvasElement.captureStream());

      final Camera camera = Camera(
          textureId: cameraId,
          cameraService: cameraService,
          options: options,
          recorderOptions: (
            audioBitrate: null,
            videoBitrate: videoBitrate,
          ))
        ..isVideoTypeSupported = isVideoTypeSupported;

      await camera.initialize();
      await camera.play();

      await camera.startVideoRecording();

      await simulateCamera(canvasElement);

      final XFile file = await camera.stopVideoRecording();

      // Real movie can be saved locally during manual test invocation.
      // First: add '--no-headless' to _targetDeviceFlags in
      // `script/tool/lib/src/drive_examples_command.dart`, then uncomment:
      // Second: uncomment next line
      // await file.saveTo('movie.$videoBitrate.webm');

      await camera.dispose();

      final int length = await file.length();

      videoElement.remove();

      canvasElement.remove();

      return length;
    }

    const int kilobits = 1024;
    const int megabits = kilobits * kilobits;

    final int lengthSmall = await recordVideo(500 * kilobits);
    final int lengthLarge = await recordVideo(2 * megabits);
    final int lengthMedium = await recordVideo(1 * megabits);

    expect(lengthSmall, lessThan(lengthMedium));
    expect(lengthMedium, lessThan(lengthLarge));
  });
}
