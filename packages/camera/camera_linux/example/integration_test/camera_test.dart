// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_linux/camera_linux.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Most code paths need a camera. Tests that do are skipped when none is
// attached; the unit tests cover them with a fake capture session.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('the Linux implementation is registered', () {
    expect(CameraPlatform.instance, isA<CameraLinux>());
  });

  group('without a created camera', () {
    testWidgets('initializeCamera throws CameraException', (WidgetTester _) async {
      final CameraPlatform camera = CameraPlatform.instance;
      expect(() async => camera.initializeCamera(1234), throwsA(isA<CameraException>()));
    });

    testWidgets('takePicture throws CameraException', (WidgetTester _) async {
      final CameraPlatform camera = CameraPlatform.instance;
      expect(() async => camera.takePicture(1234), throwsA(isA<CameraException>()));
    });

    testWidgets('pausePreview and resumePreview throw CameraException', (WidgetTester _) async {
      final CameraPlatform camera = CameraPlatform.instance;
      expect(() async => camera.pausePreview(1234), throwsA(isA<CameraException>()));
      expect(() async => camera.resumePreview(1234), throwsA(isA<CameraException>()));
    });
  });

  group('with the first available camera', () {
    late List<CameraDescription> cameras;

    setUpAll(() async {
      cameras = await CameraPlatform.instance.availableCameras();
    });

    testWidgets('initializes, streams a picture and disposes', (WidgetTester _) async {
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

      final XFile picture = await camera.takePicture(cameraId);
      final List<int> bytes = await picture.readAsBytes();
      expect(bytes.length, greaterThan(100));
      expect(bytes.sublist(0, 2), <int>[0xff, 0xd8]);

      final CameraImageData frame = await camera.onStreamedFrameAvailable(cameraId).first;
      expect(frame.format.group, ImageFormatGroup.jpeg);
      expect(frame.width, event.previewWidth.round());

      final Future<CameraClosingEvent> closing = camera.onCameraClosing(cameraId).first;
      await camera.dispose(cameraId);
      await closing.timeout(const Duration(seconds: 5));
    });
  });
}
