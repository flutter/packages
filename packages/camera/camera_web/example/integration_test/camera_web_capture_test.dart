// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: only_throw_errors

import 'dart:async';
import 'dart:js_interop';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/camera_web.dart';
// ignore_for_file: implementation_imports
import 'package:camera_web/src/camera.dart';
import 'package:camera_web/src/types/types.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:web/web.dart' hide MediaDeviceKind, OrientationType;

import 'helpers/helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('CameraPlugin', () {
    const cameraId = 1;

    late MockWindow mockWindow;
    late MockNavigator mockNavigator;
    late MockMediaDevices mockMediaDevices;

    late Window window;
    late Navigator navigator;
    late MediaDevices mediaDevices;

    late HTMLVideoElement videoElement;

    late MockScreen mockScreen;
    late MockScreenOrientation mockScreenOrientation;

    late Screen screen;
    late ScreenOrientation screenOrientation;

    late MockDocument mockDocument;
    late MockElement mockDocumentElement;

    late Document document;
    late Element documentElement;

    late MockCameraService cameraService;

    setUp(() async {
      mockWindow = MockWindow();
      mockNavigator = MockNavigator();
      mockMediaDevices = MockMediaDevices();

      window = createJSInteropWrapper(mockWindow) as Window;
      navigator = createJSInteropWrapper(mockNavigator) as Navigator;
      mediaDevices = createJSInteropWrapper(mockMediaDevices) as MediaDevices;

      mockWindow.navigator = navigator;
      mockNavigator.mediaDevices = mediaDevices;

      videoElement = getVideoElementWithBlankStream(const Size(10, 10));

      mockScreen = MockScreen();
      mockScreenOrientation = MockScreenOrientation();

      screen = createJSInteropWrapper(mockScreen) as Screen;
      screenOrientation = createJSInteropWrapper(mockScreenOrientation) as ScreenOrientation;

      mockScreen.orientation = screenOrientation;
      mockWindow.screen = screen;

      mockDocument = MockDocument();
      mockDocumentElement = MockElement();

      document = createJSInteropWrapper(mockDocument) as Document;
      documentElement = createJSInteropWrapper(mockDocumentElement) as Element;

      mockDocument.documentElement = documentElement;
      mockWindow.document = document;

      cameraService = MockCameraService();

      when(
        cameraService.getMediaStreamForOptions(any, cameraId: anyNamed('cameraId')),
      ).thenAnswer((_) async => videoElement.captureStream());

      CameraPlatform.instance = CameraPlugin(cameraService: cameraService)..window = window;
    });

    group('takePicture', () {
      testWidgets('captures a picture', (WidgetTester tester) async {
        final camera = MockCamera();
        final capturedPicture = XFile('/bogus/test');

        when(camera.takePicture()).thenAnswer((_) async => capturedPicture);

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        final XFile picture = await CameraPlatform.instance.takePicture(cameraId);

        verify(camera.takePicture()).called(1);

        expect(picture, equals(capturedPicture));
      });

      group('throws PlatformException', () {
        testWidgets('with notFound error '
            'if the camera does not exist', (WidgetTester tester) async {
          expect(
            () => CameraPlatform.instance.takePicture(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when takePicture throws DomException', (WidgetTester tester) async {
          final camera = MockCamera();
          final exception = DOMException('NotSupportedError');

          when(camera.takePicture()).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.takePicture(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });

        testWidgets('when takePicture throws CameraWebException', (WidgetTester tester) async {
          final camera = MockCamera();
          final exception = CameraWebException(cameraId, CameraErrorCode.notStarted, 'description');

          when(camera.takePicture()).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.takePicture(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                exception.code.toString(),
              ),
            ),
          );
        });
      });
    });

    group('startVideoRecording', () {
      late Camera camera;

      setUp(() {
        camera = MockCamera();

        when(camera.startVideoRecording()).thenAnswer((_) async {});

        when(camera.onVideoRecordingError).thenAnswer((_) => const Stream<ErrorEvent>.empty());
      });

      testWidgets('starts a video recording', (WidgetTester tester) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.startVideoRecording(cameraId);

        verify(camera.startVideoRecording()).called(1);
      });

      testWidgets('listens to the onVideoRecordingError stream', (WidgetTester tester) async {
        final videoRecordingErrorController = StreamController<ErrorEvent>();

        when(camera.onVideoRecordingError).thenAnswer((_) => videoRecordingErrorController.stream);

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.startVideoRecording(cameraId);

        expect(videoRecordingErrorController.hasListener, isTrue);
      });

      group('throws PlatformException', () {
        testWidgets('with notFound error '
            'if the camera does not exist', (WidgetTester tester) async {
          expect(
            () => CameraPlatform.instance.startVideoRecording(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when startVideoRecording throws DomException', (WidgetTester tester) async {
          final exception = DOMException('InvalidStateError');

          when(camera.startVideoRecording()).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.startVideoRecording(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });

        testWidgets('when startVideoRecording throws CameraWebException', (
          WidgetTester tester,
        ) async {
          final exception = CameraWebException(cameraId, CameraErrorCode.notStarted, 'description');

          when(camera.startVideoRecording()).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.startVideoRecording(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                exception.code.toString(),
              ),
            ),
          );
        });
      });
    });

    group('startVideoCapturing', () {
      late Camera camera;

      setUp(() {
        camera = MockCamera();

        when(camera.startVideoRecording()).thenAnswer((_) async {});

        when(camera.onVideoRecordingError).thenAnswer((_) => const Stream<ErrorEvent>.empty());
      });

      testWidgets('fails if trying to stream', (WidgetTester tester) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        expect(
          () => CameraPlatform.instance.startVideoCapturing(
            VideoCaptureOptions(cameraId, streamCallback: (CameraImageData imageData) {}),
          ),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('stopVideoRecording', () {
      testWidgets('stops a video recording', (WidgetTester tester) async {
        final camera = MockCamera();
        final capturedVideo = XFile('/bogus/test');

        when(camera.stopVideoRecording()).thenAnswer((_) async => capturedVideo);

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        final XFile video = await CameraPlatform.instance.stopVideoRecording(cameraId);

        verify(camera.stopVideoRecording()).called(1);

        expect(video, capturedVideo);
      });

      testWidgets('stops listening to the onVideoRecordingError stream', (
        WidgetTester tester,
      ) async {
        final camera = MockCamera();
        final videoRecordingErrorController = StreamController<ErrorEvent>();
        final capturedVideo = XFile('/bogus/test');

        when(camera.startVideoRecording()).thenAnswer((_) async {});

        when(camera.stopVideoRecording()).thenAnswer((_) async => capturedVideo);

        when(camera.onVideoRecordingError).thenAnswer((_) => videoRecordingErrorController.stream);

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.startVideoRecording(cameraId);
        final XFile _ = await CameraPlatform.instance.stopVideoRecording(cameraId);

        expect(videoRecordingErrorController.hasListener, isFalse);
      });

      group('throws PlatformException', () {
        testWidgets('with notFound error '
            'if the camera does not exist', (WidgetTester tester) async {
          expect(
            () => CameraPlatform.instance.stopVideoRecording(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when stopVideoRecording throws DomException', (WidgetTester tester) async {
          final camera = MockCamera();
          final exception = DOMException('InvalidStateError');

          when(camera.stopVideoRecording()).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.stopVideoRecording(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });

        testWidgets('when stopVideoRecording throws CameraWebException', (
          WidgetTester tester,
        ) async {
          final camera = MockCamera();
          final exception = CameraWebException(cameraId, CameraErrorCode.notStarted, 'description');

          when(camera.stopVideoRecording()).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.stopVideoRecording(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                exception.code.toString(),
              ),
            ),
          );
        });
      });
    });

    group('pauseVideoRecording', () {
      testWidgets('pauses a video recording', (WidgetTester tester) async {
        final camera = MockCamera();

        when(camera.pauseVideoRecording()).thenAnswer((_) async {});

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.pauseVideoRecording(cameraId);

        verify(camera.pauseVideoRecording()).called(1);
      });

      group('throws PlatformException', () {
        testWidgets('with notFound error '
            'if the camera does not exist', (WidgetTester tester) async {
          expect(
            () => CameraPlatform.instance.pauseVideoRecording(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when pauseVideoRecording throws DomException', (WidgetTester tester) async {
          final camera = MockCamera();
          final exception = DOMException('InvalidStateError');

          when(camera.pauseVideoRecording()).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.pauseVideoRecording(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });

        testWidgets('when pauseVideoRecording throws CameraWebException', (
          WidgetTester tester,
        ) async {
          final camera = MockCamera();
          final exception = CameraWebException(cameraId, CameraErrorCode.notStarted, 'description');

          when(camera.pauseVideoRecording()).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.pauseVideoRecording(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                exception.code.toString(),
              ),
            ),
          );
        });
      });
    });

    group('resumeVideoRecording', () {
      testWidgets('resumes a video recording', (WidgetTester tester) async {
        final camera = MockCamera();

        when(camera.resumeVideoRecording()).thenAnswer((_) async {});

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.resumeVideoRecording(cameraId);

        verify(camera.resumeVideoRecording()).called(1);
      });

      group('throws PlatformException', () {
        testWidgets('with notFound error '
            'if the camera does not exist', (WidgetTester tester) async {
          expect(
            () => CameraPlatform.instance.resumeVideoRecording(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when resumeVideoRecording throws DomException', (WidgetTester tester) async {
          final camera = MockCamera();
          final exception = DOMException('InvalidStateError');

          when(camera.resumeVideoRecording()).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.resumeVideoRecording(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });

        testWidgets('when resumeVideoRecording throws CameraWebException', (
          WidgetTester tester,
        ) async {
          final camera = MockCamera();
          final exception = CameraWebException(cameraId, CameraErrorCode.notStarted, 'description');

          when(camera.resumeVideoRecording()).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.resumeVideoRecording(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                exception.code.toString(),
              ),
            ),
          );
        });
      });
    });
  });
}
