// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui';

import 'package:async/async.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
// ignore_for_file: implementation_imports
import 'package:camera_web/src/camera.dart';
import 'package:camera_web/src/camera_service.dart';
import 'package:camera_web/src/types/types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web/web.dart';

import 'helpers/helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Camera', () {
    const int textureId = 1;

    late MockWindow mockWindow;
    late MockNavigator mockNavigator;
    late MockMediaDevices mockMediaDevices;

    late Window window;
    late Navigator navigator;
    late MediaDevices mediaDevices;

    late MediaStream mediaStream;
    late CameraService cameraService;

    setUp(() {
      mockWindow = MockWindow();
      mockNavigator = MockNavigator();
      mockMediaDevices = MockMediaDevices();

      window = createJSInteropWrapper(mockWindow) as Window;
      navigator = createJSInteropWrapper(mockNavigator) as Navigator;
      mediaDevices = createJSInteropWrapper(mockMediaDevices) as MediaDevices;

      mockWindow.navigator = navigator;
      mockNavigator.mediaDevices = mediaDevices;

      cameraService = MockCameraService();

      final HTMLVideoElement videoElement =
          getVideoElementWithBlankStream(const Size(10, 10));
      mediaStream = videoElement.captureStream();

      when(
        () => cameraService.getMediaStreamForOptions(
          any(),
          cameraId: any(named: 'cameraId'),
        ),
      ).thenAnswer((_) => Future<MediaStream>.value(mediaStream));
    });

    setUpAll(() {
      registerFallbackValue(MockCameraOptions());
    });

    group('initialize', () {
      testWidgets(
          'calls CameraService.getMediaStreamForOptions '
          'with provided options', (WidgetTester tester) async {
        final CameraOptions options = CameraOptions(
          video: VideoConstraints(
            facingMode: FacingModeConstraint.exact(CameraType.user),
            width: const VideoSizeConstraint(ideal: 200),
          ),
        );

        final Camera camera = Camera(
          textureId: textureId,
          options: options,
          cameraService: cameraService,
        );

        await camera.initialize();

        verify(
          () => cameraService.getMediaStreamForOptions(
            options,
            cameraId: textureId,
          ),
        ).called(1);
      });

      testWidgets(
          'creates a video element '
          'with correct properties', (WidgetTester tester) async {
        const AudioConstraints audioConstraints =
            AudioConstraints(enabled: true);
        final VideoConstraints videoConstraints = VideoConstraints(
          facingMode: FacingModeConstraint(
            CameraType.user,
          ),
        );

        final Camera camera = Camera(
          textureId: textureId,
          options: CameraOptions(
            audio: audioConstraints,
            video: videoConstraints,
          ),
          cameraService: cameraService,
        );

        await camera.initialize();

        expect(camera.videoElement, isNotNull);
        expect(camera.videoElement.autoplay, isFalse);
        expect(camera.videoElement.muted, isTrue);
        expect(camera.videoElement.srcObject, mediaStream);
        expect(camera.videoElement.attributes.getNamedItem('playsinline'),
            isNotNull);

        expect(
            camera.videoElement.style.transformOrigin, equals('center center'));
        expect(camera.videoElement.style.pointerEvents, equals('none'));
        expect(camera.videoElement.style.width, equals('100%'));
        expect(camera.videoElement.style.height, equals('100%'));
        expect(camera.videoElement.style.objectFit, equals('cover'));
      });

      testWidgets(
          'flips the video element horizontally '
          'for a back camera', (WidgetTester tester) async {
        final VideoConstraints videoConstraints = VideoConstraints(
          facingMode: FacingModeConstraint(
            CameraType.environment,
          ),
        );

        final Camera camera = Camera(
          textureId: textureId,
          options: CameraOptions(
            video: videoConstraints,
          ),
          cameraService: cameraService,
        );

        await camera.initialize();

        expect(camera.videoElement.style.transform, equals('scaleX(-1)'));
      });

      testWidgets(
          'creates a wrapping div element '
          'with correct properties', (WidgetTester tester) async {
        final Camera camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();

        expect(camera.divElement, isNotNull);
        expect(camera.divElement.style.objectFit, equals('cover'));
        final JSArray<Element>? array = (globalContext['Array']! as JSObject)
                .callMethod('from'.toJS, camera.divElement.children)
            as JSArray<Element>?;
        expect(array?.toDart, contains(camera.videoElement));
      });

      testWidgets('initializes the camera stream', (WidgetTester tester) async {
        final Camera camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();

        expect(camera.stream, mediaStream);
      });

      testWidgets(
          'throws an exception '
          'when CameraService.getMediaStreamForOptions throws',
          (WidgetTester tester) async {
        final Exception exception =
            Exception('A media stream exception occured.');

        when(() => cameraService.getMediaStreamForOptions(any(),
            cameraId: any(named: 'cameraId'))).thenThrow(exception);

        final Camera camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        expect(
          camera.initialize,
          throwsA(exception),
        );
      });
    });

    group('play', () {
      testWidgets('starts playing the video element',
          (WidgetTester tester) async {
        bool startedPlaying = false;

        final Camera camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();

        final StreamSubscription<Event> cameraPlaySubscription = camera
            .videoElement.onPlay
            .listen((Event event) => startedPlaying = true);

        await camera.play();

        expect(startedPlaying, isTrue);

        await cameraPlaySubscription.cancel();
      });

      testWidgets(
          'initializes the camera stream '
          'from CameraService.getMediaStreamForOptions '
          'if it does not exist', (WidgetTester tester) async {
        const CameraOptions options = CameraOptions(
          video: VideoConstraints(
            width: VideoSizeConstraint(ideal: 100),
          ),
        );

        final Camera camera = Camera(
          textureId: textureId,
          options: options,
          cameraService: cameraService,
        );

        await camera.initialize();

        /// Remove the video element's source
        /// by stopping the camera.
        camera.stop();

        await camera.play();

        // Should be called twice: for initialize and play.
        verify(
          () => cameraService.getMediaStreamForOptions(
            options,
            cameraId: textureId,
          ),
        ).called(2);

        expect(camera.videoElement.srcObject, mediaStream);
        expect(camera.stream, mediaStream);
      });
    });

    group('pause', () {
      testWidgets('pauses the camera stream', (WidgetTester tester) async {
        final Camera camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();
        await camera.play();

        expect(camera.videoElement.paused, isFalse);

        camera.pause();

        expect(camera.videoElement.paused, isTrue);
      });
    });

    group('stop', () {
      testWidgets('resets the camera stream', (WidgetTester tester) async {
        final Camera camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();
        await camera.play();

        camera.stop();

        expect(camera.videoElement.srcObject, isNull);
        expect(camera.stream, isNull);
      });
    });

    group('takePicture', () {
      testWidgets('returns a captured picture', (WidgetTester tester) async {
        final Camera camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();
        await camera.play();

        final XFile pictureFile = await camera.takePicture();

        expect(pictureFile, isNotNull);
      });

      group(
          'enables the torch mode '
          'when taking a picture', () {
        late MockMediaStreamTrack mockVideoTrack;
        late List<MediaStreamTrack> videoTracks;
        late MediaStream videoStream;
        late HTMLVideoElement videoElement;

        setUp(() {
          mockVideoTrack = MockMediaStreamTrack();
          videoTracks = <MediaStreamTrack>[
            createJSInteropWrapper(mockVideoTrack) as MediaStreamTrack,
            createJSInteropWrapper(MockMediaStreamTrack()) as MediaStreamTrack,
          ];
          videoStream = createJSInteropWrapper(FakeMediaStream(videoTracks))
              as MediaStream;

          videoElement = getVideoElementWithBlankStream(const Size(100, 100))
            ..muted = true;

          mockVideoTrack.getCapabilities = () {
            return MediaTrackCapabilities(torch: <JSBoolean>[true.toJS].toJS);
          }.toJS;
        });

        testWidgets('if the flash mode is auto', (WidgetTester tester) async {
          final Camera camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          )
            ..window = window
            ..stream = videoStream
            ..videoElement = videoElement
            ..flashMode = FlashMode.auto;

          await camera.play();

          final List<MediaTrackConstraints> capturedConstraints =
              <MediaTrackConstraints>[];
          mockVideoTrack.applyConstraints = ([
            MediaTrackConstraints? constraints,
          ]) {
            if (constraints != null) {
              capturedConstraints.add(constraints);
            }
            return Future<JSAny?>.value().toJS;
          }.toJS;

          final XFile _ = await camera.takePicture();

          expect(capturedConstraints.length, 2);
          expect(capturedConstraints[0].torch.dartify(), true);
          expect(capturedConstraints[1].torch.dartify(), false);
        });

        testWidgets('if the flash mode is always', (WidgetTester tester) async {
          final Camera camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          )
            ..window = window
            ..stream = videoStream
            ..videoElement = videoElement
            ..flashMode = FlashMode.always;

          await camera.play();

          final List<MediaTrackConstraints> capturedConstraints =
              <MediaTrackConstraints>[];
          mockVideoTrack.applyConstraints = ([
            MediaTrackConstraints? constraints,
          ]) {
            if (constraints != null) {
              capturedConstraints.add(constraints);
            }
            return Future<JSAny?>.value().toJS;
          }.toJS;

          final XFile _ = await camera.takePicture();

          expect(capturedConstraints.length, 2);
          expect(capturedConstraints[0].torch.dartify(), true);
          expect(capturedConstraints[1].torch.dartify(), false);
        });
      });
    });

    group('getVideoSize', () {
      testWidgets(
          'returns a size '
          'based on the first video track settings',
          (WidgetTester tester) async {
        const Size videoSize = Size(1280, 720);

        final HTMLVideoElement videoElement =
            getVideoElementWithBlankStream(videoSize);
        mediaStream = videoElement.captureStream();

        final Camera camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();

        expect(
          camera.getVideoSize(),
          equals(videoSize),
        );
      });

      testWidgets(
          'returns Size.zero '
          'if the camera is missing video tracks', (WidgetTester tester) async {
        // Create a video stream with no video tracks.
        final HTMLVideoElement videoElement = HTMLVideoElement();
        mediaStream = videoElement.captureStream();

        final Camera camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();

        expect(
          camera.getVideoSize(),
          equals(Size.zero),
        );
      });
    });

    group('setFlashMode', () {
      late MockMediaStreamTrack mockVideoTrack;
      late List<MediaStreamTrack> videoTracks;
      late MediaStream videoStream;

      setUp(() {
        mockVideoTrack = MockMediaStreamTrack();
        videoTracks = <MediaStreamTrack>[
          createJSInteropWrapper(mockVideoTrack) as MediaStreamTrack,
          createJSInteropWrapper(MockMediaStreamTrack()) as MediaStreamTrack,
        ];
        videoStream =
            createJSInteropWrapper(FakeMediaStream(videoTracks)) as MediaStream;

        mockVideoTrack.applyConstraints = ([
          MediaTrackConstraints? constraints,
        ]) {
          return Future<JSAny?>.value().toJS;
        }.toJS;

        mockVideoTrack.getCapabilities = () {
          return MediaTrackCapabilities();
        }.toJS;
      });

      testWidgets('sets the camera flash mode', (WidgetTester tester) async {
        mockMediaDevices.getSupportedConstraints = () {
          return MediaTrackSupportedConstraints(torch: true);
        }.toJS;

        mockVideoTrack.getCapabilities = () {
          return MediaTrackCapabilities(torch: <JSBoolean>[true.toJS].toJS);
        }.toJS;

        final Camera camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        )
          ..window = window
          ..stream = videoStream;

        const FlashMode flashMode = FlashMode.always;

        camera.setFlashMode(flashMode);

        expect(
          camera.flashMode,
          equals(flashMode),
        );
      });

      testWidgets(
          'enables the torch mode '
          'if the flash mode is torch', (WidgetTester tester) async {
        mockMediaDevices.getSupportedConstraints = () {
          return MediaTrackSupportedConstraints(torch: true);
        }.toJS;

        mockVideoTrack.getCapabilities = () {
          return MediaTrackCapabilities(torch: <JSBoolean>[true.toJS].toJS);
        }.toJS;

        final Camera camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        )
          ..window = window
          ..stream = videoStream;

        final List<MediaTrackConstraints> capturedConstraints =
            <MediaTrackConstraints>[];
        mockVideoTrack.applyConstraints = ([
          MediaTrackConstraints? constraints,
        ]) {
          if (constraints != null) {
            capturedConstraints.add(constraints);
          }
          return Future<JSAny?>.value().toJS;
        }.toJS;

        camera.setFlashMode(FlashMode.torch);

        expect(capturedConstraints.length, 1);
        expect(capturedConstraints[0].torch.dartify(), true);
      });

      testWidgets(
          'disables the torch mode '
          'if the flash mode is not torch', (WidgetTester tester) async {
        mockMediaDevices.getSupportedConstraints = () {
          return MediaTrackSupportedConstraints(torch: true);
        }.toJS;

        mockVideoTrack.getCapabilities = () {
          return MediaTrackCapabilities(torch: <JSBoolean>[true.toJS].toJS);
        }.toJS;

        final Camera camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        )
          ..window = window
          ..stream = videoStream;

        final List<MediaTrackConstraints> capturedConstraints =
            <MediaTrackConstraints>[];
        mockVideoTrack.applyConstraints = ([
          MediaTrackConstraints? constraints,
        ]) {
          if (constraints != null) {
            capturedConstraints.add(constraints);
          }
          return Future<JSAny?>.value().toJS;
        }.toJS;

        camera.setFlashMode(FlashMode.auto);

        expect(capturedConstraints.length, 1);
        expect(capturedConstraints[0].torch.dartify(), false);
      });

      group('throws a CameraWebException', () {
        testWidgets(
            'with torchModeNotSupported error '
            'when the torch mode is not supported '
            'in the browser', (WidgetTester tester) async {
          mockMediaDevices.getSupportedConstraints = () {
            return MediaTrackSupportedConstraints(torch: false);
          }.toJS;

          mockVideoTrack.getCapabilities = () {
            return MediaTrackCapabilities(torch: <JSBoolean>[true.toJS].toJS);
          }.toJS;

          final Camera camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          )
            ..window = window
            ..stream = videoStream;

          expect(
            () => camera.setFlashMode(FlashMode.always),
            throwsA(
              isA<CameraWebException>()
                  .having(
                    (CameraWebException e) => e.cameraId,
                    'cameraId',
                    textureId,
                  )
                  .having(
                    (CameraWebException e) => e.code,
                    'code',
                    CameraErrorCode.torchModeNotSupported,
                  ),
            ),
          );
        });

        testWidgets(
            'with torchModeNotSupported error '
            'when the torch mode is not supported '
            'by the camera', (WidgetTester tester) async {
          mockMediaDevices.getSupportedConstraints = () {
            return MediaTrackSupportedConstraints(torch: true);
          }.toJS;

          mockVideoTrack.getCapabilities = () {
            return MediaTrackCapabilities(torch: <JSBoolean>[false.toJS].toJS);
          }.toJS;

          final Camera camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          )
            ..window = window
            ..stream = videoStream;

          expect(
            () => camera.setFlashMode(FlashMode.always),
            throwsA(
              isA<CameraWebException>()
                  .having(
                    (CameraWebException e) => e.cameraId,
                    'cameraId',
                    textureId,
                  )
                  .having(
                    (CameraWebException e) => e.code,
                    'code',
                    CameraErrorCode.torchModeNotSupported,
                  ),
            ),
          );
        });

        testWidgets(
            'with notStarted error '
            'when the camera stream has not been initialized',
            (WidgetTester tester) async {
          mockMediaDevices.getSupportedConstraints = () {
            return MediaTrackSupportedConstraints(torch: true);
          }.toJS;

          mockVideoTrack.getCapabilities = () {
            return MediaTrackCapabilities(torch: <JSBoolean>[true.toJS].toJS);
          }.toJS;

          final Camera camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          )..window = window;

          expect(
            () => camera.setFlashMode(FlashMode.always),
            throwsA(
              isA<CameraWebException>()
                  .having(
                    (CameraWebException e) => e.cameraId,
                    'cameraId',
                    textureId,
                  )
                  .having(
                    (CameraWebException e) => e.code,
                    'code',
                    CameraErrorCode.notStarted,
                  ),
            ),
          );
        });
      });
    });

    group('zoomLevel', () {
      group('getMaxZoomLevel', () {
        testWidgets(
            'returns maximum '
            'from CameraService.getZoomLevelCapabilityForCamera',
            (WidgetTester tester) async {
          final Camera camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          );

          final ZoomLevelCapability zoomLevelCapability = ZoomLevelCapability(
            minimum: 50.0,
            maximum: 100.0,
            videoTrack: createJSInteropWrapper(MockMediaStreamTrack())
                as MediaStreamTrack,
          );

          when(() => cameraService.getZoomLevelCapabilityForCamera(camera))
              .thenReturn(zoomLevelCapability);

          final double maximumZoomLevel = camera.getMaxZoomLevel();

          verify(() => cameraService.getZoomLevelCapabilityForCamera(camera))
              .called(1);

          expect(
            maximumZoomLevel,
            equals(zoomLevelCapability.maximum),
          );
        });
      });

      group('getMinZoomLevel', () {
        testWidgets(
            'returns minimum '
            'from CameraService.getZoomLevelCapabilityForCamera',
            (WidgetTester tester) async {
          final Camera camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          );

          final ZoomLevelCapability zoomLevelCapability = ZoomLevelCapability(
            minimum: 50.0,
            maximum: 100.0,
            videoTrack: createJSInteropWrapper(MockMediaStreamTrack())
                as MediaStreamTrack,
          );

          when(() => cameraService.getZoomLevelCapabilityForCamera(camera))
              .thenReturn(zoomLevelCapability);

          final double minimumZoomLevel = camera.getMinZoomLevel();

          verify(() => cameraService.getZoomLevelCapabilityForCamera(camera))
              .called(1);

          expect(
            minimumZoomLevel,
            equals(zoomLevelCapability.minimum),
          );
        });
      });

      group('setZoomLevel', () {
        testWidgets(
            'applies zoom on the video track '
            'from CameraService.getZoomLevelCapabilityForCamera',
            (WidgetTester tester) async {
          final Camera camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          );

          final MockMediaStreamTrack mockVideoTrack = MockMediaStreamTrack();
          final MediaStreamTrack videoTrack =
              createJSInteropWrapper(mockVideoTrack) as MediaStreamTrack;

          final ZoomLevelCapability zoomLevelCapability = ZoomLevelCapability(
            minimum: 50.0,
            maximum: 100.0,
            videoTrack: videoTrack,
          );

          final List<MediaTrackConstraints> capturedConstraints =
              <MediaTrackConstraints>[];
          mockVideoTrack.applyConstraints = ([
            MediaTrackConstraints? constraints,
          ]) {
            if (constraints != null) {
              capturedConstraints.add(constraints);
            }
            return Future<JSAny?>.value().toJS;
          }.toJS;

          when(() => cameraService.getZoomLevelCapabilityForCamera(camera))
              .thenReturn(zoomLevelCapability);

          const double zoom = 75.0;

          camera.setZoomLevel(zoom);

          expect(capturedConstraints.length, 1);
          expect(capturedConstraints[0].zoom.dartify(), zoom);
        });

        group('throws a CameraWebException', () {
          testWidgets(
              'with zoomLevelInvalid error '
              'when the provided zoom level is below minimum',
              (WidgetTester tester) async {
            final Camera camera = Camera(
              textureId: textureId,
              cameraService: cameraService,
            );

            final ZoomLevelCapability zoomLevelCapability = ZoomLevelCapability(
              minimum: 50.0,
              maximum: 100.0,
              videoTrack: createJSInteropWrapper(MockMediaStreamTrack())
                  as MediaStreamTrack,
            );

            when(() => cameraService.getZoomLevelCapabilityForCamera(camera))
                .thenReturn(zoomLevelCapability);

            expect(
                () => camera.setZoomLevel(45.0),
                throwsA(
                  isA<CameraWebException>()
                      .having(
                        (CameraWebException e) => e.cameraId,
                        'cameraId',
                        textureId,
                      )
                      .having(
                        (CameraWebException e) => e.code,
                        'code',
                        CameraErrorCode.zoomLevelInvalid,
                      ),
                ));
          });

          testWidgets(
              'with zoomLevelInvalid error '
              'when the provided zoom level is below minimum',
              (WidgetTester tester) async {
            final Camera camera = Camera(
              textureId: textureId,
              cameraService: cameraService,
            );

            final ZoomLevelCapability zoomLevelCapability = ZoomLevelCapability(
              minimum: 50.0,
              maximum: 100.0,
              videoTrack: createJSInteropWrapper(MockMediaStreamTrack())
                  as MediaStreamTrack,
            );

            when(() => cameraService.getZoomLevelCapabilityForCamera(camera))
                .thenReturn(zoomLevelCapability);

            expect(
              () => camera.setZoomLevel(105.0),
              throwsA(
                isA<CameraWebException>()
                    .having(
                      (CameraWebException e) => e.cameraId,
                      'cameraId',
                      textureId,
                    )
                    .having(
                      (CameraWebException e) => e.code,
                      'code',
                      CameraErrorCode.zoomLevelInvalid,
                    ),
              ),
            );
          });
        });
      });
    });

    group('getLensDirection', () {
      testWidgets(
          'returns a lens direction '
          'based on the first video track settings',
          (WidgetTester tester) async {
        final MockVideoElement mockVideoElement = MockVideoElement();
        final HTMLVideoElement videoElement =
            createJSInteropWrapper(mockVideoElement) as HTMLVideoElement;

        final Camera camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        )..videoElement = videoElement;

        final MockMediaStreamTrack firstVideoTrack = MockMediaStreamTrack();

        mockVideoElement.srcObject = createJSInteropWrapper(
          FakeMediaStream(
            <MediaStreamTrack>[
              createJSInteropWrapper(firstVideoTrack) as MediaStreamTrack,
              createJSInteropWrapper(MockMediaStreamTrack())
                  as MediaStreamTrack,
            ],
          ),
        ) as MediaStream;

        firstVideoTrack.getSettings = () {
          return MediaTrackSettings(facingMode: 'environment');
        }.toJS;

        when(() => cameraService.mapFacingModeToLensDirection('environment'))
            .thenReturn(CameraLensDirection.external);

        expect(
          camera.getLensDirection(),
          equals(CameraLensDirection.external),
        );
      });

      testWidgets(
          'returns null '
          'if the first video track is missing the facing mode',
          (WidgetTester tester) async {
        final MockVideoElement mockVideoElement = MockVideoElement();
        final HTMLVideoElement videoElement =
            createJSInteropWrapper(mockVideoElement) as HTMLVideoElement;

        final Camera camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        )..videoElement = videoElement;

        final MockMediaStreamTrack firstVideoTrack = MockMediaStreamTrack();

        videoElement.srcObject = createJSInteropWrapper(
          FakeMediaStream(
            <MediaStreamTrack>[
              createJSInteropWrapper(firstVideoTrack) as MediaStreamTrack,
              createJSInteropWrapper(MockMediaStreamTrack())
                  as MediaStreamTrack,
            ],
          ),
        ) as MediaStream;

        firstVideoTrack.getSettings = () {
          return MediaTrackSettings();
        }.toJS;

        expect(
          camera.getLensDirection(),
          isNull,
        );
      });

      testWidgets(
          'returns null '
          'if the camera is missing video tracks', (WidgetTester tester) async {
        // Create a video stream with no video tracks.
        final HTMLVideoElement videoElement = HTMLVideoElement();
        mediaStream = videoElement.captureStream();

        final Camera camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();

        expect(
          camera.getLensDirection(),
          isNull,
        );
      });
    });

    group('getViewType', () {
      testWidgets('returns a correct view type', (WidgetTester tester) async {
        final Camera camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();

        expect(
          camera.getViewType(),
          equals('plugins.flutter.io/camera_$textureId'),
        );
      });
    });

    group('video recording', () {
      const String supportedVideoType = 'video/webm';

      late MockMediaRecorder mockMediaRecorder;
      late MediaRecorder mediaRecorder;

      bool isVideoTypeSupported(String type) => type == supportedVideoType;

      setUp(() {
        mockMediaRecorder = MockMediaRecorder();
        mediaRecorder =
            createJSInteropWrapper(mockMediaRecorder) as MediaRecorder;
      });

      group('startVideoRecording', () {
        testWidgets(
            'creates a media recorder '
            'with appropriate options', (WidgetTester tester) async {
          final Camera camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )..isVideoTypeSupported = isVideoTypeSupported;

          await camera.initialize();
          await camera.play();

          await camera.startVideoRecording();

          expect(
            camera.mediaRecorder!.stream,
            equals(camera.stream),
          );

          expect(
            camera.mediaRecorder!.mimeType,
            equals(supportedVideoType),
          );

          expect(
            camera.mediaRecorder!.state,
            equals('recording'),
          );
        });

        testWidgets('listens to the media recorder data events',
            (WidgetTester tester) async {
          final Camera camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )
            ..mediaRecorder = mediaRecorder
            ..isVideoTypeSupported = isVideoTypeSupported;

          await camera.initialize();
          await camera.play();

          final List<String> capturedEvents = <String>[];
          mockMediaRecorder.addEventListener = (
            String type,
            EventListener? callback, [
            JSAny? options,
          ]) {
            capturedEvents.add(type);
          }.toJS;

          await camera.startVideoRecording();

          expect(
            capturedEvents.where((String e) => e == 'dataavailable').length,
            1,
          );
        });

        testWidgets('listens to the media recorder stop events',
            (WidgetTester tester) async {
          final Camera camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )
            ..mediaRecorder = mediaRecorder
            ..isVideoTypeSupported = isVideoTypeSupported;

          await camera.initialize();
          await camera.play();

          final List<String> capturedEvents = <String>[];
          mockMediaRecorder.addEventListener = (
            String type,
            EventListener? callback, [
            JSAny? options,
          ]) {
            capturedEvents.add(type);
          }.toJS;

          await camera.startVideoRecording();

          expect(
            capturedEvents.where((String e) => e == 'stop').length,
            1,
          );
        });

        testWidgets('starts a video recording', (WidgetTester tester) async {
          final Camera camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )
            ..mediaRecorder = mediaRecorder
            ..isVideoTypeSupported = isVideoTypeSupported;

          await camera.initialize();
          await camera.play();

          final List<int?> capturedStarts = <int?>[];
          mockMediaRecorder.start = ([int? timeslice]) {
            capturedStarts.add(timeslice);
          }.toJS;

          await camera.startVideoRecording();

          expect(capturedStarts.length, 1);
        });

        group('throws a CameraWebException', () {
          testWidgets(
              'with notSupported error '
              'when no video types are supported', (WidgetTester tester) async {
            final Camera camera = Camera(
              textureId: 1,
              cameraService: cameraService,
            )..isVideoTypeSupported = (String type) => false;

            await camera.initialize();
            await camera.play();

            expect(
              camera.startVideoRecording,
              throwsA(
                isA<CameraWebException>()
                    .having(
                      (CameraWebException e) => e.cameraId,
                      'cameraId',
                      textureId,
                    )
                    .having(
                      (CameraWebException e) => e.code,
                      'code',
                      CameraErrorCode.notSupported,
                    ),
              ),
            );
          });
        });
      });

      group('pauseVideoRecording', () {
        testWidgets('pauses a video recording', (WidgetTester tester) async {
          final Camera camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )..mediaRecorder = mediaRecorder;

          int pauses = 0;
          mockMediaRecorder.pause = () {
            pauses++;
          }.toJS;

          await camera.pauseVideoRecording();

          expect(pauses, 1);
        });

        testWidgets(
            'throws a CameraWebException '
            'with videoRecordingNotStarted error '
            'if the video recording was not started',
            (WidgetTester tester) async {
          final Camera camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          );

          expect(
            camera.pauseVideoRecording,
            throwsA(
              isA<CameraWebException>()
                  .having(
                    (CameraWebException e) => e.cameraId,
                    'cameraId',
                    textureId,
                  )
                  .having(
                    (CameraWebException e) => e.code,
                    'code',
                    CameraErrorCode.videoRecordingNotStarted,
                  ),
            ),
          );
        });
      });

      group('resumeVideoRecording', () {
        testWidgets('resumes a video recording', (WidgetTester tester) async {
          final Camera camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )..mediaRecorder = mediaRecorder;

          int resumes = 0;
          mockMediaRecorder.resume = () {
            resumes++;
          }.toJS;

          await camera.resumeVideoRecording();

          expect(resumes, 1);
        });

        testWidgets(
            'throws a CameraWebException '
            'with videoRecordingNotStarted error '
            'if the video recording was not started',
            (WidgetTester tester) async {
          final Camera camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          );

          expect(
            camera.resumeVideoRecording,
            throwsA(
              isA<CameraWebException>()
                  .having(
                    (CameraWebException e) => e.cameraId,
                    'cameraId',
                    textureId,
                  )
                  .having(
                    (CameraWebException e) => e.code,
                    'code',
                    CameraErrorCode.videoRecordingNotStarted,
                  ),
            ),
          );
        });
      });

      group('stopVideoRecording', () {
        testWidgets(
            'stops a video recording and '
            'returns the captured file '
            'based on all video data parts', (WidgetTester tester) async {
          final Camera camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )
            ..mediaRecorder = mediaRecorder
            ..isVideoTypeSupported = isVideoTypeSupported;

          await camera.initialize();
          await camera.play();

          late EventListener videoDataAvailableListener;
          late EventListener videoRecordingStoppedListener;

          mockMediaRecorder.addEventListener = (
            String type,
            EventListener? callback, [
            JSAny? options,
          ]) {
            if (type == 'dataavailable') {
              videoDataAvailableListener = callback!;
            } else if (type == 'stop') {
              videoRecordingStoppedListener = callback!;
            }
          }.toJS;

          Blob? finalVideo;
          List<Blob>? videoParts;
          camera.blobBuilder = (List<Blob> blobs, String videoType) {
            videoParts = <Blob>[...blobs];
            finalVideo = Blob(blobs.toJS, BlobPropertyBag(type: videoType));
            return finalVideo!;
          };

          await camera.startVideoRecording();

          int stops = 0;
          mockMediaRecorder.stop = () {
            stops++;
          }.toJS;

          final Future<XFile> videoFileFuture = camera.stopVideoRecording();

          final Blob capturedVideoPartOne = Blob(<JSAny>[].toJS);
          final Blob capturedVideoPartTwo = Blob(<JSAny>[].toJS);

          final List<Blob> capturedVideoParts = <Blob>[
            capturedVideoPartOne,
            capturedVideoPartTwo,
          ];

          videoDataAvailableListener.callAsFunction(
            null,
            createJSInteropWrapper(FakeBlobEvent(capturedVideoPartOne))
                as BlobEvent,
          );
          videoDataAvailableListener.callAsFunction(
            null,
            createJSInteropWrapper(FakeBlobEvent(capturedVideoPartTwo))
                as BlobEvent,
          );

          videoRecordingStoppedListener.callAsFunction(null, Event('stop'));

          final XFile videoFile = await videoFileFuture;

          expect(stops, 1);

          expect(
            videoFile,
            isNotNull,
          );

          expect(
            videoFile.mimeType,
            equals(supportedVideoType),
          );

          expect(
            videoFile.name,
            equals(finalVideo.hashCode.toString()),
          );

          expect(
            videoParts,
            equals(capturedVideoParts),
          );
        });

        testWidgets(
            'throws a CameraWebException '
            'with videoRecordingNotStarted error '
            'if the video recording was not started',
            (WidgetTester tester) async {
          final Camera camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          );

          expect(
            camera.stopVideoRecording,
            throwsA(
              isA<CameraWebException>()
                  .having(
                    (CameraWebException e) => e.cameraId,
                    'cameraId',
                    textureId,
                  )
                  .having(
                    (CameraWebException e) => e.code,
                    'code',
                    CameraErrorCode.videoRecordingNotStarted,
                  ),
            ),
          );
        });
      });

      group('on video recording stopped', () {
        late EventListener videoRecordingStoppedListener;

        setUp(() {
          mockMediaRecorder.addEventListener = (
            String type,
            EventListener? callback, [
            JSAny? options,
          ]) {
            if (type == 'stop') {
              videoRecordingStoppedListener = callback!;
            }
          }.toJS;
        });

        testWidgets('stops listening to the media recorder data events',
            (WidgetTester tester) async {
          final Camera camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )
            ..mediaRecorder = mediaRecorder
            ..isVideoTypeSupported = isVideoTypeSupported;

          await camera.initialize();
          await camera.play();

          await camera.startVideoRecording();

          final List<String> capturedEvents = <String>[];
          mockMediaRecorder.removeEventListener = (
            String type,
            EventListener? callback, [
            JSAny? options,
          ]) {
            capturedEvents.add(type);
          }.toJS;

          videoRecordingStoppedListener.callAsFunction(null, Event('stop'));

          await Future<void>.microtask(() {});

          expect(
            capturedEvents.where((String e) => e == 'dataavailable').length,
            1,
          );
        });

        testWidgets('stops listening to the media recorder stop events',
            (WidgetTester tester) async {
          final Camera camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )
            ..mediaRecorder = mediaRecorder
            ..isVideoTypeSupported = isVideoTypeSupported;

          await camera.initialize();
          await camera.play();

          await camera.startVideoRecording();

          final List<String> capturedEvents = <String>[];
          mockMediaRecorder.removeEventListener = (
            String type,
            EventListener? callback, [
            JSAny? options,
          ]) {
            capturedEvents.add(type);
          }.toJS;

          videoRecordingStoppedListener.callAsFunction(null, Event('stop'));

          await Future<void>.microtask(() {});

          expect(
            capturedEvents.where((String e) => e == 'stop').length,
            1,
          );
        });

        testWidgets('stops listening to the media recorder errors',
            (WidgetTester tester) async {
          final StreamController<ErrorEvent> onErrorStreamController =
              StreamController<ErrorEvent>();
          final MockEventStreamProvider<Event> provider =
              MockEventStreamProvider<Event>();

          final Camera camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )
            ..mediaRecorder = mediaRecorder
            ..isVideoTypeSupported = isVideoTypeSupported
            ..mediaRecorderOnErrorProvider = provider;

          when(() => provider.forTarget(mediaRecorder))
              .thenAnswer((_) => onErrorStreamController.stream);

          await camera.initialize();
          await camera.play();

          await camera.startVideoRecording();

          videoRecordingStoppedListener.callAsFunction(null, Event('stop'));

          await Future<void>.microtask(() {});

          expect(
            onErrorStreamController.hasListener,
            isFalse,
          );
        });
      });
    });

    group('dispose', () {
      testWidgets("resets the video element's source",
          (WidgetTester tester) async {
        final Camera camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();
        await camera.dispose();

        expect(camera.videoElement.srcObject, isNull);
      });

      testWidgets('closes the onEnded stream', (WidgetTester tester) async {
        final Camera camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();
        await camera.dispose();

        expect(
          camera.onEndedController.isClosed,
          isTrue,
        );
      });

      testWidgets('closes the onVideoRecordedEvent stream',
          (WidgetTester tester) async {
        final Camera camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();
        await camera.dispose();

        expect(
          camera.videoRecorderController.isClosed,
          isTrue,
        );
      });

      testWidgets('closes the onVideoRecordingError stream',
          (WidgetTester tester) async {
        final Camera camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();
        await camera.dispose();

        expect(
          camera.videoRecordingErrorController.isClosed,
          isTrue,
        );
      });
    });

    group('events', () {
      group('onVideoRecordedEvent', () {
        testWidgets(
            'emits a VideoRecordedEvent '
            'when a video recording is created', (WidgetTester tester) async {
          const String supportedVideoType = 'video/webm';

          final MockMediaRecorder mockMediaRecorder = MockMediaRecorder();
          final MediaRecorder mediaRecorder =
              createJSInteropWrapper(mockMediaRecorder) as MediaRecorder;

          final Camera camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )
            ..mediaRecorder = mediaRecorder
            ..isVideoTypeSupported = (String type) => type == 'video/webm';

          await camera.initialize();
          await camera.play();

          late EventListener videoDataAvailableListener;
          late EventListener videoRecordingStoppedListener;

          mockMediaRecorder.addEventListener = (
            String type,
            EventListener? callback, [
            JSAny? options,
          ]) {
            if (type == 'dataavailable') {
              videoDataAvailableListener = callback!;
            } else if (type == 'stop') {
              videoRecordingStoppedListener = callback!;
            }
          }.toJS;

          final StreamQueue<VideoRecordedEvent> streamQueue =
              StreamQueue<VideoRecordedEvent>(camera.onVideoRecordedEvent);

          await camera.startVideoRecording();

          Blob? finalVideo;
          camera.blobBuilder = (List<Blob> blobs, String videoType) {
            finalVideo = Blob(blobs.toJS, BlobPropertyBag(type: videoType));
            return finalVideo!;
          };

          videoDataAvailableListener.callAsFunction(
            null,
            createJSInteropWrapper(FakeBlobEvent(Blob(<JSAny>[].toJS))),
          );
          videoRecordingStoppedListener.callAsFunction(null, Event('stop'));

          expect(
            await streamQueue.next,
            equals(
              isA<VideoRecordedEvent>()
                  .having(
                    (VideoRecordedEvent e) => e.cameraId,
                    'cameraId',
                    textureId,
                  )
                  .having(
                    (VideoRecordedEvent e) => e.file,
                    'file',
                    isA<XFile>()
                        .having(
                          (XFile f) => f.mimeType,
                          'mimeType',
                          supportedVideoType,
                        )
                        .having(
                          (XFile f) => f.name,
                          'name',
                          finalVideo.hashCode.toString(),
                        ),
                  ),
            ),
          );

          await streamQueue.cancel();
        });
      });

      group('onEnded', () {
        testWidgets(
            'emits the default video track '
            'when it emits an ended event', (WidgetTester tester) async {
          final Camera camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          );

          final StreamQueue<MediaStreamTrack> streamQueue =
              StreamQueue<MediaStreamTrack>(camera.onEnded);

          await camera.initialize();

          final List<MediaStreamTrack> videoTracks =
              camera.stream!.getVideoTracks().toDart;
          final MediaStreamTrack defaultVideoTrack = videoTracks.first;

          defaultVideoTrack.dispatchEvent(Event('ended'));

          expect(
            await streamQueue.next,
            equals(defaultVideoTrack),
          );

          await streamQueue.cancel();
        });

        testWidgets(
            'emits the default video track '
            'when the camera is stopped', (WidgetTester tester) async {
          final Camera camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          );

          final StreamQueue<MediaStreamTrack> streamQueue =
              StreamQueue<MediaStreamTrack>(camera.onEnded);

          await camera.initialize();

          final List<MediaStreamTrack> videoTracks =
              camera.stream!.getVideoTracks().toDart;
          final MediaStreamTrack defaultVideoTrack = videoTracks.first;

          camera.stop();

          expect(
            await streamQueue.next,
            equals(defaultVideoTrack),
          );

          await streamQueue.cancel();
        });
      });

      group('onVideoRecordingError', () {
        testWidgets(
            'emits an ErrorEvent '
            'when the media recorder fails '
            'when recording a video', (WidgetTester tester) async {
          final MockMediaRecorder mockMediaRecorder = MockMediaRecorder();
          final MediaRecorder mediaRecorder =
              createJSInteropWrapper(mockMediaRecorder) as MediaRecorder;
          final StreamController<ErrorEvent> errorController =
              StreamController<ErrorEvent>();
          final MockEventStreamProvider<Event> provider =
              MockEventStreamProvider<Event>();

          final Camera camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          )
            ..mediaRecorder = mediaRecorder
            ..mediaRecorderOnErrorProvider = provider;

          when(() => provider.forTarget(mediaRecorder))
              .thenAnswer((_) => errorController.stream);

          final StreamQueue<ErrorEvent> streamQueue =
              StreamQueue<ErrorEvent>(camera.onVideoRecordingError);

          await camera.initialize();
          await camera.play();

          await camera.startVideoRecording();

          final ErrorEvent errorEvent = ErrorEvent('type');
          errorController.add(errorEvent);

          expect(
            await streamQueue.next,
            equals(errorEvent),
          );

          await streamQueue.cancel();
        });
      });
    });
  });
}
