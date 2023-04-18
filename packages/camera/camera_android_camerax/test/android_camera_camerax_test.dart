// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:async/async.dart';
import 'package:camera_android_camerax/camera_android_camerax.dart';
import 'package:camera_android_camerax/src/camera.dart';
import 'package:camera_android_camerax/src/camera_info.dart';
import 'package:camera_android_camerax/src/camera_selector.dart';
import 'package:camera_android_camerax/src/camera_state.dart';
import 'package:camera_android_camerax/src/camera_state_error.dart';
import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/image_capture.dart';
import 'package:camera_android_camerax/src/live_data.dart';
import 'package:camera_android_camerax/src/observer.dart';
import 'package:camera_android_camerax/src/preview.dart';
import 'package:camera_android_camerax/src/process_camera_provider.dart';
import 'package:camera_android_camerax/src/system_services.dart';
import 'package:camera_android_camerax/src/use_case.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'android_camera_camerax_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<Camera>(),
  MockSpec<CameraInfo>(),
  MockSpec<CameraSelector>(),
  MockSpec<ImageCapture>(),
  MockSpec<LiveData<CameraState>>(),
  MockSpec<Preview>(),
  MockSpec<ProcessCameraProvider>(),
  MockSpec<TestInstanceManagerHostApi>(),
])
@GenerateMocks(<Type>[BuildContext])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Mocks the call to clear the native InstanceManager.

  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  Future<bool> testCameraClosingObserver(AndroidCameraCameraX camera,
      int cameraId, Observer<dynamic> observer) async {
    const String testErrorDescription = 'Test error description';
    final Stream<CameraClosingEvent> cameraClosingEventStream =
        camera.onCameraClosing(cameraId);
    final StreamQueue<CameraClosingEvent> cameraClosingStreamQueue =
        StreamQueue<CameraClosingEvent>(cameraClosingEventStream);
    final Stream<CameraErrorEvent> cameraErrorEventStream =
        camera.onCameraError(cameraId);
    final StreamQueue<CameraErrorEvent> cameraErrorStreamQueue =
        StreamQueue<CameraErrorEvent>(cameraErrorEventStream);

    observer.onChanged(CameraState.detached(
        type: CameraStateType.closing,
        error: CameraStateError.detached(
            code: 0, description: testErrorDescription)));

    final bool cameraClosingEventSent =
        await cameraClosingStreamQueue.next == CameraClosingEvent(cameraId);
    final bool cameraErrorSent = await cameraErrorStreamQueue.next ==
        CameraErrorEvent(cameraId, testErrorDescription);

    await cameraClosingStreamQueue.cancel();
    await cameraErrorStreamQueue.cancel();

    return cameraClosingEventSent && cameraErrorSent;
  }

  test('Should fetch CameraDescription instances for available cameras',
      () async {
    // Arrange
    final MockAndroidCameraCamerax camera = MockAndroidCameraCamerax();
    camera.processCameraProvider = MockProcessCameraProvider();
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
    final MockCameraInfo mockFrontCameraInfo = MockCameraInfo();
    final MockCameraInfo mockBackCameraInfo = MockCameraInfo();

    // Mock calls to native platform
    when(camera.processCameraProvider!.getAvailableCameraInfos()).thenAnswer(
        (_) async => <MockCameraInfo>[mockBackCameraInfo, mockFrontCameraInfo]);
    when(camera.mockBackCameraSelector
            .filter(<MockCameraInfo>[mockFrontCameraInfo]))
        .thenAnswer((_) async => <MockCameraInfo>[]);
    when(camera.mockBackCameraSelector
            .filter(<MockCameraInfo>[mockBackCameraInfo]))
        .thenAnswer((_) async => <MockCameraInfo>[mockBackCameraInfo]);
    when(camera.mockFrontCameraSelector
            .filter(<MockCameraInfo>[mockBackCameraInfo]))
        .thenAnswer((_) async => <MockCameraInfo>[]);
    when(camera.mockFrontCameraSelector
            .filter(<MockCameraInfo>[mockFrontCameraInfo]))
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
    final MockAndroidCameraCamerax camera = MockAndroidCameraCamerax();
    final MockProcessCameraProvider processCameraProvider =
        MockProcessCameraProvider();
    const CameraLensDirection testLensDirection = CameraLensDirection.back;
    const int testSensorOrientation = 90;
    const CameraDescription testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation);
    const ResolutionPreset testResolutionPreset = ResolutionPreset.veryHigh;
    const bool enableAudio = true;
    const int testSurfaceTextureId = 6;
    final MockCamera mockCamera = MockCamera();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final MockLiveData mockLiveCameraState = MockLiveData();

    when(camera.testPreview.setSurfaceProvider())
        .thenAnswer((_) async => testSurfaceTextureId);
    when(processCameraProvider.bindToLifecycle(camera.mockBackCameraSelector,
            <UseCase>[camera.testPreview, camera.testImageCapture]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getLiveCameraState())
        .thenAnswer((_) async => mockLiveCameraState);
    camera.processCameraProvider = processCameraProvider;
    camera.createDetachedObservers = true;

    expect(
        await camera.createCamera(testCameraDescription, testResolutionPreset,
            enableAudio: enableAudio),
        equals(testSurfaceTextureId));

    // Verify permissions are requested and the camera starts listening for device orientation changes.
    expect(camera.cameraPermissionsRequested, isTrue);
    expect(camera.startedListeningForDeviceOrientationChanges, isTrue);

    // Verify CameraSelector is set with appropriate lens direction.
    expect(camera.cameraSelector, equals(camera.mockBackCameraSelector));

    // Verify the camera's Preview instance is instantiated properly.
    expect(camera.preview, equals(camera.testPreview));

    // Verify the camera's ImageCapture instance is instantiated properly.
    expect(camera.imageCapture, equals(camera.testImageCapture));

    // Verify the camera's Preview instance has its surface provider set.
    verify(camera.preview!.setSurfaceProvider());

    // Verify the camera state observer is updated.
    // expect(
    //     await testCameraClosingObserver(
    //         camera,
    //         testSurfaceTextureId,
    //         verify(mockLiveCameraState.observe(captureAny)).captured.single
    //             as Observer),
    //     isTrue);
  });

  test(
      'createCamera binds Preview and ImageCapture use cases to ProcessCameraProvider instance',
      () async {
    final MockAndroidCameraCamerax camera = MockAndroidCameraCamerax();
    final ProcessCameraProvider processCameraProvider =
        MockProcessCameraProvider();
    const CameraLensDirection testLensDirection = CameraLensDirection.back;
    const int testSensorOrientation = 90;
    const CameraDescription testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation);
    const ResolutionPreset testResolutionPreset = ResolutionPreset.veryHigh;
    const bool enableAudio = true;
    final MockCamera mockCamera = MockCamera();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();

    when(processCameraProvider.bindToLifecycle(camera.mockBackCameraSelector,
            <UseCase>[camera.testPreview, camera.testImageCapture]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getLiveCameraState())
        .thenAnswer((_) async => MockLiveData());
    camera.processCameraProvider = processCameraProvider;
    camera.createDetachedObservers = true;

    await camera.createCamera(testCameraDescription, testResolutionPreset,
        enableAudio: enableAudio);

    verify(camera.processCameraProvider!.bindToLifecycle(camera.cameraSelector!,
        <UseCase>[camera.testPreview, camera.testImageCapture]));
  });

  test(
      'initializeCamera throws AssertionError when createCamera has not been called before initializedCamera',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    expect(() => camera.initializeCamera(3), throwsAssertionError);
  });

  test('initializeCamera sends expected CameraInitializedEvent', () async {
    final MockAndroidCameraCamerax camera = MockAndroidCameraCamerax();
    camera.processCameraProvider = MockProcessCameraProvider();
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
    final CameraInfo mockCameraInfo = MockCameraInfo();

    // TODO(camsim99): Modify this when camera configuration is supported and
    // defualt values no longer being used.
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
    when(camera.testPreview.setSurfaceProvider())
        .thenAnswer((_) async => cameraId);

    when(camera.processCameraProvider!.bindToLifecycle(
            camera.mockBackCameraSelector,
            <UseCase>[camera.testPreview, camera.testImageCapture]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getLiveCameraState())
        .thenAnswer((_) async => MockLiveData());
    camera.createDetachedObservers = true;

    await camera.createCamera(testCameraDescription, testResolutionPreset,
        enableAudio: enableAudio);

    when(camera.processCameraProvider!.bindToLifecycle(camera.cameraSelector!,
            <UseCase>[camera.testPreview, camera.testImageCapture]))
        .thenAnswer((_) async => mockCamera);
    when(camera.testPreview.getResolutionInfo())
        .thenAnswer((_) async => testResolutionInfo);

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
    camera.liveCameraState = MockLiveData();

    camera.dispose(3);

    verify(camera.preview!.releaseFlutterSurfaceTexture());
    verify(camera.liveCameraState!.removeObservers());
    verify(camera.processCameraProvider!.unbindAll());
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
    final MockLiveData mockLiveCameraState = MockLiveData();

    camera.processCameraProvider = mockProcessCameraProvider;
    camera.cameraSelector = MockCameraSelector();
    camera.preview = MockPreview();

    when(camera.processCameraProvider!.isBound(camera.preview!))
        .thenAnswer((_) async => true);

    when(mockProcessCameraProvider
            .bindToLifecycle(camera.cameraSelector, <UseCase>[camera.preview!]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getLiveCameraState())
        .thenAnswer((_) async => mockLiveCameraState);

    await camera.resumePreview(78);

    verifyNever(camera.processCameraProvider!
        .bindToLifecycle(camera.cameraSelector!, <UseCase>[camera.preview!]));
    verifyNever(mockLiveCameraState.observe(any));
  });

  test(
      'resumePreview binds preview to lifecycle and updates camera state observers if not already bound',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();
    final MockCamera mockCamera = MockCamera();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final MockLiveData mockLiveCameraState = MockLiveData();

    camera.processCameraProvider = mockProcessCameraProvider;
    camera.cameraSelector = MockCameraSelector();
    camera.preview = MockPreview();
    camera.createDetachedObservers = true;

    when(mockProcessCameraProvider
            .bindToLifecycle(camera.cameraSelector, <UseCase>[camera.preview!]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getLiveCameraState())
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

    camera.processCameraProvider = mockProcessCameraProvider;
    camera.cameraSelector = MockCameraSelector();
    camera.preview = MockPreview();
    camera.createDetachedObservers = true;

    when(mockProcessCameraProvider
            .bindToLifecycle(camera.cameraSelector, <UseCase>[camera.preview!]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getLiveCameraState())
        .thenAnswer((_) async => MockLiveData());

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

    camera.processCameraProvider = mockProcessCameraProvider;
    camera.cameraSelector = MockCameraSelector();
    camera.preview = MockPreview();
    camera.createDetachedObservers = true;

    when(mockProcessCameraProvider
            .bindToLifecycle(camera.cameraSelector, <UseCase>[camera.preview!]))
        .thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(mockCameraInfo.getLiveCameraState())
        .thenAnswer((_) async => MockLiveData());

    final FutureBuilder<void> previewWidget =
        camera.buildPreview(textureId) as FutureBuilder<void>;

    final Texture previewTexture = previewWidget.builder(MockBuildContext(),
            const AsyncSnapshot<void>.withData(ConnectionState.done, null))
        as Texture;
    expect(previewTexture.textureId, equals(textureId));
  });

  test(
      'takePicture binds and unbinds ImageCapture to lifecycle and makes call to take a picture',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const String testPicturePath = 'test/absolute/path/to/picture';

    camera.processCameraProvider = MockProcessCameraProvider();
    camera.cameraSelector = MockCameraSelector();
    camera.imageCapture = MockImageCapture();

    when(camera.imageCapture!.takePicture())
        .thenAnswer((_) async => testPicturePath);

    final XFile imageFile = await camera.takePicture(3);

    expect(imageFile.path, equals(testPicturePath));
  });
}

/// Mock of [AndroidCameraCameraX] that stubs behavior of some methods for
/// testing.
class MockAndroidCameraCamerax extends AndroidCameraCameraX {
  bool cameraPermissionsRequested = false;
  bool startedListeningForDeviceOrientationChanges = false;
  final MockPreview testPreview = MockPreview();
  final MockImageCapture testImageCapture = MockImageCapture();
  final MockCameraSelector mockBackCameraSelector = MockCameraSelector();
  final MockCameraSelector mockFrontCameraSelector = MockCameraSelector();

  @override
  Future<void> requestCameraPermissions(bool enableAudio) async {
    cameraPermissionsRequested = true;
  }

  @override
  void startListeningForDeviceOrientationChange(
      bool cameraIsFrontFacing, int sensorOrientation) {
    startedListeningForDeviceOrientationChanges = true;
    return;
  }

  @override
  CameraSelector createCameraSelector(int cameraSelectorLensDirection) {
    switch (cameraSelectorLensDirection) {
      case CameraSelector.lensFacingFront:
        return mockFrontCameraSelector;
      case CameraSelector.lensFacingBack:
      default:
        return mockBackCameraSelector;
    }
  }

  @override
  Preview createPreview(int targetRotation, ResolutionInfo? targetResolution) {
    return testPreview;
  }

  @override
  ImageCapture createImageCapture(
      int? flashMode, ResolutionInfo? targetResolution) {
    return testImageCapture;
  }
}
