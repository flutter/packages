// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:camera_linux/camera_linux.dart';
import 'package:camera_linux/src/v4l2_camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// A capture session that hands out the frames it is given.
class FakeSession implements CaptureSession {
  FakeSession(this.devicePath, this.width, this.height);

  @override
  final String devicePath;
  @override
  final int width;
  @override
  final int height;

  final List<Uint8List> pending = <Uint8List>[];
  CameraException? failure;
  bool closed = false;

  @override
  Uint8List? readJpeg() {
    if (closed) {
      throw CameraException('camera_error', 'closed');
    }
    if (failure != null) {
      throw failure!;
    }
    return pending.isEmpty ? null : pending.removeAt(0);
  }

  @override
  void close() {
    closed = true;
  }
}

/// A tiny solid JPEG, so that the preview widget can decode it.
Uint8List _solidJpeg(int r, int g, int b) {
  final image = img.Image(width: 8, height: 8);
  img.fill(image, color: image.getColor(r, g, b));
  return img.encodeJpg(image);
}

final Uint8List fakeJpeg = _solidJpeg(255, 0, 0);
final Uint8List otherJpeg = _solidJpeg(0, 0, 255);

const CameraDescription testCamera = CameraDescription(
  name: '/dev/video7',
  lensDirection: CameraLensDirection.external,
  sensorOrientation: 0,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<FakeSession> opened;
  late List<(String, int, int)> openRequests;
  late Directory tempDir;
  late CameraLinux plugin;

  setUp(() {
    opened = <FakeSession>[];
    openRequests = <(String, int, int)>[];
    tempDir = Directory.systemTemp.createTempSync('camera_linux_test');
    plugin = CameraLinux(
      listDevices: () => const <V4l2Device>[
        V4l2Device(path: '/dev/video7', name: 'Test cam', pixelFormat: 'YUYV'),
        V4l2Device(path: '/dev/video9', name: 'Other cam', pixelFormat: 'MJPG'),
      ],
      openSession: (String path, int width, int height) {
        openRequests.add((path, width, height));
        if (path == '/dev/video9') {
          throw CameraException('camera_error', '/dev/video9: busy');
        }
        final session = FakeSession(path, 640, 480);
        opened.add(session);
        return session;
      },
      pictureDirectory: tempDir,
    );
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  test('registerWith installs the plugin', () {
    CameraLinux.registerWith();
    expect(CameraPlatform.instance, isA<CameraLinux>());
  });

  test('availableCameras lists V4L2 devices by node path', () async {
    final List<CameraDescription> cameras = await plugin.availableCameras();
    expect(cameras.map((CameraDescription c) => c.name), <String>['/dev/video7', '/dev/video9']);
    expect(cameras.first.lensDirection, CameraLensDirection.external);
  });

  group('creation and initialization', () {
    test('createCamera returns distinct ids without opening the device', () async {
      final int first = await plugin.createCamera(testCamera, ResolutionPreset.medium);
      final int second = await plugin.createCamera(testCamera, ResolutionPreset.medium);
      expect(first, isNot(second));
      expect(opened, isEmpty);
    });

    test('initializeCamera opens the device at the preset size and reports it', () async {
      final int id = await plugin.createCamera(testCamera, ResolutionPreset.high);
      final Future<CameraInitializedEvent> initialized = plugin.onCameraInitialized(id).first;
      await plugin.initializeCamera(id);
      expect(openRequests, <(String, int, int)>[('/dev/video7', 1280, 720)]);
      final CameraInitializedEvent event = await initialized;
      expect(event.previewWidth, 640);
      expect(event.previewHeight, 480);
      expect(event.focusMode, FocusMode.auto);
    });

    test('a null preset requests 640x480 and max requests the largest size', () async {
      final int plain = await plugin.createCameraWithSettings(testCamera, null);
      await plugin.initializeCamera(plain);
      final int max = await plugin.createCamera(testCamera, ResolutionPreset.max);
      await plugin.initializeCamera(max);
      expect(openRequests[0], ('/dev/video7', 640, 480));
      expect(openRequests[1].$2, greaterThan(4000));
    });

    test('initializing twice is a no-op', () async {
      final int id = await plugin.createCamera(testCamera, null);
      await plugin.initializeCamera(id);
      await plugin.initializeCamera(id);
      expect(opened, hasLength(1));
    });

    test('initializeCamera surfaces the driver error', () async {
      final int id = await plugin.createCamera(
        const CameraDescription(
          name: '/dev/video9',
          lensDirection: CameraLensDirection.external,
          sensorOrientation: 0,
        ),
        null,
      );
      expect(
        () => plugin.initializeCamera(id),
        throwsA(
          isA<CameraException>().having(
            (CameraException e) => e.description,
            'description',
            '/dev/video9: busy',
          ),
        ),
      );
    });

    test('unknown camera ids throw CameraException', () async {
      expect(() => plugin.initializeCamera(1234), throwsA(isA<CameraException>()));
      expect(() => plugin.takePicture(1234), throwsA(isA<CameraException>()));
      expect(() => plugin.buildPreview(1234), throwsA(isA<CameraException>()));
      expect(() => plugin.onStreamedFrameAvailable(1234), throwsA(isA<CameraException>()));
      expect(() => plugin.pausePreview(1234), throwsA(isA<CameraException>()));
      // Disposing something that does not exist is harmless.
      await plugin.dispose(1234);
    });

    test('created but not initialized cameras cannot be used', () async {
      final int id = await plugin.createCamera(testCamera, null);
      expect(
        () => plugin.takePicture(id),
        throwsA(
          isA<CameraException>().having(
            (CameraException e) => e.code,
            'code',
            'camera_not_initialized',
          ),
        ),
      );
    });
  });

  group('frames', () {
    test('takePicture writes the next frame to a JPEG file', () async {
      final int id = await plugin.createCamera(testCamera, null);
      await plugin.initializeCamera(id);
      opened.single.pending.add(fakeJpeg);
      final XFile file = await plugin.takePicture(id);
      expect(file.path, startsWith(tempDir.path));
      expect(file.path, endsWith('.jpg'));
      expect(file.mimeType, 'image/jpeg');
      expect(await file.readAsBytes(), fakeJpeg);
    });

    test('onStreamedFrameAvailable delivers JPEG image data', () async {
      final int id = await plugin.createCamera(testCamera, null);
      await plugin.initializeCamera(id);
      final Future<CameraImageData> next = plugin.onStreamedFrameAvailable(id).first;
      opened.single.pending.add(fakeJpeg);
      final CameraImageData image = await next;
      expect(image.format.group, ImageFormatGroup.jpeg);
      expect(image.width, 640);
      expect(image.height, 480);
      expect(image.planes.single.bytes, fakeJpeg);
      expect(plugin.supportsImageStreaming(), isTrue);
    });

    test('a failing capture is reported on onCameraError and to listeners', () async {
      final int id = await plugin.createCamera(testCamera, null);
      await plugin.initializeCamera(id);
      final Future<CameraErrorEvent> error = plugin.onCameraError(id).first;
      final streamError = Completer<Object>();
      plugin.onStreamedFrameAvailable(id).listen((_) {}, onError: streamError.complete);
      opened.single.failure = CameraException('camera_error', '/dev/video7: device error');
      expect((await error).description, '/dev/video7: device error');
      expect(await streamError.future, isA<CameraException>());
    });

    test('takePicture times out without frames', () async {
      final int id = await plugin.createCamera(testCamera, null);
      await plugin.initializeCamera(id);
      await expectLater(
        plugin.takePicture(id),
        throwsA(
          isA<CameraException>().having((CameraException e) => e.code, 'code', 'capture_error'),
        ),
      );
    }, timeout: const Timeout(Duration(seconds: 15)));

    testWidgets('buildPreview shows frames and honours pausePreview', (WidgetTester tester) async {
      final int id = await plugin.createCamera(testCamera, null);
      await plugin.initializeCamera(id);
      await tester.pumpWidget(plugin.buildPreview(id));
      expect(find.byType(Image), findsNothing);

      opened.single.pending.add(fakeJpeg);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      expect(find.byType(Image), findsOneWidget);

      await plugin.pausePreview(id);
      final Uint8List other = otherJpeg;
      opened.single.pending.add(other);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      expect((tester.widget<Image>(find.byType(Image)).image as MemoryImage).bytes, fakeJpeg);

      await plugin.resumePreview(id);
      opened.single.pending.add(other);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      expect((tester.widget<Image>(find.byType(Image)).image as MemoryImage).bytes, other);

      await plugin.dispose(id);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('dispose', () {
    test('closes the session and emits CameraClosingEvent', () async {
      final int id = await plugin.createCamera(testCamera, null);
      await plugin.initializeCamera(id);
      final Future<CameraClosingEvent> closing = plugin.onCameraClosing(id).first;
      await plugin.dispose(id);
      await closing;
      expect(opened.single.closed, isTrue);
      expect(() => plugin.takePicture(id), throwsA(isA<CameraException>()));
    });
  });

  group('unsupported features', () {
    test('report UnsupportedError rather than failing silently', () async {
      final int id = await plugin.createCamera(testCamera, null);
      await plugin.initializeCamera(id);
      expect(() => plugin.startVideoRecording(id), throwsUnsupportedError);
      expect(() => plugin.stopVideoRecording(id), throwsUnsupportedError);
      expect(() => plugin.setFlashMode(id, FlashMode.torch), throwsUnsupportedError);
      expect(() => plugin.setZoomLevel(id, 2), throwsUnsupportedError);
      expect(() => plugin.setFocusMode(id, FocusMode.locked), throwsUnsupportedError);
      expect(await plugin.getMaxZoomLevel(id), 1.0);
      expect(await plugin.getMinExposureOffset(id), 0.0);
      expect(
        await plugin.onDeviceOrientationChanged().first,
        isA<DeviceOrientationChangedEvent>().having(
          (DeviceOrientationChangedEvent e) => e.orientation,
          'orientation',
          DeviceOrientation.landscapeRight,
        ),
      );
    });
  });
}
