// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' show Point;

import 'package:async/async.dart';
import 'package:camera_android_camerax/camera_android_camerax.dart';
import 'package:camera_android_camerax/src/camerax_library.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart'
    show DeviceOrientation, PlatformException, Uint8List;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'android_camera_camerax_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<Analyzer>(),
  MockSpec<AspectRatioStrategy>(),
  MockSpec<Camera>(),
  MockSpec<CameraInfo>(),
  MockSpec<CameraCharacteristicsKey>(),
  MockSpec<CameraControl>(),
  MockSpec<CameraSize>(),
  MockSpec<Camera2CameraControl>(),
  MockSpec<Camera2CameraInfo>(),
  MockSpec<CameraImageData>(),
  MockSpec<CameraSelector>(),
  MockSpec<CaptureRequestOptions>(),
  MockSpec<DeviceOrientationManager>(),
  MockSpec<DisplayOrientedMeteringPointFactory>(),
  MockSpec<ExposureState>(),
  MockSpec<FallbackStrategy>(),
  MockSpec<FocusMeteringActionBuilder>(),
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
  MockSpec<SystemServicesManager>(),
  MockSpec<VideoCapture>(),
  MockSpec<ZoomState>(),
])
@GenerateMocks(
  <Type>[],
  customMocks: <MockSpec<Object>>[
    MockSpec<LiveData<CameraState>>(as: #MockLiveCameraState),
    MockSpec<LiveData<ZoomState>>(as: #MockLiveZoomState),
  ],
)
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PigeonOverrides.pigeon_reset();
    GenericsPigeonOverrides.reset();
  });

  /// Helper method for testing sending/receiving CameraErrorEvents.
  Future<bool> testCameraClosingObserver(
    AndroidCameraCameraX camera,
    int cameraId,
    Observer<dynamic> observer,
  ) async {
    final testCameraStateError = CameraStateStateError.pigeon_detached(
      code: CameraStateErrorCode.doNotDisturbModeEnabled,
    );
    final Stream<CameraClosingEvent> cameraClosingEventStream = camera
        .onCameraClosing(cameraId);
    final cameraClosingStreamQueue = StreamQueue<CameraClosingEvent>(
      cameraClosingEventStream,
    );
    final Stream<CameraErrorEvent> cameraErrorEventStream = camera
        .onCameraError(cameraId);
    final cameraErrorStreamQueue = StreamQueue<CameraErrorEvent>(
      cameraErrorEventStream,
    );

    observer.onChanged(
      observer,
      CameraState.pigeon_detached(
        type: CameraStateType.closing,
        error: testCameraStateError,
      ),
    );

    final cameraClosingEventSent =
        await cameraClosingStreamQueue.next == CameraClosingEvent(cameraId);
    final cameraErrorSent =
        await cameraErrorStreamQueue.next ==
        CameraErrorEvent(
          cameraId,
          'The camera could not be opened because "Do Not Disturb" mode is enabled. Please disable this mode, and try opening the camera again.',
        );

    await cameraClosingStreamQueue.cancel();
    await cameraErrorStreamQueue.cancel();

    return cameraClosingEventSent && cameraErrorSent;
  }

  /// Set up testing functionality related to the configuration
  /// of CameraX UseCases.
  void setUpOverridesForTestingUseCaseConfiguration(
    MockProcessCameraProvider mockProcessCameraProvider, {
    ResolutionFilter Function({required CameraSize preferredSize})?
    createWithOnePreferredSizeResolutionFilter,
    FallbackStrategy Function({required VideoQuality quality})?
    lowerQualityOrHigherThanFallbackStrategy,
    QualitySelector Function({
      required VideoQuality quality,
      FallbackStrategy? fallbackStrategy,
    })?
    fromQualitySelector,
    Preview Function({
      int? targetRotation,
      CameraIntegerRange? targetFpsRange,
      ResolutionSelector? resolutionSelector,
    })?
    newPreview,
    VideoCapture Function({
      required VideoOutput videoOutput,
      CameraIntegerRange? targetFpsRange,
    })?
    withOutputVideoCapture,
    ImageAnalysis Function({
      ResolutionSelector? resolutionSelector,
      int? outputImageFormat,
      int? targetRotation,
      CameraIntegerRange? targetFpsRange,
    })?
    newImageAnalysis,
    Analyzer Function({required void Function(Analyzer, ImageProxy) analyze})?
    newAnalyzer,
    Future<Uint8List> Function(
      int imageWidth,
      int imageHeight,
      List<PlaneProxy> planes,
    )?
    getNv21BufferImageProxyUtils,
  }) {
    final AspectRatioStrategy ratio_4_3FallbackAutoStrategyAspectRatioStrategy =
        MockAspectRatioStrategy();
    final ResolutionStrategy highestAvailableStrategyResolutionStrategy =
        MockResolutionStrategy();
    PigeonOverrides.processCameraProvider_getInstance = () async {
      return mockProcessCameraProvider;
    };
    PigeonOverrides.cameraSelector_new =
        ({LensFacing? requireLensFacing, dynamic cameraInfoForFilter}) {
          switch (requireLensFacing) {
            case LensFacing.front:
              return MockCameraSelector();
            case LensFacing.back:
            case LensFacing.external:
            case LensFacing.unknown:
            case null:
          }

          return MockCameraSelector();
        };
    PigeonOverrides.preview_new =
        newPreview ??
        ({
          int? targetRotation,
          CameraIntegerRange? targetFpsRange,
          ResolutionSelector? resolutionSelector,
        }) {
          final mockPreview = MockPreview();
          final testResolutionInfo = ResolutionInfo.pigeon_detached(
            resolution: MockCameraSize(),
          );
          when(
            mockPreview.surfaceProducerHandlesCropAndRotation(),
          ).thenAnswer((_) async => false);
          when(mockPreview.resolutionSelector).thenReturn(resolutionSelector);
          when(
            mockPreview.getResolutionInfo(),
          ).thenAnswer((_) async => testResolutionInfo);
          return mockPreview;
        };
    PigeonOverrides.imageCapture_new =
        ({
          int? targetRotation,
          CameraXFlashMode? flashMode,
          ResolutionSelector? resolutionSelector,
        }) {
          final mockImageCapture = MockImageCapture();
          when(
            mockImageCapture.resolutionSelector,
          ).thenReturn(resolutionSelector);
          return mockImageCapture;
        };
    PigeonOverrides.recorder_new =
        ({
          int? aspectRatio,
          int? targetVideoEncodingBitRate,
          QualitySelector? qualitySelector,
        }) {
          final mockRecorder = MockRecorder();
          when(
            mockRecorder.getQualitySelector(),
          ).thenAnswer((_) async => qualitySelector ?? MockQualitySelector());
          return mockRecorder;
        };
    PigeonOverrides.videoCapture_withOutput =
        withOutputVideoCapture ??
        ({
          required VideoOutput videoOutput,
          CameraIntegerRange? targetFpsRange,
        }) {
          return MockVideoCapture();
        };
    PigeonOverrides.imageAnalysis_new =
        newImageAnalysis ??
        ({
          int? targetRotation,
          CameraIntegerRange? targetFpsRange,
          int? outputImageFormat,
          ResolutionSelector? resolutionSelector,
        }) {
          final mockImageAnalysis = MockImageAnalysis();
          when(
            mockImageAnalysis.resolutionSelector,
          ).thenReturn(resolutionSelector);
          return mockImageAnalysis;
        };
    PigeonOverrides.resolutionStrategy_new =
        ({
          required CameraSize boundSize,
          required ResolutionStrategyFallbackRule fallbackRule,
        }) {
          final resolutionStrategy = MockResolutionStrategy();
          when(
            resolutionStrategy.getBoundSize(),
          ).thenAnswer((_) async => boundSize);
          when(
            resolutionStrategy.getFallbackRule(),
          ).thenAnswer((_) async => fallbackRule);
          return resolutionStrategy;
        };
    PigeonOverrides.resolutionSelector_new =
        ({
          AspectRatioStrategy? aspectRatioStrategy,
          ResolutionStrategy? resolutionStrategy,
          ResolutionFilter? resolutionFilter,
        }) {
          final mockResolutionSelector = MockResolutionSelector();
          when(mockResolutionSelector.getAspectRatioStrategy()).thenAnswer(
            (_) async =>
                aspectRatioStrategy ??
                AspectRatioStrategy.ratio_4_3FallbackAutoStrategy,
          );
          when(
            mockResolutionSelector.resolutionStrategy,
          ).thenReturn(resolutionStrategy);
          when(
            mockResolutionSelector.resolutionFilter,
          ).thenReturn(resolutionFilter);
          return mockResolutionSelector;
        };
    PigeonOverrides.qualitySelector_from =
        fromQualitySelector ??
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
        }) {
          final manager = MockDeviceOrientationManager();
          when(manager.getUiOrientation()).thenAnswer((_) async {
            return 'PORTRAIT_UP';
          });
          return manager;
        };
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
        createWithOnePreferredSizeResolutionFilter ??
        ({required CameraSize preferredSize}) => MockResolutionFilter();
    PigeonOverrides.camera2CameraInfo_from = ({required dynamic cameraInfo}) {
      final camera2cameraInfo = MockCamera2CameraInfo();
      when(
        camera2cameraInfo.getCameraCharacteristic(any),
      ).thenAnswer((_) async => 90);
      return camera2cameraInfo;
    };
    PigeonOverrides.cameraSize_new =
        ({required int width, required int height}) {
          return CameraSize.pigeon_detached(width: width, height: height);
        };
    PigeonOverrides.cameraCharacteristics_sensorOrientation =
        MockCameraCharacteristicsKey();
    PigeonOverrides.fallbackStrategy_lowerQualityOrHigherThan =
        lowerQualityOrHigherThanFallbackStrategy ??
        ({required VideoQuality quality}) {
          return MockFallbackStrategy();
        };
    PigeonOverrides.resolutionStrategy_highestAvailableStrategy =
        highestAvailableStrategyResolutionStrategy;
    PigeonOverrides.aspectRatioStrategy_ratio_4_3FallbackAutoStrategy =
        ratio_4_3FallbackAutoStrategyAspectRatioStrategy;
    PigeonOverrides.fallbackStrategy_lowerQualityThan =
        ({required VideoQuality quality}) {
          return MockFallbackStrategy();
        };
    PigeonOverrides.analyzer_new =
        newAnalyzer ??
        ({required void Function(Analyzer, ImageProxy) analyze}) {
          return MockAnalyzer();
        };
    PigeonOverrides.imageProxyUtils_getNv21Buffer =
        getNv21BufferImageProxyUtils ??
        (int imageWidth, int imageHeight, List<PlaneProxy> planes) {
          return Future<Uint8List>.value(Uint8List(0));
        };
  }

  /// Set up overrides for testing exposure and focus related controls.
  ///
  /// Modifies the creation of [MeteringPoint]s and [FocusMeteringAction]s to
  /// return objects detached from a native object.
  void setUpOverridesForExposureAndFocus({
    FocusMeteringActionBuilder Function({
      required MeteringPoint point,
      required MeteringMode mode,
    })?
    withModeFocusMeteringActionBuilder,
    DisplayOrientedMeteringPointFactory Function({
      required dynamic cameraInfo,
      required double width,
      required double height,
    })?
    newDisplayOrientedMeteringPointFactory,
  }) {
    PigeonOverrides.displayOrientedMeteringPointFactory_new =
        newDisplayOrientedMeteringPointFactory ??
        ({
          required dynamic cameraInfo,
          required double width,
          required double height,
        }) {
          final mockFactory = MockDisplayOrientedMeteringPointFactory();
          when(mockFactory.createPoint(any, any)).thenAnswer(
            (Invocation invocation) async => TestMeteringPoint.detached(
              x: invocation.positionalArguments[0]! as double,
              y: invocation.positionalArguments[1]! as double,
            ),
          );
          when(mockFactory.createPointWithSize(any, any, any)).thenAnswer(
            (Invocation invocation) async => TestMeteringPoint.detached(
              x: invocation.positionalArguments[0]! as double,
              y: invocation.positionalArguments[1]! as double,
              size: invocation.positionalArguments[2]! as double,
            ),
          );
          return mockFactory;
        };
    PigeonOverrides.focusMeteringActionBuilder_withMode =
        withModeFocusMeteringActionBuilder ??
        ({required MeteringPoint point, required MeteringMode mode}) {
          final mockBuilder = MockFocusMeteringActionBuilder();
          var disableAutoCancelCalled = false;
          when(mockBuilder.disableAutoCancel()).thenAnswer((_) async {
            disableAutoCancelCalled = true;
          });
          final meteringPointsAe = <MeteringPoint>[];
          final meteringPointsAf = <MeteringPoint>[];
          final meteringPointsAwb = <MeteringPoint>[];

          switch (mode) {
            case MeteringMode.ae:
              meteringPointsAe.add(point);
            case MeteringMode.af:
              meteringPointsAf.add(point);
            case MeteringMode.awb:
              meteringPointsAwb.add(point);
          }

          when(mockBuilder.addPointWithMode(any, any)).thenAnswer((
            Invocation invocation,
          ) async {
            switch (invocation.positionalArguments[1]) {
              case MeteringMode.ae:
                meteringPointsAe.add(
                  invocation.positionalArguments.first as MeteringPoint,
                );
              case MeteringMode.af:
                meteringPointsAf.add(
                  invocation.positionalArguments.first as MeteringPoint,
                );
              case MeteringMode.awb:
                meteringPointsAwb.add(
                  invocation.positionalArguments.first as MeteringPoint,
                );
            }
          });

          when(mockBuilder.build()).thenAnswer(
            (_) async => FocusMeteringAction.pigeon_detached(
              meteringPointsAe: meteringPointsAe,
              meteringPointsAf: meteringPointsAf,
              meteringPointsAwb: meteringPointsAwb,
              isAutoCancelEnabled: !disableAutoCancelCalled,
            ),
          );
          return mockBuilder;
        };
  }

  /// Set up overrides for testing setting focus and exposure points.
  ///
  /// Modifies the retrieval of a [Camera2CameraControl] instance to depend on
  /// interaction with expected [cameraControl] instance and modifies creation
  /// of [CaptureRequestOptions] to return objects detached from a native object.
  void setUpOverridesForSettingFocusandExposurePoints(
    CameraControl cameraControlForComparison,
    Camera2CameraControl camera2cameraControl, {
    FocusMeteringActionBuilder Function({
      required MeteringPoint point,
      required MeteringMode mode,
    })?
    withModeFocusMeteringActionBuilder,
    DisplayOrientedMeteringPointFactory Function({
      required dynamic cameraInfo,
      required double width,
      required double height,
    })?
    newDisplayOrientedMeteringPointFactory,
  }) {
    setUpOverridesForExposureAndFocus();

    if (withModeFocusMeteringActionBuilder != null) {
      PigeonOverrides.focusMeteringActionBuilder_withMode =
          withModeFocusMeteringActionBuilder;
    }
    if (newDisplayOrientedMeteringPointFactory != null) {
      PigeonOverrides.displayOrientedMeteringPointFactory_new =
          newDisplayOrientedMeteringPointFactory;
    }

    PigeonOverrides.camera2CameraControl_from =
        ({required CameraControl cameraControl}) =>
            cameraControl == cameraControlForComparison
            ? camera2cameraControl
            : Camera2CameraControl.pigeon_detached();

    PigeonOverrides.captureRequestOptions_new =
        ({required Map<CaptureRequestKey, Object?> options}) {
          final mockCaptureRequestOptions = MockCaptureRequestOptions();
          options.forEach((CaptureRequestKey key, Object? value) {
            when(
              mockCaptureRequestOptions.getCaptureRequestOption(key),
            ).thenAnswer((_) async => value);
          });
          return mockCaptureRequestOptions;
        };
    PigeonOverrides.captureRequest_controlAELock =
        CaptureRequestKey.pigeon_detached();
  }

  test(
    'Should fetch CameraDescription instances for available cameras',
    () async {
      // Arrange
      final camera = AndroidCameraCameraX();
      final returnData = <dynamic>[
        <String, dynamic>{
          'name': 'Camera 0',
          'lensFacing': 'back',
          'sensorOrientation': 0,
        },
        <String, dynamic>{
          'name': 'Camera 1',
          'lensFacing': 'front',
          'sensorOrientation': 90,
        },
      ];

      // Create mocks to use
      final mockProcessCameraProvider = MockProcessCameraProvider();
      final mockFrontCameraSelector = MockCameraSelector();
      final mockBackCameraSelector = MockCameraSelector();
      final mockFrontCameraInfo = MockCameraInfo();
      final mockBackCameraInfo = MockCameraInfo();

      // Tell plugin to create mock CameraSelectors for testing.
      PigeonOverrides.processCameraProvider_getInstance = () async =>
          mockProcessCameraProvider;
      PigeonOverrides.cameraSelector_new =
          ({LensFacing? requireLensFacing, dynamic cameraInfoForFilter}) {
            switch (requireLensFacing) {
              case LensFacing.front:
                return mockFrontCameraSelector;
              case LensFacing.back:
              case LensFacing.external:
              case LensFacing.unknown:
              case null:
            }

            return mockBackCameraSelector;
          };
      PigeonOverrides.systemServicesManager_new =
          ({
            required void Function(SystemServicesManager, String) onCameraError,
          }) {
            return MockSystemServicesManager();
          };

      // Mock calls to native platform
      when(mockProcessCameraProvider.getAvailableCameraInfos()).thenAnswer(
        (_) async => <MockCameraInfo>[mockBackCameraInfo, mockFrontCameraInfo],
      );
      when(
        mockBackCameraSelector.filter(<MockCameraInfo>[mockFrontCameraInfo]),
      ).thenAnswer((_) async => <MockCameraInfo>[]);
      when(
        mockBackCameraSelector.filter(<MockCameraInfo>[mockBackCameraInfo]),
      ).thenAnswer((_) async => <MockCameraInfo>[mockBackCameraInfo]);
      when(
        mockFrontCameraSelector.filter(<MockCameraInfo>[mockBackCameraInfo]),
      ).thenAnswer((_) async => <MockCameraInfo>[]);
      when(
        mockFrontCameraSelector.filter(<MockCameraInfo>[mockFrontCameraInfo]),
      ).thenAnswer((_) async => <MockCameraInfo>[mockFrontCameraInfo]);
      when(mockBackCameraInfo.sensorRotationDegrees).thenReturn(0);
      when(mockFrontCameraInfo.sensorRotationDegrees).thenReturn(90);

      final List<CameraDescription> cameraDescriptions = await camera
          .availableCameras();

      expect(cameraDescriptions.length, returnData.length);
      for (var i = 0; i < returnData.length; i++) {
        final Map<String, Object?> typedData =
            (returnData[i] as Map<dynamic, dynamic>).cast<String, Object?>();
        final cameraDescription = CameraDescription(
          name: typedData['name']! as String,
          lensDirection: (typedData['lensFacing']! as String) == 'front'
              ? CameraLensDirection.front
              : CameraLensDirection.back,
          sensorOrientation: typedData['sensorOrientation']! as int,
        );
        expect(cameraDescriptions[i], cameraDescription);
      }
    },
  );

  test(
    'createCamera requests permissions, starts listening for device orientation changes, updates camera state observers, and returns flutter surface texture ID',
    () async {
      final camera = AndroidCameraCameraX();
      const CameraLensDirection testLensDirection = CameraLensDirection.back;
      const testSensorOrientation = 90;
      const testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation,
      );

      const testSurfaceTextureId = 6;

      // Mock/Detached objects for (typically attached) objects created by
      // createCamera.
      final mockProcessCameraProvider = MockProcessCameraProvider();
      final mockPreview = MockPreview();
      final mockBackCameraSelector = MockCameraSelector();
      final mockImageCapture = MockImageCapture();
      final mockImageAnalysis = MockImageAnalysis();
      final mockRecorder = MockRecorder();
      final mockVideoCapture = MockVideoCapture();
      final mockCamera = MockCamera();
      final mockCameraInfo = MockCameraInfo();
      final mockLiveCameraState = MockLiveCameraState();
      final mockSystemServicesManager = MockSystemServicesManager();
      final mockCameraCharacteristicsKey = MockCameraCharacteristicsKey();

      var cameraPermissionsRequested = false;
      var startedListeningForDeviceOrientationChanges = false;

      PigeonOverrides.processCameraProvider_getInstance = () async {
        return mockProcessCameraProvider;
      };
      PigeonOverrides.cameraSelector_new =
          ({LensFacing? requireLensFacing, dynamic cameraInfoForFilter}) {
            switch (requireLensFacing) {
              case LensFacing.front:
                return MockCameraSelector();
              case LensFacing.back:
              case LensFacing.external:
              case LensFacing.unknown:
              case null:
            }

            return mockBackCameraSelector;
          };
      PigeonOverrides.preview_new =
          ({
            int? targetRotation,
            CameraIntegerRange? targetFpsRange,
            ResolutionSelector? resolutionSelector,
          }) {
            return mockPreview;
          };
      PigeonOverrides.imageCapture_new =
          ({
            int? targetRotation,
            CameraXFlashMode? flashMode,
            ResolutionSelector? resolutionSelector,
          }) {
            return mockImageCapture;
          };
      PigeonOverrides.recorder_new =
          ({
            int? aspectRatio,
            int? targetVideoEncodingBitRate,
            QualitySelector? qualitySelector,
          }) {
            return mockRecorder;
          };
      PigeonOverrides.videoCapture_withOutput =
          ({
            required VideoOutput videoOutput,
            CameraIntegerRange? targetFpsRange,
          }) {
            return mockVideoCapture;
          };
      PigeonOverrides.imageAnalysis_new =
          ({
            int? targetRotation,
            CameraIntegerRange? targetFpsRange,
            int? outputImageFormat,
            ResolutionSelector? resolutionSelector,
          }) {
            return mockImageAnalysis;
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
      PigeonOverrides.qualitySelector_from =
          ({
            required VideoQuality quality,
            FallbackStrategy? fallbackStrategy,
          }) {
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
            when(
              mockSystemServicesManager.requestCameraPermissions(any),
            ).thenAnswer((_) async {
              cameraPermissionsRequested = true;
              return null;
            });
            return mockSystemServicesManager;
          };
      PigeonOverrides.deviceOrientationManager_new =
          ({
            required void Function(DeviceOrientationManager, String)
            onDeviceOrientationChanged,
          }) {
            final manager = MockDeviceOrientationManager();
            when(manager.startListeningForDeviceOrientationChange()).thenAnswer(
              (_) async {
                startedListeningForDeviceOrientationChanges = true;
              },
            );
            when(manager.getUiOrientation()).thenAnswer((_) async {
              return 'PORTRAIT_UP';
            });
            return manager;
          };
      PigeonOverrides.aspectRatioStrategy_new =
          ({
            required AspectRatio preferredAspectRatio,
            required AspectRatioStrategyFallbackRule fallbackRule,
          }) {
            return MockAspectRatioStrategy();
          };
      PigeonOverrides.resolutionFilter_createWithOnePreferredSize =
          ({required CameraSize preferredSize}) {
            return MockResolutionFilter();
          };
      PigeonOverrides.camera2CameraInfo_from = ({required dynamic cameraInfo}) {
        final camera2cameraInfo = MockCamera2CameraInfo();
        when(
          camera2cameraInfo.getCameraCharacteristic(
            mockCameraCharacteristicsKey,
          ),
        ).thenAnswer((_) async => testSensorOrientation);
        return camera2cameraInfo;
      };
      PigeonOverrides.cameraSize_new =
          ({required int width, required int height}) {
            return MockCameraSize();
          };
      PigeonOverrides.cameraCharacteristics_sensorOrientation =
          mockCameraCharacteristicsKey;
      PigeonOverrides.fallbackStrategy_lowerQualityOrHigherThan =
          ({required VideoQuality quality}) {
            return MockFallbackStrategy();
          };

      camera.processCameraProvider = mockProcessCameraProvider;
      PigeonOverrides.cameraIntegerRange_new =
          CameraIntegerRange.pigeon_detached;

      when(
        mockPreview.setSurfaceProvider(mockSystemServicesManager),
      ).thenAnswer((_) async => testSurfaceTextureId);
      when(
        mockProcessCameraProvider.bindToLifecycle(
          mockBackCameraSelector,
          <UseCase>[mockPreview, mockImageCapture, mockImageAnalysis],
        ),
      ).thenAnswer((_) async => mockCamera);
      when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => mockLiveCameraState);

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
        equals(testSurfaceTextureId),
      );

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
      verify(camera.preview!.setSurfaceProvider(mockSystemServicesManager));
    },
  );

  test(
    'createCamera and initializeCamera properly set preset resolution selection strategy for non-video capture use cases',
    () async {
      final camera = AndroidCameraCameraX();
      const CameraLensDirection testLensDirection = CameraLensDirection.back;
      const testSensorOrientation = 90;
      const testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation,
      );
      const enableAudio = true;
      final mockCamera = MockCamera();

      // Mock/Detached objects for (typically attached) objects created by
      // createCamera.
      final mockProcessCameraProvider = MockProcessCameraProvider();
      final mockCameraInfo = MockCameraInfo();

      when(
        mockProcessCameraProvider.bindToLifecycle(any, any),
      ).thenAnswer((_) async => mockCamera);
      when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => MockLiveCameraState());
      camera.processCameraProvider = mockProcessCameraProvider;

      // Tell plugin to create mock/detached objects for testing createCamera
      // as needed.
      setUpOverridesForTestingUseCaseConfiguration(mockProcessCameraProvider);

      // Test non-null resolution presets.
      for (final ResolutionPreset resolutionPreset in ResolutionPreset.values) {
        final int flutterSurfaceTextureId = await camera.createCamera(
          testCameraDescription,
          resolutionPreset,
          enableAudio: enableAudio,
        );
        await camera.initializeCamera(flutterSurfaceTextureId);

        late final CameraSize? expectedBoundSize;

        switch (resolutionPreset) {
          case ResolutionPreset.low:
            expectedBoundSize = CameraSize.pigeon_detached(
              width: 320,
              height: 240,
            );
          case ResolutionPreset.medium:
            expectedBoundSize = CameraSize.pigeon_detached(
              width: 720,
              height: 480,
            );
          case ResolutionPreset.high:
            expectedBoundSize = CameraSize.pigeon_detached(
              width: 1280,
              height: 720,
            );
          case ResolutionPreset.veryHigh:
            expectedBoundSize = CameraSize.pigeon_detached(
              width: 1920,
              height: 1080,
            );
          case ResolutionPreset.ultraHigh:
            expectedBoundSize = CameraSize.pigeon_detached(
              width: 3840,
              height: 2160,
            );
          case ResolutionPreset.max:
            continue;
        }

        final CameraSize? previewSize = await camera
            .preview!
            .resolutionSelector!
            .resolutionStrategy!
            .getBoundSize();
        expect(previewSize?.width, equals(expectedBoundSize.width));
        expect(previewSize?.height, equals(expectedBoundSize.height));
        expect(
          await camera.preview!.resolutionSelector!.resolutionStrategy!
              .getFallbackRule(),
          ResolutionStrategyFallbackRule.closestLowerThenHigher,
        );

        final CameraSize? imageCaptureSize = await camera
            .imageCapture!
            .resolutionSelector!
            .resolutionStrategy!
            .getBoundSize();
        expect(imageCaptureSize?.width, equals(expectedBoundSize.width));
        expect(imageCaptureSize?.height, equals(expectedBoundSize.height));
        expect(
          await camera.imageCapture!.resolutionSelector!.resolutionStrategy!
              .getFallbackRule(),
          ResolutionStrategyFallbackRule.closestLowerThenHigher,
        );

        final CameraSize? imageAnalysisSize = await camera
            .imageAnalysis!
            .resolutionSelector!
            .resolutionStrategy!
            .getBoundSize();
        expect(imageAnalysisSize?.width, equals(expectedBoundSize.width));
        expect(imageAnalysisSize?.height, equals(expectedBoundSize.height));
        expect(
          await camera.imageAnalysis!.resolutionSelector!.resolutionStrategy!
              .getFallbackRule(),
          ResolutionStrategyFallbackRule.closestLowerThenHigher,
        );
      }

      // Test max case.
      await camera.createCamera(
        testCameraDescription,
        ResolutionPreset.max,
        enableAudio: true,
      );

      expect(
        camera.preview!.resolutionSelector!.resolutionStrategy,
        equals(ResolutionStrategy.highestAvailableStrategy),
      );
      expect(
        camera.imageCapture!.resolutionSelector!.resolutionStrategy,
        equals(ResolutionStrategy.highestAvailableStrategy),
      );
      expect(
        camera.imageAnalysis!.resolutionSelector!.resolutionStrategy,
        equals(ResolutionStrategy.highestAvailableStrategy),
      );

      // Test null case.
      final int flutterSurfaceTextureId = await camera.createCamera(
        testCameraDescription,
        null,
      );
      await camera.initializeCamera(flutterSurfaceTextureId);

      expect(camera.preview!.resolutionSelector, isNull);
      expect(camera.imageCapture!.resolutionSelector, isNull);
      expect(camera.imageAnalysis!.resolutionSelector, isNull);
    },
  );

  test(
    'createCamera and initializeCamera properly set filter for resolution preset for non-video capture use cases',
    () async {
      final camera = AndroidCameraCameraX();
      const CameraLensDirection testLensDirection = CameraLensDirection.front;
      const testSensorOrientation = 180;
      const testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation,
      );
      const enableAudio = true;
      final mockCamera = MockCamera();

      // Mock/Detached objects for (typically attached) objects created by
      // createCamera.
      final mockProcessCameraProvider = MockProcessCameraProvider();
      final mockCameraInfo = MockCameraInfo();

      // Tell plugin to create mock/detached objects for testing createCamera
      // as needed.
      CameraSize? lastSetPreferredSize;
      setUpOverridesForTestingUseCaseConfiguration(
        mockProcessCameraProvider,
        createWithOnePreferredSizeResolutionFilter:
            ({required CameraSize preferredSize}) {
              lastSetPreferredSize = preferredSize;
              return MockResolutionFilter();
            },
      );

      when(
        mockProcessCameraProvider.bindToLifecycle(any, any),
      ).thenAnswer((_) async => mockCamera);
      when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => MockLiveCameraState());
      camera.processCameraProvider = mockProcessCameraProvider;

      // Test non-null resolution presets.
      for (final ResolutionPreset resolutionPreset in ResolutionPreset.values) {
        final int flutterSurfaceTextureId = await camera.createCamera(
          testCameraDescription,
          resolutionPreset,
          enableAudio: enableAudio,
        );
        await camera.initializeCamera(flutterSurfaceTextureId);

        CameraSize? expectedPreferredResolution;

        switch (resolutionPreset) {
          case ResolutionPreset.low:
            expectedPreferredResolution = CameraSize.pigeon_detached(
              width: 320,
              height: 240,
            );
          case ResolutionPreset.medium:
            expectedPreferredResolution = CameraSize.pigeon_detached(
              width: 720,
              height: 480,
            );
          case ResolutionPreset.high:
            expectedPreferredResolution = CameraSize.pigeon_detached(
              width: 1280,
              height: 720,
            );
          case ResolutionPreset.veryHigh:
            expectedPreferredResolution = CameraSize.pigeon_detached(
              width: 1920,
              height: 1080,
            );
          case ResolutionPreset.ultraHigh:
            expectedPreferredResolution = CameraSize.pigeon_detached(
              width: 3840,
              height: 2160,
            );
          case ResolutionPreset.max:
            expectedPreferredResolution = null;
        }

        if (expectedPreferredResolution == null) {
          expect(camera.preview!.resolutionSelector!.resolutionFilter, isNull);
          expect(
            camera.imageCapture!.resolutionSelector!.resolutionFilter,
            isNull,
          );
          expect(
            camera.imageAnalysis!.resolutionSelector!.resolutionFilter,
            isNull,
          );
          continue;
        }

        expect(
          lastSetPreferredSize?.width,
          equals(expectedPreferredResolution.width),
        );
        expect(
          lastSetPreferredSize?.height,
          equals(expectedPreferredResolution.height),
        );

        final CameraSize? imageCaptureSize = await camera
            .imageCapture!
            .resolutionSelector!
            .resolutionStrategy!
            .getBoundSize();
        expect(
          imageCaptureSize?.width,
          equals(expectedPreferredResolution.width),
        );
        expect(
          imageCaptureSize?.height,
          equals(expectedPreferredResolution.height),
        );

        final CameraSize? imageAnalysisSize = await camera
            .imageAnalysis!
            .resolutionSelector!
            .resolutionStrategy!
            .getBoundSize();
        expect(
          imageAnalysisSize?.width,
          equals(expectedPreferredResolution.width),
        );
        expect(
          imageAnalysisSize?.height,
          equals(expectedPreferredResolution.height),
        );
      }

      // Test null case.
      final int flutterSurfaceTextureId = await camera.createCamera(
        testCameraDescription,
        null,
      );
      await camera.initializeCamera(flutterSurfaceTextureId);

      expect(camera.preview!.resolutionSelector, isNull);
      expect(camera.imageCapture!.resolutionSelector, isNull);
      expect(camera.imageAnalysis!.resolutionSelector, isNull);
    },
  );

  test(
    'createCamera and initializeCamera properly set aspect ratio based on preset resolution for non-video capture use cases',
    () async {
      final camera = AndroidCameraCameraX();
      const CameraLensDirection testLensDirection = CameraLensDirection.back;
      const testSensorOrientation = 90;
      const testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation,
      );
      const enableAudio = true;
      const testCameraId = 12;
      final mockCamera = MockCamera();

      // Mock/Detached objects for (typically attached) objects created by
      // createCamera.
      final mockProcessCameraProvider = MockProcessCameraProvider();
      final mockCameraInfo = MockCameraInfo();

      // Tell plugin to create mock/detached objects for testing createCamera
      // as needed.
      setUpOverridesForTestingUseCaseConfiguration(mockProcessCameraProvider);
      when(
        mockProcessCameraProvider.bindToLifecycle(any, any),
      ).thenAnswer((_) async => mockCamera);
      when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => MockLiveCameraState());
      camera.processCameraProvider = mockProcessCameraProvider;

      // Test non-null resolution presets.
      for (final ResolutionPreset resolutionPreset in ResolutionPreset.values) {
        final int flutterSurfaceTextureId = await camera.createCamera(
          testCameraDescription,
          resolutionPreset,
          enableAudio: enableAudio,
        );
        await camera.initializeCamera(flutterSurfaceTextureId);

        AspectRatio? expectedAspectRatio;
        AspectRatioStrategyFallbackRule? expectedFallbackRule;
        switch (resolutionPreset) {
          case ResolutionPreset.low:
            expectedAspectRatio = AspectRatio.ratio4To3;
            expectedFallbackRule = AspectRatioStrategyFallbackRule.auto;
          case ResolutionPreset.high:
          case ResolutionPreset.veryHigh:
          case ResolutionPreset.ultraHigh:
            expectedAspectRatio = AspectRatio.ratio16To9;
            expectedFallbackRule = AspectRatioStrategyFallbackRule.auto;
          case ResolutionPreset.medium:
          // Medium resolution preset uses aspect ratio 3:2 which is unsupported
          // by CameraX.
          case ResolutionPreset.max:
        }

        if (expectedAspectRatio == null) {
          expect(
            await camera.preview!.resolutionSelector!.getAspectRatioStrategy(),
            equals(AspectRatioStrategy.ratio_4_3FallbackAutoStrategy),
          );
          expect(
            await camera.imageCapture!.resolutionSelector!
                .getAspectRatioStrategy(),
            equals(AspectRatioStrategy.ratio_4_3FallbackAutoStrategy),
          );
          expect(
            await camera.imageAnalysis!.resolutionSelector!
                .getAspectRatioStrategy(),
            equals(AspectRatioStrategy.ratio_4_3FallbackAutoStrategy),
          );
          continue;
        }

        final AspectRatioStrategy previewStrategy = await camera
            .preview!
            .resolutionSelector!
            .getAspectRatioStrategy();
        final AspectRatioStrategy imageCaptureStrategy = await camera
            .imageCapture!
            .resolutionSelector!
            .getAspectRatioStrategy();
        final AspectRatioStrategy imageAnalysisStrategy = await camera
            .imageCapture!
            .resolutionSelector!
            .getAspectRatioStrategy();

        // Check aspect ratio.
        expect(
          await previewStrategy.getPreferredAspectRatio(),
          equals(expectedAspectRatio),
        );
        expect(
          await imageCaptureStrategy.getPreferredAspectRatio(),
          equals(expectedAspectRatio),
        );
        expect(
          await imageAnalysisStrategy.getPreferredAspectRatio(),
          equals(expectedAspectRatio),
        );

        // Check fallback rule.
        expect(
          await previewStrategy.getFallbackRule(),
          equals(expectedFallbackRule),
        );
        expect(
          await imageCaptureStrategy.getFallbackRule(),
          equals(expectedFallbackRule),
        );
        expect(
          await imageAnalysisStrategy.getFallbackRule(),
          equals(expectedFallbackRule),
        );
      }

      // Test null case.
      await camera.createCamera(testCameraDescription, null);
      await camera.initializeCamera(testCameraId);

      expect(camera.preview!.resolutionSelector, isNull);
      expect(camera.imageCapture!.resolutionSelector, isNull);
      expect(camera.imageAnalysis!.resolutionSelector, isNull);
    },
  );

  test(
    'createCamera and initializeCamera binds Preview, ImageCapture, and ImageAnalysis use cases to ProcessCameraProvider instance',
    () async {
      final camera = AndroidCameraCameraX();
      const CameraLensDirection testLensDirection = CameraLensDirection.back;
      const testSensorOrientation = 90;
      const testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation,
      );
      const ResolutionPreset testResolutionPreset = ResolutionPreset.veryHigh;
      const enableAudio = true;

      // Mock/Detached objects for (typically attached) objects created by
      // createCamera.
      final mockProcessCameraProvider = MockProcessCameraProvider();
      final mockPreview = MockPreview();
      final mockBackCameraSelector = MockCameraSelector();
      final mockImageCapture = MockImageCapture();
      final mockImageAnalysis = MockImageAnalysis();
      final mockRecorder = MockRecorder();
      final mockVideoCapture = MockVideoCapture();
      final mockCamera = MockCamera();
      final mockCameraInfo = MockCameraInfo();
      final mockCameraControl = MockCameraControl();
      final mockCamera2CameraInfo = MockCamera2CameraInfo();
      final mockCameraCharacteristicsKey = MockCameraCharacteristicsKey();

      // Tell plugin to create mock/detached objects and stub method calls for the
      // testing of createCamera.
      PigeonOverrides.processCameraProvider_getInstance = () async {
        return mockProcessCameraProvider;
      };
      PigeonOverrides.cameraSelector_new =
          ({LensFacing? requireLensFacing, dynamic cameraInfoForFilter}) {
            switch (requireLensFacing) {
              case LensFacing.front:
                return MockCameraSelector();
              case LensFacing.back:
              case LensFacing.external:
              case LensFacing.unknown:
              case null:
            }

            return mockBackCameraSelector;
          };
      PigeonOverrides.preview_new =
          ({
            int? targetRotation,
            CameraIntegerRange? targetFpsRange,
            ResolutionSelector? resolutionSelector,
          }) {
            final testResolutionInfo = ResolutionInfo.pigeon_detached(
              resolution: MockCameraSize(),
            );
            when(
              mockPreview.getResolutionInfo(),
            ).thenAnswer((_) async => testResolutionInfo);
            return mockPreview;
          };
      PigeonOverrides.imageCapture_new =
          ({
            int? targetRotation,
            CameraXFlashMode? flashMode,
            ResolutionSelector? resolutionSelector,
          }) {
            return mockImageCapture;
          };
      PigeonOverrides.recorder_new =
          ({
            int? aspectRatio,
            int? targetVideoEncodingBitRate,
            QualitySelector? qualitySelector,
          }) {
            return mockRecorder;
          };
      PigeonOverrides.videoCapture_withOutput =
          ({
            required VideoOutput videoOutput,
            CameraIntegerRange? targetFpsRange,
          }) {
            return mockVideoCapture;
          };
      PigeonOverrides.imageAnalysis_new =
          ({
            int? targetRotation,
            CameraIntegerRange? targetFpsRange,
            int? outputImageFormat,
            ResolutionSelector? resolutionSelector,
          }) {
            return mockImageAnalysis;
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
      PigeonOverrides.qualitySelector_from =
          ({
            required VideoQuality quality,
            FallbackStrategy? fallbackStrategy,
          }) {
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
          }) {
            final manager = MockDeviceOrientationManager();
            when(manager.getUiOrientation()).thenAnswer((_) async {
              return 'PORTRAIT_UP';
            });
            return manager;
          };
      PigeonOverrides.aspectRatioStrategy_new =
          ({
            required AspectRatio preferredAspectRatio,
            required AspectRatioStrategyFallbackRule fallbackRule,
          }) {
            return MockAspectRatioStrategy();
          };
      PigeonOverrides.resolutionFilter_createWithOnePreferredSize =
          ({required CameraSize preferredSize}) {
            return MockResolutionFilter();
          };
      PigeonOverrides.camera2CameraInfo_from = ({required dynamic cameraInfo}) {
        when(
          mockCamera2CameraInfo.getCameraCharacteristic(
            mockCameraCharacteristicsKey,
          ),
        ).thenAnswer((_) async => testSensorOrientation);
        return mockCamera2CameraInfo;
      };
      PigeonOverrides.cameraSize_new =
          ({required int width, required int height}) {
            return MockCameraSize();
          };
      PigeonOverrides.cameraCharacteristics_sensorOrientation =
          mockCameraCharacteristicsKey;
      PigeonOverrides.fallbackStrategy_lowerQualityOrHigherThan =
          ({required VideoQuality quality}) {
            return MockFallbackStrategy();
          };

      when(
        mockProcessCameraProvider.bindToLifecycle(
          mockBackCameraSelector,
          <UseCase>[mockPreview, mockImageCapture, mockImageAnalysis],
        ),
      ).thenAnswer((_) async => mockCamera);
      when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => MockLiveCameraState());
      when(mockCamera.cameraControl).thenAnswer((_) => mockCameraControl);

      camera.processCameraProvider = mockProcessCameraProvider;
      PigeonOverrides.cameraIntegerRange_new =
          CameraIntegerRange.pigeon_detached;

      final int flutterSurfaceTextureId = await camera.createCameraWithSettings(
        testCameraDescription,
        const MediaSettings(
          resolutionPreset: testResolutionPreset,
          fps: 15,
          videoBitrate: 2000000,
          audioBitrate: 64000,
          enableAudio: enableAudio,
        ),
      );
      await camera.initializeCamera(flutterSurfaceTextureId);

      // Verify expected UseCases were bound.
      verify(
        camera.processCameraProvider!.bindToLifecycle(
          camera.cameraSelector!,
          <UseCase>[mockPreview, mockImageCapture, mockImageAnalysis],
        ),
      );

      // Verify the camera's CameraInfo instance got updated.
      expect(camera.cameraInfo, equals(mockCameraInfo));

      // Verify camera's CameraControl instance got updated.
      expect(camera.cameraControl, equals(mockCameraControl));

      // Verify preview has been marked as bound to the camera lifecycle by
      // createCamera.
      expect(camera.previewInitiallyBound, isTrue);
    },
  );

  test(
    'createCamera properly sets preset resolution for video capture use case',
    () async {
      final camera = AndroidCameraCameraX();
      const CameraLensDirection testLensDirection = CameraLensDirection.back;
      const testSensorOrientation = 90;
      const testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation,
      );
      const enableAudio = true;
      final mockCamera = MockCamera();

      // Mock/Detached objects for (typically attached) objects created by
      // createCamera.
      final mockProcessCameraProvider = MockProcessCameraProvider();
      final mockCameraInfo = MockCameraInfo();

      // Tell plugin to create mock/detached objects for testing createCamera
      // as needed.
      VideoQuality? fallbackStrategyVideoQuality;
      VideoQuality? qualitySelectorVideoQuality;
      FallbackStrategy? setFallbackStrategy;
      final mockFallbackStrategy = MockFallbackStrategy();
      final mockQualitySelector = MockQualitySelector();
      setUpOverridesForTestingUseCaseConfiguration(
        mockProcessCameraProvider,
        lowerQualityOrHigherThanFallbackStrategy:
            ({required VideoQuality quality}) {
              fallbackStrategyVideoQuality = quality;
              return mockFallbackStrategy;
            },
        fromQualitySelector:
            ({
              required VideoQuality quality,
              FallbackStrategy? fallbackStrategy,
            }) {
              qualitySelectorVideoQuality = quality;
              setFallbackStrategy = fallbackStrategy;
              return mockQualitySelector;
            },
      );

      when(
        mockProcessCameraProvider.bindToLifecycle(any, any),
      ).thenAnswer((_) async => mockCamera);
      when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => MockLiveCameraState());

      // Test non-null resolution presets.
      for (final ResolutionPreset resolutionPreset in ResolutionPreset.values) {
        await camera.createCamera(
          testCameraDescription,
          resolutionPreset,
          enableAudio: enableAudio,
        );

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

        expect(
          await camera.recorder!.getQualitySelector(),
          mockQualitySelector,
        );
        expect(qualitySelectorVideoQuality, equals(expectedVideoQuality));
        expect(fallbackStrategyVideoQuality, equals(expectedVideoQuality));
        expect(setFallbackStrategy, equals(mockFallbackStrategy));
      }

      qualitySelectorVideoQuality = null;
      setFallbackStrategy = null;

      // Test null case.
      await camera.createCamera(testCameraDescription, null);
      expect(
        await camera.recorder!.getQualitySelector(),
        isNot(equals(mockQualitySelector)),
      );
    },
  );

  test(
    'createCamera sets sensorOrientationDegrees and enableRecordingAudio as expected',
    () async {
      final camera = AndroidCameraCameraX();
      const CameraLensDirection testLensDirection = CameraLensDirection.back;
      const testSensorOrientation = 90;
      const testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation,
      );
      const enableAudio = true;
      const ResolutionPreset testResolutionPreset = ResolutionPreset.veryHigh;
      const testHandlesCropAndRotation = true;

      // Mock/Detached objects for (typically attached) objects created by
      // createCamera.
      final mockCamera = MockCamera();
      final mockProcessCameraProvider = MockProcessCameraProvider();
      final mockCameraInfo = MockCameraInfo();

      // The proxy needed for this test is the same as testing resolution
      // presets except for mocking the retrieval of the sensor and current
      // UI orientation.
      setUpOverridesForTestingUseCaseConfiguration(
        mockProcessCameraProvider,
        newPreview:
            ({
              int? targetRotation,
              CameraIntegerRange? targetFpsRange,
              ResolutionSelector? resolutionSelector,
            }) {
              final mockPreview = MockPreview();
              when(
                mockPreview.surfaceProducerHandlesCropAndRotation(),
              ).thenAnswer((_) async => testHandlesCropAndRotation);
              when(
                mockPreview.resolutionSelector,
              ).thenReturn(resolutionSelector);
              return mockPreview;
            },
      );

      when(
        mockProcessCameraProvider.bindToLifecycle(any, any),
      ).thenAnswer((_) async => mockCamera);
      when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => MockLiveCameraState());

      await camera.createCamera(
        testCameraDescription,
        testResolutionPreset,
        enableAudio: enableAudio,
      );

      expect(camera.sensorOrientationDegrees, testSensorOrientation);
      expect(camera.enableRecordingAudio, isTrue);
    },
  );

  test(
    'createCamera and initializeCamera sets targetFps as expected',
    () async {
      final camera = AndroidCameraCameraX();
      const CameraLensDirection testLensDirection = CameraLensDirection.back;
      const testSensorOrientation = 90;
      const testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation,
      );
      const fastTargetFps = 60;
      const testCameraId = 12;
      final mockCamera = MockCamera();

      // Mock/Detached objects for (typically attached) objects created by
      // createCamera.
      final mockProcessCameraProvider = MockProcessCameraProvider();
      final mockCameraInfo = MockCameraInfo();

      when(
        mockProcessCameraProvider.bindToLifecycle(any, any),
      ).thenAnswer((_) async => mockCamera);
      when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => MockLiveCameraState());
      camera.processCameraProvider = mockProcessCameraProvider;
      PigeonOverrides.cameraIntegerRange_new =
          CameraIntegerRange.pigeon_detached;

      CameraIntegerRange? targetPreviewFpsRange;
      CameraIntegerRange? targetVideoCaptureFpsRange;
      CameraIntegerRange? targetImageAnalysisFpsRange;

      setUpOverridesForTestingUseCaseConfiguration(
        mockProcessCameraProvider,
        newPreview:
            ({
              ResolutionSelector? resolutionSelector,
              CameraIntegerRange? targetFpsRange,
              int? targetRotation,
            }) {
              targetPreviewFpsRange = targetFpsRange;
              final mockPreview = MockPreview();
              final testResolutionInfo = ResolutionInfo.pigeon_detached(
                resolution: MockCameraSize(),
              );
              when(
                mockPreview.getResolutionInfo(),
              ).thenAnswer((_) async => testResolutionInfo);
              return mockPreview;
            },
        withOutputVideoCapture:
            ({
              CameraIntegerRange? targetFpsRange,
              required VideoOutput videoOutput,
            }) {
              targetVideoCaptureFpsRange = targetFpsRange;
              return MockVideoCapture();
            },
        newImageAnalysis:
            ({
              int? outputImageFormat,
              ResolutionSelector? resolutionSelector,
              CameraIntegerRange? targetFpsRange,
              int? targetRotation,
            }) {
              targetImageAnalysisFpsRange = targetFpsRange;
              return MockImageAnalysis();
            },
      );

      await camera.createCameraWithSettings(
        testCameraDescription,
        const MediaSettings(fps: fastTargetFps),
      );
      await camera.initializeCamera(testCameraId);

      expect(targetPreviewFpsRange?.lower, fastTargetFps);
      expect(targetPreviewFpsRange?.upper, fastTargetFps);
      expect(targetVideoCaptureFpsRange?.lower, fastTargetFps);
      expect(targetVideoCaptureFpsRange?.upper, fastTargetFps);
      expect(targetImageAnalysisFpsRange?.lower, fastTargetFps);
      expect(targetImageAnalysisFpsRange?.upper, fastTargetFps);
    },
  );

  test(
    'createCamera properly selects specific back camera by specifying a CameraInfo',
    () async {
      // Arrange
      final camera = AndroidCameraCameraX();
      final returnData = <dynamic>[
        <String, dynamic>{
          'name': 'Camera 0',
          'lensFacing': 'back',
          'sensorOrientation': 0,
        },
        <String, dynamic>{
          'name': 'Camera 1',
          'lensFacing': 'back',
          'sensorOrientation': 0,
        },
        <String, dynamic>{
          'name': 'Camera 2',
          'lensFacing': 'front',
          'sensorOrientation': 0,
        },
      ];

      var mockCameraInfosList = <MockCameraInfo>[];
      final cameraNameToInfos = <String, MockCameraInfo?>{};

      const testSensorOrientation = 0;

      // Mocks for objects created by availableCameras.
      final mockProcessCameraProvider = MockProcessCameraProvider();
      final mockFrontCameraSelector = MockCameraSelector();
      final mockBackCameraSelector = MockCameraSelector();
      final mockChosenCameraInfoCameraSelector = MockCameraSelector();

      final mockFrontCameraInfo = MockCameraInfo();
      final mockBackCameraInfoOne = MockCameraInfo();
      final mockBackCameraInfoTwo = MockCameraInfo();

      // Mock/Detached objects for (typically attached) objects created by
      // createCamera.
      final mockPreview = MockPreview();
      final mockImageCapture = MockImageCapture();
      final mockImageAnalysis = MockImageAnalysis();
      final mockRecorder = MockRecorder();
      final mockVideoCapture = MockVideoCapture();
      final mockCamera = MockCamera();
      final mockCameraInfo = MockCameraInfo();
      final mockCameraControl = MockCameraControl();
      final mockCamera2CameraInfo = MockCamera2CameraInfo();
      final mockCameraCharacteristicsKey = MockCameraCharacteristicsKey();

      // Tell plugin to create mock/detached objects and stub method calls for the
      // testing of availableCameras and createCamera.
      PigeonOverrides.processCameraProvider_getInstance = () {
        return Future<ProcessCameraProvider>.value(mockProcessCameraProvider);
      };
      PigeonOverrides.cameraSelector_new =
          ({LensFacing? requireLensFacing, dynamic cameraInfoForFilter}) {
            switch (requireLensFacing) {
              case LensFacing.front:
                return mockFrontCameraSelector;
              case LensFacing.back:
              case LensFacing.external:
              case LensFacing.unknown:
              case null:
            }
            if (cameraInfoForFilter == mockBackCameraInfoOne) {
              return mockChosenCameraInfoCameraSelector;
            }

            return mockBackCameraSelector;
          };
      PigeonOverrides.systemServicesManager_new =
          ({
            required void Function(SystemServicesManager, String) onCameraError,
          }) {
            return MockSystemServicesManager();
          };
      PigeonOverrides.preview_new =
          ({
            int? targetRotation,
            CameraIntegerRange? targetFpsRange,
            ResolutionSelector? resolutionSelector,
          }) {
            return mockPreview;
          };
      PigeonOverrides.imageCapture_new =
          ({
            int? targetRotation,
            CameraXFlashMode? flashMode,
            ResolutionSelector? resolutionSelector,
          }) {
            return mockImageCapture;
          };
      PigeonOverrides.recorder_new =
          ({
            int? aspectRatio,
            int? targetVideoEncodingBitRate,
            QualitySelector? qualitySelector,
          }) {
            return mockRecorder;
          };
      PigeonOverrides.recorder_new =
          ({
            int? aspectRatio,
            int? targetVideoEncodingBitRate,
            QualitySelector? qualitySelector,
          }) {
            return mockRecorder;
          };
      PigeonOverrides.videoCapture_withOutput =
          ({
            required VideoOutput videoOutput,
            CameraIntegerRange? targetFpsRange,
          }) {
            return mockVideoCapture;
          };
      PigeonOverrides.imageAnalysis_new =
          ({
            int? targetRotation,
            CameraIntegerRange? targetFpsRange,
            int? outputImageFormat,
            ResolutionSelector? resolutionSelector,
          }) {
            return mockImageAnalysis;
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
      PigeonOverrides.resolutionSelector_new =
          ({
            AspectRatioStrategy? aspectRatioStrategy,
            ResolutionStrategy? resolutionStrategy,
            ResolutionFilter? resolutionFilter,
          }) {
            return MockResolutionSelector();
          };
      PigeonOverrides.qualitySelector_from =
          ({
            required VideoQuality quality,
            FallbackStrategy? fallbackStrategy,
          }) {
            return MockQualitySelector();
          };
      GenericsPigeonOverrides.observerNew =
          <T>({required void Function(Observer<T>, T) onChanged}) {
            return Observer<T>.detached(onChanged: onChanged);
          };
      PigeonOverrides.deviceOrientationManager_new =
          ({
            required void Function(DeviceOrientationManager, String)
            onDeviceOrientationChanged,
          }) {
            final manager = MockDeviceOrientationManager();
            when(manager.getUiOrientation()).thenAnswer((_) async {
              return 'PORTRAIT_UP';
            });
            return manager;
          };
      PigeonOverrides.aspectRatioStrategy_new =
          ({
            required AspectRatio preferredAspectRatio,
            required AspectRatioStrategyFallbackRule fallbackRule,
          }) {
            return MockAspectRatioStrategy();
          };
      PigeonOverrides.resolutionFilter_createWithOnePreferredSize =
          ({required CameraSize preferredSize}) {
            return MockResolutionFilter();
          };
      PigeonOverrides.camera2CameraInfo_from = ({required dynamic cameraInfo}) {
        when(
          mockCamera2CameraInfo.getCameraCharacteristic(
            mockCameraCharacteristicsKey,
          ),
        ).thenAnswer((_) async => testSensorOrientation);
        return mockCamera2CameraInfo;
      };
      PigeonOverrides.cameraSize_new =
          ({required int width, required int height}) {
            return MockCameraSize();
          };
      PigeonOverrides.cameraCharacteristics_sensorOrientation =
          mockCameraCharacteristicsKey;
      PigeonOverrides.fallbackStrategy_lowerQualityOrHigherThan =
          ({required VideoQuality quality}) {
            return MockFallbackStrategy();
          };
      PigeonOverrides.cameraIntegerRange_new =
          ({required int lower, required int upper}) {
            return CameraIntegerRange.pigeon_detached(lower: 0, upper: 0);
          };

      // Mock calls to native platform
      when(mockProcessCameraProvider.getAvailableCameraInfos()).thenAnswer((
        _,
      ) async {
        mockCameraInfosList = <MockCameraInfo>[
          mockBackCameraInfoOne,
          mockBackCameraInfoTwo,
          mockFrontCameraInfo,
        ];
        return <MockCameraInfo>[
          mockBackCameraInfoOne,
          mockBackCameraInfoTwo,
          mockFrontCameraInfo,
        ];
      });
      when(
        mockBackCameraSelector.filter(<MockCameraInfo>[mockBackCameraInfoOne]),
      ).thenAnswer((_) async => <MockCameraInfo>[mockBackCameraInfoOne]);
      when(
        mockBackCameraSelector.filter(<MockCameraInfo>[mockBackCameraInfoTwo]),
      ).thenAnswer((_) async => <MockCameraInfo>[mockBackCameraInfoTwo]);
      when(
        mockBackCameraSelector.filter(<MockCameraInfo>[mockFrontCameraInfo]),
      ).thenAnswer((_) async => <MockCameraInfo>[]);
      when(
        mockFrontCameraSelector.filter(<MockCameraInfo>[mockBackCameraInfoOne]),
      ).thenAnswer((_) async => <MockCameraInfo>[]);
      when(
        mockFrontCameraSelector.filter(<MockCameraInfo>[mockBackCameraInfoTwo]),
      ).thenAnswer((_) async => <MockCameraInfo>[]);
      when(
        mockFrontCameraSelector.filter(<MockCameraInfo>[mockFrontCameraInfo]),
      ).thenAnswer((_) async => <MockCameraInfo>[mockFrontCameraInfo]);

      final List<CameraDescription> cameraDescriptions = await camera
          .availableCameras();
      expect(cameraDescriptions.length, returnData.length);

      for (var i = 0; i < returnData.length; i++) {
        final Map<String, Object?> savedData =
            (returnData[i] as Map<dynamic, dynamic>).cast<String, Object?>();

        cameraNameToInfos[savedData['name']! as String] =
            mockCameraInfosList[i];
        final cameraDescription = CameraDescription(
          name: savedData['name']! as String,
          lensDirection: (savedData['lensFacing']! as String) == 'front'
              ? CameraLensDirection.front
              : CameraLensDirection.back,
          sensorOrientation: savedData['sensorOrientation']! as int,
        );
        expect(cameraDescriptions[i], cameraDescription);
        expect(cameraNameToInfos.containsKey(cameraDescription.name), isTrue);
      }

      when(
        mockProcessCameraProvider.bindToLifecycle(
          mockChosenCameraInfoCameraSelector,
          <UseCase>[mockPreview, mockImageCapture, mockImageAnalysis],
        ),
      ).thenAnswer((_) async => mockCamera);
      when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => MockLiveCameraState());
      when(mockCamera.cameraControl).thenAnswer((_) => mockCameraControl);

      camera.processCameraProvider = mockProcessCameraProvider;

      // Verify the camera name used to create camera is associated with mockBackCameraInfoOne.
      expect(
        cameraNameToInfos[cameraDescriptions[0].name],
        mockBackCameraInfoOne,
      );

      // Creating a camera with settings using a specific camera from
      // available cameras.
      await camera.createCameraWithSettings(
        cameraDescriptions[0],
        const MediaSettings(
          resolutionPreset: ResolutionPreset.low,
          fps: 15,
          videoBitrate: 200000,
          audioBitrate: 32000,
          enableAudio: true,
        ),
      );

      // Verify CameraSelector is chosen based on specified cameraInfo.
      expect(camera.cameraSelector, equals(mockChosenCameraInfoCameraSelector));
    },
  );

  test(
    'initializeCamera throws a CameraException when createCamera has not been called before initializedCamera',
    () async {
      final camera = AndroidCameraCameraX();
      await expectLater(() async {
        await camera.initializeCamera(3);
      }, throwsA(isA<CameraException>()));
    },
  );

  test('initializeCamera sets camera state observer as expected', () async {
    final camera = AndroidCameraCameraX();
    const CameraLensDirection testLensDirection = CameraLensDirection.back;
    const testSensorOrientation = 90;
    const testCameraDescription = CameraDescription(
      name: 'cameraName',
      lensDirection: testLensDirection,
      sensorOrientation: testSensorOrientation,
    );
    const enableAudio = true;
    final mockCamera = MockCamera();
    const testSurfaceTextureId = 244;

    // Mock/Detached objects for (typically attached) objects created by
    // createCamera.
    final mockProcessCameraProvider = MockProcessCameraProvider();
    final mockCameraInfo = MockCameraInfo();
    final mockLiveCameraState = MockLiveCameraState();
    final mockPreview = MockPreview();
    final testResolutionInfo = ResolutionInfo.pigeon_detached(
      resolution: MockCameraSize(),
    );

    when(
      mockProcessCameraProvider.bindToLifecycle(any, any),
    ).thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(
      mockCameraInfo.getCameraState(),
    ).thenAnswer((_) async => mockLiveCameraState);
    when(
      mockPreview.getResolutionInfo(),
    ).thenAnswer((_) async => testResolutionInfo);
    when(
      mockPreview.setSurfaceProvider(any),
    ).thenAnswer((_) async => testSurfaceTextureId);
    camera.processCameraProvider = mockProcessCameraProvider;

    // Tell plugin to create mock/detached objects for testing createCamera
    // as needed.
    setUpOverridesForTestingUseCaseConfiguration(
      mockProcessCameraProvider,
      newPreview:
          ({
            ResolutionSelector? resolutionSelector,
            int? targetRotation,
            CameraIntegerRange? targetFpsRange,
          }) => mockPreview,
    );

    // Create and initialize camera.
    await camera.createCameraWithSettings(
      testCameraDescription,
      const MediaSettings(enableAudio: enableAudio),
    );
    await camera.initializeCamera(testSurfaceTextureId);

    // Verify the camera state observer is updated.
    expect(
      await testCameraClosingObserver(
        camera,
        testSurfaceTextureId,
        verify(mockLiveCameraState.observe(captureAny)).captured.single
            as Observer<CameraState>,
      ),
      isTrue,
    );
  });

  test(
    'initializeCamera sets image format of ImageAnalysis use case as expected',
    () async {
      final camera = AndroidCameraCameraX();
      const CameraLensDirection testLensDirection = CameraLensDirection.back;
      const testSensorOrientation = 90;
      const testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation,
      );
      const enableAudio = true;
      final mockCamera = MockCamera();
      const testSurfaceTextureId = 244;

      // Mock/Detached objects for (typically attached) objects created by
      // createCamera.
      final mockProcessCameraProvider = MockProcessCameraProvider();
      final mockCameraInfo = MockCameraInfo();
      final mockLiveCameraState = MockLiveCameraState();
      final mockPreview = MockPreview();
      final testResolutionInfo = ResolutionInfo.pigeon_detached(
        resolution: MockCameraSize(),
      );
      final mockImageAnalysis = MockImageAnalysis();

      // Configure mocks for camera initialization.
      when(
        mockProcessCameraProvider.bindToLifecycle(any, any),
      ).thenAnswer((_) async => mockCamera);
      when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => mockLiveCameraState);
      when(
        mockPreview.getResolutionInfo(),
      ).thenAnswer((_) async => testResolutionInfo);
      when(
        mockPreview.setSurfaceProvider(any),
      ).thenAnswer((_) async => testSurfaceTextureId);
      camera.processCameraProvider = mockProcessCameraProvider;

      for (final ImageFormatGroup imageFormatGroup in ImageFormatGroup.values) {
        // Get CameraX image format constant for imageFormatGroup.
        final int? cameraXImageFormat = switch (imageFormatGroup) {
          ImageFormatGroup.yuv420 =>
            AndroidCameraCameraX.imageAnalysisOutputImageFormatYuv420_888,
          ImageFormatGroup.nv21 =>
            AndroidCameraCameraX.imageAnalysisOutputImageFormatNv21,
          _ => null,
        };
        // Tell plugin to create mock/detached objects for testing createCamera
        // as needed.
        int? imageAnalysisOutputImageFormat;
        setUpOverridesForTestingUseCaseConfiguration(
          mockProcessCameraProvider,
          newImageAnalysis:
              ({
                ResolutionSelector? resolutionSelector,
                int? targetRotation,
                CameraIntegerRange? targetFpsRange,
                int? outputImageFormat,
              }) {
                imageAnalysisOutputImageFormat = outputImageFormat;
                return mockImageAnalysis;
              },
          newPreview:
              ({
                ResolutionSelector? resolutionSelector,
                int? targetRotation,
                CameraIntegerRange? targetFpsRange,
              }) => mockPreview,
        );

        // Create and initialize camera.
        await camera.createCameraWithSettings(
          testCameraDescription,
          const MediaSettings(enableAudio: enableAudio),
        );
        await camera.initializeCamera(
          testSurfaceTextureId,
          imageFormatGroup: imageFormatGroup,
        );

        // Test image format group is set as expected.
        expect(imageAnalysisOutputImageFormat, cameraXImageFormat);
      }
    },
  );

  test('initializeCamera sends expected CameraInitializedEvent', () async {
    final camera = AndroidCameraCameraX();

    const cameraId = 10;
    const CameraLensDirection testLensDirection = CameraLensDirection.back;
    const testSensorOrientation = 90;
    const testCameraDescription = CameraDescription(
      name: 'cameraName',
      lensDirection: testLensDirection,
      sensorOrientation: testSensorOrientation,
    );
    const resolutionWidth = 350;
    const resolutionHeight = 750;
    final Camera mockCamera = MockCamera();

    final testResolutionInfo = ResolutionInfo.pigeon_detached(
      resolution: CameraSize.pigeon_detached(
        width: resolutionWidth,
        height: resolutionHeight,
      ),
    );

    // Mocks for (typically attached) objects created by createCamera.
    final mockProcessCameraProvider = MockProcessCameraProvider();
    final CameraInfo mockCameraInfo = MockCameraInfo();
    final mockBackCameraSelector = MockCameraSelector();
    final mockFrontCameraSelector = MockCameraSelector();
    final mockPreview = MockPreview();
    final mockImageCapture = MockImageCapture();
    final mockImageAnalysis = MockImageAnalysis();

    // Tell plugin to create mock/detached objects for testing createCamera
    // as needed.
    PigeonOverrides.processCameraProvider_getInstance = () =>
        Future<ProcessCameraProvider>.value(mockProcessCameraProvider);
    PigeonOverrides.cameraSelector_new =
        ({LensFacing? requireLensFacing, dynamic cameraInfoForFilter}) {
          switch (requireLensFacing) {
            case LensFacing.front:
              return mockFrontCameraSelector;
            case _:
              return mockBackCameraSelector;
          }
        };
    PigeonOverrides.preview_new =
        ({
          int? targetRotation,
          CameraIntegerRange? targetFpsRange,
          ResolutionSelector? resolutionSelector,
        }) => mockPreview;
    PigeonOverrides.imageCapture_new =
        ({
          int? targetRotation,
          CameraXFlashMode? flashMode,
          ResolutionSelector? resolutionSelector,
        }) => mockImageCapture;
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
        }) => MockVideoCapture();
    PigeonOverrides.imageAnalysis_new =
        ({
          int? targetRotation,
          CameraIntegerRange? targetFpsRange,
          int? outputImageFormat,
          ResolutionSelector? resolutionSelector,
        }) => mockImageAnalysis;
    PigeonOverrides.resolutionStrategy_new =
        ({
          required CameraSize boundSize,
          required ResolutionStrategyFallbackRule fallbackRule,
        }) => MockResolutionStrategy();
    PigeonOverrides.resolutionSelector_new =
        ({
          AspectRatioStrategy? aspectRatioStrategy,
          ResolutionStrategy? resolutionStrategy,
          ResolutionFilter? resolutionFilter,
        }) => MockResolutionSelector();
    PigeonOverrides.fallbackStrategy_lowerQualityOrHigherThan =
        ({required VideoQuality quality}) => MockFallbackStrategy();
    PigeonOverrides.qualitySelector_from =
        ({required VideoQuality quality, FallbackStrategy? fallbackStrategy}) =>
            MockQualitySelector();
    GenericsPigeonOverrides.observerNew =
        <T>({required void Function(Observer<T>, T) onChanged}) {
          return Observer<T>.detached(onChanged: onChanged);
        };
    PigeonOverrides.systemServicesManager_new =
        ({
          required void Function(SystemServicesManager, String) onCameraError,
        }) => MockSystemServicesManager();
    PigeonOverrides.deviceOrientationManager_new =
        ({
          required void Function(DeviceOrientationManager, String)
          onDeviceOrientationChanged,
        }) {
          final manager = MockDeviceOrientationManager();
          when(manager.getUiOrientation()).thenAnswer((_) async {
            return 'PORTRAIT_UP';
          });
          return manager;
        };
    PigeonOverrides.aspectRatioStrategy_new =
        ({
          required AspectRatio preferredAspectRatio,
          required AspectRatioStrategyFallbackRule fallbackRule,
        }) => MockAspectRatioStrategy();
    PigeonOverrides.resolutionFilter_createWithOnePreferredSize =
        ({required CameraSize preferredSize}) => MockResolutionFilter();
    PigeonOverrides.camera2CameraInfo_from = ({required dynamic cameraInfo}) {
      final mockCamera2CameraInfo = MockCamera2CameraInfo();
      when(
        mockCamera2CameraInfo.getCameraCharacteristic(any),
      ).thenAnswer((_) async => 90);
      return mockCamera2CameraInfo;
    };
    PigeonOverrides.cameraSize_new =
        ({required int width, required int height}) => MockCameraSize();
    PigeonOverrides.cameraCharacteristics_sensorOrientation =
        MockCameraCharacteristicsKey();
    PigeonOverrides.cameraIntegerRange_new =
        ({required int lower, required int upper}) {
          return CameraIntegerRange.pigeon_detached(lower: 0, upper: 0);
        };

    final testCameraInitializedEvent = CameraInitializedEvent(
      cameraId,
      resolutionWidth.toDouble(),
      resolutionHeight.toDouble(),
      ExposureMode.auto,
      true,
      FocusMode.auto,
      true,
    );

    // Call createCamera.
    when(mockPreview.setSurfaceProvider(any)).thenAnswer((_) async => cameraId);

    when(
      mockProcessCameraProvider.bindToLifecycle(
        mockBackCameraSelector,
        <UseCase>[mockPreview, mockImageCapture, mockImageAnalysis],
      ),
    ).thenAnswer((_) async => mockCamera);
    when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
    when(
      mockCameraInfo.getCameraState(),
    ).thenAnswer((_) async => MockLiveCameraState());
    when(
      mockPreview.getResolutionInfo(),
    ).thenAnswer((_) async => testResolutionInfo);

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
      var stoppedListeningForDeviceOrientationChange = false;
      final camera = AndroidCameraCameraX();
      PigeonOverrides.deviceOrientationManager_new =
          ({
            required void Function(DeviceOrientationManager, String)
            onDeviceOrientationChanged,
          }) {
            final mockDeviceOrientationManager = MockDeviceOrientationManager();
            when(
              mockDeviceOrientationManager
                  .stopListeningForDeviceOrientationChange(),
            ).thenAnswer((_) async {
              stoppedListeningForDeviceOrientationChange = true;
            });
            return mockDeviceOrientationManager;
          };

      camera.preview = MockPreview();
      camera.processCameraProvider = MockProcessCameraProvider();
      camera.liveCameraState = MockLiveCameraState();
      camera.imageAnalysis = MockImageAnalysis();

      await camera.dispose(3);

      verify(camera.preview!.releaseSurfaceProvider());
      verify(camera.liveCameraState!.removeObservers());
      verify(camera.processCameraProvider!.unbindAll());
      verify(camera.imageAnalysis!.clearAnalyzer());
      expect(stoppedListeningForDeviceOrientationChange, isTrue);
    },
  );

  test('onCameraInitialized stream emits CameraInitializedEvents', () async {
    final camera = AndroidCameraCameraX();
    const cameraId = 16;
    final Stream<CameraInitializedEvent> eventStream = camera
        .onCameraInitialized(cameraId);
    final streamQueue = StreamQueue<CameraInitializedEvent>(eventStream);
    const testEvent = CameraInitializedEvent(
      cameraId,
      320,
      80,
      ExposureMode.auto,
      false,
      FocusMode.auto,
      false,
    );

    camera.cameraEventStreamController.add(testEvent);

    expect(await streamQueue.next, testEvent);
    await streamQueue.cancel();
  });

  test(
    'onCameraClosing stream emits camera closing event when cameraEventStreamController emits a camera closing event',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 99;
      const cameraClosingEvent = CameraClosingEvent(cameraId);
      final Stream<CameraClosingEvent> eventStream = camera.onCameraClosing(
        cameraId,
      );
      final streamQueue = StreamQueue<CameraClosingEvent>(eventStream);

      camera.cameraEventStreamController.add(cameraClosingEvent);

      expect(await streamQueue.next, equals(cameraClosingEvent));
      await streamQueue.cancel();
    },
  );

  test(
    'onCameraError stream emits errors caught by system services or added to stream within plugin',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 27;
      const firstTestErrorDescription = 'Test error description 1!';
      const secondTestErrorDescription = 'Test error description 2!';
      const secondCameraErrorEvent = CameraErrorEvent(
        cameraId,
        secondTestErrorDescription,
      );
      final Stream<CameraErrorEvent> eventStream = camera.onCameraError(
        cameraId,
      );
      final streamQueue = StreamQueue<CameraErrorEvent>(eventStream);

      PigeonOverrides.systemServicesManager_new =
          ({
            required void Function(SystemServicesManager, String) onCameraError,
          }) {
            final mockSystemServicesManager = MockSystemServicesManager();
            when(
              mockSystemServicesManager.onCameraError,
            ).thenReturn(onCameraError);
            return mockSystemServicesManager;
          };

      camera.systemServicesManager.onCameraError(
        camera.systemServicesManager,
        firstTestErrorDescription,
      );
      expect(
        await streamQueue.next,
        equals(const CameraErrorEvent(cameraId, firstTestErrorDescription)),
      );

      camera.cameraEventStreamController.add(secondCameraErrorEvent);
      expect(await streamQueue.next, equals(secondCameraErrorEvent));

      await streamQueue.cancel();
    },
  );

  test(
    'onDeviceOrientationChanged stream emits changes in device orientation detected by system services',
    () async {
      final camera = AndroidCameraCameraX();
      final Stream<DeviceOrientationChangedEvent> eventStream = camera
          .onDeviceOrientationChanged();
      final streamQueue = StreamQueue<DeviceOrientationChangedEvent>(
        eventStream,
      );
      const testEvent = DeviceOrientationChangedEvent(
        DeviceOrientation.portraitDown,
      );

      PigeonOverrides.deviceOrientationManager_new =
          ({
            required void Function(DeviceOrientationManager, String)
            onDeviceOrientationChanged,
          }) {
            final mockDeviceOrientationManager = MockDeviceOrientationManager();
            when(
              mockDeviceOrientationManager.onDeviceOrientationChanged,
            ).thenReturn(onDeviceOrientationChanged);
            return mockDeviceOrientationManager;
          };

      camera.deviceOrientationManager.onDeviceOrientationChanged(
        camera.deviceOrientationManager,
        'PORTRAIT_DOWN',
      );

      expect(await streamQueue.next, testEvent);
      await streamQueue.cancel();
    },
  );

  test(
    'pausePreview unbinds preview from lifecycle when preview is nonnull and has been bound to lifecycle',
    () async {
      final camera = AndroidCameraCameraX();

      // Set directly for test versus calling createCamera.
      camera.processCameraProvider = MockProcessCameraProvider();
      camera.preview = MockPreview();

      when(
        camera.processCameraProvider!.isBound(camera.preview!),
      ).thenAnswer((_) async => true);

      await camera.pausePreview(579);

      verify(camera.processCameraProvider!.unbind(<UseCase>[camera.preview!]));
    },
  );

  test(
    'pausePreview does not unbind preview from lifecycle when preview has not been bound to lifecycle',
    () async {
      final camera = AndroidCameraCameraX();

      // Set directly for test versus calling createCamera.
      camera.processCameraProvider = MockProcessCameraProvider();
      camera.preview = MockPreview();

      await camera.pausePreview(632);

      verifyNever(
        camera.processCameraProvider!.unbind(<UseCase>[camera.preview!]),
      );
    },
  );

  test(
    'resumePreview does not bind preview to lifecycle or update camera state observers if already bound',
    () async {
      final camera = AndroidCameraCameraX();
      final mockProcessCameraProvider = MockProcessCameraProvider();
      final mockCamera = MockCamera();
      final mockCameraInfo = MockCameraInfo();
      final mockLiveCameraState = MockLiveCameraState();

      // Set directly for test versus calling createCamera.
      camera.processCameraProvider = mockProcessCameraProvider;
      camera.cameraSelector = MockCameraSelector();
      camera.preview = MockPreview();

      when(
        camera.processCameraProvider!.isBound(camera.preview!),
      ).thenAnswer((_) async => true);

      when(
        mockProcessCameraProvider.bindToLifecycle(
          camera.cameraSelector,
          <UseCase>[camera.preview!],
        ),
      ).thenAnswer((_) async => mockCamera);
      when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => mockLiveCameraState);

      await camera.resumePreview(78);

      verifyNever(
        camera.processCameraProvider!.bindToLifecycle(
          camera.cameraSelector!,
          <UseCase>[camera.preview!],
        ),
      );
      verifyNever(mockLiveCameraState.observe(any));
      expect(camera.cameraInfo, isNot(mockCameraInfo));
    },
  );

  test(
    'resumePreview binds preview to lifecycle and updates camera state observers if not already bound',
    () async {
      final camera = AndroidCameraCameraX();
      final mockProcessCameraProvider = MockProcessCameraProvider();
      final mockCamera = MockCamera();
      final mockCameraInfo = MockCameraInfo();
      final mockCameraControl = MockCameraControl();
      final mockLiveCameraState = MockLiveCameraState();

      // Set directly for test versus calling createCamera.
      camera.processCameraProvider = mockProcessCameraProvider;
      camera.cameraSelector = MockCameraSelector();
      camera.preview = MockPreview();

      // Tell plugin to create a detached Observer<CameraState>, that is created to
      // track camera state once preview is bound to the lifecycle and needed to
      // test for expected updates.
      GenericsPigeonOverrides.observerNew =
          <T>({required void Function(Observer<T>, T) onChanged}) {
            return Observer<T>.detached(onChanged: onChanged);
          };

      when(
        mockProcessCameraProvider.bindToLifecycle(
          camera.cameraSelector,
          <UseCase>[camera.preview!],
        ),
      ).thenAnswer((_) async => mockCamera);
      when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => mockLiveCameraState);
      when(mockCamera.cameraControl).thenReturn(mockCameraControl);

      await camera.resumePreview(78);

      verify(
        camera.processCameraProvider!.bindToLifecycle(
          camera.cameraSelector!,
          <UseCase>[camera.preview!],
        ),
      );
      expect(
        await testCameraClosingObserver(
          camera,
          78,
          verify(mockLiveCameraState.observe(captureAny)).captured.single
              as Observer<dynamic>,
        ),
        isTrue,
      );
      expect(camera.cameraInfo, equals(mockCameraInfo));
      expect(camera.cameraControl, equals(mockCameraControl));
    },
  );

  // Further `buildPreview` testing concerning the Widget that it returns is
  // located in preview_rotation_test.dart.
  test(
    'buildPreview throws an exception if the preview is not bound to the lifecycle',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 73;

      // Tell camera that createCamera has not been called and thus, preview has
      // not been bound to the lifecycle of the camera.
      camera.previewInitiallyBound = false;

      expect(
        () => camera.buildPreview(cameraId),
        throwsA(isA<CameraException>()),
      );
    },
  );

  group('video recording', () {
    test(
      'startVideoCapturing binds video capture use case, updates saved camera instance and its properties, and starts the recording with audio enabled as desired',
      () async {
        // Set up mocks and constants.
        final camera = AndroidCameraCameraX();
        final mockPendingRecording = MockPendingRecording();
        final mockPendingRecordingWithAudio = MockPendingRecording();
        final mockRecording = MockRecording();
        final mockCamera = MockCamera();
        final newMockCamera = MockCamera();
        final mockCameraInfo = MockCameraInfo();
        final mockCameraControl = MockCameraControl();
        final mockLiveCameraState = MockLiveCameraState();
        final newMockLiveCameraState = MockLiveCameraState();
        final mockCamera2CameraInfo = MockCamera2CameraInfo();
        const enableAudio = true;

        // Set directly for test versus calling createCamera.
        camera.processCameraProvider = MockProcessCameraProvider();
        camera.camera = mockCamera;
        camera.recorder = MockRecorder();
        camera.videoCapture = MockVideoCapture();
        camera.cameraSelector = MockCameraSelector();
        camera.liveCameraState = mockLiveCameraState;
        camera.cameraInfo = MockCameraInfo();
        camera.imageAnalysis = MockImageAnalysis();
        camera.enableRecordingAudio = enableAudio;

        // Ignore setting target rotation for this test; tested separately.
        camera.captureOrientationLocked = true;

        // Tell plugin to create detached Observer when camera info updated.
        const outputPath = '/temp/REC123.mp4';
        GenericsPigeonOverrides.observerNew =
            <T>({required void Function(Observer<T>, T) onChanged}) {
              return Observer<T>.detached(onChanged: onChanged);
            };
        PigeonOverrides.camera2CameraInfo_from =
            ({required dynamic cameraInfo}) => mockCamera2CameraInfo;
        PigeonOverrides.systemServicesManager_new =
            ({
              required void Function(SystemServicesManager, String)
              onCameraError,
            }) {
              final mockSystemServicesManager = MockSystemServicesManager();
              when(
                mockSystemServicesManager.getTempFilePath(
                  camera.videoPrefix,
                  '.mp4',
                ),
              ).thenAnswer((_) async => outputPath);
              return mockSystemServicesManager;
            };
        PigeonOverrides.videoRecordEventListener_new =
            ({
              required void Function(VideoRecordEventListener, VideoRecordEvent)
              onEvent,
            }) {
              return VideoRecordEventListener.pigeon_detached(onEvent: onEvent);
            };
        PigeonOverrides.cameraCharacteristics_infoSupportedHardwareLevel =
            MockCameraCharacteristicsKey();

        const cameraId = 17;

        // Mock method calls.
        when(
          camera.recorder!.prepareRecording(outputPath),
        ).thenAnswer((_) async => mockPendingRecording);
        when(
          mockPendingRecording.withAudioEnabled(!enableAudio),
        ).thenAnswer((_) async => mockPendingRecordingWithAudio);
        when(
          mockPendingRecording.asPersistentRecording(),
        ).thenAnswer((_) async => mockPendingRecording);
        when(
          mockPendingRecordingWithAudio.start(any),
        ).thenAnswer((_) async => mockRecording);
        when(
          camera.processCameraProvider!.isBound(camera.videoCapture!),
        ).thenAnswer((_) async => false);
        when(
          camera.processCameraProvider!.bindToLifecycle(
            camera.cameraSelector!,
            <UseCase>[camera.videoCapture!],
          ),
        ).thenAnswer((_) async => newMockCamera);
        when(
          newMockCamera.getCameraInfo(),
        ).thenAnswer((_) async => mockCameraInfo);
        when(newMockCamera.cameraControl).thenReturn(mockCameraControl);
        when(
          mockCameraInfo.getCameraState(),
        ).thenAnswer((_) async => newMockLiveCameraState);
        when(
          mockCamera2CameraInfo.getCameraCharacteristic(any),
        ).thenAnswer((_) async => InfoSupportedHardwareLevel.limited);

        // Simulate video recording being started so startVideoRecording completes.
        AndroidCameraCameraX.videoRecordingEventStreamController.add(
          VideoRecordEventStart.pigeon_detached(),
        );

        await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));

        // Verify VideoCapture UseCase is bound and camera & its properties
        // are updated.
        verify(
          camera.processCameraProvider!.bindToLifecycle(
            camera.cameraSelector!,
            <UseCase>[camera.videoCapture!],
          ),
        );
        expect(camera.camera, equals(newMockCamera));
        expect(camera.cameraInfo, equals(mockCameraInfo));
        expect(camera.cameraControl, equals(mockCameraControl));
        verify(mockLiveCameraState.removeObservers());
        expect(
          await testCameraClosingObserver(
            camera,
            cameraId,
            verify(newMockLiveCameraState.observe(captureAny)).captured.single
                as Observer<dynamic>,
          ),
          isTrue,
        );

        // Verify recording is started.
        expect(camera.pendingRecording, equals(mockPendingRecordingWithAudio));
        expect(camera.recording, mockRecording);
      },
    );

    test(
      'startVideoCapturing binds video capture use case and starts the recording'
      ' on first call, and does nothing on second call',
      () async {
        // Set up mocks and constants.
        final camera = AndroidCameraCameraX();
        final mockPendingRecording = MockPendingRecording();
        final mockRecording = MockRecording();
        final mockCamera = MockCamera();
        final mockCameraInfo = MockCameraInfo();
        final mockCamera2CameraInfo = MockCamera2CameraInfo();

        // Set directly for test versus calling createCamera.
        camera.processCameraProvider = MockProcessCameraProvider();
        camera.recorder = MockRecorder();
        camera.videoCapture = MockVideoCapture();
        camera.cameraSelector = MockCameraSelector();
        camera.cameraInfo = MockCameraInfo();
        camera.imageAnalysis = MockImageAnalysis();
        camera.enableRecordingAudio = false;

        // Ignore setting target rotation for this test; tested seprately.
        camera.captureOrientationLocked = true;

        // Tell plugin to create detached Observer when camera info updated.
        const outputPath = '/temp/REC123.mp4';
        GenericsPigeonOverrides.observerNew =
            <T>({required void Function(Observer<T>, T) onChanged}) {
              return Observer<T>.detached(onChanged: onChanged);
            };
        PigeonOverrides.camera2CameraInfo_from =
            ({required dynamic cameraInfo}) => mockCamera2CameraInfo;
        PigeonOverrides.systemServicesManager_new =
            ({
              required void Function(SystemServicesManager, String)
              onCameraError,
            }) {
              final mockSystemServicesManager = MockSystemServicesManager();
              when(
                mockSystemServicesManager.getTempFilePath(
                  camera.videoPrefix,
                  '.mp4',
                ),
              ).thenAnswer((_) async => outputPath);
              return mockSystemServicesManager;
            };
        PigeonOverrides.videoRecordEventListener_new =
            ({
              required void Function(VideoRecordEventListener, VideoRecordEvent)
              onEvent,
            }) {
              return VideoRecordEventListener.pigeon_detached(onEvent: onEvent);
            };
        PigeonOverrides.cameraCharacteristics_infoSupportedHardwareLevel =
            MockCameraCharacteristicsKey();

        const cameraId = 17;

        // Mock method calls.
        when(
          camera.recorder!.prepareRecording(outputPath),
        ).thenAnswer((_) async => mockPendingRecording);
        when(
          mockPendingRecording.withAudioEnabled(!camera.enableRecordingAudio),
        ).thenAnswer((_) async => mockPendingRecording);
        when(
          mockPendingRecording.asPersistentRecording(),
        ).thenAnswer((_) async => mockPendingRecording);
        when(
          mockPendingRecording.start(any),
        ).thenAnswer((_) async => mockRecording);
        when(
          camera.processCameraProvider!.isBound(camera.videoCapture!),
        ).thenAnswer((_) async => false);
        when(
          camera.processCameraProvider!.bindToLifecycle(
            camera.cameraSelector!,
            <UseCase>[camera.videoCapture!],
          ),
        ).thenAnswer((_) async => mockCamera);
        when(
          mockCamera.getCameraInfo(),
        ).thenAnswer((_) => Future<CameraInfo>.value(mockCameraInfo));
        when(
          mockCameraInfo.getCameraState(),
        ).thenAnswer((_) async => MockLiveCameraState());
        when(
          mockCamera2CameraInfo.getCameraCharacteristic(any),
        ).thenAnswer((_) async => InfoSupportedHardwareLevel.limited);

        // Simulate video recording being started so startVideoRecording completes.
        AndroidCameraCameraX.videoRecordingEventStreamController.add(
          VideoRecordEventStart.pigeon_detached(),
        );

        await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));

        verify(
          camera.processCameraProvider!.bindToLifecycle(
            camera.cameraSelector!,
            <UseCase>[camera.videoCapture!],
          ),
        );
        expect(camera.pendingRecording, equals(mockPendingRecording));
        expect(camera.recording, mockRecording);

        await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));
        // Verify that each of these calls happened only once.
        verify(
          camera.systemServicesManager.getTempFilePath(
            camera.videoPrefix,
            '.mp4',
          ),
        ).called(1);
        verifyNoMoreInteractions(camera.systemServicesManager);
        verify(camera.recorder!.prepareRecording(outputPath)).called(1);
        verifyNoMoreInteractions(camera.recorder);
        verify(mockPendingRecording.start(any)).called(1);
        verify(mockPendingRecording.withAudioEnabled(any)).called(1);
        verify(mockPendingRecording.asPersistentRecording()).called(1);
        verifyNoMoreInteractions(mockPendingRecording);
      },
    );

    test(
      'startVideoCapturing called with stream options starts image streaming',
      () async {
        // Set up mocks and constants.
        final camera = AndroidCameraCameraX();
        final mockProcessCameraProvider = MockProcessCameraProvider();
        final Recorder mockRecorder = MockRecorder();
        final mockPendingRecording = MockPendingRecording();
        final initialCameraInfo = MockCameraInfo();
        final mockCamera2CameraInfo = MockCamera2CameraInfo();

        // Set directly for test versus calling createCamera.

        camera.processCameraProvider = mockProcessCameraProvider;
        camera.cameraSelector = MockCameraSelector();
        camera.videoCapture = MockVideoCapture();
        camera.imageAnalysis = MockImageAnalysis();
        camera.camera = MockCamera();
        camera.recorder = mockRecorder;
        camera.cameraInfo = initialCameraInfo;
        camera.imageCapture = MockImageCapture();
        camera.enableRecordingAudio = true;

        // Ignore setting target rotation for this test; tested seprately.
        camera.captureOrientationLocked = true;

        // Tell plugin to create detached Analyzer for testing.
        const outputPath = '/temp/REC123.mp4';
        GenericsPigeonOverrides.observerNew =
            <T>({required void Function(Observer<T>, T) onChanged}) {
              return Observer<T>.detached(onChanged: onChanged);
            };
        PigeonOverrides.camera2CameraInfo_from =
            ({required dynamic cameraInfo}) => mockCamera2CameraInfo;
        PigeonOverrides.systemServicesManager_new =
            ({
              required void Function(SystemServicesManager, String)
              onCameraError,
            }) {
              final mockSystemServicesManager = MockSystemServicesManager();
              when(
                mockSystemServicesManager.getTempFilePath(
                  camera.videoPrefix,
                  '.mp4',
                ),
              ).thenAnswer((_) async => outputPath);
              return mockSystemServicesManager;
            };
        PigeonOverrides.videoRecordEventListener_new =
            ({
              required void Function(VideoRecordEventListener, VideoRecordEvent)
              onEvent,
            }) {
              return VideoRecordEventListener.pigeon_detached(onEvent: onEvent);
            };
        PigeonOverrides.cameraCharacteristics_infoSupportedHardwareLevel =
            MockCameraCharacteristicsKey();
        PigeonOverrides.analyzer_new =
            ({required void Function(Analyzer, ImageProxy) analyze}) {
              return MockAnalyzer();
            };

        const cameraId = 17;
        final imageDataCompleter = Completer<CameraImageData>();
        final videoCaptureOptions = VideoCaptureOptions(
          cameraId,
          streamCallback: (CameraImageData imageData) =>
              imageDataCompleter.complete(imageData),
        );

        // Mock method calls.
        when(
          camera.processCameraProvider!.isBound(camera.videoCapture!),
        ).thenAnswer((_) async => true);
        when(
          camera.processCameraProvider!.isBound(camera.imageAnalysis!),
        ).thenAnswer((_) async => true);
        when(
          camera.recorder!.prepareRecording(outputPath),
        ).thenAnswer((_) async => mockPendingRecording);
        when(
          mockPendingRecording.withAudioEnabled(!camera.enableRecordingAudio),
        ).thenAnswer((_) async => mockPendingRecording);
        when(
          mockPendingRecording.asPersistentRecording(),
        ).thenAnswer((_) async => mockPendingRecording);
        when(
          mockProcessCameraProvider.bindToLifecycle(any, any),
        ).thenAnswer((_) => Future<Camera>.value(camera.camera));
        when(
          camera.camera!.getCameraInfo(),
        ).thenAnswer((_) => Future<CameraInfo>.value(MockCameraInfo()));
        when(
          mockCamera2CameraInfo.getCameraCharacteristic(any),
        ).thenAnswer((_) async => InfoSupportedHardwareLevel.level3);

        // Simulate video recording being started so startVideoRecording completes.
        AndroidCameraCameraX.videoRecordingEventStreamController.add(
          VideoRecordEventStart.pigeon_detached(),
        );

        await camera.startVideoCapturing(videoCaptureOptions);

        final CameraImageData mockCameraImageData = MockCameraImageData();
        camera.cameraImageDataStreamController!.add(mockCameraImageData);

        expect(imageDataCompleter.future, isNotNull);
        await camera.cameraImageDataStreamController!.close();
      },
    );

    test(
      'startVideoCapturing sets VideoCapture target rotation to current video orientation if orientation unlocked',
      () async {
        // Set up mocks and constants.
        final camera = AndroidCameraCameraX();
        final mockPendingRecording = MockPendingRecording();
        final mockRecording = MockRecording();
        final mockVideoCapture = MockVideoCapture();
        final initialCameraInfo = MockCameraInfo();
        final mockCamera2CameraInfo = MockCamera2CameraInfo();
        const int defaultTargetRotation = Surface.rotation270;

        // Set directly for test versus calling createCamera.
        camera.processCameraProvider = MockProcessCameraProvider();
        camera.camera = MockCamera();
        camera.recorder = MockRecorder();
        camera.videoCapture = mockVideoCapture;
        camera.cameraSelector = MockCameraSelector();
        camera.imageAnalysis = MockImageAnalysis();
        camera.cameraInfo = initialCameraInfo;
        camera.enableRecordingAudio = false;

        // Tell plugin to mock call to get current video orientation and mock Camera2CameraInfo retrieval.
        const outputPath = '/temp/REC123.mp4';
        GenericsPigeonOverrides.observerNew =
            <T>({required void Function(Observer<T>, T) onChanged}) {
              return Observer<T>.detached(onChanged: onChanged);
            };
        PigeonOverrides.camera2CameraInfo_from =
            ({required dynamic cameraInfo}) => cameraInfo == initialCameraInfo
            ? mockCamera2CameraInfo
            : MockCamera2CameraInfo();
        PigeonOverrides.systemServicesManager_new =
            ({
              required void Function(SystemServicesManager, String)
              onCameraError,
            }) {
              final mockSystemServicesManager = MockSystemServicesManager();
              when(
                mockSystemServicesManager.getTempFilePath(
                  camera.videoPrefix,
                  '.mp4',
                ),
              ).thenAnswer((_) async => outputPath);
              return mockSystemServicesManager;
            };
        PigeonOverrides.deviceOrientationManager_new =
            ({
              required void Function(DeviceOrientationManager, String)
              onDeviceOrientationChanged,
            }) {
              final mockDeviceOrientationManager =
                  MockDeviceOrientationManager();
              when(
                mockDeviceOrientationManager.getDefaultDisplayRotation(),
              ).thenAnswer((_) async => defaultTargetRotation);
              return mockDeviceOrientationManager;
            };
        PigeonOverrides.videoRecordEventListener_new =
            ({
              required void Function(VideoRecordEventListener, VideoRecordEvent)
              onEvent,
            }) {
              return VideoRecordEventListener.pigeon_detached(onEvent: onEvent);
            };
        PigeonOverrides.cameraCharacteristics_infoSupportedHardwareLevel =
            MockCameraCharacteristicsKey();

        const cameraId = 87;

        // Mock method calls.
        when(
          camera.recorder!.prepareRecording(outputPath),
        ).thenAnswer((_) async => mockPendingRecording);
        when(
          mockPendingRecording.withAudioEnabled(!camera.enableRecordingAudio),
        ).thenAnswer((_) async => mockPendingRecording);
        when(
          mockPendingRecording.asPersistentRecording(),
        ).thenAnswer((_) async => mockPendingRecording);
        when(
          mockPendingRecording.start(any),
        ).thenAnswer((_) async => mockRecording);
        when(
          camera.processCameraProvider!.isBound(camera.videoCapture!),
        ).thenAnswer((_) async => true);
        when(
          camera.processCameraProvider!.isBound(camera.imageAnalysis!),
        ).thenAnswer((_) async => false);
        when(
          mockCamera2CameraInfo.getCameraCharacteristic(any),
        ).thenAnswer((_) async => InfoSupportedHardwareLevel.limited);

        // Simulate video recording being started so startVideoRecording completes.
        AndroidCameraCameraX.videoRecordingEventStreamController.add(
          VideoRecordEventStart.pigeon_detached(),
        );

        // Orientation is unlocked and plugin does not need to set default target
        // rotation manually.
        camera.recording = null;
        await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));
        verifyNever(mockVideoCapture.setTargetRotation(any));

        // Simulate video recording being started so startVideoRecording completes.
        AndroidCameraCameraX.videoRecordingEventStreamController.add(
          VideoRecordEventStart.pigeon_detached(),
        );

        // Orientation is locked and plugin does not need to set default target
        // rotation manually.
        camera.recording = null;
        camera.captureOrientationLocked = true;
        await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));
        verifyNever(mockVideoCapture.setTargetRotation(any));

        // Simulate video recording being started so startVideoRecording completes.
        AndroidCameraCameraX.videoRecordingEventStreamController.add(
          VideoRecordEventStart.pigeon_detached(),
        );

        // Orientation is locked and plugin does need to set default target
        // rotation manually.
        camera.recording = null;
        camera.captureOrientationLocked = true;
        camera.shouldSetDefaultRotation = true;
        await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));
        verifyNever(mockVideoCapture.setTargetRotation(any));

        // Simulate video recording being started so startVideoRecording completes.
        AndroidCameraCameraX.videoRecordingEventStreamController.add(
          VideoRecordEventStart.pigeon_detached(),
        );

        // Orientation is unlocked and plugin does need to set default target
        // rotation manually.
        camera.recording = null;
        camera.captureOrientationLocked = false;
        camera.shouldSetDefaultRotation = true;
        await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));
        verify(mockVideoCapture.setTargetRotation(defaultTargetRotation));
      },
    );

    test('pauseVideoRecording pauses the recording', () async {
      final camera = AndroidCameraCameraX();
      final recording = MockRecording();

      // Set directly for test versus calling startVideoCapturing.
      camera.recording = recording;

      await camera.pauseVideoRecording(0);
      verify(recording.pause());
      verifyNoMoreInteractions(recording);
    });

    test('resumeVideoRecording resumes the recording', () async {
      final camera = AndroidCameraCameraX();
      final recording = MockRecording();

      // Set directly for test versus calling startVideoCapturing.
      camera.recording = recording;

      await camera.resumeVideoRecording(0);
      verify(recording.resume());
      verifyNoMoreInteractions(recording);
    });

    test('stopVideoRecording stops the recording', () async {
      final camera = AndroidCameraCameraX();
      final recording = MockRecording();
      final processCameraProvider = MockProcessCameraProvider();
      final videoCapture = MockVideoCapture();
      const videoOutputPath = '/test/output/path';

      // Set directly for test versus calling createCamera and startVideoCapturing.
      camera.processCameraProvider = processCameraProvider;
      camera.recording = recording;
      camera.videoCapture = videoCapture;
      camera.videoOutputPath = videoOutputPath;

      // Tell plugin that videoCapture use case was bound to start recording.
      when(
        camera.processCameraProvider!.isBound(videoCapture),
      ).thenAnswer((_) async => true);

      // Simulate video recording being finalized so stopVideoRecording completes.
      AndroidCameraCameraX.videoRecordingEventStreamController.add(
        VideoRecordEventFinalize.pigeon_detached(),
      );

      final XFile file = await camera.stopVideoRecording(0);
      expect(file.path, videoOutputPath);

      // Verify that recording stops.
      verify(recording.close());
      verifyNoMoreInteractions(recording);
    });

    test('stopVideoRecording throws a camera exception if '
        'no recording is in progress', () async {
      final camera = AndroidCameraCameraX();
      const videoOutputPath = '/test/output/path';

      // Set directly for test versus calling startVideoCapturing.
      camera.recording = null;
      camera.videoOutputPath = videoOutputPath;

      await expectLater(() async {
        await camera.stopVideoRecording(0);
      }, throwsA(isA<CameraException>()));
    });

    test('stopVideoRecording throws a camera exception if '
        'videoOutputPath is null, and sets recording to null', () async {
      final camera = AndroidCameraCameraX();
      final mockRecording = MockRecording();
      final mockVideoCapture = MockVideoCapture();

      // Set directly for test versus calling startVideoCapturing.
      camera.processCameraProvider = MockProcessCameraProvider();
      camera.recording = mockRecording;
      camera.videoOutputPath = null;
      camera.videoCapture = mockVideoCapture;

      // Tell plugin that videoCapture use case was bound to start recording.
      when(
        camera.processCameraProvider!.isBound(mockVideoCapture),
      ).thenAnswer((_) async => true);

      await expectLater(() async {
        // Simulate video recording being finalized so stopVideoRecording completes.
        AndroidCameraCameraX.videoRecordingEventStreamController.add(
          VideoRecordEventFinalize.pigeon_detached(),
        );
        await camera.stopVideoRecording(0);
      }, throwsA(isA<CameraException>()));
      expect(camera.recording, null);
    });

    test('calling stopVideoRecording twice stops the recording '
        'and then throws a CameraException', () async {
      final camera = AndroidCameraCameraX();
      final recording = MockRecording();
      final processCameraProvider = MockProcessCameraProvider();
      final videoCapture = MockVideoCapture();
      const videoOutputPath = '/test/output/path';

      // Set directly for test versus calling createCamera and startVideoCapturing.
      camera.processCameraProvider = processCameraProvider;
      camera.recording = recording;
      camera.videoCapture = videoCapture;
      camera.videoOutputPath = videoOutputPath;

      // Simulate video recording being finalized so stopVideoRecording completes.
      AndroidCameraCameraX.videoRecordingEventStreamController.add(
        VideoRecordEventFinalize.pigeon_detached(),
      );

      final XFile file = await camera.stopVideoRecording(0);
      expect(file.path, videoOutputPath);

      await expectLater(() async {
        await camera.stopVideoRecording(0);
      }, throwsA(isA<CameraException>()));
    });

    test(
      'VideoCapture use case is unbound from lifecycle when video recording stops',
      () async {
        final camera = AndroidCameraCameraX();
        final recording = MockRecording();
        final processCameraProvider = MockProcessCameraProvider();
        final videoCapture = MockVideoCapture();
        const videoOutputPath = '/test/output/path';

        // Set directly for test versus calling createCamera and startVideoCapturing.
        camera.processCameraProvider = processCameraProvider;
        camera.recording = recording;
        camera.videoCapture = videoCapture;
        camera.videoOutputPath = videoOutputPath;

        // Tell plugin that videoCapture use case was bound to start recording.
        when(
          camera.processCameraProvider!.isBound(videoCapture),
        ).thenAnswer((_) async => true);

        // Simulate video recording being finalized so stopVideoRecording completes.
        AndroidCameraCameraX.videoRecordingEventStreamController.add(
          VideoRecordEventFinalize.pigeon_detached(),
        );

        await camera.stopVideoRecording(90);
        verify(processCameraProvider.unbind(<UseCase>[videoCapture]));

        // Verify that recording stops.
        verify(recording.close());
        verifyNoMoreInteractions(recording);
      },
    );

    test('setDescriptionWhileRecording changes the camera description', () async {
      final camera = AndroidCameraCameraX();
      final mockRecording = MockRecording();
      final mockPendingRecording = MockPendingRecording();
      final mockRecorder = MockRecorder();

      const testSensorOrientation = 90;
      const testBackCameraDescription = CameraDescription(
        name: 'Camera 0',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: testSensorOrientation,
      );
      const testFrontCameraDescription = CameraDescription(
        name: 'Camera 1',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: testSensorOrientation,
      );

      // Mock/Detached objects for (typically attached) objects created by
      // createCamera.
      final mockProcessCameraProvider = MockProcessCameraProvider();
      final mockPreview = MockPreview();
      final mockCamera = MockCamera();
      final newMockCamera = MockCamera();
      final mockLiveCameraState = MockLiveCameraState();
      final newMockLiveCameraState = MockLiveCameraState();
      final mockCameraInfo = MockCameraInfo();
      final mockCameraControl = MockCameraControl();
      final mockImageCapture = MockImageCapture();
      final mockImageAnalysis = MockImageAnalysis();
      final mockVideoCapture = MockVideoCapture();
      final mockBackCameraSelector = MockCameraSelector();
      final mockFrontCameraSelector = MockCameraSelector();
      final mockFrontCameraInfo = MockCameraInfo();
      final mockBackCameraInfo = MockCameraInfo();
      final mockCameraCharacteristicsKey = MockCameraCharacteristicsKey();

      const outputPath = 'file/output.mp4';

      PigeonOverrides.preview_new =
          ({
            ResolutionSelector? resolutionSelector,
            int? targetRotation,
            CameraIntegerRange? targetFpsRange,
          }) {
            when(
              mockPreview.setSurfaceProvider(any),
            ).thenAnswer((_) async => 19);
            final testResolutionInfo = ResolutionInfo.pigeon_detached(
              resolution: MockCameraSize(),
            );
            when(
              mockPreview.surfaceProducerHandlesCropAndRotation(),
            ).thenAnswer((_) async => false);
            when(mockPreview.resolutionSelector).thenReturn(resolutionSelector);
            when(
              mockPreview.getResolutionInfo(),
            ).thenAnswer((_) async => testResolutionInfo);
            return mockPreview;
          };
      PigeonOverrides.imageCapture_new =
          ({
            CameraXFlashMode? flashMode,
            ResolutionSelector? resolutionSelector,
            int? targetRotation,
          }) {
            return mockImageCapture;
          };
      PigeonOverrides.recorder_new =
          ({
            int? aspectRatio,
            QualitySelector? qualitySelector,
            int? targetVideoEncodingBitRate,
          }) {
            when(
              mockRecorder.prepareRecording(outputPath),
            ).thenAnswer((_) async => mockPendingRecording);
            return mockRecorder;
          };
      PigeonOverrides.videoCapture_withOutput =
          ({
            required VideoOutput videoOutput,
            CameraIntegerRange? targetFpsRange,
          }) {
            return mockVideoCapture;
          };
      PigeonOverrides.imageAnalysis_new =
          ({
            int? outputImageFormat,
            ResolutionSelector? resolutionSelector,
            int? targetRotation,
            CameraIntegerRange? targetFpsRange,
          }) {
            return mockImageAnalysis;
          };
      PigeonOverrides.cameraSelector_new =
          ({LensFacing? requireLensFacing, dynamic cameraInfoForFilter}) {
            if (cameraInfoForFilter == mockFrontCameraInfo) {
              return mockFrontCameraSelector;
            }
            return mockBackCameraSelector;
          };
      PigeonOverrides.deviceOrientationManager_new =
          ({
            required void Function(DeviceOrientationManager, String)
            onDeviceOrientationChanged,
          }) {
            final manager = MockDeviceOrientationManager();
            when(manager.getUiOrientation()).thenAnswer((_) async {
              return 'PORTRAIT_UP';
            });
            return manager;
          };
      PigeonOverrides.camera2CameraInfo_from = ({required dynamic cameraInfo}) {
        final camera2cameraInfo = MockCamera2CameraInfo();
        when(
          camera2cameraInfo.getCameraCharacteristic(any),
        ).thenAnswer((_) async => InfoSupportedHardwareLevel.limited);
        return camera2cameraInfo;
      };
      PigeonOverrides.cameraCharacteristics_sensorOrientation =
          mockCameraCharacteristicsKey;
      GenericsPigeonOverrides.observerNew =
          <T>({required void Function(Observer<T>, T) onChanged}) {
            return Observer<T>.detached(onChanged: onChanged);
          };
      PigeonOverrides.systemServicesManager_new =
          ({
            required void Function(SystemServicesManager, String) onCameraError,
          }) {
            final mockSystemServicesManager = MockSystemServicesManager();
            when(
              mockSystemServicesManager.getTempFilePath(
                camera.videoPrefix,
                '.mp4',
              ),
            ).thenAnswer((_) async => outputPath);
            return mockSystemServicesManager;
          };
      PigeonOverrides.videoRecordEventListener_new =
          ({
            required void Function(VideoRecordEventListener, VideoRecordEvent)
            onEvent,
          }) {
            return VideoRecordEventListener.pigeon_detached(onEvent: onEvent);
          };
      PigeonOverrides.cameraCharacteristics_infoSupportedHardwareLevel =
          MockCameraCharacteristicsKey();

      // mock functions
      when(mockProcessCameraProvider.getAvailableCameraInfos()).thenAnswer(
        (_) async => <MockCameraInfo>[mockBackCameraInfo, mockFrontCameraInfo],
      );
      when(
        mockProcessCameraProvider.bindToLifecycle(any, any),
      ).thenAnswer((_) async => mockCamera);
      when(
        mockBackCameraSelector.filter(<MockCameraInfo>[mockBackCameraInfo]),
      ).thenAnswer((_) async => <MockCameraInfo>[mockBackCameraInfo]);
      when(
        mockBackCameraSelector.filter(<MockCameraInfo>[mockFrontCameraInfo]),
      ).thenAnswer((_) async => <MockCameraInfo>[mockFrontCameraInfo]);
      when(
        mockFrontCameraSelector.filter(<MockCameraInfo>[mockBackCameraInfo]),
      ).thenAnswer((_) async => <MockCameraInfo>[mockBackCameraInfo]);
      when(
        mockFrontCameraSelector.filter(<MockCameraInfo>[mockFrontCameraInfo]),
      ).thenAnswer((_) async => <MockCameraInfo>[mockFrontCameraInfo]);

      camera.processCameraProvider = mockProcessCameraProvider;
      camera.liveCameraState = mockLiveCameraState;
      camera.enableRecordingAudio = false;
      when(
        mockPendingRecording.withAudioEnabled(any),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.asPersistentRecording(),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.start(any),
      ).thenAnswer((_) async => mockRecording);
      when(
        camera.processCameraProvider!.isBound(mockImageCapture),
      ).thenAnswer((_) async => true);
      when(
        camera.processCameraProvider!.isBound(mockImageAnalysis),
      ).thenAnswer((_) async => true);
      when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
      when(mockCamera.cameraControl).thenAnswer((_) => mockCameraControl);
      when(
        camera.processCameraProvider?.bindToLifecycle(
          mockFrontCameraSelector,
          <UseCase>[
            mockVideoCapture,
            mockPreview,
            mockImageCapture,
            mockImageAnalysis,
          ],
        ),
      ).thenAnswer((_) async => newMockCamera);
      when(
        newMockCamera.getCameraInfo(),
      ).thenAnswer((_) async => mockCameraInfo);
      when(newMockCamera.cameraControl).thenReturn(mockCameraControl);
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => newMockLiveCameraState);

      // Simulate video recording being started so startVideoRecording completes.
      AndroidCameraCameraX.videoRecordingEventStreamController.add(
        VideoRecordEventStart.pigeon_detached(),
      );

      await camera.availableCameras();

      final int flutterSurfaceTextureId = await camera.createCameraWithSettings(
        testBackCameraDescription,
        const MediaSettings(enableAudio: true),
      );
      await camera.initializeCamera(flutterSurfaceTextureId);

      await camera.startVideoCapturing(
        VideoCaptureOptions(flutterSurfaceTextureId),
      );
      await camera.setDescriptionWhileRecording(testFrontCameraDescription);

      //verify front camera selected and camera properties updated
      verify(camera.processCameraProvider?.unbindAll()).called(2);
      verify(
        camera.processCameraProvider?.bindToLifecycle(
          mockFrontCameraSelector,
          <UseCase>[
            mockVideoCapture,
            mockPreview,
            mockImageCapture,
            mockImageAnalysis,
          ],
        ),
      ).called(1);
      expect(camera.camera, equals(newMockCamera));
      expect(camera.cameraInfo, equals(mockCameraInfo));
      expect(camera.cameraControl, equals(mockCameraControl));
      verify(mockLiveCameraState.removeObservers());
      for (final Object? observer in verify(
        newMockLiveCameraState.observe(captureAny),
      ).captured) {
        expect(
          await testCameraClosingObserver(
            camera,
            flutterSurfaceTextureId,
            observer! as Observer<dynamic>,
          ),
          isTrue,
        );
      }

      //verify back camera selected
      await camera.setDescriptionWhileRecording(testBackCameraDescription);
      verify(
        camera.processCameraProvider?.bindToLifecycle(
          mockBackCameraSelector,
          <UseCase>[
            mockVideoCapture,
            mockPreview,
            mockImageCapture,
            mockImageAnalysis,
          ],
        ),
      ).called(1);
    });

    test('setDescriptionWhileRecording does not resume paused preview', () async {
      final camera = AndroidCameraCameraX();
      final mockRecording = MockRecording();
      final mockPendingRecording = MockPendingRecording();
      final mockRecorder = MockRecorder();

      const testSensorOrientation = 90;
      const testBackCameraDescription = CameraDescription(
        name: 'Camera 0',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: testSensorOrientation,
      );
      const testFrontCameraDescription = CameraDescription(
        name: 'Camera 1',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: testSensorOrientation,
      );

      // Mock/Detached objects for (typically attached) objects created by
      // createCamera.
      final mockProcessCameraProvider = MockProcessCameraProvider();
      final mockPreview = MockPreview();
      final mockCamera = MockCamera();
      final mockCameraInfo = MockCameraInfo();
      final mockCameraControl = MockCameraControl();
      final mockImageCapture = MockImageCapture();
      final mockImageAnalysis = MockImageAnalysis();
      final mockVideoCapture = MockVideoCapture();
      final mockBackCameraSelector = MockCameraSelector();
      final mockFrontCameraSelector = MockCameraSelector();
      final mockFrontCameraInfo = MockCameraInfo();
      final mockBackCameraInfo = MockCameraInfo();
      final mockCameraCharacteristicsKey = MockCameraCharacteristicsKey();

      const outputPath = 'file/output.mp4';

      PigeonOverrides.preview_new =
          ({
            ResolutionSelector? resolutionSelector,
            int? targetRotation,
            CameraIntegerRange? targetFpsRange,
          }) {
            when(
              mockPreview.setSurfaceProvider(any),
            ).thenAnswer((_) async => 19);
            final testResolutionInfo = ResolutionInfo.pigeon_detached(
              resolution: MockCameraSize(),
            );
            when(
              mockPreview.surfaceProducerHandlesCropAndRotation(),
            ).thenAnswer((_) async => false);
            when(mockPreview.resolutionSelector).thenReturn(resolutionSelector);
            when(
              mockPreview.getResolutionInfo(),
            ).thenAnswer((_) async => testResolutionInfo);
            return mockPreview;
          };
      PigeonOverrides.imageCapture_new =
          ({
            CameraXFlashMode? flashMode,
            ResolutionSelector? resolutionSelector,
            int? targetRotation,
          }) {
            return mockImageCapture;
          };
      PigeonOverrides.recorder_new =
          ({
            int? aspectRatio,
            QualitySelector? qualitySelector,
            int? targetVideoEncodingBitRate,
          }) {
            when(
              mockRecorder.prepareRecording(outputPath),
            ).thenAnswer((_) async => mockPendingRecording);
            return mockRecorder;
          };
      PigeonOverrides.videoCapture_withOutput =
          ({
            required VideoOutput videoOutput,
            CameraIntegerRange? targetFpsRange,
          }) {
            return mockVideoCapture;
          };
      PigeonOverrides.imageAnalysis_new =
          ({
            int? outputImageFormat,
            ResolutionSelector? resolutionSelector,
            int? targetRotation,
            CameraIntegerRange? targetFpsRange,
          }) {
            return mockImageAnalysis;
          };
      PigeonOverrides.cameraSelector_new =
          ({LensFacing? requireLensFacing, dynamic cameraInfoForFilter}) {
            if (cameraInfoForFilter == mockFrontCameraInfo) {
              return mockFrontCameraSelector;
            }
            return mockBackCameraSelector;
          };
      PigeonOverrides.deviceOrientationManager_new =
          ({
            required void Function(DeviceOrientationManager, String)
            onDeviceOrientationChanged,
          }) {
            final manager = MockDeviceOrientationManager();
            when(manager.getUiOrientation()).thenAnswer((_) async {
              return 'PORTRAIT_UP';
            });
            return manager;
          };
      PigeonOverrides.camera2CameraInfo_from = ({required dynamic cameraInfo}) {
        final camera2cameraInfo = MockCamera2CameraInfo();
        when(
          camera2cameraInfo.getCameraCharacteristic(any),
        ).thenAnswer((_) async => InfoSupportedHardwareLevel.limited);
        return camera2cameraInfo;
      };
      PigeonOverrides.cameraCharacteristics_sensorOrientation =
          mockCameraCharacteristicsKey;
      GenericsPigeonOverrides.observerNew =
          <T>({required void Function(Observer<T>, T) onChanged}) {
            return Observer<T>.detached(onChanged: onChanged);
          };
      PigeonOverrides.systemServicesManager_new =
          ({
            required void Function(SystemServicesManager, String) onCameraError,
          }) {
            final mockSystemServicesManager = MockSystemServicesManager();
            when(
              mockSystemServicesManager.getTempFilePath(
                camera.videoPrefix,
                '.mp4',
              ),
            ).thenAnswer((_) async => outputPath);
            return mockSystemServicesManager;
          };
      PigeonOverrides.videoRecordEventListener_new =
          ({
            required void Function(VideoRecordEventListener, VideoRecordEvent)
            onEvent,
          }) {
            return VideoRecordEventListener.pigeon_detached(onEvent: onEvent);
          };
      PigeonOverrides.cameraCharacteristics_infoSupportedHardwareLevel =
          MockCameraCharacteristicsKey();

      // mock functions
      when(mockProcessCameraProvider.getAvailableCameraInfos()).thenAnswer(
        (_) async => <MockCameraInfo>[mockBackCameraInfo, mockFrontCameraInfo],
      );
      when(
        mockProcessCameraProvider.bindToLifecycle(any, any),
      ).thenAnswer((_) async => mockCamera);
      when(
        mockBackCameraSelector.filter(<MockCameraInfo>[mockBackCameraInfo]),
      ).thenAnswer((_) async => <MockCameraInfo>[mockBackCameraInfo]);
      when(
        mockBackCameraSelector.filter(<MockCameraInfo>[mockFrontCameraInfo]),
      ).thenAnswer((_) async => <MockCameraInfo>[mockFrontCameraInfo]);
      when(
        mockFrontCameraSelector.filter(<MockCameraInfo>[mockBackCameraInfo]),
      ).thenAnswer((_) async => <MockCameraInfo>[mockBackCameraInfo]);
      when(
        mockFrontCameraSelector.filter(<MockCameraInfo>[mockFrontCameraInfo]),
      ).thenAnswer((_) async => <MockCameraInfo>[mockFrontCameraInfo]);

      camera.processCameraProvider = mockProcessCameraProvider;
      camera.enableRecordingAudio = false;
      when(
        mockPendingRecording.withAudioEnabled(any),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.asPersistentRecording(),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.start(any),
      ).thenAnswer((_) async => mockRecording);
      when(
        camera.processCameraProvider!.isBound(mockImageCapture),
      ).thenAnswer((_) async => true);
      when(
        camera.processCameraProvider!.isBound(mockImageAnalysis),
      ).thenAnswer((_) async => true);
      when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => MockLiveCameraState());
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => MockLiveCameraState());
      when(mockCamera.cameraControl).thenAnswer((_) => mockCameraControl);

      // Simulate video recording being started so startVideoRecording completes.
      AndroidCameraCameraX.videoRecordingEventStreamController.add(
        VideoRecordEventStart.pigeon_detached(),
      );

      await camera.availableCameras();

      final int flutterSurfaceTextureId = await camera.createCameraWithSettings(
        testBackCameraDescription,
        const MediaSettings(enableAudio: true),
      );
      await camera.initializeCamera(flutterSurfaceTextureId);

      await camera.startVideoCapturing(
        VideoCaptureOptions(flutterSurfaceTextureId),
      );

      // pause the preview
      await camera.pausePreview(flutterSurfaceTextureId);

      await camera.setDescriptionWhileRecording(testFrontCameraDescription);

      // verify preview not bound to lifecycle
      verify(camera.processCameraProvider?.unbindAll()).called(2);
      verify(
        camera.processCameraProvider?.bindToLifecycle(
          mockFrontCameraSelector,
          <UseCase>[mockVideoCapture, mockImageCapture, mockImageAnalysis],
        ),
      ).called(1);
    });
  });

  test(
    'takePicture binds ImageCapture to lifecycle and makes call to take a picture',
    () async {
      final camera = AndroidCameraCameraX();
      final mockProcessCameraProvider = MockProcessCameraProvider();
      final mockCamera = MockCamera();
      final mockCameraInfo = MockCameraInfo();
      const testPicturePath = 'test/absolute/path/to/picture';

      // Set directly for test versus calling createCamera.
      camera.imageCapture = MockImageCapture();
      camera.processCameraProvider = mockProcessCameraProvider;
      camera.cameraSelector = MockCameraSelector();

      // Ignore setting target rotation for this test; tested seprately.
      camera.captureOrientationLocked = true;

      // Tell plugin to create detached camera state observers.
      GenericsPigeonOverrides.observerNew =
          <T>({required void Function(Observer<T>, T) onChanged}) {
            return Observer<T>.detached(onChanged: onChanged);
          };

      when(
        mockProcessCameraProvider.isBound(camera.imageCapture),
      ).thenAnswer((_) async => false);
      when(
        mockProcessCameraProvider.bindToLifecycle(
          camera.cameraSelector,
          <UseCase>[camera.imageCapture!],
        ),
      ).thenAnswer((_) async => mockCamera);
      when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => MockLiveCameraState());
      when(
        camera.imageCapture!.takePicture(),
      ).thenAnswer((_) async => testPicturePath);

      final XFile imageFile = await camera.takePicture(3);

      expect(imageFile.path, equals(testPicturePath));
    },
  );

  test(
    'takePicture sets ImageCapture target rotation as expected when orientation locked or unlocked',
    () async {
      final camera = AndroidCameraCameraX();
      final mockImageCapture = MockImageCapture();
      final mockProcessCameraProvider = MockProcessCameraProvider();

      const cameraId = 3;
      const int defaultTargetRotation = Surface.rotation180;

      // Set directly for test versus calling createCamera.
      camera.imageCapture = mockImageCapture;
      camera.processCameraProvider = mockProcessCameraProvider;

      // Tell plugin to mock call to get current photo orientation.
      PigeonOverrides.deviceOrientationManager_new =
          ({
            required void Function(DeviceOrientationManager, String)
            onDeviceOrientationChanged,
          }) {
            final mockDeviceOrientationManager = MockDeviceOrientationManager();
            when(
              mockDeviceOrientationManager.getDefaultDisplayRotation(),
            ).thenAnswer((_) async => defaultTargetRotation);
            return mockDeviceOrientationManager;
          };

      when(
        mockProcessCameraProvider.isBound(camera.imageCapture),
      ).thenAnswer((_) async => true);
      when(
        camera.imageCapture!.takePicture(),
      ).thenAnswer((_) async => 'test/absolute/path/to/picture');

      // Orientation is unlocked and plugin does not need to set default target
      // rotation manually.
      await camera.takePicture(cameraId);
      verify(mockImageCapture.setTargetRotation(defaultTargetRotation));

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
    },
  );

  test(
    'takePicture turns non-torch flash mode off when torch mode enabled',
    () async {
      final camera = AndroidCameraCameraX();
      final mockProcessCameraProvider = MockProcessCameraProvider();
      const cameraId = 77;

      // Set directly for test versus calling createCamera.
      camera.imageCapture = MockImageCapture();
      camera.cameraControl = MockCameraControl();
      camera.processCameraProvider = mockProcessCameraProvider;

      // Ignore setting target rotation for this test; tested seprately.
      camera.captureOrientationLocked = true;

      when(
        mockProcessCameraProvider.isBound(camera.imageCapture),
      ).thenAnswer((_) async => true);

      await camera.setFlashMode(cameraId, FlashMode.torch);
      await camera.takePicture(cameraId);
      verify(camera.imageCapture!.setFlashMode(CameraXFlashMode.off));
    },
  );

  test(
    'setFlashMode configures ImageCapture with expected non-torch flash mode',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 22;
      final mockCameraControl = MockCameraControl();
      final mockProcessCameraProvider = MockProcessCameraProvider();

      // Set directly for test versus calling createCamera.
      camera.imageCapture = MockImageCapture();
      camera.cameraControl = mockCameraControl;

      // Ignore setting target rotation for this test; tested seprately.
      camera.captureOrientationLocked = true;
      camera.processCameraProvider = mockProcessCameraProvider;

      when(
        mockProcessCameraProvider.isBound(camera.imageCapture),
      ).thenAnswer((_) async => true);

      for (final FlashMode flashMode in FlashMode.values) {
        await camera.setFlashMode(cameraId, flashMode);

        CameraXFlashMode? expectedFlashMode;
        switch (flashMode) {
          case FlashMode.off:
            expectedFlashMode = CameraXFlashMode.off;
          case FlashMode.auto:
            expectedFlashMode = CameraXFlashMode.auto;
          case FlashMode.always:
            expectedFlashMode = CameraXFlashMode.on;
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
    },
  );

  test('setFlashMode turns on torch mode as expected', () async {
    final camera = AndroidCameraCameraX();
    const cameraId = 44;
    final mockCameraControl = MockCameraControl();

    // Set directly for test versus calling createCamera.
    camera.cameraControl = mockCameraControl;

    await camera.setFlashMode(cameraId, FlashMode.torch);

    verify(mockCameraControl.enableTorch(true));
    expect(camera.torchEnabled, isTrue);
  });

  test(
    'setFlashMode turns off torch mode when non-torch flash modes set',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 33;
      final mockCameraControl = MockCameraControl();

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
    },
  );

  test('getMinExposureOffset returns expected exposure offset', () async {
    final camera = AndroidCameraCameraX();
    final mockCameraInfo = MockCameraInfo();

    final exposureState = ExposureState.pigeon_detached(
      exposureCompensationRange: CameraIntegerRange.pigeon_detached(
        lower: 3,
        upper: 4,
      ),
      exposureCompensationStep: 0.2,
    );

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = mockCameraInfo;

    when(mockCameraInfo.exposureState).thenReturn(exposureState);

    // We expect the minimum exposure to be the minimum exposure compensation * exposure compensation step.
    // Delta is included due to avoid catching rounding errors.
    expect(await camera.getMinExposureOffset(35), closeTo(0.6, 0.0000000001));
  });

  test('getMaxExposureOffset returns expected exposure offset', () async {
    final camera = AndroidCameraCameraX();
    final mockCameraInfo = MockCameraInfo();

    final exposureState = ExposureState.pigeon_detached(
      exposureCompensationRange: CameraIntegerRange.pigeon_detached(
        lower: 3,
        upper: 4,
      ),
      exposureCompensationStep: 0.2,
    );

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = mockCameraInfo;

    when(mockCameraInfo.exposureState).thenReturn(exposureState);

    // We expect the maximum exposure to be the maximum exposure compensation * exposure compensation step.
    expect(await camera.getMaxExposureOffset(35), 0.8);
  });

  test('getExposureOffsetStepSize returns expected exposure offset', () async {
    final camera = AndroidCameraCameraX();
    final mockCameraInfo = MockCameraInfo();

    final exposureState = ExposureState.pigeon_detached(
      exposureCompensationRange: CameraIntegerRange.pigeon_detached(
        lower: 3,
        upper: 4,
      ),
      exposureCompensationStep: 0.2,
    );

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = mockCameraInfo;

    when(mockCameraInfo.exposureState).thenReturn(exposureState);

    expect(await camera.getExposureOffsetStepSize(55), 0.2);
  });

  test(
    'getExposureOffsetStepSize returns -1 when exposure compensation not supported on device',
    () async {
      final camera = AndroidCameraCameraX();
      final mockCameraInfo = MockCameraInfo();
      final exposureState = ExposureState.pigeon_detached(
        exposureCompensationRange: CameraIntegerRange.pigeon_detached(
          lower: 0,
          upper: 0,
        ),
        exposureCompensationStep: 0,
      );

      // Set directly for test versus calling createCamera.
      camera.cameraInfo = mockCameraInfo;

      when(mockCameraInfo.exposureState).thenReturn(exposureState);

      expect(await camera.getExposureOffsetStepSize(55), -1);
    },
  );

  test('getMaxZoomLevel returns expected exposure offset', () async {
    final camera = AndroidCameraCameraX();
    final mockCameraInfo = MockCameraInfo();
    const double maxZoomRatio = 1;
    final LiveData<ZoomState> mockLiveZoomState = MockLiveZoomState();
    final zoomState = ZoomState.pigeon_detached(
      maxZoomRatio: maxZoomRatio,
      minZoomRatio: 0,
    );

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = mockCameraInfo;

    when(
      mockCameraInfo.getZoomState(),
    ).thenAnswer((_) async => mockLiveZoomState);
    when(mockLiveZoomState.getValue()).thenAnswer((_) async => zoomState);

    expect(await camera.getMaxZoomLevel(55), maxZoomRatio);
  });

  test('getMinZoomLevel returns expected exposure offset', () async {
    final camera = AndroidCameraCameraX();
    final mockCameraInfo = MockCameraInfo();
    const double minZoomRatio = 0;
    final LiveData<ZoomState> mockLiveZoomState = MockLiveZoomState();
    final zoomState = ZoomState.pigeon_detached(
      maxZoomRatio: 1,
      minZoomRatio: minZoomRatio,
    );

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = mockCameraInfo;

    when(
      mockCameraInfo.getZoomState(),
    ).thenAnswer((_) async => mockLiveZoomState);
    when(mockLiveZoomState.getValue()).thenAnswer((_) async => zoomState);

    expect(await camera.getMinZoomLevel(55), minZoomRatio);
  });

  test('setZoomLevel sets zoom ratio as expected', () async {
    final camera = AndroidCameraCameraX();
    const cameraId = 44;
    const zoomRatio = 0.3;
    final mockCameraControl = MockCameraControl();

    // Set directly for test versus calling createCamera.
    camera.cameraControl = mockCameraControl;

    await camera.setZoomLevel(cameraId, zoomRatio);

    verify(mockCameraControl.setZoomRatio(zoomRatio));
  });

  test('Should report support for image streaming', () async {
    final camera = AndroidCameraCameraX();
    expect(camera.supportsImageStreaming(), true);
  });

  test(
    'onStreamedFrameAvailable emits CameraImageData when picked up from CameraImageData stream controller',
    () async {
      final camera = AndroidCameraCameraX();
      final mockProcessCameraProvider = MockProcessCameraProvider();
      final mockCamera = MockCamera();
      final mockCameraInfo = MockCameraInfo();
      const cameraId = 22;

      // Tell plugin to create detached Analyzer for testing.
      PigeonOverrides.analyzer_new =
          ({required void Function(Analyzer, ImageProxy) analyze}) {
            return Analyzer.pigeon_detached(analyze: analyze);
          };

      // Set directly for test versus calling createCamera.
      camera.processCameraProvider = mockProcessCameraProvider;
      camera.cameraSelector = MockCameraSelector();
      camera.imageAnalysis = MockImageAnalysis();

      // Ignore setting target rotation for this test; tested seprately.
      camera.captureOrientationLocked = true;

      when(
        mockProcessCameraProvider.bindToLifecycle(any, any),
      ).thenAnswer((_) => Future<Camera>.value(mockCamera));
      when(
        mockProcessCameraProvider.isBound(camera.imageAnalysis),
      ).thenAnswer((_) async => true);
      when(
        mockCamera.getCameraInfo(),
      ).thenAnswer((_) => Future<CameraInfo>.value(mockCameraInfo));
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => MockLiveCameraState());

      final CameraImageData mockCameraImageData = MockCameraImageData();
      final Stream<CameraImageData> imageStream = camera
          .onStreamedFrameAvailable(cameraId);
      final streamQueue = StreamQueue<CameraImageData>(imageStream);

      camera.cameraImageDataStreamController!.add(mockCameraImageData);

      expect(await streamQueue.next, equals(mockCameraImageData));
      await streamQueue.cancel();
    },
  );

  test(
    'onStreamedFrameAvailable emits CameraImageData when listened to after cancelation',
    () async {
      final camera = AndroidCameraCameraX();
      final mockProcessCameraProvider = MockProcessCameraProvider();
      const cameraId = 22;

      // Tell plugin to create detached Analyzer for testing.
      PigeonOverrides.analyzer_new =
          ({required void Function(Analyzer, ImageProxy) analyze}) {
            return Analyzer.pigeon_detached(analyze: analyze);
          };

      // Set directly for test versus calling createCamera.
      camera.processCameraProvider = mockProcessCameraProvider;
      camera.cameraSelector = MockCameraSelector();
      camera.imageAnalysis = MockImageAnalysis();

      // Ignore setting target rotation for this test; tested seprately.
      camera.captureOrientationLocked = true;

      when(
        mockProcessCameraProvider.isBound(camera.imageAnalysis),
      ).thenAnswer((_) async => true);

      final CameraImageData mockCameraImageData = MockCameraImageData();
      final Stream<CameraImageData> imageStream = camera
          .onStreamedFrameAvailable(cameraId);

      // Listen to image stream.
      final StreamSubscription<CameraImageData> imageStreamSubscription =
          imageStream.listen((CameraImageData data) {});

      // Cancel subscription to image stream.
      await imageStreamSubscription.cancel();
      final Stream<CameraImageData> imageStream2 = camera
          .onStreamedFrameAvailable(cameraId);

      // Listen to image stream again.
      final streamQueue = StreamQueue<CameraImageData>(imageStream2);
      camera.cameraImageDataStreamController!.add(mockCameraImageData);

      expect(await streamQueue.next, equals(mockCameraImageData));
      await streamQueue.cancel();
    },
  );

  test(
    'onStreamedFrameAvailable returns stream that responds expectedly to being listened to',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 33;
      final ProcessCameraProvider mockProcessCameraProvider =
          MockProcessCameraProvider();
      final CameraSelector mockCameraSelector = MockCameraSelector();
      final mockImageAnalysis = MockImageAnalysis();
      final Camera mockCamera = MockCamera();
      final CameraInfo mockCameraInfo = MockCameraInfo();
      final mockImageProxy = MockImageProxy();
      final mockPlane = MockPlaneProxy();
      final mockPlanes = <MockPlaneProxy>[mockPlane];
      final buffer = Uint8List(0);
      const pixelStride = 27;
      const rowStride = 58;
      const imageFormat = 582;
      const imageHeight = 100;
      const imageWidth = 200;

      // Tell plugin to create detached Analyzer for testing.
      PigeonOverrides.analyzer_new =
          ({required void Function(Analyzer, ImageProxy) analyze}) {
            return Analyzer.pigeon_detached(analyze: analyze);
          };
      GenericsPigeonOverrides.observerNew =
          <T>({required void Function(Observer<T>, T) onChanged}) {
            return Observer<T>.detached(onChanged: onChanged);
          };

      // Set directly for test versus calling createCamera.
      camera.processCameraProvider = mockProcessCameraProvider;
      camera.cameraSelector = mockCameraSelector;
      camera.imageAnalysis = mockImageAnalysis;

      // Ignore setting target rotation for this test; tested seprately.
      camera.captureOrientationLocked = true;

      when(
        mockProcessCameraProvider.isBound(mockImageAnalysis),
      ).thenAnswer((_) async => false);
      when(
        mockProcessCameraProvider.bindToLifecycle(mockCameraSelector, <UseCase>[
          mockImageAnalysis,
        ]),
      ).thenAnswer((_) async => mockCamera);
      when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => MockLiveCameraState());
      when(
        mockImageProxy.getPlanes(),
      ).thenAnswer((_) async => Future<List<PlaneProxy>>.value(mockPlanes));
      when(mockPlane.buffer).thenReturn(buffer);
      when(mockPlane.rowStride).thenReturn(rowStride);
      when(mockPlane.pixelStride).thenReturn(pixelStride);
      when(mockImageProxy.format).thenReturn(imageFormat);
      when(mockImageProxy.height).thenReturn(imageHeight);
      when(mockImageProxy.width).thenReturn(imageWidth);

      final imageDataCompleter = Completer<CameraImageData>();
      final StreamSubscription<CameraImageData>
      onStreamedFrameAvailableSubscription = camera
          .onStreamedFrameAvailable(cameraId)
          .listen((CameraImageData imageData) {
            imageDataCompleter.complete(imageData);
          });

      // Test ImageAnalysis use case is bound to ProcessCameraProvider.
      await untilCalled(mockImageAnalysis.setAnalyzer(any));
      final capturedAnalyzer =
          verify(mockImageAnalysis.setAnalyzer(captureAny)).captured.single
              as Analyzer;

      capturedAnalyzer.analyze(MockAnalyzer(), mockImageProxy);

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
    },
  );
  test(
    'onStreamedFrameAvailable emits NV21 CameraImageData with correct format and single plane when initialized with NV21',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 42;
      final mockProcessCameraProvider = MockProcessCameraProvider();
      final mockImageAnalysis = MockImageAnalysis();
      final mockCamera = MockCamera();
      final mockCameraInfo = MockCameraInfo();
      final mockImageProxy = MockImageProxy();
      final mockPlane = MockPlaneProxy();
      final mockPlanes = <MockPlaneProxy>[mockPlane, mockPlane, mockPlane];
      final testNv21Buffer = Uint8List(10);

      // Mock use case bindings and related Camera objects.
      when(
        mockProcessCameraProvider.bindToLifecycle(any, any),
      ).thenAnswer((_) async => mockCamera);
      when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => MockLiveCameraState());

      // Set up CameraXProxy with ImageAnalysis specifics needed for testing its Analyzer.
      setUpOverridesForTestingUseCaseConfiguration(
        mockProcessCameraProvider,
        newAnalyzer: ({required void Function(Analyzer, ImageProxy) analyze}) {
          return Analyzer.pigeon_detached(analyze: analyze);
        },
        newImageAnalysis:
            ({
              int? outputImageFormat,
              ResolutionSelector? resolutionSelector,
              int? targetRotation,
              CameraIntegerRange? targetFpsRange,
            }) => mockImageAnalysis,
        getNv21BufferImageProxyUtils:
            (int imageWidth, int imageHeight, List<PlaneProxy> planes) =>
                Future<Uint8List>.value(testNv21Buffer),
      );

      // Create and initialize camera with NV21.
      await camera.createCamera(
        const CameraDescription(
          name: 'test',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 0,
        ),
        ResolutionPreset.low,
      );
      await camera.initializeCamera(
        cameraId,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      // Create mock ImageProxy with theoretical underlying NV21 format but with three
      // planes still in YUV_420_888 format that should get transformed to testNv21Buffer.
      when(mockImageProxy.getPlanes()).thenAnswer((_) async => mockPlanes);

      // Set up listener to receive mock ImageProxy.
      final imageDataCompleter = Completer<CameraImageData>();
      final StreamSubscription<CameraImageData> subscription = camera
          .onStreamedFrameAvailable(cameraId)
          .listen((CameraImageData imageData) {
            imageDataCompleter.complete(imageData);
          });

      await untilCalled(mockImageAnalysis.setAnalyzer(any));
      final capturedAnalyzer =
          verify(mockImageAnalysis.setAnalyzer(captureAny)).captured.single
              as Analyzer;
      capturedAnalyzer.analyze(MockAnalyzer(), mockImageProxy);

      final CameraImageData imageData = await imageDataCompleter.future;

      expect(imageData.format.raw, AndroidCameraCameraX.imageProxyFormatNv21);
      expect(imageData.format.group, ImageFormatGroup.nv21);
      expect(imageData.planes.length, 1);
      expect(imageData.planes[0].bytes, testNv21Buffer);

      await subscription.cancel();
    },
  );

  test(
    'onStreamedFrameAvailable returns stream that responds expectedly to being canceled',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 32;
      final mockImageAnalysis = MockImageAnalysis();
      final mockProcessCameraProvider = MockProcessCameraProvider();

      // Set directly for test versus calling createCamera.
      camera.imageAnalysis = mockImageAnalysis;
      camera.processCameraProvider = mockProcessCameraProvider;

      // Ignore setting target rotation for this test; tested separately.
      camera.captureOrientationLocked = true;

      // Tell plugin to create a detached analyzer for testing purposes.
      PigeonOverrides.analyzer_new =
          ({required void Function(Analyzer, ImageProxy) analyze}) =>
              MockAnalyzer();

      when(
        mockProcessCameraProvider.isBound(mockImageAnalysis),
      ).thenAnswer((_) async => true);

      final StreamSubscription<CameraImageData> imageStreamSubscription = camera
          .onStreamedFrameAvailable(cameraId)
          .listen((CameraImageData data) {});

      await imageStreamSubscription.cancel();

      verify(mockImageAnalysis.clearAnalyzer());
    },
  );

  test(
    'onStreamedFrameAvailable sets ImageAnalysis target rotation to current photo orientation when orientation unlocked',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 35;
      const int defaultTargetRotation = Surface.rotation90;
      final mockImageAnalysis = MockImageAnalysis();
      final mockProcessCameraProvider = MockProcessCameraProvider();

      // Set directly for test versus calling createCamera.
      camera.imageAnalysis = mockImageAnalysis;
      camera.processCameraProvider = mockProcessCameraProvider;

      // Tell plugin to create a detached analyzer for testing purposes and mock
      // call to get current photo orientation.
      PigeonOverrides.analyzer_new =
          ({required void Function(Analyzer, ImageProxy) analyze}) =>
              MockAnalyzer();
      PigeonOverrides.deviceOrientationManager_new =
          ({
            required void Function(DeviceOrientationManager, String)
            onDeviceOrientationChanged,
          }) {
            final manager = MockDeviceOrientationManager();
            when(manager.getDefaultDisplayRotation()).thenAnswer((_) async {
              return defaultTargetRotation;
            });
            return manager;
          };

      when(
        mockProcessCameraProvider.isBound(mockImageAnalysis),
      ).thenAnswer((_) async => true);

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
        mockImageAnalysis.setTargetRotation(defaultTargetRotation),
      );
      await imageStreamSubscription.cancel();
    },
  );

  test(
    'lockCaptureOrientation sets capture-related use case target rotations to correct orientation',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 44;

      final mockImageAnalysis = MockImageAnalysis();
      final mockImageCapture = MockImageCapture();
      final mockVideoCapture = MockVideoCapture();

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
    },
  );

  test(
    'unlockCaptureOrientation sets capture-related use case target rotations to current photo/video orientation',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 57;

      camera.captureOrientationLocked = true;
      await camera.unlockCaptureOrientation(cameraId);
      expect(camera.captureOrientationLocked, isFalse);
    },
  );

  test(
    'setExposureMode sets expected controlAeLock value via Camera2 interop',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 78;
      final mockCameraControl = MockCameraControl();
      final mockCamera2CameraControl = MockCamera2CameraControl();

      // Set directly for test versus calling createCamera.
      camera.camera = MockCamera();
      camera.cameraControl = mockCameraControl;

      // Tell plugin to create detached Camera2CameraControl and
      // CaptureRequestOptions instances for testing.
      final controlAELockKey = CaptureRequestKey.pigeon_detached();
      PigeonOverrides.camera2CameraControl_from =
          ({required CameraControl cameraControl}) =>
              cameraControl == mockCameraControl
              ? mockCamera2CameraControl
              : Camera2CameraControl.pigeon_detached();
      PigeonOverrides.captureRequestOptions_new =
          ({required Map<CaptureRequestKey, Object?> options}) {
            final mockCaptureRequestOptions = MockCaptureRequestOptions();
            options.forEach((CaptureRequestKey key, Object? value) {
              when(
                mockCaptureRequestOptions.getCaptureRequestOption(key),
              ).thenAnswer((_) async => value);
            });
            return mockCaptureRequestOptions;
          };
      PigeonOverrides.captureRequest_controlAELock = controlAELockKey;

      // Test auto mode.
      await camera.setExposureMode(cameraId, ExposureMode.auto);

      VerificationResult verificationResult = verify(
        mockCamera2CameraControl.addCaptureRequestOptions(captureAny),
      );
      var capturedCaptureRequestOptions =
          verificationResult.captured.single as CaptureRequestOptions;
      expect(
        await capturedCaptureRequestOptions.getCaptureRequestOption(
          controlAELockKey,
        ),
        isFalse,
      );

      // Test locked mode.
      clearInteractions(mockCamera2CameraControl);
      await camera.setExposureMode(cameraId, ExposureMode.locked);

      verificationResult = verify(
        mockCamera2CameraControl.addCaptureRequestOptions(captureAny),
      );
      capturedCaptureRequestOptions =
          verificationResult.captured.single as CaptureRequestOptions;
      expect(
        await capturedCaptureRequestOptions.getCaptureRequestOption(
          controlAELockKey,
        ),
        isTrue,
      );
    },
  );

  test(
    'setExposurePoint clears current auto-exposure metering point as expected',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 93;
      final mockCameraControl = MockCameraControl();
      final mockCameraInfo = MockCameraInfo();

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = mockCameraInfo;

      final mockActionBuilder = MockFocusMeteringActionBuilder();
      when(mockActionBuilder.build()).thenAnswer(
        (_) async => FocusMeteringAction.pigeon_detached(
          meteringPointsAe: const <MeteringPoint>[],
          meteringPointsAf: const <MeteringPoint>[],
          meteringPointsAwb: const <MeteringPoint>[],
          isAutoCancelEnabled: false,
        ),
      );
      MeteringMode? actionBuilderMeteringMode;
      MeteringPoint? actionBuilderMeteringPoint;
      setUpOverridesForExposureAndFocus(
        withModeFocusMeteringActionBuilder:
            ({required MeteringMode mode, required MeteringPoint point}) {
              actionBuilderMeteringMode = mode;
              actionBuilderMeteringPoint = point;
              return mockActionBuilder;
            },
      );

      // Verify nothing happens if no current focus and metering action has been
      // enabled.
      await camera.setExposurePoint(cameraId, null);
      verifyNever(mockCameraControl.startFocusAndMetering(any));
      verifyNever(mockCameraControl.cancelFocusAndMetering());

      // Verify current auto-exposure metering point is removed if previously set.
      final originalMeteringAction = FocusMeteringAction.pigeon_detached(
        meteringPointsAe: <MeteringPoint>[MeteringPoint.pigeon_detached()],
        meteringPointsAf: <MeteringPoint>[MeteringPoint.pigeon_detached()],
        meteringPointsAwb: const <MeteringPoint>[],
        isAutoCancelEnabled: false,
      );
      camera.currentFocusMeteringAction = originalMeteringAction;

      await camera.setExposurePoint(cameraId, null);

      expect(actionBuilderMeteringMode, MeteringMode.af);
      expect(
        actionBuilderMeteringPoint,
        originalMeteringAction.meteringPointsAf.single,
      );
      verifyNever(mockActionBuilder.addPoint(any));
      verifyNever(mockActionBuilder.addPointWithMode(any, any));

      // Verify current focus and metering action is cleared if only previously
      // set metering point was for auto-exposure.
      camera.currentFocusMeteringAction = FocusMeteringAction.pigeon_detached(
        meteringPointsAe: <MeteringPoint>[MeteringPoint.pigeon_detached()],
        meteringPointsAf: const <MeteringPoint>[],
        meteringPointsAwb: const <MeteringPoint>[],
        isAutoCancelEnabled: false,
      );

      await camera.setExposurePoint(cameraId, null);

      verify(mockCameraControl.cancelFocusAndMetering());
    },
  );

  test(
    'setExposurePoint throws CameraException if invalid point specified',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 23;
      final mockCameraControl = MockCameraControl();
      const invalidExposurePoint = Point<double>(3, -1);

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = MockCameraInfo();

      setUpOverridesForExposureAndFocus();

      expect(
        () => camera.setExposurePoint(cameraId, invalidExposurePoint),
        throwsA(isA<CameraException>()),
      );
    },
  );

  test(
    'setExposurePoint adds new exposure point to focus metering action to start as expected when previous metering points have been set',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 9;
      final mockCameraControl = MockCameraControl();
      final mockCameraInfo = MockCameraInfo();

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = mockCameraInfo;

      var exposurePointX = 0.8;
      var exposurePointY = 0.1;
      final createdMeteringPoint = MeteringPoint.pigeon_detached();
      MeteringMode? actionBuilderMeteringMode;
      MeteringPoint? actionBuilderMeteringPoint;
      final mockActionBuilder = MockFocusMeteringActionBuilder();
      when(mockActionBuilder.build()).thenAnswer(
        (_) async => FocusMeteringAction.pigeon_detached(
          meteringPointsAe: const <MeteringPoint>[],
          meteringPointsAf: const <MeteringPoint>[],
          meteringPointsAwb: const <MeteringPoint>[],
          isAutoCancelEnabled: false,
        ),
      );
      setUpOverridesForExposureAndFocus(
        newDisplayOrientedMeteringPointFactory:
            ({
              required dynamic cameraInfo,
              required double width,
              required double height,
            }) {
              final mockFactory = MockDisplayOrientedMeteringPointFactory();
              when(
                mockFactory.createPoint(exposurePointX, exposurePointY),
              ).thenAnswer((_) async => createdMeteringPoint);
              return mockFactory;
            },
        withModeFocusMeteringActionBuilder:
            ({required MeteringMode mode, required MeteringPoint point}) {
              actionBuilderMeteringMode = mode;
              actionBuilderMeteringPoint = point;
              return mockActionBuilder;
            },
      );

      // Verify current auto-exposure metering point is removed if previously set.
      var exposurePoint = Point<double>(exposurePointX, exposurePointY);
      var originalMeteringAction = FocusMeteringAction.pigeon_detached(
        meteringPointsAe: <MeteringPoint>[MeteringPoint.pigeon_detached()],
        meteringPointsAf: <MeteringPoint>[MeteringPoint.pigeon_detached()],
        meteringPointsAwb: const <MeteringPoint>[],
        isAutoCancelEnabled: false,
      );
      camera.currentFocusMeteringAction = originalMeteringAction;

      await camera.setExposurePoint(cameraId, exposurePoint);

      expect(
        actionBuilderMeteringPoint,
        originalMeteringAction.meteringPointsAf.single,
      );
      expect(actionBuilderMeteringMode, MeteringMode.af);
      verify(
        mockActionBuilder.addPointWithMode(
          createdMeteringPoint,
          MeteringMode.ae,
        ),
      );

      // Verify exposure point is set when no auto-exposure metering point
      // previously set, but an auto-focus point metering point has been.
      exposurePointX = 0.2;
      exposurePointY = 0.9;
      exposurePoint = Point<double>(exposurePointX, exposurePointY);
      originalMeteringAction = FocusMeteringAction.pigeon_detached(
        meteringPointsAe: const <MeteringPoint>[],
        meteringPointsAf: <MeteringPoint>[MeteringPoint.pigeon_detached()],
        meteringPointsAwb: const <MeteringPoint>[],
        isAutoCancelEnabled: false,
      );
      camera.currentFocusMeteringAction = originalMeteringAction;

      await camera.setExposurePoint(cameraId, exposurePoint);

      expect(
        actionBuilderMeteringPoint,
        originalMeteringAction.meteringPointsAf.single,
      );
      expect(actionBuilderMeteringMode, MeteringMode.af);
      verify(
        mockActionBuilder.addPointWithMode(
          createdMeteringPoint,
          MeteringMode.ae,
        ),
      );
    },
  );

  test(
    'setExposurePoint adds new exposure point to focus metering action to start as expected when no previous metering points have been set',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 19;
      final mockCameraControl = MockCameraControl();
      const exposurePointX = 0.8;
      const exposurePointY = 0.1;
      const exposurePoint = Point<double>(exposurePointX, exposurePointY);

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = MockCameraInfo();
      camera.currentFocusMeteringAction = null;

      final createdMeteringPoint = MeteringPoint.pigeon_detached();
      MeteringMode? actionBuilderMeteringMode;
      MeteringPoint? actionBuilderMeteringPoint;
      final mockActionBuilder = MockFocusMeteringActionBuilder();
      when(mockActionBuilder.build()).thenAnswer(
        (_) async => FocusMeteringAction.pigeon_detached(
          meteringPointsAe: const <MeteringPoint>[],
          meteringPointsAf: const <MeteringPoint>[],
          meteringPointsAwb: const <MeteringPoint>[],
          isAutoCancelEnabled: false,
        ),
      );
      setUpOverridesForExposureAndFocus(
        newDisplayOrientedMeteringPointFactory:
            ({
              required dynamic cameraInfo,
              required double width,
              required double height,
            }) {
              final mockFactory = MockDisplayOrientedMeteringPointFactory();
              when(
                mockFactory.createPoint(exposurePointX, exposurePointY),
              ).thenAnswer((_) async => createdMeteringPoint);
              return mockFactory;
            },
        withModeFocusMeteringActionBuilder:
            ({required MeteringMode mode, required MeteringPoint point}) {
              actionBuilderMeteringMode = mode;
              actionBuilderMeteringPoint = point;
              return mockActionBuilder;
            },
      );

      await camera.setExposurePoint(cameraId, exposurePoint);

      expect(actionBuilderMeteringPoint, createdMeteringPoint);
      expect(actionBuilderMeteringMode, MeteringMode.ae);
    },
  );

  test(
    'setExposurePoint disables auto-cancel for focus and metering as expected',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 2;
      final mockCameraControl = MockCameraControl();
      final FocusMeteringResult mockFocusMeteringResult =
          MockFocusMeteringResult();
      const exposurePoint = Point<double>(0.1, 0.2);

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = MockCameraInfo();

      setUpOverridesForSettingFocusandExposurePoints(
        mockCameraControl,
        MockCamera2CameraControl(),
      );

      // Make setting focus and metering action successful for test.
      when(mockFocusMeteringResult.isFocusSuccessful).thenReturn(true);
      when(mockCameraControl.startFocusAndMetering(any)).thenAnswer(
        (_) async => Future<FocusMeteringResult>.value(mockFocusMeteringResult),
      );

      // Test not disabling auto cancel.
      await camera.setFocusMode(cameraId, FocusMode.auto);
      clearInteractions(mockCameraControl);
      await camera.setExposurePoint(cameraId, exposurePoint);
      VerificationResult verificationResult = verify(
        mockCameraControl.startFocusAndMetering(captureAny),
      );
      var capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isTrue);

      clearInteractions(mockCameraControl);

      // Test disabling auto cancel.
      await camera.setFocusMode(cameraId, FocusMode.locked);
      clearInteractions(mockCameraControl);
      await camera.setExposurePoint(cameraId, exposurePoint);
      verificationResult = verify(
        mockCameraControl.startFocusAndMetering(captureAny),
      );
      capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isFalse);
    },
  );

  test(
    'setExposureOffset throws exception if exposure compensation not supported',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 6;
      const double offset = 2;
      final mockCameraInfo = MockCameraInfo();
      final exposureState = ExposureState.pigeon_detached(
        exposureCompensationRange: CameraIntegerRange.pigeon_detached(
          lower: 3,
          upper: 4,
        ),
        exposureCompensationStep: 0,
      );

      // Set directly for test versus calling createCamera.
      camera.cameraInfo = mockCameraInfo;

      when(mockCameraInfo.exposureState).thenReturn(exposureState);

      expect(
        () => camera.setExposureOffset(cameraId, offset),
        throwsA(isA<CameraException>()),
      );
    },
  );

  test(
    'setExposureOffset throws exception if exposure compensation could not be set for unknown reason',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 11;
      const double offset = 3;
      final mockCameraInfo = MockCameraInfo();
      final CameraControl mockCameraControl = MockCameraControl();
      final exposureState = ExposureState.pigeon_detached(
        exposureCompensationRange: CameraIntegerRange.pigeon_detached(
          lower: 3,
          upper: 4,
        ),
        exposureCompensationStep: 0.2,
      );

      // Set directly for test versus calling createCamera.
      camera.cameraInfo = mockCameraInfo;
      camera.cameraControl = mockCameraControl;

      when(mockCameraInfo.exposureState).thenReturn(exposureState);
      when(mockCameraControl.setExposureCompensationIndex(15)).thenThrow(
        PlatformException(
          code: 'TEST_ERROR',
          message:
              'This is a test error message indicating exposure offset could not be set.',
        ),
      );

      expect(
        () => camera.setExposureOffset(cameraId, offset),
        throwsA(isA<CameraException>()),
      );
    },
  );

  test(
    'setExposureOffset throws exception if exposure compensation could not be set due to camera being closed or newer value being set',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 21;
      const double offset = 5;
      final mockCameraInfo = MockCameraInfo();
      final CameraControl mockCameraControl = MockCameraControl();
      final exposureState = ExposureState.pigeon_detached(
        exposureCompensationRange: CameraIntegerRange.pigeon_detached(
          lower: 3,
          upper: 4,
        ),
        exposureCompensationStep: 0.1,
      );
      final int expectedExposureCompensationIndex =
          (offset / exposureState.exposureCompensationStep).round();

      // Set directly for test versus calling createCamera.
      camera.cameraInfo = mockCameraInfo;
      camera.cameraControl = mockCameraControl;

      when(mockCameraInfo.exposureState).thenReturn(exposureState);
      when(
        mockCameraControl.setExposureCompensationIndex(
          expectedExposureCompensationIndex,
        ),
      ).thenAnswer((_) async => Future<int?>.value());

      expect(
        () => camera.setExposureOffset(cameraId, offset),
        throwsA(isA<CameraException>()),
      );
    },
  );

  test(
    'setExposureOffset behaves as expected to successful attempt to set exposure compensation index',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 11;
      const double offset = 3;
      final mockCameraInfo = MockCameraInfo();
      final CameraControl mockCameraControl = MockCameraControl();
      final exposureState = ExposureState.pigeon_detached(
        exposureCompensationRange: CameraIntegerRange.pigeon_detached(
          lower: 3,
          upper: 4,
        ),
        exposureCompensationStep: 0.2,
      );
      final int expectedExposureCompensationIndex =
          (offset / exposureState.exposureCompensationStep).round();

      // Set directly for test versus calling createCamera.
      camera.cameraInfo = mockCameraInfo;
      camera.cameraControl = mockCameraControl;

      when(mockCameraInfo.exposureState).thenReturn(exposureState);
      when(
        mockCameraControl.setExposureCompensationIndex(
          expectedExposureCompensationIndex,
        ),
      ).thenAnswer(
        (_) async => Future<int>.value(
          (expectedExposureCompensationIndex *
                  exposureState.exposureCompensationStep)
              .round(),
        ),
      );

      // Exposure index * exposure offset step size = exposure offset, i.e.
      // 15 * 0.2 = 3.
      expect(await camera.setExposureOffset(cameraId, offset), equals(3));
    },
  );

  test(
    'setFocusPoint clears current auto-exposure metering point as expected',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 93;
      final mockCameraControl = MockCameraControl();
      final mockCameraInfo = MockCameraInfo();

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = mockCameraInfo;

      final mockActionBuilder = MockFocusMeteringActionBuilder();
      when(mockActionBuilder.build()).thenAnswer(
        (_) async => FocusMeteringAction.pigeon_detached(
          meteringPointsAe: const <MeteringPoint>[],
          meteringPointsAf: const <MeteringPoint>[],
          meteringPointsAwb: const <MeteringPoint>[],
          isAutoCancelEnabled: false,
        ),
      );
      MeteringMode? actionBuilderMeteringMode;
      MeteringPoint? actionBuilderMeteringPoint;
      setUpOverridesForExposureAndFocus(
        withModeFocusMeteringActionBuilder:
            ({required MeteringMode mode, required MeteringPoint point}) {
              actionBuilderMeteringMode = mode;
              actionBuilderMeteringPoint = point;
              return mockActionBuilder;
            },
      );

      // Verify nothing happens if no current focus and metering action has been
      // enabled.
      await camera.setFocusPoint(cameraId, null);
      verifyNever(mockCameraControl.startFocusAndMetering(any));
      verifyNever(mockCameraControl.cancelFocusAndMetering());

      final originalMeteringAction = FocusMeteringAction.pigeon_detached(
        meteringPointsAe: <MeteringPoint>[MeteringPoint.pigeon_detached()],
        meteringPointsAf: <MeteringPoint>[MeteringPoint.pigeon_detached()],
        meteringPointsAwb: const <MeteringPoint>[],
        isAutoCancelEnabled: false,
      );
      camera.currentFocusMeteringAction = originalMeteringAction;

      await camera.setFocusPoint(cameraId, null);

      expect(actionBuilderMeteringMode, MeteringMode.ae);
      expect(
        actionBuilderMeteringPoint,
        originalMeteringAction.meteringPointsAe.single,
      );
      verifyNever(mockActionBuilder.addPoint(any));
      verifyNever(mockActionBuilder.addPointWithMode(any, any));

      // Verify current focus and metering action is cleared if only previously
      // set metering point was for auto-exposure.
      camera.currentFocusMeteringAction = FocusMeteringAction.pigeon_detached(
        meteringPointsAe: const <MeteringPoint>[],
        meteringPointsAf: <MeteringPoint>[MeteringPoint.pigeon_detached()],
        meteringPointsAwb: const <MeteringPoint>[],
        isAutoCancelEnabled: false,
      );

      await camera.setFocusPoint(cameraId, null);

      verify(mockCameraControl.cancelFocusAndMetering());
    },
  );

  test(
    'setFocusPoint throws CameraException if invalid point specified',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 23;
      final mockCameraControl = MockCameraControl();
      const invalidFocusPoint = Point<double>(-3, 1);

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = MockCameraInfo();

      setUpOverridesForExposureAndFocus();

      expect(
        () => camera.setFocusPoint(cameraId, invalidFocusPoint),
        throwsA(isA<CameraException>()),
      );
    },
  );

  test(
    'setFocusPoint adds new focus point to focus metering action to start as expected when previous metering points have been set',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 9;
      final mockCameraControl = MockCameraControl();
      final mockCameraInfo = MockCameraInfo();

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = mockCameraInfo;

      var focusPointX = 0.8;
      var focusPointY = 0.1;
      var focusPoint = Point<double>(focusPointX, focusPointY);
      final createdMeteringPoint = MeteringPoint.pigeon_detached();
      MeteringMode? actionBuilderMeteringMode;
      MeteringPoint? actionBuilderMeteringPoint;
      final mockActionBuilder = MockFocusMeteringActionBuilder();
      when(mockActionBuilder.build()).thenAnswer(
        (_) async => FocusMeteringAction.pigeon_detached(
          meteringPointsAe: const <MeteringPoint>[],
          meteringPointsAf: const <MeteringPoint>[],
          meteringPointsAwb: const <MeteringPoint>[],
          isAutoCancelEnabled: false,
        ),
      );
      setUpOverridesForExposureAndFocus(
        newDisplayOrientedMeteringPointFactory:
            ({
              required dynamic cameraInfo,
              required double width,
              required double height,
            }) {
              final mockFactory = MockDisplayOrientedMeteringPointFactory();
              when(
                mockFactory.createPoint(focusPointX, focusPointY),
              ).thenAnswer((_) async => createdMeteringPoint);
              return mockFactory;
            },
        withModeFocusMeteringActionBuilder:
            ({required MeteringMode mode, required MeteringPoint point}) {
              actionBuilderMeteringMode = mode;
              actionBuilderMeteringPoint = point;
              return mockActionBuilder;
            },
      );

      // Verify current auto-exposure metering point is removed if previously set.
      var originalMeteringAction = FocusMeteringAction.pigeon_detached(
        meteringPointsAe: <MeteringPoint>[MeteringPoint.pigeon_detached()],
        meteringPointsAf: <MeteringPoint>[MeteringPoint.pigeon_detached()],
        meteringPointsAwb: const <MeteringPoint>[],
        isAutoCancelEnabled: false,
      );
      camera.currentFocusMeteringAction = originalMeteringAction;

      await camera.setFocusPoint(cameraId, focusPoint);

      expect(
        actionBuilderMeteringPoint,
        originalMeteringAction.meteringPointsAe.single,
      );
      expect(actionBuilderMeteringMode, MeteringMode.ae);
      verify(
        mockActionBuilder.addPointWithMode(
          createdMeteringPoint,
          MeteringMode.af,
        ),
      );

      // Verify exposure point is set when no auto-focus metering point
      // previously set, but an auto-exposure point metering point has been.
      focusPointX = 0.2;
      focusPointY = 0.9;
      focusPoint = Point<double>(focusPointX, focusPointY);
      originalMeteringAction = FocusMeteringAction.pigeon_detached(
        meteringPointsAe: <MeteringPoint>[MeteringPoint.pigeon_detached()],
        meteringPointsAf: const <MeteringPoint>[],
        meteringPointsAwb: const <MeteringPoint>[],
        isAutoCancelEnabled: false,
      );
      camera.currentFocusMeteringAction = originalMeteringAction;

      await camera.setFocusPoint(cameraId, focusPoint);

      expect(
        actionBuilderMeteringPoint,
        originalMeteringAction.meteringPointsAe.single,
      );
      expect(actionBuilderMeteringMode, MeteringMode.ae);
      verify(
        mockActionBuilder.addPointWithMode(
          createdMeteringPoint,
          MeteringMode.af,
        ),
      );
    },
  );

  test(
    'setFocusPoint adds new focus point to focus metering action to start as expected when no previous metering points have been set',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 19;
      final mockCameraControl = MockCameraControl();
      const focusPointX = 0.8;
      const focusPointY = 0.1;
      const focusPoint = Point<double>(focusPointX, focusPointY);

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = MockCameraInfo();
      camera.currentFocusMeteringAction = null;

      final createdMeteringPoint = MeteringPoint.pigeon_detached();
      MeteringMode? actionBuilderMeteringMode;
      MeteringPoint? actionBuilderMeteringPoint;
      final mockActionBuilder = MockFocusMeteringActionBuilder();
      when(mockActionBuilder.build()).thenAnswer(
        (_) async => FocusMeteringAction.pigeon_detached(
          meteringPointsAe: const <MeteringPoint>[],
          meteringPointsAf: const <MeteringPoint>[],
          meteringPointsAwb: const <MeteringPoint>[],
          isAutoCancelEnabled: false,
        ),
      );
      setUpOverridesForExposureAndFocus(
        newDisplayOrientedMeteringPointFactory:
            ({
              required dynamic cameraInfo,
              required double width,
              required double height,
            }) {
              final mockFactory = MockDisplayOrientedMeteringPointFactory();
              when(
                mockFactory.createPoint(focusPointX, focusPointY),
              ).thenAnswer((_) async => createdMeteringPoint);
              return mockFactory;
            },
        withModeFocusMeteringActionBuilder:
            ({required MeteringMode mode, required MeteringPoint point}) {
              actionBuilderMeteringMode = mode;
              actionBuilderMeteringPoint = point;
              return mockActionBuilder;
            },
      );

      await camera.setFocusPoint(cameraId, focusPoint);

      expect(actionBuilderMeteringPoint, createdMeteringPoint);
      expect(actionBuilderMeteringMode, MeteringMode.af);
    },
  );

  test(
    'setFocusPoint disables auto-cancel for focus and metering as expected',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 2;
      final mockCameraControl = MockCameraControl();
      final mockFocusMeteringResult = MockFocusMeteringResult();
      const exposurePoint = Point<double>(0.1, 0.2);

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = MockCameraInfo();

      setUpOverridesForSettingFocusandExposurePoints(
        mockCameraControl,
        MockCamera2CameraControl(),
      );

      // Make setting focus and metering action successful for test.
      when(mockFocusMeteringResult.isFocusSuccessful).thenReturn(true);
      when(mockCameraControl.startFocusAndMetering(any)).thenAnswer(
        (_) async => Future<FocusMeteringResult>.value(mockFocusMeteringResult),
      );

      // Test not disabling auto cancel.
      await camera.setFocusMode(cameraId, FocusMode.auto);
      clearInteractions(mockCameraControl);

      await camera.setFocusPoint(cameraId, exposurePoint);
      VerificationResult verificationResult = verify(
        mockCameraControl.startFocusAndMetering(captureAny),
      );
      var capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isTrue);

      clearInteractions(mockCameraControl);

      // Test disabling auto cancel.
      await camera.setFocusMode(cameraId, FocusMode.locked);
      clearInteractions(mockCameraControl);

      await camera.setFocusPoint(cameraId, exposurePoint);
      verificationResult = verify(
        mockCameraControl.startFocusAndMetering(captureAny),
      );
      capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isFalse);
    },
  );

  test(
    'setFocusMode does nothing if setting auto-focus mode and is already using auto-focus mode',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 4;
      final mockCameraControl = MockCameraControl();
      final mockFocusMeteringResult = MockFocusMeteringResult();

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = MockCameraInfo();

      setUpOverridesForSettingFocusandExposurePoints(
        mockCameraControl,
        MockCamera2CameraControl(),
      );

      // Make setting focus and metering action successful for test.
      when(mockFocusMeteringResult.isFocusSuccessful).thenReturn(true);
      when(mockCameraControl.startFocusAndMetering(any)).thenAnswer(
        (_) async => Future<FocusMeteringResult>.value(mockFocusMeteringResult),
      );

      // Set locked focus mode and then try to re-set it.
      await camera.setFocusMode(cameraId, FocusMode.locked);
      clearInteractions(mockCameraControl);

      await camera.setFocusMode(cameraId, FocusMode.locked);
      verifyNoMoreInteractions(mockCameraControl);
    },
  );

  test(
    'setFocusMode does nothing if setting locked focus mode and is already using locked focus mode',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 4;
      final mockCameraControl = MockCameraControl();

      // Camera uses auto-focus by default, so try setting auto mode again.
      await camera.setFocusMode(cameraId, FocusMode.auto);

      verifyNoMoreInteractions(mockCameraControl);
    },
  );

  test(
    'setFocusMode removes default auto-focus point if previously set and setting auto-focus mode',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 5;
      final mockCameraControl = MockCameraControl();
      final mockFocusMeteringResult = MockFocusMeteringResult();
      final mockCamera2CameraControl = MockCamera2CameraControl();
      const exposurePointX = 0.2;
      const exposurePointY = 0.7;

      // Set directly for test versus calling createCamera.
      camera.cameraInfo = MockCameraInfo();
      camera.cameraControl = mockCameraControl;

      when(
        mockCamera2CameraControl.addCaptureRequestOptions(any),
      ).thenAnswer((_) async => Future<void>.value());

      final createdMeteringPoints = <MeteringPoint>[];
      setUpOverridesForSettingFocusandExposurePoints(
        mockCameraControl,
        mockCamera2CameraControl,
        newDisplayOrientedMeteringPointFactory:
            ({
              required dynamic cameraInfo,
              required double width,
              required double height,
            }) {
              final mockFactory = MockDisplayOrientedMeteringPointFactory();
              when(
                mockFactory.createPoint(exposurePointX, exposurePointY),
              ).thenAnswer((_) async {
                final createdMeteringPoint = MeteringPoint.pigeon_detached();
                createdMeteringPoints.add(createdMeteringPoint);
                return createdMeteringPoint;
              });
              when(mockFactory.createPointWithSize(0.5, 0.5, 1)).thenAnswer((
                _,
              ) async {
                final createdMeteringPoint = MeteringPoint.pigeon_detached();
                createdMeteringPoints.add(createdMeteringPoint);
                return createdMeteringPoint;
              });
              return mockFactory;
            },
      );

      // Make setting focus and metering action successful for test.
      when(mockFocusMeteringResult.isFocusSuccessful).thenReturn(true);
      when(mockCameraControl.startFocusAndMetering(any)).thenAnswer(
        (_) async => Future<FocusMeteringResult>.value(mockFocusMeteringResult),
      );

      // Set exposure points.
      await camera.setExposurePoint(
        cameraId,
        const Point<double>(exposurePointX, exposurePointY),
      );

      // Lock focus default focus point.
      await camera.setFocusMode(cameraId, FocusMode.locked);

      clearInteractions(mockCameraControl);

      // Test removal of default focus point.
      await camera.setFocusMode(cameraId, FocusMode.auto);

      final VerificationResult verificationResult = verify(
        mockCameraControl.startFocusAndMetering(captureAny),
      );
      final capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isTrue);

      // We expect only the previously set exposure point to be re-set.
      expect(capturedAction.meteringPointsAe.first, createdMeteringPoints[0]);
      expect(capturedAction.meteringPointsAe.length, equals(1));
      expect(capturedAction.meteringPointsAf.length, equals(0));
    },
  );

  test(
    'setFocusMode cancels focus and metering if only focus point previously set is a focus point',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 5;
      final mockCameraControl = MockCameraControl();
      final FocusMeteringResult mockFocusMeteringResult =
          MockFocusMeteringResult();
      final mockCamera2CameraControl = MockCamera2CameraControl();

      // Set directly for test versus calling createCamera.
      camera.cameraInfo = MockCameraInfo();
      camera.cameraControl = mockCameraControl;

      when(
        mockCamera2CameraControl.addCaptureRequestOptions(any),
      ).thenAnswer((_) async => Future<void>.value());

      setUpOverridesForSettingFocusandExposurePoints(
        mockCameraControl,
        mockCamera2CameraControl,
      );

      // Make setting focus and metering action successful for test.
      when(mockFocusMeteringResult.isFocusSuccessful).thenReturn(true);
      when(mockCameraControl.startFocusAndMetering(any)).thenAnswer(
        (_) async => Future<FocusMeteringResult>.value(mockFocusMeteringResult),
      );

      // Lock focus default focus point.
      await camera.setFocusMode(cameraId, FocusMode.locked);

      // Test removal of default focus point.
      await camera.setFocusMode(cameraId, FocusMode.auto);

      verify(mockCameraControl.cancelFocusAndMetering());
    },
  );

  test(
    'setFocusMode re-focuses on previously set auto-focus point with auto-canceled enabled if setting auto-focus mode',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 6;
      final mockCameraControl = MockCameraControl();
      final FocusMeteringResult mockFocusMeteringResult =
          MockFocusMeteringResult();
      final mockCamera2CameraControl = MockCamera2CameraControl();
      const focusPointX = 0.1;
      const focusPointY = 0.2;

      // Set directly for test versus calling createCamera.
      camera.cameraInfo = MockCameraInfo();
      camera.cameraControl = mockCameraControl;

      when(
        mockCamera2CameraControl.addCaptureRequestOptions(any),
      ).thenAnswer((_) async => Future<void>.value());

      setUpOverridesForSettingFocusandExposurePoints(
        mockCameraControl,
        mockCamera2CameraControl,
      );

      // Make setting focus and metering action successful for test.
      when(mockFocusMeteringResult.isFocusSuccessful).thenReturn(true);
      when(mockCameraControl.startFocusAndMetering(any)).thenAnswer(
        (_) async => Future<FocusMeteringResult>.value(mockFocusMeteringResult),
      );

      // Lock a focus point.
      await camera.setFocusPoint(
        cameraId,
        const Point<double>(focusPointX, focusPointY),
      );
      await camera.setFocusMode(cameraId, FocusMode.locked);

      clearInteractions(mockCameraControl);

      // Test re-focusing on previously set auto-focus point with auto-cancel enabled.
      await camera.setFocusMode(cameraId, FocusMode.auto);

      final VerificationResult verificationResult = verify(
        mockCameraControl.startFocusAndMetering(captureAny),
      );
      final capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isTrue);
      expect(capturedAction.meteringPointsAe.length, equals(0));
      expect(capturedAction.meteringPointsAf.length, equals(1));
      expect(capturedAction.meteringPointsAwb.length, equals(0));
      final focusPoint =
          capturedAction.meteringPointsAf.single as TestMeteringPoint;
      expect(focusPoint.x, equals(focusPointX));
      expect(focusPoint.y, equals(focusPointY));
      expect(focusPoint.size, isNull);
    },
  );

  test(
    'setFocusMode starts expected focus and metering action with previously set auto-focus point if setting locked focus mode and current focus and metering action has auto-focus point',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 7;
      final mockCameraControl = MockCameraControl();
      final mockCamera2CameraControl = MockCamera2CameraControl();
      const focusPointX = 0.88;
      const focusPointY = 0.33;

      // Set directly for test versus calling createCamera.
      camera.cameraInfo = MockCameraInfo();
      camera.cameraControl = mockCameraControl;

      when(
        mockCamera2CameraControl.addCaptureRequestOptions(any),
      ).thenAnswer((_) async => Future<void>.value());

      setUpOverridesForSettingFocusandExposurePoints(
        mockCameraControl,
        mockCamera2CameraControl,
      );

      // Set a focus point.
      await camera.setFocusPoint(
        cameraId,
        const Point<double>(focusPointX, focusPointY),
      );
      clearInteractions(mockCameraControl);

      // Lock focus point.
      await camera.setFocusMode(cameraId, FocusMode.locked);

      final VerificationResult verificationResult = verify(
        mockCameraControl.startFocusAndMetering(captureAny),
      );
      final capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isFalse);

      // We expect the set focus point to be locked.
      expect(capturedAction.meteringPointsAe.length, equals(0));
      expect(capturedAction.meteringPointsAf.length, equals(1));
      expect(capturedAction.meteringPointsAwb.length, equals(0));

      final focusPoint =
          capturedAction.meteringPointsAf.single as TestMeteringPoint;
      expect(focusPoint.x, equals(focusPointX));
      expect(focusPoint.y, equals(focusPointY));
      expect(focusPoint.size, isNull);
    },
  );

  test(
    'setFocusMode starts expected focus and metering action with previously set auto-focus point if setting locked focus mode and current focus and metering action has auto-focus point amongst others',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 8;
      final mockCameraControl = MockCameraControl();
      final mockCamera2CameraControl = MockCamera2CameraControl();
      const focusPointX = 0.38;
      const focusPointY = 0.38;
      const exposurePointX = 0.54;
      const exposurePointY = 0.45;

      // Set directly for test versus calling createCamera.
      camera.cameraInfo = MockCameraInfo();
      camera.cameraControl = mockCameraControl;

      when(
        mockCamera2CameraControl.addCaptureRequestOptions(any),
      ).thenAnswer((_) async => Future<void>.value());

      setUpOverridesForSettingFocusandExposurePoints(
        mockCameraControl,
        mockCamera2CameraControl,
      );

      // Set focus and exposure points.
      await camera.setFocusPoint(
        cameraId,
        const Point<double>(focusPointX, focusPointY),
      );
      await camera.setExposurePoint(
        cameraId,
        const Point<double>(exposurePointX, exposurePointY),
      );
      clearInteractions(mockCameraControl);

      // Lock focus point.
      await camera.setFocusMode(cameraId, FocusMode.locked);

      final VerificationResult verificationResult = verify(
        mockCameraControl.startFocusAndMetering(captureAny),
      );
      final capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isFalse);

      // We expect two MeteringPoints, the set focus point and the set exposure
      // point.
      expect(capturedAction.meteringPointsAe.length, equals(1));
      expect(capturedAction.meteringPointsAf.length, equals(1));
      expect(capturedAction.meteringPointsAwb.length, equals(0));

      final focusPoint =
          capturedAction.meteringPointsAf.single as TestMeteringPoint;
      expect(focusPoint.x, equals(focusPointX));
      expect(focusPoint.y, equals(focusPointY));
      expect(focusPoint.size, isNull);

      final exposurePoint =
          capturedAction.meteringPointsAe.single as TestMeteringPoint;
      expect(exposurePoint.x, equals(exposurePointX));
      expect(exposurePoint.y, equals(exposurePointY));
      expect(exposurePoint.size, isNull);
    },
  );

  test(
    'setFocusMode starts expected focus and metering action if setting locked focus mode and current focus and metering action does not contain an auto-focus point',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 9;
      final mockCameraControl = MockCameraControl();
      final mockCamera2CameraControl = MockCamera2CameraControl();
      const exposurePointX = 0.8;
      const exposurePointY = 0.3;
      const defaultFocusPointX = 0.5;
      const defaultFocusPointY = 0.5;
      const double defaultFocusPointSize = 1;

      // Set directly for test versus calling createCamera.
      camera.cameraInfo = MockCameraInfo();
      camera.cameraControl = mockCameraControl;

      when(
        mockCamera2CameraControl.addCaptureRequestOptions(any),
      ).thenAnswer((_) async => Future<void>.value());

      setUpOverridesForSettingFocusandExposurePoints(
        mockCameraControl,
        mockCamera2CameraControl,
      );

      // Set an exposure point (creates a current focus and metering action
      // without a focus point).
      await camera.setExposurePoint(
        cameraId,
        const Point<double>(exposurePointX, exposurePointY),
      );
      clearInteractions(mockCameraControl);

      // Lock focus point.
      await camera.setFocusMode(cameraId, FocusMode.locked);

      final VerificationResult verificationResult = verify(
        mockCameraControl.startFocusAndMetering(captureAny),
      );
      final capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isFalse);

      // We expect two MeteringPoints, the default focus point and the set
      //exposure point.
      expect(capturedAction.meteringPointsAe.length, equals(1));
      expect(capturedAction.meteringPointsAf.length, equals(1));
      expect(capturedAction.meteringPointsAwb.length, equals(0));

      final focusPoint =
          capturedAction.meteringPointsAf.single as TestMeteringPoint;
      expect(focusPoint.x, equals(defaultFocusPointX));
      expect(focusPoint.y, equals(defaultFocusPointY));
      expect(focusPoint.size, equals(defaultFocusPointSize));

      final exposurePoint =
          capturedAction.meteringPointsAe.single as TestMeteringPoint;
      expect(exposurePoint.x, equals(exposurePointX));
      expect(exposurePoint.y, equals(exposurePointY));
      expect(exposurePoint.size, isNull);
    },
  );

  test(
    'setFocusMode starts expected focus and metering action if there is no current focus and metering action',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 10;
      final mockCameraControl = MockCameraControl();
      final mockCamera2CameraControl = MockCamera2CameraControl();
      const defaultFocusPointX = 0.5;
      const defaultFocusPointY = 0.5;
      const double defaultFocusPointSize = 1;

      // Set directly for test versus calling createCamera.
      camera.cameraInfo = MockCameraInfo();
      camera.cameraControl = mockCameraControl;

      when(
        mockCamera2CameraControl.addCaptureRequestOptions(any),
      ).thenAnswer((_) async => Future<void>.value());

      setUpOverridesForSettingFocusandExposurePoints(
        mockCameraControl,
        mockCamera2CameraControl,
      );

      // Lock focus point.
      await camera.setFocusMode(cameraId, FocusMode.locked);

      final VerificationResult verificationResult = verify(
        mockCameraControl.startFocusAndMetering(captureAny),
      );
      final capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isFalse);

      // We expect only the default focus point to be set.
      expect(capturedAction.meteringPointsAe.length, equals(0));
      expect(capturedAction.meteringPointsAf.length, equals(1));
      expect(capturedAction.meteringPointsAwb.length, equals(0));

      final focusPoint =
          capturedAction.meteringPointsAf.single as TestMeteringPoint;
      expect(focusPoint.x, equals(defaultFocusPointX));
      expect(focusPoint.y, equals(defaultFocusPointY));
      expect(focusPoint.size, equals(defaultFocusPointSize));
    },
  );

  test(
    'setFocusMode re-sets exposure mode if setting locked focus mode while using auto exposure mode',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 11;
      final mockCameraControl = MockCameraControl();
      final FocusMeteringResult mockFocusMeteringResult =
          MockFocusMeteringResult();
      final mockCamera2CameraControl = MockCamera2CameraControl();

      // Set directly for test versus calling createCamera.
      camera.cameraInfo = MockCameraInfo();
      camera.cameraControl = mockCameraControl;

      when(
        mockCamera2CameraControl.addCaptureRequestOptions(any),
      ).thenAnswer((_) async => Future<void>.value());

      setUpOverridesForSettingFocusandExposurePoints(
        mockCameraControl,
        mockCamera2CameraControl,
      );

      // Make setting focus and metering action successful for test.
      when(mockFocusMeteringResult.isFocusSuccessful).thenReturn(true);
      when(mockCameraControl.startFocusAndMetering(any)).thenAnswer(
        (_) async => Future<FocusMeteringResult>.value(mockFocusMeteringResult),
      );

      // Set auto exposure mode.
      await camera.setExposureMode(cameraId, ExposureMode.auto);
      clearInteractions(mockCamera2CameraControl);

      // Lock focus point.
      await camera.setFocusMode(cameraId, FocusMode.locked);

      final VerificationResult verificationResult = verify(
        mockCamera2CameraControl.addCaptureRequestOptions(captureAny),
      );
      final capturedCaptureRequestOptions =
          verificationResult.captured.single as CaptureRequestOptions;
      expect(
        await capturedCaptureRequestOptions.getCaptureRequestOption(
          CaptureRequest.controlAELock,
        ),
        isFalse,
      );
    },
  );

  test(
    'setFocusPoint disables auto-cancel if auto focus mode fails to be set after locked focus mode is set',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 22;
      final mockCameraControl = MockCameraControl();
      final mockFocusMeteringResult = MockFocusMeteringResult();
      const focusPoint = Point<double>(0.21, 0.21);

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = MockCameraInfo();

      setUpOverridesForSettingFocusandExposurePoints(
        mockCameraControl,
        MockCamera2CameraControl(),
      );

      // Make setting focus and metering action successful to set locked focus
      // mode.
      when(mockFocusMeteringResult.isFocusSuccessful).thenReturn(true);
      when(mockCameraControl.startFocusAndMetering(any)).thenAnswer(
        (_) async => Future<FocusMeteringResult>.value(mockFocusMeteringResult),
      );

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
      when(mockFocusMeteringResult.isFocusSuccessful).thenReturn(false);

      // Test disabling auto cancel.
      await camera.setFocusMode(cameraId, FocusMode.auto);
      clearInteractions(mockCameraControl);

      await camera.setFocusPoint(cameraId, focusPoint);
      final VerificationResult verificationResult = verify(
        mockCameraControl.startFocusAndMetering(captureAny),
      );
      final capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isFalse);
    },
  );

  test(
    'setExposurePoint disables auto-cancel if auto focus mode fails to be set after locked focus mode is set',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 342;
      final mockCameraControl = MockCameraControl();
      final mockFocusMeteringResult = MockFocusMeteringResult();
      const exposurePoint = Point<double>(0.23, 0.32);

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = MockCameraInfo();

      setUpOverridesForSettingFocusandExposurePoints(
        mockCameraControl,
        MockCamera2CameraControl(),
      );

      // Make setting focus and metering action successful to set locked focus
      // mode.
      when(mockFocusMeteringResult.isFocusSuccessful).thenReturn(true);
      when(mockCameraControl.startFocusAndMetering(any)).thenAnswer(
        (_) async => Future<FocusMeteringResult>.value(mockFocusMeteringResult),
      );

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
      when(mockFocusMeteringResult.isFocusSuccessful).thenReturn(false);

      // Test disabling auto cancel.
      await camera.setFocusMode(cameraId, FocusMode.auto);
      clearInteractions(mockCameraControl);

      await camera.setExposurePoint(cameraId, exposurePoint);
      final VerificationResult verificationResult = verify(
        mockCameraControl.startFocusAndMetering(captureAny),
      );
      final capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isFalse);
    },
  );

  test(
    'setFocusPoint enables auto-cancel if locked focus mode fails to be set after auto focus mode is set',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 232;
      final mockCameraControl = MockCameraControl();
      final mockFocusMeteringResult = MockFocusMeteringResult();
      const focusPoint = Point<double>(0.221, 0.211);

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = MockCameraInfo();

      setUpOverridesForSettingFocusandExposurePoints(
        mockCameraControl,
        MockCamera2CameraControl(),
      );

      // Make setting focus and metering action fail to test auto-cancel is not
      // disabled.
      when(mockFocusMeteringResult.isFocusSuccessful).thenReturn(false);
      when(mockCameraControl.startFocusAndMetering(any)).thenAnswer(
        (_) async => Future<FocusMeteringResult>.value(mockFocusMeteringResult),
      );

      // Set exposure point to later mock failed call to set an exposure point.
      await camera.setExposurePoint(cameraId, const Point<double>(0.43, 0.34));

      // Test failing to set locked focus mode.
      await camera.setFocusMode(cameraId, FocusMode.locked);
      clearInteractions(mockCameraControl);

      await camera.setFocusPoint(cameraId, focusPoint);
      final VerificationResult verificationResult = verify(
        mockCameraControl.startFocusAndMetering(captureAny),
      );
      final capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isTrue);
    },
  );

  test(
    'setExposurePoint enables auto-cancel if locked focus mode fails to be set after auto focus mode is set',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 323;
      final mockCameraControl = MockCameraControl();
      final mockFocusMeteringResult = MockFocusMeteringResult();
      const exposurePoint = Point<double>(0.223, 0.332);

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = MockCameraInfo();

      setUpOverridesForSettingFocusandExposurePoints(
        mockCameraControl,
        MockCamera2CameraControl(),
      );

      // Make setting focus and metering action fail to test auto-cancel is not
      // disabled.
      when(mockFocusMeteringResult.isFocusSuccessful).thenReturn(false);
      when(mockCameraControl.startFocusAndMetering(any)).thenAnswer(
        (_) async => Future<FocusMeteringResult>.value(mockFocusMeteringResult),
      );

      // Set exposure point to later mock failed call to set an exposure point.
      await camera.setExposurePoint(cameraId, const Point<double>(0.5, 0.2));

      // Test failing to set locked focus mode.
      await camera.setFocusMode(cameraId, FocusMode.locked);
      clearInteractions(mockCameraControl);

      await camera.setExposurePoint(cameraId, exposurePoint);
      final VerificationResult verificationResult = verify(
        mockCameraControl.startFocusAndMetering(captureAny),
      );
      final capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isTrue);
    },
  );

  test(
    'onStreamedFrameAvailable binds ImageAnalysis use case when not already bound',
    () async {
      final camera = AndroidCameraCameraX();
      const cameraId = 22;
      final mockImageAnalysis = MockImageAnalysis();
      final mockProcessCameraProvider = MockProcessCameraProvider();
      final mockCamera = MockCamera();
      final mockCameraInfo = MockCameraInfo();

      // Set directly for test versus calling createCamera.
      camera.imageAnalysis = mockImageAnalysis;
      camera.processCameraProvider = mockProcessCameraProvider;
      camera.cameraSelector = MockCameraSelector();

      // Ignore setting target rotation for this test; tested seprately.
      camera.captureOrientationLocked = true;

      // Tell plugin to create a detached analyzer for testing purposes.
      PigeonOverrides.analyzer_new =
          ({required void Function(Analyzer, ImageProxy) analyze}) =>
              MockAnalyzer();
      GenericsPigeonOverrides.observerNew =
          <T>({required void Function(Observer<T>, T) onChanged}) {
            return Observer<T>.detached(onChanged: onChanged);
          };

      when(
        mockProcessCameraProvider.isBound(mockImageAnalysis),
      ).thenAnswer((_) async => false);
      when(
        mockProcessCameraProvider.bindToLifecycle(any, <UseCase>[
          mockImageAnalysis,
        ]),
      ).thenAnswer((_) async => mockCamera);
      when(mockCamera.getCameraInfo()).thenAnswer((_) async => mockCameraInfo);
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => MockLiveCameraState());

      final StreamSubscription<CameraImageData> imageStreamSubscription = camera
          .onStreamedFrameAvailable(cameraId)
          .listen((CameraImageData data) {});

      await untilCalled(mockImageAnalysis.setAnalyzer(any));
      verify(
        mockProcessCameraProvider.bindToLifecycle(
          camera.cameraSelector,
          <UseCase>[mockImageAnalysis],
        ),
      );

      await imageStreamSubscription.cancel();
    },
  );

  test(
    'startVideoCapturing unbinds ImageAnalysis use case when camera device is not at least level 3, no image streaming callback is specified, and preview is not paused',
    () async {
      // Set up mocks and constants.
      final camera = AndroidCameraCameraX();
      final mockPendingRecording = MockPendingRecording();
      final mockRecording = MockRecording();
      final mockCamera = MockCamera();
      final mockCameraInfo = MockCameraInfo();
      final mockCamera2CameraInfo = MockCamera2CameraInfo();

      // Set directly for test versus calling createCamera.
      camera.processCameraProvider = MockProcessCameraProvider();
      camera.recorder = MockRecorder();
      camera.videoCapture = MockVideoCapture();
      camera.cameraSelector = MockCameraSelector();
      camera.cameraInfo = MockCameraInfo();
      camera.imageAnalysis = MockImageAnalysis();
      camera.enableRecordingAudio = false;

      // Ignore setting target rotation for this test; tested seprately.
      camera.captureOrientationLocked = true;

      // Tell plugin to create detached Observer when camera info updated.
      const outputPath = '/temp/REC123.mp4';
      GenericsPigeonOverrides.observerNew =
          <T>({required void Function(Observer<T>, T) onChanged}) {
            return Observer<T>.detached(onChanged: onChanged);
          };
      GenericsPigeonOverrides.observerNew =
          <T>({required void Function(Observer<T>, T) onChanged}) {
            return Observer<T>.detached(onChanged: onChanged);
          };
      PigeonOverrides.camera2CameraInfo_from =
          ({required dynamic cameraInfo}) => mockCamera2CameraInfo;
      PigeonOverrides.systemServicesManager_new =
          ({
            required void Function(SystemServicesManager, String) onCameraError,
          }) {
            final mockSystemServicesManager = MockSystemServicesManager();
            when(
              mockSystemServicesManager.getTempFilePath(
                camera.videoPrefix,
                '.mp4',
              ),
            ).thenAnswer((_) async => outputPath);
            return mockSystemServicesManager;
          };
      PigeonOverrides.videoRecordEventListener_new =
          ({
            required void Function(VideoRecordEventListener, VideoRecordEvent)
            onEvent,
          }) {
            return VideoRecordEventListener.pigeon_detached(onEvent: onEvent);
          };
      PigeonOverrides.cameraCharacteristics_infoSupportedHardwareLevel =
          MockCameraCharacteristicsKey();

      const cameraId = 7;

      // Mock method calls.
      when(
        camera.recorder!.prepareRecording(outputPath),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.withAudioEnabled(!camera.enableRecordingAudio),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.asPersistentRecording(),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.start(any),
      ).thenAnswer((_) async => mockRecording);
      when(
        camera.processCameraProvider!.isBound(camera.videoCapture!),
      ).thenAnswer((_) async => false);
      when(
        camera.processCameraProvider!.isBound(camera.imageAnalysis!),
      ).thenAnswer((_) async => true);
      when(
        camera.processCameraProvider!.bindToLifecycle(
          camera.cameraSelector!,
          <UseCase>[camera.videoCapture!],
        ),
      ).thenAnswer((_) async => mockCamera);
      when(
        mockCamera.getCameraInfo(),
      ).thenAnswer((_) => Future<CameraInfo>.value(mockCameraInfo));
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => MockLiveCameraState());
      when(
        mockCamera2CameraInfo.getCameraCharacteristic(any),
      ).thenAnswer((_) async => InfoSupportedHardwareLevel.full);

      // Simulate video recording being started so startVideoRecording completes.
      AndroidCameraCameraX.videoRecordingEventStreamController.add(
        VideoRecordEventStart.pigeon_detached(),
      );

      await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));

      verify(
        camera.processCameraProvider!.unbind(<UseCase>[camera.imageAnalysis!]),
      );
    },
  );

  test(
    'startVideoCapturing unbinds ImageAnalysis use case when image streaming callback not specified, camera device is level 3, and preview is not paused',
    () async {
      // Set up mocks and constants.
      final camera = AndroidCameraCameraX();
      final mockPendingRecording = MockPendingRecording();
      final mockRecording = MockRecording();
      final mockCamera = MockCamera();
      final mockCameraInfo = MockCameraInfo();
      final mockCamera2CameraInfo = MockCamera2CameraInfo();

      // Set directly for test versus calling createCamera.
      camera.processCameraProvider = MockProcessCameraProvider();
      camera.recorder = MockRecorder();
      camera.videoCapture = MockVideoCapture();
      camera.cameraSelector = MockCameraSelector();
      camera.cameraInfo = MockCameraInfo();
      camera.imageAnalysis = MockImageAnalysis();
      camera.enableRecordingAudio = true;

      // Ignore setting target rotation for this test; tested seprately.
      camera.captureOrientationLocked = true;

      // Tell plugin to create detached Observer when camera info updated.
      const outputPath = '/temp/REC123.mp4';
      GenericsPigeonOverrides.observerNew =
          <T>({required void Function(Observer<T>, T) onChanged}) {
            return Observer<T>.detached(onChanged: onChanged);
          };
      PigeonOverrides.camera2CameraInfo_from =
          ({required dynamic cameraInfo}) => mockCamera2CameraInfo;
      PigeonOverrides.systemServicesManager_new =
          ({
            required void Function(SystemServicesManager, String) onCameraError,
          }) {
            final mockSystemServicesManager = MockSystemServicesManager();
            when(
              mockSystemServicesManager.getTempFilePath(
                camera.videoPrefix,
                '.mp4',
              ),
            ).thenAnswer((_) async => outputPath);
            return mockSystemServicesManager;
          };
      PigeonOverrides.videoRecordEventListener_new =
          ({
            required void Function(VideoRecordEventListener, VideoRecordEvent)
            onEvent,
          }) {
            return VideoRecordEventListener.pigeon_detached(onEvent: onEvent);
          };
      PigeonOverrides.cameraCharacteristics_infoSupportedHardwareLevel =
          MockCameraCharacteristicsKey();

      const cameraId = 77;

      // Mock method calls.
      when(
        camera.recorder!.prepareRecording(outputPath),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.withAudioEnabled(!camera.enableRecordingAudio),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.asPersistentRecording(),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.start(any),
      ).thenAnswer((_) async => mockRecording);
      when(
        camera.processCameraProvider!.isBound(camera.videoCapture!),
      ).thenAnswer((_) async => false);
      when(
        camera.processCameraProvider!.isBound(camera.imageAnalysis!),
      ).thenAnswer((_) async => true);
      when(
        camera.processCameraProvider!.bindToLifecycle(
          camera.cameraSelector!,
          <UseCase>[camera.videoCapture!],
        ),
      ).thenAnswer((_) async => mockCamera);
      when(
        mockCamera.getCameraInfo(),
      ).thenAnswer((_) => Future<CameraInfo>.value(mockCameraInfo));
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => MockLiveCameraState());
      when(
        mockCamera2CameraInfo.getCameraCharacteristic(any),
      ).thenAnswer((_) async => InfoSupportedHardwareLevel.level3);

      // Simulate video recording being started so startVideoRecording completes.
      AndroidCameraCameraX.videoRecordingEventStreamController.add(
        VideoRecordEventStart.pigeon_detached(),
      );

      await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));

      verify(
        camera.processCameraProvider!.unbind(<UseCase>[camera.imageAnalysis!]),
      );
    },
  );

  test(
    'startVideoCapturing unbinds ImageAnalysis use case when image streaming callback is specified, camera device is not at least level 3, and preview is not paused',
    () async {
      // Set up mocks and constants.
      final camera = AndroidCameraCameraX();
      final mockPendingRecording = MockPendingRecording();
      final mockRecording = MockRecording();
      final mockCamera = MockCamera();
      final mockCameraInfo = MockCameraInfo();
      final mockCamera2CameraInfo = MockCamera2CameraInfo();

      // Set directly for test versus calling createCamera.
      camera.processCameraProvider = MockProcessCameraProvider();
      camera.recorder = MockRecorder();
      camera.videoCapture = MockVideoCapture();
      camera.cameraSelector = MockCameraSelector();
      camera.cameraInfo = MockCameraInfo();
      camera.imageAnalysis = MockImageAnalysis();
      camera.enableRecordingAudio = false;

      // Ignore setting target rotation for this test; tested separately.
      camera.captureOrientationLocked = true;

      // Tell plugin to create detached Observer when camera info updated.
      const outputPath = '/temp/REC123.mp4';
      GenericsPigeonOverrides.observerNew =
          <T>({required void Function(Observer<T>, T) onChanged}) {
            return Observer<T>.detached(onChanged: onChanged);
          };
      PigeonOverrides.camera2CameraInfo_from =
          ({required dynamic cameraInfo}) => mockCamera2CameraInfo;
      PigeonOverrides.systemServicesManager_new =
          ({
            required void Function(SystemServicesManager, String) onCameraError,
          }) {
            final mockSystemServicesManager = MockSystemServicesManager();
            when(
              mockSystemServicesManager.getTempFilePath(
                camera.videoPrefix,
                '.mp4',
              ),
            ).thenAnswer((_) async => outputPath);
            return mockSystemServicesManager;
          };
      PigeonOverrides.videoRecordEventListener_new =
          ({
            required void Function(VideoRecordEventListener, VideoRecordEvent)
            onEvent,
          }) {
            return VideoRecordEventListener.pigeon_detached(onEvent: onEvent);
          };
      PigeonOverrides.cameraCharacteristics_infoSupportedHardwareLevel =
          MockCameraCharacteristicsKey();

      const cameraId = 87;

      // Mock method calls.
      when(
        camera.recorder!.prepareRecording(outputPath),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.withAudioEnabled(!camera.enableRecordingAudio),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.asPersistentRecording(),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.start(any),
      ).thenAnswer((_) async => mockRecording);
      when(
        camera.processCameraProvider!.isBound(camera.videoCapture!),
      ).thenAnswer((_) async => false);
      when(
        camera.processCameraProvider!.isBound(camera.imageAnalysis!),
      ).thenAnswer((_) async => true);
      when(
        camera.processCameraProvider!.bindToLifecycle(
          camera.cameraSelector!,
          <UseCase>[camera.videoCapture!],
        ),
      ).thenAnswer((_) async => mockCamera);
      when(
        mockCamera.getCameraInfo(),
      ).thenAnswer((_) => Future<CameraInfo>.value(mockCameraInfo));
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => MockLiveCameraState());
      when(
        mockCamera2CameraInfo.getCameraCharacteristic(any),
      ).thenAnswer((_) async => InfoSupportedHardwareLevel.external);

      // Simulate video recording being started so startVideoRecording completes.
      AndroidCameraCameraX.videoRecordingEventStreamController.add(
        VideoRecordEventStart.pigeon_detached(),
      );

      await camera.startVideoCapturing(
        VideoCaptureOptions(
          cameraId,
          streamCallback: (CameraImageData image) {},
        ),
      );
      verify(
        camera.processCameraProvider!.unbind(<UseCase>[camera.imageAnalysis!]),
      );
    },
  );

  test(
    'startVideoCapturing unbinds ImageCapture use case when image streaming callback is specified,  camera device is at least level 3, and preview is not paused',
    () async {
      // Set up mocks and constants.
      final camera = AndroidCameraCameraX();
      final mockPendingRecording = MockPendingRecording();
      final mockRecording = MockRecording();
      final mockCamera = MockCamera();
      final mockCameraInfo = MockCameraInfo();
      final mockCamera2CameraInfo = MockCamera2CameraInfo();

      // Set directly for test versus calling createCamera.
      camera.processCameraProvider = MockProcessCameraProvider();
      camera.recorder = MockRecorder();
      camera.videoCapture = MockVideoCapture();
      camera.cameraSelector = MockCameraSelector();
      camera.cameraInfo = MockCameraInfo();
      camera.imageAnalysis = MockImageAnalysis();
      camera.imageCapture = MockImageCapture();
      camera.enableRecordingAudio = true;

      // Ignore setting target rotation for this test; tested seprately.
      camera.captureOrientationLocked = true;

      // Tell plugin to create detached Observer when camera info updated.
      const outputPath = '/temp/REC123.mp4';
      PigeonOverrides.analyzer_new =
          ({required void Function(Analyzer, ImageProxy) analyze}) {
            return Analyzer.pigeon_detached(analyze: analyze);
          };
      GenericsPigeonOverrides.observerNew =
          <T>({required void Function(Observer<T>, T) onChanged}) {
            return Observer<T>.detached(onChanged: onChanged);
          };
      PigeonOverrides.camera2CameraInfo_from =
          ({required dynamic cameraInfo}) => mockCamera2CameraInfo;
      PigeonOverrides.systemServicesManager_new =
          ({
            required void Function(SystemServicesManager, String) onCameraError,
          }) {
            final mockSystemServicesManager = MockSystemServicesManager();
            when(
              mockSystemServicesManager.getTempFilePath(
                camera.videoPrefix,
                '.mp4',
              ),
            ).thenAnswer((_) async => outputPath);
            return mockSystemServicesManager;
          };
      PigeonOverrides.videoRecordEventListener_new =
          ({
            required void Function(VideoRecordEventListener, VideoRecordEvent)
            onEvent,
          }) {
            return VideoRecordEventListener.pigeon_detached(onEvent: onEvent);
          };
      PigeonOverrides.cameraCharacteristics_infoSupportedHardwareLevel =
          MockCameraCharacteristicsKey();

      const cameraId = 107;

      // Mock method calls.
      when(
        camera.recorder!.prepareRecording(outputPath),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.withAudioEnabled(!camera.enableRecordingAudio),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.asPersistentRecording(),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.start(any),
      ).thenAnswer((_) async => mockRecording);
      when(
        camera.processCameraProvider!.isBound(camera.videoCapture!),
      ).thenAnswer((_) async => false);
      when(
        camera.processCameraProvider!.isBound(camera.imageCapture!),
      ).thenAnswer((_) async => true);
      when(
        camera.processCameraProvider!.isBound(camera.imageAnalysis!),
      ).thenAnswer((_) async => true);
      when(
        camera.processCameraProvider!.bindToLifecycle(
          camera.cameraSelector!,
          <UseCase>[camera.videoCapture!],
        ),
      ).thenAnswer((_) async => mockCamera);
      when(
        mockCamera.getCameraInfo(),
      ).thenAnswer((_) => Future<CameraInfo>.value(mockCameraInfo));
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => MockLiveCameraState());
      when(
        mockCamera2CameraInfo.getCameraCharacteristic(any),
      ).thenAnswer((_) async => InfoSupportedHardwareLevel.level3);

      // Simulate video recording being started so startVideoRecording completes.
      AndroidCameraCameraX.videoRecordingEventStreamController.add(
        VideoRecordEventStart.pigeon_detached(),
      );

      await camera.startVideoCapturing(
        VideoCaptureOptions(
          cameraId,
          streamCallback: (CameraImageData image) {},
        ),
      );
      verify(
        camera.processCameraProvider!.unbind(<UseCase>[camera.imageCapture!]),
      );
    },
  );

  test(
    'startVideoCapturing does not unbind ImageCapture or ImageAnalysis use cases when preview is paused',
    () async {
      // Set up mocks and constants.
      final camera = AndroidCameraCameraX();
      final mockPendingRecording = MockPendingRecording();
      final mockRecording = MockRecording();
      final mockCamera = MockCamera();
      final mockCameraInfo = MockCameraInfo();
      final mockCamera2CameraInfo = MockCamera2CameraInfo();

      // Set directly for test versus calling createCamera.
      camera.processCameraProvider = MockProcessCameraProvider();
      camera.recorder = MockRecorder();
      camera.videoCapture = MockVideoCapture();
      camera.cameraSelector = MockCameraSelector();
      camera.cameraInfo = MockCameraInfo();
      camera.imageAnalysis = MockImageAnalysis();
      camera.imageCapture = MockImageCapture();
      camera.preview = MockPreview();
      camera.enableRecordingAudio = false;

      // Ignore setting target rotation for this test; tested seprately.
      camera.captureOrientationLocked = true;

      // Tell plugin to create detached Observer when camera info updated.
      const outputPath = '/temp/REC123.mp4';
      PigeonOverrides.analyzer_new =
          ({required void Function(Analyzer, ImageProxy) analyze}) {
            return Analyzer.pigeon_detached(analyze: analyze);
          };
      GenericsPigeonOverrides.observerNew =
          <T>({required void Function(Observer<T>, T) onChanged}) {
            return Observer<T>.detached(onChanged: onChanged);
          };
      PigeonOverrides.camera2CameraInfo_from =
          ({required dynamic cameraInfo}) => mockCamera2CameraInfo;
      PigeonOverrides.systemServicesManager_new =
          ({
            required void Function(SystemServicesManager, String) onCameraError,
          }) {
            final mockSystemServicesManager = MockSystemServicesManager();
            when(
              mockSystemServicesManager.getTempFilePath(
                camera.videoPrefix,
                '.mp4',
              ),
            ).thenAnswer((_) async => outputPath);
            return mockSystemServicesManager;
          };
      PigeonOverrides.videoRecordEventListener_new =
          ({
            required void Function(VideoRecordEventListener, VideoRecordEvent)
            onEvent,
          }) {
            return VideoRecordEventListener.pigeon_detached(onEvent: onEvent);
          };
      PigeonOverrides.cameraCharacteristics_infoSupportedHardwareLevel =
          MockCameraCharacteristicsKey();

      const cameraId = 97;

      // Mock method calls.
      when(
        camera.recorder!.prepareRecording(outputPath),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.withAudioEnabled(!camera.enableRecordingAudio),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.asPersistentRecording(),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.start(any),
      ).thenAnswer((_) async => mockRecording);
      when(
        camera.processCameraProvider!.isBound(camera.videoCapture!),
      ).thenAnswer((_) async => false);
      when(
        camera.processCameraProvider!.bindToLifecycle(
          camera.cameraSelector!,
          <UseCase>[camera.videoCapture!],
        ),
      ).thenAnswer((_) async => mockCamera);
      when(
        mockCamera.getCameraInfo(),
      ).thenAnswer((_) => Future<CameraInfo>.value(mockCameraInfo));
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => MockLiveCameraState());

      await camera.pausePreview(cameraId);

      // Simulate video recording being started so startVideoRecording completes.
      AndroidCameraCameraX.videoRecordingEventStreamController.add(
        VideoRecordEventStart.pigeon_detached(),
      );

      await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));

      verifyNever(
        camera.processCameraProvider!.unbind(<UseCase>[camera.imageCapture!]),
      );
      verifyNever(
        camera.processCameraProvider!.unbind(<UseCase>[camera.imageAnalysis!]),
      );
    },
  );

  test(
    'startVideoCapturing unbinds ImageCapture and ImageAnalysis use cases when running on a legacy hardware device',
    () async {
      // Set up mocks and constants.
      final camera = AndroidCameraCameraX();
      final mockPendingRecording = MockPendingRecording();
      final mockRecording = MockRecording();
      final mockCamera = MockCamera();
      final mockCameraInfo = MockCameraInfo();
      final mockCamera2CameraInfo = MockCamera2CameraInfo();

      // Set directly for test versus calling createCamera.
      camera.processCameraProvider = MockProcessCameraProvider();
      camera.recorder = MockRecorder();
      camera.videoCapture = MockVideoCapture();
      camera.cameraSelector = MockCameraSelector();
      camera.cameraInfo = MockCameraInfo();
      camera.imageAnalysis = MockImageAnalysis();
      camera.imageCapture = MockImageCapture();
      camera.preview = MockPreview();
      camera.enableRecordingAudio = true;

      // Ignore setting target rotation for this test; tested seprately.
      camera.captureOrientationLocked = true;

      // Tell plugin to create detached Observer when camera info updated.
      const outputPath = '/temp/REC123.mp4';
      PigeonOverrides.analyzer_new =
          ({required void Function(Analyzer, ImageProxy) analyze}) {
            return Analyzer.pigeon_detached(analyze: analyze);
          };
      GenericsPigeonOverrides.observerNew =
          <T>({required void Function(Observer<T>, T) onChanged}) {
            return Observer<T>.detached(onChanged: onChanged);
          };
      PigeonOverrides.camera2CameraInfo_from =
          ({required dynamic cameraInfo}) => mockCamera2CameraInfo;
      PigeonOverrides.systemServicesManager_new =
          ({
            required void Function(SystemServicesManager, String) onCameraError,
          }) {
            final mockSystemServicesManager = MockSystemServicesManager();
            when(
              mockSystemServicesManager.getTempFilePath(
                camera.videoPrefix,
                '.mp4',
              ),
            ).thenAnswer((_) async => outputPath);
            return mockSystemServicesManager;
          };
      PigeonOverrides.videoRecordEventListener_new =
          ({
            required void Function(VideoRecordEventListener, VideoRecordEvent)
            onEvent,
          }) {
            return VideoRecordEventListener.pigeon_detached(onEvent: onEvent);
          };
      PigeonOverrides.cameraCharacteristics_infoSupportedHardwareLevel =
          MockCameraCharacteristicsKey();

      const cameraId = 44;

      // Mock method calls.
      when(
        camera.recorder!.prepareRecording(outputPath),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.withAudioEnabled(!camera.enableRecordingAudio),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.asPersistentRecording(),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.start(any),
      ).thenAnswer((_) async => mockRecording);
      when(
        camera.processCameraProvider!.isBound(camera.videoCapture!),
      ).thenAnswer((_) async => false);
      when(
        camera.processCameraProvider!.isBound(camera.imageCapture!),
      ).thenAnswer((_) async => true);
      when(
        camera.processCameraProvider!.isBound(camera.imageAnalysis!),
      ).thenAnswer((_) async => true);
      when(
        camera.processCameraProvider!.bindToLifecycle(
          camera.cameraSelector!,
          <UseCase>[camera.videoCapture!],
        ),
      ).thenAnswer((_) async => mockCamera);
      when(
        mockCamera.getCameraInfo(),
      ).thenAnswer((_) => Future<CameraInfo>.value(mockCameraInfo));
      when(
        mockCameraInfo.getCameraState(),
      ).thenAnswer((_) async => MockLiveCameraState());
      when(
        mockCamera2CameraInfo.getCameraCharacteristic(any),
      ).thenAnswer((_) async => InfoSupportedHardwareLevel.legacy);

      // Simulate video recording being started so startVideoRecording completes.
      AndroidCameraCameraX.videoRecordingEventStreamController.add(
        VideoRecordEventStart.pigeon_detached(),
      );

      await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));

      verify(
        camera.processCameraProvider!.unbind(<UseCase>[camera.imageCapture!]),
      );
      verify(
        camera.processCameraProvider!.unbind(<UseCase>[camera.imageAnalysis!]),
      );
    },
  );

  test(
    'prepareForVideoRecording does not make any calls involving starting video recording',
    () async {
      final camera = AndroidCameraCameraX();

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
    },
  );
}

class TestMeteringPoint extends MeteringPoint {
  TestMeteringPoint.detached({required this.x, required this.y, this.size})
    : super.pigeon_detached();

  final double x;
  final double y;
  final double? size;
}
