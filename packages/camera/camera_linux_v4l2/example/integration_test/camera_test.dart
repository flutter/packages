// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_linux_v4l2/camera_linux_v4l2.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the Linux implementation is registered', (WidgetTester _) async {
    expect(CameraPlatform.instance, isA<CameraLinuxV4l2>());
  });

  group('without a created camera', () {
    testWidgets('initializeCamera throws CameraException', (WidgetTester _) async {
      final CameraPlatform camera = CameraPlatform.instance;
      await expectLater(camera.initializeCamera(1234), throwsA(isA<CameraException>()));
    });

    testWidgets('onStreamedFrameAvailable throws CameraException', (WidgetTester _) async {
      final CameraPlatform camera = CameraPlatform.instance;
      expect(() => camera.onStreamedFrameAvailable(1234), throwsA(isA<CameraException>()));
    });
  });

  group('with the first available camera', () {
    late List<CameraDescription> cameras;

    setUpAll(() async {
      cameras = await CameraPlatform.instance.availableCameras();
    });

    testWidgets('initializes, renders texture preview, streams BGRA8888, and disposes', (
      WidgetTester tester,
    ) async {
      if (cameras.isEmpty) {
        markTestSkipped('no camera attached');
        return;
      }

      final CameraPlatform camera = CameraPlatform.instance;
      final int cameraId = await camera.createCamera(cameras.first, ResolutionPreset.medium);
      final Future<CameraInitializedEvent> initialized = camera.onCameraInitialized(cameraId).first;
      await camera.initializeCamera(cameraId);
      final CameraInitializedEvent event = await initialized;
      expect(event.previewWidth, greaterThan(0));
      expect(event.previewHeight, greaterThan(0));

      final Widget preview = camera.buildPreview(cameraId);
      expect(preview, isA<Texture>());
      expect((preview as Texture).textureId, cameraId);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(width: 320, height: 240, child: preview),
        ),
      );
      await tester.pump();

      final CameraImageData frame = await camera
          .onStreamedFrameAvailable(cameraId)
          .first
          .timeout(const Duration(seconds: 5));
      expect(frame.format.group, ImageFormatGroup.bgra8888);
      expect(frame.width, event.previewWidth.round());
      expect(frame.height, event.previewHeight.round());
      expect(frame.planes.single.bytes.length, frame.width * frame.height * 4);

      final Future<CameraClosingEvent> closing = camera.onCameraClosing(cameraId).first;
      await camera.dispose(cameraId);
      await closing.timeout(const Duration(seconds: 5));
    });
  });
}
