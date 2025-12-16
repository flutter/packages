// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/camera_android_camerax.dart';
import 'package:camera_android_camerax/src/camerax_library.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart'
    show MatrixUtils, RotatedBox, Texture, Transform;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'android_camera_camerax_test.mocks.dart';

// Constants to map clockwise degree rotations to quarter turns:
const int _0DegreesClockwise = 0;
const int _90DegreesClockwise = 1;
const int _180DegreesClockwise = 2;
const int _270DegreesClockwise = 3;

// Serialize DeviceOrientations to Strings.
String _serializeDeviceOrientation(DeviceOrientation orientation) {
  switch (orientation) {
    case DeviceOrientation.portraitUp:
      return 'PORTRAIT_UP';
    case DeviceOrientation.landscapeLeft:
      return 'LANDSCAPE_LEFT';
    case DeviceOrientation.portraitDown:
      return 'PORTRAIT_DOWN';
    case DeviceOrientation.landscapeRight:
      return 'LANDSCAPE_RIGHT';
  }
}

void main() {
  tearDownAll(() {
    AndroidCameraCameraX.deviceOrientationChangedStreamController.close();
  });

  setUp(() {
    PigeonOverrides.pigeon_reset();
    GenericsPigeonOverrides.reset();
  });

  /// Sets up mock CameraSelector and mock ProcessCameraProvider used to
  /// select test camera when `availableCameras` is called.
  ///
  /// Also mocks a call for mock ProcessCameraProvider that is irrelevant
  /// to this test.
  ///
  /// Returns mock ProcessCameraProvider that is used to select test camera.
  MockProcessCameraProvider
  setUpMockCameraSelectorAndMockProcessCameraProviderForSelectingTestCamera({
    required MockCameraSelector mockCameraSelector,
    required int sensorRotationDegrees,
  }) {
    final mockProcessCameraProvider = MockProcessCameraProvider();
    final mockCameraInfo = MockCameraInfo();
    final mockCamera = MockCamera();

    // Mock retrieving available test camera.
    when(
      mockProcessCameraProvider.bindToLifecycle(any, any),
    ).thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(
      mockProcessCameraProvider.getAvailableCameraInfos(),
    ).thenAnswer((_) async => <MockCameraInfo>[mockCameraInfo]);
    when(
      mockCameraSelector.filter(<MockCameraInfo>[mockCameraInfo]),
    ).thenAnswer((_) async => <MockCameraInfo>[mockCameraInfo]);
    when(
      mockCameraInfo.sensorRotationDegrees,
    ).thenReturn(sensorRotationDegrees);

    // Mock additional ProcessCameraProvider operation that is irrelevant
    // for the tests in this file.
    when(
      mockCameraInfo.getCameraState(),
    ).thenAnswer((_) async => MockLiveCameraState());

    return mockProcessCameraProvider;
  }

  /// Set up overrides used to mock all calls to native Android in
  /// the `availableCameras` and `createCameraWithSettings` methods, with
  /// a DeviceORientationManager specified.
  ///
  /// Useful for tests that need a reference to a DeviceOrientationManager.
  void setUpOverridesForCreatingTestCameraWithDeviceOrientationManager(
    DeviceOrientationManager deviceOrientationManager, {
    required MockProcessCameraProvider mockProcessCameraProvider,
    required CameraSelector Function({
      LensFacing? requireLensFacing,
      dynamic cameraInfoForFilter,
    })
    createCameraSelector,
    required bool handlesCropAndRotation,
  }) {
    PigeonOverrides.processCameraProvider_getInstance = () async =>
        mockProcessCameraProvider;
    PigeonOverrides.cameraSelector_new = createCameraSelector;
    PigeonOverrides.preview_new =
        ({
          int? targetRotation,
          CameraIntegerRange? targetFpsRange,
          ResolutionSelector? resolutionSelector,
        }) {
          final preview = MockPreview();
          when(
            preview.surfaceProducerHandlesCropAndRotation(),
          ).thenAnswer((_) async => handlesCropAndRotation);
          when(preview.getResolutionInfo()).thenAnswer(
            (_) async =>
                ResolutionInfo.pigeon_detached(resolution: MockCameraSize()),
          );
          return preview;
        };
    PigeonOverrides.imageCapture_new =
        ({
          int? targetRotation,
          CameraXFlashMode? flashMode,
          ResolutionSelector? resolutionSelector,
        }) => MockImageCapture();
    PigeonOverrides.recorder_new =
        ({
          int? aspectRatio,
          int? targetVideoEncodingBitRate,
          QualitySelector? qualitySelector,
        }) => MockRecorder();
    PigeonOverrides.videoCapture_withOutput =
        ({
          required VideoOutput videoOutput,
          CameraIntegerRange? targetFpsRange,
        }) {
          return MockVideoCapture();
        };
    PigeonOverrides.imageAnalysis_new =
        ({
          int? targetRotation,
          CameraIntegerRange? targetFpsRange,
          ResolutionSelector? resolutionSelector,
          int? outputImageFormat,
        }) {
          return MockImageAnalysis();
        };
    PigeonOverrides.resolutionStrategy_new =
        ({
          required CameraSize boundSize,
          required ResolutionStrategyFallbackRule fallbackRule,
        }) {
          return MockResolutionStrategy();
        };
    PigeonOverrides.resolutionSelector_new =
        ({
          AspectRatioStrategy? aspectRatioStrategy,
          ResolutionStrategy? resolutionStrategy,
          ResolutionFilter? resolutionFilter,
        }) {
          return MockResolutionSelector();
        };
    PigeonOverrides.fallbackStrategy_lowerQualityOrHigherThan =
        ({required VideoQuality quality}) {
          return MockFallbackStrategy();
        };
    PigeonOverrides.fallbackStrategy_lowerQualityThan =
        ({required VideoQuality quality}) {
          return MockFallbackStrategy();
        };
    PigeonOverrides.camera2CameraInfo_from = ({required dynamic cameraInfo}) {
      final camera2cameraInfo = MockCamera2CameraInfo();
      when(
        camera2cameraInfo.getCameraCharacteristic(any),
      ).thenAnswer((_) async => 90);
      return camera2cameraInfo;
    };
    PigeonOverrides.qualitySelector_from =
        ({required VideoQuality quality, FallbackStrategy? fallbackStrategy}) {
          return MockQualitySelector();
        };
    GenericsPigeonOverrides.observerNew =
        <T>({required void Function(Observer<T>, T) onChanged}) {
          return Observer<T>.detached(onChanged: onChanged);
        };
    PigeonOverrides.systemServicesManager_new =
        ({
          required void Function(SystemServicesManager, String) onCameraError,
        }) {
          return MockSystemServicesManager();
        };
    PigeonOverrides.deviceOrientationManager_new =
        ({
          required void Function(DeviceOrientationManager, String)
          onDeviceOrientationChanged,
        }) => deviceOrientationManager;
    PigeonOverrides.aspectRatioStrategy_new =
        ({
          required AspectRatio preferredAspectRatio,
          required AspectRatioStrategyFallbackRule fallbackRule,
        }) {
          final mockAspectRatioStrategy = MockAspectRatioStrategy();
          when(
            mockAspectRatioStrategy.getFallbackRule(),
          ).thenAnswer((_) async => fallbackRule);
          when(
            mockAspectRatioStrategy.getPreferredAspectRatio(),
          ).thenAnswer((_) async => preferredAspectRatio);
          return mockAspectRatioStrategy;
        };
    PigeonOverrides.resolutionFilter_createWithOnePreferredSize =
        ({required CameraSize preferredSize}) {
          return MockResolutionFilter();
        };
  }

  /// Set up overrides used to mock all calls to native Android in
  /// the `availableCameras` and `createCameraWithSettings` methods, with
  /// functions `getUiOrientation` and `getDefaultDisplayRotation` specified
  /// to create a mock DeviceOrientationManager.
  ///
  /// Useful for tests that do not need a reference to a DeviceOrientationManager.
  void setUpOverridesForCreatingTestCamera({
    required MockProcessCameraProvider mockProcessCameraProvider,
    required CameraSelector Function({
      LensFacing? requireLensFacing,
      dynamic cameraInfoForFilter,
    })
    createCameraSelector,
    required bool handlesCropAndRotation,
    required Future<String> Function() getUiOrientation,
    required Future<int> Function() getDefaultDisplayRotation,
  }) {
    final deviceOrientationManager = MockDeviceOrientationManager();
    when(
      deviceOrientationManager.getUiOrientation(),
    ).thenAnswer((_) => getUiOrientation());
    when(
      deviceOrientationManager.getDefaultDisplayRotation(),
    ).thenAnswer((_) => getDefaultDisplayRotation());
    setUpOverridesForCreatingTestCameraWithDeviceOrientationManager(
      deviceOrientationManager,
      mockProcessCameraProvider: mockProcessCameraProvider,
      createCameraSelector: createCameraSelector,
      handlesCropAndRotation: handlesCropAndRotation,
    );
  }

  /// Returns function that a CameraXProxy can use to select the front camera.
  MockCameraSelector Function({
    LensFacing? requireLensFacing,
    dynamic cameraInfoForFilter,
  })
  createCameraSelectorForFrontCamera(MockCameraSelector mockCameraSelector) {
    return ({LensFacing? requireLensFacing, dynamic cameraInfoForFilter}) {
      switch (requireLensFacing) {
        case LensFacing.front:
          return mockCameraSelector;
        case LensFacing.back:
        case LensFacing.external:
        case LensFacing.unknown:
        case null:
          return MockCameraSelector();
      }
    };
  }

  /// Returns function that a CameraXProxy can use to select the back camera.
  MockCameraSelector Function({
    LensFacing? requireLensFacing,
    dynamic cameraInfoForFilter,
  })
  createCameraSelectorForBackCamera(MockCameraSelector mockCameraSelector) {
    return ({LensFacing? requireLensFacing, dynamic cameraInfoForFilter}) {
      switch (requireLensFacing) {
        case LensFacing.back:
          return mockCameraSelector;
        case LensFacing.front:
        case LensFacing.external:
        case LensFacing.unknown:
        case null:
          return MockCameraSelector();
      }
    };
  }

  /// Error message for detecting an incorrect preview rotation.
  String getExpectedRotationTestFailureReason(
    int expectedQuarterTurns,
    int actualQuarterTurns,
  ) =>
      'Expected the preview to be rotated by $expectedQuarterTurns quarter turns (which is ${expectedQuarterTurns * 90} degrees clockwise) but instead was rotated $actualQuarterTurns quarter turns.';

  /// Checks that the transform matrix (Matrix4) mirrors across the x-axis by
  /// confirming the following to be the transformation matrix:
  /// [[-1.0,  0.0,  0.0,  0.0],
  ///  [ 0.0,  1.0,  0.0,  0.0],
  ///  [ 0.0,  0.0,  1.0,  0.0],
  ///  [ 0.0,  0.0,  0.0,  1.0]]
  void checkXAxisIsMirrored(Matrix4 transformationMatrix) {
    final mirrorAcrossXMatrix = Matrix4(
      -1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
    );

    expect(
      MatrixUtils.matrixEquals(mirrorAcrossXMatrix, transformationMatrix),
      isTrue,
    );
  }

  /// Checks that the transform matrix (Matrix4) mirrors across the y-axis by
  /// confirming the following to be the transformation matrix:
  /// [[1.0,  0.0,  0.0,  0.0],
  ///  [ 0.0,  -1.0,  0.0,  0.0],
  ///  [ 0.0,  0.0,  1.0,  0.0],
  ///  [ 0.0,  0.0,  0.0,  1.0]]
  void checkYAxisIsMirrored(Matrix4 transformationMatrix) {
    final mirrorAcrossYMatrix = Matrix4(
      1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      -1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
    );

    expect(
      MatrixUtils.matrixEquals(mirrorAcrossYMatrix, transformationMatrix),
      isTrue,
    );
  }

  group('when handlesCropAndRotation is true', () {
    // Test that preview rotation responds to initial default display rotation:
    group('initial device orientation is landscapeRight,', () {
      final mockCameraSelector = MockCameraSelector();
      late AndroidCameraCameraX camera;
      late int cameraId;
      late DeviceOrientation testInitialDeviceOrientation;
      late MockProcessCameraProvider mockProcessCameraProvider;
      late MockCameraSelector Function({
        LensFacing? requireLensFacing,
        dynamic cameraInfoForFilter,
      })
      fakeCreateCameraSelector;
      late MediaSettings testMediaSettings;

      setUp(() {
        camera = AndroidCameraCameraX();
        cameraId = 7;

        // Set test camera initial device orientation for test.
        testInitialDeviceOrientation = DeviceOrientation.landscapeRight;

        // Set up test camera and fake camera selector (specifics irrelevant for this test).
        mockProcessCameraProvider =
            setUpMockCameraSelectorAndMockProcessCameraProviderForSelectingTestCamera(
              mockCameraSelector: mockCameraSelector,
              sensorRotationDegrees: /* irrelevant for test */ 90,
            );
        fakeCreateCameraSelector = createCameraSelectorForBackCamera(
          mockCameraSelector,
        );

        // Media settings to create camera; irrelevant for test.
        testMediaSettings = const MediaSettings();
      });

      testWidgets(
        'initial default display rotation is 0 degrees clockwise, then the preview Texture is rotation 270 degrees clockwise',
        (WidgetTester tester) async {
          // Mock calls to CameraXProxy. Most importantly, tell camera that handlesCropAndRotation is true, set initial device
          // orientation to landscape right, and set initial default display rotation to 0 degrees clockwise.
          setUpOverridesForCreatingTestCamera(
            mockProcessCameraProvider: mockProcessCameraProvider,
            createCameraSelector: fakeCreateCameraSelector,
            handlesCropAndRotation: true,
            getUiOrientation: () async =>
                _serializeDeviceOrientation(testInitialDeviceOrientation),
            getDefaultDisplayRotation: () =>
                Future<int>.value(Surface.rotation0),
          );

          // Get and create test camera.
          final List<CameraDescription> availableCameras = await camera
              .availableCameras();
          expect(availableCameras.length, 1);
          final int flutterSurfaceTextureId = await camera
              .createCameraWithSettings(
                availableCameras.first,
                testMediaSettings,
              );
          await camera.initializeCamera(flutterSurfaceTextureId);

          // Put camera preview in widget tree and pump one frame so that Future to retrieve
          // the initial default display rotation completes.
          await tester.pumpWidget(camera.buildPreview(cameraId));
          await tester.pump();

          // Verify Texture was built.
          final Texture texture = tester.widget<Texture>(find.byType(Texture));
          expect(texture.textureId, cameraId);

          // Verify Texture is rotated by 0 - 90 = -90 degrees clockwise = 270 degrees clockwise.
          const int expectedQuarterTurns = _270DegreesClockwise;
          final RotatedBox rotatedBox = tester.widget<RotatedBox>(
            find.byType(RotatedBox),
          );
          final int clockwiseQuarterTurns = rotatedBox.quarterTurns + 4;

          expect(rotatedBox.child, isA<Texture>());
          expect((rotatedBox.child! as Texture).textureId, cameraId);
          expect(
            clockwiseQuarterTurns,
            expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
              expectedQuarterTurns,
              rotatedBox.quarterTurns,
            ),
          );
        },
      );

      testWidgets(
        'initial default display rotation is 90 degrees clockwise, then the preview Texture is rotation 180 degrees clockwise',
        (WidgetTester tester) async {
          // Mock calls to CameraXProxy. Most importantly, tell camera that handlesCropAndRotation is true, set initial device
          // orientation to landscape right, and set initial default display rotation to 90 degrees clockwise.
          setUpOverridesForCreatingTestCamera(
            mockProcessCameraProvider: mockProcessCameraProvider,
            createCameraSelector: fakeCreateCameraSelector,
            handlesCropAndRotation: true,
            getUiOrientation: () async =>
                _serializeDeviceOrientation(testInitialDeviceOrientation),
            getDefaultDisplayRotation: () =>
                Future<int>.value(Surface.rotation90),
          );

          // Get and create test camera.
          final List<CameraDescription> availableCameras = await camera
              .availableCameras();
          expect(availableCameras.length, 1);
          final int flutterSurfaceTextureId = await camera
              .createCameraWithSettings(
                availableCameras.first,
                testMediaSettings,
              );
          await camera.initializeCamera(flutterSurfaceTextureId);

          // Put camera preview in widget tree and pump one frame so that Future to retrieve
          // the initial default display rotation completes.
          await tester.pumpWidget(camera.buildPreview(cameraId));
          await tester.pump();

          // Verify Texture was built.
          final Texture texture = tester.widget<Texture>(find.byType(Texture));
          expect(texture.textureId, cameraId);

          // Verify Texture is rotated by 270 - 90 = 180 degrees clockwise.
          const int expectedQuarterTurns = _180DegreesClockwise;
          final RotatedBox rotatedBox = tester.widget<RotatedBox>(
            find.byType(RotatedBox),
          );

          expect(rotatedBox.child, isA<Texture>());
          expect((rotatedBox.child! as Texture).textureId, cameraId);
          expect(
            rotatedBox.quarterTurns,
            expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
              expectedQuarterTurns,
              rotatedBox.quarterTurns,
            ),
          );
        },
      );
      testWidgets(
        'initial default display rotation is 180 degrees clockwise, then the preview Texture is rotation 90 degrees clockwise',
        (WidgetTester tester) async {
          // Mock calls to CameraXProxy. Most importantly, tell camera that handlesCropAndRotation is true, set initial device
          // orientation to landscape right, and set initial default display rotation to 180 degrees clockwise.
          setUpOverridesForCreatingTestCamera(
            mockProcessCameraProvider: mockProcessCameraProvider,
            createCameraSelector: fakeCreateCameraSelector,
            handlesCropAndRotation: true,
            getUiOrientation: () async =>
                _serializeDeviceOrientation(testInitialDeviceOrientation),
            getDefaultDisplayRotation: () =>
                Future<int>.value(Surface.rotation180),
          );

          // Get and create test camera.
          final List<CameraDescription> availableCameras = await camera
              .availableCameras();
          expect(availableCameras.length, 1);
          final int flutterSurfaceTextureId = await camera
              .createCameraWithSettings(
                availableCameras.first,
                testMediaSettings,
              );
          await camera.initializeCamera(flutterSurfaceTextureId);

          // Put camera preview in widget tree and pump one frame so that Future to retrieve
          // the initial default display rotation completes.
          await tester.pumpWidget(camera.buildPreview(cameraId));
          await tester.pump();

          // Verify Texture was built.
          final Texture texture = tester.widget<Texture>(find.byType(Texture));
          expect(texture.textureId, cameraId);

          // Verify Texture is rotated by 180 - 90 = 90 degrees clockwise.
          const int expectedQuarterTurns = _90DegreesClockwise;
          final RotatedBox rotatedBox = tester.widget<RotatedBox>(
            find.byType(RotatedBox),
          );

          expect(rotatedBox.child, isA<Texture>());
          expect((rotatedBox.child! as Texture).textureId, cameraId);
          expect(
            rotatedBox.quarterTurns,
            expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
              expectedQuarterTurns,
              rotatedBox.quarterTurns,
            ),
          );
        },
      );
      testWidgets(
        'initial default display rotation is 270 degrees clockwise, then the preview Texture is rotation 0 degrees clockwise',
        (WidgetTester tester) async {
          // Mock calls to CameraXProxy. Most importantly, tell camera that handlesCropAndRotation is true, set initial device
          // orientation to landscape right, and set initial default display rotation to 270 degrees clockwise.
          setUpOverridesForCreatingTestCamera(
            mockProcessCameraProvider: mockProcessCameraProvider,
            createCameraSelector: fakeCreateCameraSelector,
            handlesCropAndRotation: true,
            getUiOrientation: () async =>
                _serializeDeviceOrientation(testInitialDeviceOrientation),
            getDefaultDisplayRotation: () =>
                Future<int>.value(Surface.rotation270),
          );

          // Get and create test camera.
          final List<CameraDescription> availableCameras = await camera
              .availableCameras();
          expect(availableCameras.length, 1);
          final int flutterSurfaceTextureId = await camera
              .createCameraWithSettings(
                availableCameras.first,
                testMediaSettings,
              );
          await camera.initializeCamera(flutterSurfaceTextureId);

          // Put camera preview in widget tree and pump one frame so that Future to retrieve
          // the initial default display rotation completes.
          await tester.pumpWidget(camera.buildPreview(cameraId));
          await tester.pump();

          // Verify Texture was built.
          final Texture texture = tester.widget<Texture>(find.byType(Texture));
          expect(texture.textureId, cameraId);

          // Verify Texture is rotated by 90 - 90 = 0 degrees.
          const int expectedQuarterTurns = _0DegreesClockwise;
          final RotatedBox rotatedBox = tester.widget<RotatedBox>(
            find.byType(RotatedBox),
          );

          expect(rotatedBox.child, isA<Texture>());
          expect((rotatedBox.child! as Texture).textureId, cameraId);
          expect(
            rotatedBox.quarterTurns,
            expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
              expectedQuarterTurns,
              rotatedBox.quarterTurns,
            ),
          );
        },
      );
    });

    // Test that preview rotation responds to initial device orientation:
    group('initial default display rotation is 90,', () {
      final mockCameraSelector = MockCameraSelector();
      late AndroidCameraCameraX camera;
      late int cameraId;
      late int testInitialDefaultDisplayRotation;
      late MockProcessCameraProvider mockProcessCameraProvider;
      late MockCameraSelector Function({
        LensFacing? requireLensFacing,
        dynamic cameraInfoForFilter,
      })
      fakeCreateCameraSelector;
      late MediaSettings testMediaSettings;

      setUp(() {
        camera = AndroidCameraCameraX();
        cameraId = 7;

        // Set test camera initial default display rotation for test.
        testInitialDefaultDisplayRotation = Surface.rotation90;

        // Set up test camera (specifics irrelevant for this test).
        mockProcessCameraProvider =
            setUpMockCameraSelectorAndMockProcessCameraProviderForSelectingTestCamera(
              mockCameraSelector: mockCameraSelector,
              sensorRotationDegrees: /* irrelevant for test */ 90,
            );
        fakeCreateCameraSelector = createCameraSelectorForBackCamera(
          mockCameraSelector,
        );

        // Media settings to create camera; irrelevant for test.
        testMediaSettings = const MediaSettings();
      });

      testWidgets(
        'initial device orientation is portraitUp, then the preview Texture is rotation 270 degrees clockwise',
        (WidgetTester tester) async {
          // Mock calls to CameraXProxy. Most importantly, tell camera that handlesCropAndRotation is true, set initial device
          // orientation to portrait up, and set initial default display rotation to 90 degrees clockwise.
          setUpOverridesForCreatingTestCamera(
            mockProcessCameraProvider: mockProcessCameraProvider,
            createCameraSelector: fakeCreateCameraSelector,
            handlesCropAndRotation: true,
            getUiOrientation: () async =>
                _serializeDeviceOrientation(DeviceOrientation.portraitUp),
            getDefaultDisplayRotation: () =>
                Future<int>.value(testInitialDefaultDisplayRotation),
          );

          // Get and create test camera.
          final List<CameraDescription> availableCameras = await camera
              .availableCameras();
          expect(availableCameras.length, 1);
          final int flutterSurfaceTextureId = await camera
              .createCameraWithSettings(
                availableCameras.first,
                testMediaSettings,
              );
          await camera.initializeCamera(flutterSurfaceTextureId);

          // Put camera preview in widget tree and pump one frame so that Future to retrieve
          // the initial default display rotation completes.
          await tester.pumpWidget(camera.buildPreview(cameraId));
          await tester.pump();

          // Verify Texture was built.
          final Texture texture = tester.widget<Texture>(find.byType(Texture));
          expect(texture.textureId, cameraId);

          // Verify Texture is rotated by 270 - 0 = 270 degrees clockwise.
          const int expectedQuarterTurns = _270DegreesClockwise;
          final RotatedBox rotatedBox = tester.widget<RotatedBox>(
            find.byType(RotatedBox),
          );

          expect(rotatedBox.child, isA<Texture>());
          expect((rotatedBox.child! as Texture).textureId, cameraId);
          expect(
            rotatedBox.quarterTurns,
            expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
              expectedQuarterTurns,
              rotatedBox.quarterTurns,
            ),
          );
        },
      );
      testWidgets(
        'initial device orientation is landscapeLeft, then the preview Texture is rotation 0 degrees clockwise',
        (WidgetTester tester) async {
          // Mock calls to CameraXProxy. Most importantly, tell camera that handlesCropAndRotation is true, set initial device
          // orientation to landscape left, and set initial default display rotation to 90 degrees clockwise.
          setUpOverridesForCreatingTestCamera(
            mockProcessCameraProvider: mockProcessCameraProvider,
            createCameraSelector: fakeCreateCameraSelector,
            handlesCropAndRotation: true,
            getUiOrientation: () async =>
                _serializeDeviceOrientation(DeviceOrientation.landscapeLeft),
            getDefaultDisplayRotation: () =>
                Future<int>.value(testInitialDefaultDisplayRotation),
          );

          // Get and create test camera.
          final List<CameraDescription> availableCameras = await camera
              .availableCameras();
          expect(availableCameras.length, 1);
          final int flutterSurfaceTextureId = await camera
              .createCameraWithSettings(
                availableCameras.first,
                testMediaSettings,
              );
          await camera.initializeCamera(flutterSurfaceTextureId);

          // Put camera preview in widget tree and pump one frame so that Future to retrieve
          // the initial default display rotation completes.
          await tester.pumpWidget(camera.buildPreview(cameraId));
          await tester.pump();

          // Verify Texture was built.
          final Texture texture = tester.widget<Texture>(find.byType(Texture));
          expect(texture.textureId, cameraId);

          // Verify Texture is rotated by 270 - 270 = 0 degrees.
          const int expectedQuarterTurns = _0DegreesClockwise;
          final RotatedBox rotatedBox = tester.widget<RotatedBox>(
            find.byType(RotatedBox),
          );

          expect(rotatedBox.child, isA<Texture>());
          expect((rotatedBox.child! as Texture).textureId, cameraId);
          expect(
            rotatedBox.quarterTurns,
            expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
              expectedQuarterTurns,
              rotatedBox.quarterTurns,
            ),
          );
        },
      );
      testWidgets(
        'initial device orientation is portraitDown, then the preview Texture is rotation 90 degrees clockwise',
        (WidgetTester tester) async {
          // Mock calls to CameraXProxy. Most importantly, tell camera that handlesCropAndRotation is true, set initial device
          // orientation to portrait down, and set initial default display rotation to 90 degrees clockwise.
          setUpOverridesForCreatingTestCamera(
            mockProcessCameraProvider: mockProcessCameraProvider,
            createCameraSelector: fakeCreateCameraSelector,
            handlesCropAndRotation: true,
            getUiOrientation: () async =>
                _serializeDeviceOrientation(DeviceOrientation.portraitDown),
            getDefaultDisplayRotation: () =>
                Future<int>.value(testInitialDefaultDisplayRotation),
          );

          // Get and create test camera.
          final List<CameraDescription> availableCameras = await camera
              .availableCameras();
          expect(availableCameras.length, 1);
          final int flutterSurfaceTextureId = await camera
              .createCameraWithSettings(
                availableCameras.first,
                testMediaSettings,
              );
          await camera.initializeCamera(flutterSurfaceTextureId);

          // Put camera preview in widget tree and pump one frame so that Future to retrieve
          // the initial default display rotation completes.
          await tester.pumpWidget(camera.buildPreview(cameraId));
          await tester.pump();

          // Verify Texture was built.
          final Texture texture = tester.widget<Texture>(find.byType(Texture));
          expect(texture.textureId, cameraId);

          // Verify Texture is rotated by 270 - 180 = 90 degrees clockwise.
          const int expectedQuarterTurns = _90DegreesClockwise;
          final RotatedBox rotatedBox = tester.widget<RotatedBox>(
            find.byType(RotatedBox),
          );

          expect(rotatedBox.child, isA<Texture>());
          expect((rotatedBox.child! as Texture).textureId, cameraId);
          expect(
            rotatedBox.quarterTurns,
            expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
              expectedQuarterTurns,
              rotatedBox.quarterTurns,
            ),
          );
        },
      );
      testWidgets(
        'initial device orientation is landscapeRight, then the preview Texture is rotation 180 degrees clockwise',
        (WidgetTester tester) async {
          // Mock calls to CameraXProxy. Most importantly, tell camera that handlesCropAndRotation is true, set initial device
          // orientation to landscape right, and set initial default display rotation to 90 degrees clockwise.
          setUpOverridesForCreatingTestCamera(
            mockProcessCameraProvider: mockProcessCameraProvider,
            createCameraSelector: fakeCreateCameraSelector,
            handlesCropAndRotation: true,
            getUiOrientation: () async =>
                _serializeDeviceOrientation(DeviceOrientation.landscapeRight),
            getDefaultDisplayRotation: () =>
                Future<int>.value(testInitialDefaultDisplayRotation),
          );

          // Get and create test camera.
          final List<CameraDescription> availableCameras = await camera
              .availableCameras();
          expect(availableCameras.length, 1);
          final int flutterSurfaceTextureId = await camera
              .createCameraWithSettings(
                availableCameras.first,
                testMediaSettings,
              );
          await camera.initializeCamera(flutterSurfaceTextureId);

          // Put camera preview in widget tree and pump one frame so that Future to retrieve
          // the initial default display rotation completes.
          await tester.pumpWidget(camera.buildPreview(cameraId));
          await tester.pump();

          // Verify Texture was built.
          final Texture texture = tester.widget<Texture>(find.byType(Texture));
          expect(texture.textureId, cameraId);

          // Verify Texture is rotated by 270 - 90 = 180 degrees clockwise.
          const int expectedQuarterTurns = _180DegreesClockwise;
          final RotatedBox rotatedBox = tester.widget<RotatedBox>(
            find.byType(RotatedBox),
          );

          expect(rotatedBox.child, isA<Texture>());
          expect((rotatedBox.child! as Texture).textureId, cameraId);
          expect(
            rotatedBox.quarterTurns,
            expectedQuarterTurns,
            reason: getExpectedRotationTestFailureReason(
              expectedQuarterTurns,
              rotatedBox.quarterTurns,
            ),
          );
        },
      );
    });

    // Test that preview rotation responds to change in default display rotation:
    testWidgets(
      'device orientation is portraitDown, then the preview Texture rotates correctly as the default display rotation changes',
      (WidgetTester tester) async {
        final camera = AndroidCameraCameraX();
        const cameraId = 11;
        const DeviceOrientation testDeviceOrientation =
            DeviceOrientation.portraitDown;

        // Create and set up mock CameraSelector, mock ProcessCameraProvider, and media settings for test front camera.
        // These settings do not matter for this test.
        final mockFrontCameraSelector = MockCameraSelector();
        final MockCameraSelector Function({
          LensFacing? requireLensFacing,
          dynamic cameraInfoForFilter,
        })
        proxyCreateCameraSelectorForFrontCamera =
            createCameraSelectorForFrontCamera(mockFrontCameraSelector);
        final MockProcessCameraProvider
        mockProcessCameraProviderForFrontCamera =
            setUpMockCameraSelectorAndMockProcessCameraProviderForSelectingTestCamera(
              mockCameraSelector: mockFrontCameraSelector,
              sensorRotationDegrees: 270,
            );
        const testMediaSettings = MediaSettings();

        // Tell camera that handlesCropAndRotation is true, set camera initial device orientation
        // to portrait down, set initial default display rotation to 0 degrees clockwise.
        final mockDeviceOrientationManager = MockDeviceOrientationManager();
        when(mockDeviceOrientationManager.getUiOrientation()).thenAnswer(
          (_) => Future<String>.value(
            _serializeDeviceOrientation(testDeviceOrientation),
          ),
        );
        when(
          mockDeviceOrientationManager.getDefaultDisplayRotation(),
        ).thenAnswer((_) => Future<int>.value(Surface.rotation0));

        setUpOverridesForCreatingTestCameraWithDeviceOrientationManager(
          mockDeviceOrientationManager,
          mockProcessCameraProvider: mockProcessCameraProviderForFrontCamera,
          createCameraSelector: proxyCreateCameraSelectorForFrontCamera,
          handlesCropAndRotation: true,
        );

        // Get and create test front camera.
        final List<CameraDescription> availableCameras = await camera
            .availableCameras();
        expect(availableCameras.length, 1);
        final int flutterSurfaceTextureId = await camera
            .createCameraWithSettings(
              availableCameras.first,
              testMediaSettings,
            );
        await camera.initializeCamera(flutterSurfaceTextureId);

        // Calculated according to: counterClockwiseCurrentDefaultDisplayRotation - cameraPreviewPreAppliedRotation,
        // where the cameraPreviewPreAppliedRotation is the clockwise rotation applied by the CameraPreview widget
        // according to the current device orientation (fixed to portraitDown for this test, so it is 180).
        final expectedRotationPerDefaultDisplayRotation = <int, int>{
          Surface.rotation0: _180DegreesClockwise,
          Surface.rotation90: _90DegreesClockwise,
          Surface.rotation180: _0DegreesClockwise,
          Surface.rotation270: _270DegreesClockwise,
        };

        // Put camera preview in widget tree.
        await tester.pumpWidget(camera.buildPreview(cameraId));

        for (final int currentDefaultDisplayRotation
            in expectedRotationPerDefaultDisplayRotation.keys) {
          // Modify CameraXProxy to return the default display rotation we want to test.
          when(
            mockDeviceOrientationManager.getDefaultDisplayRotation(),
          ).thenAnswer((_) => Future<int>.value(currentDefaultDisplayRotation));

          const testEvent = DeviceOrientationChangedEvent(
            testDeviceOrientation,
          );
          AndroidCameraCameraX.deviceOrientationChangedStreamController.add(
            testEvent,
          );

          await tester.pumpAndSettle();

          // Verify Texture is rotated by expected clockwise degrees.
          final int expectedQuarterTurns =
              expectedRotationPerDefaultDisplayRotation[currentDefaultDisplayRotation]!;
          final RotatedBox rotatedBox = tester.widget<RotatedBox>(
            find.byType(RotatedBox),
          );
          final int clockwiseQuarterTurns = rotatedBox.quarterTurns < 0
              ? rotatedBox.quarterTurns + 4
              : rotatedBox.quarterTurns;
          expect(rotatedBox.child, isA<Texture>());
          expect((rotatedBox.child! as Texture).textureId, cameraId);
          expect(
            clockwiseQuarterTurns,
            expectedQuarterTurns,
            reason:
                'When the default display rotation is $currentDefaultDisplayRotation, expected the preview to be rotated by $expectedQuarterTurns quarter turns (which is ${expectedQuarterTurns * 90} degrees clockwise) but instead was rotated ${rotatedBox.quarterTurns} quarter turns.',
          );
        }
      },
    );

    // Test that preview rotation responds to change in device orientation:
    testWidgets(
      'initial default display rotation is 270 degrees clockwise, then the preview Texture rotates correctly as the device orientation changes',
      (WidgetTester tester) async {
        final camera = AndroidCameraCameraX();
        const cameraId = 11;
        const int testInitialDefaultDisplayRotation = Surface.rotation270;

        // Create and set up mock CameraSelector, mock ProcessCameraProvider, and media settings for test front camera.
        // These settings do not matter for this test.
        final mockFrontCameraSelector = MockCameraSelector();
        final MockCameraSelector Function({
          LensFacing? requireLensFacing,
          dynamic cameraInfoForFilter,
        })
        proxyCreateCameraSelectorForFrontCamera =
            createCameraSelectorForFrontCamera(mockFrontCameraSelector);
        final MockProcessCameraProvider
        mockProcessCameraProviderForFrontCamera =
            setUpMockCameraSelectorAndMockProcessCameraProviderForSelectingTestCamera(
              mockCameraSelector: mockFrontCameraSelector,
              sensorRotationDegrees: 270,
            );
        const testMediaSettings = MediaSettings();

        // Tell camera that handlesCropAndRotation is true, set camera initial device orientation
        // to portrait up, set initial default display rotation to 270 degrees clockwise.
        setUpOverridesForCreatingTestCamera(
          mockProcessCameraProvider: mockProcessCameraProviderForFrontCamera,
          createCameraSelector: proxyCreateCameraSelectorForFrontCamera,
          handlesCropAndRotation: true,
          getUiOrientation: /* initial device orientation is irrelevant */
              () async =>
                  _serializeDeviceOrientation(DeviceOrientation.portraitUp),
          getDefaultDisplayRotation: () =>
              Future<int>.value(testInitialDefaultDisplayRotation),
        );

        // Get and create test front camera.
        final List<CameraDescription> availableCameras = await camera
            .availableCameras();
        expect(availableCameras.length, 1);
        final int flutterSurfaceTextureId = await camera
            .createCameraWithSettings(
              availableCameras.first,
              testMediaSettings,
            );
        await camera.initializeCamera(flutterSurfaceTextureId);

        // Calculated according to: counterClockwiseCurrentDefaultDisplayRotation - cameraPreviewPreAppliedRotation,
        // where the cameraPreviewPreAppliedRotation is the clockwise rotation applied by the CameraPreview widget
        // according to the current device orientation. counterClockwiseCurrentDefaultDisplayRotation is fixed to 90 for
        // this test (the counter-clockwise rotation of the clockwise 270 degree default display rotation).
        final expectedRotationPerDeviceOrientation = <DeviceOrientation, int>{
          DeviceOrientation.portraitUp: _90DegreesClockwise,
          DeviceOrientation.landscapeRight: _0DegreesClockwise,
          DeviceOrientation.portraitDown: _270DegreesClockwise,
          DeviceOrientation.landscapeLeft: _180DegreesClockwise,
        };

        // Put camera preview in widget tree.
        await tester.pumpWidget(camera.buildPreview(cameraId));

        for (final DeviceOrientation currentDeviceOrientation
            in expectedRotationPerDeviceOrientation.keys) {
          final testEvent = DeviceOrientationChangedEvent(
            currentDeviceOrientation,
          );
          AndroidCameraCameraX.deviceOrientationChangedStreamController.add(
            testEvent,
          );

          await tester.pumpAndSettle();

          // Verify Texture is rotated by expected clockwise degrees.
          final int expectedQuarterTurns =
              expectedRotationPerDeviceOrientation[currentDeviceOrientation]!;
          final RotatedBox rotatedBox = tester.widget<RotatedBox>(
            find.byType(RotatedBox),
          );
          final int clockwiseQuarterTurns = rotatedBox.quarterTurns < 0
              ? rotatedBox.quarterTurns + 4
              : rotatedBox.quarterTurns;
          expect(rotatedBox.child, isA<Texture>());
          expect((rotatedBox.child! as Texture).textureId, cameraId);
          expect(
            clockwiseQuarterTurns,
            expectedQuarterTurns,
            reason:
                'When the device orientation is $currentDeviceOrientation, expected the preview to be rotated by $expectedQuarterTurns quarter turns (which is ${expectedQuarterTurns * 90} degrees clockwise) but instead was rotated ${rotatedBox.quarterTurns} quarter turns.',
          );
        }
      },
    );
  });

  group('when handlesCropAndRotation is false,', () {
    // Test that preview rotation responds to initial device orientation:
    group(
      'sensor orientation degrees is 270, camera is front facing, initial default display rotation is 0 degrees clockwise',
      () {
        late AndroidCameraCameraX camera;
        late int cameraId;
        late MockCameraSelector mockFrontCameraSelector;
        late MockCameraSelector Function({
          LensFacing? requireLensFacing,
          dynamic cameraInfoForFilter,
        })
        proxyCreateCameraSelectorForFrontCamera;
        late MockProcessCameraProvider mockProcessCameraProviderForFrontCamera;
        late Future<int> Function() proxyGetDefaultDisplayRotation;
        late MediaSettings testMediaSettings;

        setUp(() {
          camera = AndroidCameraCameraX();
          cameraId = 27;

          // Create and set up mock CameraSelector and mock ProcessCameraProvider for test front camera
          // with sensor orientation degrees 270. Also, set up function to mock initial default display
          // of 0.
          mockFrontCameraSelector = MockCameraSelector();
          proxyCreateCameraSelectorForFrontCamera =
              createCameraSelectorForFrontCamera(mockFrontCameraSelector);
          mockProcessCameraProviderForFrontCamera =
              setUpMockCameraSelectorAndMockProcessCameraProviderForSelectingTestCamera(
                mockCameraSelector: mockFrontCameraSelector,
                sensorRotationDegrees: 270,
              );
          proxyGetDefaultDisplayRotation = () =>
              Future<int>.value(Surface.rotation0);

          // Media settings to create camera; irrelevant for test.
          testMediaSettings = const MediaSettings();
        });

        testWidgets(
          'initial device orientation fixed to DeviceOrientation.portraitUp, then the preview Texture is rotated 270 degrees clockwise',
          (WidgetTester tester) async {
            // Set up test to use front camera, tell camera that handlesCropAndRotation is false,
            // set camera initial device orientation to portrait up.
            setUpOverridesForCreatingTestCamera(
              mockProcessCameraProvider:
                  mockProcessCameraProviderForFrontCamera,
              createCameraSelector: proxyCreateCameraSelectorForFrontCamera,
              getDefaultDisplayRotation: proxyGetDefaultDisplayRotation,
              handlesCropAndRotation: false,
              getUiOrientation: () async =>
                  _serializeDeviceOrientation(DeviceOrientation.portraitUp),
            );

            // Get and create test front camera.
            final List<CameraDescription> availableCameras = await camera
                .availableCameras();
            expect(availableCameras.length, 1);
            final int flutterSurfaceTextureId = await camera
                .createCameraWithSettings(
                  availableCameras.first,
                  testMediaSettings,
                );
            await camera.initializeCamera(flutterSurfaceTextureId);

            // Put camera preview in widget tree and pump one frame so that Future to retrieve
            // the initial default display rotation completes.
            await tester.pumpWidget(camera.buildPreview(cameraId));
            await tester.pump();

            // Verify Texture is rotated by ((270 - 0 * 1 + 360) % 360) - 0 = 270 degrees.
            const int expectedQuarterTurns = _270DegreesClockwise;
            final RotatedBox rotatedBox = tester.widget<RotatedBox>(
              find.byType(RotatedBox),
            );

            // We expect a Transform widget to wrap the RotatedBox with the camera
            // preview to mirror the preview, since the front camera is being
            // used.
            expect(rotatedBox.child, isA<Transform>());

            final transformedPreview = rotatedBox.child! as Transform;
            final Matrix4 transformedPreviewMatrix =
                transformedPreview.transform;

            // Since the front camera is in portrait mode, we expect the camera
            // preview to be mirrored across the y-axis.
            checkYAxisIsMirrored(transformedPreviewMatrix);
            expect((transformedPreview.child! as Texture).textureId, cameraId);
            expect(
              rotatedBox.quarterTurns,
              expectedQuarterTurns,
              reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns,
                rotatedBox.quarterTurns,
              ),
            );
          },
        );

        testWidgets(
          'initial device orientation fixed to DeviceOrientation.landscapeRight, then the preview Texture is rotated 180 degrees clockwise',
          (WidgetTester tester) async {
            // Set up test to use front camera, tell camera that handlesCropAndRotation is false,
            // set camera initial device orientation to landscape right.
            setUpOverridesForCreatingTestCamera(
              mockProcessCameraProvider:
                  mockProcessCameraProviderForFrontCamera,
              createCameraSelector: proxyCreateCameraSelectorForFrontCamera,
              getDefaultDisplayRotation: proxyGetDefaultDisplayRotation,
              handlesCropAndRotation: false,
              getUiOrientation: () async =>
                  _serializeDeviceOrientation(DeviceOrientation.landscapeRight),
            );

            // Get and create test front camera.
            final List<CameraDescription> availableCameras = await camera
                .availableCameras();
            expect(availableCameras.length, 1);
            final int flutterSurfaceTextureId = await camera
                .createCameraWithSettings(
                  availableCameras.first,
                  testMediaSettings,
                );
            await camera.initializeCamera(flutterSurfaceTextureId);

            // Put camera preview in widget tree and pump one frame so that Future to retrieve
            // the initial default display rotation completes.
            await tester.pumpWidget(camera.buildPreview(cameraId));
            await tester.pump();

            // Verify Texture is rotated by ((270 - 0 * 1 + 360) % 360) - 90 = 180 degrees.
            const int expectedQuarterTurns = _180DegreesClockwise;
            final RotatedBox rotatedBox = tester.widget<RotatedBox>(
              find.byType(RotatedBox),
            );

            // We expect a Transform widget to wrap the RotatedBox with the camera
            // preview to mirror the preview, since the front camera is being
            // used.
            expect(rotatedBox.child, isA<Transform>());

            final transformedPreview = rotatedBox.child! as Transform;
            final Matrix4 transformedPreviewMatrix =
                transformedPreview.transform;

            // Since the front camera is in landscape mode, we expect the camera
            // preview to be mirrored across the x-axis.
            checkXAxisIsMirrored(transformedPreviewMatrix);
            expect((transformedPreview.child! as Texture).textureId, cameraId);
            expect(
              rotatedBox.quarterTurns,
              expectedQuarterTurns,
              reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns,
                rotatedBox.quarterTurns,
              ),
            );
          },
        );

        testWidgets(
          'initial device orientation fixed to DeviceOrientation.portraitDown, then the preview Texture is rotated 90 degrees clockwise',
          (WidgetTester tester) async {
            // Set up test to use front camera, tell camera that handlesCropAndRotation is false,
            // set camera initial device orientation to portrait down.
            setUpOverridesForCreatingTestCamera(
              mockProcessCameraProvider:
                  mockProcessCameraProviderForFrontCamera,
              createCameraSelector: proxyCreateCameraSelectorForFrontCamera,
              getDefaultDisplayRotation: proxyGetDefaultDisplayRotation,
              handlesCropAndRotation: false,
              getUiOrientation: () async =>
                  _serializeDeviceOrientation(DeviceOrientation.portraitDown),
            );

            // Get and create test front camera.
            final List<CameraDescription> availableCameras = await camera
                .availableCameras();
            expect(availableCameras.length, 1);
            final int flutterSurfaceTextureId = await camera
                .createCameraWithSettings(
                  availableCameras.first,
                  testMediaSettings,
                );
            await camera.initializeCamera(flutterSurfaceTextureId);

            // Put camera preview in widget tree and pump one frame so that Future to retrieve
            // the initial default display rotation completes.
            await tester.pumpWidget(camera.buildPreview(cameraId));
            await tester.pump();

            // Verify Texture is rotated by ((270 - 0 * 1 + 360) % 360) - 180 = 90 degrees clockwise.
            const int expectedQuarterTurns = _90DegreesClockwise;
            final RotatedBox rotatedBox = tester.widget<RotatedBox>(
              find.byType(RotatedBox),
            );

            // We expect a Transform widget to wrap the RotatedBox with the camera
            // preview to mirror the preview, since the front camera is being
            // used.
            expect(rotatedBox.child, isA<Transform>());

            final transformedPreview = rotatedBox.child! as Transform;
            final Matrix4 transformedPreviewMatrix =
                transformedPreview.transform;

            // Since the front camera is in portrait mode, we expect the camera
            // preview to be mirrored across the y-axis.
            checkYAxisIsMirrored(transformedPreviewMatrix);
            expect((transformedPreview.child! as Texture).textureId, cameraId);
            expect(
              rotatedBox.quarterTurns,
              expectedQuarterTurns,
              reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns,
                rotatedBox.quarterTurns,
              ),
            );
          },
        );

        testWidgets(
          'initial device orientation fixed to DeviceOrientation.landscapeLeft, then the preview Texture is rotated 0 degrees clockwise',
          (WidgetTester tester) async {
            // Set up test to use front camera, tell camera that handlesCropAndRotation is false,
            // set camera initial device orientation to landscape left.
            setUpOverridesForCreatingTestCamera(
              mockProcessCameraProvider:
                  mockProcessCameraProviderForFrontCamera,
              createCameraSelector: proxyCreateCameraSelectorForFrontCamera,
              getDefaultDisplayRotation: proxyGetDefaultDisplayRotation,
              handlesCropAndRotation: false,
              getUiOrientation: () async =>
                  _serializeDeviceOrientation(DeviceOrientation.landscapeLeft),
            );

            // Get and create test front camera.
            final List<CameraDescription> availableCameras = await camera
                .availableCameras();
            expect(availableCameras.length, 1);
            final int flutterSurfaceTextureId = await camera
                .createCameraWithSettings(
                  availableCameras.first,
                  testMediaSettings,
                );
            await camera.initializeCamera(flutterSurfaceTextureId);

            // Put camera preview in widget tree and pump one frame so that Future to retrieve
            // the initial default display rotation completes.
            await tester.pumpWidget(camera.buildPreview(cameraId));
            await tester.pump();

            // Verify Texture is rotated by ((270 - 0 * 1 + 360) % 360) - 270 = 0 degrees clockwise.
            const int expectedQuarterTurns = _0DegreesClockwise;
            final RotatedBox rotatedBox = tester.widget<RotatedBox>(
              find.byType(RotatedBox),
            );

            // We expect a Transform widget to wrap the RotatedBox with the camera
            // preview to mirror the preview, since the front camera is being
            // used.
            expect(rotatedBox.child, isA<Transform>());

            final transformedPreview = rotatedBox.child! as Transform;
            final Matrix4 transformedPreviewMatrix =
                transformedPreview.transform;

            // Since the front camera is in landscape mode, we expect the camera
            // preview to be mirrored across the x-axis.
            checkXAxisIsMirrored(transformedPreviewMatrix);
            expect((transformedPreview.child! as Texture).textureId, cameraId);
            expect(
              rotatedBox.quarterTurns,
              expectedQuarterTurns,
              reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns,
                rotatedBox.quarterTurns,
              ),
            );
          },
        );
      },
    );

    // Test that preview rotation responds to initial default display rotation:
    group(
      'initial device orientation fixed to DeviceOrientation.landscapeLeft, sensor orientation degrees is 270, camera is front facing,',
      () {
        late AndroidCameraCameraX camera;
        late int cameraId;
        late MockCameraSelector mockFrontCameraSelector;
        late MockProcessCameraProvider mockProcessCameraProviderForFrontCamera;
        late MockCameraSelector Function({
          LensFacing? requireLensFacing,
          dynamic cameraInfoForFilter,
        })
        proxyCreateCameraSelectorForFrontCamera;
        late Future<String> Function() proxyGetUiOrientation;
        late MediaSettings testMediaSettings;

        setUp(() {
          camera = AndroidCameraCameraX();
          cameraId = 48;

          // Create and set up mock CameraSelector and mock ProcessCameraProvider for test front camera
          // with sensor orientation degrees 270. Also, set up function to mock initial default display
          // of 0.
          mockFrontCameraSelector = MockCameraSelector();
          proxyCreateCameraSelectorForFrontCamera =
              createCameraSelectorForFrontCamera(mockFrontCameraSelector);
          mockProcessCameraProviderForFrontCamera =
              setUpMockCameraSelectorAndMockProcessCameraProviderForSelectingTestCamera(
                mockCameraSelector: mockFrontCameraSelector,
                sensorRotationDegrees: 270,
              );
          proxyGetUiOrientation = () async =>
              _serializeDeviceOrientation(DeviceOrientation.landscapeLeft);

          // Media settings to create camera; irrelevant for test.
          testMediaSettings = const MediaSettings();
        });

        testWidgets(
          'initial default display rotation is 0 degrees, then the preview Texture is rotated 0 degrees clockwise',
          (WidgetTester tester) async {
            // Set up test to use front camera, tell camera that handlesCropAndRotation is false,
            // set camera initial default display rotation to 0 degrees.
            setUpOverridesForCreatingTestCamera(
              mockProcessCameraProvider:
                  mockProcessCameraProviderForFrontCamera,
              createCameraSelector: proxyCreateCameraSelectorForFrontCamera,
              getDefaultDisplayRotation: () =>
                  Future<int>.value(Surface.rotation0),
              handlesCropAndRotation: false,
              getUiOrientation: proxyGetUiOrientation,
            );

            // Get and create test front camera.
            final List<CameraDescription> availableCameras = await camera
                .availableCameras();
            expect(availableCameras.length, 1);
            final int flutterSurfaceTextureId = await camera
                .createCameraWithSettings(
                  availableCameras.first,
                  testMediaSettings,
                );
            await camera.initializeCamera(flutterSurfaceTextureId);

            // Put camera preview in widget tree and pump one frame so that Future to retrieve
            // the initial default display rotation completes.
            await tester.pumpWidget(camera.buildPreview(cameraId));
            await tester.pump();

            // Verify Texture is rotated by ((270 - 0 * 1 + 360) % 360) - 270 = 0 degrees.
            const int expectedQuarterTurns = _0DegreesClockwise;
            final RotatedBox rotatedBox = tester.widget<RotatedBox>(
              find.byType(RotatedBox),
            );

            // We expect a Transform widget to wrap the RotatedBox with the camera
            // preview to mirror the preview, since the front camera is being
            // used.
            expect(rotatedBox.child, isA<Transform>());

            final transformedPreview = rotatedBox.child! as Transform;
            final Matrix4 transformedPreviewMatrix =
                transformedPreview.transform;

            // Since the front camera is in landscape mode, we expect the camera
            // preview to be mirrored across the x-axis.
            checkXAxisIsMirrored(transformedPreviewMatrix);
            expect((transformedPreview.child! as Texture).textureId, cameraId);
            expect(
              rotatedBox.quarterTurns,
              expectedQuarterTurns,
              reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns,
                rotatedBox.quarterTurns,
              ),
            );
          },
        );

        testWidgets(
          'initial default display rotation is 90 degrees, then the preview Texture is rotated 90 degrees clockwise',
          (WidgetTester tester) async {
            // Set up test to use front camera, tell camera that handlesCropAndRotation is false,
            // set camera initial default display rotation to 0 degrees.
            setUpOverridesForCreatingTestCamera(
              mockProcessCameraProvider:
                  mockProcessCameraProviderForFrontCamera,
              createCameraSelector: proxyCreateCameraSelectorForFrontCamera,
              getDefaultDisplayRotation: () =>
                  Future<int>.value(Surface.rotation90),
              handlesCropAndRotation: false,
              getUiOrientation: proxyGetUiOrientation,
            );

            // Get and create test front camera.
            final List<CameraDescription> availableCameras = await camera
                .availableCameras();
            expect(availableCameras.length, 1);
            final int flutterSurfaceTextureId = await camera
                .createCameraWithSettings(
                  availableCameras.first,
                  testMediaSettings,
                );
            await camera.initializeCamera(flutterSurfaceTextureId);

            // Put camera preview in widget tree and pump one frame so that Future to retrieve
            // the initial default display rotation completes.
            await tester.pumpWidget(camera.buildPreview(cameraId));
            await tester.pump();

            // Verify Texture is rotated by ((270 - 270 * 1 + 360) % 360) - 270 = -270 degrees clockwise = 90 degrees clockwise.
            // 270 is used in this calculation for the device orientation because it is the counter-clockwise degrees of the
            // default display rotation.
            const int expectedQuarterTurns = _90DegreesClockwise;
            final RotatedBox rotatedBox = tester.widget<RotatedBox>(
              find.byType(RotatedBox),
            );

            // We expect a Transform widget to wrap the RotatedBox with the camera
            // preview to mirror the preview, since the front camera is being
            // used.
            expect(rotatedBox.child, isA<Transform>());

            final transformedPreview = rotatedBox.child! as Transform;
            final Matrix4 transformedPreviewMatrix =
                transformedPreview.transform;

            // Since the front camera is in landscape mode, we expect the camera
            // preview to be mirrored across the x-axis.
            checkXAxisIsMirrored(transformedPreviewMatrix);
            expect((transformedPreview.child! as Texture).textureId, cameraId);

            final int clockwiseQuarterTurns = rotatedBox.quarterTurns + 4;
            expect(
              clockwiseQuarterTurns,
              expectedQuarterTurns,
              reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns,
                rotatedBox.quarterTurns,
              ),
            );
          },
        );

        testWidgets(
          'initial default display rotation is 180 degrees, then the preview Texture is rotated 180 degrees clockwise',
          (WidgetTester tester) async {
            // Set up test to use front camera, tell camera that handlesCropAndRotation is false,
            // set camera initial default display rotation to 0 degrees.
            setUpOverridesForCreatingTestCamera(
              mockProcessCameraProvider:
                  mockProcessCameraProviderForFrontCamera,
              createCameraSelector: proxyCreateCameraSelectorForFrontCamera,
              getDefaultDisplayRotation: () =>
                  Future<int>.value(Surface.rotation180),
              handlesCropAndRotation: false,
              getUiOrientation: proxyGetUiOrientation,
            );

            // Get and create test front camera.
            final List<CameraDescription> availableCameras = await camera
                .availableCameras();
            expect(availableCameras.length, 1);
            final int flutterSurfaceTextureId = await camera
                .createCameraWithSettings(
                  availableCameras.first,
                  testMediaSettings,
                );
            await camera.initializeCamera(flutterSurfaceTextureId);

            // Put camera preview in widget tree and pump one frame so that Future to retrieve
            // the initial default display rotation completes.
            await tester.pumpWidget(camera.buildPreview(cameraId));
            await tester.pump();

            // Verify Texture is rotated by ((270 - 180 * 1 + 360) % 360) - 270 = -180 degrees clockwise = 180 degrees clockwise.
            const int expectedQuarterTurns = _180DegreesClockwise;
            final RotatedBox rotatedBox = tester.widget<RotatedBox>(
              find.byType(RotatedBox),
            );

            // We expect a Transform widget to wrap the RotatedBox with the camera
            // preview to mirror the preview, since the front camera is being
            // used.
            expect(rotatedBox.child, isA<Transform>());

            final transformedPreview = rotatedBox.child! as Transform;
            final Matrix4 transformedPreviewMatrix =
                transformedPreview.transform;

            // Since the front camera is in landscape mode, we expect the camera
            // preview to be mirrored across the x-axis.
            checkXAxisIsMirrored(transformedPreviewMatrix);
            expect((transformedPreview.child! as Texture).textureId, cameraId);

            final int clockwiseQuarterTurns = rotatedBox.quarterTurns + 4;
            expect(
              clockwiseQuarterTurns,
              expectedQuarterTurns,
              reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns,
                rotatedBox.quarterTurns,
              ),
            );
          },
        );

        testWidgets(
          'initial default display rotation is 270 degrees, then the preview Texture is rotated 270 degrees clockwise',
          (WidgetTester tester) async {
            // Set up test to use front camera, tell camera that handlesCropAndRotation is false,
            // set camera initial default display rotation to 0 degrees.
            setUpOverridesForCreatingTestCamera(
              mockProcessCameraProvider:
                  mockProcessCameraProviderForFrontCamera,
              createCameraSelector: proxyCreateCameraSelectorForFrontCamera,
              getDefaultDisplayRotation: () =>
                  Future<int>.value(Surface.rotation270),
              handlesCropAndRotation: false,
              getUiOrientation: proxyGetUiOrientation,
            );

            // Get and create test front camera.
            final List<CameraDescription> availableCameras = await camera
                .availableCameras();
            expect(availableCameras.length, 1);
            final int flutterSurfaceTextureId = await camera
                .createCameraWithSettings(
                  availableCameras.first,
                  testMediaSettings,
                );
            await camera.initializeCamera(flutterSurfaceTextureId);

            // Put camera preview in widget tree and pump one frame so that Future to retrieve
            // the initial default display rotation completes.
            await tester.pumpWidget(camera.buildPreview(cameraId));
            await tester.pump();

            // Verify Texture is rotated by ((270 - 90 * 1 + 360) % 360) - 270 = -90 degrees clockwise = 270 degrees clockwise.
            // 90 is used in this calculation for the device orientation because it is the counter-clockwise degrees of the
            // default display rotation.
            const int expectedQuarterTurns = _270DegreesClockwise;
            final RotatedBox rotatedBox = tester.widget<RotatedBox>(
              find.byType(RotatedBox),
            );

            // We expect a Transform widget to wrap the RotatedBox with the camera
            // preview to mirror the preview, since the front camera is being
            // used.
            expect(rotatedBox.child, isA<Transform>());

            final transformedPreview = rotatedBox.child! as Transform;
            final Matrix4 transformedPreviewMatrix =
                transformedPreview.transform;

            // Since the front camera is in landscape mode, we expect the camera
            // preview to be mirrored across the x-axis.
            checkXAxisIsMirrored(transformedPreviewMatrix);
            expect((transformedPreview.child! as Texture).textureId, cameraId);

            final int clockwiseQuarterTurns = rotatedBox.quarterTurns + 4;
            expect(
              clockwiseQuarterTurns,
              expectedQuarterTurns,
              reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns,
                rotatedBox.quarterTurns,
              ),
            );
          },
        );
      },
    );

    // Test that preview widgets responds as expected to the default display rotation changing:
    testWidgets(
      'device orientation is landscapeRight, sensor orientation degrees is 270, camera is front facing, then the preview Texture rotates correctly as the default display rotation changes',
      (WidgetTester tester) async {
        final camera = AndroidCameraCameraX();
        const cameraId = 11;
        const DeviceOrientation testDeviceOrientation =
            DeviceOrientation.landscapeRight;

        // Create and set up mock front camera CameraSelector, mock ProcessCameraProvider, 270 degree sensor orientation,
        // media settings for test front camera.
        final mockFrontCameraSelector = MockCameraSelector();
        final MockCameraSelector Function({
          LensFacing? requireLensFacing,
          dynamic cameraInfoForFilter,
        })
        proxyCreateCameraSelectorForFrontCamera =
            createCameraSelectorForFrontCamera(mockFrontCameraSelector);
        final MockProcessCameraProvider
        mockProcessCameraProviderForFrontCamera =
            setUpMockCameraSelectorAndMockProcessCameraProviderForSelectingTestCamera(
              mockCameraSelector: mockFrontCameraSelector,
              sensorRotationDegrees: 270,
            );
        const testMediaSettings = MediaSettings();

        // Tell camera that handlesCropAndRotation is true, set camera initial device orientation
        // to portrait down, set initial default display rotation to 0 degrees clockwise.
        final mockDeviceOrientationManager = MockDeviceOrientationManager();
        when(mockDeviceOrientationManager.getUiOrientation()).thenAnswer(
          (_) => Future<String>.value(
            _serializeDeviceOrientation(testDeviceOrientation),
          ),
        );
        when(
          mockDeviceOrientationManager.getDefaultDisplayRotation(),
        ).thenAnswer((_) => Future<int>.value(Surface.rotation0));
        setUpOverridesForCreatingTestCameraWithDeviceOrientationManager(
          mockDeviceOrientationManager,
          mockProcessCameraProvider: mockProcessCameraProviderForFrontCamera,
          createCameraSelector: proxyCreateCameraSelectorForFrontCamera,
          handlesCropAndRotation: false,
        );

        // Get and create test front camera.
        final List<CameraDescription> availableCameras = await camera
            .availableCameras();
        expect(availableCameras.length, 1);
        final int flutterSurfaceTextureId = await camera
            .createCameraWithSettings(
              availableCameras.first,
              testMediaSettings,
            );
        await camera.initializeCamera(flutterSurfaceTextureId);

        // Calculated according to: ((270 - counterClockwiseDefaultDisplayRotation * 1 + 360) % 360) - 90.
        // 90 is used in this calculation for the CameraPreview pre-applied rotation because it is the
        // rotation that the CameraPreview widget aapplies based on the landscape right device orientation.
        final expectedRotationPerDefaultDisplayRotation = <int, int>{
          Surface.rotation0: _180DegreesClockwise,
          Surface.rotation90: _270DegreesClockwise,
          Surface.rotation180: _0DegreesClockwise,
          Surface.rotation270: _90DegreesClockwise,
        };

        // Put camera preview in widget tree.
        await tester.pumpWidget(camera.buildPreview(cameraId));

        for (final int currentDefaultDisplayRotation
            in expectedRotationPerDefaultDisplayRotation.keys) {
          // Modify CameraXProxy to return the default display rotation we want to test.
          when(
            mockDeviceOrientationManager.getDefaultDisplayRotation(),
          ).thenAnswer((_) async => currentDefaultDisplayRotation);

          const testEvent = DeviceOrientationChangedEvent(
            testDeviceOrientation,
          );
          AndroidCameraCameraX.deviceOrientationChangedStreamController.add(
            testEvent,
          );

          await tester.pumpAndSettle();

          // Verify Texture is rotated by expected clockwise degrees.
          final int expectedQuarterTurns =
              expectedRotationPerDefaultDisplayRotation[currentDefaultDisplayRotation]!;
          final RotatedBox rotatedBox = tester.widget<RotatedBox>(
            find.byType(RotatedBox),
          );

          // We expect a Transform widget to wrap the RotatedBox with the camera
          // preview to mirror the preview, since the front camera is being
          // used.
          expect(rotatedBox.child, isA<Transform>());

          final transformedPreview = rotatedBox.child! as Transform;
          final Matrix4 transformedPreviewMatrix = transformedPreview.transform;

          // Since the front camera is in landscape mode, we expect the camera
          // preview to be mirrored across the x-axis.
          checkXAxisIsMirrored(transformedPreviewMatrix);
          expect((transformedPreview.child! as Texture).textureId, cameraId);

          final int clockwiseQuarterTurns = rotatedBox.quarterTurns < 0
              ? rotatedBox.quarterTurns + 4
              : rotatedBox.quarterTurns;
          expect(
            clockwiseQuarterTurns,
            expectedQuarterTurns,
            reason:
                'When the default display rotation is $currentDefaultDisplayRotation, expected the preview to be rotated by $expectedQuarterTurns quarter turns (which is ${expectedQuarterTurns * 90} degrees clockwise) but instead was rotated ${rotatedBox.quarterTurns} quarter turns.',
          );
        }
      },
    );

    // Test that preview widgets responds as expected to the device orientation changing:
    testWidgets(
      'default display rotation is 90, sensor orientation degrees is 90, camera is front facing, then the preview Texture rotates correctly as the device orientation rotates',
      (WidgetTester tester) async {
        final camera = AndroidCameraCameraX();
        const cameraId = 3372;

        // Create and set up mock CameraSelector and mock ProcessCameraProvider for test front camera
        // with sensor orientation degrees 90.
        final mockFrontCameraSelector = MockCameraSelector();
        final MockCameraSelector Function({
          LensFacing? requireLensFacing,
          dynamic cameraInfoForFilter,
        })
        proxyCreateCameraSelectorForFrontCamera =
            createCameraSelectorForFrontCamera(mockFrontCameraSelector);
        final MockProcessCameraProvider
        mockProcessCameraProviderForFrontCamera =
            setUpMockCameraSelectorAndMockProcessCameraProviderForSelectingTestCamera(
              mockCameraSelector: mockFrontCameraSelector,
              sensorRotationDegrees: 90,
            );

        // Media settings to create camera; irrelevant for test.
        const testMediaSettings = MediaSettings();

        // Set up test to use front camera and tell camera that handlesCropAndRotation is false,
        // set camera initial device orientation to landscape left, set initial default display
        // rotation to 90 degrees clockwise.
        setUpOverridesForCreatingTestCamera(
          mockProcessCameraProvider: mockProcessCameraProviderForFrontCamera,
          createCameraSelector: proxyCreateCameraSelectorForFrontCamera,
          handlesCropAndRotation: false,
          getUiOrientation: /* initial device orientation irrelevant for test */
              () async =>
                  _serializeDeviceOrientation(DeviceOrientation.landscapeLeft),
          getDefaultDisplayRotation: () =>
              Future<int>.value(Surface.rotation90),
        );

        // Get and create test front camera.
        final List<CameraDescription> availableCameras = await camera
            .availableCameras();
        expect(availableCameras.length, 1);
        final int flutterSurfaceTextureId = await camera
            .createCameraWithSettings(
              availableCameras.first,
              testMediaSettings,
            );
        await camera.initializeCamera(flutterSurfaceTextureId);

        // Calculated according to: ((90 - 270 * 1 + 360) % 360) - cameraPreviewPreAppliedRotation.
        // 270 is used in this calculation for the device orientation because it is the
        // counter-clockwise degrees of the default display rotation.
        final expectedRotationPerDeviceOrientation = <DeviceOrientation, int>{
          DeviceOrientation.portraitUp: _180DegreesClockwise,
          DeviceOrientation.landscapeRight: _90DegreesClockwise,
          DeviceOrientation.portraitDown: _0DegreesClockwise,
          DeviceOrientation.landscapeLeft: _270DegreesClockwise,
        };

        // Put camera preview in widget tree.
        await tester.pumpWidget(camera.buildPreview(cameraId));

        for (final DeviceOrientation currentDeviceOrientation
            in expectedRotationPerDeviceOrientation.keys) {
          final testEvent = DeviceOrientationChangedEvent(
            currentDeviceOrientation,
          );
          AndroidCameraCameraX.deviceOrientationChangedStreamController.add(
            testEvent,
          );

          await tester.pumpAndSettle();

          // Verify Texture is rotated by expected clockwise degrees.
          final int expectedQuarterTurns =
              expectedRotationPerDeviceOrientation[currentDeviceOrientation]!;
          final RotatedBox rotatedBox = tester.widget<RotatedBox>(
            find.byType(RotatedBox),
          );

          // We expect a Transform widget to wrap the RotatedBox with the camera
          // preview to mirror the preview, since the front camera is being
          // used.
          expect(rotatedBox.child, isA<Transform>());

          final transformedPreview = rotatedBox.child! as Transform;
          final Matrix4 transformedPreviewMatrix = transformedPreview.transform;

          // When the front camera is in landscape mode, we expect the camera
          // preview to be mirrored across the x-axis. When the front camera
          // is in portrait mode, we expect the camera preview to be mirrored
          // across the y-axis.
          if (currentDeviceOrientation == DeviceOrientation.landscapeLeft ||
              currentDeviceOrientation == DeviceOrientation.landscapeRight) {
            checkXAxisIsMirrored(transformedPreviewMatrix);
          } else {
            checkYAxisIsMirrored(transformedPreviewMatrix);
          }
          expect((transformedPreview.child! as Texture).textureId, cameraId);
          final int clockwiseQuarterTurns = rotatedBox.quarterTurns < 0
              ? rotatedBox.quarterTurns + 4
              : rotatedBox.quarterTurns;
          expect(
            clockwiseQuarterTurns,
            expectedQuarterTurns,
            reason:
                'When the device orientation is $currentDeviceOrientation, expected the preview to be rotated by $expectedQuarterTurns quarter turns (which is ${expectedQuarterTurns * 90} degrees clockwise) but instead was rotated ${rotatedBox.quarterTurns} quarter turns.',
          );
        }
      },
    );

    // Test the preview rotation responds to the two most common sensor orientations for Android phone cameras; see
    // https://developer.android.com/media/camera/camera2/camera-preview#camera_orientation.
    group(
      'initial device orientation is DeviceOrientation.landscapeLeft, initial default display rotation is 90, camera is back facing,',
      () {
        late AndroidCameraCameraX camera;
        late int cameraId;
        late MockCameraSelector mockBackCameraSelector;
        late MockCameraSelector Function({
          LensFacing? requireLensFacing,
          dynamic cameraInfoForFilter,
        })
        proxyCreateCameraSelectorForBackCamera;
        late Future<int> Function() proxyGetDefaultDisplayRotation;
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
          proxyGetDefaultDisplayRotation = () =>
              Future<int>.value(Surface.rotation270);

          testMediaSettings = const MediaSettings();
        });

        testWidgets(
          'sensor orientation degrees is 90, then the preview Texture is rotated 270 degrees clockwise',
          (WidgetTester tester) async {
            // Create mock ProcessCameraProvider that will acknowledge that the test back camera with sensor orientation degrees
            // 90 is available.
            final MockProcessCameraProvider
            mockProcessCameraProviderForBackCamera =
                setUpMockCameraSelectorAndMockProcessCameraProviderForSelectingTestCamera(
                  mockCameraSelector: mockBackCameraSelector,
                  sensorRotationDegrees: 90,
                );

            // Set up test to use back camera, tell camera that handlesCropAndRotation is false,
            // set camera initial device orientation to landscape left.
            setUpOverridesForCreatingTestCamera(
              mockProcessCameraProvider: mockProcessCameraProviderForBackCamera,
              createCameraSelector: proxyCreateCameraSelectorForBackCamera,
              getDefaultDisplayRotation: proxyGetDefaultDisplayRotation,
              handlesCropAndRotation: false,
              getUiOrientation: () async =>
                  _serializeDeviceOrientation(testInitialDeviceOrientation),
            );

            // Get and create test back camera.
            final List<CameraDescription> availableCameras = await camera
                .availableCameras();
            expect(availableCameras.length, 1);
            final int flutterSurfaceTextureId = await camera
                .createCameraWithSettings(
                  availableCameras.first,
                  testMediaSettings,
                );
            await camera.initializeCamera(flutterSurfaceTextureId);

            // Put camera preview in widget tree and pump one frame so that Future to retrieve
            // the initial default display rotation completes.
            await tester.pumpWidget(camera.buildPreview(cameraId));
            await tester.pump();

            // Verify Texture is rotated by ((90 - 90 * -1 + 360) % 360) - 270 = -90 degrees clockwise = 270 degrees clockwise.
            // 90 is used in this calculation for the device orientation because it is the counter-clockwise degrees of the
            // default display rotation.
            const int expectedQuarterTurns = _270DegreesClockwise;
            final RotatedBox rotatedBox = tester.widget<RotatedBox>(
              find.byType(RotatedBox),
            );
            final int clockwiseQuarterTurns = rotatedBox.quarterTurns + 4;
            expect(rotatedBox.child, isA<Texture>());
            expect((rotatedBox.child! as Texture).textureId, cameraId);
            expect(
              clockwiseQuarterTurns,
              expectedQuarterTurns,
              reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns,
                rotatedBox.quarterTurns,
              ),
            );
          },
        );

        testWidgets(
          'sensor orientation degrees is 270, then the preview Texture is rotated 90 degrees clockwise',
          (WidgetTester tester) async {
            // Create mock ProcessCameraProvider that will acknowledge that the test back camera with sensor orientation degrees
            // 270 is available.
            final MockProcessCameraProvider
            mockProcessCameraProviderForBackCamera =
                setUpMockCameraSelectorAndMockProcessCameraProviderForSelectingTestCamera(
                  mockCameraSelector: mockBackCameraSelector,
                  sensorRotationDegrees: 270,
                );

            // Set up test to use back camera, tell camera that handlesCropAndRotation is false,
            // set camera initial device orientation to landscape left.
            setUpOverridesForCreatingTestCamera(
              mockProcessCameraProvider: mockProcessCameraProviderForBackCamera,
              createCameraSelector: proxyCreateCameraSelectorForBackCamera,
              getDefaultDisplayRotation: proxyGetDefaultDisplayRotation,
              handlesCropAndRotation: false,
              getUiOrientation: () async =>
                  _serializeDeviceOrientation(testInitialDeviceOrientation),
            );

            // Get and create test back camera.
            final List<CameraDescription> availableCameras = await camera
                .availableCameras();
            expect(availableCameras.length, 1);
            final int flutterSurfaceTextureId = await camera
                .createCameraWithSettings(
                  availableCameras.first,
                  testMediaSettings,
                );
            await camera.initializeCamera(flutterSurfaceTextureId);

            // Put camera preview in widget tree and pump one frame so that Future to retrieve
            // the initial default display rotation completes.
            await tester.pumpWidget(camera.buildPreview(cameraId));
            await tester.pump();

            // Verify Texture is rotated by ((270 - 90 * -1 + 360) % 360) - 270 = -270 degrees clockwise = 90 degrees clockwise.
            // 90 is used in this calculation for the device orientation because it is the counter-clockwise degrees of the
            // default display rotation.
            const int expectedQuarterTurns = _90DegreesClockwise;
            final RotatedBox rotatedBox = tester.widget<RotatedBox>(
              find.byType(RotatedBox),
            );
            final int clockwiseQuarterTurns = rotatedBox.quarterTurns + 4;
            expect(rotatedBox.child, isA<Texture>());
            expect((rotatedBox.child! as Texture).textureId, cameraId);
            expect(
              clockwiseQuarterTurns,
              expectedQuarterTurns,
              reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns,
                rotatedBox.quarterTurns,
              ),
            );
          },
        );
      },
    );

    // Test the preview rotation responds to the camera being front or back facing:
    group(
      'initial device orientation is DeviceOrientation.landscapeRight, initial default displauy rotation is 0 degrees, sensor orientation degrees is 90,',
      () {
        late AndroidCameraCameraX camera;
        late int cameraId;
        late DeviceOrientation testInitialDeviceOrientation;
        late int testSensorOrientation;
        late Future<int> Function() proxyGetDefaultDisplayRotation;
        late MediaSettings testMediaSettings;

        setUp(() {
          camera = AndroidCameraCameraX();
          cameraId = 317;

          // Set test camera initial device orientation and sensor orientation for test.
          testInitialDeviceOrientation = DeviceOrientation.landscapeRight;
          testSensorOrientation = 90;

          // Create mock for seting initial default display rotation to 180 degrees.
          proxyGetDefaultDisplayRotation = () =>
              Future<int>.value(Surface.rotation90);

          // Media settings to create camera; irrelevant for test.
          testMediaSettings = const MediaSettings();
        });

        testWidgets(
          'camera is front facing, then the preview Texture is rotated 90 degrees clockwise',
          (WidgetTester tester) async {
            // Set up test front camera with sensor orientation degrees 90.
            final mockFrontCameraSelector = MockCameraSelector();
            final MockProcessCameraProvider mockProcessCameraProvider =
                setUpMockCameraSelectorAndMockProcessCameraProviderForSelectingTestCamera(
                  mockCameraSelector: mockFrontCameraSelector,
                  sensorRotationDegrees: testSensorOrientation,
                );
            // Set up front camera selection and initial device orientation as landscape right.
            final MockCameraSelector Function({
              LensFacing? requireLensFacing,
              dynamic cameraInfoForFilter,
            })
            proxyCreateCameraSelectorForFrontCamera =
                createCameraSelectorForFrontCamera(mockFrontCameraSelector);
            setUpOverridesForCreatingTestCamera(
              mockProcessCameraProvider: mockProcessCameraProvider,
              createCameraSelector: proxyCreateCameraSelectorForFrontCamera,
              getDefaultDisplayRotation: proxyGetDefaultDisplayRotation,
              handlesCropAndRotation: false,
              getUiOrientation: () async =>
                  _serializeDeviceOrientation(testInitialDeviceOrientation),
            );

            // Get and create test camera.
            final List<CameraDescription> availableCameras = await camera
                .availableCameras();
            expect(availableCameras.length, 1);
            final int flutterSurfaceTextureId = await camera
                .createCameraWithSettings(
                  availableCameras.first,
                  testMediaSettings,
                );
            await camera.initializeCamera(flutterSurfaceTextureId);

            // Put camera preview in widget tree and pump one frame so that Future to retrieve
            // the initial default display rotation completes.
            await tester.pumpWidget(camera.buildPreview(cameraId));
            await tester.pump();

            // Verify Texture is rotated by ((90 - 270 * 1 + 360) % 360) - 90 = 90 degrees clockwise.
            // 270 is used in this calculation for the device orientation because it is the counter-clockwise degrees of the
            // default display rotation.
            const int expectedQuarterTurns = _90DegreesClockwise;
            final RotatedBox rotatedBox = tester.widget<RotatedBox>(
              find.byType(RotatedBox),
            );

            // We expect a Transform widget to wrap the RotatedBox with the camera
            // preview to mirror the preview, since the front camera is being
            // used.
            expect(rotatedBox.child, isA<Transform>());

            final transformedPreview = rotatedBox.child! as Transform;
            final Matrix4 transformedPreviewMatrix =
                transformedPreview.transform;

            // Since the front camera is in landscape mode, we expect the camera
            // preview to be mirrored across the x-axis.
            checkXAxisIsMirrored(transformedPreviewMatrix);
            expect((transformedPreview.child! as Texture).textureId, cameraId);
            expect(
              rotatedBox.quarterTurns,
              expectedQuarterTurns,
              reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns,
                rotatedBox.quarterTurns,
              ),
            );
          },
        );

        testWidgets(
          'camera is back facing, then the preview Texture is rotated 270 degrees clockwise',
          (WidgetTester tester) async {
            // Set up test front camera with sensor orientation degrees 90.
            final mockBackCameraSelector = MockCameraSelector();
            final MockProcessCameraProvider mockProcessCameraProvider =
                setUpMockCameraSelectorAndMockProcessCameraProviderForSelectingTestCamera(
                  mockCameraSelector: mockBackCameraSelector,
                  sensorRotationDegrees: testSensorOrientation,
                );

            // Set up front camera selection and initial device orientation as landscape right.
            final MockCameraSelector Function({
              LensFacing? requireLensFacing,
              dynamic cameraInfoForFilter,
            })
            proxyCreateCameraSelectorForFrontCamera =
                createCameraSelectorForBackCamera(mockBackCameraSelector);
            setUpOverridesForCreatingTestCamera(
              mockProcessCameraProvider: mockProcessCameraProvider,
              createCameraSelector: proxyCreateCameraSelectorForFrontCamera,
              getDefaultDisplayRotation: proxyGetDefaultDisplayRotation,
              handlesCropAndRotation: false,
              getUiOrientation: () async =>
                  _serializeDeviceOrientation(testInitialDeviceOrientation),
            );

            // Get and create test camera.
            final List<CameraDescription> availableCameras = await camera
                .availableCameras();
            expect(availableCameras.length, 1);
            final int flutterSurfaceTextureId = await camera
                .createCameraWithSettings(
                  availableCameras.first,
                  testMediaSettings,
                );
            await camera.initializeCamera(flutterSurfaceTextureId);

            // Put camera preview in widget tree and pump one frame so that Future to retrieve
            // the initial default display rotation completes.
            await tester.pumpWidget(camera.buildPreview(cameraId));
            await tester.pump();

            // Verify Texture is rotated by ((90 - 270 * -1 + 360) % 360) - 90 = -90 degrees clockwise = 270 degrees clockwise.
            // 270 is used in this calculation for the device orientation because it is the counter-clockwise degrees of the
            // default display rotation.
            const int expectedQuarterTurns = _270DegreesClockwise;
            final RotatedBox rotatedBox = tester.widget<RotatedBox>(
              find.byType(RotatedBox),
            );
            final int clockwiseQuarterTurns = rotatedBox.quarterTurns + 4;
            expect(rotatedBox.child, isA<Texture>());
            expect((rotatedBox.child! as Texture).textureId, cameraId);
            expect(
              clockwiseQuarterTurns,
              expectedQuarterTurns,
              reason: getExpectedRotationTestFailureReason(
                expectedQuarterTurns,
                rotatedBox.quarterTurns,
              ),
            );
          },
        );
      },
    );
  });
}
