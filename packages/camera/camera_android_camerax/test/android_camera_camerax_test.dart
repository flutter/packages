// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:async/async.dart';
import 'package:camera_android_camerax/camera_android_camerax.dart';
import 'package:camera_android_camerax/src/analyzer.dart';
import 'package:camera_android_camerax/src/camera.dart';
import 'package:camera_android_camerax/src/camera_control.dart';
import 'package:camera_android_camerax/src/camera_info.dart';
import 'package:camera_android_camerax/src/camera_selector.dart';
import 'package:camera_android_camerax/src/camera_state.dart';
import 'package:camera_android_camerax/src/camera_state_error.dart';
import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/camerax_proxy.dart';
import 'package:camera_android_camerax/src/exposure_state.dart';
import 'package:camera_android_camerax/src/fallback_strategy.dart';
import 'package:camera_android_camerax/src/image_analysis.dart';
import 'package:camera_android_camerax/src/image_capture.dart';
import 'package:camera_android_camerax/src/image_proxy.dart';
import 'package:camera_android_camerax/src/live_data.dart';
import 'package:camera_android_camerax/src/observer.dart';
import 'package:camera_android_camerax/src/pending_recording.dart';
import 'package:camera_android_camerax/src/plane_proxy.dart';
import 'package:camera_android_camerax/src/preview.dart';
import 'package:camera_android_camerax/src/process_camera_provider.dart';
import 'package:camera_android_camerax/src/quality_selector.dart';
import 'package:camera_android_camerax/src/recorder.dart';
import 'package:camera_android_camerax/src/recording.dart';
import 'package:camera_android_camerax/src/resolution_selector.dart';
import 'package:camera_android_camerax/src/resolution_strategy.dart';
import 'package:camera_android_camerax/src/system_services.dart';
import 'package:camera_android_camerax/src/use_case.dart';
import 'package:camera_android_camerax/src/video_capture.dart';
import 'package:camera_android_camerax/src/zoom_state.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart' show DeviceOrientation, Uint8List;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'android_camera_camerax_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<Analyzer>(),
  MockSpec<Camera>(),
  MockSpec<CameraInfo>(),
  MockSpec<CameraControl>(),
  MockSpec<CameraImageData>(),
  MockSpec<CameraSelector>(),
  MockSpec<ExposureState>(),
  MockSpec<FallbackStrategy>(),
  MockSpec<ImageAnalysis>(),
  MockSpec<ImageCapture>(),
  MockSpec<ImageProxy>(),
  MockSpec<Observer<CameraState>>(),
  MockSpec<PendingRecording>(),
  MockSpec<PlaneProxy>(),
  MockSpec<Preview>(),
  MockSpec<ProcessCameraProvider>(),
  MockSpec<QualitySelector>(),
  MockSpec<Recorder>(),
  MockSpec<ResolutionSelector>(),
  MockSpec<ResolutionStrategy>(),
  MockSpec<Recording>(),
  MockSpec<VideoCapture>(),
  MockSpec<BuildContext>(),
  MockSpec<TestInstanceManagerHostApi>(),
  MockSpec<TestSystemServicesHostApi>(),
  MockSpec<ZoomState>(),
])
@GenerateMocks(<Type>[], customMocks: <MockSpec<Object>>[
  MockSpec<LiveData<CameraState>>(as: #MockLiveCameraState),
  MockSpec<LiveData<ZoomState>>(as: #MockLiveZoomState),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  /// Helper method for testing sending/receiving CameraErrorEvents.
  Future<bool> testCameraClosingObserver(AndroidCameraCameraX camera,
      int cameraId, Observer<dynamic> observer) async {
    final CameraStateError testCameraStateError =
        CameraStateError.detached(code: 0);
    final Stream<CameraClosingEvent> cameraClosingEventStream =
        camera.onCameraClosing(cameraId);
    final StreamQueue<CameraClosingEvent> cameraClosingStreamQueue =
        StreamQueue<CameraClosingEvent>(cameraClosingEventStream);
    final Stream<CameraErrorEvent> cameraErrorEventStream =
        camera.onCameraError(cameraId);
    final StreamQueue<CameraErrorEvent> cameraErrorStreamQueue =
        StreamQueue<CameraErrorEvent>(cameraErrorEventStream);

    observer.onChanged(CameraState.detached(
        type: CameraStateType.closing, error: testCameraStateError));

    final bool cameraClosingEventSent =
        await cameraClosingStreamQueue.next == CameraClosingEvent(cameraId);
    final bool cameraErrorSent = await cameraErrorStreamQueue.next ==
        CameraErrorEvent(cameraId, testCameraStateError.getDescription());

    await cameraClosingStreamQueue.cancel();
    await cameraErrorStreamQueue.cancel();

    return cameraClosingEventSent && cameraErrorSent;
  }

  test('Should fetch CameraDescription instances for available cameras',
      () async {
    // Arrange
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final List<dynamic> returnData = <dynamic>[
      <String, dynamic>{
        'name': 'Camera 0',
        'lensFacing': 'back',
        'sensorOrientation': 0
      },
      <String, dynamic>{
        'name': 'Camera 1',
        'lensFacing': 'front',
        'sensorOrientation': 90
      }
    ];

    // Create mocks to use
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();
    final MockCameraSelector mockFrontCameraSelector = MockCameraSelector();
    final MockCameraSelector mockBackCameraSelector = MockCameraSelector();
    final MockCameraInfo mockFrontCameraInfo = MockCameraInfo();
    final MockCameraInfo mockBackCameraInfo = MockCameraInfo();

    // Tell plugin to create mock CameraSelectors for testing.
    camera.proxy = CameraXProxy(
      getProcessCameraProvider: () =>
          Future<ProcessCameraProvider>.value(mockProcessCameraProvider),
      createCameraSelector: (int cameraSelectorLensDirection) {
        switch (cameraSelectorLensDirection) {
          case CameraSelector.lensFacingFront:
            return mockFrontCameraSelector;
          case CameraSelector.lensFacingBack:
          default:
            return mockBackCameraSelector;
        }
      },
    );

    // Mock calls to native platform
    when(mockProcessCameraProvider.getAvailableCameraInfos()).thenAnswer(
        (_) async => <MockCameraInfo>[mockBackCameraInfo, mockFrontCameraInfo]);
    when(mockBackCameraSelector.filter(<MockCameraInfo>[mockFrontCameraInfo]))
        .thenAnswer((_) async => <MockCameraInfo>[]);
    when(mockBackCameraSelector.filter(<MockCameraInfo>[mockBackCameraInfo]))
        .thenAnswer((_) async => <MockCameraInfo>[mockBackCameraInfo]);
    when(mockFrontCameraSelector.filter(<MockCameraInfo>[mockBackCameraInfo]))
        .thenAnswer((_) async => <MockCameraInfo>[]);
    when(mockFrontCameraSelector.filter(<MockCameraInfo>[mockFrontCameraInfo]))
        .thenAnswer((_) async => <MockCameraInfo>[mockFrontCameraInfo]);
    when(mockBackCameraInfo.getSensorRotationDegrees())
        .thenAnswer((_) async => 0);
    when(mockFrontCameraInfo.getSensorRotationDegrees())
        .thenAnswer((_) async => 90);

    final List<CameraDescription> cameraDescriptions =
        await camera.availableCameras();

    expect(cameraDescriptions.length, returnData.length);
    for (int i = 0; i < returnData.length; i++) {
      final Map<String, Object?> typedData =
          (returnData[i] as Map<dynamic, dynamic>).cast<String, Object?>();
      final CameraDescription cameraDescription = CameraDescription(
        name: typedData['name']! as String,
        lensDirection: (typedData['lensFacing']! as String) == 'front'
            ? CameraLensDirection.front
            : CameraLensDirection.back,
        sensorOrientation: typedData['sensorOrientation']! as int,
      );
      expect(cameraDescriptions[i], cameraDescription);
    }
  });

  test(
      'createCamera requests permissions, starts listening for device orientation changes, updates camera state observers, and returns flutter surface texture ID',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const CameraLensDirection testLensDirection = CameraLensDirection.back;
    const int testSensorOrientation = 90;
    const CameraDescription testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation);
    const ResolutionPreset testResolutionPreset = ResolutionPreset.veryHigh;
    const bool enableAudio = true;
    const int testSurfaceTextureId = 6;

    // Mock/Detached objects for (typically attached) objects created by
    // createCamera.
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();
    final MockPreview mockPreview = MockPreview();
    final MockCameraSelector mockBackCameraSelector = MockCameraSelector();
    final MockImageCapture mockImageCapture = MockImageCapture();
    final MockImageAnalysis mockImageAnalysis = MockImageAnalysis();
    final MockRecorder mockRecorder = MockRecorder();
    final MockVideoCapture mockVideoCapture = MockVideoCapture();
    final MockCamera mockCamera = MockCamera();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final MockLiveCameraState mockLiveCameraState = MockLiveCameraState();
    bool cameraPermissionsRequested = false;
    bool startedListeningForDeviceOrientationChanges = false;

    // Tell plugin to create mock/detached objects and stub method calls for the
    // testing of createCamera.
    camera.proxy = CameraXProxy(
      getProcessCameraProvider: () =>
          Future<ProcessCameraProvider>.value(mockProcessCameraProvider),
      createCameraSelector: (int cameraSelectorLensDirection) {
        switch (cameraSelectorLensDirection) {
          case CameraSelector.lensFacingFront:
            return MockCameraSelector();
          case CameraSelector.lensFacingBack:
          default:
            return mockBackCameraSelector;
        }
      },
      createPreview: (
              {required int targetRotation,
              ResolutionSelector? resolutionSelector}) =>
          mockPreview,
      createImageCapture: (_) => mockImageCapture,
      createRecorder: (_) => mockRecorder,
      createVideoCapture: (_) => Future<VideoCapture>.value(mockVideoCapture),
      createImageAnalysis: (_) => mockImageAnalysis,
      createResolutionStrategy: (
              {bool highestAvailable = false,
              Size? boundSize,
              int? fallbackRule}) =>
          MockResolutionStrategy(),
      createResolutionSelector: (_) => MockResolutionSelector(),
      createFallbackStrategy: (
              {required VideoQuality quality,
              required VideoResolutionFallbackRule fallbackRule}) =>
          MockFallbackStrategy(),
      createQualitySelector: (
              {required VideoQuality videoQuality,
              required FallbackStrategy fallbackStrategy}) =>
          MockQualitySelector(),
      createCameraStateObserver: (void Function(Object) onChanged) =>
          Observer<CameraState>.detached(onChanged: onChanged),
      requestCameraPermissions: (_) {
        cameraPermissionsRequested = true;
        return Future<void>.value();
      },
      startListeningForDeviceOrientationChange: (_, __) {
        startedListeningForDeviceOrientationChanges = true;
      },
    );

    when(mockPreview.setSurfaceProvider())
        .thenAnswer((_) async => testSurfaceTextureId);
    when(mockProcessCameraProvider.bindToLifecycle(mockBackCameraSelector,
            <UseCase>[mockPreview, mockImageCapture, mockImageAnalysis]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => mockLiveCameraState);
    camera.processCameraProvider = mockProcessCameraProvider;

    expect(
        await camera.createCamera(testCameraDescription, testResolutionPreset,
            enableAudio: enableAudio),
        equals(testSurfaceTextureId));

    // Verify permissions are requested and the camera starts listening for device orientation changes.
    expect(cameraPermissionsRequested, isTrue);
    expect(startedListeningForDeviceOrientationChanges, isTrue);

    // Verify CameraSelector is set with appropriate lens direction.
    expect(camera.cameraSelector, equals(mockBackCameraSelector));

    // Verify the camera's Preview instance is instantiated properly.
    expect(camera.preview, equals(mockPreview));

    // Verify the camera's ImageCapture instance is instantiated properly.
    expect(camera.imageCapture, equals(mockImageCapture));

    // Verify the camera's Recorder and VideoCapture instances are instantiated properly.
    expect(camera.recorder, equals(mockRecorder));
    expect(camera.videoCapture, equals(mockVideoCapture));

    // Verify the camera's Preview instance has its surface provider set.
    verify(camera.preview!.setSurfaceProvider());

    // Verify the camera state observer is updated.
    expect(
        await testCameraClosingObserver(
            camera,
            testSurfaceTextureId,
            verify(mockLiveCameraState.observe(captureAny)).captured.single
                as Observer<CameraState>),
        isTrue);
  });

  test(
      'createCamera binds Preview and ImageCapture use cases to ProcessCameraProvider instance',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const CameraLensDirection testLensDirection = CameraLensDirection.back;
    const int testSensorOrientation = 90;
    const CameraDescription testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation);
    const ResolutionPreset testResolutionPreset = ResolutionPreset.veryHigh;
    const bool enableAudio = true;

    // Mock/Detached objects for (typically attached) objects created by
    // createCamera.
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();
    final MockPreview mockPreview = MockPreview();
    final MockCameraSelector mockBackCameraSelector = MockCameraSelector();
    final MockImageCapture mockImageCapture = MockImageCapture();
    final MockImageAnalysis mockImageAnalysis = MockImageAnalysis();
    final MockRecorder mockRecorder = MockRecorder();
    final MockVideoCapture mockVideoCapture = MockVideoCapture();
    final MockCamera mockCamera = MockCamera();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();

    // Tell plugin to create mock/detached objects and stub method calls for the
    // testing of createCamera.
    camera.proxy = CameraXProxy(
      getProcessCameraProvider: () =>
          Future<ProcessCameraProvider>.value(mockProcessCameraProvider),
      createCameraSelector: (int cameraSelectorLensDirection) {
        switch (cameraSelectorLensDirection) {
          case CameraSelector.lensFacingFront:
            return MockCameraSelector();
          case CameraSelector.lensFacingBack:
          default:
            return mockBackCameraSelector;
        }
      },
      createPreview: (
              {required int targetRotation,
              ResolutionSelector? resolutionSelector}) =>
          mockPreview,
      createImageCapture: (_) => mockImageCapture,
      createRecorder: (_) => mockRecorder,
      createVideoCapture: (_) => Future<VideoCapture>.value(mockVideoCapture),
      createImageAnalysis: (_) => mockImageAnalysis,
      createResolutionStrategy: (
              {bool highestAvailable = false,
              Size? boundSize,
              int? fallbackRule}) =>
          MockResolutionStrategy(),
      createResolutionSelector: (_) => MockResolutionSelector(),
      createFallbackStrategy: (
              {required VideoQuality quality,
              required VideoResolutionFallbackRule fallbackRule}) =>
          MockFallbackStrategy(),
      createQualitySelector: (
              {required VideoQuality videoQuality,
              required FallbackStrategy fallbackStrategy}) =>
          MockQualitySelector(),
      createCameraStateObserver: (void Function(Object) onChanged) =>
          Observer<CameraState>.detached(onChanged: onChanged),
      requestCameraPermissions: (_) => Future<void>.value(),
      startListeningForDeviceOrientationChange: (_, __) {},
    );

    when(mockProcessCameraProvider.bindToLifecycle(mockBackCameraSelector,
            <UseCase>[mockPreview, mockImageCapture, mockImageAnalysis]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());
    camera.processCameraProvider = mockProcessCameraProvider;

    await camera.createCamera(testCameraDescription, testResolutionPreset,
        enableAudio: enableAudio);

    // Verify expected UseCases were bound.
    verify(camera.processCameraProvider!.bindToLifecycle(camera.cameraSelector!,
        <UseCase>[mockPreview, mockImageCapture, mockImageAnalysis]));

    // Verify the camera's CameraInfo instance got updated.
    expect(camera.cameraInfo, equals(mockCameraInfo));
  });

  test(
      'createCamera properly sets preset resolution for non-video capture use cases',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const CameraLensDirection testLensDirection = CameraLensDirection.back;
    const int testSensorOrientation = 90;
    const CameraDescription testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation);
    const bool enableAudio = true;
    final MockCamera mockCamera = MockCamera();

    // Mock/Detached objects for (typically attached) objects created by
    // createCamera.
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final MockCameraSelector mockBackCameraSelector = MockCameraSelector();
    final MockCameraSelector mockFrontCameraSelector = MockCameraSelector();
    final MockVideoCapture mockVideoCapture = MockVideoCapture();
    final MockRecorder mockRecorder = MockRecorder();

    // Tell plugin to create mock/detached objects for testing createCamera
    // as needed.
    camera.proxy = CameraXProxy(
      getProcessCameraProvider: () =>
          Future<ProcessCameraProvider>.value(mockProcessCameraProvider),
      createCameraSelector: (int cameraSelectorLensDirection) {
        switch (cameraSelectorLensDirection) {
          case CameraSelector.lensFacingFront:
            return mockFrontCameraSelector;
          case CameraSelector.lensFacingBack:
          default:
            return mockBackCameraSelector;
        }
      },
      createPreview: (
              {required int targetRotation,
              ResolutionSelector? resolutionSelector}) =>
          Preview.detached(
              targetRotation: targetRotation,
              resolutionSelector: resolutionSelector),
      createImageCapture: (ResolutionSelector? resolutionSelector) =>
          ImageCapture.detached(resolutionSelector: resolutionSelector),
      createRecorder: (_) => mockRecorder,
      createVideoCapture: (_) => Future<VideoCapture>.value(mockVideoCapture),
      createImageAnalysis: (ResolutionSelector? resolutionSelector) =>
          ImageAnalysis.detached(resolutionSelector: resolutionSelector),
      createResolutionStrategy: (
          {bool highestAvailable = false, Size? boundSize, int? fallbackRule}) {
        if (highestAvailable) {
          return ResolutionStrategy.detachedHighestAvailableStrategy();
        }

        return ResolutionStrategy.detached(
            boundSize: boundSize, fallbackRule: fallbackRule);
      },
      createResolutionSelector: (ResolutionStrategy resolutionStrategy) =>
          ResolutionSelector.detached(resolutionStrategy: resolutionStrategy),
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
          3), // 3 is a random Flutter SurfaceTexture ID for testing},
    );

    when(mockProcessCameraProvider.bindToLifecycle(mockBackCameraSelector, any))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());
    camera.processCameraProvider = mockProcessCameraProvider;

    // Test non-null resolution presets.
    for (final ResolutionPreset resolutionPreset in ResolutionPreset.values) {
      await camera.createCamera(testCameraDescription, resolutionPreset,
          enableAudio: enableAudio);

      Size? expectedBoundSize;
      ResolutionStrategy? expectedResolutionStrategy;
      switch (resolutionPreset) {
        case ResolutionPreset.low:
          expectedBoundSize = const Size(320, 240);
          break;
        case ResolutionPreset.medium:
          expectedBoundSize = const Size(720, 480);
          break;
        case ResolutionPreset.high:
          expectedBoundSize = const Size(1280, 720);
          break;
        case ResolutionPreset.veryHigh:
          expectedBoundSize = const Size(1920, 1080);
          break;
        case ResolutionPreset.ultraHigh:
          expectedBoundSize = const Size(3840, 2160);
          break;
        case ResolutionPreset.max:
          expectedResolutionStrategy =
              ResolutionStrategy.detachedHighestAvailableStrategy();
          break;
      }

      // We expect the strategy to be the highest available or correspond to the
      // expected bound size, with fallback to the closest and highest available
      // resolution.
      expectedResolutionStrategy ??= ResolutionStrategy.detached(
          boundSize: expectedBoundSize,
          fallbackRule: ResolutionStrategy.fallbackRuleClosestLowerThenHigher);

      expect(camera.preview!.resolutionSelector!.resolutionStrategy!.boundSize,
          equals(expectedResolutionStrategy.boundSize));
      expect(
          camera
              .imageCapture!.resolutionSelector!.resolutionStrategy!.boundSize,
          equals(expectedResolutionStrategy.boundSize));
      expect(
          camera
              .imageAnalysis!.resolutionSelector!.resolutionStrategy!.boundSize,
          equals(expectedResolutionStrategy.boundSize));
      expect(
          camera.preview!.resolutionSelector!.resolutionStrategy!.fallbackRule,
          equals(expectedResolutionStrategy.fallbackRule));
      expect(
          camera.imageCapture!.resolutionSelector!.resolutionStrategy!
              .fallbackRule,
          equals(expectedResolutionStrategy.fallbackRule));
      expect(
          camera.imageAnalysis!.resolutionSelector!.resolutionStrategy!
              .fallbackRule,
          equals(expectedResolutionStrategy.fallbackRule));
    }

    // Test null case.
    await camera.createCamera(testCameraDescription, null);
    expect(camera.preview!.resolutionSelector, isNull);
    expect(camera.imageCapture!.resolutionSelector, isNull);
    expect(camera.imageAnalysis!.resolutionSelector, isNull);
  });

  test(
      'createCamera properly sets preset resolution for video capture use case',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const CameraLensDirection testLensDirection = CameraLensDirection.back;
    const int testSensorOrientation = 90;
    const CameraDescription testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation);
    const bool enableAudio = true;
    final MockCamera mockCamera = MockCamera();

    // Mock/Detached objects for (typically attached) objects created by
    // createCamera.
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final MockCameraSelector mockBackCameraSelector = MockCameraSelector();
    final MockCameraSelector mockFrontCameraSelector = MockCameraSelector();
    final MockPreview mockPreview = MockPreview();
    final MockImageCapture mockImageCapture = MockImageCapture();
    final MockVideoCapture mockVideoCapture = MockVideoCapture();
    final MockImageAnalysis mockImageAnalysis = MockImageAnalysis();

    // Tell plugin to create mock/detached objects for testing createCamera
    // as needed.
    camera.proxy = CameraXProxy(
      getProcessCameraProvider: () =>
          Future<ProcessCameraProvider>.value(mockProcessCameraProvider),
      createCameraSelector: (int cameraSelectorLensDirection) {
        switch (cameraSelectorLensDirection) {
          case CameraSelector.lensFacingFront:
            return mockFrontCameraSelector;
          case CameraSelector.lensFacingBack:
          default:
            return mockBackCameraSelector;
        }
      },
      createPreview: (
              {required int targetRotation,
              ResolutionSelector? resolutionSelector}) =>
          mockPreview,
      createImageCapture: (_) => mockImageCapture,
      createRecorder: (QualitySelector? qualitySelector) =>
          Recorder.detached(qualitySelector: qualitySelector),
      createVideoCapture: (_) => Future<VideoCapture>.value(mockVideoCapture),
      createImageAnalysis: (_) => mockImageAnalysis,
      createResolutionStrategy: (
              {bool highestAvailable = false,
              Size? boundSize,
              int? fallbackRule}) =>
          MockResolutionStrategy(),
      createResolutionSelector: (_) => MockResolutionSelector(),
      createFallbackStrategy: (
              {required VideoQuality quality,
              required VideoResolutionFallbackRule fallbackRule}) =>
          FallbackStrategy.detached(
              quality: quality, fallbackRule: fallbackRule),
      createQualitySelector: (
              {required VideoQuality videoQuality,
              required FallbackStrategy fallbackStrategy}) =>
          QualitySelector.detached(qualityList: <VideoQualityData>[
        VideoQualityData(quality: videoQuality)
      ], fallbackStrategy: fallbackStrategy),
      createCameraStateObserver: (void Function(Object) onChanged) =>
          Observer<CameraState>.detached(onChanged: onChanged),
      requestCameraPermissions: (_) => Future<void>.value(),
      startListeningForDeviceOrientationChange: (_, __) {},
    );

    when(mockProcessCameraProvider.bindToLifecycle(mockBackCameraSelector,
            <UseCase>[mockPreview, mockImageCapture, mockImageAnalysis]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());

    // Test non-null resolution presets.
    for (final ResolutionPreset resolutionPreset in ResolutionPreset.values) {
      await camera.createCamera(testCameraDescription, resolutionPreset,
          enableAudio: enableAudio);

      VideoQuality? expectedVideoQuality;
      switch (resolutionPreset) {
        case ResolutionPreset.low:
        // 240p is not supported by CameraX.
        case ResolutionPreset.medium:
          expectedVideoQuality = VideoQuality.SD;
          break;
        case ResolutionPreset.high:
          expectedVideoQuality = VideoQuality.HD;
          break;
        case ResolutionPreset.veryHigh:
          expectedVideoQuality = VideoQuality.FHD;
          break;
        case ResolutionPreset.ultraHigh:
          expectedVideoQuality = VideoQuality.UHD;
          break;
        case ResolutionPreset.max:
          expectedVideoQuality = VideoQuality.highest;
          break;
      }

      const VideoResolutionFallbackRule expectedFallbackRule =
          VideoResolutionFallbackRule.lowerQualityOrHigherThan;
      final FallbackStrategy expectedFallbackStrategy =
          FallbackStrategy.detached(
              quality: expectedVideoQuality,
              fallbackRule: expectedFallbackRule);

      expect(camera.recorder!.qualitySelector!.qualityList.length, equals(1));
      expect(camera.recorder!.qualitySelector!.qualityList.first.quality,
          equals(expectedVideoQuality));
      expect(camera.recorder!.qualitySelector!.fallbackStrategy!.quality,
          equals(expectedFallbackStrategy.quality));
      expect(camera.recorder!.qualitySelector!.fallbackStrategy!.fallbackRule,
          equals(expectedFallbackStrategy.fallbackRule));
    }

    // Test null case.
    await camera.createCamera(testCameraDescription, null);
    expect(camera.recorder!.qualitySelector, isNull);
  });

  test(
      'initializeCamera throws a CameraException when createCamera has not been called before initializedCamera',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    expect(() => camera.initializeCamera(3), throwsA(isA<CameraException>()));
  });

  test('initializeCamera sends expected CameraInitializedEvent', () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();

    const int cameraId = 10;
    const CameraLensDirection testLensDirection = CameraLensDirection.back;
    const int testSensorOrientation = 90;
    const CameraDescription testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation);
    const ResolutionPreset testResolutionPreset = ResolutionPreset.veryHigh;
    const bool enableAudio = true;
    const int resolutionWidth = 350;
    const int resolutionHeight = 750;
    final Camera mockCamera = MockCamera();
    final ResolutionInfo testResolutionInfo =
        ResolutionInfo(width: resolutionWidth, height: resolutionHeight);

    // Mocks for (typically attached) objects created by createCamera.
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();
    final CameraInfo mockCameraInfo = MockCameraInfo();
    final MockCameraSelector mockBackCameraSelector = MockCameraSelector();
    final MockCameraSelector mockFrontCameraSelector = MockCameraSelector();
    final MockPreview mockPreview = MockPreview();
    final MockImageCapture mockImageCapture = MockImageCapture();
    final MockImageAnalysis mockImageAnalysis = MockImageAnalysis();

    // Tell plugin to create mock/detached objects for testing createCamera
    // as needed.
    camera.proxy = CameraXProxy(
      getProcessCameraProvider: () =>
          Future<ProcessCameraProvider>.value(mockProcessCameraProvider),
      createCameraSelector: (int cameraSelectorLensDirection) {
        switch (cameraSelectorLensDirection) {
          case CameraSelector.lensFacingFront:
            return mockFrontCameraSelector;
          case CameraSelector.lensFacingBack:
          default:
            return mockBackCameraSelector;
        }
      },
      createPreview: (
              {required int targetRotation,
              ResolutionSelector? resolutionSelector}) =>
          mockPreview,
      createImageCapture: (_) => mockImageCapture,
      createRecorder: (QualitySelector? qualitySelector) => MockRecorder(),
      createVideoCapture: (_) => Future<VideoCapture>.value(MockVideoCapture()),
      createImageAnalysis: (_) => mockImageAnalysis,
      createResolutionStrategy: (
              {bool highestAvailable = false,
              Size? boundSize,
              int? fallbackRule}) =>
          MockResolutionStrategy(),
      createResolutionSelector: (_) => MockResolutionSelector(),
      createFallbackStrategy: (
              {required VideoQuality quality,
              required VideoResolutionFallbackRule fallbackRule}) =>
          MockFallbackStrategy(),
      createQualitySelector: (
              {required VideoQuality videoQuality,
              required FallbackStrategy fallbackStrategy}) =>
          MockQualitySelector(),
      createCameraStateObserver: (void Function(Object) onChanged) =>
          Observer<CameraState>.detached(onChanged: onChanged),
      requestCameraPermissions: (_) => Future<void>.value(),
      startListeningForDeviceOrientationChange: (_, __) {},
    );

    // TODO(camsim99): Modify this when camera configuration is supported and
    // default values no longer being used.
    // https://github.com/flutter/flutter/issues/120468
    // https://github.com/flutter/flutter/issues/120467
    final CameraInitializedEvent testCameraInitializedEvent =
        CameraInitializedEvent(
            cameraId,
            resolutionWidth.toDouble(),
            resolutionHeight.toDouble(),
            ExposureMode.auto,
            false,
            FocusMode.auto,
            false);

    // Call createCamera.
    when(mockPreview.setSurfaceProvider()).thenAnswer((_) async => cameraId);

    when(mockProcessCameraProvider.bindToLifecycle(mockBackCameraSelector,
            <UseCase>[mockPreview, mockImageCapture, mockImageAnalysis]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());
    when(mockPreview.getResolutionInfo())
        .thenAnswer((_) async => testResolutionInfo);

    await camera.createCamera(testCameraDescription, testResolutionPreset,
        enableAudio: enableAudio);

    // Start listening to camera events stream to verify the proper CameraInitializedEvent is sent.
    camera.cameraEventStreamController.stream.listen((CameraEvent event) {
      expect(event, const TypeMatcher<CameraInitializedEvent>());
      expect(event, equals(testCameraInitializedEvent));
    });

    await camera.initializeCamera(cameraId);

    // Check camera instance was received.
    expect(camera.camera, isNotNull);
  });

  test(
      'dispose releases Flutter surface texture, removes camera state observers, and unbinds all use cases',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();

    camera.preview = MockPreview();
    camera.processCameraProvider = MockProcessCameraProvider();
    camera.liveCameraState = MockLiveCameraState();
    camera.imageAnalysis = MockImageAnalysis();

    await camera.dispose(3);

    verify(camera.preview!.releaseFlutterSurfaceTexture());
    verify(camera.liveCameraState!.removeObservers());
    verify(camera.processCameraProvider!.unbindAll());
    verify(camera.imageAnalysis!.clearAnalyzer());
  });

  test('onCameraInitialized stream emits CameraInitializedEvents', () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 16;
    final Stream<CameraInitializedEvent> eventStream =
        camera.onCameraInitialized(cameraId);
    final StreamQueue<CameraInitializedEvent> streamQueue =
        StreamQueue<CameraInitializedEvent>(eventStream);
    const CameraInitializedEvent testEvent = CameraInitializedEvent(
        cameraId, 320, 80, ExposureMode.auto, false, FocusMode.auto, false);

    camera.cameraEventStreamController.add(testEvent);

    expect(await streamQueue.next, testEvent);
    await streamQueue.cancel();
  });

  test(
      'onCameraClosing stream emits camera closing event when cameraEventStreamController emits a camera closing event',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 99;
    const CameraClosingEvent cameraClosingEvent = CameraClosingEvent(cameraId);
    final Stream<CameraClosingEvent> eventStream =
        camera.onCameraClosing(cameraId);
    final StreamQueue<CameraClosingEvent> streamQueue =
        StreamQueue<CameraClosingEvent>(eventStream);

    camera.cameraEventStreamController.add(cameraClosingEvent);

    expect(await streamQueue.next, equals(cameraClosingEvent));
    await streamQueue.cancel();
  });

  test(
      'onCameraError stream emits errors caught by system services or added to stream within plugin',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 27;
    const String firstTestErrorDescription = 'Test error description 1!';
    const String secondTestErrorDescription = 'Test error description 2!';
    const CameraErrorEvent secondCameraErrorEvent =
        CameraErrorEvent(cameraId, secondTestErrorDescription);
    final Stream<CameraErrorEvent> eventStream = camera.onCameraError(cameraId);
    final StreamQueue<CameraErrorEvent> streamQueue =
        StreamQueue<CameraErrorEvent>(eventStream);

    SystemServices.cameraErrorStreamController.add(firstTestErrorDescription);
    expect(await streamQueue.next,
        equals(const CameraErrorEvent(cameraId, firstTestErrorDescription)));

    camera.cameraEventStreamController.add(secondCameraErrorEvent);
    expect(await streamQueue.next, equals(secondCameraErrorEvent));

    await streamQueue.cancel();
  });

  test(
      'onDeviceOrientationChanged stream emits changes in device oreintation detected by system services',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final Stream<DeviceOrientationChangedEvent> eventStream =
        camera.onDeviceOrientationChanged();
    final StreamQueue<DeviceOrientationChangedEvent> streamQueue =
        StreamQueue<DeviceOrientationChangedEvent>(eventStream);
    const DeviceOrientationChangedEvent testEvent =
        DeviceOrientationChangedEvent(DeviceOrientation.portraitDown);

    SystemServices.deviceOrientationChangedStreamController.add(testEvent);

    expect(await streamQueue.next, testEvent);
    await streamQueue.cancel();
  });

  test(
      'pausePreview unbinds preview from lifecycle when preview is nonnull and has been bound to lifecycle',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();

    // Set directly for test versus calling createCamera.
    camera.processCameraProvider = MockProcessCameraProvider();
    camera.preview = MockPreview();

    when(camera.processCameraProvider!.isBound(camera.preview!))
        .thenAnswer((_) async => true);

    await camera.pausePreview(579);

    verify(camera.processCameraProvider!.unbind(<UseCase>[camera.preview!]));
  });

  test(
      'pausePreview does not unbind preview from lifecycle when preview has not been bound to lifecycle',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();

    // Set directly for test versus calling createCamera.
    camera.processCameraProvider = MockProcessCameraProvider();
    camera.preview = MockPreview();

    await camera.pausePreview(632);

    verifyNever(
        camera.processCameraProvider!.unbind(<UseCase>[camera.preview!]));
  });

  test(
      'resumePreview does not bind preview to lifecycle or update camera state observers if already bound',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();
    final MockCamera mockCamera = MockCamera();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final MockLiveCameraState mockLiveCameraState = MockLiveCameraState();

    // Set directly for test versus calling createCamera.
    camera.processCameraProvider = mockProcessCameraProvider;
    camera.cameraSelector = MockCameraSelector();
    camera.preview = MockPreview();

    when(camera.processCameraProvider!.isBound(camera.preview!))
        .thenAnswer((_) async => true);

    when(mockProcessCameraProvider
            .bindToLifecycle(camera.cameraSelector, <UseCase>[camera.preview!]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => mockLiveCameraState);

    await camera.resumePreview(78);

    verifyNever(camera.processCameraProvider!
        .bindToLifecycle(camera.cameraSelector!, <UseCase>[camera.preview!]));
    verifyNever(mockLiveCameraState.observe(any));
    expect(camera.cameraInfo, isNot(mockCameraInfo));
  });

  test(
      'resumePreview binds preview to lifecycle and updates camera state observers if not already bound',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();
    final MockCamera mockCamera = MockCamera();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final MockLiveCameraState mockLiveCameraState = MockLiveCameraState();

    // Set directly for test versus calling createCamera.
    camera.processCameraProvider = mockProcessCameraProvider;
    camera.cameraSelector = MockCameraSelector();
    camera.preview = MockPreview();

    // Tell plugin to create a detached Observer<CameraState>, that is created to
    // track camera state once preview is bound to the lifecycle and needed to
    // test for expected updates.
    camera.proxy = CameraXProxy(
        createCameraStateObserver:
            (void Function(Object stateAsObject) onChanged) =>
                Observer<CameraState>.detached(onChanged: onChanged));

    when(mockProcessCameraProvider
            .bindToLifecycle(camera.cameraSelector, <UseCase>[camera.preview!]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => mockLiveCameraState);

    await camera.resumePreview(78);

    verify(camera.processCameraProvider!
        .bindToLifecycle(camera.cameraSelector!, <UseCase>[camera.preview!]));
    expect(
        await testCameraClosingObserver(
            camera,
            78,
            verify(mockLiveCameraState.observe(captureAny)).captured.single
                as Observer<dynamic>),
        isTrue);
    expect(camera.cameraInfo, equals(mockCameraInfo));
  });

  test(
      'buildPreview returns a FutureBuilder that does not return a Texture until the preview is bound to the lifecycle',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();
    final MockCamera mockCamera = MockCamera();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    const int textureId = 75;

    // Set directly for test versus calling createCamera.
    camera.processCameraProvider = mockProcessCameraProvider;
    camera.cameraSelector = MockCameraSelector();
    camera.preview = MockPreview();

    // Tell plugin to create a mock Observer<CameraState>, that is created to
    // track camera state once preview is bound to the lifecycle.
    camera.proxy =
        CameraXProxy(createCameraStateObserver: (_) => MockObserver());

    when(mockProcessCameraProvider
            .bindToLifecycle(camera.cameraSelector, <UseCase>[camera.preview!]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());

    final FutureBuilder<void> previewWidget =
        camera.buildPreview(textureId) as FutureBuilder<void>;

    expect(
        previewWidget.builder(
            MockBuildContext(), const AsyncSnapshot<void>.nothing()),
        isA<SizedBox>());
    expect(
        previewWidget.builder(
            MockBuildContext(), const AsyncSnapshot<void>.waiting()),
        isA<SizedBox>());
    expect(
        previewWidget.builder(MockBuildContext(),
            const AsyncSnapshot<void>.withData(ConnectionState.active, null)),
        isA<SizedBox>());
  });

  test(
      'buildPreview returns a FutureBuilder that returns a Texture once the preview is bound to the lifecycle',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();
    final MockCamera mockCamera = MockCamera();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    const int textureId = 75;

    // Set directly for test versus calling createCamera.
    camera.processCameraProvider = mockProcessCameraProvider;
    camera.cameraSelector = MockCameraSelector();
    camera.preview = MockPreview();

    // Tell plugin to create a mock Observer<CameraState>, that is created to
    // track camera state once preview is bound to the lifecycle.
    camera.proxy =
        CameraXProxy(createCameraStateObserver: (_) => MockObserver());

    when(mockProcessCameraProvider
            .bindToLifecycle(camera.cameraSelector, <UseCase>[camera.preview!]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());

    final FutureBuilder<void> previewWidget =
        camera.buildPreview(textureId) as FutureBuilder<void>;

    final Texture previewTexture = previewWidget.builder(MockBuildContext(),
            const AsyncSnapshot<void>.withData(ConnectionState.done, null))
        as Texture;
    expect(previewTexture.textureId, equals(textureId));
  });

  group('video recording', () {
    test(
        'startVideoCapturing binds video capture use case and starts the recording',
        () async {
      // Set up mocks and constants.
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      final MockPendingRecording mockPendingRecording = MockPendingRecording();
      final MockRecording mockRecording = MockRecording();
      final TestSystemServicesHostApi mockSystemServicesApi =
          MockTestSystemServicesHostApi();
      TestSystemServicesHostApi.setup(mockSystemServicesApi);

      // Set directly for test versus calling createCamera.
      camera.processCameraProvider = MockProcessCameraProvider();
      camera.camera = MockCamera();
      camera.recorder = MockRecorder();
      camera.videoCapture = MockVideoCapture();
      camera.cameraSelector = MockCameraSelector();

      const int cameraId = 17;
      const String outputPath = '/temp/MOV123.temp';

      // Mock method calls.
      when(mockSystemServicesApi.getTempFilePath(camera.videoPrefix, '.temp'))
          .thenReturn(outputPath);
      when(camera.recorder!.prepareRecording(outputPath))
          .thenAnswer((_) async => mockPendingRecording);
      when(mockPendingRecording.start()).thenAnswer((_) async => mockRecording);
      when(camera.processCameraProvider!.isBound(camera.videoCapture!))
          .thenAnswer((_) async => false);
      when(camera.processCameraProvider!.bindToLifecycle(
              camera.cameraSelector!, <UseCase>[camera.videoCapture!]))
          .thenAnswer((_) async => camera.camera!);

      await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));

      verify(camera.processCameraProvider!.bindToLifecycle(
          camera.cameraSelector!, <UseCase>[camera.videoCapture!]));
      expect(camera.pendingRecording, equals(mockPendingRecording));
      expect(camera.recording, mockRecording);
    });

    test(
        'startVideoCapturing binds video capture use case and starts the recording'
        ' on first call, and does nothing on second call', () async {
      // Set up mocks and constants.
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      final MockPendingRecording mockPendingRecording = MockPendingRecording();
      final MockRecording mockRecording = MockRecording();
      final TestSystemServicesHostApi mockSystemServicesApi =
          MockTestSystemServicesHostApi();
      TestSystemServicesHostApi.setup(mockSystemServicesApi);

      // Set directly for test versus calling createCamera.
      camera.processCameraProvider = MockProcessCameraProvider();
      camera.recorder = MockRecorder();
      camera.videoCapture = MockVideoCapture();
      camera.cameraSelector = MockCameraSelector();

      const int cameraId = 17;
      const String outputPath = '/temp/MOV123.temp';

      // Mock method calls.
      when(mockSystemServicesApi.getTempFilePath(camera.videoPrefix, '.temp'))
          .thenReturn(outputPath);
      when(camera.recorder!.prepareRecording(outputPath))
          .thenAnswer((_) async => mockPendingRecording);
      when(mockPendingRecording.start()).thenAnswer((_) async => mockRecording);
      when(camera.processCameraProvider!.isBound(camera.videoCapture!))
          .thenAnswer((_) async => false);
      when(camera.processCameraProvider!.bindToLifecycle(
              camera.cameraSelector!, <UseCase>[camera.videoCapture!]))
          .thenAnswer((_) async => MockCamera());

      await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));

      verify(camera.processCameraProvider!.bindToLifecycle(
          camera.cameraSelector!, <UseCase>[camera.videoCapture!]));
      expect(camera.pendingRecording, equals(mockPendingRecording));
      expect(camera.recording, mockRecording);

      await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));
      // Verify that each of these calls happened only once.
      verify(mockSystemServicesApi.getTempFilePath(camera.videoPrefix, '.temp'))
          .called(1);
      verifyNoMoreInteractions(mockSystemServicesApi);
      verify(camera.recorder!.prepareRecording(outputPath)).called(1);
      verifyNoMoreInteractions(camera.recorder);
      verify(mockPendingRecording.start()).called(1);
      verifyNoMoreInteractions(mockPendingRecording);
    });

    test(
        'startVideoCapturing called with stream options starts image streaming',
        () async {
      // Set up mocks and constants.
      final AndroidCameraCameraX camera = AndroidCameraCameraX();

      // Set directly for test versus calling createCamera.
      final MockProcessCameraProvider mockProcessCameraProvider =
          MockProcessCameraProvider();
      camera.processCameraProvider = mockProcessCameraProvider;
      camera.cameraSelector = MockCameraSelector();
      camera.videoCapture = MockVideoCapture();
      camera.imageAnalysis = MockImageAnalysis();
      camera.camera = MockCamera();
      final Recorder mockRecorder = MockRecorder();
      camera.recorder = mockRecorder;
      final MockPendingRecording mockPendingRecording = MockPendingRecording();
      final TestSystemServicesHostApi mockSystemServicesApi =
          MockTestSystemServicesHostApi();
      TestSystemServicesHostApi.setup(mockSystemServicesApi);

      // Tell plugin to create detached Analyzer for testing.
      camera.proxy = CameraXProxy(
          createAnalyzer:
              (Future<void> Function(ImageProxy imageProxy) analyze) =>
                  Analyzer.detached(analyze: analyze));

      const int cameraId = 17;
      const String outputPath = '/temp/MOV123.temp';
      final Completer<CameraImageData> imageDataCompleter =
          Completer<CameraImageData>();
      final VideoCaptureOptions videoCaptureOptions = VideoCaptureOptions(
          cameraId,
          streamCallback: (CameraImageData imageData) =>
              imageDataCompleter.complete(imageData));

      // Mock method calls.
      when(camera.processCameraProvider!.isBound(camera.videoCapture!))
          .thenAnswer((_) async => true);
      when(mockSystemServicesApi.getTempFilePath(camera.videoPrefix, '.temp'))
          .thenReturn(outputPath);
      when(camera.recorder!.prepareRecording(outputPath))
          .thenAnswer((_) async => mockPendingRecording);
      when(mockProcessCameraProvider.bindToLifecycle(any, any))
          .thenAnswer((_) => Future<Camera>.value(camera.camera));
      when(camera.camera!.getCameraInfo())
          .thenAnswer((_) => Future<CameraInfo>.value(MockCameraInfo()));

      await camera.startVideoCapturing(videoCaptureOptions);

      final CameraImageData mockCameraImageData = MockCameraImageData();
      camera.cameraImageDataStreamController!.add(mockCameraImageData);

      expect(imageDataCompleter.future, isNotNull);
      await camera.cameraImageDataStreamController!.close();
    });

    test('pauseVideoRecording pauses the recording', () async {
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      final MockRecording recording = MockRecording();

      // Set directly for test versus calling startVideoCapturing.
      camera.recording = recording;

      await camera.pauseVideoRecording(0);
      verify(recording.pause());
      verifyNoMoreInteractions(recording);
    });

    test('resumeVideoRecording resumes the recording', () async {
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      final MockRecording recording = MockRecording();

      // Set directly for test versus calling startVideoCapturing.
      camera.recording = recording;

      await camera.resumeVideoRecording(0);
      verify(recording.resume());
      verifyNoMoreInteractions(recording);
    });

    test('stopVideoRecording stops the recording', () async {
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      final MockRecording recording = MockRecording();
      final MockProcessCameraProvider processCameraProvider =
          MockProcessCameraProvider();
      final MockVideoCapture videoCapture = MockVideoCapture();
      const String videoOutputPath = '/test/output/path';

      // Set directly for test versus calling createCamera and startVideoCapturing.
      camera.processCameraProvider = processCameraProvider;
      camera.recording = recording;
      camera.videoCapture = videoCapture;
      camera.videoOutputPath = videoOutputPath;

      final XFile file = await camera.stopVideoRecording(0);
      expect(file.path, videoOutputPath);

      verify(recording.close());
      verifyNoMoreInteractions(recording);
    });

    test(
        'stopVideoRecording throws a camera exception if '
        'no recording is in progress', () async {
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const String videoOutputPath = '/test/output/path';

      // Set directly for test versus calling startVideoCapturing.
      camera.recording = null;
      camera.videoOutputPath = videoOutputPath;

      expect(
          () => camera.stopVideoRecording(0), throwsA(isA<CameraException>()));
    });

    test(
        'stopVideoRecording throws a camera exception if '
        'videoOutputPath is null, and sets recording to null', () async {
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      final MockRecording recording = MockRecording();

      // Set directly for test versus calling startVideoCapturing.
      camera.recording = recording;
      camera.videoOutputPath = null;

      expect(
          () => camera.stopVideoRecording(0), throwsA(isA<CameraException>()));
      expect(camera.recording, null);
    });

    test(
        'calling stopVideoRecording twice stops the recording '
        'and then throws a CameraException', () async {
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      final MockRecording recording = MockRecording();
      final MockProcessCameraProvider processCameraProvider =
          MockProcessCameraProvider();
      final MockVideoCapture videoCapture = MockVideoCapture();
      const String videoOutputPath = '/test/output/path';

      // Set directly for test versus calling createCamera and startVideoCapturing.
      camera.processCameraProvider = processCameraProvider;
      camera.recording = recording;
      camera.videoCapture = videoCapture;
      camera.videoOutputPath = videoOutputPath;

      final XFile file = await camera.stopVideoRecording(0);
      expect(file.path, videoOutputPath);

      expect(
          () => camera.stopVideoRecording(0), throwsA(isA<CameraException>()));
    });
  });

  test(
      'takePicture binds and unbinds ImageCapture to lifecycle and makes call to take a picture',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const String testPicturePath = 'test/absolute/path/to/picture';

    // Set directly for test versus calling createCamera.
    camera.imageCapture = MockImageCapture();

    when(camera.imageCapture!.takePicture())
        .thenAnswer((_) async => testPicturePath);

    final XFile imageFile = await camera.takePicture(3);

    expect(imageFile.path, equals(testPicturePath));
  });

  test('takePicture turns non-torch flash mode off when torch mode enabled',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 77;
    final MockCameraControl mockCameraControl = MockCameraControl();

    // Set directly for test versus calling createCamera.
    camera.imageCapture = MockImageCapture();
    camera.camera = MockCamera();

    when(camera.camera!.getCameraControl())
        .thenAnswer((_) async => mockCameraControl);

    await camera.setFlashMode(cameraId, FlashMode.torch);
    await camera.takePicture(cameraId);
    verify(camera.imageCapture!.setFlashMode(ImageCapture.flashModeOff));
  });

  test(
      'setFlashMode configures ImageCapture with expected non-torch flash mode',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 22;
    final MockCameraControl mockCameraControl = MockCameraControl();

    // Set directly for test versus calling createCamera.
    camera.imageCapture = MockImageCapture();
    camera.camera = MockCamera();

    when(camera.camera!.getCameraControl())
        .thenAnswer((_) async => mockCameraControl);

    for (final FlashMode flashMode in FlashMode.values) {
      await camera.setFlashMode(cameraId, flashMode);

      int? expectedFlashMode;
      switch (flashMode) {
        case FlashMode.off:
          expectedFlashMode = ImageCapture.flashModeOff;
          break;
        case FlashMode.auto:
          expectedFlashMode = ImageCapture.flashModeAuto;
          break;
        case FlashMode.always:
          expectedFlashMode = ImageCapture.flashModeOn;
          break;
        case FlashMode.torch:
          expectedFlashMode = null;
          break;
      }

      if (expectedFlashMode == null) {
        // Torch mode enabled and won't be used for configuring image capture.
        continue;
      }

      verifyNever(mockCameraControl.enableTorch(true));
      expect(camera.torchEnabled, isFalse);
      await camera.takePicture(cameraId);
      verify(camera.imageCapture!.setFlashMode(expectedFlashMode));
    }
  });

  test('setFlashMode turns on torch mode as expected', () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 44;
    final MockCameraControl mockCameraControl = MockCameraControl();

    // Set directly for test versus calling createCamera.
    camera.camera = MockCamera();

    when(camera.camera!.getCameraControl())
        .thenAnswer((_) async => mockCameraControl);

    await camera.setFlashMode(cameraId, FlashMode.torch);

    verify(mockCameraControl.enableTorch(true));
    expect(camera.torchEnabled, isTrue);
  });

  test('setFlashMode turns off torch mode when non-torch flash modes set',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 33;
    final MockCameraControl mockCameraControl = MockCameraControl();

    // Set directly for test versus calling createCamera.
    camera.camera = MockCamera();

    when(camera.camera!.getCameraControl())
        .thenAnswer((_) async => mockCameraControl);

    for (final FlashMode flashMode in FlashMode.values) {
      camera.torchEnabled = true;
      await camera.setFlashMode(cameraId, flashMode);

      switch (flashMode) {
        case FlashMode.off:
        case FlashMode.auto:
        case FlashMode.always:
          verify(mockCameraControl.enableTorch(false));
          expect(camera.torchEnabled, isFalse);
          break;
        case FlashMode.torch:
          verifyNever(mockCameraControl.enableTorch(true));
          expect(camera.torchEnabled, true);
          break;
      }
    }
  });

  test('getMinExposureOffset returns expected exposure offset', () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final ExposureState exposureState = ExposureState.detached(
        exposureCompensationRange:
            ExposureCompensationRange(minCompensation: 3, maxCompensation: 4),
        exposureCompensationStep: 0.2);

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = mockCameraInfo;

    when(mockCameraInfo.getExposureState())
        .thenAnswer((_) async => exposureState);

    // We expect the minimum exposure to be the minimum exposure compensation * exposure compensation step.
    // Delta is included due to avoid catching rounding errors.
    expect(await camera.getMinExposureOffset(35), closeTo(0.6, 0.0000000001));
  });

  test('getMaxExposureOffset returns expected exposure offset', () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final ExposureState exposureState = ExposureState.detached(
        exposureCompensationRange:
            ExposureCompensationRange(minCompensation: 3, maxCompensation: 4),
        exposureCompensationStep: 0.2);

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = mockCameraInfo;

    when(mockCameraInfo.getExposureState())
        .thenAnswer((_) async => exposureState);

    // We expect the maximum exposure to be the maximum exposure compensation * exposure compensation step.
    expect(await camera.getMaxExposureOffset(35), 0.8);
  });

  test('getExposureOffsetStepSize returns expected exposure offset', () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final ExposureState exposureState = ExposureState.detached(
        exposureCompensationRange:
            ExposureCompensationRange(minCompensation: 3, maxCompensation: 4),
        exposureCompensationStep: 0.2);

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = mockCameraInfo;

    when(mockCameraInfo.getExposureState())
        .thenAnswer((_) async => exposureState);

    expect(await camera.getExposureOffsetStepSize(55), 0.2);
  });

  test('getMaxZoomLevel returns expected exposure offset', () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    const double maxZoomRatio = 1;
    final LiveData<ZoomState> mockLiveZoomState = MockLiveZoomState();
    final ZoomState zoomState =
        ZoomState.detached(maxZoomRatio: maxZoomRatio, minZoomRatio: 0);

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = mockCameraInfo;

    when(mockCameraInfo.getZoomState())
        .thenAnswer((_) async => mockLiveZoomState);
    when(mockLiveZoomState.getValue()).thenAnswer((_) async => zoomState);

    expect(await camera.getMaxZoomLevel(55), maxZoomRatio);
  });

  test('getMinZoomLevel returns expected exposure offset', () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    const double minZoomRatio = 0;
    final LiveData<ZoomState> mockLiveZoomState = MockLiveZoomState();
    final ZoomState zoomState =
        ZoomState.detached(maxZoomRatio: 1, minZoomRatio: minZoomRatio);

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = mockCameraInfo;

    when(mockCameraInfo.getZoomState())
        .thenAnswer((_) async => mockLiveZoomState);
    when(mockLiveZoomState.getValue()).thenAnswer((_) async => zoomState);

    expect(await camera.getMinZoomLevel(55), minZoomRatio);
  });

  test('setZoomLevel sets zoom ratio as expected', () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 44;
    const double zoomRatio = 0.3;
    final MockCameraControl mockCameraControl = MockCameraControl();

    // Set directly for test versus calling createCamera.
    camera.camera = MockCamera();

    when(camera.camera!.getCameraControl())
        .thenAnswer((_) async => mockCameraControl);

    await camera.setZoomLevel(cameraId, zoomRatio);

    verify(mockCameraControl.setZoomRatio(zoomRatio));
  });

  test(
      'onStreamedFrameAvailable emits CameraImageData when picked up from CameraImageData stream controller',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();
    final MockCamera mockCamera = MockCamera();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    const int cameraId = 22;

    // Tell plugin to create detached Analyzer for testing.
    camera.proxy = CameraXProxy(
        createAnalyzer:
            (Future<void> Function(ImageProxy imageProxy) analyze) =>
                Analyzer.detached(analyze: analyze));

    // Set directly for test versus calling createCamera.
    camera.processCameraProvider = mockProcessCameraProvider;
    camera.cameraSelector = MockCameraSelector();
    camera.imageAnalysis = MockImageAnalysis();

    when(mockProcessCameraProvider.bindToLifecycle(any, any))
        .thenAnswer((_) => Future<Camera>.value(mockCamera));
    when(mockCamera.getCameraInfo())
        .thenAnswer((_) => Future<CameraInfo>.value(mockCameraInfo));
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());

    final CameraImageData mockCameraImageData = MockCameraImageData();
    final Stream<CameraImageData> imageStream =
        camera.onStreamedFrameAvailable(cameraId);
    final StreamQueue<CameraImageData> streamQueue =
        StreamQueue<CameraImageData>(imageStream);

    camera.cameraImageDataStreamController!.add(mockCameraImageData);

    expect(await streamQueue.next, equals(mockCameraImageData));
    await streamQueue.cancel();
  });

  test(
      'onStreamedFrameAvailable emits CameraImageData when listened to after cancelation',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();
    final MockCamera mockCamera = MockCamera();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    const int cameraId = 22;

    // Tell plugin to create detached Analyzer for testing.
    camera.proxy = CameraXProxy(
        createAnalyzer:
            (Future<void> Function(ImageProxy imageProxy) analyze) =>
                Analyzer.detached(analyze: analyze));

    // Set directly for test versus calling createCamera.
    camera.processCameraProvider = mockProcessCameraProvider;
    camera.cameraSelector = MockCameraSelector();
    camera.imageAnalysis = MockImageAnalysis();

    when(mockProcessCameraProvider.bindToLifecycle(any, any))
        .thenAnswer((_) => Future<Camera>.value(mockCamera));
    when(mockCamera.getCameraInfo())
        .thenAnswer((_) => Future<CameraInfo>.value(mockCameraInfo));
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());

    final CameraImageData mockCameraImageData = MockCameraImageData();
    final Stream<CameraImageData> imageStream =
        camera.onStreamedFrameAvailable(cameraId);

    // Listen to image stream.
    final StreamSubscription<CameraImageData> imageStreamSubscription =
        imageStream.listen((CameraImageData data) {});

    // Cancel subscription to image stream.
    await imageStreamSubscription.cancel();
    final Stream<CameraImageData> imageStream2 =
        camera.onStreamedFrameAvailable(cameraId);

    // Listen to image stream again.
    final StreamQueue<CameraImageData> streamQueue =
        StreamQueue<CameraImageData>(imageStream2);
    camera.cameraImageDataStreamController!.add(mockCameraImageData);

    expect(await streamQueue.next, equals(mockCameraImageData));
    await streamQueue.cancel();
  });

  test(
      'onStreamedFrameAvailable returns stream that responds expectedly to being listened to',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 33;
    final ProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();
    final CameraSelector mockCameraSelector = MockCameraSelector();
    final MockImageAnalysis mockImageAnalysis = MockImageAnalysis();
    final Camera mockCamera = MockCamera();
    final CameraInfo mockCameraInfo = MockCameraInfo();
    final MockImageProxy mockImageProxy = MockImageProxy();
    final MockPlaneProxy mockPlane = MockPlaneProxy();
    final List<MockPlaneProxy> mockPlanes = <MockPlaneProxy>[mockPlane];
    final Uint8List buffer = Uint8List(0);
    const int pixelStride = 27;
    const int rowStride = 58;
    const int imageFormat = 582;
    const int imageHeight = 100;
    const int imageWidth = 200;

    // Tell plugin to create detached Analyzer for testing.
    camera.proxy = CameraXProxy(
        createAnalyzer:
            (Future<void> Function(ImageProxy imageProxy) analyze) =>
                Analyzer.detached(analyze: analyze));

    // Set directly for test versus calling createCamera.
    camera.processCameraProvider = mockProcessCameraProvider;
    camera.cameraSelector = mockCameraSelector;
    camera.imageAnalysis = mockImageAnalysis;

    when(mockProcessCameraProvider.isBound(mockImageAnalysis))
        .thenAnswer((_) async => Future<bool>.value(false));
    when(mockProcessCameraProvider
            .bindToLifecycle(mockCameraSelector, <UseCase>[mockImageAnalysis]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());
    when(mockImageProxy.getPlanes())
        .thenAnswer((_) => Future<List<PlaneProxy>>.value(mockPlanes));
    when(mockPlane.buffer).thenReturn(buffer);
    when(mockPlane.rowStride).thenReturn(rowStride);
    when(mockPlane.pixelStride).thenReturn(pixelStride);
    when(mockImageProxy.format).thenReturn(imageFormat);
    when(mockImageProxy.height).thenReturn(imageHeight);
    when(mockImageProxy.width).thenReturn(imageWidth);

    final Completer<CameraImageData> imageDataCompleter =
        Completer<CameraImageData>();
    final StreamSubscription<CameraImageData>
        onStreamedFrameAvailableSubscription = camera
            .onStreamedFrameAvailable(cameraId)
            .listen((CameraImageData imageData) {
      imageDataCompleter.complete(imageData);
    });

    // Test ImageAnalysis use case is bound to ProcessCameraProvider.
    final Analyzer capturedAnalyzer =
        verify(mockImageAnalysis.setAnalyzer(captureAny)).captured.single
            as Analyzer;

    await capturedAnalyzer.analyze(mockImageProxy);
    final CameraImageData imageData = await imageDataCompleter.future;

    // Test Analyzer correctly process ImageProxy instances.
    expect(imageData.planes.length, equals(1));
    expect(imageData.planes[0].bytes, equals(buffer));
    expect(imageData.planes[0].bytesPerRow, equals(rowStride));
    expect(imageData.planes[0].bytesPerPixel, equals(pixelStride));
    expect(imageData.format.raw, equals(imageFormat));
    expect(imageData.height, equals(imageHeight));
    expect(imageData.width, equals(imageWidth));

    await onStreamedFrameAvailableSubscription.cancel();
  });

  test(
      'onStreamedFrameAvailable returns stream that responds expectedly to being canceled',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 32;
    final MockImageAnalysis mockImageAnalysis = MockImageAnalysis();

    // Set directly for test versus calling createCamera.
    camera.imageAnalysis = mockImageAnalysis;

    final StreamSubscription<CameraImageData> imageStreamSubscription = camera
        .onStreamedFrameAvailable(cameraId)
        .listen((CameraImageData data) {});

    await imageStreamSubscription.cancel();

    verify(mockImageAnalysis.clearAnalyzer());
  });
}
