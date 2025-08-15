// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:async/async.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_windows/camera_windows.dart';
import 'package:camera_windows/src/messages.g.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'camera_windows_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[MockSpec<CameraApi>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$CameraWindows()', () {
    test('registered instance', () {
      CameraWindows.registerWith();
      expect(CameraPlatform.instance, isA<CameraWindows>());
    });

    group('Creation, Initialization & Disposal Tests', () {
      test('Should send creation data and receive back a camera id', () async {
        // Arrange
        final MockCameraApi mockApi = MockCameraApi();
        when(mockApi.create(any, any)).thenAnswer((_) async => 1);
        final CameraWindows plugin = CameraWindows(api: mockApi);
        const String cameraName = 'Test';

        // Act
        final int cameraId = await plugin.createCameraWithSettings(
          const CameraDescription(
              name: cameraName,
              lensDirection: CameraLensDirection.front,
              sensorOrientation: 0),
          const MediaSettings(
            resolutionPreset: ResolutionPreset.low,
            fps: 15,
            videoBitrate: 200000,
            audioBitrate: 32000,
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
        expect(cameraId, 1);
      });

      test(
          'Should throw CameraException when create throws a PlatformException',
          () {
        // Arrange
        const String exceptionCode = 'TESTING_ERROR_CODE';
        const String exceptionMessage =
            'Mock error message used during testing.';
        final MockCameraApi mockApi = MockCameraApi();
        when(mockApi.create(any, any)).thenAnswer((_) async {
          throw PlatformException(
              code: exceptionCode, message: exceptionMessage);
        });
        final CameraWindows camera = CameraWindows(api: mockApi);

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
          when(mockApi.initialize(any)).thenAnswer((_) async {
            throw PlatformException(
                code: exceptionCode, message: exceptionMessage);
          });
          final CameraWindows plugin = CameraWindows(api: mockApi);

          // Act
          expect(
            () => plugin.initializeCamera(0),
            throwsA(
              isA<CameraException>()
                  .having((CameraException e) => e.code, 'code',
                      'TESTING_ERROR_CODE')
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
        when(mockApi.initialize(any))
            .thenAnswer((_) async => PlatformSize(width: 1920, height: 1080));
        final CameraWindows plugin = CameraWindows(api: mockApi);
        final int cameraId = await plugin.createCameraWithSettings(
          const CameraDescription(
            name: 'Test',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          ),
          const MediaSettings(
            resolutionPreset: ResolutionPreset.low,
            fps: 15,
            videoBitrate: 200000,
            audioBitrate: 32000,
            enableAudio: true,
          ),
        );

        // Act
        await plugin.initializeCamera(cameraId);

        // Assert
        final VerificationResult verification =
            verify(mockApi.initialize(captureAny));
        expect(verification.captured[0], cameraId);
      });

      test('Should send a disposal call on dispose', () async {
        // Arrange
        final MockCameraApi mockApi = MockCameraApi();
        when(mockApi.initialize(any))
            .thenAnswer((_) async => PlatformSize(width: 1920, height: 1080));
        final CameraWindows plugin = CameraWindows(api: mockApi);
        final int cameraId = await plugin.createCameraWithSettings(
          const CameraDescription(
            name: 'Test',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          ),
          const MediaSettings(
            resolutionPreset: ResolutionPreset.low,
            fps: 15,
            videoBitrate: 200000,
            audioBitrate: 32000,
            enableAudio: true,
          ),
        );
        await plugin.initializeCamera(cameraId);

        // Act
        await plugin.dispose(cameraId);

        // Assert
        final VerificationResult verification =
            verify(mockApi.dispose(captureAny));
        expect(verification.captured[0], cameraId);
      });
    });

    group('Event Tests', () {
      late CameraWindows plugin;
      late int cameraId;
      setUp(() async {
        final MockCameraApi mockApi = MockCameraApi();
        when(mockApi.create(any, any)).thenAnswer((_) async => 1);
        when(mockApi.initialize(any))
            .thenAnswer((_) async => PlatformSize(width: 1920, height: 1080));
        plugin = CameraWindows(api: mockApi);
        cameraId = await plugin.createCameraWithSettings(
          const CameraDescription(
            name: 'Test',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          ),
          const MediaSettings(
            resolutionPreset: ResolutionPreset.low,
            fps: 15,
            videoBitrate: 200000,
            audioBitrate: 32000,
            enableAudio: true,
          ),
        );
        await plugin.initializeCamera(cameraId);
      });

      test('Should receive camera closing events', () async {
        // Act
        final Stream<CameraClosingEvent> eventStream =
            plugin.onCameraClosing(cameraId);
        final StreamQueue<CameraClosingEvent> streamQueue =
            StreamQueue<CameraClosingEvent>(eventStream);

        // Emit test events
        final CameraClosingEvent event = CameraClosingEvent(cameraId);
        plugin.hostCameraHandlers[cameraId]!.cameraClosing();
        plugin.hostCameraHandlers[cameraId]!.cameraClosing();
        plugin.hostCameraHandlers[cameraId]!.cameraClosing();

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
            plugin.onCameraError(cameraId);
        final StreamQueue<CameraErrorEvent> streamQueue =
            StreamQueue<CameraErrorEvent>(errorStream);

        // Emit test events
        const String errorMessage = 'Error Description';
        final CameraErrorEvent event = CameraErrorEvent(cameraId, errorMessage);
        plugin.hostCameraHandlers[cameraId]!.error(errorMessage);
        plugin.hostCameraHandlers[cameraId]!.error(errorMessage);
        plugin.hostCameraHandlers[cameraId]!.error(errorMessage);

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
      late CameraWindows plugin;
      late int cameraId;

      setUp(() async {
        mockApi = MockCameraApi();
        when(mockApi.create(any, any)).thenAnswer((_) async => 1);
        when(mockApi.initialize(any))
            .thenAnswer((_) async => PlatformSize(width: 1920, height: 1080));
        plugin = CameraWindows(api: mockApi);
        cameraId = await plugin.createCameraWithSettings(
          const CameraDescription(
            name: 'Test',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          ),
          const MediaSettings(
            resolutionPreset: ResolutionPreset.low,
            fps: 15,
            videoBitrate: 200000,
            audioBitrate: 32000,
            enableAudio: true,
          ),
        );
        await plugin.initializeCamera(cameraId);
        clearInteractions(mockApi);
      });

      test('Should fetch CameraDescription instances for available cameras',
          () async {
        // Arrange
        final List<String> returnData = <String>[
          'Test 1',
          'Test 2',
        ];
        when(mockApi.getAvailableCameras()).thenAnswer((_) async => returnData);

        // Act
        final List<CameraDescription> cameras = await plugin.availableCameras();

        // Assert
        expect(cameras.length, returnData.length);
        for (int i = 0; i < returnData.length; i++) {
          expect(cameras[i].name, returnData[i]);
          // This value isn't provided by the platform, so is hard-coded to front.
          expect(cameras[i].lensDirection, CameraLensDirection.front);
          // This value isn't provided by the platform, so is hard-coded to 0.
          expect(cameras[i].sensorOrientation, 0);
        }
      });

      test(
          'Should throw CameraException when availableCameras throws a PlatformException',
          () {
        // Arrange
        const String code = 'TESTING_ERROR_CODE';
        const String message = 'Mock error message used during testing.';
        when(mockApi.getAvailableCameras()).thenAnswer(
            (_) async => throw PlatformException(code: code, message: message));

        // Act
        expect(
          plugin.availableCameras,
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
        const String stubPath = '/test/path.jpg';
        when(mockApi.takePicture(any)).thenAnswer((_) async => stubPath);

        // Act
        final XFile file = await plugin.takePicture(cameraId);

        // Assert
        expect(file.path, '/test/path.jpg');
      });

      test('prepare for video recording should no-op', () async {
        // Act
        await plugin.prepareForVideoRecording();

        // Assert
        verifyNoMoreInteractions(mockApi);
      });

      test('Should start recording a video', () async {
        // Act
        await plugin.startVideoRecording(cameraId);

        // Assert
        verify(mockApi.startVideoRecording(any));
      });

      test('capturing fails if trying to stream', () async {
        // Act and Assert
        expect(
          () => plugin.startVideoCapturing(VideoCaptureOptions(cameraId,
              streamCallback: (CameraImageData imageData) {})),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('Should stop a video recording and return the file', () async {
        // Arrange
        const String stubPath = '/test/path.mp4';
        when(mockApi.stopVideoRecording(any)).thenAnswer((_) async => stubPath);

        // Act
        final XFile file = await plugin.stopVideoRecording(cameraId);

        // Assert
        expect(file.path, '/test/path.mp4');
      });

      test('Should throw UnsupportedError when pause video recording is called',
          () async {
        // Act
        expect(
          () => plugin.pauseVideoRecording(cameraId),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test(
          'Should throw UnsupportedError when resume video recording is called',
          () async {
        // Act
        expect(
          () => plugin.resumeVideoRecording(cameraId),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('Should throw UnimplementedError when flash mode is set', () async {
        // Act
        expect(
          () => plugin.setFlashMode(cameraId, FlashMode.torch),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('Should throw UnimplementedError when exposure mode is set',
          () async {
        // Act
        expect(
          () => plugin.setExposureMode(cameraId, ExposureMode.auto),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('Should throw UnsupportedError when exposure point is set',
          () async {
        // Act
        expect(
          () => plugin.setExposurePoint(cameraId, null),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('Should get the min exposure offset', () async {
        // Act
        final double minExposureOffset =
            await plugin.getMinExposureOffset(cameraId);

        // Assert
        expect(minExposureOffset, 0.0);
      });

      test('Should get the max exposure offset', () async {
        // Act
        final double maxExposureOffset =
            await plugin.getMaxExposureOffset(cameraId);

        // Assert
        expect(maxExposureOffset, 0.0);
      });

      test('Should get the exposure offset step size', () async {
        // Act
        final double stepSize =
            await plugin.getExposureOffsetStepSize(cameraId);

        // Assert
        expect(stepSize, 1.0);
      });

      test('Should throw UnimplementedError when exposure offset is set',
          () async {
        // Act
        expect(
          () => plugin.setExposureOffset(cameraId, 0.5),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('Should throw UnimplementedError when focus mode is set', () async {
        // Act
        expect(
          () => plugin.setFocusMode(cameraId, FocusMode.auto),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('Should throw UnsupportedError when exposure point is set',
          () async {
        // Act
        expect(
          () => plugin.setFocusMode(cameraId, FocusMode.auto),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('Should build a texture widget as preview widget', () async {
        // Act
        final Widget widget = plugin.buildPreview(cameraId);

        // Act
        expect(widget is Texture, isTrue);
        expect((widget as Texture).textureId, cameraId);
      });

      test('Should get the max zoom level', () async {
        // Act
        final double maxZoomLevel = await plugin.getMaxZoomLevel(cameraId);

        // Assert
        expect(maxZoomLevel, 1.0);
      });

      test('Should get the min zoom level', () async {
        // Act
        final double maxZoomLevel = await plugin.getMinZoomLevel(cameraId);

        // Assert
        expect(maxZoomLevel, 1.0);
      });

      test('Should throw UnimplementedError when zoom level is set', () async {
        // Act
        expect(
          () => plugin.setZoomLevel(cameraId, 2.0),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test(
          'Should throw UnimplementedError when lock capture orientation is called',
          () async {
        // Act
        expect(
          () => plugin.setZoomLevel(cameraId, 2.0),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test(
          'Should throw UnimplementedError when unlock capture orientation is called',
          () async {
        // Act
        expect(
          () => plugin.unlockCaptureOrientation(cameraId),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('Should pause the camera preview', () async {
        // Act
        await plugin.pausePreview(cameraId);

        // Assert
        final VerificationResult verification =
            verify(mockApi.pausePreview(captureAny));
        expect(verification.captured[0], cameraId);
      });

      test('Should resume the camera preview', () async {
        // Act
        await plugin.resumePreview(cameraId);

        // Assert
        final VerificationResult verification =
            verify(mockApi.resumePreview(captureAny));
        expect(verification.captured[0], cameraId);
      });
    });
  });
}
