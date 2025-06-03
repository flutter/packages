// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:async/async.dart';
import 'package:camera_android/src/android_camera.dart';
import 'package:camera_android/src/messages.g.dart';
import 'package:camera_android/src/utils.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'android_camera_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<dynamic>>[MockSpec<CameraApi>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('registers instance', () async {
    AndroidCamera.registerWith();
    expect(CameraPlatform.instance, isA<AndroidCamera>());
  });

  test('registration does not set message handlers', () async {
    AndroidCamera.registerWith();

    // Setting up a handler requires bindings to be initialized, and since
    // registerWith is called very early in initialization the bindings won't
    // have been initialized. While registerWith could initialize them, that
    // could slow down startup, so instead the handler should be set up lazily.
    final ByteData? response = await TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .handlePlatformMessage(
            AndroidCamera.deviceEventChannelName,
            const StandardMethodCodec().encodeMethodCall(const MethodCall(
                'orientation_changed',
                <String, Object>{'orientation': 'portraitDown'})),
            (ByteData? data) {});
    expect(response, null);
  });

  group('Creation, Initialization & Disposal Tests', () {
    late MockCameraApi mockCameraApi;
    setUp(() {
      mockCameraApi = MockCameraApi();
    });

    test('Should send creation data and receive back a camera id', () async {
      // Arrange
      final AndroidCamera camera = AndroidCamera(hostApi: mockCameraApi);
      when(mockCameraApi.create(
          'Test',
          argThat(predicate((PlatformMediaSettings settings) =>
              settings.resolutionPreset == PlatformResolutionPreset.high &&
              !settings.enableAudio)))).thenAnswer((_) async => 1);

      // Act
      final int cameraId = await camera.createCamera(
        const CameraDescription(
            name: 'Test',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0),
        ResolutionPreset.high,
      );

      // Assert
      expect(cameraId, 1);
    });

    test(
        'Should send creation data and receive back a camera id using createCameraWithSettings',
        () async {
      // Arrange
      final AndroidCamera camera = AndroidCamera(hostApi: mockCameraApi);
      when(mockCameraApi.create(
          'Test',
          argThat(predicate((PlatformMediaSettings settings) =>
              settings.resolutionPreset == PlatformResolutionPreset.low &&
              !settings.enableAudio &&
              settings.fps == 15 &&
              settings.videoBitrate == 200000 &&
              settings.audioBitrate == 32000)))).thenAnswer((_) async => 1);

      // Act
      final int cameraId = await camera.createCameraWithSettings(
        const CameraDescription(
            name: 'Test',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0),
        const MediaSettings(
          resolutionPreset: ResolutionPreset.low,
          fps: 15,
          videoBitrate: 200000,
          audioBitrate: 32000,
        ),
      );

      // Assert
      expect(cameraId, 1);
    });

    test('Should throw CameraException when create throws a PlatformException',
        () {
      // Arrange
      final AndroidCamera camera = AndroidCamera(hostApi: mockCameraApi);
      when(mockCameraApi.create(
          'Test',
          argThat(predicate((PlatformMediaSettings settings) =>
              settings.resolutionPreset == PlatformResolutionPreset.high &&
              !settings.enableAudio)))).thenThrow(CameraException(
          'TESTING_ERROR_CODE', 'Mock error message used during testing.'));

      // Act
      expect(
        () => camera.createCamera(
          const CameraDescription(
            name: 'Test',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          ),
          ResolutionPreset.high,
        ),
        throwsA(
          isA<CameraException>()
              .having(
                  (CameraException e) => e.code, 'code', 'TESTING_ERROR_CODE')
              .having((CameraException e) => e.description, 'description',
                  'Mock error message used during testing.'),
        ),
      );
    });

    test(
      'Should throw CameraException when initialize throws a PlatformException',
      () {
        // Arrange
        final AndroidCamera camera = AndroidCamera(hostApi: mockCameraApi);
        when(mockCameraApi.initialize(PlatformImageFormatGroup.yuv420))
            .thenThrow(CameraException('TESTING_ERROR_CODE',
                'Mock error message used during testing.'));

        // Act
        expect(
          () => camera.initializeCamera(0),
          throwsA(
            isA<CameraException>()
                .having(
                    (CameraException e) => e.code, 'code', 'TESTING_ERROR_CODE')
                .having(
                  (CameraException e) => e.description,
                  'description',
                  'Mock error message used during testing.',
                ),
          ),
        );
      },
    );

    test('Should send initialization data', () async {
      // Arrange
      final AndroidCamera camera = AndroidCamera(hostApi: mockCameraApi);
      when(mockCameraApi.create(
          'Test',
          argThat(predicate((PlatformMediaSettings settings) =>
              settings.resolutionPreset == PlatformResolutionPreset.high &&
              !settings.enableAudio)))).thenAnswer((_) async => 1);

      final int cameraId = await camera.createCamera(
        const CameraDescription(
          name: 'Test',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 0,
        ),
        ResolutionPreset.high,
      );

      // Act
      final Future<void> initializeFuture = camera.initializeCamera(cameraId);
      camera.cameraEventStreamController.add(CameraInitializedEvent(
        cameraId,
        1920,
        1080,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        true,
      ));
      await initializeFuture;

      // Assert
      expect(cameraId, 1);
      verify(mockCameraApi.initialize(PlatformImageFormatGroup.yuv420))
          .called(1);
    });

    test('Should send a disposal call on dispose', () async {
      // Arrange
      final AndroidCamera camera = AndroidCamera(hostApi: mockCameraApi);
      when(mockCameraApi.create(
          'Test',
          argThat(predicate((PlatformMediaSettings settings) =>
              settings.resolutionPreset == PlatformResolutionPreset.high &&
              !settings.enableAudio)))).thenAnswer((_) async => 1);
      final int cameraId = await camera.createCamera(
        const CameraDescription(
          name: 'Test',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 0,
        ),
        ResolutionPreset.high,
      );
      final Future<void> initializeFuture = camera.initializeCamera(cameraId);
      camera.cameraEventStreamController.add(CameraInitializedEvent(
        cameraId,
        1920,
        1080,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        true,
      ));
      await initializeFuture;

      // Act
      await camera.dispose(cameraId);

      // Assert
      expect(cameraId, 1);
      verify(mockCameraApi.dispose()).called(1);
    });
  });

  group('Event Tests', () {
    late AndroidCamera camera;
    late int cameraId;
    late MockCameraApi mockCameraApi;
    setUp(() async {
      mockCameraApi = MockCameraApi();
      camera = AndroidCamera(hostApi: mockCameraApi);
      cameraId = await camera.createCamera(
        const CameraDescription(
          name: 'Test',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 0,
        ),
        ResolutionPreset.high,
      );
      final Future<void> initializeFuture = camera.initializeCamera(cameraId);
      camera.cameraEventStreamController.add(CameraInitializedEvent(
        cameraId,
        1920,
        1080,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        true,
      ));
      await initializeFuture;
    });

    test('Should receive initialized event', () async {
      // Act
      final Stream<CameraInitializedEvent> eventStream =
          camera.onCameraInitialized(cameraId);
      final StreamQueue<CameraInitializedEvent> streamQueue =
          StreamQueue<CameraInitializedEvent>(eventStream);

      // Emit test events
      final PlatformSize previewSize = PlatformSize(width: 3840, height: 2160);
      final CameraInitializedEvent event = CameraInitializedEvent(
        cameraId,
        previewSize.width,
        previewSize.height,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        true,
      );
      camera.hostCameraHandlers[cameraId]!.initialized(PlatformCameraState(
          previewSize: previewSize,
          exposureMode: PlatformExposureMode.auto,
          focusMode: PlatformFocusMode.auto,
          exposurePointSupported: true,
          focusPointSupported: true));

      // Assert
      expect(await streamQueue.next, event);

      // Clean up
      await streamQueue.cancel();
    });

    test('Should receive camera closing events', () async {
      // Act
      final Stream<CameraClosingEvent> eventStream =
          camera.onCameraClosing(cameraId);
      final StreamQueue<CameraClosingEvent> streamQueue =
          StreamQueue<CameraClosingEvent>(eventStream);

      // Emit test events
      final CameraClosingEvent event = CameraClosingEvent(cameraId);
      for (int i = 0; i < 3; i++) {
        camera.hostCameraHandlers[cameraId]!.closed();
      }

      // Assert
      expect(await streamQueue.next, event);
      expect(await streamQueue.next, event);
      expect(await streamQueue.next, event);

      // Clean up
      await streamQueue.cancel();
    });

    test('Should receive camera error events', () async {
      // Act
      final Stream<CameraErrorEvent> errorStream =
          camera.onCameraError(cameraId);
      final StreamQueue<CameraErrorEvent> streamQueue =
          StreamQueue<CameraErrorEvent>(errorStream);

      // Emit test events
      final CameraErrorEvent event =
          CameraErrorEvent(cameraId, 'Error Description');
      for (int i = 0; i < 3; i++) {
        camera.hostCameraHandlers[cameraId]!.error('Error Description');
      }

      // Assert
      expect(await streamQueue.next, event);
      expect(await streamQueue.next, event);
      expect(await streamQueue.next, event);

      // Clean up
      await streamQueue.cancel();
    });

    test('Should receive device orientation change events', () async {
      // Act
      final Stream<DeviceOrientationChangedEvent> eventStream =
          camera.onDeviceOrientationChanged();
      final StreamQueue<DeviceOrientationChangedEvent> streamQueue =
          StreamQueue<DeviceOrientationChangedEvent>(eventStream);

      // Emit test events
      const DeviceOrientationChangedEvent event =
          DeviceOrientationChangedEvent(DeviceOrientation.portraitUp);
      for (int i = 0; i < 3; i++) {
        camera.hostHandler
            .deviceOrientationChanged(PlatformDeviceOrientation.portraitUp);
      }

      // Assert
      expect(await streamQueue.next, event);
      expect(await streamQueue.next, event);
      expect(await streamQueue.next, event);

      // Clean up
      await streamQueue.cancel();
    });
  });

  group('Function Tests', () {
    late AndroidCamera camera;
    late int cameraId;
    late MockCameraApi mockCameraApi;

    setUp(() async {
      mockCameraApi = MockCameraApi();
      camera = AndroidCamera(hostApi: mockCameraApi);
      cameraId = await camera.createCamera(
        const CameraDescription(
          name: 'Test',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 0,
        ),
        ResolutionPreset.high,
      );
      final Future<void> initializeFuture = camera.initializeCamera(cameraId);
      camera.cameraEventStreamController.add(
        CameraInitializedEvent(
          cameraId,
          1920,
          1080,
          ExposureMode.auto,
          true,
          FocusMode.auto,
          true,
        ),
      );
      await initializeFuture;
    });

    test('Should fetch CameraDescription instances for available cameras',
        () async {
      // Arrange
      final List<PlatformCameraDescription> returnData =
          <PlatformCameraDescription>[
        PlatformCameraDescription(
            name: 'Test 1',
            lensDirection: PlatformCameraLensDirection.front,
            sensorOrientation: 1),
        PlatformCameraDescription(
            name: 'Test 2',
            lensDirection: PlatformCameraLensDirection.back,
            sensorOrientation: 2),
      ];
      when(mockCameraApi.getAvailableCameras())
          .thenAnswer((_) async => returnData);

      // Act
      final List<CameraDescription> cameras = await camera.availableCameras();

      // Assert
      expect(cameras.length, returnData.length);
      for (int i = 0; i < returnData.length; i++) {
        final PlatformCameraDescription platformCameraDescription =
            returnData[i];
        final CameraDescription cameraDescription = CameraDescription(
            name: platformCameraDescription.name,
            lensDirection: cameraLensDirectionFromPlatform(
                platformCameraDescription.lensDirection),
            sensorOrientation: platformCameraDescription.sensorOrientation);
        expect(cameras[i], cameraDescription);
      }
    });

    test(
        'Should throw CameraException when availableCameras throws a PlatformException',
        () {
      // Arrange
      when(mockCameraApi.getAvailableCameras()).thenThrow(PlatformException(
          code: 'TESTING_ERROR_CODE',
          message: 'Mock error message used during testing.'));

      // Act
      expect(
        camera.availableCameras,
        throwsA(
          isA<CameraException>()
              .having(
                  (CameraException e) => e.code, 'code', 'TESTING_ERROR_CODE')
              .having((CameraException e) => e.description, 'description',
                  'Mock error message used during testing.'),
        ),
      );
    });

    test('Should take a picture and return an XFile instance', () async {
      // Arrange
      when(mockCameraApi.takePicture())
          .thenAnswer((_) async => '/test/path.jpg');

      // Act
      final XFile file = await camera.takePicture(cameraId);

      // Assert
      expect(file.path, '/test/path.jpg');
    });

    test('Should start recording a video', () async {
      // Arrange
      // Act
      await camera.startVideoRecording(cameraId);

      // Assert
      verify(mockCameraApi.startVideoRecording(false)).called(1);
    });

    test(
        'Should pass enableStream if callback is passed when starting recording a video',
        () async {
      // Arrange
      // Act
      await camera.startVideoCapturing(
        VideoCaptureOptions(cameraId,
            streamCallback: (CameraImageData imageData) {}),
      );

      // Assert
      verify(mockCameraApi.startVideoRecording(true)).called(1);
    });

    test('Should stop a video recording and return the file', () async {
      // Arrange
      when(mockCameraApi.stopVideoRecording())
          .thenAnswer((_) async => '/test/path.mp4');

      // Act
      final XFile file = await camera.stopVideoRecording(cameraId);

      // Assert
      expect(file.path, '/test/path.mp4');
    });

    test('Should pause a video recording', () async {
      // Arrange
      // Act
      await camera.pauseVideoRecording(cameraId);

      // Assert
      verify(mockCameraApi.pauseVideoRecording()).called(1);
    });

    test('Should resume a video recording', () async {
      // Arrange
      // Act
      await camera.resumeVideoRecording(cameraId);

      // Assert
      verify(mockCameraApi.resumeVideoRecording()).called(1);
    });

    test('Should set the description while recording', () async {
      // Arrange
      const CameraDescription camera2Description = CameraDescription(
          name: 'Test2',
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 0);

      // Act
      await camera.setDescriptionWhileRecording(camera2Description);

      // Assert
      verify(mockCameraApi
              .setDescriptionWhileRecording(camera2Description.name))
          .called(1);
    });

    test('Should set the flash mode', () async {
      // Arrange
      // Act
      await camera.setFlashMode(cameraId, FlashMode.torch);
      await camera.setFlashMode(cameraId, FlashMode.always);
      await camera.setFlashMode(cameraId, FlashMode.auto);
      await camera.setFlashMode(cameraId, FlashMode.off);

      // Assert
      verify(mockCameraApi.setFlashMode(PlatformFlashMode.torch)).called(1);
      verify(mockCameraApi.setFlashMode(PlatformFlashMode.always)).called(1);
      verify(mockCameraApi.setFlashMode(PlatformFlashMode.auto)).called(1);
      verify(mockCameraApi.setFlashMode(PlatformFlashMode.off)).called(1);
    });

    test('Should set the exposure mode', () async {
      // Arrange
      // Act
      await camera.setExposureMode(cameraId, ExposureMode.auto);
      await camera.setExposureMode(cameraId, ExposureMode.locked);

      // Assert
      verify(mockCameraApi.setExposureMode(PlatformExposureMode.auto))
          .called(1);
      verify(mockCameraApi.setExposureMode(PlatformExposureMode.locked))
          .called(1);
    });

    test('Should set the exposure point', () async {
      // Arrange
      // Act
      await camera.setExposurePoint(cameraId, const Point<double>(0.4, 0.5));
      await camera.setExposurePoint(cameraId, null);

      // Assert
      verify(mockCameraApi.setExposurePoint(argThat(predicate(
              (PlatformPoint point) => point.x == 0.4 && point.y == 0.5))))
          .called(1);
      verify(mockCameraApi.setExposurePoint(null)).called(1);
    });

    test('Should get the min exposure offset', () async {
      // Arrange
      when(mockCameraApi.getMinExposureOffset()).thenAnswer((_) async => 2.0);

      // Act
      final double minExposureOffset =
          await camera.getMinExposureOffset(cameraId);

      // Assert
      expect(minExposureOffset, 2.0);
    });

    test('Should get the max exposure offset', () async {
      // Arrange
      when(mockCameraApi.getMaxExposureOffset()).thenAnswer((_) async => 2.0);

      // Act
      final double maxExposureOffset =
          await camera.getMaxExposureOffset(cameraId);

      // Assert
      expect(maxExposureOffset, 2.0);
    });

    test('Should get the exposure offset step size', () async {
      // Arrange
      when(mockCameraApi.getExposureOffsetStepSize())
          .thenAnswer((_) async => 0.25);

      // Act
      final double stepSize = await camera.getExposureOffsetStepSize(cameraId);

      // Assert
      expect(stepSize, 0.25);
    });

    test('Should set the exposure offset', () async {
      // Arrange
      when(mockCameraApi.setExposureOffset(0.5)).thenAnswer((_) async => 0.6);

      // Act
      final double actualOffset = await camera.setExposureOffset(cameraId, 0.5);

      // Assert
      expect(actualOffset, 0.6);
    });

    test('Should set the focus mode', () async {
      // Arrange
      // Act
      await camera.setFocusMode(cameraId, FocusMode.auto);
      await camera.setFocusMode(cameraId, FocusMode.locked);

      // Assert
      verify(mockCameraApi.setFocusMode(PlatformFocusMode.auto)).called(1);
      verify(mockCameraApi.setFocusMode(PlatformFocusMode.locked)).called(1);
    });

    test('Should build a texture widget as preview widget', () async {
      // Act
      final Widget widget = camera.buildPreview(cameraId);

      // Act
      expect(widget is Texture, isTrue);
      expect((widget as Texture).textureId, cameraId);
    });

    test('Should get the max zoom level', () async {
      // Arrange
      when(mockCameraApi.getMaxZoomLevel()).thenAnswer((_) async => 10.0);

      // Act
      final double maxZoomLevel = await camera.getMaxZoomLevel(cameraId);

      // Assert
      expect(maxZoomLevel, 10.0);
    });

    test('Should get the min zoom level', () async {
      // Arrange
      when(mockCameraApi.getMinZoomLevel()).thenAnswer((_) async => 1.0);

      // Act
      final double maxZoomLevel = await camera.getMinZoomLevel(cameraId);

      // Assert
      expect(maxZoomLevel, 1.0);
    });

    test('Should set the zoom level', () async {
      // Arrange
      // Act
      await camera.setZoomLevel(cameraId, 2.0);

      // Assert
      verify(mockCameraApi.setZoomLevel(2.0)).called(1);
    });

    test('Should throw CameraException when illegal zoom level is supplied',
        () async {
      // Arrange
      when(mockCameraApi.setZoomLevel(-1.0)).thenThrow(
          PlatformException(code: 'ZOOM_ERROR', message: 'Illegal zoom error'));

      // Act & assert
      expect(
          () => camera.setZoomLevel(cameraId, -1.0),
          throwsA(isA<CameraException>()
              .having((CameraException e) => e.code, 'code', 'ZOOM_ERROR')
              .having((CameraException e) => e.description, 'description',
                  'Illegal zoom error')));
    });

    test('Should lock the capture orientation', () async {
      // Arrange
      // Act
      await camera.lockCaptureOrientation(
          cameraId, DeviceOrientation.portraitUp);

      // Assert
      verify(mockCameraApi
              .lockCaptureOrientation(PlatformDeviceOrientation.portraitUp))
          .called(1);
    });

    test('Should unlock the capture orientation', () async {
      // Arrange
      // Act
      await camera.unlockCaptureOrientation(cameraId);

      // Assert
      verify(mockCameraApi.unlockCaptureOrientation()).called(1);
    });

    test('Should pause the camera preview', () async {
      // Arrange
      // Act
      await camera.pausePreview(cameraId);

      // Assert
      verify(mockCameraApi.pausePreview()).called(1);
    });

    test('Should resume the camera preview', () async {
      // Arrange
      // Act
      await camera.resumePreview(cameraId);

      // Assert
      verify(mockCameraApi.resumePreview()).called(1);
    });

    test('Should report support for image streaming', () async {
      expect(camera.supportsImageStreaming(), true);
    });

    test('Should start streaming', () async {
      // Arrange
      // Act
      final StreamSubscription<CameraImageData> subscription = camera
          .onStreamedFrameAvailable(cameraId)
          .listen((CameraImageData imageData) {});

      // Assert
      verify(mockCameraApi.startImageStream()).called(1);

      await subscription.cancel();
    });

    test('Should stop streaming', () async {
      // Arrange
      // Act
      final StreamSubscription<CameraImageData> subscription = camera
          .onStreamedFrameAvailable(cameraId)
          .listen((CameraImageData imageData) {});
      await subscription.cancel();

      // Assert
      verify(mockCameraApi.startImageStream()).called(1);
      verify(mockCameraApi.stopImageStream()).called(1);
    });
  });
}
