// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' show Point;

import 'package:async/async.dart';
import 'package:camera_android_camerax/camera_android_camerax.dart';
import 'package:camera_android_camerax/src/analyzer.dart';
import 'package:camera_android_camerax/src/aspect_ratio_strategy.dart';
import 'package:camera_android_camerax/src/camera.dart';
import 'package:camera_android_camerax/src/camera2_camera_control.dart';
import 'package:camera_android_camerax/src/camera2_camera_info.dart';
import 'package:camera_android_camerax/src/camera_control.dart';
import 'package:camera_android_camerax/src/camera_info.dart';
import 'package:camera_android_camerax/src/camera_metadata.dart';
import 'package:camera_android_camerax/src/camera_selector.dart';
import 'package:camera_android_camerax/src/camera_state.dart';
import 'package:camera_android_camerax/src/camera_state_error.dart';
import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/camerax_proxy.dart';
import 'package:camera_android_camerax/src/capture_request_options.dart';
import 'package:camera_android_camerax/src/device_orientation_manager.dart';
import 'package:camera_android_camerax/src/exposure_state.dart';
import 'package:camera_android_camerax/src/fallback_strategy.dart';
import 'package:camera_android_camerax/src/focus_metering_action.dart';
import 'package:camera_android_camerax/src/focus_metering_result.dart';
import 'package:camera_android_camerax/src/image_analysis.dart';
import 'package:camera_android_camerax/src/image_capture.dart';
import 'package:camera_android_camerax/src/image_proxy.dart';
import 'package:camera_android_camerax/src/live_data.dart';
import 'package:camera_android_camerax/src/metering_point.dart';
import 'package:camera_android_camerax/src/observer.dart';
import 'package:camera_android_camerax/src/pending_recording.dart';
import 'package:camera_android_camerax/src/plane_proxy.dart';
import 'package:camera_android_camerax/src/preview.dart';
import 'package:camera_android_camerax/src/process_camera_provider.dart';
import 'package:camera_android_camerax/src/quality_selector.dart';
import 'package:camera_android_camerax/src/recorder.dart';
import 'package:camera_android_camerax/src/recording.dart';
import 'package:camera_android_camerax/src/resolution_filter.dart';
import 'package:camera_android_camerax/src/resolution_selector.dart';
import 'package:camera_android_camerax/src/resolution_strategy.dart';
import 'package:camera_android_camerax/src/surface.dart';
import 'package:camera_android_camerax/src/system_services.dart';
import 'package:camera_android_camerax/src/use_case.dart';
import 'package:camera_android_camerax/src/video_capture.dart';
import 'package:camera_android_camerax/src/zoom_state.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart'
    show DeviceOrientation, PlatformException, Uint8List;
import 'package:flutter/widgets.dart' show BuildContext, Size, Texture, Widget;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'android_camera_camerax_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<Analyzer>(),
  MockSpec<AspectRatioStrategy>(),
  MockSpec<BuildContext>(),
  MockSpec<Camera>(),
  MockSpec<CameraInfo>(),
  MockSpec<CameraControl>(),
  MockSpec<Camera2CameraControl>(),
  MockSpec<Camera2CameraInfo>(),
  MockSpec<CameraImageData>(),
  MockSpec<CameraSelector>(),
  MockSpec<ExposureState>(),
  MockSpec<FallbackStrategy>(),
  MockSpec<FocusMeteringResult>(),
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
  MockSpec<ResolutionFilter>(),
  MockSpec<ResolutionSelector>(),
  MockSpec<ResolutionStrategy>(),
  MockSpec<Recording>(),
  MockSpec<TestInstanceManagerHostApi>(),
  MockSpec<TestSystemServicesHostApi>(),
  MockSpec<VideoCapture>(),
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

  /// CameraXProxy for testing functionality related to the camera resolution
  /// preset (setting expected ResolutionSelectors, QualitySelectors, etc.).
  CameraXProxy getProxyForTestingResolutionPreset(
          MockProcessCameraProvider mockProcessCameraProvider) =>
      CameraXProxy(
        getProcessCameraProvider: () =>
            Future<ProcessCameraProvider>.value(mockProcessCameraProvider),
        createCameraSelector: (int cameraSelectorLensDirection) =>
            MockCameraSelector(),
        createPreview:
            (ResolutionSelector? resolutionSelector, int? targetRotation) =>
                Preview.detached(
                    initialTargetRotation: targetRotation,
                    resolutionSelector: resolutionSelector),
        createImageCapture:
            (ResolutionSelector? resolutionSelector, int? targetRotation) =>
                ImageCapture.detached(
                    resolutionSelector: resolutionSelector,
                    initialTargetRotation: targetRotation),
        createRecorder: (QualitySelector? qualitySelector) =>
            Recorder.detached(qualitySelector: qualitySelector),
        createVideoCapture: (_) =>
            Future<VideoCapture>.value(MockVideoCapture()),
        createImageAnalysis:
            (ResolutionSelector? resolutionSelector, int? targetRotation) =>
                ImageAnalysis.detached(
                    resolutionSelector: resolutionSelector,
                    initialTargetRotation: targetRotation),
        createResolutionStrategy: (
            {bool highestAvailable = false,
            Size? boundSize,
            int? fallbackRule}) {
          if (highestAvailable) {
            return ResolutionStrategy.detachedHighestAvailableStrategy();
          }
          return ResolutionStrategy.detached(
              boundSize: boundSize, fallbackRule: fallbackRule);
        },
        createResolutionSelector: (ResolutionStrategy resolutionStrategy,
                ResolutionFilter? resolutionFilter,
                AspectRatioStrategy? aspectRatioStrategy) =>
            ResolutionSelector.detached(
                resolutionStrategy: resolutionStrategy,
                resolutionFilter: resolutionFilter,
                aspectRatioStrategy: aspectRatioStrategy),
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
        createCameraStateObserver: (_) => MockObserver(),
        requestCameraPermissions: (_) => Future<void>.value(),
        startListeningForDeviceOrientationChange: (_, __) {},
        setPreviewSurfaceProvider: (_) => Future<int>.value(
            3), // 3 is a random Flutter SurfaceTexture ID for testing,
        createAspectRatioStrategy: (int aspectRatio, int fallbackRule) =>
            AspectRatioStrategy.detached(
                preferredAspectRatio: aspectRatio, fallbackRule: fallbackRule),
        createResolutionFilterWithOnePreferredSize:
            (Size preferredResolution) =>
                ResolutionFilter.onePreferredSizeDetached(
                    preferredResolution: preferredResolution),
        getCamera2CameraInfo: (_) =>
            Future<Camera2CameraInfo>.value(MockCamera2CameraInfo()),
        getUiOrientation: () =>
            Future<DeviceOrientation>.value(DeviceOrientation.portraitUp),
      );

  /// CameraXProxy for testing exposure and focus related controls.
  ///
  /// Modifies the creation of [MeteringPoint]s and [FocusMeteringAction]s to
  /// return objects detached from a native object.
  CameraXProxy getProxyForExposureAndFocus() => CameraXProxy(
        createMeteringPoint:
            (double x, double y, double? size, CameraInfo cameraInfo) =>
                MeteringPoint.detached(
                    x: x, y: y, size: size, cameraInfo: cameraInfo),
        createFocusMeteringAction:
            (List<(MeteringPoint, int?)> meteringPointInfos,
                    bool? disableAutoCancel) =>
                FocusMeteringAction.detached(
                    meteringPointInfos: meteringPointInfos,
                    disableAutoCancel: disableAutoCancel),
      );

  /// CameraXProxy for testing setting focus and exposure points.
  ///
  /// Modifies the retrieval of a [Camera2CameraControl] instance to depend on
  /// interaction with expected [cameraControl] instance and modifies creation
  /// of [CaptureRequestOptions] to return objects detached from a native object.
  CameraXProxy getProxyForSettingFocusandExposurePoints(
      CameraControl cameraControlForComparison,
      Camera2CameraControl camera2cameraControl) {
    final CameraXProxy proxy = getProxyForExposureAndFocus();

    proxy.getCamera2CameraControl = (CameraControl cameraControl) =>
        cameraControl == cameraControlForComparison
            ? camera2cameraControl
            : Camera2CameraControl.detached(cameraControl: cameraControl);

    proxy.createCaptureRequestOptions =
        (List<(CaptureRequestKeySupportedType, Object?)> options) =>
            CaptureRequestOptions.detached(requestedOptions: options);

    return proxy;
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
    final TestSystemServicesHostApi mockSystemServicesApi =
        MockTestSystemServicesHostApi();
    TestSystemServicesHostApi.setup(mockSystemServicesApi);

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
      createPreview: (_, __) => mockPreview,
      createImageCapture: (_, __) => mockImageCapture,
      createRecorder: (_) => mockRecorder,
      createVideoCapture: (_) => Future<VideoCapture>.value(mockVideoCapture),
      createImageAnalysis: (_, __) => mockImageAnalysis,
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
      createCameraStateObserver: (void Function(Object) onChanged) =>
          Observer<CameraState>.detached(onChanged: onChanged),
      requestCameraPermissions: (_) {
        cameraPermissionsRequested = true;
        return Future<void>.value();
      },
      startListeningForDeviceOrientationChange: (_, __) {
        startedListeningForDeviceOrientationChanges = true;
      },
      createAspectRatioStrategy: (_, __) => MockAspectRatioStrategy(),
      createResolutionFilterWithOnePreferredSize: (_) => MockResolutionFilter(),
      getCamera2CameraInfo: (_) =>
          Future<Camera2CameraInfo>.value(MockCamera2CameraInfo()),
      getUiOrientation: () =>
          Future<DeviceOrientation>.value(DeviceOrientation.portraitUp),
    );

    camera.processCameraProvider = mockProcessCameraProvider;

    when(mockPreview.setSurfaceProvider())
        .thenAnswer((_) async => testSurfaceTextureId);
    when(mockProcessCameraProvider.bindToLifecycle(mockBackCameraSelector,
            <UseCase>[mockPreview, mockImageCapture, mockImageAnalysis]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => mockLiveCameraState);

    expect(
        await camera.createCameraWithSettings(
          testCameraDescription,
          const MediaSettings(
            resolutionPreset: ResolutionPreset.low,
            fps: 15,
            videoBitrate: 200000,
            audioBitrate: 32000,
            enableAudio: true,
          ),
        ),
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
    final MockCameraControl mockCameraControl = MockCameraControl();
    final MockCamera2CameraInfo mockCamera2CameraInfo = MockCamera2CameraInfo();
    final TestSystemServicesHostApi mockSystemServicesApi =
        MockTestSystemServicesHostApi();
    TestSystemServicesHostApi.setup(mockSystemServicesApi);

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
      createPreview: (_, __) => mockPreview,
      createImageCapture: (_, __) => mockImageCapture,
      createRecorder: (_) => mockRecorder,
      createVideoCapture: (_) => Future<VideoCapture>.value(mockVideoCapture),
      createImageAnalysis: (_, __) => mockImageAnalysis,
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
      createCameraStateObserver: (void Function(Object) onChanged) =>
          Observer<CameraState>.detached(onChanged: onChanged),
      requestCameraPermissions: (_) => Future<void>.value(),
      startListeningForDeviceOrientationChange: (_, __) {},
      createAspectRatioStrategy: (_, __) => MockAspectRatioStrategy(),
      createResolutionFilterWithOnePreferredSize: (_) => MockResolutionFilter(),
      getCamera2CameraInfo: (CameraInfo cameraInfo) =>
          cameraInfo == mockCameraInfo
              ? Future<Camera2CameraInfo>.value(mockCamera2CameraInfo)
              : Future<Camera2CameraInfo>.value(MockCamera2CameraInfo()),
      getUiOrientation: () =>
          Future<DeviceOrientation>.value(DeviceOrientation.portraitUp),
    );

    when(mockProcessCameraProvider.bindToLifecycle(mockBackCameraSelector,
            <UseCase>[mockPreview, mockImageCapture, mockImageAnalysis]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());
    when(mockCamera.getCameraControl())
        .thenAnswer((_) async => mockCameraControl);

    camera.processCameraProvider = mockProcessCameraProvider;

    await camera.createCameraWithSettings(
        testCameraDescription,
        const MediaSettings(
          resolutionPreset: testResolutionPreset,
          fps: 15,
          videoBitrate: 2000000,
          audioBitrate: 64000,
          enableAudio: enableAudio,
        ));

    // Verify expected UseCases were bound.
    verify(camera.processCameraProvider!.bindToLifecycle(camera.cameraSelector!,
        <UseCase>[mockPreview, mockImageCapture, mockImageAnalysis]));

    // Verify the camera's CameraInfo instance got updated.
    expect(camera.cameraInfo, equals(mockCameraInfo));

    // Verify camera's CameraControl instance got updated.
    expect(camera.cameraControl, equals(mockCameraControl));

    // Verify preview has been marked as bound to the camera lifecycle by
    // createCamera.
    expect(camera.previewInitiallyBound, isTrue);
  });

  test(
      'createCamera properly sets preset resolution selection strategy for non-video capture use cases',
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
    final TestSystemServicesHostApi mockSystemServicesApi =
        MockTestSystemServicesHostApi();
    TestSystemServicesHostApi.setup(mockSystemServicesApi);

    // Tell plugin to create mock/detached objects for testing createCamera
    // as needed.
    camera.proxy =
        getProxyForTestingResolutionPreset(mockProcessCameraProvider);

    when(mockProcessCameraProvider.bindToLifecycle(any, any))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());
    camera.processCameraProvider = mockProcessCameraProvider;

    // Test non-null resolution presets.
    for (final ResolutionPreset resolutionPreset in ResolutionPreset.values) {
      await camera.createCamera(
        testCameraDescription,
        resolutionPreset,
        enableAudio: enableAudio,
      );

      Size? expectedBoundSize;
      ResolutionStrategy? expectedResolutionStrategy;
      switch (resolutionPreset) {
        case ResolutionPreset.low:
          expectedBoundSize = const Size(320, 240);
        case ResolutionPreset.medium:
          expectedBoundSize = const Size(720, 480);
        case ResolutionPreset.high:
          expectedBoundSize = const Size(1280, 720);
        case ResolutionPreset.veryHigh:
          expectedBoundSize = const Size(1920, 1080);
        case ResolutionPreset.ultraHigh:
          expectedBoundSize = const Size(3840, 2160);
        case ResolutionPreset.max:
          expectedResolutionStrategy =
              ResolutionStrategy.detachedHighestAvailableStrategy();
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
      'createCamera properly sets filter for resolution preset for non-video capture use cases',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const CameraLensDirection testLensDirection = CameraLensDirection.front;
    const int testSensorOrientation = 180;
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

    // Tell plugin to create mock/detached objects for testing createCamera
    // as needed.
    camera.proxy =
        getProxyForTestingResolutionPreset(mockProcessCameraProvider);

    when(mockProcessCameraProvider.bindToLifecycle(any, any))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());
    camera.processCameraProvider = mockProcessCameraProvider;

    // Test non-null resolution presets.
    for (final ResolutionPreset resolutionPreset in ResolutionPreset.values) {
      await camera.createCamera(testCameraDescription, resolutionPreset,
          enableAudio: enableAudio);

      Size? expectedPreferredResolution;
      switch (resolutionPreset) {
        case ResolutionPreset.low:
          expectedPreferredResolution = const Size(320, 240);
        case ResolutionPreset.medium:
          expectedPreferredResolution = const Size(720, 480);
        case ResolutionPreset.high:
          expectedPreferredResolution = const Size(1280, 720);
        case ResolutionPreset.veryHigh:
          expectedPreferredResolution = const Size(1920, 1080);
        case ResolutionPreset.ultraHigh:
          expectedPreferredResolution = const Size(3840, 2160);
        case ResolutionPreset.max:
          expectedPreferredResolution = null;
      }

      if (expectedPreferredResolution == null) {
        expect(camera.preview!.resolutionSelector!.resolutionFilter, isNull);
        expect(
            camera.imageCapture!.resolutionSelector!.resolutionFilter, isNull);
        expect(
            camera.imageAnalysis!.resolutionSelector!.resolutionFilter, isNull);
        continue;
      }

      expect(
          camera.preview!.resolutionSelector!.resolutionFilter!
              .preferredResolution,
          equals(expectedPreferredResolution));
      expect(
          camera
              .imageCapture!.resolutionSelector!.resolutionStrategy!.boundSize,
          equals(expectedPreferredResolution));
      expect(
          camera
              .imageAnalysis!.resolutionSelector!.resolutionStrategy!.boundSize,
          equals(expectedPreferredResolution));
    }

    // Test null case.
    await camera.createCamera(testCameraDescription, null);
    expect(camera.preview!.resolutionSelector, isNull);
    expect(camera.imageCapture!.resolutionSelector, isNull);
    expect(camera.imageAnalysis!.resolutionSelector, isNull);
  });

  test(
      'createCamera properly sets aspect ratio based on preset resolution for non-video capture use cases',
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

    // Tell plugin to create mock/detached objects for testing createCamera
    // as needed.
    camera.proxy =
        getProxyForTestingResolutionPreset(mockProcessCameraProvider);
    when(mockProcessCameraProvider.bindToLifecycle(any, any))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());
    camera.processCameraProvider = mockProcessCameraProvider;

    // Test non-null resolution presets.
    for (final ResolutionPreset resolutionPreset in ResolutionPreset.values) {
      await camera.createCamera(testCameraDescription, resolutionPreset,
          enableAudio: enableAudio);

      int? expectedAspectRatio;
      AspectRatioStrategy? expectedAspectRatioStrategy;
      switch (resolutionPreset) {
        case ResolutionPreset.low:
          expectedAspectRatio = AspectRatio.ratio4To3;
        case ResolutionPreset.high:
        case ResolutionPreset.veryHigh:
        case ResolutionPreset.ultraHigh:
          expectedAspectRatio = AspectRatio.ratio16To9;
        case ResolutionPreset.medium:
        // Medium resolution preset uses aspect ratio 3:2 which is unsupported
        // by CameraX.
        case ResolutionPreset.max:
          expectedAspectRatioStrategy = null;
      }

      expectedAspectRatioStrategy = expectedAspectRatio == null
          ? null
          : AspectRatioStrategy.detached(
              preferredAspectRatio: expectedAspectRatio,
              fallbackRule: AspectRatioStrategy.fallbackRuleAuto);

      if (expectedAspectRatio == null) {
        expect(camera.preview!.resolutionSelector!.aspectRatioStrategy, isNull);
        expect(camera.imageCapture!.resolutionSelector!.aspectRatioStrategy,
            isNull);
        expect(camera.imageAnalysis!.resolutionSelector!.aspectRatioStrategy,
            isNull);
        continue;
      }

      // Check aspect ratio.
      expect(
          camera.preview!.resolutionSelector!.aspectRatioStrategy!
              .preferredAspectRatio,
          equals(expectedAspectRatioStrategy!.preferredAspectRatio));
      expect(
          camera.imageCapture!.resolutionSelector!.aspectRatioStrategy!
              .preferredAspectRatio,
          equals(expectedAspectRatioStrategy.preferredAspectRatio));
      expect(
          camera.imageAnalysis!.resolutionSelector!.aspectRatioStrategy!
              .preferredAspectRatio,
          equals(expectedAspectRatioStrategy.preferredAspectRatio));

      // Check fallback rule.
      expect(
          camera.preview!.resolutionSelector!.aspectRatioStrategy!.fallbackRule,
          equals(expectedAspectRatioStrategy.fallbackRule));
      expect(
          camera.imageCapture!.resolutionSelector!.aspectRatioStrategy!
              .fallbackRule,
          equals(expectedAspectRatioStrategy.fallbackRule));
      expect(
          camera.imageAnalysis!.resolutionSelector!.aspectRatioStrategy!
              .fallbackRule,
          equals(expectedAspectRatioStrategy.fallbackRule));
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

    // Tell plugin to create mock/detached objects for testing createCamera
    // as needed.
    camera.proxy =
        getProxyForTestingResolutionPreset(mockProcessCameraProvider);

    when(mockProcessCameraProvider.bindToLifecycle(any, any))
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
        case ResolutionPreset.high:
          expectedVideoQuality = VideoQuality.HD;
        case ResolutionPreset.veryHigh:
          expectedVideoQuality = VideoQuality.FHD;
        case ResolutionPreset.ultraHigh:
          expectedVideoQuality = VideoQuality.UHD;
        case ResolutionPreset.max:
          expectedVideoQuality = VideoQuality.highest;
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

  test('createCamera sets sensor orientation as expected', () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const CameraLensDirection testLensDirection = CameraLensDirection.back;
    const int testSensorOrientation = 270;
    const CameraDescription testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation);
    const bool enableAudio = true;
    const ResolutionPreset testResolutionPreset = ResolutionPreset.veryHigh;
    const DeviceOrientation testUiOrientation = DeviceOrientation.portraitDown;

    // Mock/Detached objects for (typically attached) objects created by
    // createCamera.
    final MockCamera mockCamera = MockCamera();
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final TestSystemServicesHostApi mockSystemServicesApi =
        MockTestSystemServicesHostApi();
    TestSystemServicesHostApi.setup(mockSystemServicesApi);

    // The proxy needed for this test is the same as testing resolution
    // presets except for mocking the retrievall of the sensor and current
    // UI orientation.
    camera.proxy =
        getProxyForTestingResolutionPreset(mockProcessCameraProvider);
    camera.proxy.getSensorOrientation =
        (_) async => Future<int>.value(testSensorOrientation);
    camera.proxy.getUiOrientation =
        () async => Future<DeviceOrientation>.value(testUiOrientation);

    when(mockProcessCameraProvider.bindToLifecycle(any, any))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());

    await camera.createCamera(testCameraDescription, testResolutionPreset,
        enableAudio: enableAudio);

    expect(camera.sensorOrientation, testSensorOrientation);
  });

  test(
      'initializeCamera throws a CameraException when createCamera has not been called before initializedCamera',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    await expectLater(() async {
      await camera.initializeCamera(3);
    }, throwsA(isA<CameraException>()));
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
    final TestSystemServicesHostApi mockSystemServicesApi =
        MockTestSystemServicesHostApi();
    TestSystemServicesHostApi.setup(mockSystemServicesApi);

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
      createPreview: (_, __) => mockPreview,
      createImageCapture: (_, __) => mockImageCapture,
      createRecorder: (QualitySelector? qualitySelector) => MockRecorder(),
      createVideoCapture: (_) => Future<VideoCapture>.value(MockVideoCapture()),
      createImageAnalysis: (_, __) => mockImageAnalysis,
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
      createCameraStateObserver: (void Function(Object) onChanged) =>
          Observer<CameraState>.detached(onChanged: onChanged),
      requestCameraPermissions: (_) => Future<void>.value(),
      startListeningForDeviceOrientationChange: (_, __) {},
      createAspectRatioStrategy: (_, __) => MockAspectRatioStrategy(),
      createResolutionFilterWithOnePreferredSize: (_) => MockResolutionFilter(),
      getCamera2CameraInfo: (_) =>
          Future<Camera2CameraInfo>.value(MockCamera2CameraInfo()),
      getUiOrientation: () =>
          Future<DeviceOrientation>.value(DeviceOrientation.portraitUp),
    );

    final CameraInitializedEvent testCameraInitializedEvent =
        CameraInitializedEvent(
            cameraId,
            resolutionWidth.toDouble(),
            resolutionHeight.toDouble(),
            ExposureMode.auto,
            true,
            FocusMode.auto,
            true);

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

    await camera.createCameraWithSettings(
      testCameraDescription,
      const MediaSettings(
        resolutionPreset: ResolutionPreset.medium,
        fps: 15,
        videoBitrate: 200000,
        audioBitrate: 32000,
        enableAudio: true,
      ),
    );

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
      'onDeviceOrientationChanged stream emits changes in device orientation detected by system services',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final Stream<DeviceOrientationChangedEvent> eventStream =
        camera.onDeviceOrientationChanged();
    final StreamQueue<DeviceOrientationChangedEvent> streamQueue =
        StreamQueue<DeviceOrientationChangedEvent>(eventStream);
    const DeviceOrientationChangedEvent testEvent =
        DeviceOrientationChangedEvent(DeviceOrientation.portraitDown);

    DeviceOrientationManager.deviceOrientationChangedStreamController
        .add(testEvent);

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
    final MockCameraControl mockCameraControl = MockCameraControl();
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
    when(mockCamera.getCameraControl())
        .thenAnswer((_) async => mockCameraControl);

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
    expect(camera.cameraControl, equals(mockCameraControl));
  });

  test(
      'buildPreview throws an exception if the preview is not bound to the lifecycle',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 73;

    // Tell camera that createCamera has not been called and thus, preview has
    // not been bound to the lifecycle of the camera.
    camera.previewInitiallyBound = false;

    expect(
        () => camera.buildPreview(cameraId), throwsA(isA<CameraException>()));
  });

  test(
      'buildPreview returns a Texture once the preview is bound to the lifecycle if it is backed by a SurfaceTexture',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 37;

    // Tell camera that createCamera has been called and thus, preview has been
    // bound to the lifecycle of the camera.
    camera.previewInitiallyBound = true;

    final Widget widget = camera.buildPreview(cameraId);

    expect(widget is Texture, isTrue);
    expect((widget as Texture).textureId, cameraId);
  });

  group('video recording', () {
    test(
        'startVideoCapturing binds video capture use case, updates saved camera instance and its properties, and starts the recording',
        () async {
      // Set up mocks and constants.
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      final MockPendingRecording mockPendingRecording = MockPendingRecording();
      final MockRecording mockRecording = MockRecording();
      final MockCamera mockCamera = MockCamera();
      final MockCamera newMockCamera = MockCamera();
      final MockCameraInfo mockCameraInfo = MockCameraInfo();
      final MockCameraControl mockCameraControl = MockCameraControl();
      final MockLiveCameraState mockLiveCameraState = MockLiveCameraState();
      final MockLiveCameraState newMockLiveCameraState = MockLiveCameraState();
      final MockCamera2CameraInfo mockCamera2CameraInfo =
          MockCamera2CameraInfo();
      final TestSystemServicesHostApi mockSystemServicesApi =
          MockTestSystemServicesHostApi();
      TestSystemServicesHostApi.setup(mockSystemServicesApi);

      // Set directly for test versus calling createCamera.
      camera.processCameraProvider = MockProcessCameraProvider();
      camera.camera = mockCamera;
      camera.recorder = MockRecorder();
      camera.videoCapture = MockVideoCapture();
      camera.cameraSelector = MockCameraSelector();
      camera.liveCameraState = mockLiveCameraState;
      camera.cameraInfo = MockCameraInfo();
      camera.imageAnalysis = MockImageAnalysis();

      // Ignore setting target rotation for this test; tested seprately.
      camera.captureOrientationLocked = true;

      // Tell plugin to create detached Observer when camera info updated.
      camera.proxy = CameraXProxy(
          createCameraStateObserver: (void Function(Object) onChanged) =>
              Observer<CameraState>.detached(onChanged: onChanged),
          getCamera2CameraInfo: (CameraInfo cameraInfo) =>
              Future<Camera2CameraInfo>.value(mockCamera2CameraInfo));

      const int cameraId = 17;
      const String outputPath = '/temp/REC123.temp';

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
          .thenAnswer((_) async => newMockCamera);
      when(newMockCamera.getCameraInfo())
          .thenAnswer((_) async => mockCameraInfo);
      when(newMockCamera.getCameraControl())
          .thenAnswer((_) async => mockCameraControl);
      when(mockCameraInfo.getCameraState())
          .thenAnswer((_) async => newMockLiveCameraState);
      when(mockCamera2CameraInfo.getSupportedHardwareLevel()).thenAnswer(
          (_) async => CameraMetadata.infoSupportedHardwareLevelLimited);

      // Simulate video recording being started so startVideoRecording completes.
      PendingRecording.videoRecordingEventStreamController
          .add(VideoRecordEvent.start);

      await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));

      // Verify VideoCapture UseCase is bound and camera & its properties
      // are updated.
      verify(camera.processCameraProvider!.bindToLifecycle(
          camera.cameraSelector!, <UseCase>[camera.videoCapture!]));
      expect(camera.camera, equals(newMockCamera));
      expect(camera.cameraInfo, equals(mockCameraInfo));
      expect(camera.cameraControl, equals(mockCameraControl));
      verify(mockLiveCameraState.removeObservers());
      expect(
          await testCameraClosingObserver(
              camera,
              cameraId,
              verify(newMockLiveCameraState.observe(captureAny)).captured.single
                  as Observer<dynamic>),
          isTrue);

      // Verify recording is started.
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
      final MockCamera mockCamera = MockCamera();
      final MockCameraInfo mockCameraInfo = MockCameraInfo();
      final MockCamera2CameraInfo mockCamera2CameraInfo =
          MockCamera2CameraInfo();
      final TestSystemServicesHostApi mockSystemServicesApi =
          MockTestSystemServicesHostApi();
      TestSystemServicesHostApi.setup(mockSystemServicesApi);

      // Set directly for test versus calling createCamera.
      camera.processCameraProvider = MockProcessCameraProvider();
      camera.recorder = MockRecorder();
      camera.videoCapture = MockVideoCapture();
      camera.cameraSelector = MockCameraSelector();
      camera.cameraInfo = MockCameraInfo();
      camera.imageAnalysis = MockImageAnalysis();

      // Ignore setting target rotation for this test; tested seprately.
      camera.captureOrientationLocked = true;

      // Tell plugin to create detached Observer when camera info updated.
      camera.proxy = CameraXProxy(
          createCameraStateObserver: (void Function(Object) onChanged) =>
              Observer<CameraState>.detached(onChanged: onChanged),
          getCamera2CameraInfo: (CameraInfo cameraInfo) =>
              Future<Camera2CameraInfo>.value(mockCamera2CameraInfo));

      const int cameraId = 17;
      const String outputPath = '/temp/REC123.temp';

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
          .thenAnswer((_) async => mockCamera);
      when(mockCamera.getCameraInfo())
          .thenAnswer((_) => Future<CameraInfo>.value(mockCameraInfo));
      when(mockCameraInfo.getCameraState())
          .thenAnswer((_) async => MockLiveCameraState());
      when(mockCamera2CameraInfo.getSupportedHardwareLevel()).thenAnswer(
          (_) async => CameraMetadata.infoSupportedHardwareLevelLimited);

      // Simulate video recording being started so startVideoRecording completes.
      PendingRecording.videoRecordingEventStreamController
          .add(VideoRecordEvent.start);

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
      final MockProcessCameraProvider mockProcessCameraProvider =
          MockProcessCameraProvider();
      final Recorder mockRecorder = MockRecorder();
      final MockPendingRecording mockPendingRecording = MockPendingRecording();
      final MockCameraInfo initialCameraInfo = MockCameraInfo();
      final MockCamera2CameraInfo mockCamera2CameraInfo =
          MockCamera2CameraInfo();
      final TestSystemServicesHostApi mockSystemServicesApi =
          MockTestSystemServicesHostApi();
      TestSystemServicesHostApi.setup(mockSystemServicesApi);

      // Set directly for test versus calling createCamera.

      camera.processCameraProvider = mockProcessCameraProvider;
      camera.cameraSelector = MockCameraSelector();
      camera.videoCapture = MockVideoCapture();
      camera.imageAnalysis = MockImageAnalysis();
      camera.camera = MockCamera();
      camera.recorder = mockRecorder;
      camera.cameraInfo = initialCameraInfo;
      camera.imageCapture = MockImageCapture();

      // Ignore setting target rotation for this test; tested seprately.
      camera.captureOrientationLocked = true;

      // Tell plugin to create detached Analyzer for testing.
      camera.proxy = CameraXProxy(
          createAnalyzer:
              (Future<void> Function(ImageProxy imageProxy) analyze) =>
                  Analyzer.detached(analyze: analyze),
          getCamera2CameraInfo: (CameraInfo cameraInfo) async =>
              cameraInfo == initialCameraInfo
                  ? mockCamera2CameraInfo
                  : MockCamera2CameraInfo());

      const int cameraId = 17;
      const String outputPath = '/temp/REC123.temp';
      final Completer<CameraImageData> imageDataCompleter =
          Completer<CameraImageData>();
      final VideoCaptureOptions videoCaptureOptions = VideoCaptureOptions(
          cameraId,
          streamCallback: (CameraImageData imageData) =>
              imageDataCompleter.complete(imageData));

      // Mock method calls.
      when(camera.processCameraProvider!.isBound(camera.videoCapture!))
          .thenAnswer((_) async => true);
      when(camera.processCameraProvider!.isBound(camera.imageAnalysis!))
          .thenAnswer((_) async => true);
      when(mockSystemServicesApi.getTempFilePath(camera.videoPrefix, '.temp'))
          .thenReturn(outputPath);
      when(camera.recorder!.prepareRecording(outputPath))
          .thenAnswer((_) async => mockPendingRecording);
      when(mockProcessCameraProvider.bindToLifecycle(any, any))
          .thenAnswer((_) => Future<Camera>.value(camera.camera));
      when(camera.camera!.getCameraInfo())
          .thenAnswer((_) => Future<CameraInfo>.value(MockCameraInfo()));
      when(mockCamera2CameraInfo.getSupportedHardwareLevel())
          .thenAnswer((_) async => CameraMetadata.infoSupportedHardwareLevel3);

      // Simulate video recording being started so startVideoRecording completes.
      PendingRecording.videoRecordingEventStreamController
          .add(VideoRecordEvent.start);

      await camera.startVideoCapturing(videoCaptureOptions);

      final CameraImageData mockCameraImageData = MockCameraImageData();
      camera.cameraImageDataStreamController!.add(mockCameraImageData);

      expect(imageDataCompleter.future, isNotNull);
      await camera.cameraImageDataStreamController!.close();
    });

    test(
        'startVideoCapturing sets VideoCapture target rotation to current video orientation if orientation unlocked',
        () async {
      // Set up mocks and constants.
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      final MockPendingRecording mockPendingRecording = MockPendingRecording();
      final MockRecording mockRecording = MockRecording();
      final MockVideoCapture mockVideoCapture = MockVideoCapture();
      final MockCameraInfo initialCameraInfo = MockCameraInfo();
      final MockCamera2CameraInfo mockCamera2CameraInfo =
          MockCamera2CameraInfo();
      final TestSystemServicesHostApi mockSystemServicesApi =
          MockTestSystemServicesHostApi();
      TestSystemServicesHostApi.setup(mockSystemServicesApi);
      const int defaultTargetRotation = Surface.rotation270;

      // Set directly for test versus calling createCamera.
      camera.processCameraProvider = MockProcessCameraProvider();
      camera.camera = MockCamera();
      camera.recorder = MockRecorder();
      camera.videoCapture = mockVideoCapture;
      camera.cameraSelector = MockCameraSelector();
      camera.imageAnalysis = MockImageAnalysis();
      camera.cameraInfo = initialCameraInfo;

      // Tell plugin to mock call to get current video orientation and mock Camera2CameraInfo retrieval.
      camera.proxy = CameraXProxy(
          getDefaultDisplayRotation: () =>
              Future<int>.value(defaultTargetRotation),
          getCamera2CameraInfo: (CameraInfo cameraInfo) async =>
              cameraInfo == initialCameraInfo
                  ? mockCamera2CameraInfo
                  : MockCamera2CameraInfo());

      const int cameraId = 87;
      const String outputPath = '/temp/REC123.temp';

      // Mock method calls.
      when(mockSystemServicesApi.getTempFilePath(camera.videoPrefix, '.temp'))
          .thenReturn(outputPath);
      when(camera.recorder!.prepareRecording(outputPath))
          .thenAnswer((_) async => mockPendingRecording);
      when(mockPendingRecording.start()).thenAnswer((_) async => mockRecording);
      when(camera.processCameraProvider!.isBound(camera.videoCapture!))
          .thenAnswer((_) async => true);
      when(camera.processCameraProvider!.isBound(camera.imageAnalysis!))
          .thenAnswer((_) async => false);

      // Simulate video recording being started so startVideoRecording completes.
      PendingRecording.videoRecordingEventStreamController
          .add(VideoRecordEvent.start);

      // Orientation is unlocked and plugin does not need to set default target
      // rotation manually.
      camera.recording = null;
      await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));
      verifyNever(mockVideoCapture.setTargetRotation(any));

      // Simulate video recording being started so startVideoRecording completes.
      PendingRecording.videoRecordingEventStreamController
          .add(VideoRecordEvent.start);

      // Orientation is locked and plugin does not need to set default target
      // rotation manually.
      camera.recording = null;
      camera.captureOrientationLocked = true;
      await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));
      verifyNever(mockVideoCapture.setTargetRotation(any));

      // Simulate video recording being started so startVideoRecording completes.
      PendingRecording.videoRecordingEventStreamController
          .add(VideoRecordEvent.start);

      // Orientation is locked and plugin does need to set default target
      // rotation manually.
      camera.recording = null;
      camera.captureOrientationLocked = true;
      camera.shouldSetDefaultRotation = true;
      await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));
      verifyNever(mockVideoCapture.setTargetRotation(any));

      // Simulate video recording being started so startVideoRecording completes.
      PendingRecording.videoRecordingEventStreamController
          .add(VideoRecordEvent.start);

      // Orientation is unlocked and plugin does need to set default target
      // rotation manually.
      camera.recording = null;
      camera.captureOrientationLocked = false;
      camera.shouldSetDefaultRotation = true;
      await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));
      verify(mockVideoCapture.setTargetRotation(defaultTargetRotation));
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

      // Tell plugin that videoCapture use case was bound to start recording.
      when(camera.processCameraProvider!.isBound(videoCapture))
          .thenAnswer((_) async => true);

      // Simulate video recording being finalized so stopVideoRecording completes.
      PendingRecording.videoRecordingEventStreamController
          .add(VideoRecordEvent.finalize);

      final XFile file = await camera.stopVideoRecording(0);
      expect(file.path, videoOutputPath);

      // Verify that recording stops.
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

      await expectLater(() async {
        await camera.stopVideoRecording(0);
      }, throwsA(isA<CameraException>()));
    });

    test(
        'stopVideoRecording throws a camera exception if '
        'videoOutputPath is null, and sets recording to null', () async {
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      final MockRecording mockRecording = MockRecording();
      final MockVideoCapture mockVideoCapture = MockVideoCapture();

      // Set directly for test versus calling startVideoCapturing.
      camera.processCameraProvider = MockProcessCameraProvider();
      camera.recording = mockRecording;
      camera.videoOutputPath = null;
      camera.videoCapture = mockVideoCapture;

      // Tell plugin that videoCapture use case was bound to start recording.
      when(camera.processCameraProvider!.isBound(mockVideoCapture))
          .thenAnswer((_) async => true);

      await expectLater(() async {
        // Simulate video recording being finalized so stopVideoRecording completes.
        PendingRecording.videoRecordingEventStreamController
            .add(VideoRecordEvent.finalize);
        await camera.stopVideoRecording(0);
      }, throwsA(isA<CameraException>()));
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

      // Simulate video recording being finalized so stopVideoRecording completes.
      PendingRecording.videoRecordingEventStreamController
          .add(VideoRecordEvent.finalize);

      final XFile file = await camera.stopVideoRecording(0);
      expect(file.path, videoOutputPath);

      await expectLater(() async {
        await camera.stopVideoRecording(0);
      }, throwsA(isA<CameraException>()));
    });

    test(
        'VideoCapture use case is unbound from lifecycle when video recording stops',
        () async {
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

      // Tell plugin that videoCapture use case was bound to start recording.
      when(camera.processCameraProvider!.isBound(videoCapture))
          .thenAnswer((_) async => true);

      // Simulate video recording being finalized so stopVideoRecording completes.
      PendingRecording.videoRecordingEventStreamController
          .add(VideoRecordEvent.finalize);

      await camera.stopVideoRecording(90);
      verify(processCameraProvider.unbind(<UseCase>[videoCapture]));

      // Verify that recording stops.
      verify(recording.close());
      verifyNoMoreInteractions(recording);
    });

    test(
        'setDescriptionWhileRecording does not make any calls involving starting video recording',
        () async {
      // TODO(camsim99): Modify test when implemented, see https://github.com/flutter/flutter/issues/148013.
      final AndroidCameraCameraX camera = AndroidCameraCameraX();

      // Set directly for test versus calling createCamera.
      camera.processCameraProvider = MockProcessCameraProvider();
      camera.recorder = MockRecorder();
      camera.videoCapture = MockVideoCapture();
      camera.camera = MockCamera();

      await camera.setDescriptionWhileRecording(const CameraDescription(
          name: 'fakeCameraName',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 90));
      verifyNoMoreInteractions(camera.processCameraProvider);
      verifyNoMoreInteractions(camera.recorder);
      verifyNoMoreInteractions(camera.videoCapture);
      verifyNoMoreInteractions(camera.camera);
    });
  });

  test(
      'takePicture binds ImageCapture to lifecycle and makes call to take a picture',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();
    final MockCamera mockCamera = MockCamera();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    const String testPicturePath = 'test/absolute/path/to/picture';

    // Set directly for test versus calling createCamera.
    camera.imageCapture = MockImageCapture();
    camera.processCameraProvider = mockProcessCameraProvider;
    camera.cameraSelector = MockCameraSelector();

    // Ignore setting target rotation for this test; tested seprately.
    camera.captureOrientationLocked = true;

    // Tell plugin to create detached camera state observers.
    camera.proxy = CameraXProxy(
        createCameraStateObserver: (void Function(Object) onChanged) =>
            Observer<CameraState>.detached(onChanged: onChanged));

    when(mockProcessCameraProvider.isBound(camera.imageCapture))
        .thenAnswer((_) async => false);
    when(mockProcessCameraProvider.bindToLifecycle(
            camera.cameraSelector, <UseCase>[camera.imageCapture!]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());
    when(camera.imageCapture!.takePicture())
        .thenAnswer((_) async => testPicturePath);

    final XFile imageFile = await camera.takePicture(3);

    expect(imageFile.path, equals(testPicturePath));
  });

  test(
      'takePicture sets ImageCapture target rotation to currrent photo rotation when orientation unlocked',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockImageCapture mockImageCapture = MockImageCapture();
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();

    const int cameraId = 3;
    const int defaultTargetRotation = Surface.rotation180;

    // Set directly for test versus calling createCamera.
    camera.imageCapture = mockImageCapture;
    camera.processCameraProvider = mockProcessCameraProvider;

    // Tell plugin to mock call to get current photo orientation.
    camera.proxy = CameraXProxy(
        getDefaultDisplayRotation: () =>
            Future<int>.value(defaultTargetRotation));

    when(mockProcessCameraProvider.isBound(camera.imageCapture))
        .thenAnswer((_) async => true);
    when(camera.imageCapture!.takePicture())
        .thenAnswer((_) async => 'test/absolute/path/to/picture');

    // Orientation is unlocked and plugin does not need to set default target
    // rotation manually.
    await camera.takePicture(cameraId);
    verifyNever(mockImageCapture.setTargetRotation(any));

    // Orientation is locked and plugin does not need to set default target
    // rotation manually.
    camera.captureOrientationLocked = true;
    await camera.takePicture(cameraId);
    verifyNever(mockImageCapture.setTargetRotation(any));

    // Orientation is locked and plugin does need to set default target
    // rotation manually.
    camera.captureOrientationLocked = true;
    camera.shouldSetDefaultRotation = true;
    await camera.takePicture(cameraId);
    verifyNever(mockImageCapture.setTargetRotation(any));

    // Orientation is unlocked and plugin does need to set default target
    // rotation manually.
    camera.captureOrientationLocked = false;
    camera.shouldSetDefaultRotation = true;
    await camera.takePicture(cameraId);
    verify(mockImageCapture.setTargetRotation(defaultTargetRotation));
  });

  test('takePicture turns non-torch flash mode off when torch mode enabled',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();
    const int cameraId = 77;

    // Set directly for test versus calling createCamera.
    camera.imageCapture = MockImageCapture();
    camera.cameraControl = MockCameraControl();
    camera.processCameraProvider = mockProcessCameraProvider;

    // Ignore setting target rotation for this test; tested seprately.
    camera.captureOrientationLocked = true;

    when(mockProcessCameraProvider.isBound(camera.imageCapture))
        .thenAnswer((_) async => true);

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
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();

    // Set directly for test versus calling createCamera.
    camera.imageCapture = MockImageCapture();
    camera.cameraControl = mockCameraControl;

    // Ignore setting target rotation for this test; tested seprately.
    camera.captureOrientationLocked = true;
    camera.processCameraProvider = mockProcessCameraProvider;

    when(mockProcessCameraProvider.isBound(camera.imageCapture))
        .thenAnswer((_) async => true);

    for (final FlashMode flashMode in FlashMode.values) {
      await camera.setFlashMode(cameraId, flashMode);

      int? expectedFlashMode;
      switch (flashMode) {
        case FlashMode.off:
          expectedFlashMode = ImageCapture.flashModeOff;
        case FlashMode.auto:
          expectedFlashMode = ImageCapture.flashModeAuto;
        case FlashMode.always:
          expectedFlashMode = ImageCapture.flashModeOn;
        case FlashMode.torch:
          expectedFlashMode = null;
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
    camera.cameraControl = mockCameraControl;

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
    camera.cameraControl = mockCameraControl;

    for (final FlashMode flashMode in FlashMode.values) {
      camera.torchEnabled = true;
      await camera.setFlashMode(cameraId, flashMode);

      switch (flashMode) {
        case FlashMode.off:
        case FlashMode.auto:
        case FlashMode.always:
          verify(mockCameraControl.enableTorch(false));
          expect(camera.torchEnabled, isFalse);
        case FlashMode.torch:
          verifyNever(mockCameraControl.enableTorch(true));
          expect(camera.torchEnabled, true);
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

  test(
      'getExposureOffsetStepSize returns -1 when exposure compensation not supported on device',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final ExposureState exposureState = ExposureState.detached(
        exposureCompensationRange:
            ExposureCompensationRange(minCompensation: 0, maxCompensation: 0),
        exposureCompensationStep: 0);

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = mockCameraInfo;

    when(mockCameraInfo.getExposureState())
        .thenAnswer((_) async => exposureState);

    expect(await camera.getExposureOffsetStepSize(55), -1);
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
    camera.cameraControl = mockCameraControl;

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

    // Ignore setting target rotation for this test; tested seprately.
    camera.captureOrientationLocked = true;

    when(mockProcessCameraProvider.bindToLifecycle(any, any))
        .thenAnswer((_) => Future<Camera>.value(mockCamera));
    when(mockProcessCameraProvider.isBound(camera.imageAnalysis))
        .thenAnswer((_) async => true);
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

    // Ignore setting target rotation for this test; tested seprately.
    camera.captureOrientationLocked = true;

    when(mockProcessCameraProvider.isBound(camera.imageAnalysis))
        .thenAnswer((_) async => true);

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
                Analyzer.detached(analyze: analyze),
        createCameraStateObserver: (void Function(Object) onChanged) =>
            Observer<CameraState>.detached(onChanged: onChanged));

    // Set directly for test versus calling createCamera.
    camera.processCameraProvider = mockProcessCameraProvider;
    camera.cameraSelector = mockCameraSelector;
    camera.imageAnalysis = mockImageAnalysis;

    // Ignore setting target rotation for this test; tested seprately.
    camera.captureOrientationLocked = true;

    when(mockProcessCameraProvider.isBound(mockImageAnalysis))
        .thenAnswer((_) async => false);
    when(mockProcessCameraProvider
            .bindToLifecycle(mockCameraSelector, <UseCase>[mockImageAnalysis]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());
    when(mockImageProxy.getPlanes())
        .thenAnswer((_) async => Future<List<PlaneProxy>>.value(mockPlanes));
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
    await untilCalled(mockImageAnalysis.setAnalyzer(any));
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
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();

    // Set directly for test versus calling createCamera.
    camera.imageAnalysis = mockImageAnalysis;
    camera.processCameraProvider = mockProcessCameraProvider;

    // Ignore setting target rotation for this test; tested seprately.
    camera.captureOrientationLocked = true;

    // Tell plugin to create a detached analyzer for testing purposes.
    camera.proxy = CameraXProxy(createAnalyzer: (_) => MockAnalyzer());

    when(mockProcessCameraProvider.isBound(mockImageAnalysis))
        .thenAnswer((_) async => true);

    final StreamSubscription<CameraImageData> imageStreamSubscription = camera
        .onStreamedFrameAvailable(cameraId)
        .listen((CameraImageData data) {});

    await imageStreamSubscription.cancel();

    verify(mockImageAnalysis.clearAnalyzer());
  });

  test(
      'onStreamedFrameAvailable sets ImageAnalysis target rotation to current photo orientation when orientation unlocked',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 35;
    const int defaultTargetRotation = Surface.rotation90;
    final MockImageAnalysis mockImageAnalysis = MockImageAnalysis();
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();

    // Set directly for test versus calling createCamera.
    camera.imageAnalysis = mockImageAnalysis;
    camera.processCameraProvider = mockProcessCameraProvider;

    // Tell plugin to create a detached analyzer for testing purposes and mock
    // call to get current photo orientation.
    camera.proxy = CameraXProxy(
        createAnalyzer: (_) => MockAnalyzer(),
        getDefaultDisplayRotation: () =>
            Future<int>.value(defaultTargetRotation));

    when(mockProcessCameraProvider.isBound(mockImageAnalysis))
        .thenAnswer((_) async => true);

    // Orientation is unlocked and plugin does not need to set default target
    // rotation manually.
    StreamSubscription<CameraImageData> imageStreamSubscription = camera
        .onStreamedFrameAvailable(cameraId)
        .listen((CameraImageData data) {});
    await untilCalled(mockImageAnalysis.setAnalyzer(any));
    verifyNever(mockImageAnalysis.setTargetRotation(any));
    await imageStreamSubscription.cancel();

    // Orientation is locked and plugin does not need to set default target
    // rotation manually.
    camera.captureOrientationLocked = true;
    imageStreamSubscription = camera
        .onStreamedFrameAvailable(cameraId)
        .listen((CameraImageData data) {});
    await untilCalled(mockImageAnalysis.setAnalyzer(any));
    verifyNever(mockImageAnalysis.setTargetRotation(any));
    await imageStreamSubscription.cancel();

    // Orientation is locked and plugin does need to set default target
    // rotation manually.
    camera.captureOrientationLocked = true;
    camera.shouldSetDefaultRotation = true;
    imageStreamSubscription = camera
        .onStreamedFrameAvailable(cameraId)
        .listen((CameraImageData data) {});
    await untilCalled(mockImageAnalysis.setAnalyzer(any));
    verifyNever(mockImageAnalysis.setTargetRotation(any));
    await imageStreamSubscription.cancel();

    // Orientation is unlocked and plugin does need to set default target
    // rotation manually.
    camera.captureOrientationLocked = false;
    camera.shouldSetDefaultRotation = true;
    imageStreamSubscription = camera
        .onStreamedFrameAvailable(cameraId)
        .listen((CameraImageData data) {});
    await untilCalled(
        mockImageAnalysis.setTargetRotation(defaultTargetRotation));
    await imageStreamSubscription.cancel();
  });

  test(
      'lockCaptureOrientation sets capture-related use case target rotations to correct orientation',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 44;

    final MockImageAnalysis mockImageAnalysis = MockImageAnalysis();
    final MockImageCapture mockImageCapture = MockImageCapture();
    final MockVideoCapture mockVideoCapture = MockVideoCapture();

    // Set directly for test versus calling createCamera.
    camera.imageAnalysis = mockImageAnalysis;
    camera.imageCapture = mockImageCapture;
    camera.videoCapture = mockVideoCapture;

    for (final DeviceOrientation orientation in DeviceOrientation.values) {
      int? expectedTargetRotation;
      switch (orientation) {
        case DeviceOrientation.portraitUp:
          expectedTargetRotation = Surface.rotation0;
        case DeviceOrientation.landscapeLeft:
          expectedTargetRotation = Surface.rotation90;
        case DeviceOrientation.portraitDown:
          expectedTargetRotation = Surface.rotation180;
        case DeviceOrientation.landscapeRight:
          expectedTargetRotation = Surface.rotation270;
      }

      await camera.lockCaptureOrientation(cameraId, orientation);

      verify(mockImageAnalysis.setTargetRotation(expectedTargetRotation));
      verify(mockImageCapture.setTargetRotation(expectedTargetRotation));
      verify(mockVideoCapture.setTargetRotation(expectedTargetRotation));
      expect(camera.captureOrientationLocked, isTrue);
      expect(camera.shouldSetDefaultRotation, isTrue);

      // Reset flags for testing.
      camera.captureOrientationLocked = false;
      camera.shouldSetDefaultRotation = false;
    }
  });

  test(
      'unlockCaptureOrientation sets capture-related use case target rotations to current photo/video orientation',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 57;

    camera.captureOrientationLocked = true;
    await camera.unlockCaptureOrientation(cameraId);
    expect(camera.captureOrientationLocked, isFalse);
  });

  test('setExposureMode sets expected controlAeLock value via Camera2 interop',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 78;
    final MockCameraControl mockCameraControl = MockCameraControl();
    final MockCamera2CameraControl mockCamera2CameraControl =
        MockCamera2CameraControl();

    // Set directly for test versus calling createCamera.
    camera.camera = MockCamera();
    camera.cameraControl = mockCameraControl;

    // Tell plugin to create detached Camera2CameraControl and
    // CaptureRequestOptions instances for testing.
    camera.proxy = CameraXProxy(
      getCamera2CameraControl: (CameraControl cameraControl) =>
          cameraControl == mockCameraControl
              ? mockCamera2CameraControl
              : Camera2CameraControl.detached(cameraControl: cameraControl),
      createCaptureRequestOptions:
          (List<(CaptureRequestKeySupportedType, Object?)> options) =>
              CaptureRequestOptions.detached(requestedOptions: options),
    );

    // Test auto mode.
    await camera.setExposureMode(cameraId, ExposureMode.auto);

    VerificationResult verificationResult =
        verify(mockCamera2CameraControl.addCaptureRequestOptions(captureAny));
    CaptureRequestOptions capturedCaptureRequestOptions =
        verificationResult.captured.single as CaptureRequestOptions;
    List<(CaptureRequestKeySupportedType, Object?)> requestedOptions =
        capturedCaptureRequestOptions.requestedOptions;
    expect(requestedOptions.length, equals(1));
    expect(requestedOptions.first.$1,
        equals(CaptureRequestKeySupportedType.controlAeLock));
    expect(requestedOptions.first.$2, equals(false));

    // Test locked mode.
    clearInteractions(mockCamera2CameraControl);
    await camera.setExposureMode(cameraId, ExposureMode.locked);

    verificationResult =
        verify(mockCamera2CameraControl.addCaptureRequestOptions(captureAny));
    capturedCaptureRequestOptions =
        verificationResult.captured.single as CaptureRequestOptions;
    requestedOptions = capturedCaptureRequestOptions.requestedOptions;
    expect(requestedOptions.length, equals(1));
    expect(requestedOptions.first.$1,
        equals(CaptureRequestKeySupportedType.controlAeLock));
    expect(requestedOptions.first.$2, equals(true));
  });

  test(
      'setExposurePoint clears current auto-exposure metering point as expected',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 93;
    final MockCameraControl mockCameraControl = MockCameraControl();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();

    // Set directly for test versus calling createCamera.
    camera.cameraControl = mockCameraControl;
    camera.cameraInfo = mockCameraInfo;

    camera.proxy = getProxyForExposureAndFocus();

    // Verify nothing happens if no current focus and metering action has been
    // enabled.
    await camera.setExposurePoint(cameraId, null);
    verifyNever(mockCameraControl.startFocusAndMetering(any));
    verifyNever(mockCameraControl.cancelFocusAndMetering());

    // Verify current auto-exposure metering point is removed if previously set.
    final (MeteringPoint, int?) autofocusMeteringPointInfo = (
      MeteringPoint.detached(x: 0.3, y: 0.7, cameraInfo: mockCameraInfo),
      FocusMeteringAction.flagAf
    );
    List<(MeteringPoint, int?)> meteringPointInfos = <(MeteringPoint, int?)>[
      (
        MeteringPoint.detached(x: 0.2, y: 0.5, cameraInfo: mockCameraInfo),
        FocusMeteringAction.flagAe
      ),
      autofocusMeteringPointInfo
    ];

    camera.currentFocusMeteringAction =
        FocusMeteringAction.detached(meteringPointInfos: meteringPointInfos);

    await camera.setExposurePoint(cameraId, null);

    final VerificationResult verificationResult =
        verify(mockCameraControl.startFocusAndMetering(captureAny));
    final FocusMeteringAction capturedAction =
        verificationResult.captured.single as FocusMeteringAction;
    final List<(MeteringPoint, int?)> capturedMeteringPointInfos =
        capturedAction.meteringPointInfos;
    expect(capturedMeteringPointInfos.length, equals(1));
    expect(
        capturedMeteringPointInfos.first, equals(autofocusMeteringPointInfo));

    // Verify current focus and metering action is cleared if only previously
    // set metering point was for auto-exposure.
    meteringPointInfos = <(MeteringPoint, int?)>[
      (
        MeteringPoint.detached(x: 0.2, y: 0.5, cameraInfo: mockCameraInfo),
        FocusMeteringAction.flagAe
      )
    ];
    camera.currentFocusMeteringAction =
        FocusMeteringAction.detached(meteringPointInfos: meteringPointInfos);

    await camera.setExposurePoint(cameraId, null);

    verify(mockCameraControl.cancelFocusAndMetering());
  });

  test('setExposurePoint throws CameraException if invalid point specified',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 23;
    final MockCameraControl mockCameraControl = MockCameraControl();
    const Point<double> invalidExposurePoint = Point<double>(3, -1);

    // Set directly for test versus calling createCamera.
    camera.cameraControl = mockCameraControl;
    camera.cameraInfo = MockCameraInfo();

    camera.proxy = getProxyForExposureAndFocus();

    expect(() => camera.setExposurePoint(cameraId, invalidExposurePoint),
        throwsA(isA<CameraException>()));
  });

  test(
      'setExposurePoint adds new exposure point to focus metering action to start as expected when previous metering points have been set',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 9;
    final MockCameraControl mockCameraControl = MockCameraControl();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();

    // Set directly for test versus calling createCamera.
    camera.cameraControl = mockCameraControl;
    camera.cameraInfo = mockCameraInfo;

    camera.proxy = getProxyForExposureAndFocus();

    // Verify current auto-exposure metering point is removed if previously set.
    double exposurePointX = 0.8;
    double exposurePointY = 0.1;
    Point<double> exposurePoint = Point<double>(exposurePointX, exposurePointY);
    final (MeteringPoint, int?) autofocusMeteringPointInfo = (
      MeteringPoint.detached(x: 0.3, y: 0.7, cameraInfo: mockCameraInfo),
      FocusMeteringAction.flagAf
    );
    List<(MeteringPoint, int?)> meteringPointInfos = <(MeteringPoint, int?)>[
      (
        MeteringPoint.detached(x: 0.2, y: 0.5, cameraInfo: mockCameraInfo),
        FocusMeteringAction.flagAe
      ),
      autofocusMeteringPointInfo
    ];

    camera.currentFocusMeteringAction =
        FocusMeteringAction.detached(meteringPointInfos: meteringPointInfos);

    await camera.setExposurePoint(cameraId, exposurePoint);

    VerificationResult verificationResult =
        verify(mockCameraControl.startFocusAndMetering(captureAny));
    FocusMeteringAction capturedAction =
        verificationResult.captured.single as FocusMeteringAction;
    List<(MeteringPoint, int?)> capturedMeteringPointInfos =
        capturedAction.meteringPointInfos;
    expect(capturedMeteringPointInfos.length, equals(2));
    expect(
        capturedMeteringPointInfos.first, equals(autofocusMeteringPointInfo));
    expect(capturedMeteringPointInfos[1].$1.x, equals(exposurePointX));
    expect(capturedMeteringPointInfos[1].$1.y, equals(exposurePointY));
    expect(
        capturedMeteringPointInfos[1].$2, equals(FocusMeteringAction.flagAe));

    // Verify exposure point is set when no auto-exposure metering point
    // previously set, but an auto-focus point metering point has been.
    exposurePointX = 0.2;
    exposurePointY = 0.9;
    exposurePoint = Point<double>(exposurePointX, exposurePointY);
    meteringPointInfos = <(MeteringPoint, int?)>[autofocusMeteringPointInfo];

    camera.currentFocusMeteringAction =
        FocusMeteringAction.detached(meteringPointInfos: meteringPointInfos);

    await camera.setExposurePoint(cameraId, exposurePoint);

    verificationResult =
        verify(mockCameraControl.startFocusAndMetering(captureAny));
    capturedAction = verificationResult.captured.single as FocusMeteringAction;
    capturedMeteringPointInfos = capturedAction.meteringPointInfos;
    expect(capturedMeteringPointInfos.length, equals(2));
    expect(
        capturedMeteringPointInfos.first, equals(autofocusMeteringPointInfo));
    expect(capturedMeteringPointInfos[1].$1.x, equals(exposurePointX));
    expect(capturedMeteringPointInfos[1].$1.y, equals(exposurePointY));
    expect(
        capturedMeteringPointInfos[1].$2, equals(FocusMeteringAction.flagAe));
  });

  test(
      'setExposurePoint adds new exposure point to focus metering action to start as expected when no previous metering points have been set',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 19;
    final MockCameraControl mockCameraControl = MockCameraControl();
    const double exposurePointX = 0.8;
    const double exposurePointY = 0.1;
    const Point<double> exposurePoint =
        Point<double>(exposurePointX, exposurePointY);

    // Set directly for test versus calling createCamera.
    camera.cameraControl = mockCameraControl;
    camera.cameraInfo = MockCameraInfo();
    camera.currentFocusMeteringAction = null;

    camera.proxy = getProxyForExposureAndFocus();

    await camera.setExposurePoint(cameraId, exposurePoint);

    final VerificationResult verificationResult =
        verify(mockCameraControl.startFocusAndMetering(captureAny));
    final FocusMeteringAction capturedAction =
        verificationResult.captured.single as FocusMeteringAction;
    final List<(MeteringPoint, int?)> capturedMeteringPointInfos =
        capturedAction.meteringPointInfos;
    expect(capturedMeteringPointInfos.length, equals(1));
    expect(capturedMeteringPointInfos.first.$1.x, equals(exposurePointX));
    expect(capturedMeteringPointInfos.first.$1.y, equals(exposurePointY));
    expect(capturedMeteringPointInfos.first.$2,
        equals(FocusMeteringAction.flagAe));
  });

  test(
      'setExposurePoint disables auto-cancel for focus and metering as expected',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 2;
    final MockCameraControl mockCameraControl = MockCameraControl();
    final FocusMeteringResult mockFocusMeteringResult =
        MockFocusMeteringResult();
    const Point<double> exposurePoint = Point<double>(0.1, 0.2);

    // Set directly for test versus calling createCamera.
    camera.cameraControl = mockCameraControl;
    camera.cameraInfo = MockCameraInfo();

    camera.proxy = getProxyForSettingFocusandExposurePoints(
        mockCameraControl, MockCamera2CameraControl());

    // Make setting focus and metering action successful for test.
    when(mockFocusMeteringResult.isFocusSuccessful())
        .thenAnswer((_) async => Future<bool>.value(true));
    when(mockCameraControl.startFocusAndMetering(any)).thenAnswer((_) async =>
        Future<FocusMeteringResult>.value(mockFocusMeteringResult));

    // Test not disabling auto cancel.
    await camera.setFocusMode(cameraId, FocusMode.auto);
    clearInteractions(mockCameraControl);
    await camera.setExposurePoint(cameraId, exposurePoint);
    VerificationResult verificationResult =
        verify(mockCameraControl.startFocusAndMetering(captureAny));
    FocusMeteringAction capturedAction =
        verificationResult.captured.single as FocusMeteringAction;
    expect(capturedAction.disableAutoCancel, isFalse);

    clearInteractions(mockCameraControl);

    // Test disabling auto cancel.
    await camera.setFocusMode(cameraId, FocusMode.locked);
    clearInteractions(mockCameraControl);
    await camera.setExposurePoint(cameraId, exposurePoint);
    verificationResult =
        verify(mockCameraControl.startFocusAndMetering(captureAny));
    capturedAction = verificationResult.captured.single as FocusMeteringAction;
    expect(capturedAction.disableAutoCancel, isTrue);
  });

  test(
      'setExposureOffset throws exception if exposure compensation not supported',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 6;
    const double offset = 2;
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final ExposureState exposureState = ExposureState.detached(
        exposureCompensationRange:
            ExposureCompensationRange(minCompensation: 3, maxCompensation: 4),
        exposureCompensationStep: 0);

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = mockCameraInfo;

    when(mockCameraInfo.getExposureState())
        .thenAnswer((_) async => exposureState);

    expect(() => camera.setExposureOffset(cameraId, offset),
        throwsA(isA<CameraException>()));
  });

  test(
      'setExposureOffset throws exception if exposure compensation could not be set for unknown reason',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 11;
    const double offset = 3;
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final CameraControl mockCameraControl = MockCameraControl();
    final ExposureState exposureState = ExposureState.detached(
        exposureCompensationRange:
            ExposureCompensationRange(minCompensation: 3, maxCompensation: 4),
        exposureCompensationStep: 0.2);

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = mockCameraInfo;
    camera.cameraControl = mockCameraControl;

    when(mockCameraInfo.getExposureState())
        .thenAnswer((_) async => exposureState);
    when(mockCameraControl.setExposureCompensationIndex(15)).thenThrow(
        PlatformException(
            code: 'TEST_ERROR',
            message:
                'This is a test error message indicating exposure offset could not be set.'));

    expect(() => camera.setExposureOffset(cameraId, offset),
        throwsA(isA<CameraException>()));
  });

  test(
      'setExposureOffset throws exception if exposure compensation could not be set due to camera being closed or newer value being set',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 21;
    const double offset = 5;
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final CameraControl mockCameraControl = MockCameraControl();
    final ExposureState exposureState = ExposureState.detached(
        exposureCompensationRange:
            ExposureCompensationRange(minCompensation: 3, maxCompensation: 4),
        exposureCompensationStep: 0.1);
    final int expectedExposureCompensationIndex =
        (offset / exposureState.exposureCompensationStep).round();

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = mockCameraInfo;
    camera.cameraControl = mockCameraControl;

    when(mockCameraInfo.getExposureState())
        .thenAnswer((_) async => exposureState);
    when(mockCameraControl
            .setExposureCompensationIndex(expectedExposureCompensationIndex))
        .thenAnswer((_) async => Future<int?>.value());

    expect(() => camera.setExposureOffset(cameraId, offset),
        throwsA(isA<CameraException>()));
  });

  test(
      'setExposureOffset behaves as expected to successful attempt to set exposure compensation index',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 11;
    const double offset = 3;
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final CameraControl mockCameraControl = MockCameraControl();
    final ExposureState exposureState = ExposureState.detached(
        exposureCompensationRange:
            ExposureCompensationRange(minCompensation: 3, maxCompensation: 4),
        exposureCompensationStep: 0.2);
    final int expectedExposureCompensationIndex =
        (offset / exposureState.exposureCompensationStep).round();

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = mockCameraInfo;
    camera.cameraControl = mockCameraControl;

    when(mockCameraInfo.getExposureState())
        .thenAnswer((_) async => exposureState);
    when(mockCameraControl
            .setExposureCompensationIndex(expectedExposureCompensationIndex))
        .thenAnswer((_) async => Future<int>.value(
            (expectedExposureCompensationIndex *
                    exposureState.exposureCompensationStep)
                .round()));

    // Exposure index * exposure offset step size = exposure offset, i.e.
    // 15 * 0.2 = 3.
    expect(await camera.setExposureOffset(cameraId, offset), equals(3));
  });

  test('setFocusPoint clears current auto-exposure metering point as expected',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 93;
    final MockCameraControl mockCameraControl = MockCameraControl();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();

    // Set directly for test versus calling createCamera.
    camera.cameraControl = mockCameraControl;
    camera.cameraInfo = mockCameraInfo;

    camera.proxy = getProxyForExposureAndFocus();

    // Verify nothing happens if no current focus and metering action has been
    // enabled.
    await camera.setFocusPoint(cameraId, null);
    verifyNever(mockCameraControl.startFocusAndMetering(any));
    verifyNever(mockCameraControl.cancelFocusAndMetering());

    // Verify current auto-exposure metering point is removed if previously set.
    final (MeteringPoint, int?) autoexposureMeteringPointInfo = (
      MeteringPoint.detached(x: 0.3, y: 0.7, cameraInfo: mockCameraInfo),
      FocusMeteringAction.flagAe
    );
    List<(MeteringPoint, int?)> meteringPointInfos = <(MeteringPoint, int?)>[
      (
        MeteringPoint.detached(x: 0.2, y: 0.5, cameraInfo: mockCameraInfo),
        FocusMeteringAction.flagAf
      ),
      autoexposureMeteringPointInfo
    ];

    camera.currentFocusMeteringAction =
        FocusMeteringAction.detached(meteringPointInfos: meteringPointInfos);

    await camera.setFocusPoint(cameraId, null);

    final VerificationResult verificationResult =
        verify(mockCameraControl.startFocusAndMetering(captureAny));
    final FocusMeteringAction capturedAction =
        verificationResult.captured.single as FocusMeteringAction;
    final List<(MeteringPoint, int?)> capturedMeteringPointInfos =
        capturedAction.meteringPointInfos;
    expect(capturedMeteringPointInfos.length, equals(1));
    expect(capturedMeteringPointInfos.first,
        equals(autoexposureMeteringPointInfo));

    // Verify current focus and metering action is cleared if only previously
    // set metering point was for auto-exposure.
    meteringPointInfos = <(MeteringPoint, int?)>[
      (
        MeteringPoint.detached(x: 0.2, y: 0.5, cameraInfo: mockCameraInfo),
        FocusMeteringAction.flagAf
      )
    ];
    camera.currentFocusMeteringAction =
        FocusMeteringAction.detached(meteringPointInfos: meteringPointInfos);

    await camera.setFocusPoint(cameraId, null);

    verify(mockCameraControl.cancelFocusAndMetering());
  });

  test('setFocusPoint throws CameraException if invalid point specified',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 23;
    final MockCameraControl mockCameraControl = MockCameraControl();
    const Point<double> invalidFocusPoint = Point<double>(-3, 1);

    // Set directly for test versus calling createCamera.
    camera.cameraControl = mockCameraControl;
    camera.cameraInfo = MockCameraInfo();

    camera.proxy = getProxyForExposureAndFocus();

    expect(() => camera.setFocusPoint(cameraId, invalidFocusPoint),
        throwsA(isA<CameraException>()));
  });

  test(
      'setFocusPoint adds new exposure point to focus metering action to start as expected when previous metering points have been set',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 9;
    final MockCameraControl mockCameraControl = MockCameraControl();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();

    // Set directly for test versus calling createCamera.
    camera.cameraControl = mockCameraControl;
    camera.cameraInfo = mockCameraInfo;

    camera.proxy = getProxyForExposureAndFocus();

    // Verify current auto-exposure metering point is removed if previously set.
    double focusPointX = 0.8;
    double focusPointY = 0.1;
    Point<double> exposurePoint = Point<double>(focusPointX, focusPointY);
    final (MeteringPoint, int?) autoExposureMeteringPointInfo = (
      MeteringPoint.detached(x: 0.3, y: 0.7, cameraInfo: mockCameraInfo),
      FocusMeteringAction.flagAe
    );
    List<(MeteringPoint, int?)> meteringPointInfos = <(MeteringPoint, int?)>[
      (
        MeteringPoint.detached(x: 0.2, y: 0.5, cameraInfo: mockCameraInfo),
        FocusMeteringAction.flagAf
      ),
      autoExposureMeteringPointInfo
    ];

    camera.currentFocusMeteringAction =
        FocusMeteringAction.detached(meteringPointInfos: meteringPointInfos);

    await camera.setFocusPoint(cameraId, exposurePoint);

    VerificationResult verificationResult =
        verify(mockCameraControl.startFocusAndMetering(captureAny));
    FocusMeteringAction capturedAction =
        verificationResult.captured.single as FocusMeteringAction;
    List<(MeteringPoint, int?)> capturedMeteringPointInfos =
        capturedAction.meteringPointInfos;
    expect(capturedMeteringPointInfos.length, equals(2));
    expect(capturedMeteringPointInfos.first,
        equals(autoExposureMeteringPointInfo));
    expect(capturedMeteringPointInfos[1].$1.x, equals(focusPointX));
    expect(capturedMeteringPointInfos[1].$1.y, equals(focusPointY));
    expect(
        capturedMeteringPointInfos[1].$2, equals(FocusMeteringAction.flagAf));

    // Verify exposure point is set when no auto-exposure metering point
    // previously set, but an auto-focus point metering point has been.
    focusPointX = 0.2;
    focusPointY = 0.9;
    exposurePoint = Point<double>(focusPointX, focusPointY);
    meteringPointInfos = <(MeteringPoint, int?)>[autoExposureMeteringPointInfo];

    camera.currentFocusMeteringAction =
        FocusMeteringAction.detached(meteringPointInfos: meteringPointInfos);

    await camera.setFocusPoint(cameraId, exposurePoint);

    verificationResult =
        verify(mockCameraControl.startFocusAndMetering(captureAny));
    capturedAction = verificationResult.captured.single as FocusMeteringAction;
    capturedMeteringPointInfos = capturedAction.meteringPointInfos;
    expect(capturedMeteringPointInfos.length, equals(2));
    expect(capturedMeteringPointInfos.first,
        equals(autoExposureMeteringPointInfo));
    expect(capturedMeteringPointInfos[1].$1.x, equals(focusPointX));
    expect(capturedMeteringPointInfos[1].$1.y, equals(focusPointY));
    expect(
        capturedMeteringPointInfos[1].$2, equals(FocusMeteringAction.flagAf));
  });

  test(
      'setFocusPoint adds new exposure point to focus metering action to start as expected when no previous metering points have been set',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 19;
    final MockCameraControl mockCameraControl = MockCameraControl();
    const double focusPointX = 0.8;
    const double focusPointY = 0.1;
    const Point<double> exposurePoint = Point<double>(focusPointX, focusPointY);

    // Set directly for test versus calling createCamera.
    camera.cameraControl = mockCameraControl;
    camera.cameraInfo = MockCameraInfo();
    camera.currentFocusMeteringAction = null;

    camera.proxy = getProxyForExposureAndFocus();

    await camera.setFocusPoint(cameraId, exposurePoint);

    final VerificationResult verificationResult =
        verify(mockCameraControl.startFocusAndMetering(captureAny));
    final FocusMeteringAction capturedAction =
        verificationResult.captured.single as FocusMeteringAction;
    final List<(MeteringPoint, int?)> capturedMeteringPointInfos =
        capturedAction.meteringPointInfos;
    expect(capturedMeteringPointInfos.length, equals(1));
    expect(capturedMeteringPointInfos.first.$1.x, equals(focusPointX));
    expect(capturedMeteringPointInfos.first.$1.y, equals(focusPointY));
    expect(capturedMeteringPointInfos.first.$2,
        equals(FocusMeteringAction.flagAf));
  });

  test('setFocusPoint disables auto-cancel for focus and metering as expected',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 2;
    final MockCameraControl mockCameraControl = MockCameraControl();
    final MockFocusMeteringResult mockFocusMeteringResult =
        MockFocusMeteringResult();
    const Point<double> exposurePoint = Point<double>(0.1, 0.2);

    // Set directly for test versus calling createCamera.
    camera.cameraControl = mockCameraControl;
    camera.cameraInfo = MockCameraInfo();

    camera.proxy = getProxyForSettingFocusandExposurePoints(
        mockCameraControl, MockCamera2CameraControl());

    // Make setting focus and metering action successful for test.
    when(mockFocusMeteringResult.isFocusSuccessful())
        .thenAnswer((_) async => Future<bool>.value(true));
    when(mockCameraControl.startFocusAndMetering(any)).thenAnswer((_) async =>
        Future<FocusMeteringResult>.value(mockFocusMeteringResult));

    // Test not disabling auto cancel.
    await camera.setFocusMode(cameraId, FocusMode.auto);
    clearInteractions(mockCameraControl);

    await camera.setFocusPoint(cameraId, exposurePoint);
    VerificationResult verificationResult =
        verify(mockCameraControl.startFocusAndMetering(captureAny));
    FocusMeteringAction capturedAction =
        verificationResult.captured.single as FocusMeteringAction;
    expect(capturedAction.disableAutoCancel, isFalse);

    clearInteractions(mockCameraControl);

    // Test disabling auto cancel.
    await camera.setFocusMode(cameraId, FocusMode.locked);
    clearInteractions(mockCameraControl);

    await camera.setFocusPoint(cameraId, exposurePoint);
    verificationResult =
        verify(mockCameraControl.startFocusAndMetering(captureAny));
    capturedAction = verificationResult.captured.single as FocusMeteringAction;
    expect(capturedAction.disableAutoCancel, isTrue);
  });

  test(
      'setFocusMode does nothing if setting auto-focus mode and is already using auto-focus mode',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 4;
    final MockCameraControl mockCameraControl = MockCameraControl();
    final MockFocusMeteringResult mockFocusMeteringResult =
        MockFocusMeteringResult();

    // Set directly for test versus calling createCamera.
    camera.cameraControl = mockCameraControl;
    camera.cameraInfo = MockCameraInfo();

    camera.proxy = getProxyForSettingFocusandExposurePoints(
        mockCameraControl, MockCamera2CameraControl());

    // Make setting focus and metering action successful for test.
    when(mockFocusMeteringResult.isFocusSuccessful())
        .thenAnswer((_) async => Future<bool>.value(true));
    when(mockCameraControl.startFocusAndMetering(any)).thenAnswer((_) async =>
        Future<FocusMeteringResult>.value(mockFocusMeteringResult));

    // Set locked focus mode and then try to re-set it.
    await camera.setFocusMode(cameraId, FocusMode.locked);
    clearInteractions(mockCameraControl);

    await camera.setFocusMode(cameraId, FocusMode.locked);
    verifyNoMoreInteractions(mockCameraControl);
  });

  test(
      'setFocusMode does nothing if setting locked focus mode and is already using locked focus mode',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 4;
    final MockCameraControl mockCameraControl = MockCameraControl();

    // Camera uses auto-focus by default, so try setting auto mode again.
    await camera.setFocusMode(cameraId, FocusMode.auto);

    verifyNoMoreInteractions(mockCameraControl);
  });

  test(
      'setFocusMode removes default auto-focus point if previously set and setting auto-focus mode',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 5;
    final MockCameraControl mockCameraControl = MockCameraControl();
    final MockFocusMeteringResult mockFocusMeteringResult =
        MockFocusMeteringResult();
    final MockCamera2CameraControl mockCamera2CameraControl =
        MockCamera2CameraControl();
    const double exposurePointX = 0.2;
    const double exposurePointY = 0.7;

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = MockCameraInfo();
    camera.cameraControl = mockCameraControl;

    when(mockCamera2CameraControl.addCaptureRequestOptions(any))
        .thenAnswer((_) async => Future<void>.value());

    camera.proxy = getProxyForSettingFocusandExposurePoints(
        mockCameraControl, mockCamera2CameraControl);

    // Make setting focus and metering action successful for test.
    when(mockFocusMeteringResult.isFocusSuccessful())
        .thenAnswer((_) async => Future<bool>.value(true));
    when(mockCameraControl.startFocusAndMetering(any)).thenAnswer((_) async =>
        Future<FocusMeteringResult>.value(mockFocusMeteringResult));

    // Set exposure points.
    await camera.setExposurePoint(
        cameraId, const Point<double>(exposurePointX, exposurePointY));

    // Lock focus default focus point.
    await camera.setFocusMode(cameraId, FocusMode.locked);

    clearInteractions(mockCameraControl);

    // Test removal of default focus point.
    await camera.setFocusMode(cameraId, FocusMode.auto);

    final VerificationResult verificationResult =
        verify(mockCameraControl.startFocusAndMetering(captureAny));
    final FocusMeteringAction capturedAction =
        verificationResult.captured.single as FocusMeteringAction;
    expect(capturedAction.disableAutoCancel, isFalse);

    // We expect only the previously set exposure point to be re-set.
    final List<(MeteringPoint, int?)> capturedMeteringPointInfos =
        capturedAction.meteringPointInfos;
    expect(capturedMeteringPointInfos.length, equals(1));
    expect(capturedMeteringPointInfos.first.$1.x, equals(exposurePointX));
    expect(capturedMeteringPointInfos.first.$1.y, equals(exposurePointY));
    expect(capturedMeteringPointInfos.first.$1.size, isNull);
    expect(capturedMeteringPointInfos.first.$2,
        equals(FocusMeteringAction.flagAe));
  });

  test(
      'setFocusMode cancels focus and metering if only focus point previously set is a focus point',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 5;
    final MockCameraControl mockCameraControl = MockCameraControl();
    final FocusMeteringResult mockFocusMeteringResult =
        MockFocusMeteringResult();
    final MockCamera2CameraControl mockCamera2CameraControl =
        MockCamera2CameraControl();

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = MockCameraInfo();
    camera.cameraControl = mockCameraControl;

    when(mockCamera2CameraControl.addCaptureRequestOptions(any))
        .thenAnswer((_) async => Future<void>.value());

    camera.proxy = getProxyForSettingFocusandExposurePoints(
        mockCameraControl, mockCamera2CameraControl);

    // Make setting focus and metering action successful for test.
    when(mockFocusMeteringResult.isFocusSuccessful())
        .thenAnswer((_) async => Future<bool>.value(true));
    when(mockCameraControl.startFocusAndMetering(any)).thenAnswer((_) async =>
        Future<FocusMeteringResult>.value(mockFocusMeteringResult));

    // Lock focus default focus point.
    await camera.setFocusMode(cameraId, FocusMode.locked);

    // Test removal of default focus point.
    await camera.setFocusMode(cameraId, FocusMode.auto);

    verify(mockCameraControl.cancelFocusAndMetering());
  });

  test(
      'setFocusMode re-focuses on previously set auto-focus point with auto-canceled enabled if setting auto-focus mode',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 6;
    final MockCameraControl mockCameraControl = MockCameraControl();
    final FocusMeteringResult mockFocusMeteringResult =
        MockFocusMeteringResult();
    final MockCamera2CameraControl mockCamera2CameraControl =
        MockCamera2CameraControl();
    const double focusPointX = 0.1;
    const double focusPointY = 0.2;

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = MockCameraInfo();
    camera.cameraControl = mockCameraControl;

    when(mockCamera2CameraControl.addCaptureRequestOptions(any))
        .thenAnswer((_) async => Future<void>.value());

    camera.proxy = getProxyForSettingFocusandExposurePoints(
        mockCameraControl, mockCamera2CameraControl);

    // Make setting focus and metering action successful for test.
    when(mockFocusMeteringResult.isFocusSuccessful())
        .thenAnswer((_) async => Future<bool>.value(true));
    when(mockCameraControl.startFocusAndMetering(any)).thenAnswer((_) async =>
        Future<FocusMeteringResult>.value(mockFocusMeteringResult));

    // Lock a focus point.
    await camera.setFocusPoint(
        cameraId, const Point<double>(focusPointX, focusPointY));
    await camera.setFocusMode(cameraId, FocusMode.locked);

    clearInteractions(mockCameraControl);

    // Test re-focusing on previously set auto-focus point with auto-cancel enabled.
    await camera.setFocusMode(cameraId, FocusMode.auto);

    final VerificationResult verificationResult =
        verify(mockCameraControl.startFocusAndMetering(captureAny));
    final FocusMeteringAction capturedAction =
        verificationResult.captured.single as FocusMeteringAction;
    expect(capturedAction.disableAutoCancel, isFalse);
    final List<(MeteringPoint, int?)> capturedMeteringPointInfos =
        capturedAction.meteringPointInfos;
    expect(capturedMeteringPointInfos.length, equals(1));
    expect(capturedMeteringPointInfos.first.$1.x, equals(focusPointX));
    expect(capturedMeteringPointInfos.first.$1.y, equals(focusPointY));
    expect(capturedMeteringPointInfos.first.$1.size, isNull);
    expect(capturedMeteringPointInfos.first.$2,
        equals(FocusMeteringAction.flagAf));
  });

  test(
      'setFocusMode starts expected focus and metering action with previously set auto-focus point if setting locked focus mode and current focus and metering action has auto-focus point',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 7;
    final MockCameraControl mockCameraControl = MockCameraControl();
    final MockCamera2CameraControl mockCamera2CameraControl =
        MockCamera2CameraControl();
    const double focusPointX = 0.88;
    const double focusPointY = 0.33;

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = MockCameraInfo();
    camera.cameraControl = mockCameraControl;

    when(mockCamera2CameraControl.addCaptureRequestOptions(any))
        .thenAnswer((_) async => Future<void>.value());

    camera.proxy = getProxyForSettingFocusandExposurePoints(
        mockCameraControl, mockCamera2CameraControl);

    // Set a focus point.
    await camera.setFocusPoint(
        cameraId, const Point<double>(focusPointX, focusPointY));
    clearInteractions(mockCameraControl);

    // Lock focus point.
    await camera.setFocusMode(cameraId, FocusMode.locked);

    final VerificationResult verificationResult =
        verify(mockCameraControl.startFocusAndMetering(captureAny));
    final FocusMeteringAction capturedAction =
        verificationResult.captured.single as FocusMeteringAction;
    expect(capturedAction.disableAutoCancel, isTrue);

    // We expect the set focus point to be locked.
    final List<(MeteringPoint, int?)> capturedMeteringPointInfos =
        capturedAction.meteringPointInfos;
    expect(capturedMeteringPointInfos.length, equals(1));
    expect(capturedMeteringPointInfos.first.$1.x, equals(focusPointX));
    expect(capturedMeteringPointInfos.first.$1.y, equals(focusPointY));
    expect(capturedMeteringPointInfos.first.$1.size, isNull);
    expect(capturedMeteringPointInfos.first.$2,
        equals(FocusMeteringAction.flagAf));
  });

  test(
      'setFocusMode starts expected focus and metering action with previously set auto-focus point if setting locked focus mode and current focus and metering action has auto-focus point amongst others',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 8;
    final MockCameraControl mockCameraControl = MockCameraControl();
    final MockCamera2CameraControl mockCamera2CameraControl =
        MockCamera2CameraControl();
    const double focusPointX = 0.38;
    const double focusPointY = 0.38;
    const double exposurePointX = 0.54;
    const double exposurePointY = 0.45;

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = MockCameraInfo();
    camera.cameraControl = mockCameraControl;

    when(mockCamera2CameraControl.addCaptureRequestOptions(any))
        .thenAnswer((_) async => Future<void>.value());

    camera.proxy = getProxyForSettingFocusandExposurePoints(
        mockCameraControl, mockCamera2CameraControl);

    // Set focus and exposure points.
    await camera.setFocusPoint(
        cameraId, const Point<double>(focusPointX, focusPointY));
    await camera.setExposurePoint(
        cameraId, const Point<double>(exposurePointX, exposurePointY));
    clearInteractions(mockCameraControl);

    // Lock focus point.
    await camera.setFocusMode(cameraId, FocusMode.locked);

    final VerificationResult verificationResult =
        verify(mockCameraControl.startFocusAndMetering(captureAny));
    final FocusMeteringAction capturedAction =
        verificationResult.captured.single as FocusMeteringAction;
    expect(capturedAction.disableAutoCancel, isTrue);

    // We expect two MeteringPoints, the set focus point and the set exposure
    // point.
    final List<(MeteringPoint, int?)> capturedMeteringPointInfos =
        capturedAction.meteringPointInfos;
    expect(capturedMeteringPointInfos.length, equals(2));

    final List<(MeteringPoint, int?)> focusPoints = capturedMeteringPointInfos
        .where(((MeteringPoint, int?) meteringPointInfo) =>
            meteringPointInfo.$2 == FocusMeteringAction.flagAf)
        .toList();
    expect(focusPoints.length, equals(1));
    expect(focusPoints.first.$1.x, equals(focusPointX));
    expect(focusPoints.first.$1.y, equals(focusPointY));
    expect(focusPoints.first.$1.size, isNull);

    final List<(MeteringPoint, int?)> exposurePoints =
        capturedMeteringPointInfos
            .where(((MeteringPoint, int?) meteringPointInfo) =>
                meteringPointInfo.$2 == FocusMeteringAction.flagAe)
            .toList();
    expect(exposurePoints.length, equals(1));
    expect(exposurePoints.first.$1.x, equals(exposurePointX));
    expect(exposurePoints.first.$1.y, equals(exposurePointY));
    expect(exposurePoints.first.$1.size, isNull);
  });

  test(
      'setFocusMode starts expected focus and metering action if setting locked focus mode and current focus and metering action does not contain an auto-focus point',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 9;
    final MockCameraControl mockCameraControl = MockCameraControl();
    final MockCamera2CameraControl mockCamera2CameraControl =
        MockCamera2CameraControl();
    const double exposurePointX = 0.8;
    const double exposurePointY = 0.3;
    const double defaultFocusPointX = 0.5;
    const double defaultFocusPointY = 0.5;
    const double defaultFocusPointSize = 1;

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = MockCameraInfo();
    camera.cameraControl = mockCameraControl;

    when(mockCamera2CameraControl.addCaptureRequestOptions(any))
        .thenAnswer((_) async => Future<void>.value());

    camera.proxy = getProxyForSettingFocusandExposurePoints(
        mockCameraControl, mockCamera2CameraControl);

    // Set an exposure point (creates a current focus and metering action
    // without a focus point).
    await camera.setExposurePoint(
        cameraId, const Point<double>(exposurePointX, exposurePointY));
    clearInteractions(mockCameraControl);

    // Lock focus point.
    await camera.setFocusMode(cameraId, FocusMode.locked);

    final VerificationResult verificationResult =
        verify(mockCameraControl.startFocusAndMetering(captureAny));
    final FocusMeteringAction capturedAction =
        verificationResult.captured.single as FocusMeteringAction;
    expect(capturedAction.disableAutoCancel, isTrue);

    // We expect two MeteringPoints, the default focus point and the set
    //exposure point.
    final List<(MeteringPoint, int?)> capturedMeteringPointInfos =
        capturedAction.meteringPointInfos;
    expect(capturedMeteringPointInfos.length, equals(2));

    final List<(MeteringPoint, int?)> focusPoints = capturedMeteringPointInfos
        .where(((MeteringPoint, int?) meteringPointInfo) =>
            meteringPointInfo.$2 == FocusMeteringAction.flagAf)
        .toList();
    expect(focusPoints.length, equals(1));
    expect(focusPoints.first.$1.x, equals(defaultFocusPointX));
    expect(focusPoints.first.$1.y, equals(defaultFocusPointY));
    expect(focusPoints.first.$1.size, equals(defaultFocusPointSize));

    final List<(MeteringPoint, int?)> exposurePoints =
        capturedMeteringPointInfos
            .where(((MeteringPoint, int?) meteringPointInfo) =>
                meteringPointInfo.$2 == FocusMeteringAction.flagAe)
            .toList();
    expect(exposurePoints.length, equals(1));
    expect(exposurePoints.first.$1.x, equals(exposurePointX));
    expect(exposurePoints.first.$1.y, equals(exposurePointY));
    expect(exposurePoints.first.$1.size, isNull);
  });

  test(
      'setFocusMode starts expected focus and metering action if there is no current focus and metering action',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 10;
    final MockCameraControl mockCameraControl = MockCameraControl();
    final MockCamera2CameraControl mockCamera2CameraControl =
        MockCamera2CameraControl();
    const double defaultFocusPointX = 0.5;
    const double defaultFocusPointY = 0.5;
    const double defaultFocusPointSize = 1;

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = MockCameraInfo();
    camera.cameraControl = mockCameraControl;

    when(mockCamera2CameraControl.addCaptureRequestOptions(any))
        .thenAnswer((_) async => Future<void>.value());

    camera.proxy = getProxyForSettingFocusandExposurePoints(
        mockCameraControl, mockCamera2CameraControl);

    // Lock focus point.
    await camera.setFocusMode(cameraId, FocusMode.locked);

    final VerificationResult verificationResult =
        verify(mockCameraControl.startFocusAndMetering(captureAny));
    final FocusMeteringAction capturedAction =
        verificationResult.captured.single as FocusMeteringAction;
    expect(capturedAction.disableAutoCancel, isTrue);

    // We expect only the default focus point to be set.
    final List<(MeteringPoint, int?)> capturedMeteringPointInfos =
        capturedAction.meteringPointInfos;
    expect(capturedMeteringPointInfos.length, equals(1));
    expect(capturedMeteringPointInfos.first.$1.x, equals(defaultFocusPointX));
    expect(capturedMeteringPointInfos.first.$1.y, equals(defaultFocusPointY));
    expect(capturedMeteringPointInfos.first.$1.size,
        equals(defaultFocusPointSize));
    expect(capturedMeteringPointInfos.first.$2,
        equals(FocusMeteringAction.flagAf));
  });

  test(
      'setFocusMode re-sets exposure mode if setting locked focus mode while using auto exposure mode',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 11;
    final MockCameraControl mockCameraControl = MockCameraControl();
    final FocusMeteringResult mockFocusMeteringResult =
        MockFocusMeteringResult();
    final MockCamera2CameraControl mockCamera2CameraControl =
        MockCamera2CameraControl();

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = MockCameraInfo();
    camera.cameraControl = mockCameraControl;

    when(mockCamera2CameraControl.addCaptureRequestOptions(any))
        .thenAnswer((_) async => Future<void>.value());

    camera.proxy = getProxyForSettingFocusandExposurePoints(
        mockCameraControl, mockCamera2CameraControl);

    // Make setting focus and metering action successful for test.
    when(mockFocusMeteringResult.isFocusSuccessful())
        .thenAnswer((_) async => Future<bool>.value(true));
    when(mockCameraControl.startFocusAndMetering(any)).thenAnswer((_) async =>
        Future<FocusMeteringResult>.value(mockFocusMeteringResult));

    // Set auto exposure mode.
    await camera.setExposureMode(cameraId, ExposureMode.auto);
    clearInteractions(mockCamera2CameraControl);

    // Lock focus point.
    await camera.setFocusMode(cameraId, FocusMode.locked);

    final VerificationResult verificationResult =
        verify(mockCamera2CameraControl.addCaptureRequestOptions(captureAny));
    final CaptureRequestOptions capturedCaptureRequestOptions =
        verificationResult.captured.single as CaptureRequestOptions;
    final List<(CaptureRequestKeySupportedType, Object?)> requestedOptions =
        capturedCaptureRequestOptions.requestedOptions;
    expect(requestedOptions.length, equals(1));
    expect(requestedOptions.first.$1,
        equals(CaptureRequestKeySupportedType.controlAeLock));
    expect(requestedOptions.first.$2, equals(false));
  });

  test(
      'setFocusPoint disables auto-cancel if auto focus mode fails to be set after locked focus mode is set',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 22;
    final MockCameraControl mockCameraControl = MockCameraControl();
    final MockFocusMeteringResult mockFocusMeteringResult =
        MockFocusMeteringResult();
    const Point<double> focusPoint = Point<double>(0.21, 0.21);

    // Set directly for test versus calling createCamera.
    camera.cameraControl = mockCameraControl;
    camera.cameraInfo = MockCameraInfo();

    camera.proxy = getProxyForSettingFocusandExposurePoints(
        mockCameraControl, MockCamera2CameraControl());

    // Make setting focus and metering action successful to set locked focus
    // mode.
    when(mockFocusMeteringResult.isFocusSuccessful())
        .thenAnswer((_) async => Future<bool>.value(true));
    when(mockCameraControl.startFocusAndMetering(any)).thenAnswer((_) async =>
        Future<FocusMeteringResult>.value(mockFocusMeteringResult));

    // Set exposure point to later mock failed call to set an exposure point (
    // otherwise, focus and metering will be canceled altogether, which is
    //considered a successful call).
    await camera.setExposurePoint(cameraId, const Point<double>(0.3, 0.4));

    // Set locked focus mode so we can set auto mode (cannot set auto mode
    // directly since it is the default).
    await camera.setFocusMode(cameraId, FocusMode.locked);
    clearInteractions(mockCameraControl);

    // Make setting focus and metering action fail to test that auto-cancel is
    // still disabled.
    reset(mockFocusMeteringResult);
    when(mockFocusMeteringResult.isFocusSuccessful())
        .thenAnswer((_) async => Future<bool>.value(false));

    // Test disabling auto cancel.
    await camera.setFocusMode(cameraId, FocusMode.auto);
    clearInteractions(mockCameraControl);

    await camera.setFocusPoint(cameraId, focusPoint);
    final VerificationResult verificationResult =
        verify(mockCameraControl.startFocusAndMetering(captureAny));
    final FocusMeteringAction capturedAction =
        verificationResult.captured.single as FocusMeteringAction;
    expect(capturedAction.disableAutoCancel, isTrue);
  });

  test(
      'setExposurePoint disables auto-cancel if auto focus mode fails to be set after locked focus mode is set',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 342;
    final MockCameraControl mockCameraControl = MockCameraControl();
    final MockFocusMeteringResult mockFocusMeteringResult =
        MockFocusMeteringResult();
    const Point<double> exposurePoint = Point<double>(0.23, 0.32);

    // Set directly for test versus calling createCamera.
    camera.cameraControl = mockCameraControl;
    camera.cameraInfo = MockCameraInfo();

    camera.proxy = getProxyForSettingFocusandExposurePoints(
        mockCameraControl, MockCamera2CameraControl());

    // Make setting focus and metering action successful to set locked focus
    // mode.
    when(mockFocusMeteringResult.isFocusSuccessful())
        .thenAnswer((_) async => Future<bool>.value(true));
    when(mockCameraControl.startFocusAndMetering(any)).thenAnswer((_) async =>
        Future<FocusMeteringResult>.value(mockFocusMeteringResult));

    // Set exposure point to later mock failed call to set an exposure point (
    // otherwise, focus and metering will be canceled altogether, which is
    //considered a successful call).
    await camera.setExposurePoint(cameraId, const Point<double>(0.4, 0.3));

    // Set locked focus mode so we can set auto mode (cannot set auto mode
    // directly since it is the default).
    await camera.setFocusMode(cameraId, FocusMode.locked);
    clearInteractions(mockCameraControl);

    // Make setting focus and metering action fail to test that auto-cancel is
    // still disabled.
    when(mockFocusMeteringResult.isFocusSuccessful())
        .thenAnswer((_) async => Future<bool>.value(false));

    // Test disabling auto cancel.
    await camera.setFocusMode(cameraId, FocusMode.auto);
    clearInteractions(mockCameraControl);

    await camera.setExposurePoint(cameraId, exposurePoint);
    final VerificationResult verificationResult =
        verify(mockCameraControl.startFocusAndMetering(captureAny));
    final FocusMeteringAction capturedAction =
        verificationResult.captured.single as FocusMeteringAction;
    expect(capturedAction.disableAutoCancel, isTrue);
  });

  test(
      'setFocusPoint enables auto-cancel if locked focus mode fails to be set after auto focus mode is set',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 232;
    final MockCameraControl mockCameraControl = MockCameraControl();
    final MockFocusMeteringResult mockFocusMeteringResult =
        MockFocusMeteringResult();
    const Point<double> focusPoint = Point<double>(0.221, 0.211);

    // Set directly for test versus calling createCamera.
    camera.cameraControl = mockCameraControl;
    camera.cameraInfo = MockCameraInfo();

    camera.proxy = getProxyForSettingFocusandExposurePoints(
        mockCameraControl, MockCamera2CameraControl());

    // Make setting focus and metering action fail to test auto-cancel is not
    // disabled.
    when(mockFocusMeteringResult.isFocusSuccessful())
        .thenAnswer((_) async => Future<bool>.value(false));
    when(mockCameraControl.startFocusAndMetering(any)).thenAnswer((_) async =>
        Future<FocusMeteringResult>.value(mockFocusMeteringResult));

    // Set exposure point to later mock failed call to set an exposure point.
    await camera.setExposurePoint(cameraId, const Point<double>(0.43, 0.34));

    // Test failing to set locked focus mode.
    await camera.setFocusMode(cameraId, FocusMode.locked);
    clearInteractions(mockCameraControl);

    await camera.setFocusPoint(cameraId, focusPoint);
    final VerificationResult verificationResult =
        verify(mockCameraControl.startFocusAndMetering(captureAny));
    final FocusMeteringAction capturedAction =
        verificationResult.captured.single as FocusMeteringAction;
    expect(capturedAction.disableAutoCancel, isFalse);
  });

  test(
      'setExposurePoint enables auto-cancel if locked focus mode fails to be set after auto focus mode is set',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 323;
    final MockCameraControl mockCameraControl = MockCameraControl();
    final MockFocusMeteringResult mockFocusMeteringResult =
        MockFocusMeteringResult();
    const Point<double> exposurePoint = Point<double>(0.223, 0.332);

    // Set directly for test versus calling createCamera.
    camera.cameraControl = mockCameraControl;
    camera.cameraInfo = MockCameraInfo();

    camera.proxy = getProxyForSettingFocusandExposurePoints(
        mockCameraControl, MockCamera2CameraControl());

    // Make setting focus and metering action fail to test auto-cancel is not
    // disabled.
    when(mockFocusMeteringResult.isFocusSuccessful())
        .thenAnswer((_) async => Future<bool>.value(false));
    when(mockCameraControl.startFocusAndMetering(any)).thenAnswer((_) async =>
        Future<FocusMeteringResult>.value(mockFocusMeteringResult));

    // Set exposure point to later mock failed call to set an exposure point.
    await camera.setExposurePoint(cameraId, const Point<double>(0.5, 0.2));

    // Test failing to set locked focus mode.
    await camera.setFocusMode(cameraId, FocusMode.locked);
    clearInteractions(mockCameraControl);

    await camera.setExposurePoint(cameraId, exposurePoint);
    final VerificationResult verificationResult =
        verify(mockCameraControl.startFocusAndMetering(captureAny));
    final FocusMeteringAction capturedAction =
        verificationResult.captured.single as FocusMeteringAction;
    expect(capturedAction.disableAutoCancel, isFalse);
  });

  test(
      'onStreamedFrameAvailable binds ImageAnalysis use case when not already bound',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 22;
    final MockImageAnalysis mockImageAnalysis = MockImageAnalysis();
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();
    final MockCamera mockCamera = MockCamera();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();

    // Set directly for test versus calling createCamera.
    camera.imageAnalysis = mockImageAnalysis;
    camera.processCameraProvider = mockProcessCameraProvider;
    camera.cameraSelector = MockCameraSelector();

    // Ignore setting target rotation for this test; tested seprately.
    camera.captureOrientationLocked = true;

    // Tell plugin to create a detached analyzer for testing purposes.
    camera.proxy = CameraXProxy(
      createAnalyzer: (_) => MockAnalyzer(),
      createCameraStateObserver: (_) => MockObserver(),
    );

    when(mockProcessCameraProvider.isBound(mockImageAnalysis))
        .thenAnswer((_) async => false);
    when(mockProcessCameraProvider.bindToLifecycle(
        any, <UseCase>[mockImageAnalysis])).thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());

    final StreamSubscription<CameraImageData> imageStreamSubscription = camera
        .onStreamedFrameAvailable(cameraId)
        .listen((CameraImageData data) {});

    await untilCalled(mockImageAnalysis.setAnalyzer(any));
    verify(mockProcessCameraProvider
        .bindToLifecycle(camera.cameraSelector, <UseCase>[mockImageAnalysis]));

    await imageStreamSubscription.cancel();
  });

  test(
      'startVideoCapturing unbinds ImageAnalysis use case when camera device is not at least level 3, no image streaming callback is specified, and preview is not paused',
      () async {
    // Set up mocks and constants.
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockPendingRecording mockPendingRecording = MockPendingRecording();
    final MockRecording mockRecording = MockRecording();
    final MockCamera mockCamera = MockCamera();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final MockCamera2CameraInfo mockCamera2CameraInfo = MockCamera2CameraInfo();
    final TestSystemServicesHostApi mockSystemServicesApi =
        MockTestSystemServicesHostApi();
    TestSystemServicesHostApi.setup(mockSystemServicesApi);

    // Set directly for test versus calling createCamera.
    camera.processCameraProvider = MockProcessCameraProvider();
    camera.recorder = MockRecorder();
    camera.videoCapture = MockVideoCapture();
    camera.cameraSelector = MockCameraSelector();
    camera.cameraInfo = MockCameraInfo();
    camera.imageAnalysis = MockImageAnalysis();

    // Ignore setting target rotation for this test; tested seprately.
    camera.captureOrientationLocked = true;

    // Tell plugin to create detached Observer when camera info updated.
    camera.proxy = CameraXProxy(
        createCameraStateObserver: (void Function(Object) onChanged) =>
            Observer<CameraState>.detached(onChanged: onChanged),
        getCamera2CameraInfo: (CameraInfo cameraInfo) =>
            Future<Camera2CameraInfo>.value(mockCamera2CameraInfo));

    const int cameraId = 7;
    const String outputPath = '/temp/REC123.temp';

    // Mock method calls.
    when(mockSystemServicesApi.getTempFilePath(camera.videoPrefix, '.temp'))
        .thenReturn(outputPath);
    when(camera.recorder!.prepareRecording(outputPath))
        .thenAnswer((_) async => mockPendingRecording);
    when(mockPendingRecording.start()).thenAnswer((_) async => mockRecording);
    when(camera.processCameraProvider!.isBound(camera.videoCapture!))
        .thenAnswer((_) async => false);
    when(camera.processCameraProvider!.isBound(camera.imageAnalysis!))
        .thenAnswer((_) async => true);
    when(camera.processCameraProvider!.bindToLifecycle(
            camera.cameraSelector!, <UseCase>[camera.videoCapture!]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo())
        .thenAnswer((_) => Future<CameraInfo>.value(mockCameraInfo));
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());
    when(mockCamera2CameraInfo.getSupportedHardwareLevel())
        .thenAnswer((_) async => CameraMetadata.infoSupportedHardwareLevelFull);

    // Simulate video recording being started so startVideoRecording completes.
    PendingRecording.videoRecordingEventStreamController
        .add(VideoRecordEvent.start);

    await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));

    verify(
        camera.processCameraProvider!.unbind(<UseCase>[camera.imageAnalysis!]));
  });

  test(
      'startVideoCapturing unbinds ImageAnalysis use case when image streaming callback not specified, camera device is level 3, and preview is not paused',
      () async {
    // Set up mocks and constants.
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockPendingRecording mockPendingRecording = MockPendingRecording();
    final MockRecording mockRecording = MockRecording();
    final MockCamera mockCamera = MockCamera();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final MockCamera2CameraInfo mockCamera2CameraInfo = MockCamera2CameraInfo();
    final TestSystemServicesHostApi mockSystemServicesApi =
        MockTestSystemServicesHostApi();
    TestSystemServicesHostApi.setup(mockSystemServicesApi);

    // Set directly for test versus calling createCamera.
    camera.processCameraProvider = MockProcessCameraProvider();
    camera.recorder = MockRecorder();
    camera.videoCapture = MockVideoCapture();
    camera.cameraSelector = MockCameraSelector();
    camera.cameraInfo = MockCameraInfo();
    camera.imageAnalysis = MockImageAnalysis();

    // Ignore setting target rotation for this test; tested seprately.
    camera.captureOrientationLocked = true;

    // Tell plugin to create detached Observer when camera info updated.
    camera.proxy = CameraXProxy(
        createCameraStateObserver: (void Function(Object) onChanged) =>
            Observer<CameraState>.detached(onChanged: onChanged),
        getCamera2CameraInfo: (CameraInfo cameraInfo) =>
            Future<Camera2CameraInfo>.value(mockCamera2CameraInfo));

    const int cameraId = 77;
    const String outputPath = '/temp/REC123.temp';

    // Mock method calls.
    when(mockSystemServicesApi.getTempFilePath(camera.videoPrefix, '.temp'))
        .thenReturn(outputPath);
    when(camera.recorder!.prepareRecording(outputPath))
        .thenAnswer((_) async => mockPendingRecording);
    when(mockPendingRecording.start()).thenAnswer((_) async => mockRecording);
    when(camera.processCameraProvider!.isBound(camera.videoCapture!))
        .thenAnswer((_) async => false);
    when(camera.processCameraProvider!.isBound(camera.imageAnalysis!))
        .thenAnswer((_) async => true);
    when(camera.processCameraProvider!.bindToLifecycle(
            camera.cameraSelector!, <UseCase>[camera.videoCapture!]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo())
        .thenAnswer((_) => Future<CameraInfo>.value(mockCameraInfo));
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());
    when(mockCamera2CameraInfo.getSupportedHardwareLevel())
        .thenAnswer((_) async => CameraMetadata.infoSupportedHardwareLevel3);

    // Simulate video recording being started so startVideoRecording completes.
    PendingRecording.videoRecordingEventStreamController
        .add(VideoRecordEvent.start);

    await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));

    verify(
        camera.processCameraProvider!.unbind(<UseCase>[camera.imageAnalysis!]));
  });

  test(
      'startVideoCapturing unbinds ImageAnalysis use case when image streaming callback is specified, camera device is not at least level 3, and preview is not paused',
      () async {
    // Set up mocks and constants.
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockPendingRecording mockPendingRecording = MockPendingRecording();
    final MockRecording mockRecording = MockRecording();
    final MockCamera mockCamera = MockCamera();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final MockCamera2CameraInfo mockCamera2CameraInfo = MockCamera2CameraInfo();
    final TestSystemServicesHostApi mockSystemServicesApi =
        MockTestSystemServicesHostApi();
    TestSystemServicesHostApi.setup(mockSystemServicesApi);

    // Set directly for test versus calling createCamera.
    camera.processCameraProvider = MockProcessCameraProvider();
    camera.recorder = MockRecorder();
    camera.videoCapture = MockVideoCapture();
    camera.cameraSelector = MockCameraSelector();
    camera.cameraInfo = MockCameraInfo();
    camera.imageAnalysis = MockImageAnalysis();

    // Ignore setting target rotation for this test; tested seprately.
    camera.captureOrientationLocked = true;

    // Tell plugin to create detached Observer when camera info updated.
    camera.proxy = CameraXProxy(
        createCameraStateObserver: (void Function(Object) onChanged) =>
            Observer<CameraState>.detached(onChanged: onChanged),
        getCamera2CameraInfo: (CameraInfo cameraInfo) =>
            Future<Camera2CameraInfo>.value(mockCamera2CameraInfo));

    const int cameraId = 87;
    const String outputPath = '/temp/REC123.temp';

    // Mock method calls.
    when(mockSystemServicesApi.getTempFilePath(camera.videoPrefix, '.temp'))
        .thenReturn(outputPath);
    when(camera.recorder!.prepareRecording(outputPath))
        .thenAnswer((_) async => mockPendingRecording);
    when(mockPendingRecording.start()).thenAnswer((_) async => mockRecording);
    when(camera.processCameraProvider!.isBound(camera.videoCapture!))
        .thenAnswer((_) async => false);
    when(camera.processCameraProvider!.isBound(camera.imageAnalysis!))
        .thenAnswer((_) async => true);
    when(camera.processCameraProvider!.bindToLifecycle(
            camera.cameraSelector!, <UseCase>[camera.videoCapture!]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo())
        .thenAnswer((_) => Future<CameraInfo>.value(mockCameraInfo));
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());
    when(mockCamera2CameraInfo.getSupportedHardwareLevel()).thenAnswer(
        (_) async => CameraMetadata.infoSupportedHardwareLevelExternal);

    // Simulate video recording being started so startVideoRecording completes.
    PendingRecording.videoRecordingEventStreamController
        .add(VideoRecordEvent.start);

    await camera.startVideoCapturing(VideoCaptureOptions(cameraId,
        streamCallback: (CameraImageData image) {}));
    verify(
        camera.processCameraProvider!.unbind(<UseCase>[camera.imageAnalysis!]));
  });

  test(
      'startVideoCapturing unbinds ImageCapture use case when image streaming callback is specified,  camera device is at least level 3, and preview is not paused',
      () async {
    // Set up mocks and constants.
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockPendingRecording mockPendingRecording = MockPendingRecording();
    final MockRecording mockRecording = MockRecording();
    final MockCamera mockCamera = MockCamera();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final MockCamera2CameraInfo mockCamera2CameraInfo = MockCamera2CameraInfo();
    final TestSystemServicesHostApi mockSystemServicesApi =
        MockTestSystemServicesHostApi();
    TestSystemServicesHostApi.setup(mockSystemServicesApi);

    // Set directly for test versus calling createCamera.
    camera.processCameraProvider = MockProcessCameraProvider();
    camera.recorder = MockRecorder();
    camera.videoCapture = MockVideoCapture();
    camera.cameraSelector = MockCameraSelector();
    camera.cameraInfo = MockCameraInfo();
    camera.imageAnalysis = MockImageAnalysis();
    camera.imageCapture = MockImageCapture();

    // Ignore setting target rotation for this test; tested seprately.
    camera.captureOrientationLocked = true;

    // Tell plugin to create detached Observer when camera info updated.
    camera.proxy = CameraXProxy(
        createAnalyzer:
            (Future<void> Function(ImageProxy imageProxy) analyze) =>
                Analyzer.detached(analyze: analyze),
        createCameraStateObserver: (void Function(Object) onChanged) =>
            Observer<CameraState>.detached(onChanged: onChanged),
        getCamera2CameraInfo: (CameraInfo cameraInfo) =>
            Future<Camera2CameraInfo>.value(mockCamera2CameraInfo));

    const int cameraId = 107;
    const String outputPath = '/temp/REC123.temp';

    // Mock method calls.
    when(mockSystemServicesApi.getTempFilePath(camera.videoPrefix, '.temp'))
        .thenReturn(outputPath);
    when(camera.recorder!.prepareRecording(outputPath))
        .thenAnswer((_) async => mockPendingRecording);
    when(mockPendingRecording.start()).thenAnswer((_) async => mockRecording);
    when(camera.processCameraProvider!.isBound(camera.videoCapture!))
        .thenAnswer((_) async => false);
    when(camera.processCameraProvider!.isBound(camera.imageCapture!))
        .thenAnswer((_) async => true);
    when(camera.processCameraProvider!.isBound(camera.imageAnalysis!))
        .thenAnswer((_) async => true);
    when(camera.processCameraProvider!.bindToLifecycle(
            camera.cameraSelector!, <UseCase>[camera.videoCapture!]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo())
        .thenAnswer((_) => Future<CameraInfo>.value(mockCameraInfo));
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());
    when(mockCamera2CameraInfo.getSupportedHardwareLevel())
        .thenAnswer((_) async => CameraMetadata.infoSupportedHardwareLevel3);

    // Simulate video recording being started so startVideoRecording completes.
    PendingRecording.videoRecordingEventStreamController
        .add(VideoRecordEvent.start);

    await camera.startVideoCapturing(VideoCaptureOptions(cameraId,
        streamCallback: (CameraImageData image) {}));
    verify(
        camera.processCameraProvider!.unbind(<UseCase>[camera.imageCapture!]));
  });

  test(
      'startVideoCapturing does not unbind ImageCapture or ImageAnalysis use cases when preview is paused',
      () async {
    // Set up mocks and constants.
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockPendingRecording mockPendingRecording = MockPendingRecording();
    final MockRecording mockRecording = MockRecording();
    final MockCamera mockCamera = MockCamera();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final MockCamera2CameraInfo mockCamera2CameraInfo = MockCamera2CameraInfo();
    final TestSystemServicesHostApi mockSystemServicesApi =
        MockTestSystemServicesHostApi();
    TestSystemServicesHostApi.setup(mockSystemServicesApi);

    // Set directly for test versus calling createCamera.
    camera.processCameraProvider = MockProcessCameraProvider();
    camera.recorder = MockRecorder();
    camera.videoCapture = MockVideoCapture();
    camera.cameraSelector = MockCameraSelector();
    camera.cameraInfo = MockCameraInfo();
    camera.imageAnalysis = MockImageAnalysis();
    camera.imageCapture = MockImageCapture();
    camera.preview = MockPreview();

    // Ignore setting target rotation for this test; tested seprately.
    camera.captureOrientationLocked = true;

    // Tell plugin to create detached Observer when camera info updated.
    camera.proxy = CameraXProxy(
        createCameraStateObserver: (void Function(Object) onChanged) =>
            Observer<CameraState>.detached(onChanged: onChanged),
        getCamera2CameraInfo: (CameraInfo cameraInfo) =>
            Future<Camera2CameraInfo>.value(mockCamera2CameraInfo));

    const int cameraId = 97;
    const String outputPath = '/temp/REC123.temp';

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
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo())
        .thenAnswer((_) => Future<CameraInfo>.value(mockCameraInfo));
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());

    await camera.pausePreview(cameraId);

    // Simulate video recording being started so startVideoRecording completes.
    PendingRecording.videoRecordingEventStreamController
        .add(VideoRecordEvent.start);

    await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));

    verifyNever(
        camera.processCameraProvider!.unbind(<UseCase>[camera.imageCapture!]));
    verifyNever(
        camera.processCameraProvider!.unbind(<UseCase>[camera.imageAnalysis!]));
  });

  test(
      'startVideoCapturing unbinds ImageCapture and ImageAnalysis use cases when running on a legacy hardware device',
      () async {
    // Set up mocks and constants.
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockPendingRecording mockPendingRecording = MockPendingRecording();
    final MockRecording mockRecording = MockRecording();
    final MockCamera mockCamera = MockCamera();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final MockCamera2CameraInfo mockCamera2CameraInfo = MockCamera2CameraInfo();
    final TestSystemServicesHostApi mockSystemServicesApi =
        MockTestSystemServicesHostApi();
    TestSystemServicesHostApi.setup(mockSystemServicesApi);

    // Set directly for test versus calling createCamera.
    camera.processCameraProvider = MockProcessCameraProvider();
    camera.recorder = MockRecorder();
    camera.videoCapture = MockVideoCapture();
    camera.cameraSelector = MockCameraSelector();
    camera.cameraInfo = MockCameraInfo();
    camera.imageAnalysis = MockImageAnalysis();
    camera.imageCapture = MockImageCapture();
    camera.preview = MockPreview();

    // Ignore setting target rotation for this test; tested seprately.
    camera.captureOrientationLocked = true;

    // Tell plugin to create detached Observer when camera info updated.
    camera.proxy = CameraXProxy(
        createCameraStateObserver: (void Function(Object) onChanged) =>
            Observer<CameraState>.detached(onChanged: onChanged),
        getCamera2CameraInfo: (CameraInfo cameraInfo) =>
            Future<Camera2CameraInfo>.value(mockCamera2CameraInfo));

    const int cameraId = 44;
    const String outputPath = '/temp/REC123.temp';

    // Mock method calls.
    when(mockSystemServicesApi.getTempFilePath(camera.videoPrefix, '.temp'))
        .thenReturn(outputPath);
    when(camera.recorder!.prepareRecording(outputPath))
        .thenAnswer((_) async => mockPendingRecording);
    when(mockPendingRecording.start()).thenAnswer((_) async => mockRecording);
    when(camera.processCameraProvider!.isBound(camera.videoCapture!))
        .thenAnswer((_) async => false);
    when(camera.processCameraProvider!.isBound(camera.imageCapture!))
        .thenAnswer((_) async => true);
    when(camera.processCameraProvider!.isBound(camera.imageAnalysis!))
        .thenAnswer((_) async => true);
    when(camera.processCameraProvider!.bindToLifecycle(
            camera.cameraSelector!, <UseCase>[camera.videoCapture!]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo())
        .thenAnswer((_) => Future<CameraInfo>.value(mockCameraInfo));
    when(mockCameraInfo.getCameraState())
        .thenAnswer((_) async => MockLiveCameraState());
    when(mockCamera2CameraInfo.getSupportedHardwareLevel()).thenAnswer(
        (_) async => CameraMetadata.infoSupportedHardwareLevelLegacy);

    // Simulate video recording being started so startVideoRecording completes.
    PendingRecording.videoRecordingEventStreamController
        .add(VideoRecordEvent.start);

    await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));

    verify(
        camera.processCameraProvider!.unbind(<UseCase>[camera.imageCapture!]));
    verify(
        camera.processCameraProvider!.unbind(<UseCase>[camera.imageAnalysis!]));
  });

  test(
      'prepareForVideoRecording does not make any calls involving starting video recording',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();

    // Set directly for test versus calling createCamera.
    camera.processCameraProvider = MockProcessCameraProvider();
    camera.recorder = MockRecorder();
    camera.videoCapture = MockVideoCapture();
    camera.camera = MockCamera();

    await camera.prepareForVideoRecording();
    verifyNoMoreInteractions(camera.processCameraProvider);
    verifyNoMoreInteractions(camera.recorder);
    verifyNoMoreInteractions(camera.videoCapture);
    verifyNoMoreInteractions(camera.camera);
  });
}
