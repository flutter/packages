// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

// ignore_for_file: non_constant_identifier_names

import 'camerax_library.dart';

/// Handles constructing objects and calling static methods for the Android
/// Interactive Media Ads native library.
///
/// This class provides dependency injection for the implementations of the
/// platform interface classes. Improving the ease of unit testing and/or
/// overriding the underlying Android classes.
///
/// By default each function calls the default constructor of the class it
/// intends to return.
class CameraXProxy {
  /// Constructs an [CameraXProxy].
  CameraXProxy({
    this.setUpGenericsProxy = setUpGenerics,
    this.newCameraSize = CameraSize.new,
    this.newCameraIntegerRange = CameraIntegerRange.new,
    this.newObserver = Observer.new,
    this.newCameraSelector = CameraSelector.new,
    this.newSystemServicesManager = SystemServicesManager.new,
    this.newDeviceOrientationManager = DeviceOrientationManager.new,
    this.newPreview = Preview.new,
    this.withOutputVideoCapture = VideoCapture.withOutput,
    this.newRecorder = Recorder.new,
    this.newVideoRecordEventListener = VideoRecordEventListener.new,
    this.newImageCapture = ImageCapture.new,
    this.newResolutionStrategy = ResolutionStrategy.new,
    this.newResolutionSelector = ResolutionSelector.new,
    this.newAspectRatioStrategy = AspectRatioStrategy.new,
    this.newImageAnalysis = ImageAnalysis.new,
    this.newAnalyzer = Analyzer.new,
    this.fromQualitySelector = QualitySelector.from,
    this.fromOrderedListQualitySelector = QualitySelector.fromOrderedList,
    this.higherQualityOrLowerThanFallbackStrategy =
        FallbackStrategy.higherQualityOrLowerThan,
    this.higherQualityThanFallbackStrategy = FallbackStrategy.higherQualityThan,
    this.lowerQualityOrHigherThanFallbackStrategy =
        FallbackStrategy.lowerQualityOrHigherThan,
    this.lowerQualityThanFallbackStrategy = FallbackStrategy.lowerQualityThan,
    this.newFocusMeteringActionBuilder = FocusMeteringActionBuilder.new,
    this.withModeFocusMeteringActionBuilder =
        FocusMeteringActionBuilder.withMode,
    this.newCaptureRequestOptions = CaptureRequestOptions.new,
    this.fromCamera2CameraControl = Camera2CameraControl.from,
    this.createWithOnePreferredSizeResolutionFilter =
        ResolutionFilter.createWithOnePreferredSize,
    this.fromCamera2CameraInfo = Camera2CameraInfo.from,
    this.newDisplayOrientedMeteringPointFactory =
        DisplayOrientedMeteringPointFactory.new,
    this.getInstanceProcessCameraProvider = ProcessCameraProvider.getInstance,
    this.getResolutionQualitySelector = QualitySelector.getResolution,
    this.defaultBackCameraCameraSelector = _defaultBackCameraCameraSelector,
    this.defaultFrontCameraCameraSelector = _defaultFrontCameraCameraSelector,
    this.highestAvailableStrategyResolutionStrategy =
        _highestAvailableStrategyResolutionStrategy,
    this.ratio_16_9FallbackAutoStrategyAspectRatioStrategy =
        _ratio_16_9FallbackAutoStrategyAspectRatioStrategy,
    this.ratio_4_3FallbackAutoStrategyAspectRatioStrategy =
        _ratio_4_3FallbackAutoStrategyAspectRatioStrategy,
    this.controlAELockCaptureRequest = _controlAELockCaptureRequest,
    this.infoSupportedHardwareLevelCameraCharacteristics =
        _infoSupportedHardwareLevelCameraCharacteristics,
    this.sensorOrientationCameraCharacteristics =
        _sensorOrientationCameraCharacteristics,
  });

  /// Handles adding support for generic classes.
  final void Function({
    BinaryMessenger? pigeonBinaryMessenger,
    PigeonInstanceManager? pigeonInstanceManager,
  })
  setUpGenericsProxy;

  /// Constructs [CameraSize].
  final CameraSize Function({
    required int width,
    required int height,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  newCameraSize;

  /// Constructs [CameraIntegerRange].
  final CameraIntegerRange Function({
    required int lower,
    required int upper,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  newCameraIntegerRange;

  /// Constructs [Observer].
  final Observer<T> Function<T>({
    required void Function(Observer<T>, T) onChanged,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  newObserver;

  /// Constructs [CameraSelector].
  final CameraSelector Function({
    LensFacing? requireLensFacing,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  newCameraSelector;

  /// Constructs [SystemServicesManager].
  final SystemServicesManager Function({
    required void Function(SystemServicesManager, String) onCameraError,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  newSystemServicesManager;

  /// Constructs [DeviceOrientationManager].
  final DeviceOrientationManager Function({
    required void Function(DeviceOrientationManager, String)
    onDeviceOrientationChanged,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  newDeviceOrientationManager;

  /// Constructs [Preview].
  final Preview Function({
    int? targetRotation,
    ResolutionSelector? resolutionSelector,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  newPreview;

  /// Constructs [VideoCapture].
  final VideoCapture Function({
    required VideoOutput videoOutput,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  withOutputVideoCapture;

  /// Constructs [Recorder].
  final Recorder Function({
    int? aspectRatio,
    int? targetVideoEncodingBitRate,
    QualitySelector? qualitySelector,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  newRecorder;

  /// Constructs [VideoRecordEventListener].
  final VideoRecordEventListener Function({
    required void Function(VideoRecordEventListener, VideoRecordEvent) onEvent,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  newVideoRecordEventListener;

  /// Constructs [ImageCapture].
  final ImageCapture Function({
    int? targetRotation,
    CameraXFlashMode? flashMode,
    ResolutionSelector? resolutionSelector,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  newImageCapture;

  /// Constructs [ResolutionStrategy].
  final ResolutionStrategy Function({
    required CameraSize boundSize,
    required ResolutionStrategyFallbackRule fallbackRule,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  newResolutionStrategy;

  /// Constructs [ResolutionSelector].
  final ResolutionSelector Function({
    AspectRatioStrategy? aspectRatioStrategy,
    ResolutionStrategy? resolutionStrategy,
    ResolutionFilter? resolutionFilter,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  newResolutionSelector;

  /// Constructs [AspectRatioStrategy].
  final AspectRatioStrategy Function({
    required AspectRatio preferredAspectRatio,
    required AspectRatioStrategyFallbackRule fallbackRule,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  newAspectRatioStrategy;

  /// Constructs [ImageAnalysis].
  final ImageAnalysis Function({
    int? targetRotation,
    ResolutionSelector? resolutionSelector,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  newImageAnalysis;

  /// Constructs [Analyzer].
  final Analyzer Function({
    required void Function(Analyzer, ImageProxy) analyze,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  newAnalyzer;

  /// Constructs [QualitySelector].
  final QualitySelector Function({
    required VideoQuality quality,
    FallbackStrategy? fallbackStrategy,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  fromQualitySelector;

  /// Constructs [QualitySelector].
  final QualitySelector Function({
    required List<VideoQuality> qualities,
    FallbackStrategy? fallbackStrategy,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  fromOrderedListQualitySelector;

  /// Constructs [FallbackStrategy].
  final FallbackStrategy Function({
    required VideoQuality quality,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  higherQualityOrLowerThanFallbackStrategy;

  /// Constructs [FallbackStrategy].
  final FallbackStrategy Function({
    required VideoQuality quality,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  higherQualityThanFallbackStrategy;

  /// Constructs [FallbackStrategy].
  final FallbackStrategy Function({
    required VideoQuality quality,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  lowerQualityOrHigherThanFallbackStrategy;

  /// Constructs [FallbackStrategy].
  final FallbackStrategy Function({
    required VideoQuality quality,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  lowerQualityThanFallbackStrategy;

  /// Constructs [FocusMeteringActionBuilder].
  final FocusMeteringActionBuilder Function({
    required MeteringPoint point,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  newFocusMeteringActionBuilder;

  /// Constructs [FocusMeteringActionBuilder].
  FocusMeteringActionBuilder Function({
    required MeteringPoint point,
    required MeteringMode mode,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  withModeFocusMeteringActionBuilder;

  /// Constructs [CaptureRequestOptions].
  CaptureRequestOptions Function({
    required Map<CaptureRequestKey, Object?> options,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  newCaptureRequestOptions;

  /// Constructs [Camera2CameraControl].
  Camera2CameraControl Function({
    required CameraControl cameraControl,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  fromCamera2CameraControl;

  /// Constructs [ResolutionFilter].
  final ResolutionFilter Function({
    required CameraSize preferredSize,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  createWithOnePreferredSizeResolutionFilter;

  /// Constructs [Camera2CameraInfo].
  final Camera2CameraInfo Function({
    required CameraInfo cameraInfo,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  fromCamera2CameraInfo;

  /// Constructs [DisplayOrientedMeteringPointFactory].
  DisplayOrientedMeteringPointFactory Function({
    required CameraInfo cameraInfo,
    required double width,
    required double height,
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  newDisplayOrientedMeteringPointFactory;

  /// Calls to [ProcessCameraProvider.getInstance].
  final Future<ProcessCameraProvider> Function({
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  getInstanceProcessCameraProvider;

  /// Calls to [QualitySelector.getResolution].
  final Future<CameraSize?> Function(
    CameraInfo,
    VideoQuality, {
    BinaryMessenger? pigeon_binaryMessenger,
    PigeonInstanceManager? pigeon_instanceManager,
  })
  getResolutionQualitySelector;

  /// Calls to [CameraSelector.defaultBackCamera].
  final CameraSelector Function() defaultBackCameraCameraSelector;

  /// Calls to [CameraSelector.defaultFrontCamera].
  final CameraSelector Function() defaultFrontCameraCameraSelector;

  /// Calls to [ResolutionStrategy.highestAvailableStrategy].
  final ResolutionStrategy Function()
  highestAvailableStrategyResolutionStrategy;

  /// Calls to [AspectRatioStrategy.ratio_16_9FallbackAutoStrategy].
  final AspectRatioStrategy Function()
  ratio_16_9FallbackAutoStrategyAspectRatioStrategy;

  /// Calls to [AspectRatioStrategy.ratio_4_3FallbackAutoStrategy].
  final AspectRatioStrategy Function()
  ratio_4_3FallbackAutoStrategyAspectRatioStrategy;

  /// Calls to [CaptureRequest.controlAELock].
  CaptureRequestKey Function() controlAELockCaptureRequest;

  /// Calls to [CameraCharacteristics.infoSupportedHardwareLevel].
  final CameraCharacteristicsKey Function()
  infoSupportedHardwareLevelCameraCharacteristics;

  /// Calls to [CameraCharacteristics.sensorOrientation].
  final CameraCharacteristicsKey Function()
  sensorOrientationCameraCharacteristics;

  static CameraSelector _defaultBackCameraCameraSelector() =>
      CameraSelector.defaultBackCamera;

  static CameraSelector _defaultFrontCameraCameraSelector() =>
      CameraSelector.defaultFrontCamera;

  static ResolutionStrategy _highestAvailableStrategyResolutionStrategy() =>
      ResolutionStrategy.highestAvailableStrategy;

  static AspectRatioStrategy
  _ratio_16_9FallbackAutoStrategyAspectRatioStrategy() =>
      AspectRatioStrategy.ratio_16_9FallbackAutoStrategy;

  static AspectRatioStrategy
  _ratio_4_3FallbackAutoStrategyAspectRatioStrategy() =>
      AspectRatioStrategy.ratio_4_3FallbackAutoStrategy;

  static CaptureRequestKey _controlAELockCaptureRequest() =>
      CaptureRequest.controlAELock;

  static CameraCharacteristicsKey
  _infoSupportedHardwareLevelCameraCharacteristics() =>
      CameraCharacteristics.infoSupportedHardwareLevel;

  static CameraCharacteristicsKey _sensorOrientationCameraCharacteristics() =>
      CameraCharacteristics.sensorOrientation;
}
