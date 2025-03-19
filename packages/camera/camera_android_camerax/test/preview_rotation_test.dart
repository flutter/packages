// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/camera_android_camerax.dart';
import 'package:camera_android_camerax/src/camera_selector.dart';
import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/camerax_proxy.dart';
import 'package:camera_android_camerax/src/device_orientation_manager.dart';
import 'package:camera_android_camerax/src/fallback_strategy.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'android_camera_camerax_test.mocks.dart';

// Constants to map clockwise degree rotations to quarter turns:
const int _90DegreesClockwise = 1;
const int _270DegreesClockwise = 3;

void main() {
  /// Sets up mock CameraSelector and mock ProcessCameraProvider used to
  /// select test camera when `availableCameras` is called.
  ///
  /// Also mocks a call for mock ProcessCameraProvider that is irrelevant
  /// to this test.
  ///
  /// Returns mock ProcessCameraProvider that is used to select test camera.
  MockProcessCameraProvider
      setUpMockCameraSelectorAndMockProcessCameraProviderForSelectingTestCamera(
          {required MockCameraSelector mockCameraSelector,
          required int sensorRotationDegrees}) {
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final MockCamera mockCamera = MockCamera();

    // Mock retrieving available test camera.
    when(mockProcessCameraProvider.bindToLifecycle(any, any))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockProcessCameraProvider.getAvailableCameraInfos())
        .thenAnswer((_) async => <MockCameraInfo>[mockCameraInfo]);
    when(mockCameraSelector.filter(<MockCameraInfo>[mockCameraInfo]))
        .thenAnswer((_) async => <MockCameraInfo>[mockCameraInfo]);
    when(mockCameraInfo.getSensorRotationDegrees())
        .thenAnswer((_) async => sensorRotationDegrees);

    // Mock additional ProcessCameraProvider operation that is irrelevant
    // for the tests in this file.
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());

    return mockProcessCameraProvider;
  }

  /// Returns CameraXProxy used to mock all calls to native Android in
  /// the `availableCameras` and `createCameraWithSettings` methods.
  CameraXProxy getProxyForCreatingTestCamera(
          {required MockProcessCameraProvider mockProcessCameraProvider,
          required CameraSelector Function(int) createCameraSelector,
          required bool handlesCropAndRotation,
          required Future<DeviceOrientation> Function() getUiOrientation}) =>
      CameraXProxy(
        getProcessCameraProvider: () async => mockProcessCameraProvider,
        createCameraSelector: createCameraSelector,
        previewSurfaceProducerHandlesCropAndRotation: (_) =>
            Future<bool>.value(handlesCropAndRotation),
        getUiOrientation: getUiOrientation,
        createPreview: (_, __) => MockPreview(),
        createImageCapture: (_, __) => MockImageCapture(),
        createRecorder: (_) => MockRecorder(),
        createVideoCapture: (_) async => MockVideoCapture(),
        createImageAnalysis: (_, __) => MockImageAnalysis(),
        createResolutionStrategy: (
                {bool highestAvailable = false,
                Size? boundSize,
                int? fallbackRule}) =>
            MockResolutionStrategy(),
        createResolutionSelector: (_, __, ___) => MockResolutionSelector(),
        createFallbackStrategy: (
                {required VideoQuality quality,
                required VideoResolutionFallbackRule fallbackRule}) =>
            MockFallbackStrategy(),
        createQualitySelector: (
                {required VideoQuality videoQuality,
                required FallbackStrategy fallbackStrategy}) =>
            MockQualitySelector(),
        createCameraStateObserver: (_) => MockObserver(),
        requestCameraPermissions: (_) => Future<void>.value(),
        startListeningForDeviceOrientationChange: (_, __) {},
        setPreviewSurfaceProvider: (_) => Future<int>.value(
            3), // 3 is a random Flutter SurfaceTexture ID for testing
        createAspectRatioStrategy: (int aspectRatio, int fallbackRule) =>
            MockAspectRatioStrategy(),
        createResolutionFilterWithOnePreferredSize:
            (Size preferredResolution) => MockResolutionFilter(),
      );

  /// Returns function that a CameraXProxy can use to select the front camera.
  MockCameraSelector Function(int cameraSelectorLensDirection)
      createCameraSelectorForFrontCamera(
          MockCameraSelector mockCameraSelector) {
    return (int cameraSelectorLensDirection) {
      switch (cameraSelectorLensDirection) {
        case CameraSelector.lensFacingFront:
          return mockCameraSelector;
        default:
          return MockCameraSelector();
      }
    };
  }

  /// Returns function that a CameraXProxy can use to select the back camera.
  MockCameraSelector Function(int cameraSelectorLensDirection)
      createCameraSelectorForBackCamera(MockCameraSelector mockCameraSelector) {
    return (int cameraSelectorLensDirection) {
      switch (cameraSelectorLensDirection) {
        case CameraSelector.lensFacingBack:
          return mockCameraSelector;
        default:
          return MockCameraSelector();
      }
    };
  }

  /// Error message for detecting an incorrect preview rotation.
  String getExpectedRotationTestFailureReason(
          int expectedQuarterTurns, int actualQuarterTurns) =>
      'Expected the preview to be rotated by $expectedQuarterTurns quarter turns (which is ${expectedQuarterTurns * 90} degrees clockwise) but instead was rotated $actualQuarterTurns quarter turns.';

  testWidgets(
      'when handlesCropAndRotation is true, the preview is an unrotated Texture',
      (WidgetTester tester) async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 537;
    const MediaSettings testMediaSettings =
        MediaSettings(); // media settings irrelevant for test

    // Set up test camera (specifics irrelevant for this test) and
    // tell camera that handlesCropAndRotation is true.
    final MockCameraSelector mockCameraSelector = MockCameraSelector();
    final MockProcessCameraProvider mockProcessCameraProvider =
        setUpMockCameraSelectorAndMockProcessCameraProviderForSelectingTestCamera(
            mockCameraSelector: mockCameraSelector,
            sensorRotationDegrees: /* irrelevant for test */ 90);
    camera.proxy = getProxyForCreatingTestCamera(
        mockProcessCameraProvider: mockProcessCameraProvider,
        createCameraSelector: (_) => mockCameraSelector,
        handlesCropAndRotation: true,
        /* irrelevant for test */ getUiOrientation: () =>
            Future<DeviceOrientation>.value(DeviceOrientation.landscapeLeft));

    // Get and create test camera.
    final List<CameraDescription> availableCameras =
        await camera.availableCameras();
    expect(availableCameras.length, 1);
    await camera.createCameraWithSettings(
        availableCameras.first, testMediaSettings);

    // Put camera preview in widget tree.
    await tester.pumpWidget(camera.buildPreview(cameraId));

    // Verify Texture was built.
    final Texture texture = tester.widget<Texture>(find.byType(Texture));
    expect(texture.textureId, cameraId);

    // Verify RotatedBox was not built and thus, the Texture is not rotated.
    expect(() => tester.widget<RotatedBox>(find.byType(RotatedBox)),
        throwsStateError);
  });

  group('when handlesCropAndRotation is false,', () {
    // Test that preview rotation responds to initial device orientation:
    group('sensor orientation degrees is 270, camera is front facing,', () {
      late AndroidCameraCameraX camera;
      late int cameraId;
      late MockCameraSelector mockFrontCameraSelector;
      late MockCameraSelector Function(int cameraSelectorLensDirection)
          proxyCreateCameraSelectorForFrontCamera;
      late MockProcessCameraProvider mockProcessCameraProviderForFrontCamera;
      late MediaSettings testMediaSettings;

      setUp(() {
        camera = AndroidCameraCameraX();
        cameraId = 27;

        // Create and set up mock CameraSelector and mock ProcessCameraProvider for test front camera
        // with sensor orientation degrees 270.
        mockFrontCameraSelector = MockCameraSelector();
        proxyCreateCameraSelectorForFrontCamera =
            createCameraSelectorForFrontCamera(mockFrontCameraSelector);
        mockProcessCameraProviderForFrontCamera =
            setUpMockCameraSelectorAndMockProcessCameraProviderForSelectingTestCamera(
                mockCameraSelector: mockFrontCameraSelector,
                sensorRotationDegrees: 270);

        // Media settings to create camera; irrelevant for test.
        testMediaSettings = const MediaSettings();
      });

      testWidgets(
          'initial device orientation fixed to DeviceOrientation.portraitUp, then the preview Texture is rotated 270 degrees clockwise',
          (WidgetTester tester) async {
        // Set up test to use front camera, tell camera that handlesCropAndRotation is false,
        // set camera initial device orientation to portrait up.
        camera.proxy = getProxyForCreatingTestCamera(
            mockProcessCameraProvider: mockProcessCameraProviderForFrontCamera,
            createCameraSelector: proxyCreateCameraSelectorForFrontCamera,
            handlesCropAndRotation: false,
            getUiOrientation: () =>
                Future<DeviceOrientation>.value(DeviceOrientation.portraitUp));

        // Get and create test front camera.
        final List<CameraDescription> availableCameras =
            await camera.availableCameras();
        expect(availableCameras.length, 1);
        await camera.createCameraWithSettings(
            availableCameras.first, testMediaSettings);

        // Put camera preview in widget tree.
        await tester.pumpWidget(camera.buildPreview(cameraId));

        // Verify Texture is rotated by ((270 - 0 * 1 + 360) % 360) - 0 = 270 degrees.
        const int expectedQuarterTurns = _270DegreesClockwise;
        final RotatedBox rotatedBox =
            tester.widget<RotatedBox>(find.byType(RotatedBox));
        expect(rotatedBox.child, isA<Texture>());
        expect((rotatedBox.child! as Texture).textureId, cameraId);
        expect(rotatedBox.quarterTurns, expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns, rotatedBox.quarterTurns));
      });

      testWidgets(
          'initial device orientation fixed to DeviceOrientation.landscapeRight, then the preview Texture is rotated 90 degrees clockwise',
          (WidgetTester tester) async {
        // Set up test to use front camera, tell camera that handlesCropAndRotation is false,
        // set camera initial device orientation to landscape right.
        camera.proxy = getProxyForCreatingTestCamera(
            mockProcessCameraProvider: mockProcessCameraProviderForFrontCamera,
            createCameraSelector: proxyCreateCameraSelectorForFrontCamera,
            handlesCropAndRotation: false,
            getUiOrientation: () => Future<DeviceOrientation>.value(
                DeviceOrientation.landscapeRight));

        // Get and create test front camera.
        final List<CameraDescription> availableCameras =
            await camera.availableCameras();
        expect(availableCameras.length, 1);
        await camera.createCameraWithSettings(
            availableCameras.first, testMediaSettings);

        // Put camera preview in widget tree.
        await tester.pumpWidget(camera.buildPreview(cameraId));

        // Verify Texture is rotated by ((90 - 270 * 1 + 360) % 360) - 90 = 90 degrees.
        const int expectedQuarterTurns = _90DegreesClockwise;
        final RotatedBox rotatedBox =
            tester.widget<RotatedBox>(find.byType(RotatedBox));
        expect(rotatedBox.child, isA<Texture>());
        expect((rotatedBox.child! as Texture).textureId, cameraId);
        expect(rotatedBox.quarterTurns, expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns, rotatedBox.quarterTurns));
      });

      testWidgets(
          'initial device orientation fixed to DeviceOrientation.portraitDown, then the preview Texture is rotated 270 degrees clockwise',
          (WidgetTester tester) async {
        // Set up test to use front camera, tell camera that handlesCropAndRotation is false,
        // set camera initial device orientation to portrait down.
        camera.proxy = getProxyForCreatingTestCamera(
            mockProcessCameraProvider: mockProcessCameraProviderForFrontCamera,
            createCameraSelector: proxyCreateCameraSelectorForFrontCamera,
            handlesCropAndRotation: false,
            getUiOrientation: () => Future<DeviceOrientation>.value(
                DeviceOrientation.portraitDown));

        // Get and create test front camera.
        final List<CameraDescription> availableCameras =
            await camera.availableCameras();
        expect(availableCameras.length, 1);
        await camera.createCameraWithSettings(
            availableCameras.first, testMediaSettings);

        // Put camera preview in widget tree.
        await tester.pumpWidget(camera.buildPreview(cameraId));

        // Verify Texture is rotated by ((270 - 180 * 1 + 360) % 360) - 180 = -90 degrees clockwise = 90 degrees counterclockwise = 270 degrees.
        const int expectedQuarterTurns = _270DegreesClockwise;
        final RotatedBox rotatedBox =
            tester.widget<RotatedBox>(find.byType(RotatedBox));
        final int clockwiseQuarterTurns = rotatedBox.quarterTurns + 4;
        expect(rotatedBox.child, isA<Texture>());
        expect((rotatedBox.child! as Texture).textureId, cameraId);
        expect(clockwiseQuarterTurns, expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns, rotatedBox.quarterTurns));
      });

      testWidgets(
          'initial device orientation fixed to DeviceOrientation.landscapeLeft, then the preview Texture is rotated 90 degrees clockwise',
          (WidgetTester tester) async {
        // Set up test to use front camera, tell camera that handlesCropAndRotation is false,
        // set camera initial device orientation to landscape left.
        camera.proxy = getProxyForCreatingTestCamera(
            mockProcessCameraProvider: mockProcessCameraProviderForFrontCamera,
            createCameraSelector: proxyCreateCameraSelectorForFrontCamera,
            handlesCropAndRotation: false,
            getUiOrientation: () => Future<DeviceOrientation>.value(
                DeviceOrientation.landscapeLeft));

        // Get and create test front camera.
        final List<CameraDescription> availableCameras =
            await camera.availableCameras();
        expect(availableCameras.length, 1);
        await camera.createCameraWithSettings(
            availableCameras.first, testMediaSettings);

        // Put camera preview in widget tree.
        await tester.pumpWidget(camera.buildPreview(cameraId));

        // Verify Texture is rotated by ((270 - 270 * 1 + 360) % 360) - 270 = -270 degrees clockwise = 270 degrees counterclockwise = 90 degrees.
        const int expectedQuarterTurns = _90DegreesClockwise;
        final RotatedBox rotatedBox =
            tester.widget<RotatedBox>(find.byType(RotatedBox));
        final int clockwiseQuarterTurns = rotatedBox.quarterTurns + 4;
        expect(rotatedBox.child, isA<Texture>());
        expect((rotatedBox.child! as Texture).textureId, cameraId);
        expect(clockwiseQuarterTurns, expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns, rotatedBox.quarterTurns));
      });
    });

    testWidgets(
        'sensor orientation degrees is 90, camera is front facing, then the preview Texture rotates correctly as the device orientation rotates',
        (WidgetTester tester) async {
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const int cameraId = 3372;

      // Create and set up mock CameraSelector and mock ProcessCameraProvider for test front camera
      // with sensor orientation degrees 90.
      final MockCameraSelector mockFrontCameraSelector = MockCameraSelector();
      final MockCameraSelector Function(int cameraSelectorLensDirection)
          proxyCreateCameraSelectorForFrontCamera =
          createCameraSelectorForFrontCamera(mockFrontCameraSelector);
      final MockProcessCameraProvider mockProcessCameraProviderForFrontCamera =
          setUpMockCameraSelectorAndMockProcessCameraProviderForSelectingTestCamera(
              mockCameraSelector: mockFrontCameraSelector,
              sensorRotationDegrees: 90);

      // Media settings to create camera; irrelevant for test.
      const MediaSettings testMediaSettings = MediaSettings();

      // Set up test to use front camera and tell camera that handlesCropAndRotation is false,
      // set camera initial device orientation to landscape left.
      camera.proxy = getProxyForCreatingTestCamera(
          mockProcessCameraProvider: mockProcessCameraProviderForFrontCamera,
          createCameraSelector: proxyCreateCameraSelectorForFrontCamera,
          handlesCropAndRotation: false,
          getUiOrientation: /* initial device orientation irrelevant for test */
              () => Future<DeviceOrientation>.value(
                  DeviceOrientation.landscapeLeft));

      // Get and create test front camera.
      final List<CameraDescription> availableCameras =
          await camera.availableCameras();
      expect(availableCameras.length, 1);
      await camera.createCameraWithSettings(
          availableCameras.first, testMediaSettings);

      // Calculated according to:
      // ((90 - currentDeviceOrientation * 1 + 360) % 360) - currentDeviceOrientation.
      final Map<DeviceOrientation, int> expectedRotationPerDeviceOrientation =
          <DeviceOrientation, int>{
        DeviceOrientation.portraitUp: _90DegreesClockwise,
        DeviceOrientation.landscapeRight: _270DegreesClockwise,
        DeviceOrientation.portraitDown: _90DegreesClockwise,
        DeviceOrientation.landscapeLeft: _270DegreesClockwise,
      };

      // Put camera preview in widget tree.
      await tester.pumpWidget(camera.buildPreview(cameraId));

      for (final DeviceOrientation currentDeviceOrientation
          in expectedRotationPerDeviceOrientation.keys) {
        final DeviceOrientationChangedEvent testEvent =
            DeviceOrientationChangedEvent(currentDeviceOrientation);
        DeviceOrientationManager.deviceOrientationChangedStreamController
            .add(testEvent);

        await tester.pumpAndSettle();

        // Verify Texture is rotated by expected clockwise degrees.
        final int expectedQuarterTurns =
            expectedRotationPerDeviceOrientation[currentDeviceOrientation]!;
        final RotatedBox rotatedBox =
            tester.widget<RotatedBox>(find.byType(RotatedBox));
        final int clockwiseQuarterTurns = rotatedBox.quarterTurns < 0
            ? rotatedBox.quarterTurns + 4
            : rotatedBox.quarterTurns;
        expect(rotatedBox.child, isA<Texture>());
        expect((rotatedBox.child! as Texture).textureId, cameraId);
        expect(clockwiseQuarterTurns, expectedQuarterTurns,
            reason:
                'When the device orientation is $currentDeviceOrientation, expected the preview to be rotated by $expectedQuarterTurns quarter turns (which is ${expectedQuarterTurns * 90} degrees clockwise) but instead was rotated ${rotatedBox.quarterTurns} quarter turns.');
      }

      await DeviceOrientationManager.deviceOrientationChangedStreamController
          .close();
    });

    // Test the preview rotation responds to the two most common sensor orientations for Android phone cameras; see
    // https://developer.android.com/media/camera/camera2/camera-preview#camera_orientation.
    group(
        'initial device orientation is DeviceOrientation.landscapeLeft, camera is back facing,',
        () {
      late AndroidCameraCameraX camera;
      late int cameraId;
      late MockCameraSelector mockBackCameraSelector;
      late MockCameraSelector Function(int cameraSelectorLensDirection)
          proxyCreateCameraSelectorForBackCamera;
      late MediaSettings testMediaSettings;
      late DeviceOrientation testInitialDeviceOrientation;

      setUp(() {
        camera = AndroidCameraCameraX();
        cameraId = 347;

        // Set test camera initial device orientation for test.
        testInitialDeviceOrientation = DeviceOrientation.landscapeLeft;

        // Create and set up mock CameraSelector and mock ProcessCameraProvider for test back camera
        // with sensor orientation degrees 270.
        mockBackCameraSelector = MockCameraSelector();
        proxyCreateCameraSelectorForBackCamera =
            createCameraSelectorForBackCamera(mockBackCameraSelector);

        testMediaSettings = const MediaSettings();
      });

      testWidgets(
          'sensor orientation degrees is 90, then the preview Texture is rotated 90 degrees clockwise',
          (WidgetTester tester) async {
        // Create mock ProcessCameraProvider that will acknowledge that the test back camera with sensor orientation degrees
        // 90 is available.
        final MockProcessCameraProvider mockProcessCameraProviderForBackCamera =
            setUpMockCameraSelectorAndMockProcessCameraProviderForSelectingTestCamera(
                mockCameraSelector: mockBackCameraSelector,
                sensorRotationDegrees: 90);

        // Set up test to use back camera, tell camera that handlesCropAndRotation is false,
        // set camera initial device orientation to landscape left.
        camera.proxy = getProxyForCreatingTestCamera(
            mockProcessCameraProvider: mockProcessCameraProviderForBackCamera,
            createCameraSelector: proxyCreateCameraSelectorForBackCamera,
            handlesCropAndRotation: false,
            getUiOrientation: () =>
                Future<DeviceOrientation>.value(testInitialDeviceOrientation));

        // Get and create test back camera.
        final List<CameraDescription> availableCameras =
            await camera.availableCameras();
        expect(availableCameras.length, 1);
        await camera.createCameraWithSettings(
            availableCameras.first, testMediaSettings);

        // Put camera preview in widget tree.
        await tester.pumpWidget(camera.buildPreview(cameraId));

        // Verify Texture is rotated by ((90 - 270 * -1 + 360) % 360) - 270 = -270 degrees clockwise = 270 degrees counterclockwise = 90 degrees clockwise.
        const int expectedQuarterTurns = _90DegreesClockwise;
        final RotatedBox rotatedBox =
            tester.widget<RotatedBox>(find.byType(RotatedBox));
        final int clockwiseQuarterTurns = rotatedBox.quarterTurns + 4;
        expect(rotatedBox.child, isA<Texture>());
        expect((rotatedBox.child! as Texture).textureId, cameraId);
        expect(clockwiseQuarterTurns, expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns, rotatedBox.quarterTurns));
      });

      testWidgets(
          'sensor orientation degrees is 270, then the preview Texture is rotated 270 degrees clockwise',
          (WidgetTester tester) async {
        // Create mock ProcessCameraProvider that will acknowledge that the test back camera with sensor orientation degrees
        // 270 is available.
        final MockProcessCameraProvider mockProcessCameraProviderForBackCamera =
            setUpMockCameraSelectorAndMockProcessCameraProviderForSelectingTestCamera(
                mockCameraSelector: mockBackCameraSelector,
                sensorRotationDegrees: 270);

        // Set up test to use back camera, tell camera that handlesCropAndRotation is false,
        // set camera initial device orientation to landscape left.
        camera.proxy = getProxyForCreatingTestCamera(
            mockProcessCameraProvider: mockProcessCameraProviderForBackCamera,
            createCameraSelector: proxyCreateCameraSelectorForBackCamera,
            handlesCropAndRotation: false,
            getUiOrientation: () =>
                Future<DeviceOrientation>.value(testInitialDeviceOrientation));

        // Get and create test back camera.
        final List<CameraDescription> availableCameras =
            await camera.availableCameras();
        expect(availableCameras.length, 1);
        await camera.createCameraWithSettings(
            availableCameras.first, testMediaSettings);

        // Put camera preview in widget tree.
        await tester.pumpWidget(camera.buildPreview(cameraId));

        // Verify Texture is rotated by ((270 - 270 * -1 + 360) % 360) - 270 = -90 degrees clockwise = 90 degrees counterclockwise = 270 degrees clockwise.
        const int expectedQuarterTurns = _270DegreesClockwise;
        final RotatedBox rotatedBox =
            tester.widget<RotatedBox>(find.byType(RotatedBox));
        final int clockwiseQuarterTurns = rotatedBox.quarterTurns + 4;
        expect(rotatedBox.child, isA<Texture>());
        expect((rotatedBox.child! as Texture).textureId, cameraId);
        expect(clockwiseQuarterTurns, expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns, rotatedBox.quarterTurns));
      });
    });

    // Test the preview rotation responds to the camera being front or back facing:
    group(
        'initial device orientation is DeviceOrientation.landscapeRight, sensor orientation degrees is 90,',
        () {
      late AndroidCameraCameraX camera;
      late int cameraId;
      late MediaSettings testMediaSettings;
      late DeviceOrientation testInitialDeviceOrientation;
      late int testSensorOrientation;

      setUp(() {
        camera = AndroidCameraCameraX();
        cameraId = 317;

        // Set test camera initial device orientation and sensor orientation for test.
        testInitialDeviceOrientation = DeviceOrientation.landscapeRight;
        testSensorOrientation = 90;

        // Media settings to create camera; irrelevant for test.
        testMediaSettings = const MediaSettings();
      });

      testWidgets(
          'camera is front facing, then the preview Texture is rotated 270 degrees clockwise',
          (WidgetTester tester) async {
        // Set up test front camera with sensor orientation degrees 90.
        final MockCameraSelector mockFrontCameraSelector = MockCameraSelector();
        final MockProcessCameraProvider mockProcessCameraProvider =
            setUpMockCameraSelectorAndMockProcessCameraProviderForSelectingTestCamera(
                mockCameraSelector: mockFrontCameraSelector,
                sensorRotationDegrees: testSensorOrientation);

        // Set up front camera selection and initial device orientation as landscape right.
        final MockCameraSelector Function(int cameraSelectorLensDirection)
            proxyCreateCameraSelectorForFrontCamera =
            createCameraSelectorForFrontCamera(mockFrontCameraSelector);
        camera.proxy = getProxyForCreatingTestCamera(
            mockProcessCameraProvider: mockProcessCameraProvider,
            createCameraSelector: proxyCreateCameraSelectorForFrontCamera,
            handlesCropAndRotation: false,
            getUiOrientation: () =>
                Future<DeviceOrientation>.value(testInitialDeviceOrientation));

        // Get and create test camera.
        final List<CameraDescription> availableCameras =
            await camera.availableCameras();
        expect(availableCameras.length, 1);
        await camera.createCameraWithSettings(
            availableCameras.first, testMediaSettings);

        // Put camera preview in widget tree.
        await tester.pumpWidget(camera.buildPreview(cameraId));

        // Verify Texture is rotated by ((90 - 90 * 1 + 360) % 360) - 90 = -90 degrees clockwise = 90 degrees counterclockwise = 270 degrees clockwise.
        const int expectedQuarterTurns = _270DegreesClockwise;
        final RotatedBox rotatedBox =
            tester.widget<RotatedBox>(find.byType(RotatedBox));
        final int clockwiseQuarterTurns = rotatedBox.quarterTurns + 4;
        expect(rotatedBox.child, isA<Texture>());
        expect((rotatedBox.child! as Texture).textureId, cameraId);
        expect(clockwiseQuarterTurns, expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns, rotatedBox.quarterTurns));
      });

      testWidgets(
          'camera is back facing, then the preview Texture is rotated 90 degrees clockwise',
          (WidgetTester tester) async {
        // Set up test front camera with sensor orientation degrees 90.
        final MockCameraSelector mockBackCameraSelector = MockCameraSelector();
        final MockProcessCameraProvider mockProcessCameraProvider =
            setUpMockCameraSelectorAndMockProcessCameraProviderForSelectingTestCamera(
                mockCameraSelector: mockBackCameraSelector,
                sensorRotationDegrees: testSensorOrientation);

        // Set up front camera selection and initial device orientation as landscape right.
        final MockCameraSelector Function(int cameraSelectorLensDirection)
            proxyCreateCameraSelectorForFrontCamera =
            createCameraSelectorForBackCamera(mockBackCameraSelector);
        camera.proxy = getProxyForCreatingTestCamera(
            mockProcessCameraProvider: mockProcessCameraProvider,
            createCameraSelector: proxyCreateCameraSelectorForFrontCamera,
            handlesCropAndRotation: false,
            getUiOrientation: () =>
                Future<DeviceOrientation>.value(testInitialDeviceOrientation));

        // Get and create test camera.
        final List<CameraDescription> availableCameras =
            await camera.availableCameras();
        expect(availableCameras.length, 1);
        await camera.createCameraWithSettings(
            availableCameras.first, testMediaSettings);

        // Put camera preview in widget tree.
        await tester.pumpWidget(camera.buildPreview(cameraId));

        // Verify Texture is rotated by ((90 - 90 * -1 + 360) % 360) - 90 = 90 degrees clockwise.
        const int expectedQuarterTurns = _90DegreesClockwise;
        final RotatedBox rotatedBox =
            tester.widget<RotatedBox>(find.byType(RotatedBox));
        expect(rotatedBox.child, isA<Texture>());
        expect((rotatedBox.child! as Texture).textureId, cameraId);
        expect(rotatedBox.quarterTurns, expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns, rotatedBox.quarterTurns));
      });
    });
  });
}
