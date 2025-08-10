// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' show Point;

import 'package:async/async.dart';
import 'package:camera_android_camerax/camera_android_camerax.dart';
import 'package:camera_android_camerax/src/camerax_library.dart';
import 'package:camera_android_camerax/src/camerax_proxy.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart'
    show BinaryMessenger, DeviceOrientation, PlatformException, Uint8List;
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
  MockSpec<CameraXProxy>(),
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

  /// Helper method for testing sending/receiving CameraErrorEvents.
  Future<bool> testCameraClosingObserver(
    AndroidCameraCameraX camera,
    int cameraId,
    Observer<dynamic> observer,
  ) async {
    final CameraStateStateError testCameraStateError =
        CameraStateStateError.pigeon_detached(
          code: CameraStateErrorCode.doNotDisturbModeEnabled,
          pigeon_instanceManager: PigeonInstanceManager(
            onWeakReferenceRemoved: (_) {},
          ),
        );
    final Stream<CameraClosingEvent> cameraClosingEventStream = camera
        .onCameraClosing(cameraId);
    final StreamQueue<CameraClosingEvent> cameraClosingStreamQueue =
        StreamQueue<CameraClosingEvent>(cameraClosingEventStream);
    final Stream<CameraErrorEvent> cameraErrorEventStream = camera
        .onCameraError(cameraId);
    final StreamQueue<CameraErrorEvent> cameraErrorStreamQueue =
        StreamQueue<CameraErrorEvent>(cameraErrorEventStream);

    observer.onChanged(
      observer,
      CameraState.pigeon_detached(
        type: CameraStateType.closing,
        error: testCameraStateError,
        pigeon_instanceManager: PigeonInstanceManager(
          onWeakReferenceRemoved: (_) {},
        ),
      ),
    );

    final bool cameraClosingEventSent =
        await cameraClosingStreamQueue.next == CameraClosingEvent(cameraId);
    final bool cameraErrorSent =
        await cameraErrorStreamQueue.next ==
        CameraErrorEvent(
          cameraId,
          'The camera could not be opened because "Do Not Disturb" mode is enabled. Please disable this mode, and try opening the camera again.',
        );

    await cameraClosingStreamQueue.cancel();
    await cameraErrorStreamQueue.cancel();

    return cameraClosingEventSent && cameraErrorSent;
  }

  /// CameraXProxy for testing functionality related to the camera resolution
  /// preset (setting expected ResolutionSelectors, QualitySelectors, etc.).
  CameraXProxy getProxyForTestingResolutionPreset(
    MockProcessCameraProvider mockProcessCameraProvider, {
    ResolutionFilter Function({
      required CameraSize preferredSize,
      // ignore: non_constant_identifier_names
      BinaryMessenger? pigeon_binaryMessenger,
      // ignore: non_constant_identifier_names
      PigeonInstanceManager? pigeon_instanceManager,
    })?
    createWithOnePreferredSizeResolutionFilter,
    FallbackStrategy Function({
      required VideoQuality quality,
      // ignore: non_constant_identifier_names
      BinaryMessenger? pigeon_binaryMessenger,
      // ignore: non_constant_identifier_names
      PigeonInstanceManager? pigeon_instanceManager,
    })?
    lowerQualityOrHigherThanFallbackStrategy,
    QualitySelector Function({
      required VideoQuality quality,
      FallbackStrategy? fallbackStrategy,
      // ignore: non_constant_identifier_names
      BinaryMessenger? pigeon_binaryMessenger,
      // ignore: non_constant_identifier_names
      PigeonInstanceManager? pigeon_instanceManager,
    })?
    fromQualitySelector,
    Preview Function({
      int? targetRotation,
      ResolutionSelector? resolutionSelector,
      // ignore: non_constant_identifier_names
      BinaryMessenger? pigeon_binaryMessenger,
      // ignore: non_constant_identifier_names
      PigeonInstanceManager? pigeon_instanceManager,
    })?
    newPreview,
  }) {
    late final CameraXProxy proxy;
    final AspectRatioStrategy ratio_4_3FallbackAutoStrategyAspectRatioStrategy =
        MockAspectRatioStrategy();
    final ResolutionStrategy highestAvailableStrategyResolutionStrategy =
        MockResolutionStrategy();
    proxy = CameraXProxy(
      getInstanceProcessCameraProvider:
          ({
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) async {
            return mockProcessCameraProvider;
          },
      newCameraSelector:
          ({
            LensFacing? requireLensFacing,
            CameraInfo? cameraInfoForFilter,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) {
            switch (requireLensFacing) {
              case LensFacing.front:
                return MockCameraSelector();
              case LensFacing.back:
              case LensFacing.external:
              case LensFacing.unknown:
              case null:
            }

            return MockCameraSelector();
          },
      newPreview:
          newPreview ??
          ({
            int? targetRotation,
            ResolutionSelector? resolutionSelector,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) {
            final MockPreview mockPreview = MockPreview();
            when(
              mockPreview.surfaceProducerHandlesCropAndRotation(),
            ).thenAnswer((_) async => false);
            when(mockPreview.resolutionSelector).thenReturn(resolutionSelector);
            return mockPreview;
          },
      newImageCapture:
          ({
            int? targetRotation,
            CameraXFlashMode? flashMode,
            ResolutionSelector? resolutionSelector,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) {
            final MockImageCapture mockImageCapture = MockImageCapture();
            when(
              mockImageCapture.resolutionSelector,
            ).thenReturn(resolutionSelector);
            return mockImageCapture;
          },
      newRecorder:
          ({
            int? aspectRatio,
            int? targetVideoEncodingBitRate,
            QualitySelector? qualitySelector,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) {
            final MockRecorder mockRecorder = MockRecorder();
            when(
              mockRecorder.getQualitySelector(),
            ).thenAnswer((_) async => qualitySelector ?? MockQualitySelector());
            return mockRecorder;
          },
      withOutputVideoCapture:
          ({
            required VideoOutput videoOutput,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) {
            return MockVideoCapture();
          },
      newImageAnalysis:
          ({
            int? targetRotation,
            ResolutionSelector? resolutionSelector,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) {
            final MockImageAnalysis mockImageAnalysis = MockImageAnalysis();
            when(
              mockImageAnalysis.resolutionSelector,
            ).thenReturn(resolutionSelector);
            return mockImageAnalysis;
          },
      newResolutionStrategy:
          ({
            required CameraSize boundSize,
            required ResolutionStrategyFallbackRule fallbackRule,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) {
            final MockResolutionStrategy resolutionStrategy =
                MockResolutionStrategy();
            when(
              resolutionStrategy.getBoundSize(),
            ).thenAnswer((_) async => boundSize);
            when(
              resolutionStrategy.getFallbackRule(),
            ).thenAnswer((_) async => fallbackRule);
            return resolutionStrategy;
          },
      newResolutionSelector:
          ({
            AspectRatioStrategy? aspectRatioStrategy,
            ResolutionStrategy? resolutionStrategy,
            ResolutionFilter? resolutionFilter,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) {
            final MockResolutionSelector mockResolutionSelector =
                MockResolutionSelector();
            when(mockResolutionSelector.getAspectRatioStrategy()).thenAnswer(
              (_) async =>
                  aspectRatioStrategy ??
                  proxy.ratio_4_3FallbackAutoStrategyAspectRatioStrategy(),
            );
            when(
              mockResolutionSelector.resolutionStrategy,
            ).thenReturn(resolutionStrategy);
            when(
              mockResolutionSelector.resolutionFilter,
            ).thenReturn(resolutionFilter);
            return mockResolutionSelector;
          },
      fromQualitySelector:
          fromQualitySelector ??
          ({
            required VideoQuality quality,
            FallbackStrategy? fallbackStrategy,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) {
            return MockQualitySelector();
          },
      newObserver:
          <T>({
            required void Function(Observer<T>, T) onChanged,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) {
            return Observer<T>.detached(
              onChanged: onChanged,
              pigeon_instanceManager: PigeonInstanceManager(
                onWeakReferenceRemoved: (_) {},
              ),
            );
          },
      newSystemServicesManager:
          ({
            required void Function(SystemServicesManager, String) onCameraError,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) {
            return MockSystemServicesManager();
          },
      newDeviceOrientationManager:
          ({
            required void Function(DeviceOrientationManager, String)
            onDeviceOrientationChanged,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) {
            final MockDeviceOrientationManager manager =
                MockDeviceOrientationManager();
            when(manager.getUiOrientation()).thenAnswer((_) async {
              return 'PORTRAIT_UP';
            });
            return manager;
          },
      newAspectRatioStrategy:
          ({
            required AspectRatio preferredAspectRatio,
            required AspectRatioStrategyFallbackRule fallbackRule,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) {
            final MockAspectRatioStrategy mockAspectRatioStrategy =
                MockAspectRatioStrategy();
            when(
              mockAspectRatioStrategy.getFallbackRule(),
            ).thenAnswer((_) async => fallbackRule);
            when(
              mockAspectRatioStrategy.getPreferredAspectRatio(),
            ).thenAnswer((_) async => preferredAspectRatio);
            return mockAspectRatioStrategy;
          },
      createWithOnePreferredSizeResolutionFilter:
          createWithOnePreferredSizeResolutionFilter ??
          ({
            required CameraSize preferredSize,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) {
            return MockResolutionFilter();
          },
      fromCamera2CameraInfo:
          ({
            required CameraInfo cameraInfo,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) {
            final MockCamera2CameraInfo camera2cameraInfo =
                MockCamera2CameraInfo();
            when(
              camera2cameraInfo.getCameraCharacteristic(any),
            ).thenAnswer((_) async => 90);
            return camera2cameraInfo;
          },
      newCameraSize:
          ({
            required int width,
            required int height,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) {
            return CameraSize.pigeon_detached(
              width: width,
              height: height,
              pigeon_instanceManager: PigeonInstanceManager(
                onWeakReferenceRemoved: (_) {},
              ),
            );
          },
      sensorOrientationCameraCharacteristics: () {
        return MockCameraCharacteristicsKey();
      },
      lowerQualityOrHigherThanFallbackStrategy:
          lowerQualityOrHigherThanFallbackStrategy ??
          ({
            required VideoQuality quality,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) {
            return MockFallbackStrategy();
          },
      highestAvailableStrategyResolutionStrategy: () {
        return highestAvailableStrategyResolutionStrategy;
      },
      ratio_4_3FallbackAutoStrategyAspectRatioStrategy: () =>
          ratio_4_3FallbackAutoStrategyAspectRatioStrategy,
      lowerQualityThanFallbackStrategy:
          ({
            required VideoQuality quality,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) {
            return MockFallbackStrategy();
          },
    );

    return proxy;
  }

  /// CameraXProxy for testing exposure and focus related controls.
  ///
  /// Modifies the creation of [MeteringPoint]s and [FocusMeteringAction]s to
  /// return objects detached from a native object.
  CameraXProxy getProxyForExposureAndFocus({
    FocusMeteringActionBuilder Function({
      required MeteringPoint point,
      required MeteringMode mode,
      // ignore: non_constant_identifier_names
      BinaryMessenger? pigeon_binaryMessenger,
      // ignore: non_constant_identifier_names
      PigeonInstanceManager? pigeon_instanceManager,
    })?
    withModeFocusMeteringActionBuilder,
    DisplayOrientedMeteringPointFactory Function({
      required CameraInfo cameraInfo,
      required double width,
      required double height,
      // ignore: non_constant_identifier_names
      BinaryMessenger? pigeon_binaryMessenger,
      // ignore: non_constant_identifier_names
      PigeonInstanceManager? pigeon_instanceManager,
    })?
    newDisplayOrientedMeteringPointFactory,
  }) => CameraXProxy(
    newDisplayOrientedMeteringPointFactory:
        newDisplayOrientedMeteringPointFactory ??
        ({
          required CameraInfo cameraInfo,
          required double width,
          required double height,
          // ignore: non_constant_identifier_names
          BinaryMessenger? pigeon_binaryMessenger,
          // ignore: non_constant_identifier_names
          PigeonInstanceManager? pigeon_instanceManager,
        }) {
          final MockDisplayOrientedMeteringPointFactory mockFactory =
              MockDisplayOrientedMeteringPointFactory();
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
        },
    withModeFocusMeteringActionBuilder:
        withModeFocusMeteringActionBuilder ??
        ({
          required MeteringPoint point,
          required MeteringMode mode,
          // ignore: non_constant_identifier_names
          BinaryMessenger? pigeon_binaryMessenger,
          // ignore: non_constant_identifier_names
          PigeonInstanceManager? pigeon_instanceManager,
        }) {
          final PigeonInstanceManager testInstanceManager =
              PigeonInstanceManager(onWeakReferenceRemoved: (_) {});
          final MockFocusMeteringActionBuilder mockBuilder =
              MockFocusMeteringActionBuilder();
          bool disableAutoCancelCalled = false;
          when(mockBuilder.disableAutoCancel()).thenAnswer((_) async {
            disableAutoCancelCalled = true;
          });
          final List<MeteringPoint> meteringPointsAe = <MeteringPoint>[];
          final List<MeteringPoint> meteringPointsAf = <MeteringPoint>[];
          final List<MeteringPoint> meteringPointsAwb = <MeteringPoint>[];

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
              pigeon_instanceManager: testInstanceManager,
            ),
          );
          return mockBuilder;
        },
  );

  /// CameraXProxy for testing setting focus and exposure points.
  ///
  /// Modifies the retrieval of a [Camera2CameraControl] instance to depend on
  /// interaction with expected [cameraControl] instance and modifies creation
  /// of [CaptureRequestOptions] to return objects detached from a native object.
  CameraXProxy getProxyForSettingFocusandExposurePoints(
    CameraControl cameraControlForComparison,
    Camera2CameraControl camera2cameraControl, {
    FocusMeteringActionBuilder Function({
      required MeteringPoint point,
      required MeteringMode mode,
      // ignore: non_constant_identifier_names
      BinaryMessenger? pigeon_binaryMessenger,
      // ignore: non_constant_identifier_names
      PigeonInstanceManager? pigeon_instanceManager,
    })?
    withModeFocusMeteringActionBuilder,
    DisplayOrientedMeteringPointFactory Function({
      required CameraInfo cameraInfo,
      required double width,
      required double height,
      // ignore: non_constant_identifier_names
      BinaryMessenger? pigeon_binaryMessenger,
      // ignore: non_constant_identifier_names
      PigeonInstanceManager? pigeon_instanceManager,
    })?
    newDisplayOrientedMeteringPointFactory,
  }) {
    final CameraXProxy proxy = getProxyForExposureAndFocus();

    final PigeonInstanceManager testInstanceManager = PigeonInstanceManager(
      onWeakReferenceRemoved: (_) {},
    );
    if (withModeFocusMeteringActionBuilder != null) {
      proxy.withModeFocusMeteringActionBuilder =
          withModeFocusMeteringActionBuilder;
    }
    if (newDisplayOrientedMeteringPointFactory != null) {
      proxy.newDisplayOrientedMeteringPointFactory =
          newDisplayOrientedMeteringPointFactory;
    }
    proxy.fromCamera2CameraControl =
        ({
          required CameraControl cameraControl,
          // ignore: non_constant_identifier_names
          BinaryMessenger? pigeon_binaryMessenger,
          // ignore: non_constant_identifier_names
          PigeonInstanceManager? pigeon_instanceManager,
        }) => cameraControl == cameraControlForComparison
        ? camera2cameraControl
        : Camera2CameraControl.pigeon_detached(
            pigeon_instanceManager: testInstanceManager,
          );
    proxy.newCaptureRequestOptions =
        ({
          required Map<CaptureRequestKey, Object?> options,
          // ignore: non_constant_identifier_names
          BinaryMessenger? pigeon_binaryMessenger,
          // ignore: non_constant_identifier_names
          PigeonInstanceManager? pigeon_instanceManager,
        }) {
          final MockCaptureRequestOptions mockCaptureRequestOptions =
              MockCaptureRequestOptions();
          options.forEach((CaptureRequestKey key, Object? value) {
            when(
              mockCaptureRequestOptions.getCaptureRequestOption(key),
            ).thenAnswer((_) async => value);
          });
          return mockCaptureRequestOptions;
        };
    final CaptureRequestKey controlAeLock = CaptureRequestKey.pigeon_detached(
      pigeon_instanceManager: testInstanceManager,
    );
    proxy.controlAELockCaptureRequest = () => controlAeLock;

    return proxy;
  }

  test(
    'Should fetch CameraDescription instances for available cameras',
    () async {
      // Arrange
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      final List<dynamic> returnData = <dynamic>[
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
      final MockProcessCameraProvider mockProcessCameraProvider =
          MockProcessCameraProvider();
      final MockCameraSelector mockFrontCameraSelector = MockCameraSelector();
      final MockCameraSelector mockBackCameraSelector = MockCameraSelector();
      final MockCameraInfo mockFrontCameraInfo = MockCameraInfo();
      final MockCameraInfo mockBackCameraInfo = MockCameraInfo();

      // Tell plugin to create mock CameraSelectors for testing.
      camera.proxy = CameraXProxy(
        setUpGenericsProxy:
            ({
              BinaryMessenger? pigeonBinaryMessenger,
              PigeonInstanceManager? pigeonInstanceManager,
            }) {},
        getInstanceProcessCameraProvider:
            ({
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) =>
                Future<ProcessCameraProvider>.value(mockProcessCameraProvider),
        newCameraSelector:
            ({
              LensFacing? requireLensFacing,
              CameraInfo? cameraInfoForFilter,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              switch (requireLensFacing) {
                case LensFacing.front:
                  return mockFrontCameraSelector;
                case LensFacing.back:
                case LensFacing.external:
                case LensFacing.unknown:
                case null:
              }

              return mockBackCameraSelector;
            },
        newSystemServicesManager:
            ({
              required void Function(SystemServicesManager, String)
              onCameraError,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockSystemServicesManager();
            },
      );

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
    },
  );

  test(
    'createCamera requests permissions, starts listening for device orientation changes, updates camera state observers, and returns flutter surface texture ID',
    () async {
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const CameraLensDirection testLensDirection = CameraLensDirection.back;
      const int testSensorOrientation = 90;
      const CameraDescription testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation,
      );

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
      final MockSystemServicesManager mockSystemServicesManager =
          MockSystemServicesManager();
      final MockCameraCharacteristicsKey mockCameraCharacteristicsKey =
          MockCameraCharacteristicsKey();

      bool cameraPermissionsRequested = false;
      bool startedListeningForDeviceOrientationChanges = false;

      camera.proxy = CameraXProxy(
        getInstanceProcessCameraProvider:
            ({
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) async {
              return mockProcessCameraProvider;
            },
        newCameraSelector:
            ({
              LensFacing? requireLensFacing,
              CameraInfo? cameraInfoForFilter,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              switch (requireLensFacing) {
                case LensFacing.front:
                  return MockCameraSelector();
                case LensFacing.back:
                case LensFacing.external:
                case LensFacing.unknown:
                case null:
              }

              return mockBackCameraSelector;
            },
        newPreview:
            ({
              int? targetRotation,
              ResolutionSelector? resolutionSelector,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return mockPreview;
            },
        newImageCapture:
            ({
              int? targetRotation,
              CameraXFlashMode? flashMode,
              ResolutionSelector? resolutionSelector,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return mockImageCapture;
            },
        newRecorder:
            ({
              int? aspectRatio,
              int? targetVideoEncodingBitRate,
              QualitySelector? qualitySelector,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return mockRecorder;
            },
        withOutputVideoCapture:
            ({
              required VideoOutput videoOutput,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return mockVideoCapture;
            },
        newImageAnalysis:
            ({
              int? targetRotation,
              ResolutionSelector? resolutionSelector,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return mockImageAnalysis;
            },
        newResolutionStrategy:
            ({
              required CameraSize boundSize,
              required ResolutionStrategyFallbackRule fallbackRule,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockResolutionStrategy();
            },
        newResolutionSelector:
            ({
              AspectRatioStrategy? aspectRatioStrategy,
              ResolutionStrategy? resolutionStrategy,
              ResolutionFilter? resolutionFilter,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockResolutionSelector();
            },
        fromQualitySelector:
            ({
              required VideoQuality quality,
              FallbackStrategy? fallbackStrategy,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockQualitySelector();
            },
        newObserver:
            <T>({
              required void Function(Observer<T>, T) onChanged,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return Observer<T>.detached(
                onChanged: onChanged,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
        newSystemServicesManager:
            ({
              required void Function(SystemServicesManager, String)
              onCameraError,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              when(
                mockSystemServicesManager.requestCameraPermissions(any),
              ).thenAnswer((_) async {
                cameraPermissionsRequested = true;
                return null;
              });
              return mockSystemServicesManager;
            },
        newDeviceOrientationManager:
            ({
              required void Function(DeviceOrientationManager, String)
              onDeviceOrientationChanged,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              final MockDeviceOrientationManager manager =
                  MockDeviceOrientationManager();
              when(
                manager.startListeningForDeviceOrientationChange(),
              ).thenAnswer((_) async {
                startedListeningForDeviceOrientationChanges = true;
              });
              when(manager.getUiOrientation()).thenAnswer((_) async {
                return 'PORTRAIT_UP';
              });
              return manager;
            },
        newAspectRatioStrategy:
            ({
              required AspectRatio preferredAspectRatio,
              required AspectRatioStrategyFallbackRule fallbackRule,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockAspectRatioStrategy();
            },
        createWithOnePreferredSizeResolutionFilter:
            ({
              required CameraSize preferredSize,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockResolutionFilter();
            },
        fromCamera2CameraInfo:
            ({
              required CameraInfo cameraInfo,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              final MockCamera2CameraInfo camera2cameraInfo =
                  MockCamera2CameraInfo();
              when(
                camera2cameraInfo.getCameraCharacteristic(
                  mockCameraCharacteristicsKey,
                ),
              ).thenAnswer((_) async => testSensorOrientation);
              return camera2cameraInfo;
            },
        newCameraSize:
            ({
              required int width,
              required int height,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockCameraSize();
            },
        sensorOrientationCameraCharacteristics: () {
          return mockCameraCharacteristicsKey;
        },
        lowerQualityOrHigherThanFallbackStrategy:
            ({
              required VideoQuality quality,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockFallbackStrategy();
            },
      );

      camera.processCameraProvider = mockProcessCameraProvider;

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
    },
  );

  test(
    'createCamera binds Preview and ImageCapture use cases to ProcessCameraProvider instance',
    () async {
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const CameraLensDirection testLensDirection = CameraLensDirection.back;
      const int testSensorOrientation = 90;
      const CameraDescription testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation,
      );
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
      final MockCamera2CameraInfo mockCamera2CameraInfo =
          MockCamera2CameraInfo();
      final MockCameraCharacteristicsKey mockCameraCharacteristicsKey =
          MockCameraCharacteristicsKey();

      // Tell plugin to create mock/detached objects and stub method calls for the
      // testing of createCamera.
      camera.proxy = CameraXProxy(
        getInstanceProcessCameraProvider:
            ({
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) async {
              return mockProcessCameraProvider;
            },
        newCameraSelector:
            ({
              LensFacing? requireLensFacing,
              CameraInfo? cameraInfoForFilter,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              switch (requireLensFacing) {
                case LensFacing.front:
                  return MockCameraSelector();
                case LensFacing.back:
                case LensFacing.external:
                case LensFacing.unknown:
                case null:
              }

              return mockBackCameraSelector;
            },
        newPreview:
            ({
              int? targetRotation,
              ResolutionSelector? resolutionSelector,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return mockPreview;
            },
        newImageCapture:
            ({
              int? targetRotation,
              CameraXFlashMode? flashMode,
              ResolutionSelector? resolutionSelector,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return mockImageCapture;
            },
        newRecorder:
            ({
              int? aspectRatio,
              int? targetVideoEncodingBitRate,
              QualitySelector? qualitySelector,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return mockRecorder;
            },
        withOutputVideoCapture:
            ({
              required VideoOutput videoOutput,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return mockVideoCapture;
            },
        newImageAnalysis:
            ({
              int? targetRotation,
              ResolutionSelector? resolutionSelector,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return mockImageAnalysis;
            },
        newResolutionStrategy:
            ({
              required CameraSize boundSize,
              required ResolutionStrategyFallbackRule fallbackRule,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockResolutionStrategy();
            },
        newResolutionSelector:
            ({
              AspectRatioStrategy? aspectRatioStrategy,
              ResolutionStrategy? resolutionStrategy,
              ResolutionFilter? resolutionFilter,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockResolutionSelector();
            },
        fromQualitySelector:
            ({
              required VideoQuality quality,
              FallbackStrategy? fallbackStrategy,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockQualitySelector();
            },
        newObserver:
            <T>({
              required void Function(Observer<T>, T) onChanged,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return Observer<T>.detached(
                onChanged: onChanged,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
        newSystemServicesManager:
            ({
              required void Function(SystemServicesManager, String)
              onCameraError,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockSystemServicesManager();
            },
        newDeviceOrientationManager:
            ({
              required void Function(DeviceOrientationManager, String)
              onDeviceOrientationChanged,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              final MockDeviceOrientationManager manager =
                  MockDeviceOrientationManager();
              when(manager.getUiOrientation()).thenAnswer((_) async {
                return 'PORTRAIT_UP';
              });
              return manager;
            },
        newAspectRatioStrategy:
            ({
              required AspectRatio preferredAspectRatio,
              required AspectRatioStrategyFallbackRule fallbackRule,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockAspectRatioStrategy();
            },
        createWithOnePreferredSizeResolutionFilter:
            ({
              required CameraSize preferredSize,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockResolutionFilter();
            },
        fromCamera2CameraInfo:
            ({
              required CameraInfo cameraInfo,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              when(
                mockCamera2CameraInfo.getCameraCharacteristic(
                  mockCameraCharacteristicsKey,
                ),
              ).thenAnswer((_) async => testSensorOrientation);
              return mockCamera2CameraInfo;
            },
        newCameraSize:
            ({
              required int width,
              required int height,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockCameraSize();
            },
        sensorOrientationCameraCharacteristics: () {
          return mockCameraCharacteristicsKey;
        },
        lowerQualityOrHigherThanFallbackStrategy:
            ({
              required VideoQuality quality,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockFallbackStrategy();
            },
      );

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

      await camera.createCameraWithSettings(
        testCameraDescription,
        const MediaSettings(
          resolutionPreset: testResolutionPreset,
          fps: 15,
          videoBitrate: 2000000,
          audioBitrate: 64000,
          enableAudio: enableAudio,
        ),
      );

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
    'createCamera properly sets preset resolution selection strategy for non-video capture use cases',
    () async {
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const CameraLensDirection testLensDirection = CameraLensDirection.back;
      const int testSensorOrientation = 90;
      const CameraDescription testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation,
      );
      const bool enableAudio = true;
      final MockCamera mockCamera = MockCamera();

      // Mock/Detached objects for (typically attached) objects created by
      // createCamera.
      final MockProcessCameraProvider mockProcessCameraProvider =
          MockProcessCameraProvider();
      final MockCameraInfo mockCameraInfo = MockCameraInfo();

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
      camera.proxy = getProxyForTestingResolutionPreset(
        mockProcessCameraProvider,
      );

      // Test non-null resolution presets.
      for (final ResolutionPreset resolutionPreset in ResolutionPreset.values) {
        await camera.createCamera(
          testCameraDescription,
          resolutionPreset,
          enableAudio: enableAudio,
        );

        late final CameraSize? expectedBoundSize;
        final PigeonInstanceManager testInstanceManager = PigeonInstanceManager(
          onWeakReferenceRemoved: (_) {},
        );
        switch (resolutionPreset) {
          case ResolutionPreset.low:
            expectedBoundSize = CameraSize.pigeon_detached(
              width: 320,
              height: 240,
              pigeon_instanceManager: testInstanceManager,
            );
          case ResolutionPreset.medium:
            expectedBoundSize = CameraSize.pigeon_detached(
              width: 720,
              height: 480,
              pigeon_instanceManager: testInstanceManager,
            );
          case ResolutionPreset.high:
            expectedBoundSize = CameraSize.pigeon_detached(
              width: 1280,
              height: 720,
              pigeon_instanceManager: testInstanceManager,
            );
          case ResolutionPreset.veryHigh:
            expectedBoundSize = CameraSize.pigeon_detached(
              width: 1920,
              height: 1080,
              pigeon_instanceManager: testInstanceManager,
            );
          case ResolutionPreset.ultraHigh:
            expectedBoundSize = CameraSize.pigeon_detached(
              width: 3840,
              height: 2160,
              pigeon_instanceManager: testInstanceManager,
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
        equals(camera.proxy.highestAvailableStrategyResolutionStrategy()),
      );
      expect(
        camera.imageCapture!.resolutionSelector!.resolutionStrategy,
        equals(camera.proxy.highestAvailableStrategyResolutionStrategy()),
      );
      expect(
        camera.imageAnalysis!.resolutionSelector!.resolutionStrategy,
        equals(camera.proxy.highestAvailableStrategyResolutionStrategy()),
      );

      // Test null case.
      await camera.createCamera(testCameraDescription, null);
      expect(camera.preview!.resolutionSelector, isNull);
      expect(camera.imageCapture!.resolutionSelector, isNull);
      expect(camera.imageAnalysis!.resolutionSelector, isNull);
    },
  );

  test(
    'createCamera properly sets filter for resolution preset for non-video capture use cases',
    () async {
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const CameraLensDirection testLensDirection = CameraLensDirection.front;
      const int testSensorOrientation = 180;
      const CameraDescription testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation,
      );
      const bool enableAudio = true;
      final MockCamera mockCamera = MockCamera();

      // Mock/Detached objects for (typically attached) objects created by
      // createCamera.
      final MockProcessCameraProvider mockProcessCameraProvider =
          MockProcessCameraProvider();
      final MockCameraInfo mockCameraInfo = MockCameraInfo();

      // Tell plugin to create mock/detached objects for testing createCamera
      // as needed.
      CameraSize? lastSetPreferredSize;
      camera.proxy = getProxyForTestingResolutionPreset(
        mockProcessCameraProvider,
        createWithOnePreferredSizeResolutionFilter:
            ({
              required CameraSize preferredSize,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
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
        await camera.createCamera(
          testCameraDescription,
          resolutionPreset,
          enableAudio: enableAudio,
        );

        CameraSize? expectedPreferredResolution;
        final PigeonInstanceManager testInstanceManager = PigeonInstanceManager(
          onWeakReferenceRemoved: (_) {},
        );
        switch (resolutionPreset) {
          case ResolutionPreset.low:
            expectedPreferredResolution = CameraSize.pigeon_detached(
              width: 320,
              height: 240,
              pigeon_instanceManager: testInstanceManager,
            );
          case ResolutionPreset.medium:
            expectedPreferredResolution = CameraSize.pigeon_detached(
              width: 720,
              height: 480,
              pigeon_instanceManager: testInstanceManager,
            );
          case ResolutionPreset.high:
            expectedPreferredResolution = CameraSize.pigeon_detached(
              width: 1280,
              height: 720,
              pigeon_instanceManager: testInstanceManager,
            );
          case ResolutionPreset.veryHigh:
            expectedPreferredResolution = CameraSize.pigeon_detached(
              width: 1920,
              height: 1080,
              pigeon_instanceManager: testInstanceManager,
            );
          case ResolutionPreset.ultraHigh:
            expectedPreferredResolution = CameraSize.pigeon_detached(
              width: 3840,
              height: 2160,
              pigeon_instanceManager: testInstanceManager,
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
      await camera.createCamera(testCameraDescription, null);
      expect(camera.preview!.resolutionSelector, isNull);
      expect(camera.imageCapture!.resolutionSelector, isNull);
      expect(camera.imageAnalysis!.resolutionSelector, isNull);
    },
  );

  test(
    'createCamera properly sets aspect ratio based on preset resolution for non-video capture use cases',
    () async {
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const CameraLensDirection testLensDirection = CameraLensDirection.back;
      const int testSensorOrientation = 90;
      const CameraDescription testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation,
      );
      const bool enableAudio = true;
      final MockCamera mockCamera = MockCamera();

      // Mock/Detached objects for (typically attached) objects created by
      // createCamera.
      final MockProcessCameraProvider mockProcessCameraProvider =
          MockProcessCameraProvider();
      final MockCameraInfo mockCameraInfo = MockCameraInfo();

      // Tell plugin to create mock/detached objects for testing createCamera
      // as needed.
      camera.proxy = getProxyForTestingResolutionPreset(
        mockProcessCameraProvider,
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
        await camera.createCamera(
          testCameraDescription,
          resolutionPreset,
          enableAudio: enableAudio,
        );

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
            equals(
              camera.proxy.ratio_4_3FallbackAutoStrategyAspectRatioStrategy(),
            ),
          );
          expect(
            await camera.imageCapture!.resolutionSelector!
                .getAspectRatioStrategy(),
            equals(
              camera.proxy.ratio_4_3FallbackAutoStrategyAspectRatioStrategy(),
            ),
          );
          expect(
            await camera.imageAnalysis!.resolutionSelector!
                .getAspectRatioStrategy(),
            equals(
              camera.proxy.ratio_4_3FallbackAutoStrategyAspectRatioStrategy(),
            ),
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
      expect(camera.preview!.resolutionSelector, isNull);
      expect(camera.imageCapture!.resolutionSelector, isNull);
      expect(camera.imageAnalysis!.resolutionSelector, isNull);
    },
  );

  test(
    'createCamera properly sets preset resolution for video capture use case',
    () async {
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const CameraLensDirection testLensDirection = CameraLensDirection.back;
      const int testSensorOrientation = 90;
      const CameraDescription testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation,
      );
      const bool enableAudio = true;
      final MockCamera mockCamera = MockCamera();

      // Mock/Detached objects for (typically attached) objects created by
      // createCamera.
      final MockProcessCameraProvider mockProcessCameraProvider =
          MockProcessCameraProvider();
      final MockCameraInfo mockCameraInfo = MockCameraInfo();

      // Tell plugin to create mock/detached objects for testing createCamera
      // as needed.
      VideoQuality? fallbackStrategyVideoQuality;
      VideoQuality? qualitySelectorVideoQuality;
      FallbackStrategy? setFallbackStrategy;
      final MockFallbackStrategy mockFallbackStrategy = MockFallbackStrategy();
      final MockQualitySelector mockQualitySelector = MockQualitySelector();
      camera.proxy = getProxyForTestingResolutionPreset(
        mockProcessCameraProvider,
        lowerQualityOrHigherThanFallbackStrategy:
            ({
              required VideoQuality quality,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              fallbackStrategyVideoQuality = quality;
              return mockFallbackStrategy;
            },
        fromQualitySelector:
            ({
              required VideoQuality quality,
              FallbackStrategy? fallbackStrategy,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const CameraLensDirection testLensDirection = CameraLensDirection.back;
      const int testSensorOrientation = 90;
      const CameraDescription testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation,
      );
      const bool enableAudio = true;
      const ResolutionPreset testResolutionPreset = ResolutionPreset.veryHigh;
      const bool testHandlesCropAndRotation = true;

      // Mock/Detached objects for (typically attached) objects created by
      // createCamera.
      final MockCamera mockCamera = MockCamera();
      final MockProcessCameraProvider mockProcessCameraProvider =
          MockProcessCameraProvider();
      final MockCameraInfo mockCameraInfo = MockCameraInfo();

      // The proxy needed for this test is the same as testing resolution
      // presets except for mocking the retrieval of the sensor and current
      // UI orientation.
      camera.proxy = getProxyForTestingResolutionPreset(
        mockProcessCameraProvider,
        newPreview:
            ({
              int? targetRotation,
              ResolutionSelector? resolutionSelector,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              final MockPreview mockPreview = MockPreview();
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
    'createCamera properly selects specific back camera by specifying a CameraInfo',
    () async {
      // Arrange
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      final List<dynamic> returnData = <dynamic>[
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

      List<MockCameraInfo> mockCameraInfosList = <MockCameraInfo>[];
      final Map<String, MockCameraInfo?> cameraNameToInfos =
          <String, MockCameraInfo?>{};

      const int testSensorOrientation = 0;

      // Mocks for objects created by availableCameras.
      final MockProcessCameraProvider mockProcessCameraProvider =
          MockProcessCameraProvider();
      final MockCameraSelector mockFrontCameraSelector = MockCameraSelector();
      final MockCameraSelector mockBackCameraSelector = MockCameraSelector();
      final MockCameraSelector mockChosenCameraInfoCameraSelector =
          MockCameraSelector();

      final MockCameraInfo mockFrontCameraInfo = MockCameraInfo();
      final MockCameraInfo mockBackCameraInfoOne = MockCameraInfo();
      final MockCameraInfo mockBackCameraInfoTwo = MockCameraInfo();

      // Mock/Detached objects for (typically attached) objects created by
      // createCamera.
      final MockPreview mockPreview = MockPreview();
      final MockImageCapture mockImageCapture = MockImageCapture();
      final MockImageAnalysis mockImageAnalysis = MockImageAnalysis();
      final MockRecorder mockRecorder = MockRecorder();
      final MockVideoCapture mockVideoCapture = MockVideoCapture();
      final MockCamera mockCamera = MockCamera();
      final MockCameraInfo mockCameraInfo = MockCameraInfo();
      final MockCameraControl mockCameraControl = MockCameraControl();
      final MockCamera2CameraInfo mockCamera2CameraInfo =
          MockCamera2CameraInfo();
      final MockCameraCharacteristicsKey mockCameraCharacteristicsKey =
          MockCameraCharacteristicsKey();

      // Tell plugin to create mock/detached objects and stub method calls for the
      // testing of availableCameras and createCamera.
      camera.proxy = CameraXProxy(
        setUpGenericsProxy:
            ({
              BinaryMessenger? pigeonBinaryMessenger,
              PigeonInstanceManager? pigeonInstanceManager,
            }) {},
        getInstanceProcessCameraProvider:
            ({
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return Future<ProcessCameraProvider>.value(
                mockProcessCameraProvider,
              );
            },
        newCameraSelector:
            ({
              LensFacing? requireLensFacing,
              CameraInfo? cameraInfoForFilter,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
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
            },
        newSystemServicesManager:
            ({
              required void Function(SystemServicesManager, String)
              onCameraError,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockSystemServicesManager();
            },
        newPreview:
            ({
              int? targetRotation,
              ResolutionSelector? resolutionSelector,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return mockPreview;
            },
        newImageCapture:
            ({
              int? targetRotation,
              CameraXFlashMode? flashMode,
              ResolutionSelector? resolutionSelector,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return mockImageCapture;
            },
        newRecorder:
            ({
              int? aspectRatio,
              int? targetVideoEncodingBitRate,
              QualitySelector? qualitySelector,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return mockRecorder;
            },
        withOutputVideoCapture:
            ({
              required VideoOutput videoOutput,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return mockVideoCapture;
            },
        newImageAnalysis:
            ({
              int? targetRotation,
              ResolutionSelector? resolutionSelector,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return mockImageAnalysis;
            },
        newResolutionStrategy:
            ({
              required CameraSize boundSize,
              required ResolutionStrategyFallbackRule fallbackRule,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockResolutionStrategy();
            },
        newResolutionSelector:
            ({
              AspectRatioStrategy? aspectRatioStrategy,
              ResolutionStrategy? resolutionStrategy,
              ResolutionFilter? resolutionFilter,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockResolutionSelector();
            },
        fromQualitySelector:
            ({
              required VideoQuality quality,
              FallbackStrategy? fallbackStrategy,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockQualitySelector();
            },
        newObserver:
            <T>({
              required void Function(Observer<T>, T) onChanged,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return Observer<T>.detached(
                onChanged: onChanged,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
        newDeviceOrientationManager:
            ({
              required void Function(DeviceOrientationManager, String)
              onDeviceOrientationChanged,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              final MockDeviceOrientationManager manager =
                  MockDeviceOrientationManager();
              when(manager.getUiOrientation()).thenAnswer((_) async {
                return 'PORTRAIT_UP';
              });
              return manager;
            },
        newAspectRatioStrategy:
            ({
              required AspectRatio preferredAspectRatio,
              required AspectRatioStrategyFallbackRule fallbackRule,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockAspectRatioStrategy();
            },
        createWithOnePreferredSizeResolutionFilter:
            ({
              required CameraSize preferredSize,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockResolutionFilter();
            },
        fromCamera2CameraInfo:
            ({
              required CameraInfo cameraInfo,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              when(
                mockCamera2CameraInfo.getCameraCharacteristic(
                  mockCameraCharacteristicsKey,
                ),
              ).thenAnswer((_) async => testSensorOrientation);
              return mockCamera2CameraInfo;
            },
        newCameraSize:
            ({
              required int width,
              required int height,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockCameraSize();
            },
        sensorOrientationCameraCharacteristics: () {
          return mockCameraCharacteristicsKey;
        },
        lowerQualityOrHigherThanFallbackStrategy:
            ({
              required VideoQuality quality,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return MockFallbackStrategy();
            },
      );

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

      for (int i = 0; i < returnData.length; i++) {
        final Map<String, Object?> savedData =
            (returnData[i] as Map<dynamic, dynamic>).cast<String, Object?>();

        cameraNameToInfos[savedData['name']! as String] =
            mockCameraInfosList[i];
        final CameraDescription cameraDescription = CameraDescription(
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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      await expectLater(() async {
        await camera.initializeCamera(3);
      }, throwsA(isA<CameraException>()));
    },
  );

  test('initializeCamera sends expected CameraInitializedEvent', () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();

    const int cameraId = 10;
    const CameraLensDirection testLensDirection = CameraLensDirection.back;
    const int testSensorOrientation = 90;
    const CameraDescription testCameraDescription = CameraDescription(
      name: 'cameraName',
      lensDirection: testLensDirection,
      sensorOrientation: testSensorOrientation,
    );
    const int resolutionWidth = 350;
    const int resolutionHeight = 750;
    final Camera mockCamera = MockCamera();
    final PigeonInstanceManager testInstanceManager = PigeonInstanceManager(
      onWeakReferenceRemoved: (_) {},
    );
    final ResolutionInfo testResolutionInfo = ResolutionInfo.pigeon_detached(
      resolution: CameraSize.pigeon_detached(
        width: resolutionWidth,
        height: resolutionHeight,
        pigeon_instanceManager: testInstanceManager,
      ),
      pigeon_instanceManager: testInstanceManager,
    );

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
      getInstanceProcessCameraProvider:
          ({
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) => Future<ProcessCameraProvider>.value(mockProcessCameraProvider),
      newCameraSelector:
          ({
            LensFacing? requireLensFacing,
            CameraInfo? cameraInfoForFilter,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) {
            switch (requireLensFacing) {
              case LensFacing.front:
                return mockFrontCameraSelector;
              case _:
                return mockBackCameraSelector;
            }
          },
      newPreview:
          ({
            int? targetRotation,
            ResolutionSelector? resolutionSelector,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) => mockPreview,
      newImageCapture:
          ({
            int? targetRotation,
            CameraXFlashMode? flashMode,
            ResolutionSelector? resolutionSelector,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) => mockImageCapture,
      newRecorder:
          ({
            int? aspectRatio,
            int? targetVideoEncodingBitRate,
            QualitySelector? qualitySelector,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) => MockRecorder(),
      withOutputVideoCapture:
          ({
            required VideoOutput videoOutput,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) => MockVideoCapture(),
      newImageAnalysis:
          ({
            int? targetRotation,
            ResolutionSelector? resolutionSelector,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) => mockImageAnalysis,
      newResolutionStrategy:
          ({
            required CameraSize boundSize,
            required ResolutionStrategyFallbackRule fallbackRule,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) => MockResolutionStrategy(),
      newResolutionSelector:
          ({
            AspectRatioStrategy? aspectRatioStrategy,
            ResolutionStrategy? resolutionStrategy,
            ResolutionFilter? resolutionFilter,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) => MockResolutionSelector(),
      lowerQualityOrHigherThanFallbackStrategy:
          ({
            required VideoQuality quality,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) => MockFallbackStrategy(),
      fromQualitySelector:
          ({
            required VideoQuality quality,
            FallbackStrategy? fallbackStrategy,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) => MockQualitySelector(),
      newObserver:
          <T>({
            required void Function(Observer<T>, T) onChanged,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) {
            return Observer<T>.detached(
              onChanged: onChanged,
              pigeon_instanceManager: PigeonInstanceManager(
                onWeakReferenceRemoved: (_) {},
              ),
            );
          },
      newSystemServicesManager:
          ({
            required void Function(SystemServicesManager, String) onCameraError,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) => MockSystemServicesManager(),
      newDeviceOrientationManager:
          ({
            required void Function(DeviceOrientationManager, String)
            onDeviceOrientationChanged,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) {
            final MockDeviceOrientationManager manager =
                MockDeviceOrientationManager();
            when(manager.getUiOrientation()).thenAnswer((_) async {
              return 'PORTRAIT_UP';
            });
            return manager;
          },
      newAspectRatioStrategy:
          ({
            required AspectRatio preferredAspectRatio,
            required AspectRatioStrategyFallbackRule fallbackRule,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) => MockAspectRatioStrategy(),
      createWithOnePreferredSizeResolutionFilter:
          ({
            required CameraSize preferredSize,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) => MockResolutionFilter(),
      fromCamera2CameraInfo:
          ({
            required CameraInfo cameraInfo,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) {
            final MockCamera2CameraInfo mockCamera2CameraInfo =
                MockCamera2CameraInfo();
            when(
              mockCamera2CameraInfo.getCameraCharacteristic(any),
            ).thenAnswer((_) async => 90);
            return mockCamera2CameraInfo;
          },
      newCameraSize:
          ({
            required int width,
            required int height,
            // ignore: non_constant_identifier_names
            BinaryMessenger? pigeon_binaryMessenger,
            // ignore: non_constant_identifier_names
            PigeonInstanceManager? pigeon_instanceManager,
          }) => MockCameraSize(),
      sensorOrientationCameraCharacteristics: () =>
          MockCameraCharacteristicsKey(),
    );

    final CameraInitializedEvent testCameraInitializedEvent =
        CameraInitializedEvent(
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
      bool stoppedListeningForDeviceOrientationChange = false;
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      camera.proxy = CameraXProxy(
        newDeviceOrientationManager:
            ({
              required void Function(DeviceOrientationManager, String)
              onDeviceOrientationChanged,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              final MockDeviceOrientationManager mockDeviceOrientationManager =
                  MockDeviceOrientationManager();
              when(
                mockDeviceOrientationManager
                    .stopListeningForDeviceOrientationChange(),
              ).thenAnswer((_) async {
                stoppedListeningForDeviceOrientationChange = true;
              });
              return mockDeviceOrientationManager;
            },
      );

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
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 16;
    final Stream<CameraInitializedEvent> eventStream = camera
        .onCameraInitialized(cameraId);
    final StreamQueue<CameraInitializedEvent> streamQueue =
        StreamQueue<CameraInitializedEvent>(eventStream);
    const CameraInitializedEvent testEvent = CameraInitializedEvent(
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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const int cameraId = 99;
      const CameraClosingEvent cameraClosingEvent = CameraClosingEvent(
        cameraId,
      );
      final Stream<CameraClosingEvent> eventStream = camera.onCameraClosing(
        cameraId,
      );
      final StreamQueue<CameraClosingEvent> streamQueue =
          StreamQueue<CameraClosingEvent>(eventStream);

      camera.cameraEventStreamController.add(cameraClosingEvent);

      expect(await streamQueue.next, equals(cameraClosingEvent));
      await streamQueue.cancel();
    },
  );

  test(
    'onCameraError stream emits errors caught by system services or added to stream within plugin',
    () async {
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const int cameraId = 27;
      const String firstTestErrorDescription = 'Test error description 1!';
      const String secondTestErrorDescription = 'Test error description 2!';
      const CameraErrorEvent secondCameraErrorEvent = CameraErrorEvent(
        cameraId,
        secondTestErrorDescription,
      );
      final Stream<CameraErrorEvent> eventStream = camera.onCameraError(
        cameraId,
      );
      final StreamQueue<CameraErrorEvent> streamQueue =
          StreamQueue<CameraErrorEvent>(eventStream);

      camera.proxy = CameraXProxy(
        newSystemServicesManager:
            ({
              required void Function(SystemServicesManager, String)
              onCameraError,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              final MockSystemServicesManager mockSystemServicesManager =
                  MockSystemServicesManager();
              when(
                mockSystemServicesManager.onCameraError,
              ).thenReturn(onCameraError);
              return mockSystemServicesManager;
            },
      );

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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      final Stream<DeviceOrientationChangedEvent> eventStream = camera
          .onDeviceOrientationChanged();
      final StreamQueue<DeviceOrientationChangedEvent> streamQueue =
          StreamQueue<DeviceOrientationChangedEvent>(eventStream);
      const DeviceOrientationChangedEvent testEvent =
          DeviceOrientationChangedEvent(DeviceOrientation.portraitDown);

      camera.proxy = CameraXProxy(
        newDeviceOrientationManager:
            ({
              required void Function(DeviceOrientationManager, String)
              onDeviceOrientationChanged,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              final MockDeviceOrientationManager mockDeviceOrientationManager =
                  MockDeviceOrientationManager();
              when(
                mockDeviceOrientationManager.onDeviceOrientationChanged,
              ).thenReturn(onDeviceOrientationChanged);
              return mockDeviceOrientationManager;
            },
      );

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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();

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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();

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
        newObserver:
            <T>({
              required void Function(Observer<T>, T) onChanged,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return Observer<T>.detached(
                onChanged: onChanged,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
      );

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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const int cameraId = 73;

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
        final AndroidCameraCameraX camera = AndroidCameraCameraX();
        final MockPendingRecording mockPendingRecording =
            MockPendingRecording();
        final MockPendingRecording mockPendingRecordingWithAudio =
            MockPendingRecording();
        final MockRecording mockRecording = MockRecording();
        final MockCamera mockCamera = MockCamera();
        final MockCamera newMockCamera = MockCamera();
        final MockCameraInfo mockCameraInfo = MockCameraInfo();
        final MockCameraControl mockCameraControl = MockCameraControl();
        final MockLiveCameraState mockLiveCameraState = MockLiveCameraState();
        final MockLiveCameraState newMockLiveCameraState =
            MockLiveCameraState();
        final MockCamera2CameraInfo mockCamera2CameraInfo =
            MockCamera2CameraInfo();
        const bool enableAudio = true;

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
        const String outputPath = '/temp/REC123.temp';
        camera.proxy = CameraXProxy(
          newObserver:
              <T>({
                required void Function(Observer<T>, T) onChanged,
                // ignore: non_constant_identifier_names
                BinaryMessenger? pigeon_binaryMessenger,
                // ignore: non_constant_identifier_names
                PigeonInstanceManager? pigeon_instanceManager,
              }) {
                return Observer<T>.detached(
                  onChanged: onChanged,
                  pigeon_instanceManager: PigeonInstanceManager(
                    onWeakReferenceRemoved: (_) {},
                  ),
                );
              },
          fromCamera2CameraInfo:
              ({
                required CameraInfo cameraInfo,
                // ignore: non_constant_identifier_names
                BinaryMessenger? pigeon_binaryMessenger,
                // ignore: non_constant_identifier_names
                PigeonInstanceManager? pigeon_instanceManager,
              }) => mockCamera2CameraInfo,
          newSystemServicesManager:
              ({
                required void Function(SystemServicesManager, String)
                onCameraError,
                // ignore: non_constant_identifier_names
                BinaryMessenger? pigeon_binaryMessenger,
                // ignore: non_constant_identifier_names
                PigeonInstanceManager? pigeon_instanceManager,
              }) {
                final MockSystemServicesManager mockSystemServicesManager =
                    MockSystemServicesManager();
                when(
                  mockSystemServicesManager.getTempFilePath(
                    camera.videoPrefix,
                    '.temp',
                  ),
                ).thenAnswer((_) async => outputPath);
                return mockSystemServicesManager;
              },
          newVideoRecordEventListener:
              ({
                required void Function(
                  VideoRecordEventListener,
                  VideoRecordEvent,
                )
                onEvent,
                // ignore: non_constant_identifier_names
                BinaryMessenger? pigeon_binaryMessenger,
                // ignore: non_constant_identifier_names
                PigeonInstanceManager? pigeon_instanceManager,
              }) {
                return VideoRecordEventListener.pigeon_detached(
                  onEvent: onEvent,
                  pigeon_instanceManager: PigeonInstanceManager(
                    onWeakReferenceRemoved: (_) {},
                  ),
                );
              },
          infoSupportedHardwareLevelCameraCharacteristics: () {
            return MockCameraCharacteristicsKey();
          },
        );

        const int cameraId = 17;

        // Mock method calls.
        when(
          camera.recorder!.prepareRecording(outputPath),
        ).thenAnswer((_) async => mockPendingRecording);
        when(
          mockPendingRecording.withAudioEnabled(!enableAudio),
        ).thenAnswer((_) async => mockPendingRecordingWithAudio);
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
          VideoRecordEventStart.pigeon_detached(
            pigeon_instanceManager: PigeonInstanceManager(
              onWeakReferenceRemoved: (_) {},
            ),
          ),
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
        final AndroidCameraCameraX camera = AndroidCameraCameraX();
        final MockPendingRecording mockPendingRecording =
            MockPendingRecording();
        final MockRecording mockRecording = MockRecording();
        final MockCamera mockCamera = MockCamera();
        final MockCameraInfo mockCameraInfo = MockCameraInfo();
        final MockCamera2CameraInfo mockCamera2CameraInfo =
            MockCamera2CameraInfo();

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
        const String outputPath = '/temp/REC123.temp';
        camera.proxy = CameraXProxy(
          newObserver:
              <T>({
                required void Function(Observer<T>, T) onChanged,
                // ignore: non_constant_identifier_names
                BinaryMessenger? pigeon_binaryMessenger,
                // ignore: non_constant_identifier_names
                PigeonInstanceManager? pigeon_instanceManager,
              }) {
                return Observer<T>.detached(
                  onChanged: onChanged,
                  pigeon_instanceManager: PigeonInstanceManager(
                    onWeakReferenceRemoved: (_) {},
                  ),
                );
              },
          fromCamera2CameraInfo:
              ({
                required CameraInfo cameraInfo,
                // ignore: non_constant_identifier_names
                BinaryMessenger? pigeon_binaryMessenger,
                // ignore: non_constant_identifier_names
                PigeonInstanceManager? pigeon_instanceManager,
              }) => mockCamera2CameraInfo,
          newSystemServicesManager:
              ({
                required void Function(SystemServicesManager, String)
                onCameraError,
                // ignore: non_constant_identifier_names
                BinaryMessenger? pigeon_binaryMessenger,
                // ignore: non_constant_identifier_names
                PigeonInstanceManager? pigeon_instanceManager,
              }) {
                final MockSystemServicesManager mockSystemServicesManager =
                    MockSystemServicesManager();
                when(
                  mockSystemServicesManager.getTempFilePath(
                    camera.videoPrefix,
                    '.temp',
                  ),
                ).thenAnswer((_) async => outputPath);
                return mockSystemServicesManager;
              },
          newVideoRecordEventListener:
              ({
                required void Function(
                  VideoRecordEventListener,
                  VideoRecordEvent,
                )
                onEvent,
                // ignore: non_constant_identifier_names
                BinaryMessenger? pigeon_binaryMessenger,
                // ignore: non_constant_identifier_names
                PigeonInstanceManager? pigeon_instanceManager,
              }) {
                return VideoRecordEventListener.pigeon_detached(
                  onEvent: onEvent,
                  pigeon_instanceManager: PigeonInstanceManager(
                    onWeakReferenceRemoved: (_) {},
                  ),
                );
              },
          infoSupportedHardwareLevelCameraCharacteristics: () {
            return MockCameraCharacteristicsKey();
          },
        );

        const int cameraId = 17;

        // Mock method calls.
        when(
          camera.recorder!.prepareRecording(outputPath),
        ).thenAnswer((_) async => mockPendingRecording);
        when(
          mockPendingRecording.withAudioEnabled(!camera.enableRecordingAudio),
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
          VideoRecordEventStart.pigeon_detached(
            pigeon_instanceManager: PigeonInstanceManager(
              onWeakReferenceRemoved: (_) {},
            ),
          ),
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
            '.temp',
          ),
        ).called(1);
        verifyNoMoreInteractions(camera.systemServicesManager);
        verify(camera.recorder!.prepareRecording(outputPath)).called(1);
        verifyNoMoreInteractions(camera.recorder);
        verify(mockPendingRecording.start(any)).called(1);
        verify(mockPendingRecording.withAudioEnabled(any)).called(1);
        verifyNoMoreInteractions(mockPendingRecording);
      },
    );

    test(
      'startVideoCapturing called with stream options starts image streaming',
      () async {
        // Set up mocks and constants.
        final AndroidCameraCameraX camera = AndroidCameraCameraX();
        final MockProcessCameraProvider mockProcessCameraProvider =
            MockProcessCameraProvider();
        final Recorder mockRecorder = MockRecorder();
        final MockPendingRecording mockPendingRecording =
            MockPendingRecording();
        final MockCameraInfo initialCameraInfo = MockCameraInfo();
        final MockCamera2CameraInfo mockCamera2CameraInfo =
            MockCamera2CameraInfo();

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
        const String outputPath = '/temp/REC123.temp';
        camera.proxy = CameraXProxy(
          newObserver:
              <T>({
                required void Function(Observer<T>, T) onChanged,
                // ignore: non_constant_identifier_names
                BinaryMessenger? pigeon_binaryMessenger,
                // ignore: non_constant_identifier_names
                PigeonInstanceManager? pigeon_instanceManager,
              }) {
                return Observer<T>.detached(
                  onChanged: onChanged,
                  pigeon_instanceManager: PigeonInstanceManager(
                    onWeakReferenceRemoved: (_) {},
                  ),
                );
              },
          fromCamera2CameraInfo:
              ({
                required CameraInfo cameraInfo,
                // ignore: non_constant_identifier_names
                BinaryMessenger? pigeon_binaryMessenger,
                // ignore: non_constant_identifier_names
                PigeonInstanceManager? pigeon_instanceManager,
              }) => mockCamera2CameraInfo,
          newSystemServicesManager:
              ({
                required void Function(SystemServicesManager, String)
                onCameraError,
                // ignore: non_constant_identifier_names
                BinaryMessenger? pigeon_binaryMessenger,
                // ignore: non_constant_identifier_names
                PigeonInstanceManager? pigeon_instanceManager,
              }) {
                final MockSystemServicesManager mockSystemServicesManager =
                    MockSystemServicesManager();
                when(
                  mockSystemServicesManager.getTempFilePath(
                    camera.videoPrefix,
                    '.temp',
                  ),
                ).thenAnswer((_) async => outputPath);
                return mockSystemServicesManager;
              },
          newVideoRecordEventListener:
              ({
                required void Function(
                  VideoRecordEventListener,
                  VideoRecordEvent,
                )
                onEvent,
                // ignore: non_constant_identifier_names
                BinaryMessenger? pigeon_binaryMessenger,
                // ignore: non_constant_identifier_names
                PigeonInstanceManager? pigeon_instanceManager,
              }) {
                return VideoRecordEventListener.pigeon_detached(
                  onEvent: onEvent,
                  pigeon_instanceManager: PigeonInstanceManager(
                    onWeakReferenceRemoved: (_) {},
                  ),
                );
              },
          infoSupportedHardwareLevelCameraCharacteristics: () {
            return MockCameraCharacteristicsKey();
          },
          newAnalyzer:
              ({
                required void Function(Analyzer, ImageProxy) analyze,
                // ignore: non_constant_identifier_names
                BinaryMessenger? pigeon_binaryMessenger,
                // ignore: non_constant_identifier_names
                PigeonInstanceManager? pigeon_instanceManager,
              }) {
                return MockAnalyzer();
              },
        );

        const int cameraId = 17;
        final Completer<CameraImageData> imageDataCompleter =
            Completer<CameraImageData>();
        final VideoCaptureOptions videoCaptureOptions = VideoCaptureOptions(
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
          VideoRecordEventStart.pigeon_detached(
            pigeon_instanceManager: PigeonInstanceManager(
              onWeakReferenceRemoved: (_) {},
            ),
          ),
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
        final AndroidCameraCameraX camera = AndroidCameraCameraX();
        final MockPendingRecording mockPendingRecording =
            MockPendingRecording();
        final MockRecording mockRecording = MockRecording();
        final MockVideoCapture mockVideoCapture = MockVideoCapture();
        final MockCameraInfo initialCameraInfo = MockCameraInfo();
        final MockCamera2CameraInfo mockCamera2CameraInfo =
            MockCamera2CameraInfo();
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
        const String outputPath = '/temp/REC123.temp';
        camera.proxy = CameraXProxy(
          newObserver:
              <T>({
                required void Function(Observer<T>, T) onChanged,
                // ignore: non_constant_identifier_names
                BinaryMessenger? pigeon_binaryMessenger,
                // ignore: non_constant_identifier_names
                PigeonInstanceManager? pigeon_instanceManager,
              }) {
                return Observer<T>.detached(
                  onChanged: onChanged,
                  pigeon_instanceManager: PigeonInstanceManager(
                    onWeakReferenceRemoved: (_) {},
                  ),
                );
              },
          fromCamera2CameraInfo:
              ({
                required CameraInfo cameraInfo,
                // ignore: non_constant_identifier_names
                BinaryMessenger? pigeon_binaryMessenger,
                // ignore: non_constant_identifier_names
                PigeonInstanceManager? pigeon_instanceManager,
              }) => cameraInfo == initialCameraInfo
              ? mockCamera2CameraInfo
              : MockCamera2CameraInfo(),
          newSystemServicesManager:
              ({
                required void Function(SystemServicesManager, String)
                onCameraError,
                // ignore: non_constant_identifier_names
                BinaryMessenger? pigeon_binaryMessenger,
                // ignore: non_constant_identifier_names
                PigeonInstanceManager? pigeon_instanceManager,
              }) {
                final MockSystemServicesManager mockSystemServicesManager =
                    MockSystemServicesManager();
                when(
                  mockSystemServicesManager.getTempFilePath(
                    camera.videoPrefix,
                    '.temp',
                  ),
                ).thenAnswer((_) async => outputPath);
                return mockSystemServicesManager;
              },
          newDeviceOrientationManager:
              ({
                required void Function(DeviceOrientationManager, String)
                onDeviceOrientationChanged,
                // ignore: non_constant_identifier_names
                BinaryMessenger? pigeon_binaryMessenger,
                // ignore: non_constant_identifier_names
                PigeonInstanceManager? pigeon_instanceManager,
              }) {
                final MockDeviceOrientationManager
                mockDeviceOrientationManager = MockDeviceOrientationManager();
                when(
                  mockDeviceOrientationManager.getDefaultDisplayRotation(),
                ).thenAnswer((_) async => defaultTargetRotation);
                return mockDeviceOrientationManager;
              },
          newVideoRecordEventListener:
              ({
                required void Function(
                  VideoRecordEventListener,
                  VideoRecordEvent,
                )
                onEvent,
                // ignore: non_constant_identifier_names
                BinaryMessenger? pigeon_binaryMessenger,
                // ignore: non_constant_identifier_names
                PigeonInstanceManager? pigeon_instanceManager,
              }) {
                return VideoRecordEventListener.pigeon_detached(
                  onEvent: onEvent,
                  pigeon_instanceManager: PigeonInstanceManager(
                    onWeakReferenceRemoved: (_) {},
                  ),
                );
              },
          infoSupportedHardwareLevelCameraCharacteristics: () {
            return MockCameraCharacteristicsKey();
          },
        );

        const int cameraId = 87;

        // Mock method calls.
        when(
          camera.recorder!.prepareRecording(outputPath),
        ).thenAnswer((_) async => mockPendingRecording);
        when(
          mockPendingRecording.withAudioEnabled(!camera.enableRecordingAudio),
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
          VideoRecordEventStart.pigeon_detached(
            pigeon_instanceManager: PigeonInstanceManager(
              onWeakReferenceRemoved: (_) {},
            ),
          ),
        );

        // Orientation is unlocked and plugin does not need to set default target
        // rotation manually.
        camera.recording = null;
        await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));
        verifyNever(mockVideoCapture.setTargetRotation(any));

        // Simulate video recording being started so startVideoRecording completes.
        AndroidCameraCameraX.videoRecordingEventStreamController.add(
          VideoRecordEventStart.pigeon_detached(
            pigeon_instanceManager: PigeonInstanceManager(
              onWeakReferenceRemoved: (_) {},
            ),
          ),
        );

        // Orientation is locked and plugin does not need to set default target
        // rotation manually.
        camera.recording = null;
        camera.captureOrientationLocked = true;
        await camera.startVideoCapturing(const VideoCaptureOptions(cameraId));
        verifyNever(mockVideoCapture.setTargetRotation(any));

        // Simulate video recording being started so startVideoRecording completes.
        AndroidCameraCameraX.videoRecordingEventStreamController.add(
          VideoRecordEventStart.pigeon_detached(
            pigeon_instanceManager: PigeonInstanceManager(
              onWeakReferenceRemoved: (_) {},
            ),
          ),
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
          VideoRecordEventStart.pigeon_detached(
            pigeon_instanceManager: PigeonInstanceManager(
              onWeakReferenceRemoved: (_) {},
            ),
          ),
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
      when(
        camera.processCameraProvider!.isBound(videoCapture),
      ).thenAnswer((_) async => true);

      // Simulate video recording being finalized so stopVideoRecording completes.
      AndroidCameraCameraX.videoRecordingEventStreamController.add(
        VideoRecordEventFinalize.pigeon_detached(
          pigeon_instanceManager: PigeonInstanceManager(
            onWeakReferenceRemoved: (_) {},
          ),
        ),
      );

      final XFile file = await camera.stopVideoRecording(0);
      expect(file.path, videoOutputPath);

      // Verify that recording stops.
      verify(recording.close());
      verifyNoMoreInteractions(recording);
    });

    test('stopVideoRecording throws a camera exception if '
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

    test('stopVideoRecording throws a camera exception if '
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
      when(
        camera.processCameraProvider!.isBound(mockVideoCapture),
      ).thenAnswer((_) async => true);

      await expectLater(() async {
        // Simulate video recording being finalized so stopVideoRecording completes.
        AndroidCameraCameraX.videoRecordingEventStreamController.add(
          VideoRecordEventFinalize.pigeon_detached(
            pigeon_instanceManager: PigeonInstanceManager(
              onWeakReferenceRemoved: (_) {},
            ),
          ),
        );
        await camera.stopVideoRecording(0);
      }, throwsA(isA<CameraException>()));
      expect(camera.recording, null);
    });

    test('calling stopVideoRecording twice stops the recording '
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
      AndroidCameraCameraX.videoRecordingEventStreamController.add(
        VideoRecordEventFinalize.pigeon_detached(
          pigeon_instanceManager: PigeonInstanceManager(
            onWeakReferenceRemoved: (_) {},
          ),
        ),
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
        when(
          camera.processCameraProvider!.isBound(videoCapture),
        ).thenAnswer((_) async => true);

        // Simulate video recording being finalized so stopVideoRecording completes.
        AndroidCameraCameraX.videoRecordingEventStreamController.add(
          VideoRecordEventFinalize.pigeon_detached(
            pigeon_instanceManager: PigeonInstanceManager(
              onWeakReferenceRemoved: (_) {},
            ),
          ),
        );

        await camera.stopVideoRecording(90);
        verify(processCameraProvider.unbind(<UseCase>[videoCapture]));

        // Verify that recording stops.
        verify(recording.close());
        verifyNoMoreInteractions(recording);
      },
    );

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

        await camera.setDescriptionWhileRecording(
          const CameraDescription(
            name: 'fakeCameraName',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 90,
          ),
        );
        verifyNoMoreInteractions(camera.processCameraProvider);
        verifyNoMoreInteractions(camera.recorder);
        verifyNoMoreInteractions(camera.videoCapture);
        verifyNoMoreInteractions(camera.camera);
      },
    );
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
        newObserver:
            <T>({
              required void Function(Observer<T>, T) onChanged,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return Observer<T>.detached(
                onChanged: onChanged,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
      );

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
        newDeviceOrientationManager:
            ({
              required void Function(DeviceOrientationManager, String)
              onDeviceOrientationChanged,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              final MockDeviceOrientationManager mockDeviceOrientationManager =
                  MockDeviceOrientationManager();
              when(
                mockDeviceOrientationManager.getDefaultDisplayRotation(),
              ).thenAnswer((_) async => defaultTargetRotation);
              return mockDeviceOrientationManager;
            },
      );

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
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 44;
    final MockCameraControl mockCameraControl = MockCameraControl();

    // Set directly for test versus calling createCamera.
    camera.cameraControl = mockCameraControl;

    await camera.setFlashMode(cameraId, FlashMode.torch);

    verify(mockCameraControl.enableTorch(true));
    expect(camera.torchEnabled, isTrue);
  });

  test(
    'setFlashMode turns off torch mode when non-torch flash modes set',
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
    },
  );

  test('getMinExposureOffset returns expected exposure offset', () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final PigeonInstanceManager testInstanceManager = PigeonInstanceManager(
      onWeakReferenceRemoved: (_) {},
    );
    final ExposureState exposureState = ExposureState.pigeon_detached(
      exposureCompensationRange: CameraIntegerRange.pigeon_detached(
        lower: 3,
        upper: 4,
        pigeon_instanceManager: testInstanceManager,
      ),
      exposureCompensationStep: 0.2,
      pigeon_instanceManager: testInstanceManager,
    );

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = mockCameraInfo;

    when(mockCameraInfo.exposureState).thenReturn(exposureState);

    // We expect the minimum exposure to be the minimum exposure compensation * exposure compensation step.
    // Delta is included due to avoid catching rounding errors.
    expect(await camera.getMinExposureOffset(35), closeTo(0.6, 0.0000000001));
  });

  test('getMaxExposureOffset returns expected exposure offset', () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final PigeonInstanceManager testInstanceManager = PigeonInstanceManager(
      onWeakReferenceRemoved: (_) {},
    );
    final ExposureState exposureState = ExposureState.pigeon_detached(
      exposureCompensationRange: CameraIntegerRange.pigeon_detached(
        lower: 3,
        upper: 4,
        pigeon_instanceManager: testInstanceManager,
      ),
      exposureCompensationStep: 0.2,
      pigeon_instanceManager: testInstanceManager,
    );

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = mockCameraInfo;

    when(mockCameraInfo.exposureState).thenReturn(exposureState);

    // We expect the maximum exposure to be the maximum exposure compensation * exposure compensation step.
    expect(await camera.getMaxExposureOffset(35), 0.8);
  });

  test('getExposureOffsetStepSize returns expected exposure offset', () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    final PigeonInstanceManager testInstanceManager = PigeonInstanceManager(
      onWeakReferenceRemoved: (_) {},
    );
    final ExposureState exposureState = ExposureState.pigeon_detached(
      exposureCompensationRange: CameraIntegerRange.pigeon_detached(
        lower: 3,
        upper: 4,
        pigeon_instanceManager: testInstanceManager,
      ),
      exposureCompensationStep: 0.2,
      pigeon_instanceManager: testInstanceManager,
    );

    // Set directly for test versus calling createCamera.
    camera.cameraInfo = mockCameraInfo;

    when(mockCameraInfo.exposureState).thenReturn(exposureState);

    expect(await camera.getExposureOffsetStepSize(55), 0.2);
  });

  test(
    'getExposureOffsetStepSize returns -1 when exposure compensation not supported on device',
    () async {
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      final MockCameraInfo mockCameraInfo = MockCameraInfo();
      final PigeonInstanceManager testInstanceManager = PigeonInstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final ExposureState exposureState = ExposureState.pigeon_detached(
        exposureCompensationRange: CameraIntegerRange.pigeon_detached(
          lower: 0,
          upper: 0,
          pigeon_instanceManager: testInstanceManager,
        ),
        exposureCompensationStep: 0,
        pigeon_instanceManager: testInstanceManager,
      );

      // Set directly for test versus calling createCamera.
      camera.cameraInfo = mockCameraInfo;

      when(mockCameraInfo.exposureState).thenReturn(exposureState);

      expect(await camera.getExposureOffsetStepSize(55), -1);
    },
  );

  test('getMaxZoomLevel returns expected exposure offset', () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    const double maxZoomRatio = 1;
    final LiveData<ZoomState> mockLiveZoomState = MockLiveZoomState();
    final ZoomState zoomState = ZoomState.pigeon_detached(
      maxZoomRatio: maxZoomRatio,
      minZoomRatio: 0,
      pigeon_instanceManager: PigeonInstanceManager(
        onWeakReferenceRemoved: (_) {},
      ),
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
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final MockCameraInfo mockCameraInfo = MockCameraInfo();
    const double minZoomRatio = 0;
    final LiveData<ZoomState> mockLiveZoomState = MockLiveZoomState();
    final ZoomState zoomState = ZoomState.pigeon_detached(
      maxZoomRatio: 1,
      minZoomRatio: minZoomRatio,
      pigeon_instanceManager: PigeonInstanceManager(
        onWeakReferenceRemoved: (_) {},
      ),
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
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 44;
    const double zoomRatio = 0.3;
    final MockCameraControl mockCameraControl = MockCameraControl();

    // Set directly for test versus calling createCamera.
    camera.cameraControl = mockCameraControl;

    await camera.setZoomLevel(cameraId, zoomRatio);

    verify(mockCameraControl.setZoomRatio(zoomRatio));
  });

  test('Should report support for image streaming', () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    expect(camera.supportsImageStreaming(), true);
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
        newAnalyzer:
            ({
              required void Function(Analyzer, ImageProxy) analyze,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return Analyzer.pigeon_detached(
                analyze: analyze,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
      );

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
      final StreamQueue<CameraImageData> streamQueue =
          StreamQueue<CameraImageData>(imageStream);

      camera.cameraImageDataStreamController!.add(mockCameraImageData);

      expect(await streamQueue.next, equals(mockCameraImageData));
      await streamQueue.cancel();
    },
  );

  test(
    'onStreamedFrameAvailable emits CameraImageData when listened to after cancelation',
    () async {
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      final MockProcessCameraProvider mockProcessCameraProvider =
          MockProcessCameraProvider();
      const int cameraId = 22;

      // Tell plugin to create detached Analyzer for testing.
      camera.proxy = CameraXProxy(
        newAnalyzer:
            ({
              required void Function(Analyzer, ImageProxy) analyze,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return Analyzer.pigeon_detached(
                analyze: analyze,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
      );

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
      final StreamQueue<CameraImageData> streamQueue =
          StreamQueue<CameraImageData>(imageStream2);
      camera.cameraImageDataStreamController!.add(mockCameraImageData);

      expect(await streamQueue.next, equals(mockCameraImageData));
      await streamQueue.cancel();
    },
  );

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
        newAnalyzer:
            ({
              required void Function(Analyzer, ImageProxy) analyze,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return Analyzer.pigeon_detached(
                analyze: analyze,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
        newObserver:
            <T>({
              required void Function(Observer<T>, T) onChanged,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return Observer<T>.detached(
                onChanged: onChanged,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
      );

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
      camera.proxy = CameraXProxy(
        newAnalyzer:
            ({
              required void Function(Analyzer, ImageProxy) analyze,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) => MockAnalyzer(),
      );

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
        newAnalyzer:
            ({
              required void Function(Analyzer, ImageProxy) analyze,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) => MockAnalyzer(),
        newDeviceOrientationManager:
            ({
              required void Function(DeviceOrientationManager, String)
              onDeviceOrientationChanged,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              final MockDeviceOrientationManager manager =
                  MockDeviceOrientationManager();
              when(manager.getDefaultDisplayRotation()).thenAnswer((_) async {
                return defaultTargetRotation;
              });
              return manager;
            },
      );

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
    },
  );

  test(
    'unlockCaptureOrientation sets capture-related use case target rotations to current photo/video orientation',
    () async {
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const int cameraId = 57;

      camera.captureOrientationLocked = true;
      await camera.unlockCaptureOrientation(cameraId);
      expect(camera.captureOrientationLocked, isFalse);
    },
  );

  test(
    'setExposureMode sets expected controlAeLock value via Camera2 interop',
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
      final PigeonInstanceManager testInstanceManager = PigeonInstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final CaptureRequestKey controlAELockKey =
          CaptureRequestKey.pigeon_detached(
            pigeon_instanceManager: testInstanceManager,
          );
      camera.proxy = CameraXProxy(
        fromCamera2CameraControl:
            ({
              required CameraControl cameraControl,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) => cameraControl == mockCameraControl
            ? mockCamera2CameraControl
            : Camera2CameraControl.pigeon_detached(
                pigeon_instanceManager: testInstanceManager,
              ),
        newCaptureRequestOptions:
            ({
              required Map<CaptureRequestKey, Object?> options,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              final MockCaptureRequestOptions mockCaptureRequestOptions =
                  MockCaptureRequestOptions();
              options.forEach((CaptureRequestKey key, Object? value) {
                when(
                  mockCaptureRequestOptions.getCaptureRequestOption(key),
                ).thenAnswer((_) async => value);
              });
              return mockCaptureRequestOptions;
            },
        controlAELockCaptureRequest: () => controlAELockKey,
      );

      // Test auto mode.
      await camera.setExposureMode(cameraId, ExposureMode.auto);

      VerificationResult verificationResult = verify(
        mockCamera2CameraControl.addCaptureRequestOptions(captureAny),
      );
      CaptureRequestOptions capturedCaptureRequestOptions =
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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const int cameraId = 93;
      final MockCameraControl mockCameraControl = MockCameraControl();
      final MockCameraInfo mockCameraInfo = MockCameraInfo();

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = mockCameraInfo;

      final MockFocusMeteringActionBuilder mockActionBuilder =
          MockFocusMeteringActionBuilder();
      final PigeonInstanceManager testInstanceManager = PigeonInstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      when(mockActionBuilder.build()).thenAnswer(
        (_) async => FocusMeteringAction.pigeon_detached(
          meteringPointsAe: const <MeteringPoint>[],
          meteringPointsAf: const <MeteringPoint>[],
          meteringPointsAwb: const <MeteringPoint>[],
          isAutoCancelEnabled: false,
          pigeon_instanceManager: testInstanceManager,
        ),
      );
      MeteringMode? actionBuilderMeteringMode;
      MeteringPoint? actionBuilderMeteringPoint;
      camera.proxy = getProxyForExposureAndFocus(
        withModeFocusMeteringActionBuilder:
            ({
              required MeteringMode mode,
              required MeteringPoint point,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
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
      final FocusMeteringAction originalMeteringAction =
          FocusMeteringAction.pigeon_detached(
            meteringPointsAe: <MeteringPoint>[
              MeteringPoint.pigeon_detached(
                pigeon_instanceManager: testInstanceManager,
              ),
            ],
            meteringPointsAf: <MeteringPoint>[
              MeteringPoint.pigeon_detached(
                pigeon_instanceManager: testInstanceManager,
              ),
            ],
            meteringPointsAwb: const <MeteringPoint>[],
            isAutoCancelEnabled: false,
            pigeon_instanceManager: testInstanceManager,
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
        meteringPointsAe: <MeteringPoint>[
          MeteringPoint.pigeon_detached(
            pigeon_instanceManager: testInstanceManager,
          ),
        ],
        meteringPointsAf: const <MeteringPoint>[],
        meteringPointsAwb: const <MeteringPoint>[],
        isAutoCancelEnabled: false,
        pigeon_instanceManager: testInstanceManager,
      );

      await camera.setExposurePoint(cameraId, null);

      verify(mockCameraControl.cancelFocusAndMetering());
    },
  );

  test(
    'setExposurePoint throws CameraException if invalid point specified',
    () async {
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const int cameraId = 23;
      final MockCameraControl mockCameraControl = MockCameraControl();
      const Point<double> invalidExposurePoint = Point<double>(3, -1);

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = MockCameraInfo();

      camera.proxy = getProxyForExposureAndFocus();

      expect(
        () => camera.setExposurePoint(cameraId, invalidExposurePoint),
        throwsA(isA<CameraException>()),
      );
    },
  );

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

      final PigeonInstanceManager testInstanceManager = PigeonInstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      double exposurePointX = 0.8;
      double exposurePointY = 0.1;
      final MeteringPoint createdMeteringPoint = MeteringPoint.pigeon_detached(
        pigeon_instanceManager: testInstanceManager,
      );
      MeteringMode? actionBuilderMeteringMode;
      MeteringPoint? actionBuilderMeteringPoint;
      final MockFocusMeteringActionBuilder mockActionBuilder =
          MockFocusMeteringActionBuilder();
      when(mockActionBuilder.build()).thenAnswer(
        (_) async => FocusMeteringAction.pigeon_detached(
          meteringPointsAe: const <MeteringPoint>[],
          meteringPointsAf: const <MeteringPoint>[],
          meteringPointsAwb: const <MeteringPoint>[],
          isAutoCancelEnabled: false,
          pigeon_instanceManager: testInstanceManager,
        ),
      );
      camera.proxy = getProxyForExposureAndFocus(
        newDisplayOrientedMeteringPointFactory:
            ({
              required CameraInfo cameraInfo,
              required double width,
              required double height,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              final MockDisplayOrientedMeteringPointFactory mockFactory =
                  MockDisplayOrientedMeteringPointFactory();
              when(
                mockFactory.createPoint(exposurePointX, exposurePointY),
              ).thenAnswer((_) async => createdMeteringPoint);
              return mockFactory;
            },
        withModeFocusMeteringActionBuilder:
            ({
              required MeteringMode mode,
              required MeteringPoint point,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              actionBuilderMeteringMode = mode;
              actionBuilderMeteringPoint = point;
              return mockActionBuilder;
            },
      );

      // Verify current auto-exposure metering point is removed if previously set.
      Point<double> exposurePoint = Point<double>(
        exposurePointX,
        exposurePointY,
      );
      FocusMeteringAction originalMeteringAction =
          FocusMeteringAction.pigeon_detached(
            meteringPointsAe: <MeteringPoint>[
              MeteringPoint.pigeon_detached(
                pigeon_instanceManager: testInstanceManager,
              ),
            ],
            meteringPointsAf: <MeteringPoint>[
              MeteringPoint.pigeon_detached(
                pigeon_instanceManager: testInstanceManager,
              ),
            ],
            meteringPointsAwb: const <MeteringPoint>[],
            isAutoCancelEnabled: false,
            pigeon_instanceManager: testInstanceManager,
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
        meteringPointsAf: <MeteringPoint>[
          MeteringPoint.pigeon_detached(
            pigeon_instanceManager: testInstanceManager,
          ),
        ],
        meteringPointsAwb: const <MeteringPoint>[],
        isAutoCancelEnabled: false,
        pigeon_instanceManager: testInstanceManager,
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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const int cameraId = 19;
      final MockCameraControl mockCameraControl = MockCameraControl();
      const double exposurePointX = 0.8;
      const double exposurePointY = 0.1;
      const Point<double> exposurePoint = Point<double>(
        exposurePointX,
        exposurePointY,
      );

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = MockCameraInfo();
      camera.currentFocusMeteringAction = null;

      final PigeonInstanceManager testInstanceManager = PigeonInstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final MeteringPoint createdMeteringPoint = MeteringPoint.pigeon_detached(
        pigeon_instanceManager: testInstanceManager,
      );
      MeteringMode? actionBuilderMeteringMode;
      MeteringPoint? actionBuilderMeteringPoint;
      final MockFocusMeteringActionBuilder mockActionBuilder =
          MockFocusMeteringActionBuilder();
      when(mockActionBuilder.build()).thenAnswer(
        (_) async => FocusMeteringAction.pigeon_detached(
          meteringPointsAe: const <MeteringPoint>[],
          meteringPointsAf: const <MeteringPoint>[],
          meteringPointsAwb: const <MeteringPoint>[],
          isAutoCancelEnabled: false,
          pigeon_instanceManager: testInstanceManager,
        ),
      );
      camera.proxy = getProxyForExposureAndFocus(
        newDisplayOrientedMeteringPointFactory:
            ({
              required CameraInfo cameraInfo,
              required double width,
              required double height,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              final MockDisplayOrientedMeteringPointFactory mockFactory =
                  MockDisplayOrientedMeteringPointFactory();
              when(
                mockFactory.createPoint(exposurePointX, exposurePointY),
              ).thenAnswer((_) async => createdMeteringPoint);
              return mockFactory;
            },
        withModeFocusMeteringActionBuilder:
            ({
              required MeteringMode mode,
              required MeteringPoint point,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
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
      FocusMeteringAction capturedAction =
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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const int cameraId = 6;
      const double offset = 2;
      final MockCameraInfo mockCameraInfo = MockCameraInfo();
      final PigeonInstanceManager testInstanceManager = PigeonInstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final ExposureState exposureState = ExposureState.pigeon_detached(
        exposureCompensationRange: CameraIntegerRange.pigeon_detached(
          lower: 3,
          upper: 4,
          pigeon_instanceManager: testInstanceManager,
        ),
        exposureCompensationStep: 0,
        pigeon_instanceManager: testInstanceManager,
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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const int cameraId = 11;
      const double offset = 3;
      final MockCameraInfo mockCameraInfo = MockCameraInfo();
      final CameraControl mockCameraControl = MockCameraControl();
      final PigeonInstanceManager testInstanceManager = PigeonInstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final ExposureState exposureState = ExposureState.pigeon_detached(
        exposureCompensationRange: CameraIntegerRange.pigeon_detached(
          lower: 3,
          upper: 4,
          pigeon_instanceManager: testInstanceManager,
        ),
        exposureCompensationStep: 0.2,
        pigeon_instanceManager: testInstanceManager,
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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const int cameraId = 21;
      const double offset = 5;
      final MockCameraInfo mockCameraInfo = MockCameraInfo();
      final CameraControl mockCameraControl = MockCameraControl();
      final PigeonInstanceManager testInstanceManager = PigeonInstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final ExposureState exposureState = ExposureState.pigeon_detached(
        exposureCompensationRange: CameraIntegerRange.pigeon_detached(
          lower: 3,
          upper: 4,
          pigeon_instanceManager: testInstanceManager,
        ),
        exposureCompensationStep: 0.1,
        pigeon_instanceManager: testInstanceManager,
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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const int cameraId = 11;
      const double offset = 3;
      final MockCameraInfo mockCameraInfo = MockCameraInfo();
      final CameraControl mockCameraControl = MockCameraControl();
      final PigeonInstanceManager testInstanceManager = PigeonInstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final ExposureState exposureState = ExposureState.pigeon_detached(
        exposureCompensationRange: CameraIntegerRange.pigeon_detached(
          lower: 3,
          upper: 4,
          pigeon_instanceManager: testInstanceManager,
        ),
        exposureCompensationStep: 0.2,
        pigeon_instanceManager: testInstanceManager,
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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const int cameraId = 93;
      final MockCameraControl mockCameraControl = MockCameraControl();
      final MockCameraInfo mockCameraInfo = MockCameraInfo();

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = mockCameraInfo;

      final MockFocusMeteringActionBuilder mockActionBuilder =
          MockFocusMeteringActionBuilder();
      final PigeonInstanceManager testInstanceManager = PigeonInstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      when(mockActionBuilder.build()).thenAnswer(
        (_) async => FocusMeteringAction.pigeon_detached(
          meteringPointsAe: const <MeteringPoint>[],
          meteringPointsAf: const <MeteringPoint>[],
          meteringPointsAwb: const <MeteringPoint>[],
          isAutoCancelEnabled: false,
          pigeon_instanceManager: testInstanceManager,
        ),
      );
      MeteringMode? actionBuilderMeteringMode;
      MeteringPoint? actionBuilderMeteringPoint;
      camera.proxy = getProxyForExposureAndFocus(
        withModeFocusMeteringActionBuilder:
            ({
              required MeteringMode mode,
              required MeteringPoint point,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
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

      final FocusMeteringAction originalMeteringAction =
          FocusMeteringAction.pigeon_detached(
            meteringPointsAe: <MeteringPoint>[
              MeteringPoint.pigeon_detached(
                pigeon_instanceManager: testInstanceManager,
              ),
            ],
            meteringPointsAf: <MeteringPoint>[
              MeteringPoint.pigeon_detached(
                pigeon_instanceManager: testInstanceManager,
              ),
            ],
            meteringPointsAwb: const <MeteringPoint>[],
            isAutoCancelEnabled: false,
            pigeon_instanceManager: testInstanceManager,
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
        meteringPointsAf: <MeteringPoint>[
          MeteringPoint.pigeon_detached(
            pigeon_instanceManager: testInstanceManager,
          ),
        ],
        meteringPointsAwb: const <MeteringPoint>[],
        isAutoCancelEnabled: false,
        pigeon_instanceManager: testInstanceManager,
      );

      await camera.setFocusPoint(cameraId, null);

      verify(mockCameraControl.cancelFocusAndMetering());
    },
  );

  test(
    'setFocusPoint throws CameraException if invalid point specified',
    () async {
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const int cameraId = 23;
      final MockCameraControl mockCameraControl = MockCameraControl();
      const Point<double> invalidFocusPoint = Point<double>(-3, 1);

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = MockCameraInfo();

      camera.proxy = getProxyForExposureAndFocus();

      expect(
        () => camera.setFocusPoint(cameraId, invalidFocusPoint),
        throwsA(isA<CameraException>()),
      );
    },
  );

  test(
    'setFocusPoint adds new focus point to focus metering action to start as expected when previous metering points have been set',
    () async {
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const int cameraId = 9;
      final MockCameraControl mockCameraControl = MockCameraControl();
      final MockCameraInfo mockCameraInfo = MockCameraInfo();

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = mockCameraInfo;

      final PigeonInstanceManager testInstanceManager = PigeonInstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      double focusPointX = 0.8;
      double focusPointY = 0.1;
      Point<double> focusPoint = Point<double>(focusPointX, focusPointY);
      final MeteringPoint createdMeteringPoint = MeteringPoint.pigeon_detached(
        pigeon_instanceManager: testInstanceManager,
      );
      MeteringMode? actionBuilderMeteringMode;
      MeteringPoint? actionBuilderMeteringPoint;
      final MockFocusMeteringActionBuilder mockActionBuilder =
          MockFocusMeteringActionBuilder();
      when(mockActionBuilder.build()).thenAnswer(
        (_) async => FocusMeteringAction.pigeon_detached(
          meteringPointsAe: const <MeteringPoint>[],
          meteringPointsAf: const <MeteringPoint>[],
          meteringPointsAwb: const <MeteringPoint>[],
          isAutoCancelEnabled: false,
          pigeon_instanceManager: testInstanceManager,
        ),
      );
      camera.proxy = getProxyForExposureAndFocus(
        newDisplayOrientedMeteringPointFactory:
            ({
              required CameraInfo cameraInfo,
              required double width,
              required double height,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              final MockDisplayOrientedMeteringPointFactory mockFactory =
                  MockDisplayOrientedMeteringPointFactory();
              when(
                mockFactory.createPoint(focusPointX, focusPointY),
              ).thenAnswer((_) async => createdMeteringPoint);
              return mockFactory;
            },
        withModeFocusMeteringActionBuilder:
            ({
              required MeteringMode mode,
              required MeteringPoint point,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              actionBuilderMeteringMode = mode;
              actionBuilderMeteringPoint = point;
              return mockActionBuilder;
            },
      );

      // Verify current auto-exposure metering point is removed if previously set.
      FocusMeteringAction originalMeteringAction =
          FocusMeteringAction.pigeon_detached(
            meteringPointsAe: <MeteringPoint>[
              MeteringPoint.pigeon_detached(
                pigeon_instanceManager: testInstanceManager,
              ),
            ],
            meteringPointsAf: <MeteringPoint>[
              MeteringPoint.pigeon_detached(
                pigeon_instanceManager: testInstanceManager,
              ),
            ],
            meteringPointsAwb: const <MeteringPoint>[],
            isAutoCancelEnabled: false,
            pigeon_instanceManager: testInstanceManager,
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
        meteringPointsAe: <MeteringPoint>[
          MeteringPoint.pigeon_detached(
            pigeon_instanceManager: testInstanceManager,
          ),
        ],
        meteringPointsAf: const <MeteringPoint>[],
        meteringPointsAwb: const <MeteringPoint>[],
        isAutoCancelEnabled: false,
        pigeon_instanceManager: testInstanceManager,
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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const int cameraId = 19;
      final MockCameraControl mockCameraControl = MockCameraControl();
      const double focusPointX = 0.8;
      const double focusPointY = 0.1;
      const Point<double> focusPoint = Point<double>(focusPointX, focusPointY);

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = MockCameraInfo();
      camera.currentFocusMeteringAction = null;

      final PigeonInstanceManager testInstanceManager = PigeonInstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final MeteringPoint createdMeteringPoint = MeteringPoint.pigeon_detached(
        pigeon_instanceManager: testInstanceManager,
      );
      MeteringMode? actionBuilderMeteringMode;
      MeteringPoint? actionBuilderMeteringPoint;
      final MockFocusMeteringActionBuilder mockActionBuilder =
          MockFocusMeteringActionBuilder();
      when(mockActionBuilder.build()).thenAnswer(
        (_) async => FocusMeteringAction.pigeon_detached(
          meteringPointsAe: const <MeteringPoint>[],
          meteringPointsAf: const <MeteringPoint>[],
          meteringPointsAwb: const <MeteringPoint>[],
          isAutoCancelEnabled: false,
          pigeon_instanceManager: testInstanceManager,
        ),
      );
      camera.proxy = getProxyForExposureAndFocus(
        newDisplayOrientedMeteringPointFactory:
            ({
              required CameraInfo cameraInfo,
              required double width,
              required double height,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              final MockDisplayOrientedMeteringPointFactory mockFactory =
                  MockDisplayOrientedMeteringPointFactory();
              when(
                mockFactory.createPoint(focusPointX, focusPointY),
              ).thenAnswer((_) async => createdMeteringPoint);
              return mockFactory;
            },
        withModeFocusMeteringActionBuilder:
            ({
              required MeteringMode mode,
              required MeteringPoint point,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
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
      FocusMeteringAction capturedAction =
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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const int cameraId = 4;
      final MockCameraControl mockCameraControl = MockCameraControl();
      final MockFocusMeteringResult mockFocusMeteringResult =
          MockFocusMeteringResult();

      // Set directly for test versus calling createCamera.
      camera.cameraControl = mockCameraControl;
      camera.cameraInfo = MockCameraInfo();

      camera.proxy = getProxyForSettingFocusandExposurePoints(
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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      const int cameraId = 4;
      final MockCameraControl mockCameraControl = MockCameraControl();

      // Camera uses auto-focus by default, so try setting auto mode again.
      await camera.setFocusMode(cameraId, FocusMode.auto);

      verifyNoMoreInteractions(mockCameraControl);
    },
  );

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

      when(
        mockCamera2CameraControl.addCaptureRequestOptions(any),
      ).thenAnswer((_) async => Future<void>.value());

      final PigeonInstanceManager testInstanceManager = PigeonInstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final List<MeteringPoint> createdMeteringPoints = <MeteringPoint>[];
      camera.proxy = getProxyForSettingFocusandExposurePoints(
        mockCameraControl,
        mockCamera2CameraControl,
        newDisplayOrientedMeteringPointFactory:
            ({
              required CameraInfo cameraInfo,
              required double width,
              required double height,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              final MockDisplayOrientedMeteringPointFactory mockFactory =
                  MockDisplayOrientedMeteringPointFactory();
              when(
                mockFactory.createPoint(exposurePointX, exposurePointY),
              ).thenAnswer((_) async {
                final MeteringPoint createdMeteringPoint =
                    MeteringPoint.pigeon_detached(
                      pigeon_instanceManager: testInstanceManager,
                    );
                createdMeteringPoints.add(createdMeteringPoint);
                return createdMeteringPoint;
              });
              when(mockFactory.createPointWithSize(0.5, 0.5, 1)).thenAnswer((
                _,
              ) async {
                final MeteringPoint createdMeteringPoint =
                    MeteringPoint.pigeon_detached(
                      pigeon_instanceManager: testInstanceManager,
                    );
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
      final FocusMeteringAction capturedAction =
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

      when(
        mockCamera2CameraControl.addCaptureRequestOptions(any),
      ).thenAnswer((_) async => Future<void>.value());

      camera.proxy = getProxyForSettingFocusandExposurePoints(
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

      when(
        mockCamera2CameraControl.addCaptureRequestOptions(any),
      ).thenAnswer((_) async => Future<void>.value());

      camera.proxy = getProxyForSettingFocusandExposurePoints(
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
      final FocusMeteringAction capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isTrue);
      expect(capturedAction.meteringPointsAe.length, equals(0));
      expect(capturedAction.meteringPointsAf.length, equals(1));
      expect(capturedAction.meteringPointsAwb.length, equals(0));
      final TestMeteringPoint focusPoint =
          capturedAction.meteringPointsAf.single as TestMeteringPoint;
      expect(focusPoint.x, equals(focusPointX));
      expect(focusPoint.y, equals(focusPointY));
      expect(focusPoint.size, isNull);
    },
  );

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

      when(
        mockCamera2CameraControl.addCaptureRequestOptions(any),
      ).thenAnswer((_) async => Future<void>.value());

      camera.proxy = getProxyForSettingFocusandExposurePoints(
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
      final FocusMeteringAction capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isFalse);

      // We expect the set focus point to be locked.
      expect(capturedAction.meteringPointsAe.length, equals(0));
      expect(capturedAction.meteringPointsAf.length, equals(1));
      expect(capturedAction.meteringPointsAwb.length, equals(0));

      final TestMeteringPoint focusPoint =
          capturedAction.meteringPointsAf.single as TestMeteringPoint;
      expect(focusPoint.x, equals(focusPointX));
      expect(focusPoint.y, equals(focusPointY));
      expect(focusPoint.size, isNull);
    },
  );

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

      when(
        mockCamera2CameraControl.addCaptureRequestOptions(any),
      ).thenAnswer((_) async => Future<void>.value());

      camera.proxy = getProxyForSettingFocusandExposurePoints(
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
      final FocusMeteringAction capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isFalse);

      // We expect two MeteringPoints, the set focus point and the set exposure
      // point.
      expect(capturedAction.meteringPointsAe.length, equals(1));
      expect(capturedAction.meteringPointsAf.length, equals(1));
      expect(capturedAction.meteringPointsAwb.length, equals(0));

      final TestMeteringPoint focusPoint =
          capturedAction.meteringPointsAf.single as TestMeteringPoint;
      expect(focusPoint.x, equals(focusPointX));
      expect(focusPoint.y, equals(focusPointY));
      expect(focusPoint.size, isNull);

      final TestMeteringPoint exposurePoint =
          capturedAction.meteringPointsAe.single as TestMeteringPoint;
      expect(exposurePoint.x, equals(exposurePointX));
      expect(exposurePoint.y, equals(exposurePointY));
      expect(exposurePoint.size, isNull);
    },
  );

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

      when(
        mockCamera2CameraControl.addCaptureRequestOptions(any),
      ).thenAnswer((_) async => Future<void>.value());

      camera.proxy = getProxyForSettingFocusandExposurePoints(
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
      final FocusMeteringAction capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isFalse);

      // We expect two MeteringPoints, the default focus point and the set
      //exposure point.
      expect(capturedAction.meteringPointsAe.length, equals(1));
      expect(capturedAction.meteringPointsAf.length, equals(1));
      expect(capturedAction.meteringPointsAwb.length, equals(0));

      final TestMeteringPoint focusPoint =
          capturedAction.meteringPointsAf.single as TestMeteringPoint;
      expect(focusPoint.x, equals(defaultFocusPointX));
      expect(focusPoint.y, equals(defaultFocusPointY));
      expect(focusPoint.size, equals(defaultFocusPointSize));

      final TestMeteringPoint exposurePoint =
          capturedAction.meteringPointsAe.single as TestMeteringPoint;
      expect(exposurePoint.x, equals(exposurePointX));
      expect(exposurePoint.y, equals(exposurePointY));
      expect(exposurePoint.size, isNull);
    },
  );

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

      when(
        mockCamera2CameraControl.addCaptureRequestOptions(any),
      ).thenAnswer((_) async => Future<void>.value());

      camera.proxy = getProxyForSettingFocusandExposurePoints(
        mockCameraControl,
        mockCamera2CameraControl,
      );

      // Lock focus point.
      await camera.setFocusMode(cameraId, FocusMode.locked);

      final VerificationResult verificationResult = verify(
        mockCameraControl.startFocusAndMetering(captureAny),
      );
      final FocusMeteringAction capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isFalse);

      // We expect only the default focus point to be set.
      expect(capturedAction.meteringPointsAe.length, equals(0));
      expect(capturedAction.meteringPointsAf.length, equals(1));
      expect(capturedAction.meteringPointsAwb.length, equals(0));

      final TestMeteringPoint focusPoint =
          capturedAction.meteringPointsAf.single as TestMeteringPoint;
      expect(focusPoint.x, equals(defaultFocusPointX));
      expect(focusPoint.y, equals(defaultFocusPointY));
      expect(focusPoint.size, equals(defaultFocusPointSize));
    },
  );

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

      when(
        mockCamera2CameraControl.addCaptureRequestOptions(any),
      ).thenAnswer((_) async => Future<void>.value());

      camera.proxy = getProxyForSettingFocusandExposurePoints(
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
      final CaptureRequestOptions capturedCaptureRequestOptions =
          verificationResult.captured.single as CaptureRequestOptions;
      expect(
        await capturedCaptureRequestOptions.getCaptureRequestOption(
          camera.proxy.controlAELockCaptureRequest(),
        ),
        isFalse,
      );
    },
  );

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
      final FocusMeteringAction capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isFalse);
    },
  );

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
      final FocusMeteringAction capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isFalse);
    },
  );

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
      final FocusMeteringAction capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isTrue);
    },
  );

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
      final FocusMeteringAction capturedAction =
          verificationResult.captured.single as FocusMeteringAction;
      expect(capturedAction.isAutoCancelEnabled, isTrue);
    },
  );

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
        newAnalyzer:
            ({
              required void Function(Analyzer, ImageProxy) analyze,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) => MockAnalyzer(),
        newObserver:
            <T>({
              required void Function(Observer<T>, T) onChanged,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return Observer<T>.detached(
                onChanged: onChanged,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
      );

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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      final MockPendingRecording mockPendingRecording = MockPendingRecording();
      final MockRecording mockRecording = MockRecording();
      final MockCamera mockCamera = MockCamera();
      final MockCameraInfo mockCameraInfo = MockCameraInfo();
      final MockCamera2CameraInfo mockCamera2CameraInfo =
          MockCamera2CameraInfo();

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
      const String outputPath = '/temp/REC123.temp';
      camera.proxy = CameraXProxy(
        newObserver:
            <T>({
              required void Function(Observer<T>, T) onChanged,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return Observer<T>.detached(
                onChanged: onChanged,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
        fromCamera2CameraInfo:
            ({
              required CameraInfo cameraInfo,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) => mockCamera2CameraInfo,
        newSystemServicesManager:
            ({
              required void Function(SystemServicesManager, String)
              onCameraError,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              final MockSystemServicesManager mockSystemServicesManager =
                  MockSystemServicesManager();
              when(
                mockSystemServicesManager.getTempFilePath(
                  camera.videoPrefix,
                  '.temp',
                ),
              ).thenAnswer((_) async => outputPath);
              return mockSystemServicesManager;
            },
        newVideoRecordEventListener:
            ({
              required void Function(VideoRecordEventListener, VideoRecordEvent)
              onEvent,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return VideoRecordEventListener.pigeon_detached(
                onEvent: onEvent,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
        infoSupportedHardwareLevelCameraCharacteristics: () {
          return MockCameraCharacteristicsKey();
        },
      );

      const int cameraId = 7;

      // Mock method calls.
      when(
        camera.recorder!.prepareRecording(outputPath),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.withAudioEnabled(!camera.enableRecordingAudio),
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
        VideoRecordEventStart.pigeon_detached(
          pigeon_instanceManager: PigeonInstanceManager(
            onWeakReferenceRemoved: (_) {},
          ),
        ),
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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      final MockPendingRecording mockPendingRecording = MockPendingRecording();
      final MockRecording mockRecording = MockRecording();
      final MockCamera mockCamera = MockCamera();
      final MockCameraInfo mockCameraInfo = MockCameraInfo();
      final MockCamera2CameraInfo mockCamera2CameraInfo =
          MockCamera2CameraInfo();

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
      const String outputPath = '/temp/REC123.temp';
      camera.proxy = CameraXProxy(
        newObserver:
            <T>({
              required void Function(Observer<T>, T) onChanged,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return Observer<T>.detached(
                onChanged: onChanged,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
        fromCamera2CameraInfo:
            ({
              required CameraInfo cameraInfo,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) => mockCamera2CameraInfo,
        newSystemServicesManager:
            ({
              required void Function(SystemServicesManager, String)
              onCameraError,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              final MockSystemServicesManager mockSystemServicesManager =
                  MockSystemServicesManager();
              when(
                mockSystemServicesManager.getTempFilePath(
                  camera.videoPrefix,
                  '.temp',
                ),
              ).thenAnswer((_) async => outputPath);
              return mockSystemServicesManager;
            },
        newVideoRecordEventListener:
            ({
              required void Function(VideoRecordEventListener, VideoRecordEvent)
              onEvent,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return VideoRecordEventListener.pigeon_detached(
                onEvent: onEvent,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
        infoSupportedHardwareLevelCameraCharacteristics: () {
          return MockCameraCharacteristicsKey();
        },
      );

      const int cameraId = 77;

      // Mock method calls.
      when(
        camera.recorder!.prepareRecording(outputPath),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.withAudioEnabled(!camera.enableRecordingAudio),
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
        VideoRecordEventStart.pigeon_detached(
          pigeon_instanceManager: PigeonInstanceManager(
            onWeakReferenceRemoved: (_) {},
          ),
        ),
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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      final MockPendingRecording mockPendingRecording = MockPendingRecording();
      final MockRecording mockRecording = MockRecording();
      final MockCamera mockCamera = MockCamera();
      final MockCameraInfo mockCameraInfo = MockCameraInfo();
      final MockCamera2CameraInfo mockCamera2CameraInfo =
          MockCamera2CameraInfo();

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
      const String outputPath = '/temp/REC123.temp';
      camera.proxy = CameraXProxy(
        newObserver:
            <T>({
              required void Function(Observer<T>, T) onChanged,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return Observer<T>.detached(
                onChanged: onChanged,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
        fromCamera2CameraInfo:
            ({
              required CameraInfo cameraInfo,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) => mockCamera2CameraInfo,
        newSystemServicesManager:
            ({
              required void Function(SystemServicesManager, String)
              onCameraError,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              final MockSystemServicesManager mockSystemServicesManager =
                  MockSystemServicesManager();
              when(
                mockSystemServicesManager.getTempFilePath(
                  camera.videoPrefix,
                  '.temp',
                ),
              ).thenAnswer((_) async => outputPath);
              return mockSystemServicesManager;
            },
        newVideoRecordEventListener:
            ({
              required void Function(VideoRecordEventListener, VideoRecordEvent)
              onEvent,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return VideoRecordEventListener.pigeon_detached(
                onEvent: onEvent,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
        infoSupportedHardwareLevelCameraCharacteristics: () {
          return MockCameraCharacteristicsKey();
        },
      );

      const int cameraId = 87;

      // Mock method calls.
      when(
        camera.recorder!.prepareRecording(outputPath),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.withAudioEnabled(!camera.enableRecordingAudio),
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
        VideoRecordEventStart.pigeon_detached(
          pigeon_instanceManager: PigeonInstanceManager(
            onWeakReferenceRemoved: (_) {},
          ),
        ),
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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      final MockPendingRecording mockPendingRecording = MockPendingRecording();
      final MockRecording mockRecording = MockRecording();
      final MockCamera mockCamera = MockCamera();
      final MockCameraInfo mockCameraInfo = MockCameraInfo();
      final MockCamera2CameraInfo mockCamera2CameraInfo =
          MockCamera2CameraInfo();

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
      const String outputPath = '/temp/REC123.temp';
      camera.proxy = CameraXProxy(
        newAnalyzer:
            ({
              required void Function(Analyzer, ImageProxy) analyze,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return Analyzer.pigeon_detached(
                analyze: analyze,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
        newObserver:
            <T>({
              required void Function(Observer<T>, T) onChanged,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return Observer<T>.detached(
                onChanged: onChanged,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
        fromCamera2CameraInfo:
            ({
              required CameraInfo cameraInfo,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) => mockCamera2CameraInfo,
        newSystemServicesManager:
            ({
              required void Function(SystemServicesManager, String)
              onCameraError,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              final MockSystemServicesManager mockSystemServicesManager =
                  MockSystemServicesManager();
              when(
                mockSystemServicesManager.getTempFilePath(
                  camera.videoPrefix,
                  '.temp',
                ),
              ).thenAnswer((_) async => outputPath);
              return mockSystemServicesManager;
            },
        newVideoRecordEventListener:
            ({
              required void Function(VideoRecordEventListener, VideoRecordEvent)
              onEvent,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return VideoRecordEventListener.pigeon_detached(
                onEvent: onEvent,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
        infoSupportedHardwareLevelCameraCharacteristics: () {
          return MockCameraCharacteristicsKey();
        },
      );

      const int cameraId = 107;

      // Mock method calls.
      when(
        camera.recorder!.prepareRecording(outputPath),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.withAudioEnabled(!camera.enableRecordingAudio),
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
        VideoRecordEventStart.pigeon_detached(
          pigeon_instanceManager: PigeonInstanceManager(
            onWeakReferenceRemoved: (_) {},
          ),
        ),
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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      final MockPendingRecording mockPendingRecording = MockPendingRecording();
      final MockRecording mockRecording = MockRecording();
      final MockCamera mockCamera = MockCamera();
      final MockCameraInfo mockCameraInfo = MockCameraInfo();
      final MockCamera2CameraInfo mockCamera2CameraInfo =
          MockCamera2CameraInfo();

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
      const String outputPath = '/temp/REC123.temp';
      camera.proxy = CameraXProxy(
        newAnalyzer:
            ({
              required void Function(Analyzer, ImageProxy) analyze,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return Analyzer.pigeon_detached(
                analyze: analyze,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
        newObserver:
            <T>({
              required void Function(Observer<T>, T) onChanged,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return Observer<T>.detached(
                onChanged: onChanged,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
        fromCamera2CameraInfo:
            ({
              required CameraInfo cameraInfo,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) => mockCamera2CameraInfo,
        newSystemServicesManager:
            ({
              required void Function(SystemServicesManager, String)
              onCameraError,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              final MockSystemServicesManager mockSystemServicesManager =
                  MockSystemServicesManager();
              when(
                mockSystemServicesManager.getTempFilePath(
                  camera.videoPrefix,
                  '.temp',
                ),
              ).thenAnswer((_) async => outputPath);
              return mockSystemServicesManager;
            },
        newVideoRecordEventListener:
            ({
              required void Function(VideoRecordEventListener, VideoRecordEvent)
              onEvent,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return VideoRecordEventListener.pigeon_detached(
                onEvent: onEvent,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
        infoSupportedHardwareLevelCameraCharacteristics: () {
          return MockCameraCharacteristicsKey();
        },
      );

      const int cameraId = 97;

      // Mock method calls.
      when(
        camera.recorder!.prepareRecording(outputPath),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.withAudioEnabled(!camera.enableRecordingAudio),
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
        VideoRecordEventStart.pigeon_detached(
          pigeon_instanceManager: PigeonInstanceManager(
            onWeakReferenceRemoved: (_) {},
          ),
        ),
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
      final AndroidCameraCameraX camera = AndroidCameraCameraX();
      final MockPendingRecording mockPendingRecording = MockPendingRecording();
      final MockRecording mockRecording = MockRecording();
      final MockCamera mockCamera = MockCamera();
      final MockCameraInfo mockCameraInfo = MockCameraInfo();
      final MockCamera2CameraInfo mockCamera2CameraInfo =
          MockCamera2CameraInfo();

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
      const String outputPath = '/temp/REC123.temp';
      camera.proxy = CameraXProxy(
        newAnalyzer:
            ({
              required void Function(Analyzer, ImageProxy) analyze,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return Analyzer.pigeon_detached(
                analyze: analyze,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
        newObserver:
            <T>({
              required void Function(Observer<T>, T) onChanged,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return Observer<T>.detached(
                onChanged: onChanged,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
        fromCamera2CameraInfo:
            ({
              required CameraInfo cameraInfo,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) => mockCamera2CameraInfo,
        newSystemServicesManager:
            ({
              required void Function(SystemServicesManager, String)
              onCameraError,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              final MockSystemServicesManager mockSystemServicesManager =
                  MockSystemServicesManager();
              when(
                mockSystemServicesManager.getTempFilePath(
                  camera.videoPrefix,
                  '.temp',
                ),
              ).thenAnswer((_) async => outputPath);
              return mockSystemServicesManager;
            },
        newVideoRecordEventListener:
            ({
              required void Function(VideoRecordEventListener, VideoRecordEvent)
              onEvent,
              // ignore: non_constant_identifier_names
              BinaryMessenger? pigeon_binaryMessenger,
              // ignore: non_constant_identifier_names
              PigeonInstanceManager? pigeon_instanceManager,
            }) {
              return VideoRecordEventListener.pigeon_detached(
                onEvent: onEvent,
                pigeon_instanceManager: PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
        infoSupportedHardwareLevelCameraCharacteristics: () {
          return MockCameraCharacteristicsKey();
        },
      );

      const int cameraId = 44;

      // Mock method calls.
      when(
        camera.recorder!.prepareRecording(outputPath),
      ).thenAnswer((_) async => mockPendingRecording);
      when(
        mockPendingRecording.withAudioEnabled(!camera.enableRecordingAudio),
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
        VideoRecordEventStart.pigeon_detached(
          pigeon_instanceManager: PigeonInstanceManager(
            onWeakReferenceRemoved: (_) {},
          ),
        ),
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
    },
  );
}

class TestMeteringPoint extends MeteringPoint {
  TestMeteringPoint.detached({required this.x, required this.y, this.size})
    : super.pigeon_detached(
        pigeon_instanceManager: PigeonInstanceManager(
          onWeakReferenceRemoved: (_) {},
        ),
      );

  final double x;
  final double y;
  final double? size;
}
