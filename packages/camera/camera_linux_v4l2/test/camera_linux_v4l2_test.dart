// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:camera_linux_v4l2/camera_linux_v4l2.dart';
import 'package:camera_linux_v4l2/src/messages.g.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'camera_linux_v4l2_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[MockSpec<CameraApi>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$CameraLinuxV4l2()', () {
    test('registerWith installs CameraLinuxV4l2', () {
      CameraLinuxV4l2.registerWith();
      expect(CameraPlatform.instance, isA<CameraLinuxV4l2>());
    });

    group('availableCameras', () {
      test('maps device paths to external CameraDescriptions', () async {
        final mockApi = MockCameraApi();
        when(
          mockApi.getAvailableCameras(),
        ).thenAnswer((_) async => <String>['/dev/video0', '/dev/video2']);
        final plugin = CameraLinuxV4l2(api: mockApi);

        final List<CameraDescription> cameras = await plugin.availableCameras();

        expect(cameras, <CameraDescription>[
          const CameraDescription(
            name: '/dev/video0',
            lensDirection: CameraLensDirection.external,
            sensorOrientation: 0,
          ),
          const CameraDescription(
            name: '/dev/video2',
            lensDirection: CameraLensDirection.external,
            sensorOrientation: 0,
          ),
        ]);
      });

      test('converts PlatformException into CameraException', () async {
        final mockApi = MockCameraApi();
        when(
          mockApi.getAvailableCameras(),
        ).thenThrow(PlatformException(code: 'enum_error', message: 'Failed to scan /dev'));
        final plugin = CameraLinuxV4l2(api: mockApi);

        await expectLater(
          plugin.availableCameras(),
          throwsA(
            isA<CameraException>()
                .having((CameraException e) => e.code, 'code', 'enum_error')
                .having((CameraException e) => e.description, 'description', 'Failed to scan /dev'),
          ),
        );
      });
    });

    group('creation, initialization, and disposal', () {
      const testCamera = CameraDescription(
        name: '/dev/video0',
        lensDirection: CameraLensDirection.external,
        sensorOrientation: 0,
      );

      test('createCamera and createCameraWithSettings map every preset', () async {
        final mockApi = MockCameraApi();
        var nextId = 10;
        when(mockApi.create(any, any)).thenAnswer((_) async => nextId++);
        final plugin = CameraLinuxV4l2(api: mockApi);

        final presets = <ResolutionPreset?, PlatformResolutionPreset>{
          null: PlatformResolutionPreset.medium,
          ResolutionPreset.low: PlatformResolutionPreset.low,
          ResolutionPreset.medium: PlatformResolutionPreset.medium,
          ResolutionPreset.high: PlatformResolutionPreset.high,
          ResolutionPreset.veryHigh: PlatformResolutionPreset.veryHigh,
          ResolutionPreset.ultraHigh: PlatformResolutionPreset.ultraHigh,
          ResolutionPreset.max: PlatformResolutionPreset.max,
        };

        for (final MapEntry<ResolutionPreset?, PlatformResolutionPreset> entry in presets.entries) {
          final int id = await plugin.createCamera(testCamera, entry.key);
          expect(id, greaterThanOrEqualTo(10));
          verify(mockApi.create('/dev/video0', entry.value)).called(1);
        }

        final int withSettingsId = await plugin.createCameraWithSettings(
          testCamera,
          const MediaSettings(resolutionPreset: ResolutionPreset.high),
        );
        expect(withSettingsId, 17);
        verify(mockApi.create('/dev/video0', PlatformResolutionPreset.high)).called(1);
      });

      test('createCamera converts PlatformException into CameraException', () async {
        final mockApi = MockCameraApi();
        when(
          mockApi.create(any, any),
        ).thenThrow(PlatformException(code: 'camera_error', message: 'Texture failure'));
        final plugin = CameraLinuxV4l2(api: mockApi);

        await expectLater(
          plugin.createCamera(testCamera, ResolutionPreset.medium),
          throwsA(
            isA<CameraException>()
                .having((CameraException e) => e.code, 'code', 'camera_error')
                .having((CameraException e) => e.description, 'description', 'Texture failure'),
          ),
        );
      });

      test('initializeCamera registers handler and emits CameraInitializedEvent', () async {
        final mockApi = MockCameraApi();
        when(
          mockApi.initialize(42),
        ).thenAnswer((_) async => PlatformSize(width: 1280, height: 720));
        final plugin = CameraLinuxV4l2(api: mockApi);

        final Future<CameraInitializedEvent> initialized = plugin.onCameraInitialized(42).first;
        await plugin.initializeCamera(42);
        final CameraInitializedEvent event = await initialized;

        expect(plugin.hostCameraHandlers.containsKey(42), isTrue);
        expect(event.cameraId, 42);
        expect(event.previewWidth, 1280);
        expect(event.previewHeight, 720);
        expect(event.exposureMode, ExposureMode.auto);
        expect(event.exposurePointSupported, isFalse);
        expect(event.focusMode, FocusMode.auto);
        expect(event.focusPointSupported, isFalse);

        await plugin.dispose(42);
      });

      test('initializeCamera cleans up handler on PlatformException', () async {
        final mockApi = MockCameraApi();
        when(
          mockApi.initialize(7),
        ).thenThrow(PlatformException(code: 'CameraAccessDenied', message: 'Permission denied'));
        final plugin = CameraLinuxV4l2(api: mockApi);

        await expectLater(
          plugin.initializeCamera(7),
          throwsA(
            isA<CameraException>()
                .having((CameraException e) => e.code, 'code', 'CameraAccessDenied')
                .having((CameraException e) => e.description, 'description', 'Permission denied'),
          ),
        );
        expect(plugin.hostCameraHandlers, isEmpty);
      });

      test('buildPreview returns a Texture widget for cameraId', () {
        final plugin = CameraLinuxV4l2(api: MockCameraApi());
        final Widget preview = plugin.buildPreview(55);
        expect(preview, isA<Texture>());
        expect((preview as Texture).textureId, 55);
      });

      test('dispose keeps handler alive until host dispose completes', () async {
        final mockApi = MockCameraApi();
        when(mockApi.initialize(9)).thenAnswer((_) async => PlatformSize(width: 640, height: 480));
        final hostDisposeCompleter = Completer<void>();
        when(mockApi.dispose(9)).thenAnswer((_) => hostDisposeCompleter.future);

        final plugin = CameraLinuxV4l2(api: mockApi);
        await plugin.initializeCamera(9);

        final Future<CameraClosingEvent> closingFuture = plugin.onCameraClosing(9).first;
        final Future<void> disposeFuture = plugin.dispose(9);

        // Simulate native cameraClosing arriving before host dispose finishes.
        plugin.hostCameraHandlers[9]!.cameraClosing();
        expect((await closingFuture).cameraId, 9);

        hostDisposeCompleter.complete();
        await disposeFuture;
        expect(plugin.hostCameraHandlers, isEmpty);
      });
    });

    group('image streaming and events', () {
      test('supportsImageStreaming returns true', () {
        expect(CameraLinuxV4l2(api: MockCameraApi()).supportsImageStreaming(), isTrue);
      });

      test('onStreamedFrameAvailable throws when camera is not initialized', () {
        final plugin = CameraLinuxV4l2(api: MockCameraApi());
        expect(
          () => plugin.onStreamedFrameAvailable(1),
          throwsA(
            isA<CameraException>().having(
              (CameraException e) => e.code,
              'code',
              'camera_not_initialized',
            ),
          ),
        );
      });

      test('onStreamedFrameAvailable streams BGRA8888 frames and manages lifecycle', () async {
        final mockApi = MockCameraApi();
        when(mockApi.initialize(3)).thenAnswer((_) async => PlatformSize(width: 2, height: 2));
        final plugin = CameraLinuxV4l2(api: mockApi);
        await plugin.initializeCamera(3);

        final Stream<CameraImageData> stream = plugin.onStreamedFrameAvailable(3);
        final received = <CameraImageData>[];
        final StreamSubscription<CameraImageData> subscription = stream.listen(received.add);

        await pumpEventQueue();
        verify(mockApi.startImageStream(3)).called(1);

        final bytes = Uint8List.fromList(<int>[
          1, 2, 3, 255, 4, 5, 6, 255, // row 0
          7, 8, 9, 255, 10, 11, 12, 255, // row 1
        ]);
        plugin.hostCameraHandlers[3]!.onFrameAvailable(2, 2, 8, bytes);
        await pumpEventQueue();

        expect(received, hasLength(1));
        final CameraImageData frame = received.single;
        expect(frame.format.group, ImageFormatGroup.bgra8888);
        expect(frame.format.raw, 0x34325241);
        expect(frame.width, 2);
        expect(frame.height, 2);
        expect(frame.planes, hasLength(1));
        expect(frame.planes.single.bytes, bytes);
        expect(frame.planes.single.bytesPerRow, 8);
        expect(frame.planes.single.bytesPerPixel, 4);
        expect(frame.planes.single.width, 2);
        expect(frame.planes.single.height, 2);

        // Pausing an image stream is unsupported per CameraPlatform contract.
        final pauseError = Completer<Object>();
        runZonedGuarded(subscription.pause, (Object error, StackTrace _) {
          if (!pauseError.isCompleted) {
            pauseError.complete(error);
          }
        });
        expect(
          await pauseError.future,
          isA<CameraException>().having((CameraException e) => e.code, 'code', 'InvalidCall'),
        );

        final resumeError = Completer<Object>();
        runZonedGuarded(subscription.resume, (Object error, StackTrace _) {
          if (!resumeError.isCompleted) {
            resumeError.complete(error);
          }
        });
        expect(
          await resumeError.future,
          isA<CameraException>().having((CameraException e) => e.code, 'code', 'InvalidCall'),
        );

        await subscription.cancel();
        verify(mockApi.stopImageStream(3)).called(1);
        await plugin.dispose(3);
      });

      test('startImageStream errors propagate onto image stream', () async {
        final mockApi = MockCameraApi();
        when(mockApi.initialize(4)).thenAnswer((_) async => PlatformSize(width: 640, height: 480));
        when(
          mockApi.startImageStream(4),
        ).thenThrow(PlatformException(code: 'stream_failed', message: 'Cannot start'));
        final plugin = CameraLinuxV4l2(api: mockApi);
        await plugin.initializeCamera(4);

        final errorCompleter = Completer<Object>();
        final StreamSubscription<CameraImageData> sub = plugin
            .onStreamedFrameAvailable(4)
            .listen((_) {}, onError: errorCompleter.complete);

        expect(
          await errorCompleter.future,
          isA<CameraException>()
              .having((CameraException e) => e.code, 'code', 'stream_failed')
              .having((CameraException e) => e.description, 'description', 'Cannot start'),
        );

        await sub.cancel();
        await plugin.dispose(4);
      });

      test('dispose while streaming skips redundant stopImageStream call', () async {
        final mockApi = MockCameraApi();
        when(mockApi.initialize(5)).thenAnswer((_) async => PlatformSize(width: 640, height: 480));
        final plugin = CameraLinuxV4l2(api: mockApi);
        await plugin.initializeCamera(5);

        final done = Completer<void>();
        final StreamSubscription<CameraImageData> sub = plugin
            .onStreamedFrameAvailable(5)
            .listen((_) {}, onDone: done.complete);
        await pumpEventQueue();

        await plugin.dispose(5);
        await done.future;
        await sub.cancel();

        verify(mockApi.dispose(5)).called(1);
        verifyNever(mockApi.stopImageStream(5));
      });

      test('replacing an image stream does not stop the new stream', () async {
        final mockApi = MockCameraApi();
        when(mockApi.initialize(6)).thenAnswer((_) async => PlatformSize(width: 1, height: 1));
        final plugin = CameraLinuxV4l2(api: mockApi);
        await plugin.initializeCamera(6);

        final firstDone = Completer<void>();
        plugin.onStreamedFrameAvailable(6).listen((_) {}, onDone: firstDone.complete);
        await pumpEventQueue();

        final received = <CameraImageData>[];
        final StreamSubscription<CameraImageData> second = plugin
            .onStreamedFrameAvailable(6)
            .listen(received.add);
        await firstDone.future;
        await pumpEventQueue();

        verify(mockApi.startImageStream(6)).called(2);
        verifyNever(mockApi.stopImageStream(6));
        plugin.hostCameraHandlers[6]!.onFrameAvailable(1, 1, 4, Uint8List(4));
        await pumpEventQueue();
        expect(received, hasLength(1));

        await second.cancel();
        verify(mockApi.stopImageStream(6)).called(1);
        await plugin.dispose(6);
      });

      test('forwards error, resolution, and orientation streams', () async {
        final mockApi = MockCameraApi();
        when(mockApi.initialize(8)).thenAnswer((_) async => PlatformSize(width: 640, height: 480));
        final plugin = CameraLinuxV4l2(api: mockApi);
        await plugin.initializeCamera(8);

        final Future<CameraErrorEvent> errorFuture = plugin.onCameraError(8).first;
        plugin.hostCameraHandlers[8]!.error('Device unplugged');
        final CameraErrorEvent errorEvent = await errorFuture;
        expect(errorEvent.cameraId, 8);
        expect(errorEvent.description, 'Device unplugged');

        expect(await plugin.onCameraResolutionChanged(8).isEmpty, isTrue);
        expect(
          (await plugin.onDeviceOrientationChanged().first).orientation,
          DeviceOrientation.landscapeRight,
        );

        await plugin.dispose(8);
      });
    });

    group('neutral getters and unimplemented methods', () {
      test('returns neutral zoom and exposure defaults', () async {
        final plugin = CameraLinuxV4l2(api: MockCameraApi());
        expect(await plugin.getMinExposureOffset(1), 0.0);
        expect(await plugin.getMaxExposureOffset(1), 0.0);
        expect(await plugin.getExposureOffsetStepSize(1), 1.0);
        expect(await plugin.getMinZoomLevel(1), 1.0);
        expect(await plugin.getMaxZoomLevel(1), 1.0);
      });

      test('unimplemented methods throw UnimplementedError', () async {
        final plugin = CameraLinuxV4l2(api: MockCameraApi());
        expect(() => plugin.takePicture(1), throwsUnimplementedError);
        expect(() => plugin.prepareForVideoRecording(), throwsUnimplementedError);
        expect(() => plugin.startVideoRecording(1), throwsUnimplementedError);
        expect(
          () => plugin.startVideoCapturing(const VideoCaptureOptions(1)),
          throwsUnimplementedError,
        );
        expect(() => plugin.stopVideoRecording(1), throwsUnimplementedError);
        expect(() => plugin.pauseVideoRecording(1), throwsUnimplementedError);
        expect(() => plugin.resumeVideoRecording(1), throwsUnimplementedError);
        expect(() => plugin.pausePreview(1), throwsUnimplementedError);
        expect(() => plugin.resumePreview(1), throwsUnimplementedError);
        expect(
          () => plugin.lockCaptureOrientation(1, DeviceOrientation.portraitUp),
          throwsUnimplementedError,
        );
        expect(() => plugin.unlockCaptureOrientation(1), throwsUnimplementedError);
        expect(() => plugin.setFlashMode(1, FlashMode.off), throwsUnimplementedError);
        expect(() => plugin.setExposureMode(1, ExposureMode.auto), throwsUnimplementedError);
        expect(
          () => plugin.setExposurePoint(1, const Point<double>(0.5, 0.5)),
          throwsUnimplementedError,
        );
        expect(() => plugin.setExposureOffset(1, 0.5), throwsUnimplementedError);
        expect(() => plugin.setFocusMode(1, FocusMode.auto), throwsUnimplementedError);
        expect(
          () => plugin.setFocusPoint(1, const Point<double>(0.5, 0.5)),
          throwsUnimplementedError,
        );
        expect(() => plugin.setZoomLevel(1, 1.5), throwsUnimplementedError);
        expect(
          () => plugin.setDescriptionWhileRecording(
            const CameraDescription(
              name: '/dev/video0',
              lensDirection: CameraLensDirection.external,
              sensorOrientation: 0,
            ),
          ),
          throwsUnimplementedError,
        );
        expect(() => plugin.setImageFileFormat(1, ImageFileFormat.jpeg), throwsUnimplementedError);
        expect(() => plugin.setZeroShutterLagEnabled(1, true), throwsUnimplementedError);
        expect(
          () => plugin.setVideoStabilizationMode(1, VideoStabilizationMode.off),
          throwsUnimplementedError,
        );
        expect(() => plugin.onVideoRecordedEvent(1), throwsUnimplementedError);
      });
    });
  });
}
