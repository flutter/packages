// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:async/async.dart';
import 'package:camera_avfoundation/src/avfoundation_camera.dart';
import 'package:camera_avfoundation/src/messages.g.dart';
import 'package:camera_avfoundation/src/utils.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'avfoundation_camera_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[MockSpec<CameraApi>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('registers instance', () async {
    AVFoundationCamera.registerWith();
    expect(CameraPlatform.instance, isA<AVFoundationCamera>());
  });

  group('Creation, Initialization & Disposal Tests', () {
    test('Should send creation data and receive back a camera id', () async {
      // Arrange
      final MockCameraApi mockApi = MockCameraApi();
      when(mockApi.create(any, any)).thenAnswer((_) async => 1);
      final AVFoundationCamera camera = AVFoundationCamera(api: mockApi);
      const String cameraName = 'Test';

      // Act
      final int cameraId = await camera.createCamera(
        const CameraDescription(
            name: cameraName,
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0),
        ResolutionPreset.high,
      );

      // Assert
      final VerificationResult verification =
          verify(mockApi.create(captureAny, captureAny));
      expect(verification.captured[0], cameraName);
      final PlatformMediaSettings? settings =
          verification.captured[1] as PlatformMediaSettings?;
      expect(settings, isNotNull);
      expect(settings?.resolutionPreset, PlatformResolutionPreset.high);
      expect(cameraId, 1);
    });

    test(
        'Should send creation data and receive back a camera id using createCameraWithSettings',
        () async {
      // Arrange
      final MockCameraApi mockApi = MockCameraApi();
      when(mockApi.create(any, any)).thenAnswer((_) async => 1);
      final AVFoundationCamera camera = AVFoundationCamera(api: mockApi);
      const String cameraName = 'Test';
      const int fps = 15;
      const int videoBitrate = 200000;
      const int audioBitrate = 32000;

      // Act
      final int cameraId = await camera.createCameraWithSettings(
        const CameraDescription(
            name: cameraName,
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0),
        const MediaSettings(
          resolutionPreset: ResolutionPreset.low,
          fps: fps,
          videoBitrate: videoBitrate,
          audioBitrate: audioBitrate,
          enableAudio: true,
        ),
      );

      // Assert
      final VerificationResult verification =
          verify(mockApi.create(captureAny, captureAny));
      expect(verification.captured[0], cameraName);
      final PlatformMediaSettings? settings =
          verification.captured[1] as PlatformMediaSettings?;
      expect(settings, isNotNull);
      expect(settings?.resolutionPreset, PlatformResolutionPreset.low);
      expect(settings?.framesPerSecond, fps);
      expect(settings?.videoBitrate, videoBitrate);
      expect(settings?.audioBitrate, audioBitrate);
      expect(settings?.enableAudio, true);
      expect(cameraId, 1);
    });

    test('Should throw CameraException when create throws a PlatformException',
        () {
      // Arrange
      const String exceptionCode = 'TESTING_ERROR_CODE';
      const String exceptionMessage = 'Mock error message used during testing.';
      final MockCameraApi mockApi = MockCameraApi();
      when(mockApi.create(any, any)).thenAnswer((_) async {
        throw PlatformException(code: exceptionCode, message: exceptionMessage);
      });
      final AVFoundationCamera camera = AVFoundationCamera(api: mockApi);

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
              .having((CameraException e) => e.code, 'code', exceptionCode)
              .having((CameraException e) => e.description, 'description',
                  exceptionMessage),
        ),
      );
    });

    test(
      'Should throw CameraException when initialize throws a PlatformException',
      () {
        // Arrange
        const String exceptionCode = 'TESTING_ERROR_CODE';
        const String exceptionMessage =
            'Mock error message used during testing.';
        final MockCameraApi mockApi = MockCameraApi();
        when(mockApi.initialize(any, any)).thenAnswer((_) async {
          throw PlatformException(
              code: exceptionCode, message: exceptionMessage);
        });
        final AVFoundationCamera camera = AVFoundationCamera(api: mockApi);

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
      final MockCameraApi mockApi = MockCameraApi();
      final AVFoundationCamera camera = AVFoundationCamera(api: mockApi);
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
      final VerificationResult verification =
          verify(mockApi.initialize(captureAny, captureAny));
      expect(verification.captured[0], cameraId);
      // The default when unspecified should be bgra8888.
      expect(verification.captured[1], PlatformImageFormatGroup.bgra8888);
    });

    test('Should send a disposal call on dispose', () async {
      // Arrange
      final MockCameraApi mockApi = MockCameraApi();
      final AVFoundationCamera camera = AVFoundationCamera(api: mockApi);
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
      final VerificationResult verification =
          verify(mockApi.dispose(captureAny));
      expect(verification.captured[0], cameraId);
    });
  });

  group('Event Tests', () {
    late AVFoundationCamera camera;
    late int cameraId;
    setUp(() async {
      final MockCameraApi mockApi = MockCameraApi();
      when(mockApi.create(any, any)).thenAnswer((_) async => 1);
      camera = AVFoundationCamera(api: mockApi);
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

      final PlatformSize previewSize = PlatformSize(width: 3840, height: 2160);
      // Emit test events
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
        focusPointSupported: true,
      ));

      // Assert
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
      const String errorMessage = 'Error Description';
      final CameraErrorEvent event = CameraErrorEvent(cameraId, errorMessage);
      camera.hostCameraHandlers[cameraId]!.error(errorMessage);
      camera.hostCameraHandlers[cameraId]!.error(errorMessage);
      camera.hostCameraHandlers[cameraId]!.error(errorMessage);

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
    late MockCameraApi mockApi;
    late AVFoundationCamera camera;
    late int cameraId;

    setUp(() async {
      mockApi = MockCameraApi();
      when(mockApi.create(any, any)).thenAnswer((_) async => 1);
      camera = AVFoundationCamera(api: mockApi);
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
      final List<PlatformCameraDescription> returnData =
          <PlatformCameraDescription>[
        PlatformCameraDescription(
            name: 'Test 1', lensDirection: PlatformCameraLensDirection.front),
        PlatformCameraDescription(
            name: 'Test 2', lensDirection: PlatformCameraLensDirection.back),
      ];
      when(mockApi.getAvailableCameras()).thenAnswer((_) async => returnData);

      final List<CameraDescription> cameras = await camera.availableCameras();

      expect(cameras.length, returnData.length);
      for (int i = 0; i < returnData.length; i++) {
        expect(cameras[i].name, returnData[i].name);
        expect(cameras[i].lensDirection,
            cameraLensDirectionFromPlatform(returnData[i].lensDirection));
        // This value isn't provided by the platform, so is hard-coded to 90.
        expect(cameras[i].sensorOrientation, 90);
      }
    });

    test(
        'Should throw CameraException when availableCameras throws a PlatformException',
        () {
      const String code = 'TESTING_ERROR_CODE';
      const String message = 'Mock error message used during testing.';
      when(mockApi.getAvailableCameras()).thenAnswer(
          (_) async => throw PlatformException(code: code, message: message));

      expect(
        camera.availableCameras,
        throwsA(
          isA<CameraException>()
              .having((CameraException e) => e.code, 'code', code)
              .having(
                  (CameraException e) => e.description, 'description', message),
        ),
      );
    });

    test('Should take a picture and return an XFile instance', () async {
      const String stubPath = '/test/path.jpg';
      when(mockApi.takePicture()).thenAnswer((_) async => stubPath);

      final XFile file = await camera.takePicture(cameraId);

      expect(file.path, stubPath);
    });

    test('Should prepare for video recording', () async {
      await camera.prepareForVideoRecording();

      verify(mockApi.prepareForVideoRecording());
    });

    test('Should start recording a video', () async {
      await camera.startVideoRecording(cameraId);

      verify(mockApi.startVideoRecording(any));
    });

    test(
        'Should pass enableStream if callback is passed when starting recording a video',
        () async {
      await camera.startVideoCapturing(VideoCaptureOptions(cameraId,
          streamCallback: (CameraImageData imageData) {}));

      verify(mockApi.startVideoRecording(true));
    });

    test('Should stop a video recording and return the file', () async {
      const String stubPath = '/test/path.mp4';
      when(mockApi.stopVideoRecording()).thenAnswer((_) async => stubPath);

      final XFile file = await camera.stopVideoRecording(cameraId);

      expect(file.path, stubPath);
    });

    test('Should pause a video recording', () async {
      await camera.pauseVideoRecording(cameraId);

      verify(mockApi.pauseVideoRecording());
    });

    test('Should resume a video recording', () async {
      await camera.resumeVideoRecording(cameraId);

      verify(mockApi.resumeVideoRecording());
    });

    test('Should set the description while recording', () async {
      const CameraDescription camera2Description = CameraDescription(
          name: 'Test2',
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 0);

      await camera.setDescriptionWhileRecording(camera2Description);

      verify(mockApi.updateDescriptionWhileRecording(camera2Description.name));
    });

    test('Should set the flash mode to torch', () async {
      await camera.setFlashMode(cameraId, FlashMode.torch);

      verify(mockApi.setFlashMode(PlatformFlashMode.torch));
    });

    test('Should set the flash mode to always', () async {
      await camera.setFlashMode(cameraId, FlashMode.always);

      verify(mockApi.setFlashMode(PlatformFlashMode.always));
    });

    test('Should set the flash mode to auto', () async {
      await camera.setFlashMode(cameraId, FlashMode.auto);

      verify(mockApi.setFlashMode(PlatformFlashMode.auto));
    });

    test('Should set the flash mode to off', () async {
      await camera.setFlashMode(cameraId, FlashMode.off);

      verify(mockApi.setFlashMode(PlatformFlashMode.off));
    });

    test('Should set the exposure mode to auto', () async {
      await camera.setExposureMode(cameraId, ExposureMode.auto);

      verify(mockApi.setExposureMode(PlatformExposureMode.auto));
    });

    test('Should set the exposure mode to locked', () async {
      await camera.setExposureMode(cameraId, ExposureMode.locked);

      verify(mockApi.setExposureMode(PlatformExposureMode.locked));
    });

    test('Should set the exposure point to a value', () async {
      const Point<double> point = Point<double>(0.4, 0.6);
      await camera.setExposurePoint(cameraId, point);

      final VerificationResult verification =
          verify(mockApi.setExposurePoint(captureAny));
      final PlatformPoint? passedPoint =
          verification.captured[0] as PlatformPoint?;
      expect(passedPoint?.x, point.x);
      expect(passedPoint?.y, point.y);
    });

    test('Should set the exposure point to null for reset', () async {
      await camera.setExposurePoint(cameraId, null);

      final VerificationResult verification =
          verify(mockApi.setExposurePoint(captureAny));
      final PlatformPoint? passedPoint =
          verification.captured[0] as PlatformPoint?;
      expect(passedPoint, null);
    });

    test('Should get the min exposure offset', () async {
      const double stubMinOffset = 2.0;
      when(mockApi.getMinExposureOffset())
          .thenAnswer((_) async => stubMinOffset);

      final double minExposureOffset =
          await camera.getMinExposureOffset(cameraId);

      expect(minExposureOffset, stubMinOffset);
    });

    test('Should get the max exposure offset', () async {
      const double stubMaxOffset = 2.0;
      when(mockApi.getMaxExposureOffset())
          .thenAnswer((_) async => stubMaxOffset);

      final double maxExposureOffset =
          await camera.getMaxExposureOffset(cameraId);

      expect(maxExposureOffset, stubMaxOffset);
    });

    test('Exposure offset step size should always return zero', () async {
      final double stepSize = await camera.getExposureOffsetStepSize(cameraId);

      expect(stepSize, 0.0);
    });

    test('Should set the exposure offset', () async {
      const double stubOffset = 0.5;
      final double actualOffset = await camera.setExposureOffset(cameraId, 0.5);

      verify(mockApi.setExposureOffset(stubOffset));
      // iOS never adjusts the offset.
      expect(actualOffset, stubOffset);
    });

    test('Should set the focus mode to auto', () async {
      await camera.setFocusMode(cameraId, FocusMode.auto);

      verify(mockApi.setFocusMode(PlatformFocusMode.auto));
    });

    test('Should set the focus mode to locked', () async {
      await camera.setFocusMode(cameraId, FocusMode.locked);

      verify(mockApi.setFocusMode(PlatformFocusMode.locked));
    });

    test('Should set the focus point to a value', () async {
      const Point<double> point = Point<double>(0.4, 0.6);
      await camera.setFocusPoint(cameraId, point);

      final VerificationResult verification =
          verify(mockApi.setFocusPoint(captureAny));
      final PlatformPoint? passedPoint =
          verification.captured[0] as PlatformPoint?;
      expect(passedPoint?.x, point.x);
      expect(passedPoint?.y, point.y);
    });

    test('Should set the focus point to null for reset', () async {
      await camera.setFocusPoint(cameraId, null);

      final VerificationResult verification =
          verify(mockApi.setFocusPoint(captureAny));
      final PlatformPoint? passedPoint =
          verification.captured[0] as PlatformPoint?;
      expect(passedPoint, null);
    });

    test('Should build a texture widget as preview widget', () async {
      final Widget widget = camera.buildPreview(cameraId);

      expect(widget is Texture, isTrue);
      expect((widget as Texture).textureId, cameraId);
    });

    test('Should get the max zoom level', () async {
      const double stubZoomLevel = 10.0;
      when(mockApi.getMaxZoomLevel()).thenAnswer((_) async => stubZoomLevel);

      final double maxZoomLevel = await camera.getMaxZoomLevel(cameraId);

      expect(maxZoomLevel, stubZoomLevel);
    });

    test('Should get the min zoom level', () async {
      const double stubZoomLevel = 10.0;
      when(mockApi.getMinZoomLevel()).thenAnswer((_) async => stubZoomLevel);

      final double minZoomLevel = await camera.getMinZoomLevel(cameraId);

      expect(minZoomLevel, stubZoomLevel);
    });

    test('Should set the zoom level', () async {
      const double zoom = 2.0;

      await camera.setZoomLevel(cameraId, zoom);

      verify(mockApi.setZoomLevel(zoom));
    });

    test('Should throw CameraException when illegal zoom level is supplied',
        () async {
      const String code = 'ZOOM_ERROR';
      const String message = 'Illegal zoom error';
      when(mockApi.setZoomLevel(any)).thenAnswer(
          (_) async => throw PlatformException(code: code, message: message));

      expect(
          () => camera.setZoomLevel(cameraId, -1.0),
          throwsA(isA<CameraException>()
              .having((CameraException e) => e.code, 'code', code)
              .having((CameraException e) => e.description, 'description',
                  message)));
    });

    test('Should lock the capture orientation', () async {
      await camera.lockCaptureOrientation(
          cameraId, DeviceOrientation.portraitUp);

      verify(
          mockApi.lockCaptureOrientation(PlatformDeviceOrientation.portraitUp));
    });

    test('Should unlock the capture orientation', () async {
      await camera.unlockCaptureOrientation(cameraId);

      verify(mockApi.unlockCaptureOrientation());
    });

    test('Should pause the camera preview', () async {
      await camera.pausePreview(cameraId);

      verify(mockApi.pausePreview());
    });

    test('Should resume the camera preview', () async {
      await camera.resumePreview(cameraId);

      verify(mockApi.resumePreview());
    });

    test('Should report support for image streaming', () async {
      expect(camera.supportsImageStreaming(), true);
    });

    test('Should start streaming', () async {
      final StreamSubscription<CameraImageData> subscription = camera
          .onStreamedFrameAvailable(cameraId)
          .listen((CameraImageData imageData) {});

      verify(mockApi.startImageStream());

      await subscription.cancel();
    });

    test('Should stop streaming', () async {
      final StreamSubscription<CameraImageData> subscription = camera
          .onStreamedFrameAvailable(cameraId)
          .listen((CameraImageData imageData) {});
      await subscription.cancel();

      verify(mockApi.startImageStream());
      verify(mockApi.stopImageStream());
    });

    test('Should set the ImageFileFormat to heif', () async {
      await camera.setImageFileFormat(cameraId, ImageFileFormat.heif);

      verify(mockApi.setImageFileFormat(PlatformImageFileFormat.heif));
    });

    test('Should set the ImageFileFormat to jpeg', () async {
      await camera.setImageFileFormat(cameraId, ImageFileFormat.jpeg);

      verify(mockApi.setImageFileFormat(PlatformImageFileFormat.jpeg));
    });
  });
}
