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

    group('availableCameras', () {
      setUp(() {
        when(cameraService.getFacingModeForVideoTrack(any)).thenReturn(null);

        mockMediaDevices.enumerateDevices = () {
          return Future<JSArray<MediaDeviceInfo>>.value(<MediaDeviceInfo>[].toJS).toJS;
        }.toJS;
      });

      testWidgets('requests video permissions', (WidgetTester tester) async {
        final List<CameraDescription> _ = await CameraPlatform.instance.availableCameras();

        verify(cameraService.getMediaStreamForOptions(const CameraOptions())).called(1);
      });

      testWidgets('releases the camera stream '
          'used to request video permissions', (WidgetTester tester) async {
        final mockVideoTrack = MockMediaStreamTrack();
        final videoTrack = createJSInteropWrapper(mockVideoTrack) as MediaStreamTrack;

        var videoTrackStopped = false;
        mockVideoTrack.stop = () {
          videoTrackStopped = true;
        }.toJS;

        when(cameraService.getMediaStreamForOptions(const CameraOptions())).thenAnswer(
          (_) => Future<MediaStream>.value(
            createJSInteropWrapper(FakeMediaStream(<MediaStreamTrack>[videoTrack])) as MediaStream,
          ),
        );

        final List<CameraDescription> _ = await CameraPlatform.instance.availableCameras();

        expect(videoTrackStopped, isTrue);
      });

      testWidgets('gets a video stream '
          'for a video input device', (WidgetTester tester) async {
        final videoDevice =
            createJSInteropWrapper(FakeMediaDeviceInfo('1', 'Camera 1', MediaDeviceKind.videoInput))
                as MediaDeviceInfo;

        mockMediaDevices.enumerateDevices = () {
          return Future<JSArray<MediaDeviceInfo>>.value(<MediaDeviceInfo>[videoDevice].toJS).toJS;
        }.toJS;

        final List<CameraDescription> _ = await CameraPlatform.instance.availableCameras();

        verify(
          cameraService.getMediaStreamForOptions(
            CameraOptions(video: VideoConstraints(deviceId: videoDevice.deviceId)),
          ),
        ).called(1);
      });

      testWidgets('does not get a video stream '
          'for the video input device '
          'with an empty device id', (WidgetTester tester) async {
        final videoDevice =
            createJSInteropWrapper(FakeMediaDeviceInfo('', 'Camera 1', MediaDeviceKind.videoInput))
                as MediaDeviceInfo;

        mockMediaDevices.enumerateDevices = () {
          return Future<JSArray<MediaDeviceInfo>>.value(<MediaDeviceInfo>[videoDevice].toJS).toJS;
        }.toJS;

        final List<CameraDescription> _ = await CameraPlatform.instance.availableCameras();

        verifyNever(
          cameraService.getMediaStreamForOptions(
            CameraOptions(video: VideoConstraints(deviceId: videoDevice.deviceId)),
          ),
        );
      });

      testWidgets('gets the facing mode '
          'from the first available video track '
          'of the video input device', (WidgetTester tester) async {
        final videoDevice =
            createJSInteropWrapper(FakeMediaDeviceInfo('1', 'Camera 1', MediaDeviceKind.videoInput))
                as MediaDeviceInfo;

        final videoStream =
            createJSInteropWrapper(
                  FakeMediaStream(<MediaStreamTrack>[
                    createJSInteropWrapper(MockMediaStreamTrack()) as MediaStreamTrack,
                    createJSInteropWrapper(MockMediaStreamTrack()) as MediaStreamTrack,
                  ]),
                )
                as MediaStream;

        when(
          cameraService.getMediaStreamForOptions(
            CameraOptions(video: VideoConstraints(deviceId: videoDevice.deviceId)),
          ),
        ).thenAnswer((_) => Future<MediaStream>.value(videoStream));

        mockMediaDevices.enumerateDevices = () {
          return Future<JSArray<MediaDeviceInfo>>.value(<MediaDeviceInfo>[videoDevice].toJS).toJS;
        }.toJS;

        final List<CameraDescription> _ = await CameraPlatform.instance.availableCameras();

        verify(
          cameraService.getFacingModeForVideoTrack(videoStream.getVideoTracks().toDart.first),
        ).called(1);
      });

      testWidgets('returns appropriate camera descriptions '
          'for multiple video devices '
          'based on video streams', (WidgetTester tester) async {
        final firstVideoDevice =
            createJSInteropWrapper(FakeMediaDeviceInfo('1', 'Camera 1', MediaDeviceKind.videoInput))
                as MediaDeviceInfo;

        final secondVideoDevice =
            createJSInteropWrapper(FakeMediaDeviceInfo('4', 'Camera 4', MediaDeviceKind.videoInput))
                as MediaDeviceInfo;

        // Create a video stream for the first video device.
        final firstVideoStream =
            createJSInteropWrapper(
                  FakeMediaStream(<MediaStreamTrack>[
                    createJSInteropWrapper(MockMediaStreamTrack()) as MediaStreamTrack,
                    createJSInteropWrapper(MockMediaStreamTrack()) as MediaStreamTrack,
                  ]),
                )
                as MediaStream;

        // Create a video stream for the second video device.
        final secondVideoStream =
            createJSInteropWrapper(
                  FakeMediaStream(<MediaStreamTrack>[
                    createJSInteropWrapper(MockMediaStreamTrack()) as MediaStreamTrack,
                  ]),
                )
                as MediaStream;

        // Mock media devices to return two video input devices
        // and two audio devices.
        mockMediaDevices.enumerateDevices = () {
          return Future<JSArray<MediaDeviceInfo>>.value(
            <MediaDeviceInfo>[
              firstVideoDevice,
              createJSInteropWrapper(
                    FakeMediaDeviceInfo('2', 'Audio Input 2', MediaDeviceKind.audioInput),
                  )
                  as MediaDeviceInfo,
              createJSInteropWrapper(
                    FakeMediaDeviceInfo('3', 'Audio Output 3', MediaDeviceKind.audioOutput),
                  )
                  as MediaDeviceInfo,
              secondVideoDevice,
            ].toJS,
          ).toJS;
        }.toJS;

        // Mock camera service to return the first video stream
        // for the first video device.
        when(
          cameraService.getMediaStreamForOptions(
            CameraOptions(video: VideoConstraints(deviceId: firstVideoDevice.deviceId)),
          ),
        ).thenAnswer((_) => Future<MediaStream>.value(firstVideoStream));

        // Mock camera service to return the second video stream
        // for the second video device.
        when(
          cameraService.getMediaStreamForOptions(
            CameraOptions(video: VideoConstraints(deviceId: secondVideoDevice.deviceId)),
          ),
        ).thenAnswer((_) => Future<MediaStream>.value(secondVideoStream));

        // Mock camera service to return a user facing mode
        // for the first video stream.
        when(
          cameraService.getFacingModeForVideoTrack(firstVideoStream.getVideoTracks().toDart.first),
        ).thenReturn('user');

        when(
          cameraService.mapFacingModeToLensDirection('user'),
        ).thenReturn(CameraLensDirection.front);

        // Mock camera service to return an environment facing mode
        // for the second video stream.
        when(
          cameraService.getFacingModeForVideoTrack(secondVideoStream.getVideoTracks().toDart.first),
        ).thenReturn('environment');

        when(
          cameraService.mapFacingModeToLensDirection('environment'),
        ).thenReturn(CameraLensDirection.back);

        final List<CameraDescription> cameras = await CameraPlatform.instance.availableCameras();

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
            ),
          ]),
        );
      });

      testWidgets('sets camera metadata '
          'for the camera description', (WidgetTester tester) async {
        final videoDevice =
            createJSInteropWrapper(FakeMediaDeviceInfo('1', 'Camera 1', MediaDeviceKind.videoInput))
                as MediaDeviceInfo;

        final videoStream =
            createJSInteropWrapper(
                  FakeMediaStream(<MediaStreamTrack>[
                    createJSInteropWrapper(MockMediaStreamTrack()) as MediaStreamTrack,
                    createJSInteropWrapper(MockMediaStreamTrack()) as MediaStreamTrack,
                  ]),
                )
                as MediaStream;

        mockMediaDevices.enumerateDevices = () {
          return Future<JSArray<MediaDeviceInfo>>.value(<MediaDeviceInfo>[videoDevice].toJS).toJS;
        }.toJS;

        when(
          cameraService.getMediaStreamForOptions(
            CameraOptions(video: VideoConstraints(deviceId: videoDevice.deviceId)),
          ),
        ).thenAnswer((_) => Future<MediaStream>.value(videoStream));

        when(
          cameraService.getFacingModeForVideoTrack(videoStream.getVideoTracks().toDart.first),
        ).thenReturn('left');

        when(
          cameraService.mapFacingModeToLensDirection('left'),
        ).thenReturn(CameraLensDirection.external);

        final CameraDescription camera = (await CameraPlatform.instance.availableCameras()).first;

        expect(
          (CameraPlatform.instance as CameraPlugin).camerasMetadata,
          equals(<CameraDescription, CameraMetadata>{
            camera: CameraMetadata(deviceId: videoDevice.deviceId, facingMode: 'left'),
          }),
        );
      });

      testWidgets('releases the video stream '
          'of a video input device', (WidgetTester tester) async {
        final videoDevice =
            createJSInteropWrapper(FakeMediaDeviceInfo('1', 'Camera 1', MediaDeviceKind.videoInput))
                as MediaDeviceInfo;

        final tracks = <MediaStreamTrack>[];
        final stops = List<bool>.generate(2, (_) => false);
        for (var i = 0; i < stops.length; i++) {
          final track = MockMediaStreamTrack();
          track.stop = () {
            stops[i] = true;
          }.toJS;
          tracks.add(createJSInteropWrapper(track) as MediaStreamTrack);
        }

        final videoStream = createJSInteropWrapper(FakeMediaStream(tracks)) as MediaStream;

        mockMediaDevices.enumerateDevices = () {
          return Future<JSArray<MediaDeviceInfo>>.value(<MediaDeviceInfo>[videoDevice].toJS).toJS;
        }.toJS;

        when(
          cameraService.getMediaStreamForOptions(
            CameraOptions(video: VideoConstraints(deviceId: videoDevice.deviceId)),
          ),
        ).thenAnswer((_) => Future<MediaStream>.value(videoStream));

        final List<CameraDescription> _ = await CameraPlatform.instance.availableCameras();

        expect(stops.every((bool e) => e), isTrue);
      });

      group('throws CameraException', () {
        testWidgets('when MediaDevices.enumerateDevices throws DomException', (
          WidgetTester tester,
        ) async {
          final exception = DOMException('UnknownError');

          mockMediaDevices.enumerateDevices = () {
            throw exception;
            // ignore: dead_code
            return Future<JSArray<MediaDeviceInfo>>.value(<MediaDeviceInfo>[].toJS).toJS;
          }.toJS;

          expect(
            () => CameraPlatform.instance.availableCameras(),
            throwsA(
              isA<CameraException>().having((CameraException e) => e.code, 'code', exception.name),
            ),
          );
        });

        testWidgets('when CameraService.getMediaStreamForOptions '
            'throws CameraWebException', (WidgetTester tester) async {
          final exception = CameraWebException(cameraId, CameraErrorCode.security, 'description');

          when(cameraService.getMediaStreamForOptions(any)).thenThrow(exception);

          expect(
            CameraPlatform.instance.availableCameras(),
            throwsA(
              isA<CameraException>().having(
                (CameraException e) => e.code,
                'code',
                exception.code.toString(),
              ),
            ),
          );
        });

        testWidgets('when CameraService.getMediaStreamForOptions '
            'throws PlatformException', (WidgetTester tester) async {
          final exception = PlatformException(
            code: CameraErrorCode.notSupported.toString(),
            message: 'message',
          );

          when(cameraService.getMediaStreamForOptions(any)).thenThrow(exception);

          expect(
            () => CameraPlatform.instance.availableCameras(),
            throwsA(
              isA<CameraException>().having((CameraException e) => e.code, 'code', exception.code),
            ),
          );
        });
      });
    });

    group('createCamera', () {
      group('creates a camera', () {
        const ultraHighResolutionSize = Size(3840, 2160);
        const maxResolutionSize = Size(3840, 2160);

        const cameraDescription = CameraDescription(
          name: 'name',
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 0,
        );

        const cameraMetadata = CameraMetadata(deviceId: 'deviceId', facingMode: 'user');

        setUp(() {
          // Add metadata for the camera description.
          (CameraPlatform.instance as CameraPlugin).camerasMetadata[cameraDescription] =
              cameraMetadata;

          when(cameraService.mapFacingModeToCameraType('user')).thenReturn(CameraType.user);
        });

        testWidgets('with appropriate options', (WidgetTester tester) async {
          when(
            cameraService.mapResolutionPresetToSize(ResolutionPreset.ultraHigh),
          ).thenReturn(ultraHighResolutionSize);

          final int cameraId = await CameraPlatform.instance.createCamera(
            cameraDescription,
            ResolutionPreset.ultraHigh,
            enableAudio: true,
          );

          final Camera? camera = (CameraPlatform.instance as CameraPlugin).cameras[cameraId];

          expect(camera, isA<Camera>());
          expect(camera!.textureId, cameraId);
          expect(camera.options.audio.enabled, isTrue);
          expect(camera.options.video.facingMode, equals(FacingModeConstraint(CameraType.user)));
          expect(camera.options.video.width!.ideal, ultraHighResolutionSize.width.toInt());
          expect(camera.options.video.height!.ideal, ultraHighResolutionSize.height.toInt());
          expect(camera.options.video.deviceId, cameraMetadata.deviceId);
        });

        testWidgets('with appropriate createCameraWithSettings options', (
          WidgetTester tester,
        ) async {
          when(
            cameraService.mapResolutionPresetToSize(ResolutionPreset.ultraHigh),
          ).thenReturn(ultraHighResolutionSize);

          final int cameraId = await CameraPlatform.instance.createCameraWithSettings(
            cameraDescription,
            const MediaSettings(
              resolutionPreset: ResolutionPreset.ultraHigh,
              videoBitrate: 200000,
              audioBitrate: 32000,
              enableAudio: true,
            ),
          );

          final Camera? camera = (CameraPlatform.instance as CameraPlugin).cameras[cameraId];

          expect(camera, isA<Camera>());
          expect(camera!.textureId, cameraId);
          expect(camera.options.audio.enabled, isTrue);
          expect(camera.options.video.facingMode, equals(FacingModeConstraint(CameraType.user)));
          expect(camera.options.video.width!.ideal, ultraHighResolutionSize.width.toInt());
          expect(camera.options.video.height!.ideal, ultraHighResolutionSize.height.toInt());
          expect(camera.options.video.deviceId, cameraMetadata.deviceId);
        });

        testWidgets('with a max resolution preset '
            'and enabled audio set to false '
            'when no options are specified', (WidgetTester tester) async {
          when(
            cameraService.mapResolutionPresetToSize(ResolutionPreset.max),
          ).thenReturn(maxResolutionSize);

          final int cameraId = await CameraPlatform.instance.createCamera(cameraDescription, null);

          final Camera? camera = (CameraPlatform.instance as CameraPlugin).cameras[cameraId];

          expect(camera, isA<Camera>());
          expect(camera!.textureId, cameraId);
          expect(camera.options.audio.enabled, isFalse);
          expect(camera.options.video.facingMode, equals(FacingModeConstraint(CameraType.user)));
          expect(camera.options.video.width!.ideal, maxResolutionSize.width.toInt());
          expect(camera.options.video.height!.ideal, maxResolutionSize.height.toInt());
          expect(camera.options.video.deviceId, cameraMetadata.deviceId);
        });

        testWidgets('with a max resolution preset '
            'and enabled audio set to false '
            'when no options are specified '
            'using createCameraWithSettings', (WidgetTester tester) async {
          when(
            cameraService.mapResolutionPresetToSize(ResolutionPreset.max),
          ).thenReturn(maxResolutionSize);

          final int cameraId = await CameraPlatform.instance.createCameraWithSettings(
            cameraDescription,
            const MediaSettings(resolutionPreset: ResolutionPreset.max),
          );

          final Camera? camera = (CameraPlatform.instance as CameraPlugin).cameras[cameraId];

          expect(camera, isA<Camera>());
          expect(camera!.options.audio.enabled, isFalse);
          expect(camera.options.video.facingMode, equals(FacingModeConstraint(CameraType.user)));
          expect(camera.options.video.width!.ideal, maxResolutionSize.width.toInt());
          expect(camera.options.video.height!.ideal, maxResolutionSize.height.toInt());
          expect(camera.options.video.deviceId, cameraMetadata.deviceId);
        });
      });

      testWidgets('throws CameraException '
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

      testWidgets('throws CameraException '
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
        videoElement = createJSInteropWrapper(mockVideoElement) as HTMLVideoElement;

        errorStreamController = StreamController<Event>();
        abortStreamController = StreamController<Event>();
        endedStreamController = StreamController<MediaStreamTrack>();

        when(camera.getVideoSize()).thenReturn(const Size(10, 10));
        when(camera.initialize()).thenAnswer((_) => Future<void>.value());
        when(camera.play()).thenAnswer((_) => Future<void>.value());

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
      });

      testWidgets('initializes and plays the camera', (WidgetTester tester) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.initializeCamera(cameraId);

        verify(camera.initialize()).called(1);
        verify(camera.play()).called(1);
      });

      testWidgets('starts listening to the camera video error and abort events', (
        WidgetTester tester,
      ) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        expect(errorStreamController.hasListener, isFalse);
        expect(abortStreamController.hasListener, isFalse);

        await CameraPlatform.instance.initializeCamera(cameraId);

        expect(errorStreamController.hasListener, isTrue);
        expect(abortStreamController.hasListener, isTrue);
      });

      testWidgets('starts listening to the camera ended events', (WidgetTester tester) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        expect(endedStreamController.hasListener, isFalse);

        await CameraPlatform.instance.initializeCamera(cameraId);

        expect(endedStreamController.hasListener, isTrue);
      });

      group('throws PlatformException', () {
        testWidgets('with notFound error '
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

        testWidgets('when camera throws CameraWebException', (WidgetTester tester) async {
          final exception = CameraWebException(
            cameraId,
            CameraErrorCode.permissionDenied,
            'description',
          );

          when(camera.initialize()).thenThrow(exception);

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

        testWidgets('when camera throws DomException', (WidgetTester tester) async {
          final exception = DOMException('NotAllowedError');

          when(camera.initialize()).thenAnswer((_) => Future<void>.value());
          when(camera.play()).thenThrow(exception);

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
  });
}
