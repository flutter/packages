// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: only_throw_errors

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:camera_platform_interface/camera_platform_interface.dart';
// ignore_for_file: implementation_imports
import 'package:camera_web/src/camera.dart';
import 'package:camera_web/src/camera_service.dart';
import 'package:camera_web/src/shims/dart_js_util.dart';
import 'package:camera_web/src/types/types.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web/web.dart' as web;

import 'helpers/helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('CameraService', () {
    const int cameraId = 1;

    late MockWindow mockWindow;
    late MockNavigator mockNavigator;
    late MockMediaDevices mockMediaDevices;

    late web.Window window;
    late web.Navigator navigator;
    late web.MediaDevices mediaDevices;

    late JsUtil jsUtil;

    late CameraService cameraService;

    setUp(() async {
      mockWindow = MockWindow();
      mockNavigator = MockNavigator();
      mockMediaDevices = MockMediaDevices();

      window = createJSInteropWrapper(mockWindow) as web.Window;
      navigator = createJSInteropWrapper(mockNavigator) as web.Navigator;
      mediaDevices =
          createJSInteropWrapper(mockMediaDevices) as web.MediaDevices;

      mockWindow.navigator = navigator;
      mockNavigator.mediaDevices = mediaDevices;

      jsUtil = MockJsUtil();

      registerFallbackValue(createJSInteropWrapper(MockWindow()));

      // Mock JsUtil to return the real getProperty from dart:js_util.
      when<dynamic>(() => jsUtil.getProperty(any(), any())).thenAnswer(
        (Invocation invocation) =>
            (invocation.positionalArguments[0] as JSObject)
                .getProperty(invocation.positionalArguments[1] as JSAny),
      );

      cameraService = CameraService()..window = window;
    });

    group('getMediaStreamForOptions', () {
      testWidgets(
          'calls MediaDevices.getUserMedia '
          'with provided options', (WidgetTester tester) async {
        late final web.MediaStreamConstraints? capturedConstraints;
        mockMediaDevices.getUserMedia =
            ([web.MediaStreamConstraints? constraints]) {
          capturedConstraints = constraints;
          final web.MediaStream stream =
              createJSInteropWrapper(FakeMediaStream(<web.MediaStreamTrack>[]))
                  as web.MediaStream;
          return Future<web.MediaStream>.value(stream).toJS;
        }.toJS;

        final CameraOptions options = CameraOptions(
          video: VideoConstraints(
            facingMode: FacingModeConstraint.exact(CameraType.user),
            width: const VideoSizeConstraint(ideal: 200),
          ),
        );

        await cameraService.getMediaStreamForOptions(options);

        expect(
          capturedConstraints?.video.dartify(),
          equals(options.video.toMediaStreamConstraints().dartify()),
        );
        expect(
          capturedConstraints?.audio.dartify(),
          equals(options.audio.toMediaStreamConstraints().dartify()),
        );
      });

      group('throws CameraWebException', () {
        testWidgets(
            'with notFound error '
            'when MediaDevices.getUserMedia throws DomException '
            'with NotFoundError', (WidgetTester tester) async {
          mockMediaDevices.getUserMedia = ([web.MediaStreamConstraints? _]) {
            throw web.DOMException('', 'NotFoundError');
            // ignore: dead_code
            return Future<web.MediaStream>.value(web.MediaStream()).toJS;
          }.toJS;

          expect(
            () => cameraService.getMediaStreamForOptions(
              const CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((CameraWebException e) => e.cameraId, 'cameraId',
                      cameraId)
                  .having((CameraWebException e) => e.code, 'code',
                      CameraErrorCode.notFound),
            ),
          );
        });

        testWidgets(
            'with notFound error '
            'when MediaDevices.getUserMedia throws DomException '
            'with DevicesNotFoundError', (WidgetTester tester) async {
          mockMediaDevices.getUserMedia = ([web.MediaStreamConstraints? _]) {
            throw web.DOMException('', 'DevicesNotFoundError');
            // ignore: dead_code
            return Future<web.MediaStream>.value(web.MediaStream()).toJS;
          }.toJS;

          expect(
            () => cameraService.getMediaStreamForOptions(
              const CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((CameraWebException e) => e.cameraId, 'cameraId',
                      cameraId)
                  .having((CameraWebException e) => e.code, 'code',
                      CameraErrorCode.notFound),
            ),
          );
        });

        testWidgets(
            'with notReadable error '
            'when MediaDevices.getUserMedia throws DomException '
            'with NotReadableError', (WidgetTester tester) async {
          mockMediaDevices.getUserMedia = ([web.MediaStreamConstraints? _]) {
            throw web.DOMException('', 'NotReadableError');
            // ignore: dead_code
            return Future<web.MediaStream>.value(web.MediaStream()).toJS;
          }.toJS;
          expect(
            () => cameraService.getMediaStreamForOptions(
              const CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((CameraWebException e) => e.cameraId, 'cameraId',
                      cameraId)
                  .having((CameraWebException e) => e.code, 'code',
                      CameraErrorCode.notReadable),
            ),
          );
        });

        testWidgets(
            'with notReadable error '
            'when MediaDevices.getUserMedia throws DomException '
            'with TrackStartError', (WidgetTester tester) async {
          mockMediaDevices.getUserMedia = ([web.MediaStreamConstraints? _]) {
            throw web.DOMException('', 'TrackStartError');
            // ignore: dead_code
            return Future<web.MediaStream>.value(web.MediaStream()).toJS;
          }.toJS;

          expect(
            () => cameraService.getMediaStreamForOptions(
              const CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((CameraWebException e) => e.cameraId, 'cameraId',
                      cameraId)
                  .having((CameraWebException e) => e.code, 'code',
                      CameraErrorCode.notReadable),
            ),
          );
        });

        testWidgets(
            'with overconstrained error '
            'when MediaDevices.getUserMedia throws DomException '
            'with OverconstrainedError', (WidgetTester tester) async {
          mockMediaDevices.getUserMedia = ([web.MediaStreamConstraints? _]) {
            throw web.DOMException('', 'OverconstrainedError');
            // ignore: dead_code
            return Future<web.MediaStream>.value(web.MediaStream()).toJS;
          }.toJS;

          expect(
            () => cameraService.getMediaStreamForOptions(
              const CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((CameraWebException e) => e.cameraId, 'cameraId',
                      cameraId)
                  .having((CameraWebException e) => e.code, 'code',
                      CameraErrorCode.overconstrained),
            ),
          );
        });

        testWidgets(
            'with overconstrained error '
            'when MediaDevices.getUserMedia throws DomException '
            'with ConstraintNotSatisfiedError', (WidgetTester tester) async {
          mockMediaDevices.getUserMedia = ([web.MediaStreamConstraints? _]) {
            throw web.DOMException('', 'ConstraintNotSatisfiedError');
            // ignore: dead_code
            return Future<web.MediaStream>.value(web.MediaStream()).toJS;
          }.toJS;

          expect(
            () => cameraService.getMediaStreamForOptions(
              const CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((CameraWebException e) => e.cameraId, 'cameraId',
                      cameraId)
                  .having((CameraWebException e) => e.code, 'code',
                      CameraErrorCode.overconstrained),
            ),
          );
        });

        testWidgets(
            'with permissionDenied error '
            'when MediaDevices.getUserMedia throws DomException '
            'with NotAllowedError', (WidgetTester tester) async {
          mockMediaDevices.getUserMedia = ([web.MediaStreamConstraints? _]) {
            throw web.DOMException('', 'NotAllowedError');
            // ignore: dead_code
            return Future<web.MediaStream>.value(web.MediaStream()).toJS;
          }.toJS;

          expect(
            () => cameraService.getMediaStreamForOptions(
              const CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((CameraWebException e) => e.cameraId, 'cameraId',
                      cameraId)
                  .having((CameraWebException e) => e.code, 'code',
                      CameraErrorCode.permissionDenied),
            ),
          );
        });

        testWidgets(
            'with permissionDenied error '
            'when MediaDevices.getUserMedia throws DomException '
            'with PermissionDeniedError', (WidgetTester tester) async {
          mockMediaDevices.getUserMedia = ([web.MediaStreamConstraints? _]) {
            throw web.DOMException('', 'PermissionDeniedError');
            // ignore: dead_code
            return Future<web.MediaStream>.value(web.MediaStream()).toJS;
          }.toJS;

          expect(
            () => cameraService.getMediaStreamForOptions(
              const CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((CameraWebException e) => e.cameraId, 'cameraId',
                      cameraId)
                  .having((CameraWebException e) => e.code, 'code',
                      CameraErrorCode.permissionDenied),
            ),
          );
        });

        testWidgets(
            'with type error '
            'when MediaDevices.getUserMedia throws DomException '
            'with TypeError', (WidgetTester tester) async {
          mockMediaDevices.getUserMedia = ([web.MediaStreamConstraints? _]) {
            throw web.DOMException('', 'TypeError');
            // ignore: dead_code
            return Future<web.MediaStream>.value(web.MediaStream()).toJS;
          }.toJS;

          expect(
            () => cameraService.getMediaStreamForOptions(
              const CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((CameraWebException e) => e.cameraId, 'cameraId',
                      cameraId)
                  .having((CameraWebException e) => e.code, 'code',
                      CameraErrorCode.type),
            ),
          );
        });

        testWidgets(
            'with abort error '
            'when MediaDevices.getUserMedia throws DomException '
            'with AbortError', (WidgetTester tester) async {
          mockMediaDevices.getUserMedia = ([web.MediaStreamConstraints? _]) {
            throw web.DOMException('', 'AbortError');
            // ignore: dead_code
            return Future<web.MediaStream>.value(web.MediaStream()).toJS;
          }.toJS;

          expect(
            () => cameraService.getMediaStreamForOptions(
              const CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((CameraWebException e) => e.cameraId, 'cameraId',
                      cameraId)
                  .having((CameraWebException e) => e.code, 'code',
                      CameraErrorCode.abort),
            ),
          );
        });

        testWidgets(
            'with security error '
            'when MediaDevices.getUserMedia throws DomException '
            'with SecurityError', (WidgetTester tester) async {
          mockMediaDevices.getUserMedia = ([web.MediaStreamConstraints? _]) {
            throw web.DOMException('', 'SecurityError');
            // ignore: dead_code
            return Future<web.MediaStream>.value(web.MediaStream()).toJS;
          }.toJS;

          expect(
            () => cameraService.getMediaStreamForOptions(
              const CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((CameraWebException e) => e.cameraId, 'cameraId',
                      cameraId)
                  .having((CameraWebException e) => e.code, 'code',
                      CameraErrorCode.security),
            ),
          );
        });

        testWidgets(
            'with unknown error '
            'when MediaDevices.getUserMedia throws DomException '
            'with an unknown error', (WidgetTester tester) async {
          mockMediaDevices.getUserMedia = ([web.MediaStreamConstraints? _]) {
            throw web.DOMException('', 'Unknown');
            // ignore: dead_code
            return Future<web.MediaStream>.value(web.MediaStream()).toJS;
          }.toJS;

          expect(
            () => cameraService.getMediaStreamForOptions(
              const CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((CameraWebException e) => e.cameraId, 'cameraId',
                      cameraId)
                  .having((CameraWebException e) => e.code, 'code',
                      CameraErrorCode.unknown),
            ),
          );
        });

        testWidgets(
            'with unknown error '
            'when MediaDevices.getUserMedia throws an unknown exception',
            (WidgetTester tester) async {
          mockMediaDevices.getUserMedia = ([web.MediaStreamConstraints? _]) {
            throw Exception();
            // ignore: dead_code
            return Future<web.MediaStream>.value(web.MediaStream()).toJS;
          }.toJS;

          expect(
            () => cameraService.getMediaStreamForOptions(
              const CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((CameraWebException e) => e.cameraId, 'cameraId',
                      cameraId)
                  .having((CameraWebException e) => e.code, 'code',
                      CameraErrorCode.unknown),
            ),
          );
        });
      });
    });

    group('getZoomLevelCapabilityForCamera', () {
      late Camera camera;
      late MockMediaStreamTrack mockVideoTrack;
      late List<web.MediaStreamTrack> videoTracks;

      setUp(() {
        camera = MockCamera();
        mockVideoTrack = MockMediaStreamTrack();
        videoTracks = <web.MediaStreamTrack>[
          createJSInteropWrapper(mockVideoTrack) as web.MediaStreamTrack,
          createJSInteropWrapper(MockMediaStreamTrack())
              as web.MediaStreamTrack,
        ];

        when(() => camera.textureId).thenReturn(0);
        when(() => camera.stream).thenReturn(
          createJSInteropWrapper(FakeMediaStream(videoTracks))
              as web.MediaStream,
        );

        cameraService.jsUtil = jsUtil;
      });

      testWidgets(
          'returns the zoom level capability '
          'based on the first video track', (WidgetTester tester) async {
        mockMediaDevices.getSupportedConstraints = () {
          return web.MediaTrackSupportedConstraints(zoom: true);
        }.toJS;

        mockVideoTrack.getCapabilities = () {
          return web.MediaTrackCapabilities(
            zoom: web.MediaSettingsRange(min: 100, max: 400, step: 2),
          );
        }.toJS;

        final ZoomLevelCapability zoomLevelCapability =
            cameraService.getZoomLevelCapabilityForCamera(camera);

        expect(zoomLevelCapability.minimum, equals(100.0));
        expect(zoomLevelCapability.maximum, equals(400.0));
        expect(zoomLevelCapability.videoTrack, equals(videoTracks.first));
      });

      group('throws CameraWebException', () {
        testWidgets(
            'with zoomLevelNotSupported error '
            'when the zoom level is not supported '
            'in the browser', (WidgetTester tester) async {
          mockMediaDevices.getSupportedConstraints = () {
            return web.MediaTrackSupportedConstraints(zoom: false);
          }.toJS;

          mockVideoTrack.getCapabilities = () {
            return web.MediaTrackCapabilities(
              zoom: web.MediaSettingsRange(min: 100, max: 400, step: 2),
            );
          }.toJS;

          expect(
            () => cameraService.getZoomLevelCapabilityForCamera(camera),
            throwsA(
              isA<CameraWebException>()
                  .having(
                    (CameraWebException e) => e.cameraId,
                    'cameraId',
                    camera.textureId,
                  )
                  .having(
                    (CameraWebException e) => e.code,
                    'code',
                    CameraErrorCode.zoomLevelNotSupported,
                  ),
            ),
          );
        });

        testWidgets(
            'with notStarted error '
            'when the camera stream has not been initialized',
            (WidgetTester tester) async {
          mockMediaDevices.getSupportedConstraints = () {
            return web.MediaTrackSupportedConstraints(zoom: true);
          }.toJS;

          // Create a camera stream with no video tracks.
          when(() => camera.stream).thenReturn(
            createJSInteropWrapper(FakeMediaStream(<web.MediaStreamTrack>[]))
                as web.MediaStream,
          );

          expect(
            () => cameraService.getZoomLevelCapabilityForCamera(camera),
            throwsA(
              isA<CameraWebException>()
                  .having(
                    (CameraWebException e) => e.cameraId,
                    'cameraId',
                    camera.textureId,
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

    group('getFacingModeForVideoTrack', () {
      setUp(() {
        cameraService.jsUtil = jsUtil;
      });

      testWidgets(
          'returns null '
          'when the facing mode is not supported', (WidgetTester tester) async {
        mockMediaDevices.getSupportedConstraints = () {
          return web.MediaTrackSupportedConstraints(facingMode: false);
        }.toJS;

        final String? facingMode = cameraService.getFacingModeForVideoTrack(
          createJSInteropWrapper(MockMediaStreamTrack())
              as web.MediaStreamTrack,
        );

        expect(facingMode, isNull);
      });

      group('when the facing mode is supported', () {
        late MockMediaStreamTrack mockVideoTrack;
        late web.MediaStreamTrack videoTrack;

        setUp(() {
          mockVideoTrack = MockMediaStreamTrack();
          videoTrack =
              createJSInteropWrapper(mockVideoTrack) as web.MediaStreamTrack;

          when(() => jsUtil.hasProperty(videoTrack, 'getCapabilities'.toJS))
              .thenReturn(true);

          mockMediaDevices.getSupportedConstraints = () {
            return web.MediaTrackSupportedConstraints(facingMode: true);
          }.toJS;
        });

        testWidgets(
            'returns an appropriate facing mode '
            'based on the video track settings', (WidgetTester tester) async {
          mockVideoTrack.getSettings = () {
            return web.MediaTrackSettings(facingMode: 'user');
          }.toJS;

          final String? facingMode =
              cameraService.getFacingModeForVideoTrack(videoTrack);

          expect(facingMode, equals('user'));
        });

        testWidgets(
            'returns an appropriate facing mode '
            'based on the video track capabilities '
            'when the facing mode setting is empty',
            (WidgetTester tester) async {
          mockVideoTrack.getSettings = () {
            return web.MediaTrackSettings(facingMode: '');
          }.toJS;
          mockVideoTrack.getCapabilities = () {
            return web.MediaTrackCapabilities(
              facingMode: <JSString>['environment'.toJS, 'left'.toJS].toJS,
            );
          }.toJS;

          when(() => jsUtil.hasProperty(videoTrack, 'getCapabilities'.toJS))
              .thenReturn(true);

          final String? facingMode =
              cameraService.getFacingModeForVideoTrack(videoTrack);

          expect(facingMode, equals('environment'));
        });

        testWidgets(
            'returns null '
            'when the facing mode setting '
            'and capabilities are empty', (WidgetTester tester) async {
          mockVideoTrack.getSettings = () {
            return web.MediaTrackSettings(facingMode: '');
          }.toJS;
          mockVideoTrack.getCapabilities = () {
            return web.MediaTrackCapabilities(facingMode: <JSString>[].toJS);
          }.toJS;

          final String? facingMode =
              cameraService.getFacingModeForVideoTrack(videoTrack);

          expect(facingMode, isNull);
        });

        testWidgets(
            'returns null '
            'when the facing mode setting is empty and '
            'the video track capabilities are not supported',
            (WidgetTester tester) async {
          mockVideoTrack.getSettings = () {
            return web.MediaTrackSettings(facingMode: '');
          }.toJS;

          when(() => jsUtil.hasProperty(videoTrack, 'getCapabilities'.toJS))
              .thenReturn(false);

          final String? facingMode =
              cameraService.getFacingModeForVideoTrack(videoTrack);

          expect(facingMode, isNull);
        });
      });
    });

    group('mapFacingModeToLensDirection', () {
      testWidgets(
          'returns front '
          'when the facing mode is user', (WidgetTester tester) async {
        expect(
          cameraService.mapFacingModeToLensDirection('user'),
          equals(CameraLensDirection.front),
        );
      });

      testWidgets(
          'returns back '
          'when the facing mode is environment', (WidgetTester tester) async {
        expect(
          cameraService.mapFacingModeToLensDirection('environment'),
          equals(CameraLensDirection.back),
        );
      });

      testWidgets(
          'returns external '
          'when the facing mode is left', (WidgetTester tester) async {
        expect(
          cameraService.mapFacingModeToLensDirection('left'),
          equals(CameraLensDirection.external),
        );
      });

      testWidgets(
          'returns external '
          'when the facing mode is right', (WidgetTester tester) async {
        expect(
          cameraService.mapFacingModeToLensDirection('right'),
          equals(CameraLensDirection.external),
        );
      });
    });

    group('mapFacingModeToCameraType', () {
      testWidgets(
          'returns user '
          'when the facing mode is user', (WidgetTester tester) async {
        expect(
          cameraService.mapFacingModeToCameraType('user'),
          equals(CameraType.user),
        );
      });

      testWidgets(
          'returns environment '
          'when the facing mode is environment', (WidgetTester tester) async {
        expect(
          cameraService.mapFacingModeToCameraType('environment'),
          equals(CameraType.environment),
        );
      });

      testWidgets(
          'returns user '
          'when the facing mode is left', (WidgetTester tester) async {
        expect(
          cameraService.mapFacingModeToCameraType('left'),
          equals(CameraType.user),
        );
      });

      testWidgets(
          'returns user '
          'when the facing mode is right', (WidgetTester tester) async {
        expect(
          cameraService.mapFacingModeToCameraType('right'),
          equals(CameraType.user),
        );
      });
    });

    group('mapResolutionPresetToSize', () {
      testWidgets(
          'returns 4096x2160 '
          'when the resolution preset is max', (WidgetTester tester) async {
        expect(
          cameraService.mapResolutionPresetToSize(ResolutionPreset.max),
          equals(const Size(4096, 2160)),
        );
      });

      testWidgets(
          'returns 4096x2160 '
          'when the resolution preset is ultraHigh',
          (WidgetTester tester) async {
        expect(
          cameraService.mapResolutionPresetToSize(ResolutionPreset.ultraHigh),
          equals(const Size(4096, 2160)),
        );
      });

      testWidgets(
          'returns 1920x1080 '
          'when the resolution preset is veryHigh',
          (WidgetTester tester) async {
        expect(
          cameraService.mapResolutionPresetToSize(ResolutionPreset.veryHigh),
          equals(const Size(1920, 1080)),
        );
      });

      testWidgets(
          'returns 1280x720 '
          'when the resolution preset is high', (WidgetTester tester) async {
        expect(
          cameraService.mapResolutionPresetToSize(ResolutionPreset.high),
          equals(const Size(1280, 720)),
        );
      });

      testWidgets(
          'returns 720x480 '
          'when the resolution preset is medium', (WidgetTester tester) async {
        expect(
          cameraService.mapResolutionPresetToSize(ResolutionPreset.medium),
          equals(const Size(720, 480)),
        );
      });

      testWidgets(
          'returns 320x240 '
          'when the resolution preset is low', (WidgetTester tester) async {
        expect(
          cameraService.mapResolutionPresetToSize(ResolutionPreset.low),
          equals(const Size(320, 240)),
        );
      });
    });

    group('mapDeviceOrientationToOrientationType', () {
      testWidgets(
          'returns portraitPrimary '
          'when the device orientation is portraitUp',
          (WidgetTester tester) async {
        expect(
          cameraService.mapDeviceOrientationToOrientationType(
            DeviceOrientation.portraitUp,
          ),
          equals(OrientationType.portraitPrimary),
        );
      });

      testWidgets(
          'returns landscapePrimary '
          'when the device orientation is landscapeLeft',
          (WidgetTester tester) async {
        expect(
          cameraService.mapDeviceOrientationToOrientationType(
            DeviceOrientation.landscapeLeft,
          ),
          equals(OrientationType.landscapePrimary),
        );
      });

      testWidgets(
          'returns portraitSecondary '
          'when the device orientation is portraitDown',
          (WidgetTester tester) async {
        expect(
          cameraService.mapDeviceOrientationToOrientationType(
            DeviceOrientation.portraitDown,
          ),
          equals(OrientationType.portraitSecondary),
        );
      });

      testWidgets(
          'returns landscapeSecondary '
          'when the device orientation is landscapeRight',
          (WidgetTester tester) async {
        expect(
          cameraService.mapDeviceOrientationToOrientationType(
            DeviceOrientation.landscapeRight,
          ),
          equals(OrientationType.landscapeSecondary),
        );
      });
    });

    group('mapOrientationTypeToDeviceOrientation', () {
      testWidgets(
          'returns portraitUp '
          'when the orientation type is portraitPrimary',
          (WidgetTester tester) async {
        expect(
          cameraService.mapOrientationTypeToDeviceOrientation(
            OrientationType.portraitPrimary,
          ),
          equals(DeviceOrientation.portraitUp),
        );
      });

      testWidgets(
          'returns landscapeLeft '
          'when the orientation type is landscapePrimary',
          (WidgetTester tester) async {
        expect(
          cameraService.mapOrientationTypeToDeviceOrientation(
            OrientationType.landscapePrimary,
          ),
          equals(DeviceOrientation.landscapeLeft),
        );
      });

      testWidgets(
          'returns portraitDown '
          'when the orientation type is portraitSecondary',
          (WidgetTester tester) async {
        expect(
          cameraService.mapOrientationTypeToDeviceOrientation(
            OrientationType.portraitSecondary,
          ),
          equals(DeviceOrientation.portraitDown),
        );
      });

      testWidgets(
          'returns portraitDown '
          'when the orientation type is portraitSecondary',
          (WidgetTester tester) async {
        expect(
          cameraService.mapOrientationTypeToDeviceOrientation(
            OrientationType.portraitSecondary,
          ),
          equals(DeviceOrientation.portraitDown),
        );
      });

      testWidgets(
          'returns landscapeRight '
          'when the orientation type is landscapeSecondary',
          (WidgetTester tester) async {
        expect(
          cameraService.mapOrientationTypeToDeviceOrientation(
            OrientationType.landscapeSecondary,
          ),
          equals(DeviceOrientation.landscapeRight),
        );
      });

      testWidgets(
          'returns portraitUp '
          'for an unknown orientation type', (WidgetTester tester) async {
        expect(
          cameraService.mapOrientationTypeToDeviceOrientation(
            'unknown',
          ),
          equals(DeviceOrientation.portraitUp),
        );
      });
    });
  });
}
