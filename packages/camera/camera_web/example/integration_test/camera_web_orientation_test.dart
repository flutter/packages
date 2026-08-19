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

    group('lockCaptureOrientation', () {
      setUp(() {
        when(
          cameraService.mapDeviceOrientationToOrientationType(any),
        ).thenReturn(OrientationType.portraitPrimary);
      });

      testWidgets('requests full-screen mode '
          'on documentElement', (WidgetTester tester) async {
        var fullscreenCalls = 0;
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

      testWidgets('locks the capture orientation '
          'based on the given device orientation', (WidgetTester tester) async {
        when(
          cameraService.mapDeviceOrientationToOrientationType(DeviceOrientation.landscapeRight),
        ).thenReturn(OrientationType.landscapeSecondary);

        final capturedTypes = <OrientationLockType>[];
        mockScreenOrientation.lock = (OrientationLockType orientation) {
          capturedTypes.add(orientation);
          return Future<void>.value().toJS;
        }.toJS;

        await CameraPlatform.instance.lockCaptureOrientation(
          cameraId,
          DeviceOrientation.landscapeRight,
        );

        verify(
          cameraService.mapDeviceOrientationToOrientationType(DeviceOrientation.landscapeRight),
        ).called(1);

        expect(capturedTypes.length, 1);
        expect(capturedTypes[0], OrientationType.landscapeSecondary);
      });

      group('throws PlatformException', () {
        testWidgets('with orientationNotSupported error '
            'when documentElement is not available', (WidgetTester tester) async {
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

        testWidgets('when lock throws DomException', (WidgetTester tester) async {
          final exception = DOMException('NotAllowedError');

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
          cameraService.mapDeviceOrientationToOrientationType(any),
        ).thenReturn(OrientationType.portraitPrimary);
      });

      testWidgets('unlocks the capture orientation', (WidgetTester tester) async {
        var unlocks = 0;
        mockScreenOrientation.unlock = () {
          unlocks++;
        }.toJS;

        await CameraPlatform.instance.unlockCaptureOrientation(cameraId);

        expect(unlocks, 1);
      });

      group('throws PlatformException', () {
        testWidgets('with orientationNotSupported error '
            'when documentElement is not available', (WidgetTester tester) async {
          mockDocument.documentElement = null;

          expect(
            () => CameraPlatform.instance.unlockCaptureOrientation(cameraId),
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

        testWidgets('when unlock throws DomException', (WidgetTester tester) async {
          final exception = DOMException('NotAllowedError');

          mockScreenOrientation.unlock = () {
            throw exception;
            // ignore: dead_code
            return Future<void>.value().toJS;
          }.toJS;

          expect(
            () => CameraPlatform.instance.unlockCaptureOrientation(cameraId),
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

    group('onDeviceOrientationChanged', () {
      final eventStreamController = StreamController<Event>();

      setUp(() {
        final provider = MockEventStreamProvider<Event>();
        (CameraPlatform.instance as CameraPlugin).orientationOnChangeProvider = provider;
        when(provider.forTarget(any)).thenAnswer((_) => eventStreamController.stream);
      });

      testWidgets('emits the initial DeviceOrientationChangedEvent', (WidgetTester tester) async {
        when(
          cameraService.mapOrientationTypeToDeviceOrientation(OrientationType.portraitPrimary),
        ).thenReturn(DeviceOrientation.portraitUp);

        // Set the initial screen orientation to portraitPrimary.
        mockScreenOrientation.type = OrientationType.portraitPrimary;

        final Stream<DeviceOrientationChangedEvent> eventStream = CameraPlatform.instance
            .onDeviceOrientationChanged();

        final streamQueue = StreamQueue<DeviceOrientationChangedEvent>(eventStream);

        expect(
          await streamQueue.next,
          equals(const DeviceOrientationChangedEvent(DeviceOrientation.portraitUp)),
        );

        await streamQueue.cancel();
      });

      testWidgets('emits a DeviceOrientationChangedEvent '
          'when the screen orientation is changed', (WidgetTester tester) async {
        when(
          cameraService.mapOrientationTypeToDeviceOrientation(OrientationType.landscapePrimary),
        ).thenReturn(DeviceOrientation.landscapeLeft);

        when(
          cameraService.mapOrientationTypeToDeviceOrientation(OrientationType.portraitSecondary),
        ).thenReturn(DeviceOrientation.portraitDown);

        final Stream<DeviceOrientationChangedEvent> eventStream = CameraPlatform.instance
            .onDeviceOrientationChanged();

        final streamQueue = StreamQueue<DeviceOrientationChangedEvent>(eventStream);

        // Change the screen orientation to landscapePrimary and
        // emit an event on the screenOrientation.onChange stream.
        mockScreenOrientation.type = OrientationType.landscapePrimary;

        eventStreamController.add(Event('change'));

        expect(
          await streamQueue.next,
          equals(const DeviceOrientationChangedEvent(DeviceOrientation.landscapeLeft)),
        );

        // Change the screen orientation to portraitSecondary and
        // emit an event on the screenOrientation.onChange stream.
        mockScreenOrientation.type = OrientationType.portraitSecondary;

        eventStreamController.add(Event('change'));

        expect(
          await streamQueue.next,
          equals(const DeviceOrientationChangedEvent(DeviceOrientation.portraitDown)),
        );

        await streamQueue.cancel();
      });
    });
  });
}
