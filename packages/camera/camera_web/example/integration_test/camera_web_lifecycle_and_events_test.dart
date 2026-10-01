// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: only_throw_errors

import 'dart:async';
import 'dart:js_interop';

import 'package:async/async.dart';
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

    testWidgets('CameraPlugin is the live instance', (WidgetTester tester) async {
      expect(CameraPlatform.instance, isA<CameraPlugin>());
    });
    group('dispose', () {
      late Camera camera;
      late MockVideoElement mockVideoElement;
      late HTMLVideoElement videoElement;

      late StreamController<Event> errorStreamController, abortStreamController;
      late StreamController<MediaStreamTrack> endedStreamController;
      late StreamController<ErrorEvent> videoRecordingErrorController;

      setUp(() {
        camera = MockCamera();
        mockVideoElement = MockVideoElement();
        videoElement = createJSInteropWrapper(mockVideoElement) as HTMLVideoElement;

        errorStreamController = StreamController<Event>();
        abortStreamController = StreamController<Event>();
        endedStreamController = StreamController<MediaStreamTrack>();
        videoRecordingErrorController = StreamController<ErrorEvent>();

        when(camera.getVideoSize()).thenReturn(const Size(10, 10));
        when(camera.initialize()).thenAnswer((_) => Future<void>.value());
        when(camera.play()).thenAnswer((_) => Future<void>.value());
        when(camera.dispose()).thenAnswer((_) => Future<void>.value());

        when(camera.videoElement).thenReturn(videoElement);

        final errorProvider = MockEventStreamProvider<Event>();
        final abortProvider = MockEventStreamProvider<Event>();

        (CameraPlatform.instance as CameraPlugin).videoElementOnErrorProvider = errorProvider;
        (CameraPlatform.instance as CameraPlugin).videoElementOnAbortProvider = abortProvider;

        when(
          errorProvider.forElement(videoElement),
        ).thenAnswer((_) => FakeElementStream<Event>(errorStreamController.stream));
        when(
          abortProvider.forElement(videoElement),
        ).thenAnswer((_) => FakeElementStream<Event>(abortStreamController.stream));

        when(camera.onEnded).thenAnswer((_) => endedStreamController.stream);

        when(camera.onVideoRecordingError).thenAnswer((_) => videoRecordingErrorController.stream);

        when(camera.startVideoRecording()).thenAnswer((_) async {});
      });

      testWidgets('disposes the correct camera', (WidgetTester tester) async {
        const firstCameraId = 0;
        const secondCameraId = 1;

        final firstCamera = MockCamera();
        final secondCamera = MockCamera();

        when(firstCamera.dispose()).thenAnswer((_) => Future<void>.value());
        when(secondCamera.dispose()).thenAnswer((_) => Future<void>.value());

        // Save cameras in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras.addAll(<int, Camera>{
          firstCameraId: firstCamera,
          secondCameraId: secondCamera,
        });

        // Dispose the first camera.
        await CameraPlatform.instance.dispose(firstCameraId);

        // The first camera should be disposed.
        verify(firstCamera.dispose()).called(1);
        verifyNever(secondCamera.dispose());

        // The first camera should be removed from the camera plugin.
        expect(
          (CameraPlatform.instance as CameraPlugin).cameras,
          equals(<int, Camera>{secondCameraId: secondCamera}),
        );
      });

      testWidgets('cancels the camera video error and abort subscriptions', (
        WidgetTester tester,
      ) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.initializeCamera(cameraId);
        await CameraPlatform.instance.dispose(cameraId);

        expect(errorStreamController.hasListener, isFalse);
        expect(abortStreamController.hasListener, isFalse);
      });

      testWidgets('cancels the camera ended subscriptions', (WidgetTester tester) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.initializeCamera(cameraId);
        await CameraPlatform.instance.dispose(cameraId);

        expect(endedStreamController.hasListener, isFalse);
      });

      testWidgets('cancels the camera video recording error subscriptions', (
        WidgetTester tester,
      ) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.initializeCamera(cameraId);
        await CameraPlatform.instance.startVideoRecording(cameraId);
        await CameraPlatform.instance.dispose(cameraId);

        expect(videoRecordingErrorController.hasListener, isFalse);
      });

      group('throws PlatformException', () {
        testWidgets('with notFound error '
            'if the camera does not exist', (WidgetTester tester) async {
          expect(
            () => CameraPlatform.instance.dispose(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when dispose throws DomException', (WidgetTester tester) async {
          final camera = MockCamera();
          final exception = DOMException('InvalidAccessError');

          when(camera.dispose()).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.dispose(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });
      });
    });

    group('getCamera', () {
      testWidgets('returns the correct camera', (WidgetTester tester) async {
        final camera = Camera(textureId: cameraId, cameraService: cameraService);

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        expect((CameraPlatform.instance as CameraPlugin).getCamera(cameraId), equals(camera));
      });

      testWidgets('throws PlatformException '
          'with notFound error '
          'if the camera does not exist', (WidgetTester tester) async {
        expect(
          () => (CameraPlatform.instance as CameraPlugin).getCamera(cameraId),
          throwsA(
            isA<PlatformException>().having(
              (PlatformException e) => e.code,
              'code',
              CameraErrorCode.notFound.toString(),
            ),
          ),
        );
      });
    });

    group('events', () {
      late MockCamera camera;
      late MockVideoElement mockVideoElement;
      late HTMLVideoElement videoElement;

      late StreamController<Event> errorStreamController, abortStreamController;
      late StreamController<MediaStreamTrack> endedStreamController;
      late StreamController<ErrorEvent> videoRecordingErrorController;

      setUp(() {
        camera = MockCamera();
        mockVideoElement = MockVideoElement();
        videoElement = createJSInteropWrapper(mockVideoElement) as HTMLVideoElement;

        errorStreamController = StreamController<Event>();
        abortStreamController = StreamController<Event>();
        endedStreamController = StreamController<MediaStreamTrack>();
        videoRecordingErrorController = StreamController<ErrorEvent>();

        when(camera.getVideoSize()).thenReturn(const Size(10, 10));
        when(camera.initialize()).thenAnswer((_) => Future<void>.value());
        when(camera.play()).thenAnswer((_) => Future<void>.value());

        when(camera.videoElement).thenReturn(videoElement);

        final errorProvider = MockEventStreamProvider<Event>();
        final abortProvider = MockEventStreamProvider<Event>();

        (CameraPlatform.instance as CameraPlugin).videoElementOnErrorProvider = errorProvider;
        (CameraPlatform.instance as CameraPlugin).videoElementOnAbortProvider = abortProvider;

        when(
          errorProvider.forElement(any),
        ).thenAnswer((_) => FakeElementStream<Event>(errorStreamController.stream));
        when(
          abortProvider.forElement(any),
        ).thenAnswer((_) => FakeElementStream<Event>(abortStreamController.stream));

        when(camera.onEnded).thenAnswer((_) => endedStreamController.stream);

        when(camera.onVideoRecordingError).thenAnswer((_) => videoRecordingErrorController.stream);

        when(camera.startVideoRecording()).thenAnswer((_) async {});
      });

      testWidgets('onCameraInitialized emits a CameraInitializedEvent '
          'on initializeCamera', (WidgetTester tester) async {
        // Mock the camera to use a blank video stream of size 1280x720.
        const videoSize = Size(1280, 720);

        videoElement = getVideoElementWithBlankStream(videoSize);

        when(
          cameraService.getMediaStreamForOptions(any, cameraId: cameraId),
        ).thenAnswer((_) async => videoElement.captureStream());

        final camera = Camera(textureId: cameraId, cameraService: cameraService);

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        final Stream<CameraInitializedEvent> eventStream = CameraPlatform.instance
            .onCameraInitialized(cameraId);

        final streamQueue = StreamQueue<CameraInitializedEvent>(eventStream);

        await CameraPlatform.instance.initializeCamera(cameraId);

        expect(
          await streamQueue.next,
          equals(
            CameraInitializedEvent(
              cameraId,
              videoSize.width,
              videoSize.height,
              ExposureMode.auto,
              false,
              FocusMode.auto,
              false,
            ),
          ),
        );

        await streamQueue.cancel();
      });

      testWidgets('onCameraResolutionChanged emits an empty stream', (WidgetTester tester) async {
        final Stream<CameraResolutionChangedEvent> stream = CameraPlatform.instance
            .onCameraResolutionChanged(cameraId);
        expect(await stream.isEmpty, isTrue);
      });

      testWidgets('onCameraClosing emits a CameraClosingEvent '
          'on the camera ended event', (WidgetTester tester) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        final Stream<CameraClosingEvent> eventStream = CameraPlatform.instance.onCameraClosing(
          cameraId,
        );

        final streamQueue = StreamQueue<CameraClosingEvent>(eventStream);

        await CameraPlatform.instance.initializeCamera(cameraId);

        endedStreamController.add(
          createJSInteropWrapper(MockMediaStreamTrack()) as MediaStreamTrack,
        );

        expect(await streamQueue.next, equals(const CameraClosingEvent(cameraId)));

        await streamQueue.cancel();
      });

      group('onCameraError', () {
        setUp(() {
          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;
        });

        testWidgets('emits a CameraErrorEvent '
            'on the camera video error event '
            'with a message', (WidgetTester tester) async {
          final Stream<CameraErrorEvent> eventStream = CameraPlatform.instance.onCameraError(
            cameraId,
          );

          final streamQueue = StreamQueue<CameraErrorEvent>(eventStream);

          await CameraPlatform.instance.initializeCamera(cameraId);

          final error =
              createJSInteropWrapper(
                    FakeMediaError(MediaError.MEDIA_ERR_NETWORK, 'A network error occurred.'),
                  )
                  as MediaError;

          final CameraErrorCode errorCode = CameraErrorCode.fromMediaError(error);

          mockVideoElement.error = error;
          errorStreamController.add(Event('error'));

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(cameraId, 'Error code: $errorCode, error message: ${error.message}'),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets('emits a CameraErrorEvent '
            'on the camera video error event '
            'with no message', (WidgetTester tester) async {
          final Stream<CameraErrorEvent> eventStream = CameraPlatform.instance.onCameraError(
            cameraId,
          );

          final streamQueue = StreamQueue<CameraErrorEvent>(eventStream);

          await CameraPlatform.instance.initializeCamera(cameraId);

          final error =
              createJSInteropWrapper(FakeMediaError(MediaError.MEDIA_ERR_NETWORK)) as MediaError;
          final CameraErrorCode errorCode = CameraErrorCode.fromMediaError(error);

          mockVideoElement.error = error;
          errorStreamController.add(Event('error'));

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                'Error code: $errorCode, error message: No further diagnostic information can be determined or provided.',
              ),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets('emits a CameraErrorEvent '
            'on the camera video abort event', (WidgetTester tester) async {
          final Stream<CameraErrorEvent> eventStream = CameraPlatform.instance.onCameraError(
            cameraId,
          );

          final streamQueue = StreamQueue<CameraErrorEvent>(eventStream);

          await CameraPlatform.instance.initializeCamera(cameraId);

          abortStreamController.add(Event('abort'));

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                "Error code: ${CameraErrorCode.abort}, error message: The video element's source has not fully loaded.",
              ),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets('emits a CameraErrorEvent '
            'on takePicture error', (WidgetTester tester) async {
          final exception = CameraWebException(cameraId, CameraErrorCode.notStarted, 'description');

          when(camera.takePicture()).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream = CameraPlatform.instance.onCameraError(
            cameraId,
          );

          final streamQueue = StreamQueue<CameraErrorEvent>(eventStream);

          expect(
            () async => CameraPlatform.instance.takePicture(cameraId),
            throwsA(isA<PlatformException>()),
          );

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                'Error code: ${exception.code}, error message: ${exception.description}',
              ),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets('emits a CameraErrorEvent '
            'on setFlashMode error', (WidgetTester tester) async {
          final exception = CameraWebException(cameraId, CameraErrorCode.notStarted, 'description');

          when(camera.setFlashMode(any)).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream = CameraPlatform.instance.onCameraError(
            cameraId,
          );

          final streamQueue = StreamQueue<CameraErrorEvent>(eventStream);

          expect(
            () async => CameraPlatform.instance.setFlashMode(cameraId, FlashMode.always),
            throwsA(isA<PlatformException>()),
          );

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                'Error code: ${exception.code}, error message: ${exception.description}',
              ),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets('emits a CameraErrorEvent '
            'on getMaxZoomLevel error', (WidgetTester tester) async {
          final exception = CameraWebException(
            cameraId,
            CameraErrorCode.zoomLevelNotSupported,
            'description',
          );

          when(camera.getMaxZoomLevel()).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream = CameraPlatform.instance.onCameraError(
            cameraId,
          );

          final streamQueue = StreamQueue<CameraErrorEvent>(eventStream);

          expect(
            () async => CameraPlatform.instance.getMaxZoomLevel(cameraId),
            throwsA(isA<PlatformException>()),
          );

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                'Error code: ${exception.code}, error message: ${exception.description}',
              ),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets('emits a CameraErrorEvent '
            'on getMinZoomLevel error', (WidgetTester tester) async {
          final exception = CameraWebException(
            cameraId,
            CameraErrorCode.zoomLevelNotSupported,
            'description',
          );

          when(camera.getMinZoomLevel()).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream = CameraPlatform.instance.onCameraError(
            cameraId,
          );

          final streamQueue = StreamQueue<CameraErrorEvent>(eventStream);

          expect(
            () async => CameraPlatform.instance.getMinZoomLevel(cameraId),
            throwsA(isA<PlatformException>()),
          );

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                'Error code: ${exception.code}, error message: ${exception.description}',
              ),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets('emits a CameraErrorEvent '
            'on setZoomLevel error', (WidgetTester tester) async {
          final exception = CameraWebException(
            cameraId,
            CameraErrorCode.zoomLevelNotSupported,
            'description',
          );

          when(camera.setZoomLevel(any)).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream = CameraPlatform.instance.onCameraError(
            cameraId,
          );

          final streamQueue = StreamQueue<CameraErrorEvent>(eventStream);

          expect(
            () async => CameraPlatform.instance.setZoomLevel(cameraId, 100.0),
            throwsA(isA<CameraException>()),
          );

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                'Error code: ${exception.code}, error message: ${exception.description}',
              ),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets('emits a CameraErrorEvent '
            'on resumePreview error', (WidgetTester tester) async {
          final exception = CameraWebException(cameraId, CameraErrorCode.unknown, 'description');

          when(camera.play()).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream = CameraPlatform.instance.onCameraError(
            cameraId,
          );

          final streamQueue = StreamQueue<CameraErrorEvent>(eventStream);

          expect(
            () async => CameraPlatform.instance.resumePreview(cameraId),
            throwsA(isA<PlatformException>()),
          );

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                'Error code: ${exception.code}, error message: ${exception.description}',
              ),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets('emits a CameraErrorEvent '
            'on startVideoRecording error', (WidgetTester tester) async {
          final exception = CameraWebException(cameraId, CameraErrorCode.notStarted, 'description');

          when(camera.onVideoRecordingError).thenAnswer((_) => const Stream<ErrorEvent>.empty());

          when(camera.startVideoRecording()).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream = CameraPlatform.instance.onCameraError(
            cameraId,
          );

          final streamQueue = StreamQueue<CameraErrorEvent>(eventStream);

          expect(
            () async => CameraPlatform.instance.startVideoRecording(cameraId),
            throwsA(isA<PlatformException>()),
          );

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                'Error code: ${exception.code}, error message: ${exception.description}',
              ),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets('emits a CameraErrorEvent '
            'on the camera video recording error event', (WidgetTester tester) async {
          final Stream<CameraErrorEvent> eventStream = CameraPlatform.instance.onCameraError(
            cameraId,
          );

          final streamQueue = StreamQueue<CameraErrorEvent>(eventStream);

          await CameraPlatform.instance.initializeCamera(cameraId);
          await CameraPlatform.instance.startVideoRecording(cameraId);

          final errorEvent =
              createJSInteropWrapper(FakeErrorEvent('type', 'message')) as ErrorEvent;

          videoRecordingErrorController.add(errorEvent);

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                'Error code: ${errorEvent.type}, error message: ${errorEvent.message}.',
              ),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets('emits a CameraErrorEvent '
            'on stopVideoRecording error', (WidgetTester tester) async {
          final exception = CameraWebException(cameraId, CameraErrorCode.notStarted, 'description');

          when(camera.stopVideoRecording()).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream = CameraPlatform.instance.onCameraError(
            cameraId,
          );

          final streamQueue = StreamQueue<CameraErrorEvent>(eventStream);

          expect(
            () async => CameraPlatform.instance.stopVideoRecording(cameraId),
            throwsA(isA<PlatformException>()),
          );

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                'Error code: ${exception.code}, error message: ${exception.description}',
              ),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets('emits a CameraErrorEvent '
            'on pauseVideoRecording error', (WidgetTester tester) async {
          final exception = CameraWebException(cameraId, CameraErrorCode.notStarted, 'description');

          when(camera.pauseVideoRecording()).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream = CameraPlatform.instance.onCameraError(
            cameraId,
          );

          final streamQueue = StreamQueue<CameraErrorEvent>(eventStream);

          expect(
            () async => CameraPlatform.instance.pauseVideoRecording(cameraId),
            throwsA(isA<PlatformException>()),
          );

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                'Error code: ${exception.code}, error message: ${exception.description}',
              ),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets('emits a CameraErrorEvent '
            'on resumeVideoRecording error', (WidgetTester tester) async {
          final exception = CameraWebException(cameraId, CameraErrorCode.notStarted, 'description');

          when(camera.resumeVideoRecording()).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream = CameraPlatform.instance.onCameraError(
            cameraId,
          );

          final streamQueue = StreamQueue<CameraErrorEvent>(eventStream);

          expect(
            () async => CameraPlatform.instance.resumeVideoRecording(cameraId),
            throwsA(isA<PlatformException>()),
          );

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                'Error code: ${exception.code}, error message: ${exception.description}',
              ),
            ),
          );

          await streamQueue.cancel();
        });
      });

      testWidgets('onVideoRecordedEvent emits a VideoRecordedEvent', (WidgetTester tester) async {
        final camera = MockCamera();
        final capturedVideo = XFile('/bogus/test');
        final stream = Stream<VideoRecordedEvent>.value(
          VideoRecordedEvent(cameraId, capturedVideo, Duration.zero),
        );
        when(camera.onVideoRecordedEvent).thenAnswer((_) => stream);

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        final streamQueue = StreamQueue<VideoRecordedEvent>(
          CameraPlatform.instance.onVideoRecordedEvent(cameraId),
        );

        expect(
          await streamQueue.next,
          equals(VideoRecordedEvent(cameraId, capturedVideo, Duration.zero)),
        );
      });
    });
  });
}
