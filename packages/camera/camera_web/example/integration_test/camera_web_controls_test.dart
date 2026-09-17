// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: only_throw_errors

import 'dart:js_interop';
import 'dart:math';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/camera_web.dart';
// ignore_for_file: implementation_imports
import 'package:camera_web/src/camera.dart';
import 'package:camera_web/src/types/types.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' as widgets;
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

    group('setFlashMode', () {
      testWidgets('calls setFlashMode on the camera', (WidgetTester tester) async {
        final camera = MockCamera();
        const FlashMode flashMode = FlashMode.always;

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.setFlashMode(cameraId, flashMode);

        verify(camera.setFlashMode(flashMode)).called(1);
      });

      group('throws PlatformException', () {
        testWidgets('with notFound error '
            'if the camera does not exist', (WidgetTester tester) async {
          expect(
            () => CameraPlatform.instance.setFlashMode(cameraId, FlashMode.always),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when setFlashMode throws DomException', (WidgetTester tester) async {
          final camera = MockCamera();
          final exception = DOMException('NotSupportedError');

          when(camera.setFlashMode(any)).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.setFlashMode(cameraId, FlashMode.always),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });

        testWidgets('when setFlashMode throws CameraWebException', (WidgetTester tester) async {
          final camera = MockCamera();
          final exception = CameraWebException(cameraId, CameraErrorCode.notStarted, 'description');

          when(camera.setFlashMode(any)).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.setFlashMode(cameraId, FlashMode.torch),
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

    testWidgets('setExposureMode throws UnimplementedError', (WidgetTester tester) async {
      expect(
        () => CameraPlatform.instance.setExposureMode(cameraId, ExposureMode.auto),
        throwsUnimplementedError,
      );
    });

    testWidgets('setExposurePoint throws UnimplementedError', (WidgetTester tester) async {
      expect(
        () => CameraPlatform.instance.setExposurePoint(cameraId, const Point<double>(0, 0)),
        throwsUnimplementedError,
      );
    });

    testWidgets('getMinExposureOffset throws UnimplementedError', (WidgetTester tester) async {
      expect(
        () => CameraPlatform.instance.getMinExposureOffset(cameraId),
        throwsUnimplementedError,
      );
    });

    testWidgets('getMaxExposureOffset throws UnimplementedError', (WidgetTester tester) async {
      expect(
        () => CameraPlatform.instance.getMaxExposureOffset(cameraId),
        throwsUnimplementedError,
      );
    });

    testWidgets('getExposureOffsetStepSize throws UnimplementedError', (WidgetTester tester) async {
      expect(
        () => CameraPlatform.instance.getExposureOffsetStepSize(cameraId),
        throwsUnimplementedError,
      );
    });

    testWidgets('setExposureOffset throws UnimplementedError', (WidgetTester tester) async {
      expect(
        () => CameraPlatform.instance.setExposureOffset(cameraId, 0),
        throwsUnimplementedError,
      );
    });

    testWidgets('setFocusMode throws UnimplementedError', (WidgetTester tester) async {
      expect(
        () => CameraPlatform.instance.setFocusMode(cameraId, FocusMode.auto),
        throwsUnimplementedError,
      );
    });

    testWidgets('setFocusPoint throws UnimplementedError', (WidgetTester tester) async {
      expect(
        () => CameraPlatform.instance.setFocusPoint(cameraId, const Point<double>(0, 0)),
        throwsUnimplementedError,
      );
    });

    group('getMaxZoomLevel', () {
      testWidgets('calls getMaxZoomLevel on the camera', (WidgetTester tester) async {
        final camera = MockCamera();
        const maximumZoomLevel = 100.0;

        when(camera.getMaxZoomLevel()).thenReturn(maximumZoomLevel);

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        expect(await CameraPlatform.instance.getMaxZoomLevel(cameraId), equals(maximumZoomLevel));

        verify(camera.getMaxZoomLevel()).called(1);
      });

      group('throws PlatformException', () {
        testWidgets('with notFound error '
            'if the camera does not exist', (WidgetTester tester) async {
          expect(
            () async => CameraPlatform.instance.getMaxZoomLevel(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when getMaxZoomLevel throws DomException', (WidgetTester tester) async {
          final camera = MockCamera();
          final exception = DOMException('NotSupportedError');

          when(camera.getMaxZoomLevel()).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => CameraPlatform.instance.getMaxZoomLevel(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });

        testWidgets('when getMaxZoomLevel throws CameraWebException', (WidgetTester tester) async {
          final camera = MockCamera();
          final exception = CameraWebException(cameraId, CameraErrorCode.notStarted, 'description');

          when(camera.getMaxZoomLevel()).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => CameraPlatform.instance.getMaxZoomLevel(cameraId),
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
      testWidgets('calls getMinZoomLevel on the camera', (WidgetTester tester) async {
        final camera = MockCamera();
        const minimumZoomLevel = 100.0;

        when(camera.getMinZoomLevel()).thenReturn(minimumZoomLevel);

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        expect(await CameraPlatform.instance.getMinZoomLevel(cameraId), equals(minimumZoomLevel));

        verify(camera.getMinZoomLevel()).called(1);
      });

      group('throws PlatformException', () {
        testWidgets('with notFound error '
            'if the camera does not exist', (WidgetTester tester) async {
          expect(
            () async => CameraPlatform.instance.getMinZoomLevel(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when getMinZoomLevel throws DomException', (WidgetTester tester) async {
          final camera = MockCamera();
          final exception = DOMException('NotSupportedError');

          when(camera.getMinZoomLevel()).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => CameraPlatform.instance.getMinZoomLevel(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (PlatformException e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });

        testWidgets('when getMinZoomLevel throws CameraWebException', (WidgetTester tester) async {
          final camera = MockCamera();
          final exception = CameraWebException(cameraId, CameraErrorCode.notStarted, 'description');

          when(camera.getMinZoomLevel()).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => CameraPlatform.instance.getMinZoomLevel(cameraId),
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
      testWidgets('calls setZoomLevel on the camera', (WidgetTester tester) async {
        final camera = MockCamera();

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        const zoom = 100.0;

        await CameraPlatform.instance.setZoomLevel(cameraId, zoom);

        verify(camera.setZoomLevel(zoom)).called(1);
      });

      group('throws CameraException', () {
        testWidgets('with notFound error '
            'if the camera does not exist', (WidgetTester tester) async {
          expect(
            () async => CameraPlatform.instance.setZoomLevel(cameraId, 100.0),
            throwsA(
              isA<CameraException>().having(
                (CameraException e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when setZoomLevel throws DomException', (WidgetTester tester) async {
          final camera = MockCamera();
          final exception = DOMException('NotSupportedError');

          when(camera.setZoomLevel(any)).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => CameraPlatform.instance.setZoomLevel(cameraId, 100.0),
            throwsA(
              isA<CameraException>().having((CameraException e) => e.code, 'code', exception.name),
            ),
          );
        });

        testWidgets('when setZoomLevel throws PlatformException', (WidgetTester tester) async {
          final camera = MockCamera();
          final exception = PlatformException(
            code: CameraErrorCode.notSupported.toString(),
            message: 'message',
          );

          when(camera.setZoomLevel(any)).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => CameraPlatform.instance.setZoomLevel(cameraId, 100.0),
            throwsA(
              isA<CameraException>().having((CameraException e) => e.code, 'code', exception.code),
            ),
          );
        });

        testWidgets('when setZoomLevel throws CameraWebException', (WidgetTester tester) async {
          final camera = MockCamera();
          final exception = CameraWebException(cameraId, CameraErrorCode.notStarted, 'description');

          when(camera.setZoomLevel(any)).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => CameraPlatform.instance.setZoomLevel(cameraId, 100.0),
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
        final camera = MockCamera();

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.pausePreview(cameraId);

        verify(camera.pause()).called(1);
      });

      group('throws PlatformException', () {
        testWidgets('with notFound error '
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

        testWidgets('when pause throws DomException', (WidgetTester tester) async {
          final camera = MockCamera();
          final exception = DOMException('NotSupportedError');

          when(camera.pause()).thenThrow(exception);

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
        final camera = MockCamera();

        when(camera.play()).thenAnswer((_) async {});

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.resumePreview(cameraId);

        verify(camera.play()).called(1);
      });

      group('throws PlatformException', () {
        testWidgets('with notFound error '
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

        testWidgets('when play throws DomException', (WidgetTester tester) async {
          final camera = MockCamera();
          final exception = DOMException('NotSupportedError');

          when(camera.play()).thenThrow(exception);

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

        testWidgets('when play throws CameraWebException', (WidgetTester tester) async {
          final camera = MockCamera();
          final exception = CameraWebException(cameraId, CameraErrorCode.unknown, 'description');

          when(camera.play()).thenThrow(exception);

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

    testWidgets('buildPreview returns an HtmlElementView '
        'with an appropriate view type', (WidgetTester tester) async {
      final camera = Camera(textureId: cameraId, cameraService: cameraService);

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
  });
}
