// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: only_throw_errors

import 'dart:async';
import 'dart:js_interop';
import 'dart:math';

import 'package:async/async.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/camera_web.dart';
// ignore_for_file: implementation_imports
import 'package:camera_web/src/camera.dart';
import 'package:camera_web/src/camera_service.dart';
import 'package:camera_web/src/types/types.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web/web.dart' hide MediaDeviceKind, OrientationType;

import 'helpers/helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('CameraPlugin', () {
    const int cameraId = 1;

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

    late CameraService cameraService;

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
      screenOrientation =
          createJSInteropWrapper(mockScreenOrientation) as ScreenOrientation;

      mockScreen.orientation = screenOrientation;
      mockWindow.screen = screen;

      mockDocument = MockDocument();
      mockDocumentElement = MockElement();

      document = createJSInteropWrapper(mockDocument) as Document;
      documentElement = createJSInteropWrapper(mockDocumentElement) as Element;

      mockDocument.documentElement = documentElement;
      mockWindow.document = document;

      cameraService = MockCameraService();

      registerFallbackValue(createJSInteropWrapper(MockWindow()));

      when(
        () => cameraService.getMediaStreamForOptions(
          any(),
          cameraId: any(named: 'cameraId'),
        ),
      ).thenAnswer(
        (_) async => videoElement.captureStream(),
      );

      CameraPlatform.instance = CameraPlugin(
        cameraService: cameraService,
      )..window = window;
    });

    setUpAll(() {
      registerFallbackValue(MockMediaStreamTrack());
      registerFallbackValue(MockCameraOptions());
      registerFallbackValue(FlashMode.off);
    });

    testWidgets('CameraPlugin is the live instance',
        (WidgetTester tester) async {
      expect(CameraPlatform.instance, isA<CameraPlugin>());
    });

    group('availableCameras', () {
      setUp(() {
        when(
          () => cameraService.getFacingModeForVideoTrack(
            any(),
          ),
        ).thenReturn(null);

        mockMediaDevices.enumerateDevices = () {
          return Future<JSArray<MediaDeviceInfo>>.value(
            <MediaDeviceInfo>[].toJS,
          ).toJS;
        }.toJS;
      });

      testWidgets('requests video permissions', (WidgetTester tester) async {
        final List<CameraDescription> _ =
            await CameraPlatform.instance.availableCameras();

        verify(
          () => cameraService.getMediaStreamForOptions(const CameraOptions()),
        ).called(1);
      });

      testWidgets(
          'releases the camera stream '
          'used to request video permissions', (WidgetTester tester) async {
        final MockMediaStreamTrack mockVideoTrack = MockMediaStreamTrack();
        final MediaStreamTrack videoTrack =
            createJSInteropWrapper(mockVideoTrack) as MediaStreamTrack;

        bool videoTrackStopped = false;
        mockVideoTrack.stop = () {
          videoTrackStopped = true;
        }.toJS;

        when(
          () => cameraService.getMediaStreamForOptions(const CameraOptions()),
        ).thenAnswer(
          (_) => Future<MediaStream>.value(
            createJSInteropWrapper(
              FakeMediaStream(<MediaStreamTrack>[videoTrack]),
            ) as MediaStream,
          ),
        );

        final List<CameraDescription> _ =
            await CameraPlatform.instance.availableCameras();

        expect(videoTrackStopped, isTrue);
      });

      testWidgets(
          'gets a video stream '
          'for a video input device', (WidgetTester tester) async {
        final MediaDeviceInfo videoDevice = createJSInteropWrapper(
          FakeMediaDeviceInfo(
            '1',
            'Camera 1',
            MediaDeviceKind.videoInput,
          ),
        ) as MediaDeviceInfo;

        mockMediaDevices.enumerateDevices = () {
          return Future<JSArray<MediaDeviceInfo>>.value(
                  <MediaDeviceInfo>[videoDevice].toJS)
              .toJS;
        }.toJS;

        final List<CameraDescription> _ =
            await CameraPlatform.instance.availableCameras();

        verify(
          () => cameraService.getMediaStreamForOptions(
            CameraOptions(
              video: VideoConstraints(
                deviceId: videoDevice.deviceId,
              ),
            ),
          ),
        ).called(1);
      });

      testWidgets(
          'does not get a video stream '
          'for the video input device '
          'with an empty device id', (WidgetTester tester) async {
        final MediaDeviceInfo videoDevice = createJSInteropWrapper(
          FakeMediaDeviceInfo(
            '',
            'Camera 1',
            MediaDeviceKind.videoInput,
          ),
        ) as MediaDeviceInfo;

        mockMediaDevices.enumerateDevices = () {
          return Future<JSArray<MediaDeviceInfo>>.value(
                  <MediaDeviceInfo>[videoDevice].toJS)
              .toJS;
        }.toJS;

        final List<CameraDescription> _ =
            await CameraPlatform.instance.availableCameras();

        verifyNever(
          () => cameraService.getMediaStreamForOptions(
            CameraOptions(
              video: VideoConstraints(
                deviceId: videoDevice.deviceId,
              ),
            ),
          ),
        );
      });

      testWidgets(
          'gets the facing mode '
          'from the first available video track '
          'of the video input device', (WidgetTester tester) async {
        final MediaDeviceInfo videoDevice = createJSInteropWrapper(
          FakeMediaDeviceInfo(
            '1',
            'Camera 1',
            MediaDeviceKind.videoInput,
          ),
        ) as MediaDeviceInfo;

        final MediaStream videoStream = createJSInteropWrapper(
          FakeMediaStream(
            <MediaStreamTrack>[
              createJSInteropWrapper(MockMediaStreamTrack())
                  as MediaStreamTrack,
              createJSInteropWrapper(MockMediaStreamTrack())
                  as MediaStreamTrack,
            ],
          ),
        ) as MediaStream;

        when(
          () => cameraService.getMediaStreamForOptions(
            CameraOptions(
              video: VideoConstraints(deviceId: videoDevice.deviceId),
            ),
          ),
        ).thenAnswer((Invocation _) => Future<MediaStream>.value(videoStream));

        mockMediaDevices.enumerateDevices = () {
          return Future<JSArray<MediaDeviceInfo>>.value(
                  <MediaDeviceInfo>[videoDevice].toJS)
              .toJS;
        }.toJS;

        final List<CameraDescription> _ =
            await CameraPlatform.instance.availableCameras();

        verify(
          () => cameraService.getFacingModeForVideoTrack(
            videoStream.getVideoTracks().toDart.first,
          ),
        ).called(1);
      });

      testWidgets(
          'returns appropriate camera descriptions '
          'for multiple video devices '
          'based on video streams', (WidgetTester tester) async {
        final MediaDeviceInfo firstVideoDevice = createJSInteropWrapper(
          FakeMediaDeviceInfo(
            '1',
            'Camera 1',
            MediaDeviceKind.videoInput,
          ),
        ) as MediaDeviceInfo;

        final MediaDeviceInfo secondVideoDevice = createJSInteropWrapper(
          FakeMediaDeviceInfo(
            '4',
            'Camera 4',
            MediaDeviceKind.videoInput,
          ),
        ) as MediaDeviceInfo;

        // Create a video stream for the first video device.
        final MediaStream firstVideoStream = createJSInteropWrapper(
          FakeMediaStream(
            <MediaStreamTrack>[
              createJSInteropWrapper(MockMediaStreamTrack())
                  as MediaStreamTrack,
              createJSInteropWrapper(MockMediaStreamTrack())
                  as MediaStreamTrack,
            ],
          ),
        ) as MediaStream;

        // Create a video stream for the second video device.
        final MediaStream secondVideoStream = createJSInteropWrapper(
          FakeMediaStream(
            <MediaStreamTrack>[
              createJSInteropWrapper(MockMediaStreamTrack())
                  as MediaStreamTrack,
            ],
          ),
        ) as MediaStream;

        // Mock media devices to return two video input devices
        // and two audio devices.
        mockMediaDevices.enumerateDevices = () {
          return Future<JSArray<MediaDeviceInfo>>.value(
            <MediaDeviceInfo>[
              firstVideoDevice,
              createJSInteropWrapper(
                FakeMediaDeviceInfo(
                  '2',
                  'Audio Input 2',
                  MediaDeviceKind.audioInput,
                ),
              ) as MediaDeviceInfo,
              createJSInteropWrapper(
                FakeMediaDeviceInfo(
                  '3',
                  'Audio Output 3',
                  MediaDeviceKind.audioOutput,
                ),
              ) as MediaDeviceInfo,
              secondVideoDevice,
            ].toJS,
          ).toJS;
        }.toJS;

        // Mock camera service to return the first video stream
        // for the first video device.
        when(
          () => cameraService.getMediaStreamForOptions(
            CameraOptions(
              video: VideoConstraints(deviceId: firstVideoDevice.deviceId),
            ),
          ),
        ).thenAnswer(
            (Invocation _) => Future<MediaStream>.value(firstVideoStream));

        // Mock camera service to return the second video stream
        // for the second video device.
        when(
          () => cameraService.getMediaStreamForOptions(
            CameraOptions(
              video: VideoConstraints(deviceId: secondVideoDevice.deviceId),
            ),
          ),
        ).thenAnswer(
            (Invocation _) => Future<MediaStream>.value(secondVideoStream));

        // Mock camera service to return a user facing mode
        // for the first video stream.
        when(
          () => cameraService.getFacingModeForVideoTrack(
            firstVideoStream.getVideoTracks().toDart.first,
          ),
        ).thenReturn('user');

        when(() => cameraService.mapFacingModeToLensDirection('user'))
            .thenReturn(CameraLensDirection.front);

        // Mock camera service to return an environment facing mode
        // for the second video stream.
        when(
          () => cameraService.getFacingModeForVideoTrack(
            secondVideoStream.getVideoTracks().toDart.first,
          ),
        ).thenReturn('environment');

        when(() => cameraService.mapFacingModeToLensDirection('environment'))
            .thenReturn(CameraLensDirection.back);

        final List<CameraDescription> cameras =
            await CameraPlatform.instance.availableCameras();

        // Expect two cameras and ignore two audio devices.
        expect(
          cameras,
          equals(<CameraDescription>[
            CameraDescription(
              name: firstVideoDevice.label,
              lensDirection: CameraLensDirection.front,
              sensorOrientation: 0,
            ),
            CameraDescription(
              name: secondVideoDevice.label,
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 0,
            )
          ]),
        );
      });

      testWidgets(
          'sets camera metadata '
          'for the camera description', (WidgetTester tester) async {
        final MediaDeviceInfo videoDevice = createJSInteropWrapper(
          FakeMediaDeviceInfo(
            '1',
            'Camera 1',
            MediaDeviceKind.videoInput,
          ),
        ) as MediaDeviceInfo;

        final MediaStream videoStream = createJSInteropWrapper(
          FakeMediaStream(
            <MediaStreamTrack>[
              createJSInteropWrapper(MockMediaStreamTrack())
                  as MediaStreamTrack,
              createJSInteropWrapper(MockMediaStreamTrack())
                  as MediaStreamTrack,
            ],
          ),
        ) as MediaStream;

        mockMediaDevices.enumerateDevices = () {
          return Future<JSArray<MediaDeviceInfo>>.value(
                  <MediaDeviceInfo>[videoDevice].toJS)
              .toJS;
        }.toJS;

        when(
          () => cameraService.getMediaStreamForOptions(
            CameraOptions(
              video: VideoConstraints(deviceId: videoDevice.deviceId),
            ),
          ),
        ).thenAnswer((Invocation _) => Future<MediaStream>.value(videoStream));

        when(
          () => cameraService.getFacingModeForVideoTrack(
            videoStream.getVideoTracks().toDart.first,
          ),
        ).thenReturn('left');

        when(() => cameraService.mapFacingModeToLensDirection('left'))
            .thenReturn(CameraLensDirection.external);

        final CameraDescription camera =
            (await CameraPlatform.instance.availableCameras()).first;

        expect(
          (CameraPlatform.instance as CameraPlugin).camerasMetadata,
          equals(<CameraDescription, CameraMetadata>{
            camera: CameraMetadata(
              deviceId: videoDevice.deviceId,
              facingMode: 'left',
            )
          }),
        );
      });

      testWidgets(
          'releases the video stream '
          'of a video input device', (WidgetTester tester) async {
        final MediaDeviceInfo videoDevice = createJSInteropWrapper(
          FakeMediaDeviceInfo(
            '1',
            'Camera 1',
            MediaDeviceKind.videoInput,
          ),
        ) as MediaDeviceInfo;

        final List<MediaStreamTrack> tracks = <MediaStreamTrack>[];
        final List<bool> stops = List<bool>.generate(2, (_) => false);
        for (int i = 0; i < stops.length; i++) {
          final MockMediaStreamTrack track = MockMediaStreamTrack();
          track.stop = () {
            stops[i] = true;
          }.toJS;
          tracks.add(createJSInteropWrapper(track) as MediaStreamTrack);
        }

        final MediaStream videoStream =
            createJSInteropWrapper(FakeMediaStream(tracks)) as MediaStream;

        mockMediaDevices.enumerateDevices = () {
          return Future<JSArray<MediaDeviceInfo>>.value(
                  <MediaDeviceInfo>[videoDevice].toJS)
              .toJS;
        }.toJS;

        when(
          () => cameraService.getMediaStreamForOptions(
            CameraOptions(
              video: VideoConstraints(deviceId: videoDevice.deviceId),
            ),
          ),
        ).thenAnswer((Invocation _) => Future<MediaStream>.value(videoStream));

        final List<CameraDescription> _ =
            await CameraPlatform.instance.availableCameras();

        expect(stops.every((bool e) => e), isTrue);
      });

      group('throws CameraException', () {
        testWidgets('when MediaDevices.enumerateDevices throws DomException',
            (WidgetTester tester) async {
          final DOMException exception = DOMException('UnknownError');

          mockMediaDevices.enumerateDevices = () {
            throw exception;
            // ignore: dead_code
            return Future<JSArray<MediaDeviceInfo>>.value(
              <MediaDeviceInfo>[].toJS,
            ).toJS;
          }.toJS;

          expect(
            () => CameraPlatform.instance.availableCameras(),
            throwsA(
              isA<CameraException>().having(
                (CameraException e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });

        testWidgets(
            'when CameraService.getMediaStreamForOptions '
            'throws CameraWebException', (WidgetTester tester) async {
          final CameraWebException exception = CameraWebException(
            cameraId,
            CameraErrorCode.security,
            'description',
          );

          when(() => cameraService.getMediaStreamForOptions(any()))
              .thenThrow(exception);

          expect(
            () => CameraPlatform.instance.availableCameras(),
            throwsA(
              isA<CameraException>().having(
                (CameraException e) => e.code,
                'code',
                exception.code.toString(),
              ),
            ),
          );
        });

        testWidgets(
            'when CameraService.getMediaStreamForOptions '
            'throws PlatformException', (WidgetTester tester) async {
          final PlatformException exception = PlatformException(
            code: CameraErrorCode.notSupported.toString(),
            message: 'message',
          );

          when(() => cameraService.getMediaStreamForOptions(any()))
              .thenThrow(exception);

          expect(
            () => CameraPlatform.instance.availableCameras(),
            throwsA(
              isA<CameraException>().having(
                (CameraException e) => e.code,
                'code',
                exception.code,
              ),
            ),
          );
        });
      });
    });

    group('createCamera', () {
      group('creates a camera', () {
        const Size ultraHighResolutionSize = Size(3840, 2160);
        const Size maxResolutionSize = Size(3840, 2160);

        const CameraDescription cameraDescription = CameraDescription(
          name: 'name',
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 0,
        );

        const CameraMetadata cameraMetadata = CameraMetadata(
          deviceId: 'deviceId',
          facingMode: 'user',
        );

        setUp(() {
          // Add metadata for the camera description.
          (CameraPlatform.instance as CameraPlugin)
              .camerasMetadata[cameraDescription] = cameraMetadata;

          when(
            () => cameraService.mapFacingModeToCameraType('user'),
          ).thenReturn(CameraType.user);
        });

        testWidgets('with appropriate options', (WidgetTester tester) async {
          when(
            () => cameraService
                .mapResolutionPresetToSize(ResolutionPreset.ultraHigh),
          ).thenReturn(ultraHighResolutionSize);

          final int cameraId = await CameraPlatform.instance.createCamera(
            cameraDescription,
            ResolutionPreset.ultraHigh,
            enableAudio: true,
          );

          final Camera? camera =
              (CameraPlatform.instance as CameraPlugin).cameras[cameraId];

          expect(camera, isA<Camera>());
          expect(camera!.textureId, cameraId);
          expect(camera.options.audio.enabled, isTrue);
          expect(camera.options.video.facingMode,
              equals(FacingModeConstraint(CameraType.user)));
          expect(camera.options.video.width!.ideal,
              ultraHighResolutionSize.width.toInt());
          expect(camera.options.video.height!.ideal,
              ultraHighResolutionSize.height.toInt());
          expect(camera.options.video.deviceId, cameraMetadata.deviceId);
        });

        testWidgets('with appropriate createCameraWithSettings options',
            (WidgetTester tester) async {
          when(
            () => cameraService
                .mapResolutionPresetToSize(ResolutionPreset.ultraHigh),
          ).thenReturn(ultraHighResolutionSize);

          final int cameraId =
              await CameraPlatform.instance.createCameraWithSettings(
            cameraDescription,
            const MediaSettings(
              resolutionPreset: ResolutionPreset.ultraHigh,
              videoBitrate: 200000,
              audioBitrate: 32000,
              enableAudio: true,
            ),
          );

          final Camera? camera =
              (CameraPlatform.instance as CameraPlugin).cameras[cameraId];

          expect(camera, isA<Camera>());
          expect(camera!.textureId, cameraId);
          expect(camera.options.audio.enabled, isTrue);
          expect(camera.options.video.facingMode,
              equals(FacingModeConstraint(CameraType.user)));
          expect(camera.options.video.width!.ideal,
              ultraHighResolutionSize.width.toInt());
          expect(camera.options.video.height!.ideal,
              ultraHighResolutionSize.height.toInt());
          expect(camera.options.video.deviceId, cameraMetadata.deviceId);
        });

        testWidgets(
            'with a max resolution preset '
            'and enabled audio set to false '
            'when no options are specified', (WidgetTester tester) async {
          when(
            () => cameraService.mapResolutionPresetToSize(ResolutionPreset.max),
          ).thenReturn(maxResolutionSize);

          final int cameraId = await CameraPlatform.instance.createCamera(
            cameraDescription,
            null,
          );

          final Camera? camera =
              (CameraPlatform.instance as CameraPlugin).cameras[cameraId];

          expect(camera, isA<Camera>());
          expect(camera!.textureId, cameraId);
          expect(camera.options.audio.enabled, isFalse);
          expect(camera.options.video.facingMode,
              equals(FacingModeConstraint(CameraType.user)));
          expect(camera.options.video.width!.ideal,
              maxResolutionSize.width.toInt());
          expect(camera.options.video.height!.ideal,
              maxResolutionSize.height.toInt());
          expect(camera.options.video.deviceId, cameraMetadata.deviceId);
        });

        testWidgets(
            'with a max resolution preset '
            'and enabled audio set to false '
            'when no options are specified '
            'using createCameraWithSettings', (WidgetTester tester) async {
          when(
            () => cameraService.mapResolutionPresetToSize(ResolutionPreset.max),
          ).thenReturn(maxResolutionSize);

          final int cameraId =
              await CameraPlatform.instance.createCameraWithSettings(
            cameraDescription,
            const MediaSettings(
              resolutionPreset: ResolutionPreset.max,
            ),
          );

          final Camera? camera =
              (CameraPlatform.instance as CameraPlugin).cameras[cameraId];

          expect(camera, isA<Camera>());
          expect(camera!.options.audio.enabled, isFalse);
          expect(camera.options.video.facingMode,
              equals(FacingModeConstraint(CameraType.user)));
          expect(camera.options.video.width!.ideal,
              maxResolutionSize.width.toInt());
          expect(camera.options.video.height!.ideal,
              maxResolutionSize.height.toInt());
          expect(camera.options.video.deviceId, cameraMetadata.deviceId);
        });
      });

      testWidgets(
          'throws CameraException '
          'with missingMetadata error '
          'if there is no metadata '
          'for the given camera description', (WidgetTester tester) async {
        expect(
          () => CameraPlatform.instance.createCamera(
            const CameraDescription(
              name: 'name',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 0,
            ),
            ResolutionPreset.ultraHigh,
          ),
          throwsA(
            isA<CameraException>().having(
              (CameraException e) => e.code,
              'code',
              CameraErrorCode.missingMetadata.toString(),
            ),
          ),
        );
      });

      testWidgets(
          'throws CameraException '
          'with missingMetadata error '
          'if there is no metadata '
          'for the given camera description '
          'using createCameraWithSettings', (WidgetTester tester) async {
        expect(
          () => CameraPlatform.instance.createCameraWithSettings(
            const CameraDescription(
              name: 'name',
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
          ),
          throwsA(
            isA<CameraException>().having(
              (CameraException e) => e.code,
              'code',
              CameraErrorCode.missingMetadata.toString(),
            ),
          ),
        );
      });
    });

    group('initializeCamera', () {
      late Camera camera;
      late MockVideoElement mockVideoElement;
      late HTMLVideoElement videoElement;

      late StreamController<Event> errorStreamController, abortStreamController;
      late StreamController<MediaStreamTrack> endedStreamController;

      setUp(() {
        camera = MockCamera();
        mockVideoElement = MockVideoElement();
        videoElement =
            createJSInteropWrapper(mockVideoElement) as HTMLVideoElement;

        errorStreamController = StreamController<Event>();
        abortStreamController = StreamController<Event>();
        endedStreamController = StreamController<MediaStreamTrack>();

        when(camera.getVideoSize).thenReturn(const Size(10, 10));
        when(camera.initialize)
            .thenAnswer((Invocation _) => Future<void>.value());
        when(camera.play).thenAnswer((Invocation _) => Future<void>.value());

        when(() => camera.videoElement).thenReturn(videoElement);

        final MockEventStreamProvider<Event> errorProvider =
            MockEventStreamProvider<Event>();
        final MockEventStreamProvider<Event> abortProvider =
            MockEventStreamProvider<Event>();

        (CameraPlatform.instance as CameraPlugin).videoElementOnErrorProvider =
            errorProvider;
        (CameraPlatform.instance as CameraPlugin).videoElementOnAbortProvider =
            abortProvider;

        when(() => errorProvider.forElement(videoElement)).thenAnswer(
          (_) => FakeElementStream<Event>(errorStreamController.stream),
        );
        when(() => abortProvider.forElement(videoElement)).thenAnswer(
          (_) => FakeElementStream<Event>(abortStreamController.stream),
        );

        when(() => camera.onEnded)
            .thenAnswer((Invocation _) => endedStreamController.stream);
      });

      testWidgets('initializes and plays the camera',
          (WidgetTester tester) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.initializeCamera(cameraId);

        verify(camera.initialize).called(1);
        verify(camera.play).called(1);
      });

      testWidgets('starts listening to the camera video error and abort events',
          (WidgetTester tester) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        expect(errorStreamController.hasListener, isFalse);
        expect(abortStreamController.hasListener, isFalse);

        await CameraPlatform.instance.initializeCamera(cameraId);

        expect(errorStreamController.hasListener, isTrue);
        expect(abortStreamController.hasListener, isTrue);
      });

      testWidgets('starts listening to the camera ended events',
          (WidgetTester tester) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        expect(endedStreamController.hasListener, isFalse);

        await CameraPlatform.instance.initializeCamera(cameraId);

        expect(endedStreamController.hasListener, isTrue);
      });

      group('throws PlatformException', () {
        testWidgets(
            'with notFound error '
            'if the camera does not exist', (WidgetTester tester) async {
          expect(
            () => CameraPlatform.instance.initializeCamera(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when camera throws CameraWebException',
            (WidgetTester tester) async {
          final CameraWebException exception = CameraWebException(
            cameraId,
            CameraErrorCode.permissionDenied,
            'description',
          );

          when(camera.initialize).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.initializeCamera(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                exception.code.toString(),
              ),
            ),
          );
        });

        testWidgets('when camera throws DomException',
            (WidgetTester tester) async {
          final DOMException exception = DOMException('NotAllowedError');

          when(camera.initialize)
              .thenAnswer((Invocation _) => Future<void>.value());
          when(camera.play).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.initializeCamera(cameraId),
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

    group('lockCaptureOrientation', () {
      setUp(() {
        registerFallbackValue(DeviceOrientation.portraitUp);
        when(
          () => cameraService.mapDeviceOrientationToOrientationType(any()),
        ).thenReturn(OrientationType.portraitPrimary);
      });

      testWidgets(
          'requests full-screen mode '
          'on documentElement', (WidgetTester tester) async {
        int fullscreenCalls = 0;
        mockDocumentElement.requestFullscreen = ([FullscreenOptions? options]) {
          fullscreenCalls++;
          return Future<void>.value().toJS;
        }.toJS;

        await CameraPlatform.instance.lockCaptureOrientation(
          cameraId,
          DeviceOrientation.portraitUp,
        );

        expect(fullscreenCalls, 1);
      });

      testWidgets(
          'locks the capture orientation '
          'based on the given device orientation', (WidgetTester tester) async {
        when(
          () => cameraService.mapDeviceOrientationToOrientationType(
            DeviceOrientation.landscapeRight,
          ),
        ).thenReturn(OrientationType.landscapeSecondary);

        final List<OrientationLockType> capturedTypes = <OrientationLockType>[];
        mockScreenOrientation.lock = (OrientationLockType orientation) {
          capturedTypes.add(orientation);
          return Future<void>.value().toJS;
        }.toJS;

        await CameraPlatform.instance.lockCaptureOrientation(
          cameraId,
          DeviceOrientation.landscapeRight,
        );

        verify(
          () => cameraService.mapDeviceOrientationToOrientationType(
            DeviceOrientation.landscapeRight,
          ),
        ).called(1);

        expect(capturedTypes.length, 1);
        expect(capturedTypes[0], OrientationType.landscapeSecondary);
      });

      group('throws PlatformException', () {
        testWidgets(
            'with orientationNotSupported error '
            'when documentElement is not available',
            (WidgetTester tester) async {
          mockDocument.documentElement = null;

          expect(
            () => CameraPlatform.instance.lockCaptureOrientation(
              cameraId,
              DeviceOrientation.portraitUp,
            ),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                CameraErrorCode.orientationNotSupported.toString(),
              ),
            ),
          );

          mockDocument.documentElement = documentElement;
        });

        testWidgets('when lock throws DomException',
            (WidgetTester tester) async {
          final DOMException exception = DOMException('NotAllowedError');

          mockScreenOrientation.lock = (OrientationLockType orientation) {
            throw exception;
            // ignore: dead_code
            return Future<void>.value().toJS;
          }.toJS;

          expect(
            () => CameraPlatform.instance.lockCaptureOrientation(
              cameraId,
              DeviceOrientation.portraitDown,
            ),
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

    group('unlockCaptureOrientation', () {
      setUp(() {
        when(
          () => cameraService.mapDeviceOrientationToOrientationType(any()),
        ).thenReturn(OrientationType.portraitPrimary);
      });

      testWidgets('unlocks the capture orientation',
          (WidgetTester tester) async {
        int unlocks = 0;
        mockScreenOrientation.unlock = () {
          unlocks++;
        }.toJS;

        await CameraPlatform.instance.unlockCaptureOrientation(
          cameraId,
        );

        expect(unlocks, 1);
      });

      group('throws PlatformException', () {
        testWidgets(
            'with orientationNotSupported error '
            'when documentElement is not available',
            (WidgetTester tester) async {
          mockDocument.documentElement = null;

          expect(
            () => CameraPlatform.instance.unlockCaptureOrientation(
              cameraId,
            ),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                CameraErrorCode.orientationNotSupported.toString(),
              ),
            ),
          );

          mockDocument.documentElement = documentElement;
        });

        testWidgets('when unlock throws DomException',
            (WidgetTester tester) async {
          final DOMException exception = DOMException('NotAllowedError');

          mockScreenOrientation.unlock = () {
            throw exception;
            // ignore: dead_code
            return Future<void>.value().toJS;
          }.toJS;

          expect(
            () => CameraPlatform.instance.unlockCaptureOrientation(
              cameraId,
            ),
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

    group('takePicture', () {
      testWidgets('captures a picture', (WidgetTester tester) async {
        final MockCamera camera = MockCamera();
        final XFile capturedPicture = XFile('/bogus/test');

        when(camera.takePicture)
            .thenAnswer((Invocation _) async => capturedPicture);

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        final XFile picture =
            await CameraPlatform.instance.takePicture(cameraId);

        verify(camera.takePicture).called(1);

        expect(picture, equals(capturedPicture));
      });

      group('throws PlatformException', () {
        testWidgets(
            'with notFound error '
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

        testWidgets('when takePicture throws DomException',
            (WidgetTester tester) async {
          final MockCamera camera = MockCamera();
          final DOMException exception = DOMException('NotSupportedError');

          when(camera.takePicture).thenThrow(exception);

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

        testWidgets('when takePicture throws CameraWebException',
            (WidgetTester tester) async {
          final MockCamera camera = MockCamera();
          final CameraWebException exception = CameraWebException(
            cameraId,
            CameraErrorCode.notStarted,
            'description',
          );

          when(camera.takePicture).thenThrow(exception);

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

        when(camera.startVideoRecording).thenAnswer((Invocation _) async {});

        when(() => camera.onVideoRecordingError)
            .thenAnswer((Invocation _) => const Stream<ErrorEvent>.empty());
      });

      testWidgets('starts a video recording', (WidgetTester tester) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.startVideoRecording(cameraId);

        verify(camera.startVideoRecording).called(1);
      });

      testWidgets('listens to the onVideoRecordingError stream',
          (WidgetTester tester) async {
        final StreamController<ErrorEvent> videoRecordingErrorController =
            StreamController<ErrorEvent>();

        when(() => camera.onVideoRecordingError)
            .thenAnswer((Invocation _) => videoRecordingErrorController.stream);

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.startVideoRecording(cameraId);

        expect(
          videoRecordingErrorController.hasListener,
          isTrue,
        );
      });

      group('throws PlatformException', () {
        testWidgets(
            'with notFound error '
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

        testWidgets('when startVideoRecording throws DomException',
            (WidgetTester tester) async {
          final DOMException exception = DOMException('InvalidStateError');

          when(camera.startVideoRecording).thenThrow(exception);

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

        testWidgets('when startVideoRecording throws CameraWebException',
            (WidgetTester tester) async {
          final CameraWebException exception = CameraWebException(
            cameraId,
            CameraErrorCode.notStarted,
            'description',
          );

          when(camera.startVideoRecording).thenThrow(exception);

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

        when(camera.startVideoRecording).thenAnswer((Invocation _) async {});

        when(() => camera.onVideoRecordingError)
            .thenAnswer((Invocation _) => const Stream<ErrorEvent>.empty());
      });

      testWidgets('fails if trying to stream', (WidgetTester tester) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        expect(
          () => CameraPlatform.instance.startVideoCapturing(VideoCaptureOptions(
              cameraId,
              streamCallback: (CameraImageData imageData) {})),
          throwsA(
            isA<UnimplementedError>(),
          ),
        );
      });
    });

    group('stopVideoRecording', () {
      testWidgets('stops a video recording', (WidgetTester tester) async {
        final MockCamera camera = MockCamera();
        final XFile capturedVideo = XFile('/bogus/test');

        when(camera.stopVideoRecording)
            .thenAnswer((Invocation _) async => capturedVideo);

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        final XFile video =
            await CameraPlatform.instance.stopVideoRecording(cameraId);

        verify(camera.stopVideoRecording).called(1);

        expect(video, capturedVideo);
      });

      testWidgets('stops listening to the onVideoRecordingError stream',
          (WidgetTester tester) async {
        final MockCamera camera = MockCamera();
        final StreamController<ErrorEvent> videoRecordingErrorController =
            StreamController<ErrorEvent>();
        final XFile capturedVideo = XFile('/bogus/test');

        when(camera.startVideoRecording).thenAnswer((Invocation _) async {});

        when(camera.stopVideoRecording)
            .thenAnswer((Invocation _) async => capturedVideo);

        when(() => camera.onVideoRecordingError)
            .thenAnswer((Invocation _) => videoRecordingErrorController.stream);

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.startVideoRecording(cameraId);
        final XFile _ =
            await CameraPlatform.instance.stopVideoRecording(cameraId);

        expect(
          videoRecordingErrorController.hasListener,
          isFalse,
        );
      });

      group('throws PlatformException', () {
        testWidgets(
            'with notFound error '
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

        testWidgets('when stopVideoRecording throws DomException',
            (WidgetTester tester) async {
          final MockCamera camera = MockCamera();
          final DOMException exception = DOMException('InvalidStateError');

          when(camera.stopVideoRecording).thenThrow(exception);

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

        testWidgets('when stopVideoRecording throws CameraWebException',
            (WidgetTester tester) async {
          final MockCamera camera = MockCamera();
          final CameraWebException exception = CameraWebException(
            cameraId,
            CameraErrorCode.notStarted,
            'description',
          );

          when(camera.stopVideoRecording).thenThrow(exception);

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
        final MockCamera camera = MockCamera();

        when(camera.pauseVideoRecording).thenAnswer((Invocation _) async {});

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.pauseVideoRecording(cameraId);

        verify(camera.pauseVideoRecording).called(1);
      });

      group('throws PlatformException', () {
        testWidgets(
            'with notFound error '
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

        testWidgets('when pauseVideoRecording throws DomException',
            (WidgetTester tester) async {
          final MockCamera camera = MockCamera();
          final DOMException exception = DOMException('InvalidStateError');

          when(camera.pauseVideoRecording).thenThrow(exception);

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

        testWidgets('when pauseVideoRecording throws CameraWebException',
            (WidgetTester tester) async {
          final MockCamera camera = MockCamera();
          final CameraWebException exception = CameraWebException(
            cameraId,
            CameraErrorCode.notStarted,
            'description',
          );

          when(camera.pauseVideoRecording).thenThrow(exception);

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
        final MockCamera camera = MockCamera();

        when(camera.resumeVideoRecording).thenAnswer((Invocation _) async {});

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.resumeVideoRecording(cameraId);

        verify(camera.resumeVideoRecording).called(1);
      });

      group('throws PlatformException', () {
        testWidgets(
            'with notFound error '
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

        testWidgets('when resumeVideoRecording throws DomException',
            (WidgetTester tester) async {
          final MockCamera camera = MockCamera();
          final DOMException exception = DOMException('InvalidStateError');

          when(camera.resumeVideoRecording).thenThrow(exception);

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

        testWidgets('when resumeVideoRecording throws CameraWebException',
            (WidgetTester tester) async {
          final MockCamera camera = MockCamera();
          final CameraWebException exception = CameraWebException(
            cameraId,
            CameraErrorCode.notStarted,
            'description',
          );

          when(camera.resumeVideoRecording).thenThrow(exception);

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

    group('setFlashMode', () {
      testWidgets('calls setFlashMode on the camera',
          (WidgetTester tester) async {
        final MockCamera camera = MockCamera();
        const FlashMode flashMode = FlashMode.always;

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.setFlashMode(
          cameraId,
          flashMode,
        );

        verify(() => camera.setFlashMode(flashMode)).called(1);
      });

      group('throws PlatformException', () {
        testWidgets(
            'with notFound error '
            'if the camera does not exist', (WidgetTester tester) async {
          expect(
            () => CameraPlatform.instance.setFlashMode(
              cameraId,
              FlashMode.always,
            ),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when setFlashMode throws DomException',
            (WidgetTester tester) async {
          final MockCamera camera = MockCamera();
          final DOMException exception = DOMException('NotSupportedError');

          when(() => camera.setFlashMode(any())).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.setFlashMode(
              cameraId,
              FlashMode.always,
            ),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });

        testWidgets('when setFlashMode throws CameraWebException',
            (WidgetTester tester) async {
          final MockCamera camera = MockCamera();
          final CameraWebException exception = CameraWebException(
            cameraId,
            CameraErrorCode.notStarted,
            'description',
          );

          when(() => camera.setFlashMode(any())).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.setFlashMode(
              cameraId,
              FlashMode.torch,
            ),
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

    testWidgets('setExposureMode throws UnimplementedError',
        (WidgetTester tester) async {
      expect(
        () => CameraPlatform.instance.setExposureMode(
          cameraId,
          ExposureMode.auto,
        ),
        throwsUnimplementedError,
      );
    });

    testWidgets('setExposurePoint throws UnimplementedError',
        (WidgetTester tester) async {
      expect(
        () => CameraPlatform.instance.setExposurePoint(
          cameraId,
          const Point<double>(0, 0),
        ),
        throwsUnimplementedError,
      );
    });

    testWidgets('getMinExposureOffset throws UnimplementedError',
        (WidgetTester tester) async {
      expect(
        () => CameraPlatform.instance.getMinExposureOffset(cameraId),
        throwsUnimplementedError,
      );
    });

    testWidgets('getMaxExposureOffset throws UnimplementedError',
        (WidgetTester tester) async {
      expect(
        () => CameraPlatform.instance.getMaxExposureOffset(cameraId),
        throwsUnimplementedError,
      );
    });

    testWidgets('getExposureOffsetStepSize throws UnimplementedError',
        (WidgetTester tester) async {
      expect(
        () => CameraPlatform.instance.getExposureOffsetStepSize(cameraId),
        throwsUnimplementedError,
      );
    });

    testWidgets('setExposureOffset throws UnimplementedError',
        (WidgetTester tester) async {
      expect(
        () => CameraPlatform.instance.setExposureOffset(
          cameraId,
          0,
        ),
        throwsUnimplementedError,
      );
    });

    testWidgets('setFocusMode throws UnimplementedError',
        (WidgetTester tester) async {
      expect(
        () => CameraPlatform.instance.setFocusMode(
          cameraId,
          FocusMode.auto,
        ),
        throwsUnimplementedError,
      );
    });

    testWidgets('setFocusPoint throws UnimplementedError',
        (WidgetTester tester) async {
      expect(
        () => CameraPlatform.instance.setFocusPoint(
          cameraId,
          const Point<double>(0, 0),
        ),
        throwsUnimplementedError,
      );
    });

    group('getMaxZoomLevel', () {
      testWidgets('calls getMaxZoomLevel on the camera',
          (WidgetTester tester) async {
        final MockCamera camera = MockCamera();
        const double maximumZoomLevel = 100.0;

        when(camera.getMaxZoomLevel).thenReturn(maximumZoomLevel);

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        expect(
          await CameraPlatform.instance.getMaxZoomLevel(
            cameraId,
          ),
          equals(maximumZoomLevel),
        );

        verify(camera.getMaxZoomLevel).called(1);
      });

      group('throws PlatformException', () {
        testWidgets(
            'with notFound error '
            'if the camera does not exist', (WidgetTester tester) async {
          expect(
            () async => CameraPlatform.instance.getMaxZoomLevel(
              cameraId,
            ),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when getMaxZoomLevel throws DomException',
            (WidgetTester tester) async {
          final MockCamera camera = MockCamera();
          final DOMException exception = DOMException('NotSupportedError');

          when(camera.getMaxZoomLevel).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => CameraPlatform.instance.getMaxZoomLevel(
              cameraId,
            ),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });

        testWidgets('when getMaxZoomLevel throws CameraWebException',
            (WidgetTester tester) async {
          final MockCamera camera = MockCamera();
          final CameraWebException exception = CameraWebException(
            cameraId,
            CameraErrorCode.notStarted,
            'description',
          );

          when(camera.getMaxZoomLevel).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => CameraPlatform.instance.getMaxZoomLevel(
              cameraId,
            ),
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

    group('getMinZoomLevel', () {
      testWidgets('calls getMinZoomLevel on the camera',
          (WidgetTester tester) async {
        final MockCamera camera = MockCamera();
        const double minimumZoomLevel = 100.0;

        when(camera.getMinZoomLevel).thenReturn(minimumZoomLevel);

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        expect(
          await CameraPlatform.instance.getMinZoomLevel(
            cameraId,
          ),
          equals(minimumZoomLevel),
        );

        verify(camera.getMinZoomLevel).called(1);
      });

      group('throws PlatformException', () {
        testWidgets(
            'with notFound error '
            'if the camera does not exist', (WidgetTester tester) async {
          expect(
            () async => CameraPlatform.instance.getMinZoomLevel(
              cameraId,
            ),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when getMinZoomLevel throws DomException',
            (WidgetTester tester) async {
          final MockCamera camera = MockCamera();
          final DOMException exception = DOMException('NotSupportedError');

          when(camera.getMinZoomLevel).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => CameraPlatform.instance.getMinZoomLevel(
              cameraId,
            ),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });

        testWidgets('when getMinZoomLevel throws CameraWebException',
            (WidgetTester tester) async {
          final MockCamera camera = MockCamera();
          final CameraWebException exception = CameraWebException(
            cameraId,
            CameraErrorCode.notStarted,
            'description',
          );

          when(camera.getMinZoomLevel).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => CameraPlatform.instance.getMinZoomLevel(
              cameraId,
            ),
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

    group('setZoomLevel', () {
      testWidgets('calls setZoomLevel on the camera',
          (WidgetTester tester) async {
        final MockCamera camera = MockCamera();

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        const double zoom = 100.0;

        await CameraPlatform.instance.setZoomLevel(cameraId, zoom);

        verify(() => camera.setZoomLevel(zoom)).called(1);
      });

      group('throws CameraException', () {
        testWidgets(
            'with notFound error '
            'if the camera does not exist', (WidgetTester tester) async {
          expect(
            () async => CameraPlatform.instance.setZoomLevel(
              cameraId,
              100.0,
            ),
            throwsA(
              isA<CameraException>().having(
                (CameraException e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when setZoomLevel throws DomException',
            (WidgetTester tester) async {
          final MockCamera camera = MockCamera();
          final DOMException exception = DOMException('NotSupportedError');

          when(() => camera.setZoomLevel(any())).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => CameraPlatform.instance.setZoomLevel(
              cameraId,
              100.0,
            ),
            throwsA(
              isA<CameraException>().having(
                (CameraException e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });

        testWidgets('when setZoomLevel throws PlatformException',
            (WidgetTester tester) async {
          final MockCamera camera = MockCamera();
          final PlatformException exception = PlatformException(
            code: CameraErrorCode.notSupported.toString(),
            message: 'message',
          );

          when(() => camera.setZoomLevel(any())).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => CameraPlatform.instance.setZoomLevel(
              cameraId,
              100.0,
            ),
            throwsA(
              isA<CameraException>().having(
                (CameraException e) => e.code,
                'code',
                exception.code,
              ),
            ),
          );
        });

        testWidgets('when setZoomLevel throws CameraWebException',
            (WidgetTester tester) async {
          final MockCamera camera = MockCamera();
          final CameraWebException exception = CameraWebException(
            cameraId,
            CameraErrorCode.notStarted,
            'description',
          );

          when(() => camera.setZoomLevel(any())).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => CameraPlatform.instance.setZoomLevel(
              cameraId,
              100.0,
            ),
            throwsA(
              isA<CameraException>().having(
                (CameraException e) => e.code,
                'code',
                exception.code.toString(),
              ),
            ),
          );
        });
      });
    });

    group('pausePreview', () {
      testWidgets('calls pause on the camera', (WidgetTester tester) async {
        final MockCamera camera = MockCamera();

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.pausePreview(cameraId);

        verify(camera.pause).called(1);
      });

      group('throws PlatformException', () {
        testWidgets(
            'with notFound error '
            'if the camera does not exist', (WidgetTester tester) async {
          expect(
            () async => CameraPlatform.instance.pausePreview(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when pause throws DomException',
            (WidgetTester tester) async {
          final MockCamera camera = MockCamera();
          final DOMException exception = DOMException('NotSupportedError');

          when(camera.pause).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => CameraPlatform.instance.pausePreview(cameraId),
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

    group('resumePreview', () {
      testWidgets('calls play on the camera', (WidgetTester tester) async {
        final MockCamera camera = MockCamera();

        when(camera.play).thenAnswer((Invocation _) async {});

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.resumePreview(cameraId);

        verify(camera.play).called(1);
      });

      group('throws PlatformException', () {
        testWidgets(
            'with notFound error '
            'if the camera does not exist', (WidgetTester tester) async {
          expect(
            () async => CameraPlatform.instance.resumePreview(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when play throws DomException',
            (WidgetTester tester) async {
          final MockCamera camera = MockCamera();
          final DOMException exception = DOMException('NotSupportedError');

          when(camera.play).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => CameraPlatform.instance.resumePreview(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });

        testWidgets('when play throws CameraWebException',
            (WidgetTester tester) async {
          final MockCamera camera = MockCamera();
          final CameraWebException exception = CameraWebException(
            cameraId,
            CameraErrorCode.unknown,
            'description',
          );

          when(camera.play).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => CameraPlatform.instance.resumePreview(cameraId),
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

    testWidgets(
        'buildPreview returns an HtmlElementView '
        'with an appropriate view type', (WidgetTester tester) async {
      final Camera camera = Camera(
        textureId: cameraId,
        cameraService: cameraService,
      );

      // Save the camera in the camera plugin.
      (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

      expect(
        CameraPlatform.instance.buildPreview(cameraId),
        isA<widgets.HtmlElementView>().having(
          (widgets.HtmlElementView view) => view.viewType,
          'viewType',
          camera.getViewType(),
        ),
      );
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
        videoElement =
            createJSInteropWrapper(mockVideoElement) as HTMLVideoElement;

        errorStreamController = StreamController<Event>();
        abortStreamController = StreamController<Event>();
        endedStreamController = StreamController<MediaStreamTrack>();
        videoRecordingErrorController = StreamController<ErrorEvent>();

        when(camera.getVideoSize).thenReturn(const Size(10, 10));
        when(camera.initialize)
            .thenAnswer((Invocation _) => Future<void>.value());
        when(camera.play).thenAnswer((Invocation _) => Future<void>.value());
        when(camera.dispose).thenAnswer((Invocation _) => Future<void>.value());

        when(() => camera.videoElement).thenReturn(videoElement);

        final MockEventStreamProvider<Event> errorProvider =
            MockEventStreamProvider<Event>();
        final MockEventStreamProvider<Event> abortProvider =
            MockEventStreamProvider<Event>();

        (CameraPlatform.instance as CameraPlugin).videoElementOnErrorProvider =
            errorProvider;
        (CameraPlatform.instance as CameraPlugin).videoElementOnAbortProvider =
            abortProvider;

        when(() => errorProvider.forElement(videoElement)).thenAnswer(
          (_) => FakeElementStream<Event>(errorStreamController.stream),
        );
        when(() => abortProvider.forElement(videoElement)).thenAnswer(
          (_) => FakeElementStream<Event>(abortStreamController.stream),
        );

        when(() => camera.onEnded)
            .thenAnswer((Invocation _) => endedStreamController.stream);

        when(() => camera.onVideoRecordingError)
            .thenAnswer((Invocation _) => videoRecordingErrorController.stream);

        when(camera.startVideoRecording).thenAnswer((Invocation _) async {});
      });

      testWidgets('disposes the correct camera', (WidgetTester tester) async {
        const int firstCameraId = 0;
        const int secondCameraId = 1;

        final MockCamera firstCamera = MockCamera();
        final MockCamera secondCamera = MockCamera();

        when(firstCamera.dispose)
            .thenAnswer((Invocation _) => Future<void>.value());
        when(secondCamera.dispose)
            .thenAnswer((Invocation _) => Future<void>.value());

        // Save cameras in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras.addAll(<int, Camera>{
          firstCameraId: firstCamera,
          secondCameraId: secondCamera,
        });

        // Dispose the first camera.
        await CameraPlatform.instance.dispose(firstCameraId);

        // The first camera should be disposed.
        verify(firstCamera.dispose).called(1);
        verifyNever(secondCamera.dispose);

        // The first camera should be removed from the camera plugin.
        expect(
          (CameraPlatform.instance as CameraPlugin).cameras,
          equals(<int, Camera>{
            secondCameraId: secondCamera,
          }),
        );
      });

      testWidgets('cancels the camera video error and abort subscriptions',
          (WidgetTester tester) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.initializeCamera(cameraId);
        await CameraPlatform.instance.dispose(cameraId);

        expect(errorStreamController.hasListener, isFalse);
        expect(abortStreamController.hasListener, isFalse);
      });

      testWidgets('cancels the camera ended subscriptions',
          (WidgetTester tester) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.initializeCamera(cameraId);
        await CameraPlatform.instance.dispose(cameraId);

        expect(endedStreamController.hasListener, isFalse);
      });

      testWidgets('cancels the camera video recording error subscriptions',
          (WidgetTester tester) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.initializeCamera(cameraId);
        await CameraPlatform.instance.startVideoRecording(cameraId);
        await CameraPlatform.instance.dispose(cameraId);

        expect(videoRecordingErrorController.hasListener, isFalse);
      });

      group('throws PlatformException', () {
        testWidgets(
            'with notFound error '
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

        testWidgets('when dispose throws DomException',
            (WidgetTester tester) async {
          final MockCamera camera = MockCamera();
          final DOMException exception = DOMException('InvalidAccessError');

          when(camera.dispose).thenThrow(exception);

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
        final Camera camera = Camera(
          textureId: cameraId,
          cameraService: cameraService,
        );

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        expect(
          (CameraPlatform.instance as CameraPlugin).getCamera(cameraId),
          equals(camera),
        );
      });

      testWidgets(
          'throws PlatformException '
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
      late Camera camera;
      late MockVideoElement mockVideoElement;
      late HTMLVideoElement videoElement;

      late StreamController<Event> errorStreamController, abortStreamController;
      late StreamController<MediaStreamTrack> endedStreamController;
      late StreamController<ErrorEvent> videoRecordingErrorController;

      setUp(() {
        camera = MockCamera();
        mockVideoElement = MockVideoElement();
        videoElement =
            createJSInteropWrapper(mockVideoElement) as HTMLVideoElement;

        errorStreamController = StreamController<Event>();
        abortStreamController = StreamController<Event>();
        endedStreamController = StreamController<MediaStreamTrack>();
        videoRecordingErrorController = StreamController<ErrorEvent>();

        when(camera.getVideoSize).thenReturn(const Size(10, 10));
        when(camera.initialize)
            .thenAnswer((Invocation _) => Future<void>.value());
        when(camera.play).thenAnswer((Invocation _) => Future<void>.value());

        when(() => camera.videoElement).thenReturn(videoElement);

        final MockEventStreamProvider<Event> errorProvider =
            MockEventStreamProvider<Event>();
        final MockEventStreamProvider<Event> abortProvider =
            MockEventStreamProvider<Event>();

        (CameraPlatform.instance as CameraPlugin).videoElementOnErrorProvider =
            errorProvider;
        (CameraPlatform.instance as CameraPlugin).videoElementOnAbortProvider =
            abortProvider;

        when(() => errorProvider.forElement(any())).thenAnswer(
          (_) => FakeElementStream<Event>(errorStreamController.stream),
        );
        when(() => abortProvider.forElement(any())).thenAnswer(
          (_) => FakeElementStream<Event>(abortStreamController.stream),
        );

        when(() => camera.onEnded)
            .thenAnswer((Invocation _) => endedStreamController.stream);

        when(() => camera.onVideoRecordingError)
            .thenAnswer((Invocation _) => videoRecordingErrorController.stream);

        when(camera.startVideoRecording).thenAnswer((Invocation _) async {});
      });

      testWidgets(
          'onCameraInitialized emits a CameraInitializedEvent '
          'on initializeCamera', (WidgetTester tester) async {
        // Mock the camera to use a blank video stream of size 1280x720.
        const Size videoSize = Size(1280, 720);

        videoElement = getVideoElementWithBlankStream(videoSize);

        when(
          () => cameraService.getMediaStreamForOptions(
            any(),
            cameraId: cameraId,
          ),
        ).thenAnswer((Invocation _) async => videoElement.captureStream());

        final Camera camera = Camera(
          textureId: cameraId,
          cameraService: cameraService,
        );

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        final Stream<CameraInitializedEvent> eventStream =
            CameraPlatform.instance.onCameraInitialized(cameraId);

        final StreamQueue<CameraInitializedEvent> streamQueue =
            StreamQueue<CameraInitializedEvent>(eventStream);

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

      testWidgets('onCameraResolutionChanged emits an empty stream',
          (WidgetTester tester) async {
        final Stream<CameraResolutionChangedEvent> stream =
            CameraPlatform.instance.onCameraResolutionChanged(cameraId);
        expect(await stream.isEmpty, isTrue);
      });

      testWidgets(
          'onCameraClosing emits a CameraClosingEvent '
          'on the camera ended event', (WidgetTester tester) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        final Stream<CameraClosingEvent> eventStream =
            CameraPlatform.instance.onCameraClosing(cameraId);

        final StreamQueue<CameraClosingEvent> streamQueue =
            StreamQueue<CameraClosingEvent>(eventStream);

        await CameraPlatform.instance.initializeCamera(cameraId);

        endedStreamController.add(
          createJSInteropWrapper(MockMediaStreamTrack()) as MediaStreamTrack,
        );

        expect(
          await streamQueue.next,
          equals(
            const CameraClosingEvent(cameraId),
          ),
        );

        await streamQueue.cancel();
      });

      group('onCameraError', () {
        setUp(() {
          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;
        });

        testWidgets(
            'emits a CameraErrorEvent '
            'on the camera video error event '
            'with a message', (WidgetTester tester) async {
          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final StreamQueue<CameraErrorEvent> streamQueue =
              StreamQueue<CameraErrorEvent>(eventStream);

          await CameraPlatform.instance.initializeCamera(cameraId);

          final MediaError error = createJSInteropWrapper(
            FakeMediaError(
              MediaError.MEDIA_ERR_NETWORK,
              'A network error occurred.',
            ),
          ) as MediaError;

          final CameraErrorCode errorCode =
              CameraErrorCode.fromMediaError(error);

          mockVideoElement.error = error;
          errorStreamController.add(Event('error'));

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                'Error code: $errorCode, error message: ${error.message}',
              ),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets(
            'emits a CameraErrorEvent '
            'on the camera video error event '
            'with no message', (WidgetTester tester) async {
          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final StreamQueue<CameraErrorEvent> streamQueue =
              StreamQueue<CameraErrorEvent>(eventStream);

          await CameraPlatform.instance.initializeCamera(cameraId);

          final MediaError error = createJSInteropWrapper(
            FakeMediaError(MediaError.MEDIA_ERR_NETWORK),
          ) as MediaError;
          final CameraErrorCode errorCode =
              CameraErrorCode.fromMediaError(error);

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

        testWidgets(
            'emits a CameraErrorEvent '
            'on the camera video abort event', (WidgetTester tester) async {
          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final StreamQueue<CameraErrorEvent> streamQueue =
              StreamQueue<CameraErrorEvent>(eventStream);

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

        testWidgets(
            'emits a CameraErrorEvent '
            'on takePicture error', (WidgetTester tester) async {
          final CameraWebException exception = CameraWebException(
            cameraId,
            CameraErrorCode.notStarted,
            'description',
          );

          when(camera.takePicture).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final StreamQueue<CameraErrorEvent> streamQueue =
              StreamQueue<CameraErrorEvent>(eventStream);

          expect(
            () async => CameraPlatform.instance.takePicture(cameraId),
            throwsA(
              isA<PlatformException>(),
            ),
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

        testWidgets(
            'emits a CameraErrorEvent '
            'on setFlashMode error', (WidgetTester tester) async {
          final CameraWebException exception = CameraWebException(
            cameraId,
            CameraErrorCode.notStarted,
            'description',
          );

          when(() => camera.setFlashMode(any())).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final StreamQueue<CameraErrorEvent> streamQueue =
              StreamQueue<CameraErrorEvent>(eventStream);

          expect(
            () async => CameraPlatform.instance.setFlashMode(
              cameraId,
              FlashMode.always,
            ),
            throwsA(
              isA<PlatformException>(),
            ),
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

        testWidgets(
            'emits a CameraErrorEvent '
            'on getMaxZoomLevel error', (WidgetTester tester) async {
          final CameraWebException exception = CameraWebException(
            cameraId,
            CameraErrorCode.zoomLevelNotSupported,
            'description',
          );

          when(camera.getMaxZoomLevel).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final StreamQueue<CameraErrorEvent> streamQueue =
              StreamQueue<CameraErrorEvent>(eventStream);

          expect(
            () async => CameraPlatform.instance.getMaxZoomLevel(
              cameraId,
            ),
            throwsA(
              isA<PlatformException>(),
            ),
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

        testWidgets(
            'emits a CameraErrorEvent '
            'on getMinZoomLevel error', (WidgetTester tester) async {
          final CameraWebException exception = CameraWebException(
            cameraId,
            CameraErrorCode.zoomLevelNotSupported,
            'description',
          );

          when(camera.getMinZoomLevel).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final StreamQueue<CameraErrorEvent> streamQueue =
              StreamQueue<CameraErrorEvent>(eventStream);

          expect(
            () async => CameraPlatform.instance.getMinZoomLevel(
              cameraId,
            ),
            throwsA(
              isA<PlatformException>(),
            ),
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

        testWidgets(
            'emits a CameraErrorEvent '
            'on setZoomLevel error', (WidgetTester tester) async {
          final CameraWebException exception = CameraWebException(
            cameraId,
            CameraErrorCode.zoomLevelNotSupported,
            'description',
          );

          when(() => camera.setZoomLevel(any())).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final StreamQueue<CameraErrorEvent> streamQueue =
              StreamQueue<CameraErrorEvent>(eventStream);

          expect(
            () async => CameraPlatform.instance.setZoomLevel(
              cameraId,
              100.0,
            ),
            throwsA(
              isA<CameraException>(),
            ),
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

        testWidgets(
            'emits a CameraErrorEvent '
            'on resumePreview error', (WidgetTester tester) async {
          final CameraWebException exception = CameraWebException(
            cameraId,
            CameraErrorCode.unknown,
            'description',
          );

          when(camera.play).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final StreamQueue<CameraErrorEvent> streamQueue =
              StreamQueue<CameraErrorEvent>(eventStream);

          expect(
            () async => CameraPlatform.instance.resumePreview(cameraId),
            throwsA(
              isA<PlatformException>(),
            ),
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

        testWidgets(
            'emits a CameraErrorEvent '
            'on startVideoRecording error', (WidgetTester tester) async {
          final CameraWebException exception = CameraWebException(
            cameraId,
            CameraErrorCode.notStarted,
            'description',
          );

          when(() => camera.onVideoRecordingError)
              .thenAnswer((Invocation _) => const Stream<ErrorEvent>.empty());

          when(
            () => camera.startVideoRecording(),
          ).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final StreamQueue<CameraErrorEvent> streamQueue =
              StreamQueue<CameraErrorEvent>(eventStream);

          expect(
            () async => CameraPlatform.instance.startVideoRecording(cameraId),
            throwsA(
              isA<PlatformException>(),
            ),
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

        testWidgets(
            'emits a CameraErrorEvent '
            'on the camera video recording error event',
            (WidgetTester tester) async {
          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final StreamQueue<CameraErrorEvent> streamQueue =
              StreamQueue<CameraErrorEvent>(eventStream);

          await CameraPlatform.instance.initializeCamera(cameraId);
          await CameraPlatform.instance.startVideoRecording(cameraId);

          final ErrorEvent errorEvent =
              createJSInteropWrapper(FakeErrorEvent('type', 'message'))
                  as ErrorEvent;

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

        testWidgets(
            'emits a CameraErrorEvent '
            'on stopVideoRecording error', (WidgetTester tester) async {
          final CameraWebException exception = CameraWebException(
            cameraId,
            CameraErrorCode.notStarted,
            'description',
          );

          when(camera.stopVideoRecording).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final StreamQueue<CameraErrorEvent> streamQueue =
              StreamQueue<CameraErrorEvent>(eventStream);

          expect(
            () async => CameraPlatform.instance.stopVideoRecording(cameraId),
            throwsA(
              isA<PlatformException>(),
            ),
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

        testWidgets(
            'emits a CameraErrorEvent '
            'on pauseVideoRecording error', (WidgetTester tester) async {
          final CameraWebException exception = CameraWebException(
            cameraId,
            CameraErrorCode.notStarted,
            'description',
          );

          when(camera.pauseVideoRecording).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final StreamQueue<CameraErrorEvent> streamQueue =
              StreamQueue<CameraErrorEvent>(eventStream);

          expect(
            () async => CameraPlatform.instance.pauseVideoRecording(cameraId),
            throwsA(
              isA<PlatformException>(),
            ),
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

        testWidgets(
            'emits a CameraErrorEvent '
            'on resumeVideoRecording error', (WidgetTester tester) async {
          final CameraWebException exception = CameraWebException(
            cameraId,
            CameraErrorCode.notStarted,
            'description',
          );

          when(camera.resumeVideoRecording).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final StreamQueue<CameraErrorEvent> streamQueue =
              StreamQueue<CameraErrorEvent>(eventStream);

          expect(
            () async => CameraPlatform.instance.resumeVideoRecording(cameraId),
            throwsA(
              isA<PlatformException>(),
            ),
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

      testWidgets('onVideoRecordedEvent emits a VideoRecordedEvent',
          (WidgetTester tester) async {
        final MockCamera camera = MockCamera();
        final XFile capturedVideo = XFile('/bogus/test');
        final Stream<VideoRecordedEvent> stream =
            Stream<VideoRecordedEvent>.value(
                VideoRecordedEvent(cameraId, capturedVideo, Duration.zero));
        when(() => camera.onVideoRecordedEvent)
            .thenAnswer((Invocation _) => stream);

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        final StreamQueue<VideoRecordedEvent> streamQueue =
            StreamQueue<VideoRecordedEvent>(
                CameraPlatform.instance.onVideoRecordedEvent(cameraId));

        expect(
          await streamQueue.next,
          equals(
            VideoRecordedEvent(cameraId, capturedVideo, Duration.zero),
          ),
        );
      });

      group('onDeviceOrientationChanged', () {
        final StreamController<Event> eventStreamController =
            StreamController<Event>();

        setUp(() {
          final MockEventStreamProvider<Event> provider =
              MockEventStreamProvider<Event>();
          (CameraPlatform.instance as CameraPlugin)
              .orientationOnChangeProvider = provider;
          when(() => provider.forTarget(any()))
              .thenAnswer((_) => eventStreamController.stream);
        });

        testWidgets('emits the initial DeviceOrientationChangedEvent',
            (WidgetTester tester) async {
          when(
            () => cameraService.mapOrientationTypeToDeviceOrientation(
              OrientationType.portraitPrimary,
            ),
          ).thenReturn(DeviceOrientation.portraitUp);

          // Set the initial screen orientation to portraitPrimary.
          mockScreenOrientation.type = OrientationType.portraitPrimary;

          final Stream<DeviceOrientationChangedEvent> eventStream =
              CameraPlatform.instance.onDeviceOrientationChanged();

          final StreamQueue<DeviceOrientationChangedEvent> streamQueue =
              StreamQueue<DeviceOrientationChangedEvent>(eventStream);

          expect(
            await streamQueue.next,
            equals(
              const DeviceOrientationChangedEvent(
                DeviceOrientation.portraitUp,
              ),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets(
            'emits a DeviceOrientationChangedEvent '
            'when the screen orientation is changed',
            (WidgetTester tester) async {
          when(
            () => cameraService.mapOrientationTypeToDeviceOrientation(
              OrientationType.landscapePrimary,
            ),
          ).thenReturn(DeviceOrientation.landscapeLeft);

          when(
            () => cameraService.mapOrientationTypeToDeviceOrientation(
              OrientationType.portraitSecondary,
            ),
          ).thenReturn(DeviceOrientation.portraitDown);

          final Stream<DeviceOrientationChangedEvent> eventStream =
              CameraPlatform.instance.onDeviceOrientationChanged();

          final StreamQueue<DeviceOrientationChangedEvent> streamQueue =
              StreamQueue<DeviceOrientationChangedEvent>(eventStream);

          // Change the screen orientation to landscapePrimary and
          // emit an event on the screenOrientation.onChange stream.
          mockScreenOrientation.type = OrientationType.landscapePrimary;

          eventStreamController.add(Event('change'));

          expect(
            await streamQueue.next,
            equals(
              const DeviceOrientationChangedEvent(
                DeviceOrientation.landscapeLeft,
              ),
            ),
          );

          // Change the screen orientation to portraitSecondary and
          // emit an event on the screenOrientation.onChange stream.
          mockScreenOrientation.type = OrientationType.portraitSecondary;

          eventStreamController.add(Event('change'));

          expect(
            await streamQueue.next,
            equals(
              const DeviceOrientationChangedEvent(
                DeviceOrientation.portraitDown,
              ),
            ),
          );

          await streamQueue.cancel();
        });
      });
    });
  });
}
